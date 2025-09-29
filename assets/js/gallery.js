// Gallery JavaScript for photo albums
(function() {
  'use strict';

  // Wait for DOM to be fully loaded
  function initGallery() {
    // Lightbox functionality
    const lightbox = document.getElementById('lightbox');
    const lightboxImage = lightbox?.querySelector('.lightbox-image');
    const lightboxCaption = lightbox?.querySelector('.lightbox-caption');
    const lightboxClose = lightbox?.querySelector('.lightbox-close');

    // Function to open lightbox
    function openLightbox(imageSrc, alt, originalUrl) {
      if (lightbox && lightboxImage) {
        // Use the original R2 URL for full size image
        const fullImageUrl = originalUrl || imageSrc;

        lightboxImage.src = fullImageUrl;
        lightboxImage.alt = alt || 'Gallery Image';
        if (lightboxCaption) {
          lightboxCaption.textContent = alt || '';
        }
        lightbox.classList.add('active');
        document.body.style.overflow = 'hidden';
      }
    }

    // Click handler for gallery images
    const photoItems = document.querySelectorAll('.photo-item');

    photoItems.forEach((item, index) => {
      // Find the image and fullscreen button within this photo item
      const img = item.querySelector('.gallery-image, img');
      const fullscreenBtn = item.querySelector('.btn-fullscreen');

      if (img || fullscreenBtn) {
        // Make the entire photo item clickable (except for overlay buttons)
        item.addEventListener('click', function(e) {
          // Don't trigger if clicking on download or fullscreen buttons
          if (e.target.closest('.btn-download') || e.target.closest('.btn-fullscreen')) {
            return;
          }

          // Get data from the fullscreen button if it exists, or from the image itself
          let imageSrc, alt, originalUrl;

          if (fullscreenBtn) {
            imageSrc = fullscreenBtn.getAttribute('data-src');
            alt = fullscreenBtn.getAttribute('data-alt');
            originalUrl = fullscreenBtn.getAttribute('data-original');
          } else if (img) {
            // Fallback: try to get data from the image element
            imageSrc = img.getAttribute('data-full') || img.getAttribute('data-original') || img.src;
            alt = img.alt;
            originalUrl = img.getAttribute('data-original');
          }

          openLightbox(imageSrc, alt, originalUrl);
        });
      }
    });

    // Open lightbox from fullscreen button
    const fullscreenButtons = document.querySelectorAll('.btn-fullscreen');

    fullscreenButtons.forEach((button, index) => {
      button.addEventListener('click', function(e) {
        e.stopPropagation(); // Prevent triggering the parent click

        const imageSrc = this.getAttribute('data-src');
        const alt = this.getAttribute('data-alt');
        const originalUrl = this.getAttribute('data-original');

        openLightbox(imageSrc, alt, originalUrl);
      });
    });

    // Close lightbox function
    function closeLightbox() {
      if (lightbox) {
        lightbox.classList.remove('active');
        document.body.style.overflow = '';
        if (lightboxImage) {
          lightboxImage.src = '';
        }
      }
    }

    // Close lightbox handlers
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

      const lazyImages = document.querySelectorAll('img[data-src]');
      lazyImages.forEach(img => {
        imageObserver.observe(img);
      });
    }
  }

  // Initialize when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initGallery);
  } else {
    // DOM is already ready
    initGallery();
  }
})();