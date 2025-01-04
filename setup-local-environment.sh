#!/bin/bash

# Install components to run Jekyll on local Windows workstation

function write_message {
    local message=$1
    local color=$2

    case $color in
        "Cyan")
            echo -e "\e[36m$message\e[0m"
            ;;
        "Green")
            echo -e "\e[32m$message\e[0m"
            ;;
        "Red")
            echo -e "\e[31m$message\e[0m"
            ;;
        "White")
            echo -e "\e[37m$message\e[0m"
            ;;
        *)
            echo "$message"
            ;;
    esac
}

write_message "[*] STEP 1: Install Ruby via APT" "Cyan"

sudo apt-get update
sudo apt-get install -y ruby-full build-essential zlib1g-dev

if command -v ruby &> /dev/null; then
    write_message "[+] - Ruby installed successfully!" "Green"
else
    write_message "[-] - Failed to install Ruby." "Red"
    exit 1
fi

write_message "[*] STEP 2: Install Bundler" "Cyan"

gem install bundler --user-install
if [ $? -eq 0 ]; then
    write_message "[+] - Bundler installed successfully!" "Green"
else
    write_message "[-] - Failed to install Bundler." "Red"
    exit 1
fi

write_message "[*] STEP 3: Install Jekyll and Dependencies via Bundler" "Cyan"

bundle config set --local path 'vendor/bundle'
bundle install
if [ $? -eq 0 ]; then
    write_message "[+] - Jekyll and dependencies installed successfully!" "Green"
else
    write_message "[-] - Failed to install Jekyll and dependencies." "Red"
    exit 1
fi

write_message "" "White"
write_message "[+] - Jekyll and Bundler have been installed successfully!" "Green"
write_message "" "White"
write_message "To start the Jekyll server, run the following command:" "White"
write_message "" "White"
write_message "  bundle exec jekyll serve" "White"
write_message "" "White"
write_message "To start the Jekyll server and include your unpublished drafts, run the following command:" "White"
write_message "" "White"
write_message "  bundle exec jekyll serve --drafts" "White"
write_message "" "White"

write_message "[+] Done!" "Green"