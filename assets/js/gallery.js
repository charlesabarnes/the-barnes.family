// Gallery JavaScript for photo albums
(function() {
  'use strict';

  // Lightbox functionality
  const lightbox = document.getElementById('lightbox');
  const lightboxImage = lightbox?.querySelector('.lightbox-image');
  const lightboxCaption = lightbox?.querySelector('.lightbox-caption');
  const lightboxClose = lightbox?.querySelector('.lightbox-close');

  // Open lightbox
  document.querySelectorAll('.btn-fullscreen').forEach(button => {
    button.addEventListener('click', function() {
      const src = this.getAttribute('data-src');
      const alt = this.getAttribute('data-alt');

      if (lightbox && lightboxImage) {
        lightboxImage.src = src;
        lightboxImage.alt = alt;
        if (lightboxCaption) {
          lightboxCaption.textContent = alt;
        }
        lightbox.classList.add('active');
        document.body.style.overflow = 'hidden';
      }
    });
  });

  // Close lightbox
  if (lightboxClose) {
    lightboxClose.addEventListener('click', closeLightbox);
  }

  if (lightbox) {
    lightbox.addEventListener('click', function(e) {
      if (e.target === lightbox) {
        closeLightbox();
      }
    });
  }

  // ESC key to close
  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape' && lightbox?.classList.contains('active')) {
      closeLightbox();
    }
  });

  function closeLightbox() {
    if (lightbox) {
      lightbox.classList.remove('active');
      document.body.style.overflow = '';
      if (lightboxImage) {
        lightboxImage.src = '';
      }
    }
  }

  // Download all photos functionality
  document.querySelectorAll('.btn-download-all').forEach(button => {
    button.addEventListener('click', async function() {
      const albumSlug = this.getAttribute('data-album');
      const gallery = document.getElementById(`gallery-${albumSlug}`);

      if (!gallery) return;

      const images = gallery.querySelectorAll('.gallery-image');
      const originalText = this.textContent;

      this.textContent = 'Preparing download...';
      this.disabled = true;

      // Create a delay to avoid overwhelming the browser
      const downloadImage = (url, index) => {
        return new Promise((resolve) => {
          setTimeout(() => {
            const link = document.createElement('a');
            link.href = url;
            link.download = `${albumSlug}-photo-${index + 1}`;
            link.style.display = 'none';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            resolve();
          }, index * 200); // 200ms delay between downloads
        });
      };

      const downloadPromises = [];
      images.forEach((img, index) => {
        const fullUrl = img.getAttribute('data-full') || img.src;
        downloadPromises.push(downloadImage(fullUrl, index));
      });

      await Promise.all(downloadPromises);

      this.textContent = originalText;
      this.disabled = false;
    });
  });

  // Lazy loading for images (fallback if native loading="lazy" not supported)
  if ('IntersectionObserver' in window) {
    const imageObserver = new IntersectionObserver((entries, observer) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const img = entry.target;
          const src = img.getAttribute('data-src');
          if (src && !img.src) {
            img.src = src;
            img.removeAttribute('data-src');
          }
          observer.unobserve(img);
        }
      });
    }, {
      rootMargin: '50px'
    });

    document.querySelectorAll('img[data-src]').forEach(img => {
      imageObserver.observe(img);
    });
  }
})();