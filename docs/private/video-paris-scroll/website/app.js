(() => {
  'use strict';

  const hero = document.querySelector('.journey');
  const canvas = document.querySelector('.journey-canvas');
  const status = document.querySelector('.loading-status');
  const copy = document.querySelector('.hero-copy');
  const asides = [...document.querySelectorAll('.hero-aside')];
  const progressBar = document.querySelector('.journey-progress span');
  const counter = document.querySelector('.journey-counter');
  const scrollLabel = document.querySelector('.scroll-label');
  const motion = matchMedia('(prefers-reduced-motion: reduce)');
  const context = canvas.getContext('2d', { alpha: false });
  const CACHE_LIMIT = 10;
  const MAX_IN_FLIGHT = 3;
  const RADIUS = 4;
  const cache = new Map();
  const inFlight = new Map();
  const failed = new Set();
  let frames = [];
  let target = 0;
  let lastPainted = -1;
  let lastImage = null;
  let raf = 0;
  let running = false;
  let generation = 0;
  let manifestController = null;
  let viewportWidth = 0;
  let viewportHeight = 0;
  let paintedProgress = -1;

  // All imagery is local. A failed poster gets a readable dark backdrop.
  for (const img of document.images) {
    const onError = () => {
      img.classList.add('image-unavailable');
      if (img.classList.contains('journey-poster')) {
        status.textContent = 'Ảnh thay thế chưa tải được. Bạn vẫn có thể đọc nội dung bên dưới.';
      }
    };
    img.addEventListener('error', onError);
    if (img.complete && !img.naturalWidth) onError();
  }

  function setStatus(message) {
    if (status.textContent !== message) status.textContent = message;
  }

  function staticMode(message) {
    running = false;
    generation++;
    manifestController?.abort();
    hero.classList.remove('is-animated', 'has-frame');
    hero.classList.add('is-static');
    copy.style.opacity = '';
    asides.forEach(el => { el.style.opacity = ''; });
    copy.inert = false;
    scrollLabel.textContent = 'Khám phá câu chuyện Paris';
    counter.textContent = 'PARIS';
    cache.clear();
    failed.clear();
    // Pending requests are detached; stale completions cannot restart the player.
    for (const img of inFlight.values()) {
      img.onload = null;
      img.onerror = null;
      img.src = '';
    }
    inFlight.clear();
    lastImage = null;
    lastPainted = -1;
    canvas.width = 1;
    canvas.height = 1;
    setStatus(message);
  }

  function resizeCanvas() {
    const rect = canvas.getBoundingClientRect();
    viewportWidth = rect.width;
    viewportHeight = rect.height;
    // DPR is capped to keep a large desktop/mobile canvas within a fixed budget.
    const dpr = Math.min(devicePixelRatio || 1, 2);
    const scale = Math.min(dpr, 2560 / Math.max(rect.width, rect.height, 1));
    const width = Math.max(1, Math.round(rect.width * scale));
    const height = Math.max(1, Math.round(rect.height * scale));
    if (canvas.width !== width || canvas.height !== height) {
      canvas.width = width;
      canvas.height = height;
      lastPainted = -1;
    }
  }

  function paint(img, index) {
    if (!context || !img.naturalWidth || !viewportWidth || !viewportHeight) return;
    const scale = Math.max(canvas.width / img.naturalWidth, canvas.height / img.naturalHeight);
    const width = img.naturalWidth * scale;
    const height = img.naturalHeight * scale;
    context.drawImage(img, (canvas.width - width) / 2, (canvas.height - height) / 2, width, height);
    lastPainted = index;
    lastImage = img;
    canvas.dataset.frame = String(index);
    hero.classList.add('has-frame');
  }

  function evict() {
    while (cache.size > CACHE_LIMIT) {
      const farthest = [...cache.keys()].sort((a, b) => Math.abs(b - target) - Math.abs(a - target))[0];
      cache.delete(farthest);
    }
    canvas.dataset.cached = String(cache.size);
    canvas.dataset.pending = String(inFlight.size);
  }

  function loadFrame(index) {
    if (cache.has(index) || inFlight.has(index) || failed.has(index)) return;
    const token = generation;
    const img = new Image();
    img.decoding = 'async';
    inFlight.set(index, img);
    const finish = (success) => {
      if (token !== generation) return;
      inFlight.delete(index);
      img.onload = null;
      img.onerror = null;
      if (success) {
        cache.set(index, img);
        // Frame zero has priority: paint it as soon as its request completes.
        if (!lastImage && index === 0) paint(img, index);
      } else {
        failed.add(index);
      }
      evict();
      schedule();
    };
    img.onload = () => finish(true);
    img.onerror = () => finish(false);
    img.src = frames[index];
    evict();
  }

  function preload() {
    const wanted = [target];
    for (let offset = 1; offset <= RADIUS; offset++) wanted.push(target + offset, target - offset);
    // The queue is rebuilt around the latest target, so fast scrolling never
    // queues the entire sequence. There are at most three network loads.
    for (const index of wanted) {
      if (inFlight.size >= MAX_IN_FLIGHT) break;
      if (index >= 0 && index < frames.length) loadFrame(index);
    }
  }

  function render() {
    raf = 0;
    if (!running || document.hidden) return;
    resizeCanvas();
    const rect = hero.getBoundingClientRect();
    const travel = hero.offsetHeight - canvas.getBoundingClientRect().height;
    const progress = Math.max(0, Math.min(1, -rect.top / Math.max(1, travel)));
    target = Math.round(progress * (frames.length - 1));
    if (progress !== paintedProgress) {
      paintedProgress = progress;
      const opacity = Math.max(0, 1 - progress / .32);
      copy.style.opacity = String(opacity);
      asides.forEach(el => { el.style.opacity = String(opacity); });
      // Do not leave an invisible call-to-action in the keyboard tab order.
      // Preserve a visible control if the visitor is currently using it.
      if (opacity < .08 && !copy.contains(document.activeElement)) copy.inert = true;
      if (opacity >= .08 || copy.contains(document.activeElement)) {
        copy.inert = false;
        if (copy.contains(document.activeElement)) copy.style.opacity = '1';
      }
      progressBar.style.transform = `scaleX(${progress})`;
      const chapter = Math.min(3, Math.floor(progress * 3) + 1);
      counter.innerHTML = `0${chapter} <span>/</span> 03`;
    }
    const nearest = [...cache.keys()].sort((a, b) => Math.abs(a - target) - Math.abs(b - target))[0];
    if (nearest !== undefined && nearest !== lastPainted) paint(cache.get(nearest), nearest);
    else if (lastPainted === -1 && lastImage) paint(lastImage, Number(canvas.dataset.frame));

    if (failed.has(target)) {
      setStatus(lastImage ? 'Một khung hình bị lỗi; đang giữ cảnh gần nhất.' : 'Chuyển động chưa tải được; đang hiển thị ảnh thay thế.');
    } else if (cache.has(target)) {
      setStatus('');
    } else {
      setStatus(lastImage ? 'Đang tải cảnh tiếp theo…' : 'Đang tải cảnh mở đầu…');
    }
    preload();
    evict();
    if (!lastImage && !inFlight.size && failed.has(target)) {
      staticMode('Chuyển động chưa tải được; đang hiển thị ảnh thay thế.');
    }
  }

  function schedule() {
    if (!raf && running) raf = requestAnimationFrame(render);
  }

  async function start() {
    if (motion.matches || !context) {
      staticMode(motion.matches ? 'Đang hiển thị ảnh tĩnh theo cài đặt giảm chuyển động.' : 'Đang hiển thị ảnh tĩnh vì trình duyệt không hỗ trợ canvas.');
      return;
    }
    generation++;
    const token = generation;
    manifestController = new AbortController();
    setStatus('Đang chuẩn bị hình ảnh…');
    try {
      const response = await fetch('frames.json', { signal: manifestController.signal });
      if (!response.ok) throw new Error(`Manifest HTTP ${response.status}`);
      const manifest = await response.json();
      if (!Array.isArray(manifest.frames) || manifest.frames.length < 2 ||
          !manifest.frames.every(path => /^assets\/frames\/[\w-]+\.jpg$/.test(path))) {
        throw new Error('Invalid local frame manifest');
      }
      if (token !== generation || motion.matches) return;
      frames = manifest.frames;
      hero.classList.remove('is-static');
      hero.classList.add('is-animated');
      scrollLabel.textContent = 'Cuộn để đi qua những tầng mây';
      running = true;
      paintedProgress = -1;
      resizeCanvas();
      loadFrame(0);
      schedule();
    } catch (error) {
      if (token !== generation || error.name === 'AbortError') return;
      staticMode('Chuyển động chưa tải được; đang hiển thị ảnh thay thế.');
    }
  }

  window.addEventListener('scroll', schedule, { passive: true });
  window.addEventListener('resize', schedule, { passive: true });
  window.visualViewport?.addEventListener('resize', schedule, { passive: true });
  document.addEventListener('visibilitychange', schedule);
  copy.addEventListener('focusin', () => { copy.style.opacity = '1'; });
  copy.addEventListener('focusout', () => { paintedProgress = -1; schedule(); });
  motion.addEventListener('change', () => {
    staticMode('Đang hiển thị ảnh tĩnh theo cài đặt giảm chuyển động.');
    if (!motion.matches) start();
  });
  start();
})();
