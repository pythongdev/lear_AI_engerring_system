// Hàm tự chứa để cùng một luật chạy được cả trong head và phía client.
export function khoiTaoGiaoDien() {
  let daLuu: string | null = null;
  try {
    daLuu = window.localStorage.getItem("giao-dien");
  } catch {
    // Bộ nhớ bị chặn: dùng lựa chọn của hệ thống.
  }
  const toi = daLuu === "toi" || (daLuu !== "sang" && window.matchMedia("(prefers-color-scheme: dark)").matches);
  document.documentElement.classList.toggle("dark", toi);
  document.documentElement.style.colorScheme = toi ? "dark" : "light";
}

export const scriptGiaoDien = `(${khoiTaoGiaoDien.toString()})();`;

export function doiGiaoDien() {
  const toi = !document.documentElement.classList.contains("dark");
  document.documentElement.classList.toggle("dark", toi);
  document.documentElement.style.colorScheme = toi ? "dark" : "light";
  try {
    window.localStorage.setItem("giao-dien", toi ? "toi" : "sang");
  } catch {
    // Vẫn giữ giao diện vừa chọn trong phiên khi không ghi được bộ nhớ.
  }
  window.dispatchEvent(new Event("giao-dien"));
}
