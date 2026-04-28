#!/usr/bin/env python3
"""GeoIP lookup using local MaxMind GeoLite2 City database.

Falls back to ipapi.co if the local DB is unavailable or lookup fails.
Outputs JSON: {"latitude": ..., "longitude": ..., "city": ..., "region": ..., "country": ...}
"""
import json
import os
import subprocess
import sys

MMDB_PATH = os.path.join(
    os.path.expanduser("~"), ".config", "awesome", "geoip", "GeoLite2-City.mmdb"
)


def get_public_ip():
    """Get the public-facing IP address."""
    try:
        # Try to get the source IP for an internet route
        result = subprocess.run(
            ["ip", "route", "get", "1.1.1.1"],
            capture_output=True, text=True, timeout=5
        )
        if result.returncode == 0:
            parts = result.stdout.strip().split()
            if "src" in parts:
                return parts[parts.index("src") + 1]
    except Exception:
        pass

    # Fallback: use a simple HTTP service
    try:
        with urllib.request.urlopen("https://icanhazip.com", timeout=10) as resp:
            return resp.read().decode().strip()
    except Exception:
        pass

    try:
        with urllib.request.urlopen("https://ipapi.co/ip/", timeout=10) as resp:
            return resp.read().decode().strip()
    except Exception:
        pass

    return None


def lookup_local(ip):
    """Query local MaxMind DB."""
    try:
        import maxminddb
    except ImportError:
        return None

    if not os.path.isfile(MMDB_PATH):
        return None

    try:
        with maxminddb.open_database(MMDB_PATH) as reader:
            rec = reader.get(ip)
            if not rec:
                return None

            loc = rec.get("location", {})
            lat = loc.get("latitude")
            lon = loc.get("longitude")
            if lat is None or lon is None:
                return None

            city_names = rec.get("city", {}).get("names", {})
            city = city_names.get("en", "")

            subdiv = rec.get("subdivisions", [{}])[0]
            region = subdiv.get("names", {}).get("en", "")

            country_names = rec.get("country", {}).get("names", {})
            country = country_names.get("en", "")

            return {
                "latitude": lat,
                "longitude": lon,
                "city": city,
                "region": region,
                "country": country,
            }
    except Exception:
        return None


def lookup_ipapi():
    """Fallback to ipapi.co via curl (urllib is often blocked)."""
    try:
        result = subprocess.run(
            ["curl", "-s", "-m", "15", "https://ipapi.co/json/"],
            capture_output=True, text=True, timeout=20
        )
        if result.returncode != 0:
            return None
        data = json.loads(result.stdout)
        return {
            "latitude": data.get("latitude"),
            "longitude": data.get("longitude"),
            "city": data.get("city", ""),
            "region": data.get("region", ""),
            "country": data.get("country_name", ""),
        }
    except Exception:
        return None


def main():
    ip = get_public_ip()
    result = None

    if ip:
        result = lookup_local(ip)

    if not result:
        result = lookup_ipapi()

    if result:
        print(json.dumps(result))
        sys.exit(0)
    else:
        print(json.dumps({"error": "all lookups failed"}))
        sys.exit(1)


if __name__ == "__main__":
    main()
