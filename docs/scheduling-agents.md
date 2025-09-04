# Scheduling Agents - Automated PM Workflows

> **Turn your n8n workflows and LangFlow flows into automated, time-triggered agents**

## 🎯 Overview

The AIPM scheduling system lets you run any n8n workflow or LangFlow flow on a timer - perfect for automating recurring PM tasks like daily standups, weekly competitive analysis, or regular status reports.

### Key Features

- **Cross-platform**: Works on macOS (cron) and Windows (Task Scheduler)
- **Human-friendly schedules**: "daily at 9am", "every monday at 10am"
- **Full agent integration**: Uses your existing CLI agent scripts
- **Provider switching**: Schedule with LM Studio or Ollama
- **Logging**: All scheduled runs are logged automatically
- **Easy management**: List, add, remove scheduled agents

## 🚀 Quick Start

### Schedule Your First Agent

**macOS/Linux:**
```bash
# Daily standup at 9 AM
./scripts/schedule-agent.sh add n8n YOUR-WORKFLOW-ID "daily at 9am" "Daily Standup" --background

# Weekly competitive analysis every Monday
./scripts/schedule-agent.sh add langflow YOUR-FLOW-ID "every monday at 10am" "Weekly Competitive Analysis" --input "Generate weekly market analysis"
```

**Windows:**
```powershell
# Daily standup at 9 AM
.\scripts\schedule-agent.ps1 add n8n YOUR-WORKFLOW-ID "daily at 9am" "Daily Standup" -Background

# Weekly competitive analysis every Monday  
.\scripts\schedule-agent.ps1 add langflow YOUR-FLOW-ID "every monday at 10am" "Weekly Competitive Analysis" -Input "Generate weekly market analysis"
```

### Manage Scheduled Agents

```bash
# List all scheduled agents
./scripts/schedule-agent.sh list

# Remove a scheduled agent
./scripts/schedule-agent.sh remove daily-standup

# Check scheduling system status
./scripts/schedule-agent.sh status
```

## 📋 Schedule Formats

### Human-Friendly Formats

| Schedule | Description |
|----------|-------------|
| `"daily at 9am"` | Every day at 9:00 AM |
| `"daily at 2:30pm"` | Every day at 2:30 PM |
| `"every monday at 10am"` | Every Monday at 10:00 AM |
| `"every friday at 5pm"` | Every Friday at 5:00 PM |
| `"every 15 minutes"` | Every 15 minutes |
| `"every 30 minutes"` | Every 30 minutes |
| `"hourly"` | Every hour at minute 0 |
| `"daily"` | Every day at midnight |
| `"weekly"` | Every Sunday at midnight |

### Advanced Cron Format (macOS/Linux)

For complex schedules, you can use standard cron expressions:

| Cron Expression | Description |
|----------------|-------------|
| `"0 9 * * 1-5"` | Weekdays at 9 AM |
| `"0 */2 * * *"` | Every 2 hours |
| `"30 8 * * 1"` | Mondays at 8:30 AM |
| `"0 0 1 * *"` | First day of every month |

## 🔧 Command Reference

### macOS/Linux (`schedule-agent.sh`)

```bash
# Add scheduled agent
./schedule-agent.sh add <type> <id> "<schedule>" "<description>" [options]

# Management commands  
./schedule-agent.sh list                    # Show all scheduled agents
./schedule-agent.sh remove <job-name>       # Remove specific agent
./schedule-agent.sh status                  # Show cron service status

# Options
--provider ollama           # Use Ollama instead of LM Studio
--input "text"              # Custom input for LangFlow flows (LangFlow only)
--background                # Run agent in background mode
--log-dir <path>            # Custom log directory
```

### Windows (`schedule-agent.ps1`)

```powershell
# Add scheduled agent
.\schedule-agent.ps1 add <type> <id> "<schedule>" "<description>" [options]

# Management commands
.\schedule-agent.ps1 list                   # Show all scheduled agents  
.\schedule-agent.ps1 remove "<description>" # Remove specific agent
.\schedule-agent.ps1 status                 # Show Task Scheduler status

# Options
-Provider ollama            # Use Ollama instead of LM Studio
-Input "text"               # Custom input for LangFlow flows (LangFlow only)
-Background                 # Run agent in background mode
-LogDir <path>              # Custom log directory
```

## 📖 Examples

### Daily PM Standup Agent

**n8n Workflow:** Daily standup generator with Slack integration

```bash
# macOS
./scripts/schedule-agent.sh add n8n abc123-def456 "daily at 9am" "Daily Standup Generator" --background --provider lmstudio

# Windows
.\scripts\schedule-agent.ps1 add n8n abc123-def456 "daily at 9am" "Daily Standup Generator" -Background -Provider lmstudio
```

### Weekly Competitive Analysis

**LangFlow Flow:** Market analysis with custom prompts

```bash
# macOS
./scripts/schedule-agent.sh add langflow xyz789 "every monday at 10am" "Weekly Competitive Analysis" --input "Analyze competitors in project management space" --background

# Windows  
.\scripts\schedule-agent.ps1 add langflow xyz789 "every monday at 10am" "Weekly Competitive Analysis" -Input "Analyze competitors in project management space" -Background
```

### Status Check Every 15 Minutes

**n8n Workflow:** System health monitoring

```bash
# macOS
./scripts/schedule-agent.sh add n8n monitoring-workflow "every 15 minutes" "System Status Check" --provider ollama

# Windows
.\scripts\schedule-agent.ps1 add n8n monitoring-workflow "every 15 minutes" "System Status Check" -Provider ollama
```

### User Story Generation on Demand

**LangFlow Flow:** Generate user stories for sprint planning

```bash
# macOS - Weekdays at 2 PM for sprint planning
./scripts/schedule-agent.sh add langflow user-story-flow "0 14 * * 1-5" "Sprint Planning User Stories" --input "Generate 3 user stories for mobile app features"

# Windows - Every Tuesday at 2 PM
.\scripts\schedule-agent.ps1 add langflow user-story-flow "every tuesday at 2pm" "Sprint Planning User Stories" -Input "Generate 3 user stories for mobile app features"
```

## 📊 Monitoring and Logs

### Log Files

All scheduled agents create log files automatically:

**macOS/Linux:**
- Default location: `~/aipm-scheduled-agents/`
- Custom location: `--log-dir /path/to/logs`
- File format: `{job-name}.log`

**Windows:**
- Default location: `%USERPROFILE%\aipm-scheduled-agents\`
- Custom location: `-LogDir "C:\path\to\logs"`
- File format: `{description}.log`

### Viewing Logs

```bash
# View recent log entries
tail -f ~/aipm-scheduled-agents/daily-standup-generator.log

# View all logs
ls ~/aipm-scheduled-agents/

# Search for errors
grep -i error ~/aimp-scheduled-agents/*.log
```

### System Status

**Check scheduling service:**

```bash
# macOS/Linux
./scripts/schedule-agent.sh status

# Windows
.\scripts\schedule-agent.ps1 status
```

## 🛠️ Troubleshooting

### Common Issues

**Scheduled agents not running:**

1. **Check scheduling service:**
   ```bash
   # macOS - cron should be managed by launchd
   launchctl list | grep cron
   
   # Linux - check cron service
   sudo systemctl status cron
   
   # Windows - check Task Scheduler service
   Get-Service -Name "Schedule"
   ```

2. **Verify scheduled jobs:**
   ```bash
   # macOS/Linux - check crontab
   crontab -l | grep AIPM
   
   # Windows - open Task Scheduler
   taskschd.msc
   ```

3. **Check permissions:**
   - Ensure scripts are executable: `chmod +x scripts/*.sh`
   - Verify paths are correct in scheduled commands
   - Check environment variables are available to cron/Task Scheduler

**Environment variables not available:**

Scheduled tasks may not have access to your shell environment. Solutions:

1. **Explicit environment setup** (already handled by our scripts):
   ```bash
   # Scripts automatically load .env file
   source /path/to/project/.env
   ```

2. **Full path specifications:**
   ```bash
   # Scripts use absolute paths automatically
   cd /full/path/to/aipm-laptop-llm-kit && ./scripts/run-agent.sh
   ```

**Logs not appearing:**

1. **Check log directory permissions:**
   ```bash
   ls -la ~/aipm-scheduled-agents/
   ```

2. **Manual test:**
   ```bash
   # Test the exact command that cron/Task Scheduler runs
   cd /path/to/project && ./scripts/run-agent.sh WORKFLOW_ID --log test.log
   ```

### macOS-Specific Issues

**Cron not working on macOS Monterey+:**

1. **Grant Terminal Full Disk Access:**
   - System Preferences → Security & Privacy → Privacy → Full Disk Access
   - Add Terminal.app

2. **Check launchd:**
   ```bash
   sudo launchctl list | grep cron
   ```

### Windows-Specific Issues

**Task Scheduler permissions:**

1. **Run PowerShell as Administrator** when creating tasks
2. **Check execution policy:**
   ```powershell
   Get-ExecutionPolicy
   # Should be RemoteSigned or Unrestricted
   ```

3. **Task not running:**
   - Open Task Scheduler (`taskschd.msc`)
   - Find your AIPM task
   - Check "Last Run Result" (0 = success)
   - View History tab for details

## 🎯 Best Practices

### Scheduling Guidelines

1. **Stagger agent runs:**
   - Don't schedule multiple agents at the same time
   - Space out resource-intensive agents

2. **Use background mode:**
   - Always use `--background` or `-Background` for scheduled agents
   - This prevents blocking and enables proper logging

3. **Test before scheduling:**
   ```bash
   # Test manually first
   ./scripts/run-agent.sh WORKFLOW_ID --provider ollama
   
   # Then schedule
   ./scripts/schedule-agent.sh add n8n WORKFLOW_ID "daily at 9am" "Test Agent" --background --provider ollama
   ```

4. **Monitor logs regularly:**
   ```bash
   # Check for errors weekly
   grep -i error ~/aimp-scheduled-agents/*.log
   ```

### Resource Management

1. **Consider LLM availability:**
   - Ensure LM Studio or Ollama is always running
   - Use `--provider ollama` as backup if LM Studio is unreliable

2. **Network dependencies:**
   - Schedule external integrations (Slack, Notion) during business hours
   - Have fallback mechanisms for network failures

3. **Logging rotation:**
   ```bash
   # Clean old logs monthly
   find ~/aipm-scheduled-agents -name "*.log" -mtime +30 -delete
   ```

## 📅 PM-Specific Scheduling Examples

### Sprint Management

```bash
# Sprint planning prep - Fridays at 4 PM
./scripts/schedule-agent.sh add langflow sprint-prep "every friday at 4pm" "Sprint Planning Prep" --input "Analyze completed stories and prepare next sprint candidates"

# Daily standup reminder - Weekdays at 8:45 AM  
./scripts/schedule-agent.sh add n8n standup-reminder "45 8 * * 1-5" "Daily Standup Reminder" --background
```

### Competitive Intelligence

```bash
# Weekly competitive analysis - Mondays at 8 AM
./scripts/schedule-agent.sh add langflow competitive-analysis "every monday at 8am" "Weekly Competitive Analysis" --input "Research competitor product updates and market positioning"

# Monthly deep dive - First Monday of each month
./scripts/schedule-agent.sh add langflow monthly-competitive "0 9 * * 1" "Monthly Competitive Deep Dive" --input "Comprehensive competitive analysis with strategic recommendations"
```

### Stakeholder Communication

```bash
# Weekly stakeholder update - Fridays at 3 PM
./scripts/schedule-agent.sh add n8n stakeholder-update "every friday at 3pm" "Weekly Stakeholder Update" --background

# Monthly executive summary - Last Friday of month at 5 PM
./scripts/schedule-agent.sh add langflow executive-summary "0 17 23-31 * 5" "Monthly Executive Summary" --input "Generate executive summary of product progress and metrics"
```

---

**💡 Pro Tip:** Start with manual agent runs, then schedule the ones that prove valuable. Use descriptive names and consistent scheduling to build reliable PM automation routines!