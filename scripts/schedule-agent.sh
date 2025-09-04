#!/bin/bash
# AIPM Laptop LLM Kit - Agent Scheduler for macOS/Linux
# Schedule n8n workflows and LangFlow flows to run on a timer
#
# Usage:
#   ./schedule-agent.sh add n8n WORKFLOW_ID "daily at 9am" "Daily standup generator"
#   ./schedule-agent.sh add langflow FLOW_ID "every monday at 10am" "Weekly competitive analysis"
#   ./schedule-agent.sh list
#   ./schedule-agent.sh remove JOB_NAME

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CRON_BACKUP_DIR="$HOME/.aipm-scheduled-agents"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "$1"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
info() { echo -e "${BLUE}ℹ️ $1${NC}"; }

usage() {
    cat << EOF
${BLUE}AIPM Agent Scheduler for macOS/Linux${NC}
Schedule n8n workflows and LangFlow flows to run automatically

${YELLOW}Usage:${NC}
  $0 add <type> <id> "<schedule>" "<description>" [options]
  $0 list
  $0 remove <job-name>
  $0 status
  $0 help

${YELLOW}Agent Types:${NC}
  n8n        - n8n workflow
  langflow   - LangFlow flow

${YELLOW}Schedule Examples:${NC}
  "daily at 9am"              - Every day at 9:00 AM
  "every monday at 10am"      - Every Monday at 10:00 AM
  "every 15 minutes"          - Every 15 minutes
  "hourly"                    - Every hour at minute 0
  "weekly"                    - Every Sunday at midnight
  "0 9 * * 1-5"               - Weekdays at 9 AM (raw cron)

${YELLOW}Options:${NC}
  --provider ollama           - Use Ollama instead of LM Studio
  --input "text"              - Custom input for LangFlow flows
  --background                - Run agent in background mode
  --log-dir <path>            - Custom log directory

${YELLOW}Examples:${NC}
  # Daily standup at 9 AM
  $0 add n8n abc123 "daily at 9am" "Daily Standup" --background

  # Weekly competitive analysis
  $0 add langflow xyz789 "every monday at 10am" "Competitive Analysis" --input "Weekly market update"

  # Status check every 15 minutes  
  $0 add n8n def456 "every 15 minutes" "System Status Check"

${YELLOW}Management:${NC}
  $0 list                     # Show all scheduled agents
  $0 remove daily-standup     # Remove specific scheduled agent
  $0 status                   # Show cron service status
EOF
}

# Convert human-readable schedule to cron format
convert_schedule() {
    local schedule="$1"
    local cron_expr=""
    
    case "$schedule" in
        "daily at "*)
            local time=$(echo "$schedule" | sed 's/daily at //' | sed 's/am//' | sed 's/pm//')
            local hour=$(echo "$time" | cut -d':' -f1)
            local minute="0"
            if [[ "$time" == *":"* ]]; then
                minute=$(echo "$time" | cut -d':' -f2)
            fi
            # Handle PM times
            if [[ "$schedule" == *"pm"* ]] && [[ "$hour" != "12" ]]; then
                hour=$((hour + 12))
            fi
            # Handle 12 AM (midnight)
            if [[ "$schedule" == *"am"* ]] && [[ "$hour" == "12" ]]; then
                hour="0"
            fi
            cron_expr="$minute $hour * * *"
            ;;
        "every monday at "*)
            local time=$(echo "$schedule" | sed 's/every monday at //' | sed 's/am//' | sed 's/pm//')
            local hour=$(echo "$time" | cut -d':' -f1)
            local minute="0"
            if [[ "$time" == *":"* ]]; then
                minute=$(echo "$time" | cut -d':' -f2)
            fi
            if [[ "$schedule" == *"pm"* ]] && [[ "$hour" != "12" ]]; then
                hour=$((hour + 12))
            fi
            if [[ "$schedule" == *"am"* ]] && [[ "$hour" == "12" ]]; then
                hour="0"
            fi
            cron_expr="$minute $hour * * 1"
            ;;
        "every tuesday at "*)
            local time=$(echo "$schedule" | sed 's/every tuesday at //' | sed 's/am//' | sed 's/pm//')
            local hour=$(echo "$time" | cut -d':' -f1)
            local minute="0"
            if [[ "$time" == *":"* ]]; then
                minute=$(echo "$time" | cut -d':' -f2)
            fi
            if [[ "$schedule" == *"pm"* ]] && [[ "$hour" != "12" ]]; then
                hour=$((hour + 12))
            fi
            if [[ "$schedule" == *"am"* ]] && [[ "$hour" == "12" ]]; then
                hour="0"
            fi
            cron_expr="$minute $hour * * 2"
            ;;
        "every wednesday at "*)
            local time=$(echo "$schedule" | sed 's/every wednesday at //' | sed 's/am//' | sed 's/pm//')
            local hour=$(echo "$time" | cut -d':' -f1)
            local minute="0"
            if [[ "$time" == *":"* ]]; then
                minute=$(echo "$time" | cut -d':' -f2)
            fi
            if [[ "$schedule" == *"pm"* ]] && [[ "$hour" != "12" ]]; then
                hour=$((hour + 12))
            fi
            if [[ "$schedule" == *"am"* ]] && [[ "$hour" == "12" ]]; then
                hour="0"
            fi
            cron_expr="$minute $hour * * 3"
            ;;
        "every thursday at "*)
            local time=$(echo "$schedule" | sed 's/every thursday at //' | sed 's/am//' | sed 's/pm//')
            local hour=$(echo "$time" | cut -d':' -f1)
            local minute="0"
            if [[ "$time" == *":"* ]]; then
                minute=$(echo "$time" | cut -d':' -f2)
            fi
            if [[ "$schedule" == *"pm"* ]] && [[ "$hour" != "12" ]]; then
                hour=$((hour + 12))
            fi
            if [[ "$schedule" == *"am"* ]] && [[ "$hour" == "12" ]]; then
                hour="0"
            fi
            cron_expr="$minute $hour * * 4"
            ;;
        "every friday at "*)
            local time=$(echo "$schedule" | sed 's/every friday at //' | sed 's/am//' | sed 's/pm//')
            local hour=$(echo "$time" | cut -d':' -f1)
            local minute="0"
            if [[ "$time" == *":"* ]]; then
                minute=$(echo "$time" | cut -d':' -f2)
            fi
            if [[ "$schedule" == *"pm"* ]] && [[ "$hour" != "12" ]]; then
                hour=$((hour + 12))
            fi
            if [[ "$schedule" == *"am"* ]] && [[ "$hour" == "12" ]]; then
                hour="0"
            fi
            cron_expr="$minute $hour * * 5"
            ;;
        "every 15 minutes")
            cron_expr="*/15 * * * *"
            ;;
        "every 30 minutes")
            cron_expr="*/30 * * * *"
            ;;
        "hourly")
            cron_expr="0 * * * *"
            ;;
        "daily")
            cron_expr="0 0 * * *"
            ;;
        "weekly")
            cron_expr="0 0 * * 0"
            ;;
        *" "*)
            # Assume it's already a cron expression
            cron_expr="$schedule"
            ;;
        *)
            error "Unknown schedule format: $schedule"
            echo "Use formats like 'daily at 9am', 'every monday at 10am', or raw cron '0 9 * * 1-5'"
            return 1
            ;;
    esac
    
    echo "$cron_expr"
}

# Create job name from description
create_job_name() {
    local description="$1"
    echo "$description" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g'
}

# Add scheduled agent
add_agent() {
    local agent_type="$1"
    local agent_id="$2"  
    local schedule="$3"
    local description="$4"
    shift 4
    
    # Parse additional options
    local provider="lmstudio"
    local input_text=""
    local background_flag=""
    local log_dir="$HOME/aipm-scheduled-agents"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --provider)
                provider="$2"
                shift 2
                ;;
            --input)
                input_text="$2"
                shift 2
                ;;
            --background)
                background_flag="--background"
                shift
                ;;
            --log-dir)
                log_dir="$2"
                shift 2
                ;;
            *)
                warning "Unknown option: $1"
                shift
                ;;
        esac
    done
    
    # Convert schedule to cron format
    local cron_expr=$(convert_schedule "$schedule")
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    # Create job name
    local job_name=$(create_job_name "$description")
    
    # Create backup directory
    mkdir -p "$CRON_BACKUP_DIR"
    
    # Build command based on agent type
    local command=""
    case "$agent_type" in
        n8n)
            command="cd $PROJECT_ROOT && ./scripts/run-agent.sh $agent_id --provider $provider $background_flag"
            ;;
        langflow)
            local input_flag=""
            if [[ -n "$input_text" ]]; then
                input_flag="--input \"$input_text\""
            fi
            command="cd $PROJECT_ROOT && ./scripts/run-langflow-agent.sh $agent_id --provider $provider $background_flag $input_flag"
            ;;
        *)
            error "Unknown agent type: $agent_type. Use 'n8n' or 'langflow'"
            return 1
            ;;
    esac
    
    # Add logging
    mkdir -p "$log_dir"
    command="$command --log $log_dir/${job_name}.log"
    
    # Create cron job entry
    local cron_comment="# AIMP Agent: $description"
    local cron_job="$cron_expr $command"
    
    # Backup current crontab
    crontab -l > "$CRON_BACKUP_DIR/crontab.backup" 2>/dev/null || touch "$CRON_BACKUP_DIR/crontab.backup"
    
    # Check if job already exists
    if crontab -l 2>/dev/null | grep -q "# AIPM Agent: $description"; then
        warning "Agent '$description' is already scheduled"
        info "Remove it first with: $0 remove $job_name"
        return 1
    fi
    
    # Add new job to crontab
    (
        crontab -l 2>/dev/null || true
        echo "$cron_comment"
        echo "$cron_job"
        echo ""
    ) | crontab -
    
    # Save job info for management
    local job_info_file="$CRON_BACKUP_DIR/${job_name}.info"
    cat > "$job_info_file" << EOF
JOB_NAME=$job_name
DESCRIPTION=$description
AGENT_TYPE=$agent_type
AGENT_ID=$agent_id
SCHEDULE=$schedule
CRON_EXPR=$cron_expr
PROVIDER=$provider
INPUT_TEXT=$input_text
BACKGROUND=$background_flag
LOG_DIR=$log_dir
CREATED=$(date)
EOF
    
    success "Scheduled agent: $description"
    info "Job name: $job_name"
    info "Schedule: $schedule ($cron_expr)"
    info "Command: $command"
    info "Log file: $log_dir/${job_name}.log"
    echo ""
    info "View scheduled jobs: $0 list"
    info "Remove this job: $0 remove $job_name"
}

# List scheduled agents
list_agents() {
    info "Scheduled AIPM agents:"
    echo ""
    
    if ! crontab -l 2>/dev/null | grep -q "# AIMP Agent:"; then
        warning "No AIMP agents are currently scheduled"
        info "Add an agent with: $0 add <type> <id> \"<schedule>\" \"<description>\""
        return
    fi
    
    # Parse crontab for AIMP agents
    local current_comment=""
    while IFS= read -r line; do
        if [[ "$line" =~ ^#\ AIPM\ Agent:\ (.*)$ ]]; then
            current_comment="${BASH_REMATCH[1]}"
        elif [[ -n "$current_comment" && "$line" =~ ^[0-9\*/] ]]; then
            local schedule_part=$(echo "$line" | cut -d' ' -f1-5)
            local command_part=$(echo "$line" | cut -d' ' -f6-)
            
            echo -e "${GREEN}📅 $current_comment${NC}"
            echo "   Schedule: $schedule_part"
            echo "   Command: $command_part"
            echo ""
            current_comment=""
        fi
    done < <(crontab -l 2>/dev/null)
    
    # Show job info files
    if [[ -d "$CRON_BACKUP_DIR" ]]; then
        local info_files=("$CRON_BACKUP_DIR"/*.info)
        if [[ -f "${info_files[0]}" ]]; then
            info "Detailed job information available in: $CRON_BACKUP_DIR"
        fi
    fi
}

# Remove scheduled agent
remove_agent() {
    local job_name="$1"
    
    if [[ -z "$job_name" ]]; then
        error "Job name is required"
        info "List jobs with: $0 list"
        return 1
    fi
    
    # Backup current crontab
    mkdir -p "$CRON_BACKUP_DIR"
    crontab -l > "$CRON_BACKUP_DIR/crontab.backup" 2>/dev/null || touch "$CRON_BACKUP_DIR/crontab.backup"
    
    # Look for job info file to get description
    local job_info_file="$CRON_BACKUP_DIR/${job_name}.info"
    local description="$job_name"
    if [[ -f "$job_info_file" ]]; then
        description=$(grep "^DESCRIPTION=" "$job_info_file" | cut -d'=' -f2)
    fi
    
    # Remove from crontab (remove comment line and job line)
    local temp_cron=$(mktemp)
    local removed=false
    local skip_next=false
    
    while IFS= read -r line; do
        if [[ "$skip_next" == true ]]; then
            skip_next=false
            removed=true
            continue
        fi
        
        if [[ "$line" == "# AIPM Agent: $description" ]]; then
            skip_next=true
            continue
        fi
        
        echo "$line" >> "$temp_cron"
    done < <(crontab -l 2>/dev/null || true)
    
    if [[ "$removed" == true ]]; then
        crontab "$temp_cron"
        rm -f "$temp_cron"
        rm -f "$job_info_file"
        success "Removed scheduled agent: $description"
    else
        rm -f "$temp_cron"
        warning "Job '$job_name' not found"
        info "List current jobs with: $0 list"
        return 1
    fi
}

# Show cron service status
show_status() {
    info "Cron service status:"
    echo ""
    
    # Check if cron is running (macOS uses launchd)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if launchctl list | grep -q com.vix.cron; then
            success "Cron service is running (managed by launchd)"
        else
            warning "Cron service may not be running"
            info "On macOS, cron is managed by launchd and should start automatically"
        fi
    else
        # Linux systems
        if systemctl is-active --quiet cron 2>/dev/null; then
            success "Cron service is active"
        elif systemctl is-active --quiet crond 2>/dev/null; then
            success "Crond service is active" 
        else
            warning "Cron service is not running"
            info "Start with: sudo systemctl start cron"
        fi
    fi
    
    echo ""
    info "Current user crontab:"
    if crontab -l 2>/dev/null | grep -q .; then
        crontab -l 2>/dev/null | grep -E "(^#|AIPM)" || echo "No AIPM jobs found"
    else
        warning "No crontab entries found"
    fi
    
    echo ""
    info "Cron logs (recent):"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log show --predicate 'subsystem == "com.vix.cron"' --info --last 1h 2>/dev/null | tail -10 || \
        echo "Use 'log show --predicate \"subsystem == \\\"com.vix.cron\\\"\" --info --last 1h' to view cron logs"
    else
        tail -20 /var/log/cron 2>/dev/null || \
        journalctl -u cron -n 20 --no-pager 2>/dev/null || \
        echo "Cron logs not accessible or not found"
    fi
}

# Main script
main() {
    local command="$1"
    
    case "$command" in
        add)
            if [[ $# -lt 5 ]]; then
                error "Not enough arguments for 'add' command"
                echo ""
                usage
                exit 1
            fi
            add_agent "$2" "$3" "$4" "$5" "${@:6}"
            ;;
        list)
            list_agents
            ;;
        remove)
            if [[ -z "$2" ]]; then
                error "Job name required for 'remove' command"
                echo ""
                usage
                exit 1
            fi
            remove_agent "$2"
            ;;
        status)
            show_status
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            if [[ -n "$command" ]]; then
                error "Unknown command: $command"
                echo ""
            fi
            usage
            exit 1
            ;;
    esac
}

main "$@"