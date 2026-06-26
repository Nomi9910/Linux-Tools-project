#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
#  TOOL: mv — Move (and Rename) Files and Directories
#  FILE: 05_mv.sh
#  OS  : Red Hat Enterprise Linux 9
# ╠═══════════════════════════════════════════════════════════════════════════╣
#  WHAT IS MV?
#  mv moves a file or directory to a new location, OR renames it.
#  When source and destination are on the SAME filesystem, mv is near-instant
#  (just updates the directory entry — no data is actually copied).
#  When crossing filesystems, mv copies then deletes (like cp + rm).
#
#  BASIC SYNTAX:
#   mv [OPTIONS] SOURCE DESTINATION
#   mv [OPTIONS] SOURCE... DIRECTORY
#
#  KEY CONCEPTS:
#   - mv is both MOVE and RENAME — same command
#   - mv removes the source after moving (unlike cp)
#   - mv preserves all metadata by default (owner, perms, timestamps)
#   - mv WILL overwrite destination by default — use -i or -n for safety
#   - Renaming = mv in the same directory with a different name
#
#  EXIT CODES:
#   0 = success     1 = error
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 1: BASIC MOVE & RENAME
# ─────────────────────────────────────────────────────────────────────────────

# Rename a file (same directory, different name)
mv oldname.txt newname.txt
# Explanation: oldname.txt no longer exists; newname.txt is the same file
# No data is copied — just the name in the directory changes instantly

# Move file to another directory (keeps same name)
mv report.txt /tmp/
# Explanation: file becomes /tmp/report.txt; original is gone

# Move file to another directory with a new name
mv report.txt /tmp/report_backup.txt
# Explanation: moves AND renames in one command

# Move multiple files into a directory
mv file1.txt file2.txt file3.txt /tmp/
# Explanation: all three files are moved to /tmp/ with their original names

# Move using wildcards
mv /tmp/*.log /var/log/myapp/
# Explanation: moves all .log files from /tmp/ into /var/log/myapp/

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 2: RENAMING DIRECTORIES
# ─────────────────────────────────────────────────────────────────────────────

# Rename a directory
mv myapp/ myapp_v1/
# Explanation: the directory is renamed; all contents remain unchanged
# This is instant regardless of how many files are inside (same filesystem)

# Move a directory into another directory
mv myapp/ /opt/
# Explanation: myapp/ becomes /opt/myapp/ — the entire tree moves

# Move directory contents (not the directory itself)
mv /opt/myapp/* /opt/newapp/
# Explanation: moves all files/subdirs from myapp into newapp
# NOTE: hidden files (dotfiles) are NOT included in *

# Move contents including hidden files
mv /opt/myapp/. /opt/newapp/
# Explanation: the /. trick includes hidden files and directories

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 3: SAFETY OPTIONS
# ─────────────────────────────────────────────────────────────────────────────

# -i  Interactive — prompt before overwriting
mv -i source.txt /tmp/destination.txt
# Explanation: if /tmp/destination.txt exists, asks: "overwrite? (y/n)"
# Essential in interactive shell sessions to prevent accidents
# TIP: alias mv='mv -i' in ~/.bashrc for safety

# -n  No-clobber — never overwrite existing files
mv -n source.txt /tmp/destination.txt
# Explanation: if destination exists, mv does NOTHING (no error, no overwrite)
# Different from -i: completely silent skip

# -f  Force — overwrite without prompting (default behaviour)
mv -f source.txt /tmp/destination.txt
# Explanation: overrides -i if both are specified; useful in scripts

# --backup  Create backup of destination before overwriting
mv --backup=numbered source.txt /tmp/destination.txt
# Explanation: if /tmp/destination.txt exists, it becomes /tmp/destination.txt.~1~
# Keeps all previous versions — great for rolling updates

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 4: VERBOSE OUTPUT
# ─────────────────────────────────────────────────────────────────────────────

# -v  Verbose — show what is being moved
mv -v /tmp/*.log /var/log/myapp/
# Output: renamed '/tmp/app.log' -> '/var/log/myapp/app.log'
#         renamed '/tmp/error.log' -> '/var/log/myapp/error.log'
# Explanation: confirms exactly what moved where — useful in scripts

mv -vi source.txt dest.txt
# Explanation: combine verbose + interactive for safe, informed moves

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 5: COMMON PATTERNS & TRICKS
# ─────────────────────────────────────────────────────────────────────────────

# Add a timestamp to a file (archive old version)
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.$(date +%Y%m%d_%H%M%S)
# Explanation: renames the existing file with a timestamp suffix
# You can then write the new config in its place

# Rotate a log file manually
mv /var/log/myapp/app.log /var/log/myapp/app.log.1
# Explanation: renames current log; app will create a fresh app.log on next write

# Move files matching a pattern using find
find /tmp -name "*.tmp" -exec mv {} /trash/ \;
# Explanation: find locates all .tmp files; mv moves each to /trash/

# Rename file extension (rename all .txt to .bak)
for f in /opt/myapp/*.txt; do
    mv "$f" "${f%.txt}.bak"
done
# Explanation: ${f%.txt} strips the .txt suffix; .bak is appended
# Output: file1.txt → file1.bak, file2.txt → file2.bak

# Rename files to lowercase
for f in /tmp/*.TXT; do
    mv "$f" "${f,,}"
done
# Explanation: ${f,,} lowercases the variable value (bash 4+)

# Prefix all files with a date
DATE=$(date +%Y%m%d)
for f in /tmp/reports/*.pdf; do
    mv "$f" "$(dirname $f)/${DATE}_$(basename $f)"
done
# Explanation: prepends YYYYMMDD_ to each filename

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 6: MV ACROSS FILESYSTEMS
# ─────────────────────────────────────────────────────────────────────────────
# When source and destination are on DIFFERENT filesystems (e.g., / and /mnt),
# mv performs a copy-then-delete under the hood.
# This means: data IS read and written; large files take time.
# For large transfers, rsync is preferred (progress, resume, checksums).

# Check if two paths are on the same filesystem
stat -c %d /source/file
stat -c %d /destination/
# Explanation: if the device numbers differ → different filesystem → mv = copy+delete

# Move a large file (same as cp + rm for cross-filesystem)
mv /data/large_backup.tar.gz /mnt/backup/
# If this is cross-filesystem, consider rsync instead:
# rsync -ah --progress /data/large_backup.tar.gz /mnt/backup/ && rm /data/large_backup.tar.gz

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 7: PRACTICAL SYSADMIN EXAMPLES
# ─────────────────────────────────────────────────────────────────────────────

# Safe config deployment pattern (backup → replace)
deploy_config() {
    local src="$1"
    local dest="$2"
    local backup="${dest}.$(date +%Y%m%d_%H%M%S).bak"

    # Backup existing if present
    [[ -f "$dest" ]] && mv -v "$dest" "$backup"

    # Move new config into place
    mv -v "$src" "$dest"
    echo "Deployed: $src → $dest (backup: $backup)"
}

deploy_config /tmp/sshd_config.new /etc/ssh/sshd_config

# Archive processed files
process_and_archive() {
    local input_dir="/var/spool/incoming"
    local archive_dir="/var/spool/archive/$(date +%Y/%m/%d)"

    mkdir -p "$archive_dir"
    for file in "$input_dir"/*.csv; do
        [[ -f "$file" ]] || continue
        echo "Processing: $file"
        # ... process the file ...
        mv -v "$file" "$archive_dir/"   # Move to archive after processing
    done
}

# Promote a staged release to live
promote_release() {
    local new_release="/opt/releases/v2.0.0"
    local live="/opt/myapp"
    local old_archive="/opt/releases/archive/$(date +%Y%m%d_%H%M%S)"

    mkdir -p "$(dirname $old_archive)"
    [[ -d "$live" ]] && mv -v "$live" "$old_archive"   # Archive current live
    mv -v "$new_release" "$live"                         # Promote new release
    echo "Release promoted. Previous version archived at: $old_archive"
}

# Clean up old log files (move to archive before deletion)
archive_old_logs() {
    local log_dir="/var/log/myapp"
    local archive="/var/archive/logs/$(date +%Y%m)"
    mkdir -p "$archive"
    find "$log_dir" -name "*.log" -mtime +30 -exec mv -v {} "$archive/" \;
    echo "Archived logs older than 30 days to: $archive"
}
