#!/usr/bin/env bash

# Script: run-local.sh
# Description: Runs Jekyll local development server with error checking
# Usage: ./run-local.sh

set -euo pipefail  # Exit on error, undefined vars, and pipe failures

# ANSI color codes
CYAN='\033[36m'
YELLOW='\033[33m'
GREEN='\033[32m'
RED='\033[31m'
GRAY='\033[90m'
RESET='\033[0m'

# Check if command exists
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}[-] Error: $1 is not installed${RESET}"
        return 1
    fi
}

# Check if Ruby gems are installed
check_gems() {
    if ! gem list -i "^$1$" > /dev/null 2>&1; then
        echo -e "${RED}[-] Error: Ruby gem '$1' is not installed${RESET}"
        echo -e "${CYAN}[*] Try running: gem install $1${RESET}"
        return 1
    fi
}

echo -e "${CYAN}[*] Starting Jekyll environment checks...${RESET}"

# Check Ruby installation
echo -e "${CYAN}[*] Checking Ruby installation...${RESET}"
if check_command ruby; then
    ruby_version=$(ruby -v)
    echo -e "${GREEN}[+] Ruby is installed: $ruby_version${RESET}"
else
    echo -e "${YELLOW}[!] Please install Ruby first: https://www.ruby-lang.org/en/documentation/installation/${RESET}"
    exit 1
fi

# Check Bundler installation
echo -e "${CYAN}[*] Checking Bundler installation...${RESET}"
if check_command bundle; then
    bundler_version=$(bundle -v)
    echo -e "${GREEN}[+] Bundler is installed: $bundler_version${RESET}"
else
    echo -e "${RED}[-] Bundler is not installed${RESET}"
    echo -e "${CYAN}[*] Installing Bundler...${RESET}"
    if gem install bundler; then
        echo -e "${GREEN}[+] Bundler installed successfully${RESET}"
    else
        echo -e "${RED}[-] Failed to install Bundler${RESET}"
        exit 1
    fi
fi

# Check Jekyll installation
echo -e "${CYAN}[*] Checking Jekyll installation...${RESET}"
if check_gems jekyll; then
    jekyll_version=$(jekyll -v)
    echo -e "${GREEN}[+] Jekyll is installed: $jekyll_version${RESET}"
else
    echo -e "${YELLOW}[!] Jekyll gem not found, installing via Bundler...${RESET}"
    if bundle install; then
        echo -e "${GREEN}[+] Jekyll installed successfully${RESET}"
    else
        echo -e "${RED}[-] Failed to install Jekyll${RESET}"
        exit 1
    fi
fi

# Check if Gemfile exists
echo -e "${CYAN}[*] Checking Gemfile...${RESET}"
if [[ -f "Gemfile" ]]; then
    echo -e "${GREEN}[+] Gemfile found${RESET}"
else
    echo -e "${RED}[-] Gemfile not found in current directory${RESET}"
    exit 1
fi

# Install/Update dependencies
echo -e "${CYAN}[*] Installing/Updating dependencies...${RESET}"
if bundle install; then
    echo -e "${GREEN}[+] Dependencies installed successfully${RESET}"
else
    echo -e "${RED}[-] Failed to install dependencies${RESET}"
    exit 1
fi

# Capture additional arguments
JEKYLL_ARGS="$@"

echo -e "${CYAN}[*] Starting Jekyll server...${RESET}"
echo -e "${GRAY}[%] Running: bundle exec jekyll serve --watch --livereload --force_polling ${JEKYLL_ARGS}${RESET}"

if bundle exec jekyll serve --watch --livereload --force_polling ${JEKYLL_ARGS}; then
    echo -e "${GREEN}[+] Jekyll server stopped successfully${RESET}"
else
    echo -e "${RED}[-] Jekyll server failed${RESET}"
    exit 1
fi