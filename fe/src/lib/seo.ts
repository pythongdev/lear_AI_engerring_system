import type { Metadata } from "next";

export const SITE_NAME = "Bánh cuốn Bà Thanh";
// bản nháp chờ chủ quán duyệt — U-094
export const SITE_DESCRIPTION =
  "Bánh cuốn Bà Thanh — đặt món giao tận nơi miễn phí ship hoặc mang đi. Bán 6h–11h sáng. Hotline 0382688666.";

export const PUBLIC_ROUTES: readonly string[] = ["/"];

// Biến phía server, được đọc lúc build; không dùng tiền tố NEXT_PUBLIC_.
export function siteUrl(): string | undefined {
  return process.env.BANHCUON_SITE_URL?.replace(/\/+$/, "") || undefined;
}

export function publicPageMetadata(path: string): Metadata {
  if (!PUBLIC_ROUTES.includes(path)) {
    throw new Error(`Route chưa được công khai: ${path}`);
  }
  return {
    robots: { index: true, follow: true },
    ...(siteUrl() ? { alternates: { canonical: path } } : {}),
  };
}

export function restaurantJsonLd(baseUrl: string | undefined): string {
  return JSON.stringify({
    "@context": "https://schema.org",
    "@type": "Restaurant",
    name: SITE_NAME,
    telephone: "+84382688666",
    ...(baseUrl ? { url: baseUrl } : {}),
  }).replace(/</g, "\\u003c");
}
