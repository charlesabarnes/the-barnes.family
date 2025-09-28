#!/bin/bash

# Generate YAML photo list for album markdown files
# Based on uploaded images in Cloudflare

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to generate YAML for a directory
generate_yaml() {
    local dir=$1
    local prefix=$2
    local output_file=$3

    echo -e "${YELLOW}Generating YAML for: ${dir}${NC}"

    # Start YAML photo list
    echo "photos:" > "$output_file"

    # Process each image in directory
    for image in "$dir"/*.{jpg,jpeg,png,gif,webp} 2>/dev/null; do
        [ -e "$image" ] || continue

        # Generate ID matching upload script
        filename=$(basename "$image")
        name_without_ext="${filename%.*}"
        custom_id="${prefix}-${name_without_ext}"
        custom_id=$(echo "$custom_id" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g')

        # Generate human-readable alt text
        alt_text=$(echo "$name_without_ext" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')

        # Add to YAML
        echo "  - src: \"$custom_id\"" >> "$output_file"
        echo "    alt: \"$alt_text\"" >> "$output_file"
    done

    echo -e "${GREEN}✓ Generated: ${output_file}${NC}"
}

# Main execution
echo "==================================="
echo "Album YAML Generator"
echo "==================================="
echo "This will generate photo lists for your album markdown files"
echo ""

# Create output directory
mkdir -p generated-yaml

# Generate YAML for each album
if [ -d "local-images/2024-maine-summer" ]; then
    generate_yaml "local-images/2024-maine-summer" "maine" "generated-yaml/2024-maine-summer-photos.yaml"
fi

if [ -d "local-images/2025-elopement-photos" ]; then
    generate_yaml "local-images/2025-elopement-photos" "elopement" "generated-yaml/2025-elopement-photos.yaml"
fi

if [ -d "local-images/2025-british-columbia-honeymoon" ]; then
    generate_yaml "local-images/2025-british-columbia-honeymoon" "bc" "generated-yaml/2025-british-columbia-honeymoon.yaml"
fi

echo ""
echo -e "${GREEN}YAML generation complete!${NC}"
echo "Copy the contents from generated-yaml/*.yaml to your album markdown files"
echo ""
echo "Example usage:"
echo "  cat generated-yaml/2024-maine-summer-photos.yaml"
echo "  # Then copy to _albums/2024-maine-summer.md"