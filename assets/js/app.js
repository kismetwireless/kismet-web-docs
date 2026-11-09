/** Custom scripts */

// Screenshots in both UI themes (layouts/shortcodes/screenshot.html): a
// button switches between them, and Zoom shows the one shown at full size, or
// at 90% of the window when that's smaller, never past full size
(() => {
  const siteTheme = () => (document.documentElement.hasAttribute('data-dark-mode') ? 'dark' : 'light');
  const shownTheme = (fig) => fig.dataset.theme || siteTheme();

  function label(fig) {
    const b = fig.querySelector('[data-kshot-theme]');
    const other = shownTheme(fig) === 'dark' ? 'Light' : 'Dark';
    b.textContent = other;
    b.title = `Show the ${other.toLowerCase()} theme`;
  }

  function zoom(fig) {
    const img = fig.querySelector(shownTheme(fig) === 'dark' ? '.kshot-dark' : '.kshot-light');
    const w = img.naturalWidth || Number(img.getAttribute('width'));
    const h = img.naturalHeight || Number(img.getAttribute('height'));
    const scale = Math.min(1, (window.innerWidth * 0.9) / w, (window.innerHeight * 0.9) / h);
    const big = document.createElement('img');
    big.src = img.currentSrc || img.src;
    big.alt = img.alt;
    big.width = Math.round(w * scale);
    big.height = Math.round(h * scale);
    const view = document.createElement('div');
    view.className = 'kshot-zoom';
    view.setAttribute('role', 'dialog');
    view.setAttribute('aria-label', img.alt);
    view.append(big);
    const close = () => {
      view.remove();
      document.removeEventListener('keydown', onKey);
    };
    const onKey = (e) => {
      if (e.key === 'Escape')
        close();
    };
    view.addEventListener('click', close);
    document.addEventListener('keydown', onKey);
    document.body.append(view);
  }

  const figs = [...document.querySelectorAll('.kshot')];
  for (const fig of figs) {
    label(fig);
    fig.querySelector('[data-kshot-theme]').addEventListener('click', () => {
      const next = shownTheme(fig) === 'dark' ? 'light' : 'dark';
      // Back to following the site once it matches the site again
      if (next === siteTheme())
        delete fig.dataset.theme;
      else
        fig.dataset.theme = next;
      label(fig);
    });
    fig.querySelector('[data-kshot-zoom]').addEventListener('click', () => zoom(fig));
    fig.querySelector('.kshot-frame').addEventListener('click', () => zoom(fig));
  }

  if (figs.length)
    new MutationObserver(() => figs.forEach(label))
      .observe(document.documentElement, { attributes: true, attributeFilter: ['data-dark-mode'] });
})();
