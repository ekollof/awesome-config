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
    """Get the public-facing IP address.

    Tries external IP discovery services first (works through NAT).
    Falls back to the routing table only as a last resort — that src IP
    is often a private address on NATed desktops (10.x/192.168.x).
    """
    # 1. External services (accurate through NAT)
    for url in ("https://icanhazip.com", "https://checkip.amazonaws.com"):
        try:
            with urllib.request.urlopen(url, timeout=10) as resp:
                ip = resp.read().decode().strip()
                # Sanity check: ignore private/reserved
                if ip and not ip.startswith(("10.", "192.168.", "172.16.", "172.17.",
                                              "172.18.", "172.19.", "172.20.", "172.21.",
                                              "172.22.", "172.23.", "172.24.", "172.25.",
                                              "172.26.", "172.27.", "172.28.", "172.29.",
                                              "172.30.", "172.31.", "127.")):
                    return ip
        except Exception:
            pass

    # 2. Fallback to routing table (may be private behind NAT, but try anyway)
    try:
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
