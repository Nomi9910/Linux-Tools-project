#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
#  TOOL: awk — Pattern Scanning & Text Processing Language
#  FILE: 03_awk.sh
#  OS  : Red Hat Enterprise Linux 9
# ╠═══════════════════════════════════════════════════════════════════════════╣
#  WHAT IS AWK?
#  awk is a full programming language designed for processing structured text.
#  It reads input line by line, splits each line into FIELDS, and runs
#  user-defined patterns and actions on each line.
#
#  On RHEL 9, the default is GNU awk (gawk). Syntax is identical to mawk/nawk.
#
#  BASIC SYNTAX:
#   awk [OPTIONS] 'PROGRAM' [FILE...]
#   awk [OPTIONS] -f script.awk [FILE...]
#   command | awk 'PROGRAM'
#
#  PROGRAM STRUCTURE:
#   BEGIN { ... }       runs ONCE before processing any lines
#   /PATTERN/ { ... }   runs for every line matching PATTERN
#   { ... }             runs for EVERY line (no pattern = match all)
#   END { ... }         runs ONCE after all lines are processed
#
#  BUILT-IN VARIABLES:
#   $0     entire current line
#   $1,$2  fields (columns) 1, 2, ...
#   NF     Number of Fields on current line
#   NR     Number of Records (current line number, global)
#   FNR    File Number of Records (line number within current file)
#   FS     Field Separator (default: whitespace)
#   OFS    Output Field Separator (default: space)
#   RS     Record Separator (default: newline)
#   ORS    Output Record Separator (default: newline)
#   FILENAME current file being processed
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 1: FIELDS & BUILT-IN VARIABLES
# ─────────────────────────────────────────────────────────────────────────────

# Print entire line ($0)
awk '{ print $0 }' /etc/passwd
# Explanation: same as cat — prints every line unchanged

# Print specific field
awk -F: '{ print $1 }' /etc/passwd
# Explanation: -F: sets field separator to colon; $1 is the username
# Output: root, daemon, bin, alice, ...

# Print multiple fields with custom separator
awk -F: '{ print $1, $3 }' /etc/passwd
# Output: root 0    daemon 1    alice 1001
# Explanation: $1=username $3=UID; default OFS (space) separates them

awk -F: 'BEGIN{OFS="\t"} { print $1, $3, $7 }' /etc/passwd
# Output: root    0    /bin/bash
# Explanation: OFS=\t makes tab-separated output; $7=shell

# Print last field (regardless of how many fields)
awk -F: '{ print $NF }' /etc/passwd
# Explanation: NF = number of fields, so $NF = last field (the shell)

# Print second-to-last field
awk -F: '{ print $(NF-1) }' /etc/passwd

# Print line numbers
awk '{ print NR": "$0 }' /etc/hosts
# Output: 1: 127.0.0.1   localhost
#         2: 127.0.1.1   myhostname

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 2: PATTERNS — FILTERING LINES
# ─────────────────────────────────────────────────────────────────────────────

# Pattern match (like grep inside awk)
awk '/root/' /etc/passwd
# Explanation: prints lines containing "root"

# Negation — lines NOT matching
awk '!/^#/' /etc/ssh/sshd_config
# Explanation: prints lines that don't start with #

# Field-based condition
awk -F: '$3 >= 1000' /etc/passwd
# Explanation: print lines where UID (field 3) is 1000 or more (regular users)

awk -F: '$3 == 0' /etc/passwd
# Explanation: print only root (UID=0)

awk -F: '$7 == "/bin/bash"' /etc/passwd
# Explanation: users whose shell is /bin/bash

awk -F: '$3 >= 1000 && $7 == "/bin/bash"' /etc/passwd
# Explanation: regular users with bash shell (AND condition)

awk -F: '$3 == 0 || $3 >= 1000' /etc/passwd
# Explanation: root OR regular users (OR condition)

# String match on specific field
awk -F: '$1 ~ /^a/' /etc/passwd
# Explanation: ~ is regex match; prints users whose name starts with 'a'

awk -F: '$1 !~ /^a/' /etc/passwd
# Explanation: !~ is regex NOT match

# Range pattern (from first match to second match)
awk '/START/,/END/' file.txt
# Explanation: prints all lines from START line to END line (inclusive)

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 3: BEGIN & END BLOCKS
# ─────────────────────────────────────────────────────────────────────────────

# Print header and footer
awk 'BEGIN { print "=== User Report ===" }
     { print $0 }
     END { print "=== Total lines: "NR" ===" }' /etc/passwd

# Count matching lines
awk '/bash/ { count++ } END { print "Bash users: " count }' /etc/passwd
# Explanation: increments counter for each matching line; prints at end

# Sum a column
awk '{ total += $1 } END { print "Total: " total }' numbers.txt

# Disk usage report with header
df -h | awk '
    BEGIN { printf "%-20s %6s %6s %6s %s\n", "Filesystem","Size","Used","Avail","Use%" }
    NR > 1 { printf "%-20s %6s %6s %6s %s\n", $1, $2, $3, $4, $5 }
'

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 4: ARITHMETIC & CALCULATIONS
# ─────────────────────────────────────────────────────────────────────────────

# Basic math
echo "5 3" | awk '{ print $1 + $2, $1 - $2, $1 * $2, $1 / $2 }'
# Output: 8 2 15 1.66667

# Calculate percentage
df | awk 'NR>1 {
    gsub(/%/,"",$5)
    if ($5 != "" && $5+0 > 0)
        printf "%s is %d%% full (%.1f%% remaining)\n", $6, $5, 100-$5
}'

# Average of a column
awk '{ sum += $1; count++ } END { printf "Average: %.2f\n", sum/count }' data.txt

# Memory usage as percentage
free | awk '/^Mem:/ { printf "Memory used: %.1f%%\n", $3/$2*100 }'
# Explanation: $3=used $2=total — divide and multiply by 100

# Convert bytes to MB in output
awk '{ printf "%s: %.2f MB\n", $1, $2/1024/1024 }' sizes.txt

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 5: ARRAYS
# ─────────────────────────────────────────────────────────────────────────────

# Count occurrences (like sort | uniq -c)
awk '{ count[$1]++ } END { for (key in count) print count[key], key }' /var/log/secure \
    | sort -rn | head -10
# Explanation: associative array — key=IP/user, value=count

# Count HTTP status codes from access log
awk '{ codes[$9]++ }
     END { for (code in codes) printf "%s: %d\n", code, codes[code] }' \
     /var/log/nginx/access.log | sort -k2 -rn

# Count failed logins per user
awk '/Failed password/ { users[$11]++ }
     END { for (u in users) printf "%4d  %s\n", users[u], u }' \
     /var/log/secure | sort -rn

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 6: STRING FUNCTIONS
# ─────────────────────────────────────────────────────────────────────────────

# length() — string or array length
awk '{ print length($0), $0 }' file.txt          # Line length
awk -F: '{ print length($1), $1 }' /etc/passwd   # Username length

# substr() — extract substring
awk '{ print substr($0, 1, 10) }' file.txt       # First 10 chars of each line
awk -F: '{ print substr($1, 1, 3) }' /etc/passwd # First 3 chars of username

# index() — find position of string
awk '{ print index($0, "root") }' /etc/passwd    # 0 if not found, position if found

# sub() — replace first occurrence (like sed s//)
awk '{ sub(/foo/, "bar"); print }' file.txt

# gsub() — replace all occurrences (like sed s//g)
awk '{ gsub(/foo/, "bar"); print }' file.txt
awk -F: '{ gsub(/:/, " | "); print }' /etc/passwd  # Replace colons with " | "

# split() — split string into array
awk '{ n = split($0, arr, ":"); for(i=1;i<=n;i++) print i": "arr[i] }' /etc/passwd

# toupper() / tolower()
awk '{ print toupper($0) }' file.txt
awk -F: '{ print tolower($1) }' /etc/passwd

# sprintf() — format without printing
awk '{ line = sprintf("%-10s %5d", $1, $2); print line }' data.txt

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 7: CONTROL FLOW
# ─────────────────────────────────────────────────────────────────────────────

# if / else
awk -F: '{
    if ($3 == 0)
        print $1, "is ROOT"
    else if ($3 >= 1000)
        print $1, "is a regular user (UID=" $3 ")"
    else
        print $1, "is a system account (UID=" $3 ")"
}' /etc/passwd

# for loop
awk 'BEGIN { for (i=1; i<=5; i++) print "Line " i }'

# while loop
awk 'BEGIN { i=1; while (i<=5) { print i; i++ } }'

# next — skip to the next line (like continue)
awk '/^#/ { next } { print }' /etc/ssh/sshd_config
# Explanation: skip comment lines; print the rest

# exit — stop processing
awk 'NR==5 { exit } { print }' file.txt
# Explanation: print first 4 lines then exit (NR==5 triggers exit before print)

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 8: PRACTICAL SYSADMIN EXAMPLES
# ─────────────────────────────────────────────────────────────────────────────

# Show username, UID, and shell for regular users
awk -F: '$3>=1000 { printf "%-15s UID:%-6d Shell: %s\n", $1, $3, $7 }' /etc/passwd

# Alert on disk usage above threshold
df -h | awk 'NR>1 {
    gsub(/%/,"",$5)
    if ($5+0 >= 80)
        printf "ALERT: %s is %s%% full!\n", $6, $5
}'

# Top memory consuming processes
ps aux | sort -k4 -rn | awk 'NR<=6 { printf "%-25s %5s%%\n", $11, $4 }'

# Parse /var/log/secure for sudo usage
awk '/sudo/ && /COMMAND/ {
    split($0, a, " : ")
    print "User:", $5, "| Command:", a[3]
}' /var/log/secure

# Generate a simple CSV report of users
awk -F: 'BEGIN { print "Username,UID,GID,Home,Shell" }
         $3>=1000 { print $1","$3","$4","$6","$7 }' /etc/passwd > /tmp/users.csv

# Count lines, words, and characters (like wc)
awk '{ lines++; words+=NF; chars+=length($0)+1 }
     END { printf "Lines:%d Words:%d Chars:%d\n", lines, words, chars }' file.txt

# Process nginx access log — requests per hour
awk '{ match($4, /[0-9]{2}:[0-9]{2}:[0-9]{2}/, t); split(t[0],h,":"); hours[h[1]]++ }
     END { for (h in hours) print h":00 →", hours[h], "requests" }' \
     /var/log/nginx/access.log | sort
