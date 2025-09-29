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
      const imageSrc = this.getAttribute('data-src');
      const alt = this.getAttribute('data-alt');
      const originalUrl = this.getAttribute('data-original');

      if (lightbox && lightboxImage) {
        // Use the original R2 URL for full size image
        const fullImageUrl = originalUrl || imageSrc;

        lightboxImage.src = fullImageUrl;
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