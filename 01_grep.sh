#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
#  TOOL: grep — Global Regular Expression Print
#  FILE: 01_grep.sh
#  OS  : Red Hat Enterprise Linux 9
# ╠═══════════════════════════════════════════════════════════════════════════╣
#  WHAT IS GREP?
#  grep searches files or standard input for lines matching a pattern and
#  prints every matching line. It is the most-used text-search tool on Linux.
#
#  VARIANTS:
#   grep   — standard (basic regular expressions, BRE)
#   egrep  — extended regex (same as grep -E)
#   fgrep  — fixed-string search, no regex (same as grep -F)
#   grep -P — Perl-compatible regex (PCRE) — most powerful
#
#  BASIC SYNTAX:
#   grep [OPTIONS] PATTERN [FILE...]
#   command | grep [OPTIONS] PATTERN
#
#  EXIT CODES:
#   0 = match found
#   1 = no match found
#   2 = error (file not found, etc.)
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 1: BASIC SEARCHING
# ─────────────────────────────────────────────────────────────────────────────

# Search for a word in a file
grep "root" /etc/passwd
# Explanation: prints every line in /etc/passwd that contains the word "root"
# Output example:  root:x:0:0:root:/root:/bin/bash

# Search in multiple files
grep "root" /etc/passwd /etc/group
# Explanation: grep prefixes each match with the filename when given multiple files
# Output: /etc/passwd:root:x:0:0:...
#         /etc/group:root:x:0:root

# Search all files in a directory (recursive)
grep -r "password" /etc/ssh/
# Explanation: -r walks subdirectories recursively and searches every file

# Search with a pattern from stdin (pipe)
cat /etc/passwd | grep "bash"
# Explanation: cat outputs the file, | pipes it into grep which filters lines

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 2: CASE & MATCH OPTIONS
# ─────────────────────────────────────────────────────────────────────────────

# -i  Case-insensitive search
grep -i "error" /var/log/messages
# Explanation: matches ERROR, Error, error, eRRoR — any capitalisation

# -w  Whole-word match only
grep -w "root" /etc/passwd
# Explanation: matches "root" but NOT "chroot" or "roots"

# -x  Whole-line match
grep -x "root:.*" /etc/passwd
# Explanation: the entire line must match the pattern exactly

# -v  Invert match (print lines that do NOT match)
grep -v "^#" /etc/ssh/sshd_config
# Explanation: suppresses comment lines; shows only active config directives

grep -v "^#" /etc/ssh/sshd_config | grep -v "^$"
# Explanation: chain two greps — first removes comments, second removes blank lines

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 3: OUTPUT CONTROL
# ─────────────────────────────────────────────────────────────────────────────

# -n  Show line numbers
grep -n "PermitRootLogin" /etc/ssh/sshd_config
# Output: 38:PermitRootLogin no
# Explanation: useful for jumping to the exact line in an editor

# -c  Count matching lines (not print them)
grep -c "Failed password" /var/log/secure
# Explanation: outputs a single integer — how many lines matched
# Use case: count failed SSH login attempts

# -l  List only filenames with matches (not the lines)
grep -rl "password" /etc/
# Explanation: useful for finding which config files mention passwords

# -L  List only filenames WITHOUT matches
grep -rL "PasswordAuthentication" /etc/ssh/
# Explanation: find SSH config files missing that directive

# -o  Print ONLY the matching portion (not the whole line)
grep -oE "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" /var/log/secure | head -10
# Explanation: extracts IP addresses only; -E enables extended regex

# -h  Suppress filename prefix in output (when searching multiple files)
grep -h "error" /var/log/*.log
# Explanation: combines output from all log files without file prefixes

# -q  Quiet — no output; just return exit code (use in scripts)
if grep -q "PermitRootLogin no" /etc/ssh/sshd_config; then
    echo "Root login is correctly disabled"
fi
# Explanation: -q is perfect for boolean checks in if statements

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 4: CONTEXT LINES
# ─────────────────────────────────────────────────────────────────────────────

# -A N  Print N lines AFTER each match
grep -A 3 "error" /var/log/messages
# Explanation: shows the error line + 3 lines below it (what happened next)

# -B N  Print N lines BEFORE each match
grep -B 2 "error" /var/log/messages
# Explanation: shows 2 lines before the error (what led up to it)

# -C N  Print N lines BEFORE and AFTER each match (context)
grep -C 2 "error" /var/log/messages
# Explanation: shows 2 lines of context around every matching line

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 5: REGULAR EXPRESSIONS
# ─────────────────────────────────────────────────────────────────────────────

# Anchors
grep "^root" /etc/passwd          # Lines starting with "root"
grep "bash$" /etc/passwd          # Lines ending with "bash"
grep "^$" /etc/passwd             # Empty lines only

# Character classes
grep "[0-9]" /etc/passwd          # Lines containing any digit
grep "[A-Z]" /etc/passwd          # Lines containing uppercase letters
grep "[^a-z]" /etc/hosts          # Lines with non-lowercase chars

# -E  Extended regex (egrep equivalent)
grep -E "error|warn|critical" /var/log/messages    # OR match
grep -E "^(root|nobody)" /etc/passwd               # Start with root or nobody
grep -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" /var/log/secure  # IP

# Quantifiers (with -E)
grep -E "lo+g" /var/log/messages        # l followed by one or more o, then g
grep -E "colou?r" /etc/              # matches "color" and "colour"
grep -E "[0-9]{3}-[0-9]{4}" contacts.txt  # phone number pattern

# -P  Perl regex (most powerful — use for complex patterns)
grep -P "\d{3}-\d{4}" contacts.txt       # \d = digit (PCRE shorthand)
grep -P "(?<=User )(\w+)" /var/log/secure # Lookbehind assertion

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 6: FILE & BINARY OPTIONS
# ─────────────────────────────────────────────────────────────────────────────

# -r  Recursive (search all files in directory tree)
grep -r "AllowUsers" /etc/ssh/

# --include  Only search files matching a glob
grep -r --include="*.conf" "Listen" /etc/
# Explanation: recursively search only .conf files

# --exclude  Skip files matching a glob
grep -r --exclude="*.log" "error" /var/

# --exclude-dir  Skip directories
grep -r --exclude-dir=".git" "TODO" /opt/myapp/

# -a  Treat binary files as text (search inside binaries)
grep -a "ELF" /usr/bin/ls

# -I  Ignore binary files (skip them silently)
grep -rI "password" /etc/

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 7: PRACTICAL SYSADMIN EXAMPLES
# ─────────────────────────────────────────────────────────────────────────────

# Find all failed SSH login attempts and count by IP
grep "Failed password" /var/log/secure \
    | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" \
    | sort | uniq -c | sort -rn | head -10
# Explanation: extract IPs → sort → count occurrences → show top 10 attackers

# Check if a package is installed
rpm -qa | grep -i "nginx"

# Find all users with /bin/bash shell
grep "/bin/bash$" /etc/passwd | cut -d: -f1

# Find config files containing a specific setting
grep -rl "ServerName" /etc/httpd/ 2>/dev/null

# Monitor logs for errors in real-time
tail -f /var/log/messages | grep --line-buffered -i "error\|warn\|critical"
# Explanation: --line-buffered flushes output immediately (essential for pipes)

# Count lines excluding comments and blanks
grep -v "^#\|^$" /etc/ssh/sshd_config | wc -l

# Find SUID files (security audit)
find / -perm /4000 2>/dev/null | grep -v proc
