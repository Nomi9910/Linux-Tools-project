#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
#  TOOL: sed — Stream Editor
#  FILE: 02_sed.sh
#  OS  : Red Hat Enterprise Linux 9
# ╠═══════════════════════════════════════════════════════════════════════════╣
#  WHAT IS SED?
#  sed reads input line by line, applies editing commands, and writes the
#  result to stdout. It never modifies the original file unless you use -i.
#  It is ideal for find-and-replace, deletion, insertion, and transformation
#  of text in files or streams — without opening an editor.
#
#  BASIC SYNTAX:
#   sed [OPTIONS] 'COMMAND' [FILE...]
#   sed [OPTIONS] -e 'CMD1' -e 'CMD2' [FILE...]
#   command | sed 'COMMAND'
#
#  COMMAND STRUCTURE:
#   [ADDRESS][!]COMMAND[ARGUMENTS]
#   ADDRESS  = which line(s) to act on (default: all lines)
#   !        = invert — act on lines NOT matching address
#   COMMAND  = s (substitute), d (delete), p (print), i (insert), etc.
#
#  EXIT CODES:
#   0 = success     1 = error in script/options
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 1: SUBSTITUTE (s) — THE MOST USED COMMAND
# ─────────────────────────────────────────────────────────────────────────────
# Syntax: s/PATTERN/REPLACEMENT/[FLAGS]
# Flags:
#   g = global (replace all occurrences on the line, not just first)
#   i = case-insensitive match
#   p = print the line if substitution was made
#   N = replace Nth occurrence only

# Replace first occurrence on each line
echo "hello hello hello" | sed 's/hello/world/'
# Output: world hello hello
# Explanation: without /g, only the FIRST match per line is replaced

# Replace ALL occurrences on each line (global flag)
echo "hello hello hello" | sed 's/hello/world/g'
# Output: world world world

# Case-insensitive replacement
echo "Hello HELLO hElLo" | sed 's/hello/hi/gi'
# Output: hi hi hi

# Replace only the 2nd occurrence
echo "aaa aaa aaa" | sed 's/aaa/bbb/2'
# Output: aaa bbb aaa

# Replace from 2nd occurrence onward
echo "aaa aaa aaa" | sed 's/aaa/bbb/2g'
# Output: aaa bbb bbb

# ── In-place editing (-i) ─────────────────────────────────────
# WARNING: -i modifies the ACTUAL FILE on disk

# Replace in file, no backup
sed -i 's/old_value/new_value/g' /etc/myapp/config.ini
# Explanation: modifies config.ini directly

# Replace in file WITH backup (safe approach)
sed -i.bak 's/old_value/new_value/g' /etc/myapp/config.ini
# Explanation: creates config.ini.bak before modifying
# Always use .bak when editing system config files!

# Real-world example: disable root SSH login
sed -i.bak 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
# Explanation:
#   ^#*   = optional leading # (handles commented-out setting)
#   .*    = anything after the directive name
#   Replaces the whole line with the correct value

# Change default shell
sed -i 's|/bin/sh|/bin/bash|g' /etc/passwd
# Explanation: using | as delimiter (avoids escaping / in paths)

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 2: ADDRESS RANGES — TARGETING SPECIFIC LINES
# ─────────────────────────────────────────────────────────────────────────────

# By line number
sed '3s/old/new/' file.txt          # Only line 3
sed '3,7s/old/new/' file.txt        # Lines 3 through 7
sed '3,7s/old/new/g' file.txt       # All matches on lines 3-7
sed '1s/old/new/' file.txt          # First line only
sed '$s/old/new/' file.txt          # Last line only

# By regex pattern
sed '/^#/d' file.txt                # Delete lines starting with #
sed '/error/s/old/new/g' file.txt   # Only substitute on lines containing "error"

# From pattern to pattern
sed '/START/,/END/s/foo/bar/g' file.txt
# Explanation: substitutes only within the block between START and END lines

# Negation (!) — apply to lines NOT matching
sed '/^#/!s/old/new/g' file.txt
# Explanation: substitute on all lines that do NOT start with #

# Every Nth line (step)
sed '0~2s/old/new/' file.txt        # Every even line (0, 2, 4...)
sed '1~2s/old/new/' file.txt        # Every odd line (1, 3, 5...)

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 3: DELETE (d) — REMOVING LINES
# ─────────────────────────────────────────────────────────────────────────────

# Delete specific line number
sed '5d' file.txt                   # Delete line 5
sed '1d' file.txt                   # Delete first line (header)
sed '$d' file.txt                   # Delete last line

# Delete a range of lines
sed '3,7d' file.txt                 # Delete lines 3 through 7

# Delete lines matching a pattern
sed '/^#/d' /etc/ssh/sshd_config    # Remove all comment lines
sed '/^$/d' file.txt                # Remove all blank lines
sed '/^#/d; /^$/d' file.txt         # Remove comments AND blank lines

# Delete from pattern to end of file
sed '/^APPENDIX/,$d' document.txt
# Explanation: deletes from the line containing APPENDIX to end of file

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 4: PRINT (p) — SELECTIVE OUTPUT
# ─────────────────────────────────────────────────────────────────────────────
# Note: use -n to suppress default output (only print what you ask for)

# Print only line 5
sed -n '5p' file.txt

# Print lines 5 through 10
sed -n '5,10p' file.txt

# Print lines matching a pattern
sed -n '/error/p' /var/log/messages
# Explanation: same as grep "error" but sed can combine with other commands

# Print line number with match
sed -n '/error/{=;p}' /var/log/messages
# Explanation: = prints the line number; p prints the line itself

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 5: INSERT (i), APPEND (a), CHANGE (c)
# ─────────────────────────────────────────────────────────────────────────────

# Insert text BEFORE a line
sed '3i\This line is inserted before line 3' file.txt
sed '/^PORT/i\# Port configuration section' /etc/myapp/config

# Append text AFTER a line
sed '3a\This line is appended after line 3' file.txt
sed '/^ServerName/a\ServerAlias www.example.com' /etc/httpd/conf/httpd.conf

# Change (replace) entire line
sed '3c\This replaces line 3 entirely' file.txt
sed '/^Port 22/c\Port 2222' /etc/ssh/sshd_config
# Explanation: replaces the WHOLE line (vs s which replaces pattern within line)

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 6: MULTIPLE COMMANDS
# ─────────────────────────────────────────────────────────────────────────────

# -e  Multiple expressions in one command
sed -e 's/foo/bar/g' -e 's/baz/qux/g' file.txt
# Explanation: applies both substitutions in sequence

# Semicolon separator
sed 's/foo/bar/g; s/baz/qux/g' file.txt

# -f  Read commands from a script file
cat > /tmp/myscript.sed << 'SEDSCRIPT'
# Remove comment lines
/^#/d
# Remove blank lines
/^$/d
# Replace old with new
s/old_setting/new_setting/g
# Fix indentation
s/^   /\t/
SEDSCRIPT

sed -f /tmp/myscript.sed /etc/myapp/config.ini
# Explanation: useful for complex transforms — keep sed scripts in version control

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 7: SPECIAL CHARACTERS & BACK-REFERENCES
# ─────────────────────────────────────────────────────────────────────────────

# & in replacement = the entire matched string
echo "hello world" | sed 's/world/[&]/'
# Output: hello [world]
# Explanation: & is replaced by whatever was matched

# Wrap every word in quotes
echo "apple orange banana" | sed 's/[a-z]*/"&"/g'
# Output: "apple" "orange" "banana"

# \1, \2  Back-references — reuse captured groups
echo "John Smith" | sed 's/\(.*\) \(.*\)/\2, \1/'
# Output: Smith, John
# Explanation: \(...\) captures groups; \1 and \2 reuse them
# Use -E for cleaner syntax without backslashes:
echo "John Smith" | sed -E 's/(.*) (.*)/\2, \1/'

# Swap key=value pairs
echo "name=Alice" | sed -E 's/([^=]+)=(.*)/\2=\1/'
# Output: Alice=name

# Remove leading whitespace
sed 's/^[[:space:]]*//' file.txt

# Remove trailing whitespace
sed 's/[[:space:]]*$//' file.txt

# Remove both leading and trailing whitespace (trim)
sed 's/^[[:space:]]*//; s/[[:space:]]*$//' file.txt

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 8: PRACTICAL SYSADMIN EXAMPLES
# ─────────────────────────────────────────────────────────────────────────────

# Harden SSH config — multiple changes in one pass
sed -i.bak \
    -e 's/^#*PermitRootLogin.*/PermitRootLogin no/' \
    -e 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' \
    -e 's/^#*X11Forwarding.*/X11Forwarding no/' \
    -e 's/^#*MaxAuthTries.*/MaxAuthTries 3/' \
    /etc/ssh/sshd_config
# Explanation: updates multiple SSH directives in a single sed command

# Extract active (non-comment, non-blank) config lines
sed '/^#/d; /^$/d' /etc/ssh/sshd_config

# Set a value in a key=value config file
KEY="db_host"
VALUE="db.example.com"
FILE="/etc/myapp/config.ini"
if grep -q "^${KEY}=" "$FILE"; then
    sed -i "s|^${KEY}=.*|${KEY}=${VALUE}|" "$FILE"
else
    echo "${KEY}=${VALUE}" >> "$FILE"
fi

# Add a line after a specific match (e.g. add AllowUsers after Port)
sed -i '/^Port 22/a AllowUsers admin alice' /etc/ssh/sshd_config

# Convert Windows line endings (CRLF) to Unix (LF)
sed -i 's/\r//' file.txt
# Explanation: \r is the carriage return character

# Comment out a line
sed -i '/^ServerName/s/^/#/' /etc/httpd/conf/httpd.conf

# Uncomment a line
sed -i '/^#ServerName/s/^#//' /etc/httpd/conf/httpd.conf

# Double-space a file (add blank line after every line)
sed 'G' file.txt
# Explanation: G appends a newline + hold space (initially empty)

# Number all lines
sed = file.txt | sed 'N; s/\n/\t/'
# Explanation: = prints line number, N joins pairs, s replaces newline with tab
