import type { Metadata } from "next";

export const SITE_NAME = "Bánh cuốn Bà Thanh";
// bản nháp chờ chủ quán duyệt — U-094
export const SITE_DESCRIPTION =
  "Bánh cuốn Bà Thanh — đặt món giao tận nơi miễn phí ship hoặc mang đi. Bán 6h–11h sáng. Hotline 0382688666.";

export const PUBLIC_ROUTES: readonly string[] = ["/", "/dat-mon"];

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

// Địa chỉ và giờ mở: master_plan/shop-facts.md §1 (2026-10-19, T-205). Ngày nghỉ Tết âm lịch chủ quán báo mỗi năm,
// nên không ghi cứng vào đây.
export const SHOP_ADDRESS = {
  "@type": "PostalAddress",
  streetAddress: "Số 14B6, ngõ 332 Hoàng Công Chất",
  addressLocality: "Phú Diễn, Bắc Từ Liêm",
  addressRegion: "Hà Nội",
  addressCountry: "VN",
} as const;
export const SHOP_OPENING_HOURS = {
  "@type": "OpeningHoursSpecification",
  dayOfWeek: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],
  opens: "06:00",
  closes: "11:00",
} as const;

export function restaurantJsonLd(baseUrl: string | undefined): string {
  return JSON.stringify({
    "@context": "https://schema.org",
    "@type": "Restaurant",
    name: SITE_NAME,
    telephone: "+84382688666",
    address: SHOP_ADDRESS,
    openingHoursSpecification: [SHOP_OPENING_HOURS],
    ...(baseUrl ? { url: baseUrl } : {}),
  }).replace(/</g, "\\u003c");
}
