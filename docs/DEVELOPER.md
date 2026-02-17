# AnchorPoint Monitoring
## Developer Documentation
Maintained by: Brian Hill
Version: 1.0
Last Updated: 2026

---

# 1. Project Purpose

AnchorPoint Monitoring is a lightweight, script-driven system health and log monitoring suite designed for small business environments.

Primary goals:
- Generate daily and weekly system health summaries
- Analyze log activity
- Maintain historical tracking
- Provide configurable alert thresholds
- Support manual deployment without complex infrastructure

This project prioritizes:
- Simplicity
- Transparency
- Low overhead
- Easy deployment

---

# 2. Architecture Overview

The system is file-based and script-driven.

Core components:

- scripts/
  - generate_daily_report.py
  - generate_weekly_report.py
  - log_analyzer.py
  - run_log_check.sh

- config/
  - config.example.conf (template)
  - config.conf (local only, ignored)

- reports/
  - templates/
  - runtime output (ignored)
  - historical reports

- logs/
  - runtime logs (ignored)

There is no database.
State persistence is handled via files inside the reports directory.

---

# 3. Data Flow

1. Script execution begins (manual or scheduled via cron).
2. System metrics are gathered (CPU, memory, disk, etc.).
3. Log analyzer processes log files.
4. Metrics are written to report files.
5. Weekly script aggregates historical daily reports.
6. Output is saved in reports directory.

No external APIs are required for core functionality.

---

# 4. Configuration Model

All environment-specific values are defined in:

config/config.conf

This includes:
- File paths
- Email credentials (if enabled)
- Alert thresholds
- Report output locations

Security model:
- config.conf is ignored via .gitignore
- Only template files are committed

---

# 5. Report Generation Logic

Daily Report:
- Collects current metrics
- Evaluates against thresholds
- Writes summary report
- Updates state markers

Weekly Report:
- Reads daily historical data
- Aggregates metrics
- Generates trend summary
- Writes reusable weekly summary file

---

# 6. Log Analyzer Design

log_analyzer.py:
- Parses defined log files
- Searches for alert keywords
- Counts occurrences
- Returns structured output to report scripts

Future improvements:
- Structured log parsing
- Regex-based pattern system
- JSON output mode

---

# 7. Deployment Model

Developer Environment:
- Local macOS development
- Git version control
- GitHub remote

Client Environment:
- Folder-based deployment
- No Git required
- config.conf created from template
- Manual or cron execution

No installer currently exists.

---

# 8. Security Model

- No credentials stored in repository
- No runtime logs committed
- Templates only
- Minimal external dependencies
- Designed for single-host monitoring

---

# 9. Known Limitations

- No UI dashboard
- No centralized multi-host aggregation
- File-based state management
- Manual deployment model
- No automated installer

---

# 10. Roadmap (Future Enhancements)

- Automated installation script
- Email alert automation
- JSON export mode
- Centralized dashboard version
- Containerized deployment option
- Multi-client configuration profiles

---

# 11. Versioning Philosophy

Version 1.x:
- Stable script-based monitoring
- File-driven reporting

Version 2.x:
- Automation enhancements
- Improved aggregation logic

Version 3.x:
- Optional dashboard layer

---

End of Developer Documentation
