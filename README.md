# Bahá’í Date KDE Widget

A simple KDE Plasma widget (plasmoid) that displays the current Bahá’í date.

## Features
- Uses Python `datetime` and `convertdate.bahai` for conversion.
- Refreshes once per minute.
- Uses a simple 18:00 local-time cutoff as a lightweight sunset approximation.

## Requirements
- KDE Plasma 6
- Python 3
- Python package: `convertdate`

Install dependency:

```bash
python3 -m pip install --user convertdate
```

## Install the widget locally

From this repository root:

```bash
kpackagetool6 --type Plasma/Applet --install ./kde-bahai-date-widget
```

To upgrade after changes:

```bash
kpackagetool6 --type Plasma/Applet --upgrade ./kde-bahai-date-widget
```
