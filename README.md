# AnchorPoint Monitoring v.1.0

## Welcome

AnchorPoint Monitoring is a lightweight system health and log monitoring
suite designed to generate daily and weekly system reports.

This package is delivered as a ready-to-run folder. No Git knowledge is
required for clients.

------------------------------------------------------------------------

## Quick Start (Client Setup)

1.  Install Python 3.11 or newer.
2.  Place this folder anywhere on your system (example: /opt/anchorpoint
    or \~/anchorpoint).
3.  Navigate into the project folder: cd log-project
4.  Create your configuration file: cp config/config.example.conf
    config/config.conf
5.  Edit config/config.conf and update it with your local paths and
    credentials.
6.  Install dependencies: pip install -r requirements.txt
7.  Run a report: python3 scripts/generate_daily_report.py

Generated reports will appear inside the reports/ directory.

------------------------------------------------------------------------

## Important Security Notes

-   The file config/config.conf contains sensitive credentials and is
    not tracked in version control.
-   Always start from config/config.example.conf when creating a new
    client configuration.
-   Log files and internal snapshots remain local and are not shared
    publicly.

------------------------------------------------------------------------

## Folder Overview

scripts/ → Core report generation scripts\
config/ → Configuration files\
reports/ → Generated reports and templates\
logs/ → Local runtime logs\
requirements.txt → Python dependencies

------------------------------------------------------------------------

## Support

For support or deployment assistance, contact AnchorPoint Monitoring.
