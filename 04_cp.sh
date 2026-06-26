#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
#  TOOL: cp — Copy Files and Directories
#  FILE: 04_cp.sh
#  OS  : Red Hat Enterprise Linux 9
# ╠═══════════════════════════════════════════════════════════════════════════╣
#  WHAT IS CP?
#  cp creates an exact copy of a file or directory at a new location.
#  The original is left unchanged. Unlike mv, cp always reads and writes data
#  so it works across different filesystems and devices.
#
#  BASIC SYNTAX:
#   cp [OPTIONS] SOURCE DESTINATION
#   cp [OPTIONS] SOURCE... DIRECTORY
#
#  KEY CONCEPTS:
#   - If DESTINATION is a file name → the copy gets that name
#   - If DESTINATION is a directory → the copy goes inside with its own name
#   - -r is REQUIRED to copy directories
#   - Permissions, ownership, timestamps are NOT preserved by default
#   - Use -p or -a to preserve metadata
#
#  EXIT CODES:
#   0 = success     1 = error
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 1: BASIC FILE COPYING
# ─────────────────────────────────────────────────────────────────────────────

# Copy a file (rename the copy)
cp /etc/hosts /tmp/hosts_backup
# Explanation: creates /tmp/hosts_backup — an exact copy of /etc/hosts
# The original /etc/hosts is untouched

# Copy a file into a directory (keeps original filename)
cp /etc/hosts /tmp/
# Explanation: creates /tmp/hosts (same filename inside /tmp/)

# Copy multiple files into a directory
cp /etc/hosts /etc/hostname /etc/resolv.conf /tmp/
# Explanation: all three files are copied into /tmp/

# Copy using wildcards
cp /etc/*.conf /tmp/conf_backup/
# Explanation: copies all .conf files from /etc/ into the backup dir

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 2: DIRECTORY COPYING
# ─────────────────────────────────────────────────────────────────────────────

# -r or -R  Recursive — required for copying directories
cp -r /etc/ssh/ /tmp/ssh_backup/
# Explanation: copies the entire ssh/ directory tree including all subdirectories
# Creates /tmp/ssh_backup/ssh/ — note: the directory itself is copied inside

# Copy directory contents into another directory
cp -r /etc/ssh/. /tmp/ssh_backup/
# Explanation: /etc/ssh/. copies the CONTENTS of ssh/ directly into /tmp/ssh_backup/
# No extra nesting — files land directly in /tmp/ssh_backup/

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 3: PRESERVING METADATA
# ─────────────────────────────────────────────────────────────────────────────

# -p  Preserve permissions, ownership, and timestamps
cp -p /etc/passwd /tmp/passwd.bak
# Explanation: the copy has the same permissions, owner, group, and mtime
# Essential for backup scripts so restored files have correct attributes

# -a  Archive mode = -r + -p + preserve symlinks (best for full backups)
cp -a /etc/ /backup/etc_full/
# Explanation: recursively copies everything, preserves ALL metadata
# This is the gold standard for file system backups with cp

# --preserve=all  Preserve everything including SELinux contexts
cp --preserve=all /etc/hosts /tmp/hosts.bak
# Explanation: also copies SELinux labels, ACLs, and extended attributes
# Use this when copying system files where SELinux contexts matter

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 4: SAFETY OPTIONS
# ─────────────────────────────────────────────────────────────────────────────

# -i  Interactive — prompt before overwriting
cp -i /etc/hosts /tmp/hosts
# Explanation: asks "overwrite /tmp/hosts?" if the destination already exists
# Essential for interactive use — prevents accidental data loss

# -n  No-clobber — NEVER overwrite existing files
cp -n /etc/hosts /tmp/hosts
# Explanation: silently skips if destination exists; no prompt, no overwrite
# Useful in scripts where you only want to copy new files

# -u  Update — only copy if source is NEWER than destination
cp -u /etc/hosts /tmp/hosts
# Explanation: skips if destination is up-to-date (same as or newer than source)
# Great for incremental backup scripts

# --backup  Create numbered backups of existing files
cp --backup=numbered /etc/hosts /tmp/hosts
# Explanation: if /tmp/hosts exists, it becomes /tmp/hosts.~1~, then .~2~, etc.
# Never loses data — each cp run keeps the previous version

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 5: VERBOSE & PROGRESS
# ─────────────────────────────────────────────────────────────────────────────

# -v  Verbose — show each file as it is copied
cp -rv /etc/ssh/ /tmp/ssh_backup/
# Output: '/etc/ssh/sshd_config' -> '/tmp/ssh_backup/sshd_config'
#         '/etc/ssh/ssh_host_rsa_key' -> '/tmp/ssh_backup/ssh_host_rsa_key'
# Explanation: useful for confirming what was copied or debugging

# --progress  Show progress bar (requires pv — install with dnf install pv)
# pv /largefile | cp /dev/stdin /backup/largefile
# Alternative progress with rsync (more common):
# rsync -ah --progress source dest

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 6: SPECIAL COPY OPERATIONS
# ─────────────────────────────────────────────────────────────────────────────

# Copy and follow symlinks (-L)
cp -L /etc/alternatives/python /tmp/python_copy
# Explanation: copies the actual file the symlink points to (not the symlink)

# Copy symlinks as symlinks (-P, default)
cp -P /etc/alternatives/python /tmp/python_link
# Explanation: reproduces the symlink itself in the destination

# Copy only specific file types (use find + cp)
find /var/log -name "*.log" -exec cp {} /backup/logs/ \;
# Explanation: find locates all .log files; cp copies each one

# Sparse file copy (for large files with holes — e.g. disk images)
cp --sparse=always /path/to/disk.img /backup/disk.img
# Explanation: preserves holes in sparse files for efficient storage

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 7: COMBINING OPTIONS — COMMON PATTERNS
# ─────────────────────────────────────────────────────────────────────────────

# Safe backup of a config file before editing
cp -p /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
# Explanation: standard sysadmin practice before ANY config change
# Always do this so you can restore with: cp /etc/ssh/sshd_config.bak /etc/ssh/sshd_config

# Recursive verbose preserve (full directory backup)
cp -avp /opt/myapp/ /backup/myapp_$(date +%Y%m%d)/
# Explanation: -a archive, -v verbose, -p preserve
# Creates a dated backup directory

# Copy only newer files recursively (incremental backup)
cp -rpu /opt/myapp/ /backup/myapp/
# Explanation: -u only copies changed files; -p preserves timestamps
# Much faster than full copy for large directories that rarely change

# Copy with timestamp in backup name
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.$(date +%Y%m%d_%H%M%S)
# Explanation: creates nginx.conf.20250625_143022 — unique timestamped backup

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 8: PRACTICAL SYSADMIN EXAMPLES
# ─────────────────────────────────────────────────────────────────────────────

# Backup function used in production scripts
backup_config() {
    local file="$1"
    local backup_dir="${2:-/backup/configs}"
    local timestamp=$(date '+%Y%m%d_%H%M%S')

    mkdir -p "$backup_dir"
    cp -p "$file" "${backup_dir}/$(basename $file).${timestamp}.bak"
    echo "Backed up: $file → ${backup_dir}/$(basename $file).${timestamp}.bak"
}

# Deploy web content to multiple servers (local copy step)
DEPLOY_DIR="/var/www/html"
RELEASE_DIR="/opt/releases/v1.2.0"
cp -a "$RELEASE_DIR/." "$DEPLOY_DIR/"
# Explanation: -a preserves all; /. copies contents not directory itself

# Stage config files for distribution
STAGING="/tmp/staging"
mkdir -p "$STAGING"
cp -p /etc/ssh/sshd_config "$STAGING/"
cp -p /etc/hosts "$STAGING/"
cp -p /etc/resolv.conf "$STAGING/"
# Then distribute staging dir to remote servers via rsync or scp

# Emergency config restore
restore_config() {
    local original="$1"
    local backup="${original}.bak"
    if [[ -f "$backup" ]]; then
        cp -p "$backup" "$original"
        echo "Restored: $original from $backup"
    else
        echo "No backup found: $backup"
        return 1
    fi
}
