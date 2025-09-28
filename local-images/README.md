# Local Images Directory

This directory is for storing images locally before uploading to Cloudflare Images.
**This folder is git-ignored and won't be committed to the repository.**

## Directory Structure

```
local-images/
├── 2024-maine-summer/          # Maine trip photos
├── 2025-elopement-photos/      # Elopement ceremony photos
├── 2025-british-columbia-honeymoon/  # BC honeymoon photos
└── newsletters/                 # Newsletter and card images
```

## How to Use

### 1. Add Your Images

Place your images in the appropriate folders:
- Name files descriptively (e.g., `sunset-at-portland-head-light.jpg`)
- Supported formats: JPG, JPEG, PNG, GIF, WebP

### 2. Upload to Cloudflare

```bash
# Option 1: Source from .env file (recommended)
cp .env.example .env
# Edit .env with your values, then:
source .env

# Option 2: Export directly
export CLOUDFLARE_ACCOUNT_ID="your-account-id"
export CLOUDFLARE_API_TOKEN="your-api-token"

# Then run the upload script
./scripts/upload-to-cloudflare.sh
```

### 3. Image IDs

The script will generate image IDs based on:
- Album prefix + filename
- Example: `maine-sunset-at-portland-head-light`

### 4. Update Your Content

After uploading, update your album markdown files with the image IDs:

```yaml
photos:
  - src: "maine-sunset-at-portland-head-light"
    alt: "Sunset at Portland Head Light"
```

## Getting Your Cloudflare API Token

1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com/profile/api-tokens)
2. Create Token → Custom Token
3. Permissions needed:
   - Account → Cloudflare Images → Edit

## Image Naming Best Practices

- Use lowercase letters
- Replace spaces with hyphens
- Be descriptive but concise
- Avoid special characters

## Example Workflow

1. Copy photos to `local-images/2024-maine-summer/`
2. Run upload script
3. Check `uploaded-images.log` for successful uploads
4. Update `_albums/2024-maine-summer.md` with image IDs
5. Preview site to verify images display correctly

## Cloudflare Image Variants

Images are automatically served in these sizes:
- `small` - Mobile (480px width)
- `medium` - Tablet (768px width)
- `large` - Desktop (1200px width)
- `public` - Original/full size

The site automatically selects the appropriate variant based on screen size.