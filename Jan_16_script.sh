#!/bin/bash

PROCESS_ID=""
THRESHOLD=0
INTERVAL=5
ARTIFACT_DIR=""
RESTART_ENABLED=false
LOG_FILE="leak_monitor.log"


log_message() {
    local MESSAGE="$1"
    local TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$TIMESTAMP] $MESSAGE" | tee -a "$LOG_FILE"
}

usage() {
    echo "Usage: $0 -p <PID|Name> -t <Threshold MB> -i <Interval Secs> -d <Artifact Dir> [-r]"
    echo "  -p : Process ID or Process Name"
    echo "  -t : Memory threshold in Megabytes (MB)"
    echo "  -i : Polling interval in seconds"
    echo "  -d : Directory to save diagnostic artifacts"
    echo "  -r : (Optional) Restart process if threshold exceeded"
    exit 1
}

get_pid() {
    local INPUT=$1
    if [[ "$INPUT" =~ ^[0-9]+$ ]]; then
        # Input is a PID
        if kill -0 "$INPUT" 2>/dev/null; then
            echo "$INPUT"
        else
            return 1
        fi
    else
        # Input is a name
        local FOUND_PID=$(pgrep -f -o "$INPUT")
        if [ -n "$FOUND_PID" ]; then
            echo "$FOUND_PID"
        else
            return 1
        fi
    fi
}

get_memory_usage() {
    local PID=$1
    
    local RSS_KB=$(ps -o rss= -p "$PID" | tr -d ' ')
    if [ -z "$RSS_KB" ]; then echo 0; else echo "$((RSS_KB / 1024))"; fi
}

collect_diagnostics() {
    local PID=$1
    local STAMP=$(date '+%Y%m%d_%H%M%S')
    local SESSION_DIR="${ARTIFACT_DIR}/leak_evidince_${STAMP}_pid${PID}"
    
    mkdir -p "$SESSION_DIR"
    log_message "Collecting diagnostics into $SESSION_DIR"

    
    pmap -x "$PID" > "${SESSION_DIR}/memory_map.txt" 2>&1
    
    
    lsof -p "$PID" > "${SESSION_DIR}/open_files.txt" 2>&1
    
    
    cat "/proc/${PID}/status" > "${SESSION_DIR}/proc_status.txt" 2>&1
    
    
    if command -v gcore >/dev/null 2>&1; then
        gcore -o "${SESSION_DIR}/core" "$PID" >/dev/null 2>&1
    else
        log_message "Warning: gcore not found, skipping core dump."
    fi

    log_message "Diagnostic collection complete."
}



while getopts "p:t:i:d:r" opt; do
    case $opt in
        p) PROCESS_ID_INPUT=$OPTARG ;;
        t) THRESHOLD=$OPTARG ;;
        i) INTERVAL=$OPTARG ;;
        d) ARTIFACT_DIR=$OPTARG ;;
        r) RESTART_ENABLED=true ;;
        *) usage ;;
    esac
done

if [[ -z "$PROCESS_ID_INPUT" || $THRESHOLD -le 0 || -z "$ARTIFACT_DIR" ]]; then
    usage
fi



mkdir -p "$ARTIFACT_DIR"
PID=$(get_pid "$PROCESS_ID_INPUT")

if [ $? -ne 0 ]; then
    log_message "Error: Could not find or access process '$PROCESS_ID_INPUT'"
    exit 1
fi

log_message "Monitor started for PID $PID (Threshold: ${THRESHOLD}MB, Interval: ${INTERVAL}s)"



while true; do
    
    if ! kill -0 "$PID" 2>/dev/null; then
        log_message "Critical: Monitored process $PID terminated."
        exit 2
    fi

    CURRENT_MEM=$(get_memory_usage "$PID")

    if [ "$CURRENT_MEM" -gt "$THRESHOLD" ]; then
        log_message "ALERT: Memory usage is ${CURRENT_MEM}MB (Exceeds ${THRESHOLD}MB)"
        
        collect_diagnostics "$PID"

        if [ "$RESTART_ENABLED" = true ]; then
            log_message "Restart enabled. Killing process $PID..."
            kill -15 "$PID"
            sleep 2
            kill -9 "$PID" 2>/dev/null
            log_message "Process terminated. Manual restart required or script logic must be updated with start command."

            exit 3
        fi
    fi

    sleep "$INTERVAL"
done