// jsdom thiếu ResizeObserver mà primitive Radix của shadcn (Checkbox…) gọi khi gắn vào DOM (ADR-100).
globalThis.ResizeObserver ??= class {
  observe() {}
  unobserve() {}
  disconnect() {}
};
