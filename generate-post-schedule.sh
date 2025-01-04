#!/usr/bin/env bash

# Script: generate-post-schedule.sh
# Description: Generates Jekyll blog post drafts from a schedule file
# Author: robertsinfosec (with GitHub CoPilot, mostly Claude 3.5 Sonnet)
# Version: 1.0
# Usage: ./generate-post-schedule.sh
# Requirements: bash, awk, sed, tr

set -euo pipefail  # Exit on error, undefined vars, and pipe failures

# ANSI color codes
CYAN='\033[36m'
YELLOW='\033[33m'
GREEN='\033[32m'
RED='\033[31m'
GRAY='\033[90m'
RESET='\033[0m'

if [[ ! -f "post-schedule.psv" ]]; then
  echo -e "${RED}[-] Error: post-schedule.psv not found in the current directory.${RESET}"
  echo ""
  echo "Please create a file named 'post-schedule.psv' with the following pipe-delimited format (no header):"
  echo ""
  echo "    2024-06-04|Building a Proxmox-Based Cybersecurity Lab: A Step-by-Step Guide|security, infrastructure|proxmox, cybersecurity, homelab"
  echo ""
  echo "Each line should represent: Date|Title|Categories|Tags"
  exit 1
fi

draftsFolder="_drafts"

# Create drafts folder if it doesn't exist
if [[ ! -d "$draftsFolder" ]]; then
    echo -e "${YELLOW}[!] Creating drafts folder: $draftsFolder${RESET}"
    mkdir -p "$draftsFolder" || {
        echo -e "${RED}[-] Error: Could not create drafts folder${RESET}"
        exit 1
    }
fi

# Validate date format in schedule file
validate_date() {
    local date=$1
    if ! [[ $date =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo -e "${RED}[-] Error: Invalid date format in schedule. Expected: YYYY-MM-DD${RESET}"
        return 1
    fi
}

# Cleanup on script exit
cleanup() {
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}[-] Script failed!${RESET}"
    fi
}
trap cleanup EXIT

echo -e "${CYAN}[*] Found 'post-schedule.psv'. Starting to process posts...${RESET}"

format_array() {
    local items="$1"
    echo "$items" | tr ',' '\n' | sed '/^[[:space:]]*$/d' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr '\n' ',' | sed 's/,/, /g;s/, $//'
}

slug() {
    local title="$1"
    echo -e "${GRAY}[%] Debug - Original title: $title${RESET}" >&2
    
    # Convert special chars to spaces & lowercase
    title=$(echo "$title" | tr -s '[:punct:]' ' ' | tr '[:upper:]' '[:lower:]')
    echo -e "${GRAY}[%] Debug - After special char removal: $title${RESET}" >&2
    
    # Keep only alphanumeric and spaces
    title=$(echo "$title" | tr -cd 'a-z0-9 ')
    echo -e "${GRAY}[%] Debug - After cleaning: $title${RESET}" >&2
    
    # Convert all spaces (including multiple) to single dashes
    title=$(echo "$title" | tr -s ' ' '-')
    echo -e "${GRAY}[%] Debug - After space conversion: $title${RESET}" >&2
    
    # Remove leading/trailing dashes
    title=$(echo "$title" | sed 's/^-//;s/-$//')
    echo -e "${GRAY}[%] Debug - Final slug: $title${RESET}" >&2
    
    echo "$title"
}

lineCount=0
newCount=0
updateCount=0

while IFS='|' read -r postDate postTitle postCategories postTags || [ -n "$postDate$postTitle$postCategories$postTags" ]; do
  # Trim each field
  postDate=$(echo "$postDate" | tr -d '\n\r' | xargs)
  postTitle=$(echo "$postTitle" | tr -d '\n\r' | xargs)
  postCategories=$(format_array "$postCategories")
  postTags=$(format_array "$postTags")
  
  #echo -e "${GRAY}[%] Debug - Tags before frontmatter: [$postTags]${RESET}"
  
  # Skip empty lines or comments
  if [[ -z "$postDate" ]] || [[ -z "$postTitle" ]] || [[ "$postDate" =~ ^[[:space:]]*# ]]; then
    #echo -e "${YELLOW}[!] Skipping empty or comment line.${RESET}"
    continue
  fi

  if ! validate_date "$postDate"; then
    echo -e "${YELLOW}[!] Skipping line due to invalid date format${RESET}"
    continue
  fi

  ((lineCount++))
  echo -e "${CYAN}[*] Processing line $lineCount: ${postDate} | ${postTitle}${RESET}"
  postSlug="$(slug "$postTitle")"
  fileName="$draftsFolder/${postDate}-${postSlug}.md"

  if [[ -f "$fileName" ]]; then
    echo -e "${YELLOW}[!] File exists: $fileName - Only updating frontmatter${RESET}"
    # Store existing content after frontmatter, including the newline after second ---
    existingContent=$(awk '
      BEGIN {p=0}
      /^---$/ {
        if(++n==2) {
          p=1;
          next;
        }
      }
      p==1 {
        if(buffer=="") buffer=$0;
        else buffer=buffer"\n"$0
      }
      END {print buffer}
    ' "$fileName")
    
    # Create new file with updated frontmatter, ensuring proper spacing
    cat <<EOF >"$fileName"
---
title: "$postTitle"
date: $postDate 12:00:00 -500
categories: [$postCategories]
tags: [$postTags]
published: true
---

$existingContent
EOF
    ((updateCount++))
    echo -e "${GREEN}[+] Updated frontmatter in: $fileName${RESET}"
    echo -e "${GRAY}[%] Debug - Updated $updateCount files so far${RESET}"
  else
    # Create new file
    cat <<EOF >"$fileName"
---
title: "$postTitle"
date: $postDate 12:00:00 -500
categories: [$postCategories]
tags: [$postTags]
published: true
---

TBD

EOF
    ((newCount++))
    echo -e "${GREEN}[+] Created new file: $fileName${RESET}"
    echo -e "${GRAY}[%] Debug - Created $newCount new files so far${RESET}"
  fi

done < post-schedule.psv || {
    echo -e "${RED}[-] Error reading post-schedule.psv${RESET}"
    exit 1
}

echo -e "${GREEN}[+] Completed processing post-schedule.psv: $newCount new posts, $updateCount updated${RESET}"