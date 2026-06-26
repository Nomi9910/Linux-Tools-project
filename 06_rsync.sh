#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
#  TOOL: rsync — Remote Sync / Fast Incremental File Transfer
#  FILE: 06_rsync.sh
#  OS  : Red Hat Enterprise Linux 9
# ╠═══════════════════════════════════════════════════════════════════════════╣
#  WHAT IS RSYNC?
#  rsync is the industry-standard tool for efficiently copying and
#  synchronising files locally or over SSH. Its delta-transfer algorithm
#  sends ONLY the changed parts of files — making it far faster than cp or
#  scp for large or frequently updated datasets.
#
#  KEY ADVANTAGES OVER cp:
#   ✔ Only transfers changed files (incremental)
#   ✔ Can resume interrupted transfers
#   ✔ Shows transfer progress and speed
#   ✔ Works over SSH for remote sync
#   ✔ Preserves ALL metadata (-a flag)
#   ✔ Can delete files at destination not in source (--delete)
#   ✔ Supports dry-run to preview changes (-n / --dry-run)
#   ✔ Can exclude files/directories
#
#  BASIC SYNTAX:
#   rsync [OPTIONS] SOURCE DESTINATION
#   rsync [OPTIONS] SOURCE user@host:DESTINATION   (push to remote)
#   rsync [OPTIONS] user@host:SOURCE DESTINATION   (pull from remote)
#
#  INSTALL ON RHEL 9:
#   dnf install -y rsync
#
#  TRAILING SLASH RULE (CRITICAL):
#   rsync /src/dir  /dst/   → copies dir itself: /dst/dir/
#   rsync /src/dir/ /dst/   → copies CONTENTS of dir: /dst/file1 /dst/file2
#   The trailing slash on SOURCE controls this behaviour!
#
#  EXIT CODES:
#   0 = success    1 = syntax/usage error    11 = I/O error
#   23 = partial transfer    24 = partial (some source files vanished)
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 1: THE ESSENTIAL -avz FLAG COMBO (THE WORKHORSE)
# ─────────────────────────────────────────────────────────────────────────────

rsync -avz /source/ /destination/
# Flags explained:
#   -a  Archive mode: equivalent to -rlptgoD
#       -r  Recursive (copy directories)
#       -l  Copy symlinks as symlinks
#       -p  Preserve permissions
#       -t  Preserve modification timestamps
#       -g  Preserve group ownership
#       -o  Preserve owner (requires root)
#       -D  Preserve device and special files
#   -v  Verbose: show files being transferred
#   -z  Compress data during transfer (saves bandwidth)
# Result: exact mirror with all metadata preserved

# Same but show human-readable file sizes
rsync -avzh /source/ /destination/
# -h  Human-readable numbers (KB, MB, GB)

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 2: LOCAL FILE SYNCHRONISATION
# ─────────────────────────────────────────────────────────────────────────────

# Sync a directory (copy contents of source INTO dest)
rsync -av /etc/ssh/ /backup/ssh/
# Explanation: copies all files from /etc/ssh/ into /backup/ssh/
# Notice: trailing slash on source = copy contents, not directory itself

# Sync without trailing slash (copies the directory as a subdirectory)
rsync -av /etc/ssh /backup/
# Explanation: creates /backup/ssh/ — the directory is copied as a subdir

# Keep destination in sync — delete files not in source (--delete)
rsync -av --delete /var/www/html/ /backup/www/
# Explanation: files in /backup/www/ that don't exist in /var/www/html/ are REMOVED
# This creates a TRUE mirror — destination matches source exactly
# WARNING: --delete permanently removes files; always test with --dry-run first!

# Dry run — preview what WOULD happen without actually doing it
rsync -av --dry-run /source/ /destination/
rsync -avn /source/ /destination/    # -n is shorthand for --dry-run
# Explanation: shows exactly which files would be transferred/deleted
# ALWAYS do a dry run before using --delete for the first time!

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 3: REMOTE SYNCHRONISATION (OVER SSH)
# ─────────────────────────────────────────────────────────────────────────────

# Push files TO a remote server
rsync -avz /var/www/html/ user@192.168.1.100:/var/www/html/
# Explanation: copies local /var/www/html/ to remote server
# rsync automatically uses SSH for transport

# Pull files FROM a remote server
rsync -avz user@192.168.1.100:/etc/nginx/ /backup/nginx/
# Explanation: downloads remote nginx config to local backup directory

# Use a specific SSH key
rsync -avz -e "ssh -i ~/.ssh/deploy_key" /src/ user@host:/dst/
# Explanation: -e specifies the SSH command; useful for deploy scripts

# Use a non-standard SSH port
rsync -avz -e "ssh -p 2222" /src/ user@host:/dst/
# Explanation: -p 2222 tells SSH to use port 2222

# Compress + SSH options combined
rsync -avz -e "ssh -p 2222 -i ~/.ssh/id_ed25519 -o StrictHostKeyChecking=no" \
    /opt/myapp/ deploy@10.0.0.50:/opt/myapp/
# Explanation: production-ready remote sync with specific key and port

# Sync to multiple servers (loop)
SERVERS=("web01" "web02" "web03")
for server in "${SERVERS[@]}"; do
    echo "Syncing to $server..."
    rsync -avz --delete /var/www/html/ "deploy@${server}:/var/www/html/"
    echo "Done: $server"
done

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 4: EXCLUDING FILES & DIRECTORIES
# ─────────────────────────────────────────────────────────────────────────────

# Exclude a specific file
rsync -av --exclude='*.log' /source/ /destination/
# Explanation: skips all .log files during transfer

# Exclude a directory
rsync -av --exclude='.git' /source/ /destination/
rsync -av --exclude='.git/' /source/ /destination/
# Explanation: skips the .git directory and all its contents

# Exclude multiple patterns
rsync -av \
    --exclude='*.log' \
    --exclude='*.tmp' \
    --exclude='.git/' \
    --exclude='node_modules/' \
    --exclude='__pycache__/' \
    /opt/myapp/ /backup/myapp/

# Exclude from a file
cat > /tmp/rsync-exclude.txt << 'EXCLUDES'
*.log
*.tmp
*.pyc
.git/
.env
node_modules/
__pycache__/
*.bak
EXCLUDES

rsync -av --exclude-from='/tmp/rsync-exclude.txt' /opt/myapp/ /backup/myapp/
# Explanation: reads exclusion patterns from a file — cleaner for many patterns

# Include + Exclude (order matters — first match wins)
rsync -av \
    --include='*.conf' \
    --include='*/' \
    --exclude='*' \
    /etc/ /backup/etc-confs/
# Explanation: copies ONLY .conf files and directory structure; excludes everything else

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 5: PROGRESS & BANDWIDTH
# ─────────────────────────────────────────────────────────────────────────────

# Show transfer progress for each file
rsync -avh --progress /large/dataset/ /backup/dataset/
# Output: sending incremental file list
#         bigfile.tar.gz
#           1.23G  45%  112.34MB/s  0:00:08

# Show overall progress (requires rsync 3.1.0+)
rsync -avh --info=progress2 /large/dataset/ /backup/
# Output: 4.53G  45%   87.65MB/s   0:00:42 (xfr#23, ir-chk=478/512)
# Explanation: shows total transferred, percentage, speed, ETA

# Limit bandwidth usage (useful during business hours)
rsync -avz --bwlimit=5000 /source/ /destination/
# Explanation: limits transfer to 5000 KB/s (approx 5 MB/s)
# Prevents rsync from saturating the network

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 6: CHECKSUM & INTEGRITY
# ─────────────────────────────────────────────────────────────────────────────

# Force checksum comparison (slower but more accurate)
rsync -avc /source/ /destination/
# Explanation: -c uses MD5 checksums instead of size+timestamp to decide
# what needs copying; catches bit-rot and corruption but is slower

# Verify a completed rsync (should show 0 files to transfer)
rsync -avn --checksum /source/ /destination/
# Explanation: dry-run with checksum; if output is empty, destination matches source

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 7: ADVANCED OPTIONS
# ─────────────────────────────────────────────────────────────────────────────

# --partial  Keep partially transferred files (allows resume)
rsync -avz --partial /large/file.tar.gz user@host:/backup/
# Explanation: if transfer is interrupted, keeps the partial file
# Next rsync run will resume from where it left off

# --partial + --progress (most useful for large transfers)
rsync -avzh --partial --progress /large/file.tar.gz user@host:/backup/

# Hard links — preserve hard links in source
rsync -avH /source/ /destination/
# Explanation: -H preserves hard links (expensive — scans all files)

# Copy SELinux contexts
rsync -avX /source/ /destination/
# Explanation: -X preserves extended attributes (including SELinux labels)

# Full preservation including SELinux (most complete backup)
rsync -aAXvh /source/ /destination/
# -a  Archive, -A  Preserve ACLs, -X  Preserve xattrs (SELinux), -v verbose, -h human

# --stats  Show detailed transfer statistics at end
rsync -avz --stats /source/ /destination/
# Output: Number of files: 1,234
#         Number of created files: 45
#         Number of deleted files: 3
#         Number of regular files transferred: 45
#         Total file size: 1.23G bytes
#         Total transferred file size: 234.56M bytes
#         Literal data: 234.56M bytes
#         Transfer speed: 112.34 MB/sec

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 8: PRACTICAL SYSADMIN EXAMPLES
# ─────────────────────────────────────────────────────────────────────────────

# Daily backup script — local
daily_backup() {
    local SOURCE="/etc /home /var/www /opt/myapp"
    local DEST="/backup/daily/$(date +%Y-%m-%d)"
    local LOG="/var/log/rsync-backup.log"

    mkdir -p "$DEST"
    for dir in $SOURCE; do
        echo "$(date) Backing up $dir..." >> "$LOG"
        rsync -aAXzh --delete \
              --exclude='*.tmp' \
              --exclude='*.log' \
              --stats \
              "$dir" "$DEST/" >> "$LOG" 2>&1
        echo "$(date) Done: $dir (exit: $?)" >> "$LOG"
    done
    echo "$(date) Backup complete: $DEST" >> "$LOG"
}

# Deploy web app to remote server
deploy_webapp() {
    local LOCAL_BUILD="./dist/"
    local REMOTE="deploy@webserver:/var/www/html/"
    local SSH_KEY="~/.ssh/deploy_key"

    echo "=== Dry run first ==="
    rsync -avzn --delete \
          --exclude='.git' \
          --exclude='*.map' \
          -e "ssh -i $SSH_KEY" \
          "$LOCAL_BUILD" "$REMOTE"

    read -p "Proceed with deployment? (yes/no): " confirm
    [[ "$confirm" != "yes" ]] && { echo "Aborted."; return 1; }

    echo "=== Deploying ==="
    rsync -avzh --delete \
          --exclude='.git' \
          --exclude='*.map' \
          --stats \
          -e "ssh -i $SSH_KEY" \
          "$LOCAL_BUILD" "$REMOTE"
    echo "Deployment complete!"
}

# Mirror a remote directory locally (pull backup)
pull_remote_backup() {
    local REMOTE_HOST="backup-server"
    local REMOTE_PATH="/var/backups/"
    local LOCAL_PATH="/mnt/local-backup/"

    rsync -avzh \
          --info=progress2 \
          --bwlimit=10000 \
          "${REMOTE_HOST}:${REMOTE_PATH}" \
          "${LOCAL_PATH}"
}
