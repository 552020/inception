#!/bin/bash

# Function to generate a random password
generate_password() {
    # Generates a 16-character password with letters, numbers, and special characters
    < /dev/urandom tr -dc 'A-Za-z0-9!@#$%^&*()_+' | head -c 16
    echo
}

# Set target path (current directory if no argument provided)
target_path="${1:-.}/secrets"

# Create secrets directory
mkdir -p "$target_path"

# Array of password files
password_files=(
    "mysql_root_password.txt"
    "mysql_user_password.txt"
    "wp_admin_password.txt"
    "wp_user_password.txt"
)

# Create password files with random passwords
for file in "${password_files[@]}"; do
    generate_password > "$target_path/$file"
    echo "Created $file with random password"
done

echo "Secrets folder created at: $target_path"