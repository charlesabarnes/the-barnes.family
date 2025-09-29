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

##### For Basic Cloudflare Setup:
1. **CLOUDFLARE_ACCOUNT_ID**
   - Go to [Cloudflare Dashboard](https://dash.cloudflare.com)
   - Navigate to any Cloudflare service page
   - Copy your Account ID (shown in the right sidebar)

2. **CLOUDFLARE_API_TOKEN**
   - Go to [API Tokens](https://dash.cloudflare.com/profile/api-tokens)
   - Create Token → Custom Token
   - Set permissions based on what you're using (see below)
   - Copy the generated token

##### For R2 Storage (Recommended):
3. **R2_ACCESS_KEY_ID** and **R2_SECRET_ACCESS_KEY**
   - Go to Cloudflare Dashboard → R2
   - Click "Manage R2 API Tokens"
   - Create new API token with Object Read & Write permissions
   - Copy both the Access Key ID and Secret Access Key

4. **R2_BUCKET**
   - Create a bucket in R2 (e.g., `family-images`)
   - Configure public access or custom domain

5. **R2_PUBLIC_URL**
   - Use your custom domain (e.g., `https://images.the-barnes.family`)
   - Or use the R2.dev URL provided by Cloudflare

##### For Cloudflare Images (Legacy):
3. **CLOUDFLARE_IMAGES_HASH**
   - Go to Cloudflare Dashboard → Images
   - Find your delivery URL (format: `https://imagedelivery.net/HASH/...`)
   - Copy just the HASH portion

### 4. Update Jekyll Configuration

Edit `_config.yml` to match your storage choice:

#### For R2 Storage:
```yaml
cloudflare:
  r2_bucket: "family-images"
  r2_public_url: "https://images.the-barnes.family"
```

#### For Cloudflare Images (Legacy):
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

### Upload Images

#### To R2 Storage (Recommended):
```bash
# Install AWS CLI if not already installed
pip install awscli

# Load environment variables
source .env

# Run R2 upload script
./scripts/upload-to-r2.sh
```

#### To Cloudflare Images (Legacy):
```bash
# Load environment variables
source .env

# Run Cloudflare Images upload script
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

#### For R2:
- Verify your R2 bucket name and public URL in `_config.yml`
- Check that images were successfully uploaded (see `uploaded-r2-images.log`)
- Ensure R2 bucket has public access configured or custom domain is set up
- Verify Cloudflare Image Resizing is enabled on your domain

#### For Cloudflare Images:
- Verify your Cloudflare account hash in `_config.yml`
- Check that images were successfully uploaded (see `uploaded-images.log`)
- Ensure image IDs in markdown files match uploaded IDs

### Environment Variables Not Working
- Make sure you've sourced the .env file: `source .env`
- Verify no typos in variable names
- Check that .env file is in the project root

### R2 Upload Script Fails
- Confirm AWS CLI is installed: `pip install awscli`
- Verify R2 API credentials are correct
- Check bucket exists and permissions are set correctly
- Ensure R2_ENDPOINT is using the correct format

### Cloudflare Images Upload Script Fails
- Confirm your API token has the correct permissions
- Check your account ID is correct
- Verify you have an active Cloudflare Images subscription