#!/bin/bash

# Cloudflare Images Upload Script
# Uploads images from local-images folder to Cloudflare Images

# Configuration - Both should be environment variables
ACCOUNT_ID="${CLOUDFLARE_ACCOUNT_ID}"
API_TOKEN="${CLOUDFLARE_API_TOKEN}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if environment variables are set
if [ -z "$ACCOUNT_ID" ]; then
    echo -e "${RED}Error: CLOUDFLARE_ACCOUNT_ID environment variable not set${NC}"
    echo "Please set it with: export CLOUDFLARE_ACCOUNT_ID='your-account-id'"
    echo "Or copy .env.example to .env and fill in your values"
    exit 1
fi

if [ -z "$API_TOKEN" ]; then
    echo -e "${RED}Error: CLOUDFLARE_API_TOKEN environment variable not set${NC}"
    echo "Please set it with: export CLOUDFLARE_API_TOKEN='your-token-here'"
    exit 1
fi

# Function to upload a single image
upload_image() {
    local file_path=$1
    local custom_id=$2

    echo -e "${YELLOW}Uploading: ${file_path}${NC}"

    response=$(curl -s -X POST \
        "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/images/v1" \
        -H "Authorization: Bearer ${API_TOKEN}" \
        -F "file=@${file_path}" \
        -F "id=${custom_id}")

    # Check if upload was successful
    if echo "$response" | grep -q '"success":true'; then
        echo -e "${GREEN}✓ Successfully uploaded: ${custom_id}${NC}"
        echo "$custom_id" >> uploaded-images.log
    else
        echo -e "${RED}✗ Failed to upload: ${file_path}${NC}"
        echo "Error response: $response"
    fi
}

# Function to process a directory
process_directory() {
    local dir=$1
    local prefix=$2

    echo -e "\n${GREEN}Processing directory: ${dir}${NC}"

    # Find all image files in directory
    for image in "$dir"/*.{jpg,jpeg,png,gif,webp} 2>/dev/null; do
        [ -e "$image" ] || continue

        # Generate custom ID from filename
        filename=$(basename "$image")
        name_without_ext="${filename%.*}"
        custom_id="${prefix}-${name_without_ext}"

        # Clean the ID (remove spaces, special chars)
        custom_id=$(echo "$custom_id" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g')

        upload_image "$image" "$custom_id"

        # Small delay to avoid rate limiting
        sleep 0.5
    done
}

# Main execution
echo "==================================="
echo "Cloudflare Images Upload Script"
echo "==================================="

# Process each album directory
if [ -d "local-images/2024-maine-summer" ]; then
    process_directory "local-images/2024-maine-summer" "maine"
fi

if [ -d "local-images/2025-elopement-photos" ]; then
    process_directory "local-images/2025-elopement-photos" "elopement"
fi

if [ -d "local-images/2025-british-columbia-honeymoon" ]; then
    process_directory "local-images/2025-british-columbia-honeymoon" "bc"
fi

if [ -d "local-images/newsletters" ]; then
    process_directory "local-images/newsletters" "newsletter"
fi

echo -e "\n${GREEN}Upload complete!${NC}"
echo "Check uploaded-images.log for list of uploaded image IDs"