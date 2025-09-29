#!/bin/bash

# Cloudflare R2 Upload Script
# Uploads images from local-images folder to Cloudflare R2 bucket
# Saves results as JSON for Jekyll to consume

# Get the script's directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Load environment variables from .env file if it exists
if [ -f "$PROJECT_ROOT/.env" ]; then
    echo "Loading environment variables from .env file..."
    set -a
    source "$PROJECT_ROOT/.env"
    set +a
elif [ -f .env ]; then
    echo "Loading environment variables from .env file..."
    set -a
    source .env
    set +a
fi

# Configuration - All should be environment variables
ACCOUNT_ID="${CLOUDFLARE_ACCOUNT_ID}"
API_TOKEN="${CLOUDFLARE_API_TOKEN}"
R2_ACCESS_KEY_ID="${R2_ACCESS_KEY_ID}"
R2_SECRET_ACCESS_KEY="${R2_SECRET_ACCESS_KEY}"
R2_BUCKET="${R2_BUCKET:-family-images}"
R2_ENDPOINT="${R2_ENDPOINT:-https://${ACCOUNT_ID}.r2.cloudflarestorage.com}"
R2_PUBLIC_URL="${R2_PUBLIC_URL:-https://images.the-barnes.family}"

# JSON output file
JSON_FILE="_data/r2_images.json"

# Initialize JSON array
json_array='[]'

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

if [ -z "$R2_ACCESS_KEY_ID" ] || [ -z "$R2_SECRET_ACCESS_KEY" ]; then
    echo -e "${RED}Error: R2 credentials not set${NC}"
    echo "Please set R2_ACCESS_KEY_ID and R2_SECRET_ACCESS_KEY"
    exit 1
fi

# Check if aws CLI is installed
if ! command -v aws &> /dev/null; then
    # Try to use local install if available
    if [ -f ~/.local/bin/aws ]; then
        export PATH=$PATH:~/.local/bin
    else
        echo -e "${RED}AWS CLI not found. Please install it first.${NC}"
        echo "Run: curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip' && unzip awscliv2.zip && ./aws/install --user"
        exit 1
    fi
fi

# Configure AWS CLI for R2
export AWS_ACCESS_KEY_ID="${R2_ACCESS_KEY_ID}"
export AWS_SECRET_ACCESS_KEY="${R2_SECRET_ACCESS_KEY}"
export AWS_DEFAULT_REGION="auto"

# Function to add image to JSON
add_to_json() {
    local folder="$1"
    local filename="$2"
    local r2_path="$3"
    local status="$4"
    local url="$5"

    # Escape special characters for JSON
    folder=$(echo "$folder" | sed 's/"/\\"/g')
    filename=$(echo "$filename" | sed 's/"/\\"/g')
    r2_path=$(echo "$r2_path" | sed 's/"/\\"/g')
    url=$(echo "$url" | sed 's/"/\\"/g')

    # Create JSON object for this image
    local json_obj=$(cat <<EOF
{
  "folder": "$folder",
  "filename": "$filename",
  "r2_path": "$r2_path",
  "url": "$url",
  "status": "$status",
  "uploaded_at": "$(date -Iseconds)"
}
EOF
)

    # Add to array using jq if available, otherwise use string manipulation
    if command -v jq &> /dev/null; then
        json_array=$(echo "$json_array" | jq ". += [$json_obj]")
    else
        # Manual JSON array append (less robust but works)
        if [ "$json_array" = "[]" ]; then
            json_array="[$json_obj]"
        else
            # Remove closing bracket, add comma and new object, add closing bracket
            json_array="${json_array%]}, $json_obj]"
        fi
    fi
}

# Function to upload a single image
upload_image() {
    local file_path=$1
    local r2_path=$2
    local folder=$3

    local filename=$(basename "$file_path")
    echo -e "${YELLOW}Uploading: ${file_path} to ${r2_path}${NC}"

    # Upload to R2 using AWS CLI
    if aws s3 cp "$file_path" "s3://${R2_BUCKET}/${r2_path}" \
        --endpoint-url "${R2_ENDPOINT}" \
        --no-verify-ssl 2>/dev/null; then

        echo -e "${GREEN}✓ Successfully uploaded: ${r2_path}${NC}"

        # Construct public URL
        url="${R2_PUBLIC_URL}/${r2_path}"
        echo "  URL: $url"

        # Add to JSON
        add_to_json "$folder" "$filename" "$r2_path" "success" "$url"
        echo "$r2_path" >> uploaded-r2-images.log

    else
        # Check if file already exists
        if aws s3 ls "s3://${R2_BUCKET}/${r2_path}" \
            --endpoint-url "${R2_ENDPOINT}" \
            --no-verify-ssl 2>/dev/null | grep -q "$filename"; then

            echo -e "${YELLOW}⚠ Already exists: ${r2_path}${NC}"
            url="${R2_PUBLIC_URL}/${r2_path}"
            add_to_json "$folder" "$filename" "$r2_path" "existing" "$url"
            echo "$r2_path" >> uploaded-r2-images.log
        else
            echo -e "${RED}✗ Failed to upload: ${file_path}${NC}"
            add_to_json "$folder" "$filename" "$r2_path" "failed" ""
        fi
    fi
}

# Function to process a directory
process_directory() {
    local dir=$1
    local prefix=$2

    echo -e "\n${GREEN}Processing directory: ${dir}${NC}"

    # Find all image and video files in directory
    for image in "$dir"/*.jpg "$dir"/*.jpeg "$dir"/*.png "$dir"/*.gif "$dir"/*.webp "$dir"/*.mp4 "$dir"/*.mov "$dir"/*.avi "$dir"/*.webm; do
        [ -e "$image" ] || continue

        # Generate R2 path from filename
        filename=$(basename "$image")
        r2_path="${prefix}/${filename}"

        upload_image "$image" "$r2_path" "$prefix"

        # Small delay to avoid rate limiting
        sleep 0.2
    done
}

# Main execution
echo "==================================="
echo "Cloudflare R2 Upload Script"
echo "==================================="
echo "Bucket: ${R2_BUCKET}"
echo "Public URL: ${R2_PUBLIC_URL}"
echo ""

# Check if local-images directory exists
if [ ! -d "local-images" ]; then
    echo -e "${RED}Error: local-images directory not found${NC}"
    exit 1
fi

# Create log file
> uploaded-r2-images.log

# Process all directories in local-images automatically
for dir in local-images/*/; do
    # Skip if not a directory
    [ -d "$dir" ] || continue

    # Get directory name without path
    dirname=$(basename "$dir")

    # Skip hidden directories
    [[ "$dirname" == .* ]] && continue

    # Use the folder name directly as the prefix
    prefix="$dirname"

    process_directory "$dir" "$prefix"
done

# Save JSON to file
mkdir -p _data
echo "{" > "$JSON_FILE"
echo "  \"generated_at\": \"$(date -Iseconds)\"," >> "$JSON_FILE"
echo "  \"bucket\": \"${R2_BUCKET}\"," >> "$JSON_FILE"
echo "  \"public_url\": \"${R2_PUBLIC_URL}\"," >> "$JSON_FILE"
echo "  \"images\": $json_array" >> "$JSON_FILE"
echo "}" >> "$JSON_FILE"

# Check if any images were uploaded
if [ -f "uploaded-r2-images.log" ] && [ -s "uploaded-r2-images.log" ]; then
    echo -e "\n${GREEN}Upload complete!${NC}"
    echo "Check uploaded-r2-images.log for list of uploaded image paths"
    echo "JSON data saved to $JSON_FILE"
else
    echo -e "\n${YELLOW}No images were uploaded. Check that local-images/ contains subdirectories with images.${NC}"
fi