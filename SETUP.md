# Setup Instructions

## Initial Setup

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/the-barnes.family.git
cd the-barnes.family
```

### 2. Install Jekyll Dependencies
```bash
bundle install
```

### 3. Configure Cloudflare Integration

#### Create Your .env File
```bash
cp .env.example .env
```

#### Edit .env with Your Cloudflare Credentials

You'll need to add these values to your `.env` file:

1. **CLOUDFLARE_ACCOUNT_ID**
   - Go to [Cloudflare Dashboard](https://dash.cloudflare.com)
   - Navigate to Images
   - Copy your Account ID

2. **CLOUDFLARE_API_TOKEN**
   - Go to [API Tokens](https://dash.cloudflare.com/profile/api-tokens)
   - Create Token → Custom Token
   - Set permissions: Account → Cloudflare Images → Edit
   - Copy the generated token

3. **CLOUDFLARE_IMAGES_HASH**
   - Go to Cloudflare Dashboard → Images
   - Find your delivery URL (format: `https://imagedelivery.net/HASH/...`)
   - Copy just the HASH portion

### 4. Update Jekyll Configuration

Edit `_config.yml` to use your Cloudflare delivery hash:

```yaml
cloudflare:
  images_url: "https://imagedelivery.net"
  account_hash: "your-delivery-hash-here"  # Same as CLOUDFLARE_IMAGES_HASH
```

## Working with Images

### Local Image Organization

Place your images in the appropriate folders:
```
local-images/
├── 2024-maine-summer/
├── 2025-elopement-photos/
├── 2025-british-columbia-honeymoon/
└── newsletters/
```

### Upload Images to Cloudflare

```bash
# Load environment variables
source .env

# Run upload script
./scripts/upload-to-cloudflare.sh
```

### Generate Album YAML

After uploading, generate the photo lists for your albums:

```bash
./scripts/generate-album-yaml.sh
```

Then copy the generated YAML to your album markdown files in `_albums/`.

## Local Development

### Start the Jekyll Server
```bash
bundle exec jekyll serve
```

Visit `http://localhost:4000` to preview your site.

### Build for Production
```bash
bundle exec jekyll build
```

## Deployment to GitHub Pages

1. Push your changes to the `main` branch
2. GitHub Actions will automatically build and deploy
3. Your site will be available at `https://the-barnes.family`

## Troubleshooting

### Images Not Displaying
- Verify your Cloudflare account hash in `_config.yml`
- Check that images were successfully uploaded (see `uploaded-images.log`)
- Ensure image IDs in markdown files match uploaded IDs

### Environment Variables Not Working
- Make sure you've sourced the .env file: `source .env`
- Verify no typos in variable names
- Check that .env file is in the project root

### Upload Script Fails
- Confirm your API token has the correct permissions
- Check your account ID is correct
- Verify you have an active Cloudflare Images subscription