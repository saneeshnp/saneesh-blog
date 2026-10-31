(() => {
  const viewer = document.querySelector('.photo-viewer');
  if (!viewer || typeof viewer.showModal !== 'function') return;
  const links = [...document.querySelectorAll('.photo-link')];
  const stage = viewer.querySelector('.photo-stage');
  const status = viewer.querySelector('.photo-status');
  const metadata = viewer.querySelector('.photo-viewer-meta');
  const note = viewer.querySelector('.photo-note');
  let current = 0;
  let opener;
  let activeImage;
  let previousOverflow;

  function releaseImage(image) {
    if (!image) return;
    image.onload = null;
    image.onerror = null;
    image.removeAttribute('src');
  }

  function show(index) {
    current = (index + links.length) % links.length;
    const link = links[current];
    const image = new Image();
    image.className = 'photo-full';
    image.alt = link.querySelector('img').alt;
    image.setAttribute('aria-describedby', 'photo-viewer-meta photo-note');
    image.hidden = true;
    image.decoding = 'async';
    releaseImage(activeImage);
    activeImage = image;
    stage.querySelector('img').replaceWith(image);
    status.textContent = 'Loading photo…';
    status.hidden = false;
    metadata.replaceChildren();
    [link.dataset.year, link.dataset.location].filter(Boolean).forEach(value => {
      const item = document.createElement('span');
      item.textContent = value;
      metadata.append(item);
    });
    note.textContent = link.dataset.note || '';
    note.hidden = !note.textContent;
    viewer.querySelector('.photo-counter').textContent = `${current + 1} / ${links.length}`;
    viewer.querySelector('.photo-open').href = link.href;
    image.onload = () => {
      if (activeImage !== image || !viewer.open) return;
      image.hidden = false;
      status.hidden = true;
    };
    image.onerror = () => {
      if (activeImage !== image || !viewer.open) return;
      status.textContent = 'Could not load this photo. Try the full-size link below.';
    };
    // Full-size files are requested only after opening or navigating the viewer.
    image.src = link.href;
  }

  links.forEach((link, index) => link.addEventListener('click', event => {
    if (event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
    event.preventDefault();
    opener = link;
    previousOverflow = document.documentElement.style.overflow;
    viewer.showModal();
    document.documentElement.style.overflow = 'hidden';
    show(index);
  }));
  viewer.querySelector('.photo-close').addEventListener('click', () => viewer.close());
  viewer.querySelector('.photo-previous').addEventListener('click', () => show(current - 1));
  viewer.querySelector('.photo-next').addEventListener('click', () => show(current + 1));
  viewer.addEventListener('keydown', event => {
    if (event.key === 'ArrowLeft' || event.key === 'ArrowRight') {
      event.preventDefault();
      show(current + (event.key === 'ArrowLeft' ? -1 : 1));
    }
  });
  viewer.addEventListener('click', event => {
    const rect = viewer.getBoundingClientRect();
    if (event.target === viewer && (event.clientX < rect.left || event.clientX > rect.right || event.clientY < rect.top || event.clientY > rect.bottom)) viewer.close();
  });
  viewer.addEventListener('close', () => {
    releaseImage(activeImage);
    activeImage = null;
    document.documentElement.style.overflow = previousOverflow;
    opener?.focus();
  });
})();
