# AIPM Laptop LLM Kit - Agent Scheduler for Windows PowerShell
# Schedule n8n workflows and LangFlow flows to run on a timer using Task Scheduler
#
# Usage:
#   .\schedule-agent.ps1 add n8n WORKFLOW_ID "daily at 9am" "Daily standup generator"
#   .\schedule-agent.ps1 add langflow FLOW_ID "every monday at 10am" "Weekly competitive analysis"
#   .\schedule-agent.ps1 list
#   .\schedule-agent.ps1 remove "Daily standup generator"

param(
    [Parameter(Position=0, Mandatory=$false)]
    [string]$Command,
    
    [Parameter(Position=1, Mandatory=$false)]
    [string]$AgentType,
    
    [Parameter(Position=2, Mandatory=$false)]
    [string]$AgentId,
    
    [Parameter(Position=3, Mandatory=$false)]
    [string]$Schedule,
    
    [Parameter(Position=4, Mandatory=$false)]
    [string]$Description,
    
    [string]$Provider = "lmstudio",
    [string]$Input,
    [switch]$Background,
    [string]$LogDir,
    [switch]$Help
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ProjectRoot = Split-Path -Parent $ScriptDir
$TaskPrefix = "AIPM-Agent"

function Write-Success {
    param($Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning-Custom {
    param($Message)
    Write-Host "⚠️ $Message" -ForegroundColor Yellow
}

function Write-Error-Custom {
    param($Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Info {
    param($Message)
    Write-Host "ℹ️ $Message" -ForegroundColor Blue
}

function Show-Usage {
    Write-Host @"
AIPM Agent Scheduler for Windows
Schedule n8n workflows and LangFlow flows using Windows Task Scheduler

Usage:
  .\schedule-agent.ps1 add <type> <id> "<schedule>" "<description>" [options]
  .\schedule-agent.ps1 list
  .\schedule-agent.ps1 remove "<description>"
  .\schedule-agent.ps1 status
  .\schedule-agent.ps1 help

Agent Types:
  n8n        - n8n workflow
  langflow   - LangFlow flow

Schedule Examples:
  "daily at 9am"              - Every day at 9:00 AM
  "every monday at 10am"      - Every Monday at 10:00 AM
  "every 15 minutes"          - Every 15 minutes
  "hourly"                    - Every hour
  "daily"                     - Every day at midnight
  "weekly"                    - Every Sunday at midnight

Options:
  -Provider ollama            - Use Ollama instead of LM Studio
  -Input "text"               - Custom input for LangFlow flows
  -Background                 - Run agent in background mode
  -LogDir <path>              - Custom log directory

Examples:
  # Daily standup at 9 AM
  .\schedule-agent.ps1 add n8n abc123 "daily at 9am" "Daily Standup" -Background

  # Weekly competitive analysis
  .\schedule-agent.ps1 add langflow xyz789 "every monday at 10am" "Competitive Analysis" -Input "Weekly market update"

  # Status check every 15 minutes
  .\schedule-agent.ps1 add n8n def456 "every 15 minutes" "System Status Check"

Management:
  .\schedule-agent.ps1 list                     # Show all scheduled agents
  .\schedule-agent.ps1 remove "Daily Standup"   # Remove specific scheduled agent
  .\schedule-agent.ps1 status                   # Show Task Scheduler status
"@ -ForegroundColor Blue
}

function Convert-Schedule {
    param($ScheduleText)
    
    $trigger = $null
    
    switch -Regex ($ScheduleText) {
        "^daily at (\d{1,2})(am|pm)$" {
            $hour = [int]$matches[1]
            $period = $matches[2]
            
            if ($period -eq "pm" -and $hour -ne 12) { $hour += 12 }
            if ($period -eq "am" -and $hour -eq 12) { $hour = 0 }
            
            $trigger = New-ScheduledTaskTrigger -Daily -At ([DateTime]::Today.AddHours($hour))
            break
        }
        "^daily at (\d{1,2}):(\d{2})(am|pm)$" {
            $hour = [int]$matches[1]
            $minute = [int]$matches[2]
            $period = $matches[3]
            
            if ($period -eq "pm" -and $hour -ne 12) { $hour += 12 }
            if ($period -eq "am" -and $hour -eq 12) { $hour = 0 }
            
            $trigger = New-ScheduledTaskTrigger -Daily -At ([DateTime]::Today.AddHours($hour).AddMinutes($minute))
            break
        }
        "^every (monday|tuesday|wednesday|thursday|friday|saturday|sunday) at (\d{1,2})(am|pm)$" {
            $dayName = $matches[1]
            $hour = [int]$matches[2]
            $period = $matches[3]
            
            if ($period -eq "pm" -and $hour -ne 12) { $hour += 12 }
            if ($period -eq "am" -and $hour -eq 12) { $hour = 0 }
            
            $daysMap = @{
                'monday' = 'Monday'
                'tuesday' = 'Tuesday'
                'wednesday' = 'Wednesday'
                'thursday' = 'Thursday'
                'friday' = 'Friday'
                'saturday' = 'Saturday'
                'sunday' = 'Sunday'
            }
            
            $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $daysMap[$dayName] -At ([DateTime]::Today.AddHours($hour))
            break
        }
        "^every (\d+) minutes$" {
            $interval = [int]$matches[1]
            # Windows Task Scheduler doesn't directly support minute intervals < 1 hour easily
            # We'll use a daily trigger that repeats every X minutes
            $trigger = New-ScheduledTaskTrigger -Daily -At ([DateTime]::Today)
            $trigger.Repetition = New-ScheduledTaskRepetition -Interval (New-TimeSpan -Minutes $interval) -Duration (New-TimeSpan -Days 1)
            break
        }
        "^hourly$" {
            $trigger = New-ScheduledTaskTrigger -Daily -At ([DateTime]::Today)
            $trigger.Repetition = New-ScheduledTaskRepetition -Interval (New-TimeSpan -Hours 1) -Duration (New-TimeSpan -Days 1)
            break
        }
        "^daily$" {
            $trigger = New-ScheduledTaskTrigger -Daily -At ([DateTime]::Today)
            break
        }
        "^weekly$" {
            $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At ([DateTime]::Today)
            break
        }
        default {
            Write-Error-Custom "Unknown schedule format: $ScheduleText"
            Write-Host "Use formats like 'daily at 9am', 'every monday at 10am', 'every 15 minutes'"
            return $null
        }
    }
    
    return $trigger
}

function Add-Agent {
    param(
        $AgentType,
        $AgentId,
        $Schedule,
        $Description,
        $Provider = "lmstudio",
        $Input,
        $Background,
        $LogDir
    )
    
    # Convert schedule
    $trigger = Convert-Schedule $Schedule
    if (-not $trigger) {
        return
    }
    
    # Set default log directory
    if (-not $LogDir) {
        $LogDir = Join-Path $env:USERPROFILE "aipm-scheduled-agents"
    }
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    
    # Build command based on agent type
    $scriptPath = ""
    $arguments = ""
    
    switch ($AgentType) {
        "n8n" {
            $scriptPath = Join-Path $ProjectRoot "scripts\run-agent.ps1"
            $arguments = "$AgentId -Provider $Provider"
            if ($Background) {
                $arguments += " -Background"
            }
            $arguments += " -LogFile `"$LogDir\$($Description -replace '[^\w\s-]', '').log`""
            break
        }
        "langflow" {
            $scriptPath = Join-Path $ProjectRoot "scripts\run-langflow-agent.ps1"
            $arguments = "$AgentId -Provider $Provider"
            if ($Input) {
                $arguments += " -Input `"$Input`""
            }
            if ($Background) {
                $arguments += " -Background"
            }
            $arguments += " -LogFile `"$LogDir\$($Description -replace '[^\w\s-]', '').log`""
            break
        }
        default {
            Write-Error-Custom "Unknown agent type: $AgentType. Use 'n8n' or 'langflow'"
            return
        }
    }
    
    # Create task name
    $taskName = "$TaskPrefix-$Description"
    
    # Check if task already exists
    if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
        Write-Warning-Custom "Task '$Description' already exists"
        Write-Info "Remove it first with: .\schedule-agent.ps1 remove `"$Description`""
        return
    }
    
    # Create action
    $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`" $arguments" -WorkingDirectory $ProjectRoot
    
    # Create settings
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    
    # Create principal (run as current user)
    $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive
    
    # Register task
    try {
        Register-ScheduledTask -TaskName $taskName -Trigger $trigger -Action $action -Settings $settings -Principal $principal -Description "AIPM Agent: $Description" | Out-Null
        
        Write-Success "Scheduled agent: $Description"
        Write-Info "Task name: $taskName"
        Write-Info "Schedule: $Schedule"
        Write-Info "Script: $scriptPath"
        Write-Info "Arguments: $arguments"
        Write-Info "Log file: $LogDir\$($Description -replace '[^\w\s-]', '').log"
        Write-Host ""
        Write-Info "View scheduled tasks: .\schedule-agent.ps1 list"
        Write-Info "Remove this task: .\schedule-agent.ps1 remove `"$Description`""
    }
    catch {
        Write-Error-Custom "Failed to create scheduled task: $($_.Exception.Message)"
    }
}

function Show-Agents {
    Write-Info "Scheduled AIPM agents:"
    Write-Host ""
    
    $tasks = Get-ScheduledTask | Where-Object { $_.TaskName -like "$TaskPrefix-*" }
    
    if (-not $tasks) {
        Write-Warning-Custom "No AIPM agents are currently scheduled"
        Write-Info "Add an agent with: .\schedule-agent.ps1 add <type> <id> `"<schedule>`" `"<description>`""
        return
    }
    
    foreach ($task in $tasks) {
        $description = $task.TaskName -replace "^$TaskPrefix-", ""
        $info = Get-ScheduledTaskInfo $task.TaskName
        
        Write-Host "📅 $description" -ForegroundColor Green
        Write-Host "   Status: $($task.State)"
        Write-Host "   Last Run: $($info.LastRunTime)"
        Write-Host "   Next Run: $($info.NextRunTime)"
        
        # Show trigger info
        $trigger = $task.Triggers[0]
        if ($trigger) {
            switch ($trigger.CimClass.CimClassName) {
                "MSFT_TaskDailyTrigger" {
                    Write-Host "   Schedule: Daily at $($trigger.StartBoundary.ToString('HH:mm'))"
                }
                "MSFT_TaskWeeklyTrigger" {
                    $days = $trigger.DaysOfWeek -split ',' | ForEach-Object { $_.Trim() }
                    Write-Host "   Schedule: Weekly on $($days -join ', ') at $($trigger.StartBoundary.ToString('HH:mm'))"
                }
                "MSFT_TaskTimeTrigger" {
                    if ($trigger.Repetition.Interval) {
                        Write-Host "   Schedule: Repeating every $($trigger.Repetition.Interval)"
                    } else {
                        Write-Host "   Schedule: One-time at $($trigger.StartBoundary)"
                    }
                }
                default {
                    Write-Host "   Schedule: $($trigger.CimClass.CimClassName)"
                }
            }
        }
        
        Write-Host ""
    }
    
    Write-Info "Manage tasks in Windows Task Scheduler: taskschd.msc"
}

function Remove-Agent {
    param($Description)
    
    if (-not $Description) {
        Write-Error-Custom "Description is required"
        Write-Info "List tasks with: .\schedule-agent.ps1 list"
        return
    }
    
    $taskName = "$TaskPrefix-$Description"
    
    try {
        $task = Get-ScheduledTask -TaskName $taskName -ErrorAction Stop
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Success "Removed scheduled agent: $Description"
    }
    catch {
        Write-Warning-Custom "Task '$Description' not found"
        Write-Info "List current tasks with: .\schedule-agent.ps1 list"
    }
}

function Show-Status {
    Write-Info "Windows Task Scheduler status:"
    Write-Host ""
    
    # Check Task Scheduler service
    $service = Get-Service -Name "Schedule" -ErrorAction SilentlyContinue
    if ($service) {
        if ($service.Status -eq "Running") {
            Write-Success "Task Scheduler service is running"
        } else {
            Write-Warning-Custom "Task Scheduler service is not running (Status: $($service.Status))"
        }
    } else {
        Write-Error-Custom "Task Scheduler service not found"
    }
    
    Write-Host ""
    Write-Info "AIPM scheduled tasks:"
    
    $tasks = Get-ScheduledTask | Where-Object { $_.TaskName -like "$TaskPrefix-*" }
    if ($tasks) {
        $tasks | Format-Table TaskName, State, @{Name="Last Result"; Expression={(Get-ScheduledTaskInfo $_.TaskName).LastTaskResult}} -AutoSize
    } else {
        Write-Host "No AIPM tasks found"
    }
    
    Write-Host ""
    Write-Info "Recent Task Scheduler events:"
    try {
        Get-WinEvent -LogName "Microsoft-Windows-TaskScheduler/Operational" -MaxEvents 5 | 
            Where-Object { $_.Message -like "*$TaskPrefix*" } |
            Format-Table TimeCreated, Id, LevelDisplayName, Message -Wrap
    } catch {
        Write-Host "Could not retrieve Task Scheduler events"
    }
    
    Write-Host ""
    Write-Info "Open Task Scheduler: taskschd.msc"
}

# Main script execution
switch ($Command) {
    "add" {
        if (-not $AgentType -or -not $AgentId -or -not $Schedule -or -not $Description) {
            Write-Error-Custom "Not enough arguments for 'add' command"
            Write-Host ""
            Show-Usage
            exit 1
        }
        
        Add-Agent -AgentType $AgentType -AgentId $AgentId -Schedule $Schedule -Description $Description -Provider $Provider -Input $Input -Background $Background -LogDir $LogDir
    }
    "list" {
        Show-Agents
    }
    "remove" {
        if (-not $AgentType) {
            Write-Error-Custom "Description required for 'remove' command"
            Write-Host ""
            Show-Usage
            exit 1
        }
        Remove-Agent $AgentType  # AgentType is actually the description for remove command
    }
    "status" {
        Show-Status
    }
    "help" {
        Show-Usage
    }
    default {
        if ($Help -or -not $Command) {
            Show-Usage
        } else {
            Write-Error-Custom "Unknown command: $Command"
            Write-Host ""
            Show-Usage
            exit 1
        }
    }
}