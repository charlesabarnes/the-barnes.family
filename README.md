# The Barnes Family Website

A Jekyll-based family newsletter and photo archive site for the Barnes family.

## Features

- **Newsletter Archive**: Collection of family cards and announcements
- **Photo Galleries**: Vacation and event photo albums with download capabilities
- **Timeline View**: Chronological display of family events
- **Sticker System**: Decorative emoji elements throughout the site
- **Cloudflare Integration**: Ready for R2 storage and Images optimization
- **Natural Theme**: Greens, browns, and tans color palette with serif typography

## Local Development

1. Install dependencies:
```bash
bundle install
```

2. Run the development server:
```bash
bundle exec jekyll serve
```

3. View the site at `http://localhost:4000`

## Cloudflare Configuration

Update the following in `_config.yml`:
```yaml
cloudflare:
  images_url: "https://imagedelivery.net"
  account_hash: "YOUR_ACCOUNT_HASH"
  r2_bucket: "barnes-family-images"
```

## Adding Content

### Newsletters
Add new newsletters to `_newsletters/` with front matter:
```yaml
---
layout: newsletter
title: Your Title
date: YYYY-MM-DD
occasion: Event Name
featured_image: image-id
stickers: ["sticker1", "sticker2"]
---
```

### Photo Albums
Add new albums to `_albums/` with photo lists:
```yaml
---
layout: album
title: Album Title
date: YYYY-MM-DD
location: Location Name
photo_count: 24
photos:
  - src: photo-id
    alt: Description
---
```

## Deployment

The site is configured for GitHub Pages deployment:
1. Push to the `main` branch
2. GitHub Actions will automatically build and deploy
3. Site will be available at `https://the-barnes.family`

## Image Management

Images should be uploaded to Cloudflare R2 and referenced by their ID. The `cloudflare-image.html` include handles responsive image generation and optimization.

## Stickers

Add PNG sticker images to `/assets/stickers/` or use emoji fallbacks defined in `_includes/sticker.html`.