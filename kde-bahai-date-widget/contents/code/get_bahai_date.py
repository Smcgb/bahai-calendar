#!/usr/bin/env python3
"""Return the current Bahá’í date as text for a Plasma widget."""

from __future__ import annotations

from datetime import datetime, timedelta

try:
    from convertdate import bahai
except ModuleNotFoundError:
    print("Bahá’í date dependency missing: install python3-convertdate")
    raise SystemExit(0)


BAHAI_MONTH_NAMES = {
    0: "Ayyám-i-Há",
    1: "Bahá",
    2: "Jalál",
    3: "Jamál",
    4: "‘Aẓamat",
    5: "Núr",
    6: "Raḥmat",
    7: "Kalimát",
    8: "Kamál",
    9: "Asmá’",
    10: "‘Izzat",
    11: "Mashíyyat",
    12: "‘Ilm",
    13: "Qudrat",
    14: "Qawl",
    15: "Masá’il",
    16: "Sharaf",
    17: "Sulṭán",
    18: "Mulk",
    19: "‘Alá’",
}


now = datetime.now().astimezone()
gregorian_day = now.date()

# The Bahá’í day starts at sunset. For a lightweight local approximation,
# treat 18:00 local time and later as the next Bahá’í day.
if now.hour >= 18:
    gregorian_day += timedelta(days=1)

b_year, b_month, b_day = bahai.from_gregorian(
    gregorian_day.year,
    gregorian_day.month,
    gregorian_day.day,
)
month_name = BAHAI_MONTH_NAMES.get(b_month, f"Month {b_month}")
print(f"{b_day} {month_name} {b_year} B.E.")
