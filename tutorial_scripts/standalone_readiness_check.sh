#!/bin/bash

# Standalone Readiness Check for Day 2+ Tutorial Progression
# Verifies current state and readiness before proceeding with organization and remote setup

set -e

# Colors for enhanced output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Script metadata
SCRIPT_VERSION="1.0.0"
CHECK_NAME="Standalone Readiness Check for Day 2+ Progression"
EXECUTION_ID="readiness_$(date '+%Y%m%d_%H%M%S')"

# Tracking variables
CHECKS_PASSED=0
CHECKS_FAILED=0
WARNINGS_COUNT=0
READY_FOR_NEXT=true

# Header
print_header() {
    echo -e "${PURPLE}=================================================================${NC}"
    echo -e "${PURPLE}🔍 $CHECK_NAME${NC}"
    echo -e "${PURPLE}=================================================================${NC}"
    echo -e "${BLUE}📍 Execution ID: ${WHITE}$EXECUTION_ID${NC}"
    echo -e "${BLUE}📅 Date: ${WHITE}$(date)${NC}"
    echo -e "${BLUE}👤 User: ${WHITE}$(whoami)${NC}"
    echo -e "${BLUE}🖥️  System: ${WHITE}$(sw_vers -productName) $(sw_vers -productVersion)${NC}"
    echo ""
}

# Logging functions
log_section() {
    echo -e "\n${CYAN}🔧 $1${NC}"
    echo "----------------------------------------"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    WARNINGS_COUNT=$((WARNINGS_COUNT + 1))
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
    READY_FOR_NEXT=false
}

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_detail() {
    echo -e "   ${WHITE}$1${NC}"
}

# Find base directory
find_base_directory() {
    local current_dir="$(pwd)"
    local search_paths=(
        "$current_dir"
        "$(dirname "$current_dir")"
        "$HOME/Development/CoreAudio"
        "../.."
        "../../.."
    )
    
    for path in "${search_paths[@]}"; do
        if [[ -f "$path/.core-audio-env" ]]; then
            echo "$path"
            return 0
        fi
    done
    
    echo "$HOME/Development/CoreAudio"  # fallback
}

# Check 1: Environment and Directory Structure
check_environment_structure() {
    log_section "Environment and Directory Structure"
    
    # Find base directory
    BASE_DIR="$(find_base_directory)"
    log_detail "Base directory: $BASE_DIR"
    
    # Check environment file
    if [[ -f "$BASE_DIR/.core-audio-env" ]]; then
        source "$BASE_DIR/.core-audio-env"
        log_success "Environment file found and sourced"
        log_detail "File: $BASE_DIR/.core-audio-env"
    else
        log_error "Environment file missing: $BASE_DIR/.core-audio-env"
        return 1
    fi
    
    # Verify environment variables
    if [[ -n "$TUTORIAL_ROOT" && -d "$TUTORIAL_ROOT" ]]; then
        log_success "Tutorial root configured and exists"
        log_detail "TUTORIAL_ROOT: $TUTORIAL_ROOT"
    else
        log_error "Tutorial root not configured or missing"
        return 1
    fi
    
    if [[ -n "$CORE_AUDIO_ROOT" && -d "$CORE_AUDIO_ROOT" ]]; then
        log_success "Core Audio root configured and exists"
        log_detail "CORE_AUDIO_ROOT: $CORE_AUDIO_ROOT"
    else
        log_error "Core Audio root not configured or missing"
        return 1
    fi
    
    # Change to tutorial root for remaining checks
    cd "$TUTORIAL_ROOT"
    log_detail "Working directory: $(pwd)"
}

# Check 2: Git Repository Status
check_git_status() {
    log_section "Git Repository Status"
    
    # Check if we're in a git repository
    if [[ -d ".git" ]]; then
        log_success "Git repository detected"
    else
        log_error "Not in a git repository"
        return 1
    fi
    
    # Check git configuration
    local git_name="$(git config --global user.name 2>/dev/null || echo '')"
    local git_email="$(git config --global user.email 2>/dev/null || echo '')"
    
    if [[ -n "$git_name" ]]; then
        log_success "Git user name configured: $git_name"
    else
        log_warning "Git user name not configured globally"
        log_detail "Recommend: git config --global user.name 'Your Name'"
    fi
    
    if [[ -n "$git_email" ]]; then
        log_success "Git user email configured: $git_email"
    else
        log_warning "Git user email not configured globally"
        log_detail "Recommend: git config --global user.email 'your@email.com'"
    fi
    
    # Check current branch
    local current_branch="$(git branch --show-current 2>/dev/null || echo 'unknown')"
    if [[ "$current_branch" == "main" ]]; then
        log_success "On main branch"
    else
        log_info "Current branch: $current_branch"
        if [[ "$current_branch" == "unknown" ]]; then
            log_warning "Unable to determine current branch"
        fi
    fi
    
    # Check for uncommitted changes
    if git diff --quiet && git diff --cached --quiet; then
        log_success "Working directory clean"
    else
        log_info "Uncommitted changes detected"
        log_detail "$(git status --porcelain | wc -l | tr -d ' ') files with changes"
    fi
    
    # Show latest commit
    if git log --oneline -1 > /dev/null 2>&1; then
        local latest_commit="$(git log --oneline -1)"
        log_success "Repository has commit history"
        log_detail "Latest: $latest_commit"
    else
        log_warning "No commit history found"
    fi
}

# Check 3: Day 1 Completion Status
check_day1_completion() {
    log_section "Day 1 Completion Status"
    
    # Check for Day 1 session log
    if [[ -f "$LOGS_DIR/day01_session.log" ]]; then
        log_success "Day 1 session log found"
        
        # Check for completion marker
        if grep -q "DAY1-COMPLETE" "$LOGS_DIR/day01_session.log"; then
            log_success "Day 1 completion marker verified"
        else
            log_warning "Day 1 completion marker not found"
        fi
    else
        log_warning "Day 1 session log not found"
        log_detail "Expected: $LOGS_DIR/day01_session.log"
    fi
    
    # Check for essential Day 1 components
    local day1_items=(
        "activate-ca-env.sh:Environment activation script"
        "shared-frameworks:Testing frameworks directory"
    )
    
    for item_info in "${day1_items[@]}"; do
        local item_path="${item_info%%:*}"
        local description="${item_info##*:}"
        
        if [[ -e "$item_path" ]]; then
            log_success "$description exists"
        else
            log_warning "$description missing: $item_path"
        fi
    done
}

# Check 4: Tutorial Scripts Status
check_tutorial_scripts() {
    log_section "Tutorial Scripts Status"
    
    # Check for tutorial-scripts directory
    if [[ -d "tutorial-scripts" ]]; then
        log_success "tutorial-scripts directory exists"
    else
        log_info "tutorial-scripts directory will be created"
    fi
    
    # Check for preflight_check.sh
    local preflight_locations=(
        "tutorial-scripts/preflight_check.sh"
        "preflight_check.sh"
        "scripts/preflight_check.sh"
    )
    
    local preflight_found=false
    for location in "${preflight_locations[@]}"; do
        if [[ -f "$location" ]]; then
            log_success "preflight_check.sh found at: $location"
            
            # Check if executable
            if [[ -x "$location" ]]; then
                log_success "preflight_check.sh is executable"
            else
                log_warning "preflight_check.sh not executable"
                log_detail "Run: chmod +x $location"
            fi
            
            preflight_found=true
            break
        fi
    done
    
    if [[ "$preflight_found" == "false" ]]; then
        log_warning "preflight_check.sh not found in expected locations"
        log_detail "Will be created during organization phase"
    fi
}

# Check 5: System Prerequisites
check_system_prerequisites() {
    log_section "System Prerequisites"
    
    # macOS version
    if [[ "$OSTYPE" == "darwin"* ]]; then
        local macos_version="$(sw_vers -productVersion)"
        log_success "macOS detected: $macos_version"
    else
        log_error "macOS required for Core Audio development"
        return 1
    fi
    
    # Essential tools
    local tools=(
        "git:Git version control"
        "clang:Clang compiler"
        "curl:HTTP client"
    )
    
    for tool_info in "${tools[@]}"; do
        local tool="${tool_info%%:*}"
        local description="${tool_info##*:}"
        
        if command -v "$tool" > /dev/null 2>&1; then
            log_success "$description available"
        else
            log_error "$description missing"
        fi
    done
    
    # Core Audio framework test
    local test_code='#include <AudioToolbox/AudioToolbox.h>
int main() { return 0; }'
    
    if echo "$test_code" | clang -framework AudioToolbox -x c -c - -o /dev/null 2>/dev/null; then
        log_success "Core Audio framework accessible"
    else
        log_error "Core Audio framework not accessible"
    fi
}

# Check 6: Network and GitHub Access
check_network_github() {
    log_section "Network and GitHub Connectivity"
    
    # Internet connectivity
    if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
        log_success "Internet connectivity available"
    else
        log_error "No internet connectivity"
        return 1
    fi
    
    # GitHub connectivity
    if curl -s -f -m 10 "https://github.com" > /dev/null 2>&1; then
        log_success "GitHub.com accessible"
    else
        log_error "Cannot reach GitHub.com"
    fi
    
    # GitHub API
    if curl -s -f -m 10 "https://api.github.com/rate_limit" > /dev/null 2>&1; then
        log_success "GitHub API accessible"
    else
        log_warning "GitHub API access issues"
    fi
    
    # Check authentication methods
    local auth_methods=0
    
    # GitHub CLI
    if command -v gh > /dev/null 2>&1 && gh auth status > /dev/null 2>&1; then
        log_success "GitHub CLI authenticated"
        auth_methods=$((auth_methods + 1))
    fi
    
    # SSH keys
    if ssh -T git@github.com -o ConnectTimeout=10 -o StrictHostKeyChecking=no 2>&1 | grep -q "successfully authenticated"; then
        log_success "SSH key authentication working"
        auth_methods=$((auth_methods + 1))
    fi
    
    if [[ $auth_methods -gt 0 ]]; then
        log_success "$auth_methods GitHub authentication method(s) available"
    else
        log_info "No GitHub authentication detected (setup will guide configuration)"
    fi
}

# Check 7: Disk Space and Permissions
check_resources() {
    log_section "Disk Space and Permissions"
    
    # Check available disk space
    local available_mb="$(df -m . | tail -n1 | awk '{print $4}' || echo '0')"
    if [[ "$available_mb" -gt 1024 ]]; then
        log_success "Sufficient disk space available ($(($available_mb / 1024))GB+)"
    else
        log_warning "Low disk space detected (${available_mb}MB)"
    fi
    
    # Check write permissions
    local key_dirs=("." "$CORE_AUDIO_ROOT" "$LOGS_DIR")
    
    for dir in "${key_dirs[@]}"; do
        if [[ -w "$dir" ]]; then
            log_success "Write permission available: $dir"
        else
            log_error "No write permission: $dir"
        fi
    done
    
    # Test file creation
    local test_file="readiness_test_$$"
    if touch "$test_file" 2>/dev/null && rm "$test_file" 2>/dev/null; then
        log_success "File creation/deletion permissions verified"
    else
        log_error "Cannot create/delete files in current directory"
    fi
}

# Generate readiness summary
generate_summary() {
    echo -e "\n${PURPLE}=================================================================${NC}"
    echo -e "${PURPLE}📊 READINESS SUMMARY${NC}"
    echo -e "${PURPLE}=================================================================${NC}"
    
    echo -e "\n${BLUE}📈 Check Results:${NC}"
    echo -e "   ✅ Checks Passed: ${GREEN}$CHECKS_PASSED${NC}"
    echo -e "   ❌ Checks Failed: ${RED}$CHECKS_FAILED${NC}"
    echo -e "   ⚠️  Warnings: ${YELLOW}$WARNINGS_COUNT${NC}"
    
    if [[ "$READY_FOR_NEXT" == "true" ]]; then
        echo -e "\n${GREEN}🎉 READY TO PROCEED!${NC}"
        echo -e "${GREEN}All critical checks passed. You can proceed with:${NC}"
        echo -e "${CYAN}   1. Directory organization (daily-sessions structure)${NC}"
        echo -e "${CYAN}   2. Remote repository setup script creation${NC}"
        echo -e "${CYAN}   3. Day 1 material push to GitHub${NC}"
        
        if [[ $WARNINGS_COUNT -gt 0 ]]; then
            echo -e "\n${YELLOW}📝 Note: $WARNINGS_COUNT warning(s) detected${NC}"
            echo -e "${YELLOW}These are non-critical but should be addressed for optimal experience${NC}"
        fi
        
        echo -e "\n${GREEN}🚀 Next Steps:${NC}"
        echo -e "${BLUE}   1. Run organization script to set up daily-sessions structure${NC}"
        echo -e "${BLUE}   2. Create and test remote_repo_setup.sh${NC}"
        echo -e "${BLUE}   3. Execute remote repository setup${NC}"
        echo -e "${BLUE}   4. Begin Day 2: Foundation Building${NC}"
        
    else
        echo -e "\n${RED}❌ NOT READY TO PROCEED${NC}"
        echo -e "${RED}Critical issues must be resolved first:${NC}"
        echo -e "${RED}   $CHECKS_FAILED critical check(s) failed${NC}"
        echo -e "\n${YELLOW}Please address the critical failures above and re-run this check${NC}"
    fi
    
    # Additional information
    echo -e "\n${BLUE}📋 System Information:${NC}"
    echo -e "   OS: $(sw_vers -productName) $(sw_vers -productVersion)"
    echo -e "   User: $(whoami)"
    echo -e "   Working Directory: $(pwd)"
    echo -e "   Execution ID: $EXECUTION_ID"
    
    echo -e "\n${PURPLE}=================================================================${NC}"
}

# Main execution flow
main() {
    print_header
    
    # Run all checks
    check_environment_structure
    check_git_status
    check_day1_completion
    check_tutorial_scripts
    check_system_prerequisites
    check_network_github
    check_resources
    
    # Generate final summary
    generate_summary
    
    # Return appropriate exit code
    if [[ "$READY_FOR_NEXT" == "true" ]]; then
        exit 0
    else
        exit 1
    fi
}

# Execute main function
main "$@"
