#!/bin/bash

# Script to generate YAML photo lists for albums from uploaded images

echo "Generating YAML for uploaded images..."
echo ""

# Function to generate YAML for a specific prefix
generate_yaml() {
    local prefix=$1
    local album_name=$2

    echo "# $album_name"
    echo "photos:"

    # Filter uploaded images by prefix and generate YAML
    grep "^$prefix-" uploaded-images.log 2>/dev/null | while read -r image_id; do
        # Extract the number/name part after the prefix
        local name_part=${image_id#$prefix-}
        echo "  - src: \"$image_id\""
        echo "    alt: \"Photo $name_part\""
    done
    echo ""
}

# Generate for each album
echo "---"
echo "layout: album"
echo "title: \"Your Album Title\""
echo "date: $(date +%Y-%m-%d)"
echo "cover_image: \"CHANGE_ME\""
echo ""

# Check which prefixes have uploaded images based on folder names
if grep -q "^2025-elopement-announcement-" uploaded-images.log 2>/dev/null; then
    generate_yaml "2025-elopement-announcement" "Elopement Announcement"
fi

if grep -q "^2025-bc-honeymoon-" uploaded-images.log 2>/dev/null; then
    generate_yaml "2025-bc-honeymoon" "BC Honeymoon"
fi

if grep -q "^2025-vancouver-honeymoon-" uploaded-images.log 2>/dev/null; then
    generate_yaml "2025-vancouver-honeymoon" "Vancouver Honeymoon"
fi

if grep -q "^2024-maine-summer-" uploaded-images.log 2>/dev/null; then
    generate_yaml "2024-maine-summer" "Maine Summer 2024"
fi

if grep -q "^newsletters-" uploaded-images.log 2>/dev/null; then
    generate_yaml "newsletters" "Newsletters"
fi

echo "---"
echo ""
echo "Add your album description here..."