import { createElement } from "react";
import { renderToStaticMarkup } from "react-dom/server";
import { afterEach, describe, expect, it, vi } from "vitest";
import { PUBLIC_ROUTES, publicPageMetadata, restaurantJsonLd, siteUrl } from "./seo";
import robots from "@/app/robots";
import sitemap from "@/app/sitemap";

const description = "Bánh cuốn Bà Thanh — đặt món giao tận nơi miễn phí ship hoặc mang đi. Bán 6h–11h sáng. Hotline 0382688666.";

afterEach(() => {
  vi.unstubAllEnvs();
  vi.resetModules();
});

for (const base of [undefined, "https://example.com///"]) {
  describe(`SEO với BANHCUON_SITE_URL=${base}`, () => {
    it("A1: layout mặc định noindex, metadata và lang đúng", async () => {
      vi.stubEnv("BANHCUON_SITE_URL", base);
      vi.resetModules();
      const { metadata, default: Layout } = await import("@/app/layout");
      expect(metadata).toEqual({
        title: { default: "Bánh cuốn Bà Thanh", template: "%s · Bánh cuốn Bà Thanh" },
        description,
        openGraph: { locale: "vi_VN", siteName: "Bánh cuốn Bà Thanh", type: "website", title: "Bánh cuốn Bà Thanh", description },
        robots: { index: false, follow: false },
        ...(base ? { metadataBase: new URL("https://example.com") } : {}),
      });
      expect(renderToStaticMarkup(Layout({ children: "" } as Parameters<typeof Layout>[0]))).toContain('lang="vi"');
    });

    it("A2: trang chủ bật index và chỉ có canonical khi có địa chỉ gốc", async () => {
      vi.stubEnv("BANHCUON_SITE_URL", base);
      vi.resetModules();
      expect(siteUrl()).toBe(base ? "https://example.com" : undefined);
      const { metadata } = await import("@/app/page");
      expect(metadata).toEqual({ robots: { index: true, follow: true }, ...(base ? { alternates: { canonical: "/" } } : {}) });
      expect(publicPageMetadata("/")).toEqual(metadata);
      expect(() => publicPageMetadata("/private")).toThrow("Route chưa được công khai");
    });

    it("A3: robots chặn /api/ và sitemap chỉ khi có địa chỉ gốc", () => {
      vi.stubEnv("BANHCUON_SITE_URL", base);
      expect(robots()).toEqual({ rules: { userAgent: "*", allow: "/", disallow: "/api/" }, ...(base ? { sitemap: "https://example.com/sitemap.xml" } : {}) });
    });

    it("A4: sitemap khớp PUBLIC_ROUTES, không có lastModified giả", () => {
      vi.stubEnv("BANHCUON_SITE_URL", base);
      expect(PUBLIC_ROUTES).toEqual(["/"]);
      expect(sitemap()).toEqual(base ? PUBLIC_ROUTES.map((path) => ({ url: `https://example.com${path}` })) : []);
    });

    it("A5: server render JSON-LD có địa chỉ và giờ mở của shop-facts §1 (T-205)", async () => {
      vi.stubEnv("BANHCUON_SITE_URL", base);
      const { default: Home } = await import("@/app/page");
      const html = renderToStaticMarkup(createElement(Home));
      const json = html.match(/<script type="application\/ld\+json">(.*?)<\/script>/)?.[1];
      expect(json).toBe(restaurantJsonLd(siteUrl()));
      expect(JSON.parse(json!)).toEqual({
        "@context": "https://schema.org", "@type": "Restaurant", name: "Bánh cuốn Bà Thanh", telephone: "+84382688666",
        address: { "@type": "PostalAddress", streetAddress: "Số 14B6, ngõ 332 Hoàng Công Chất", addressLocality: "Phú Diễn, Bắc Từ Liêm", addressRegion: "Hà Nội", addressCountry: "VN" },
        openingHoursSpecification: [{ "@type": "OpeningHoursSpecification", dayOfWeek: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"], opens: "06:00", closes: "11:00" }],
        ...(base ? { url: "https://example.com" } : {}),
      });
    });
  });
}

it("A5: mã hoá dấu < để không đóng thẻ script trong JSON-LD", () => {
  const url = "https://example.com/</script><script>";
  const json = restaurantJsonLd(url);
  expect(json).not.toContain("<");
  expect(json).toContain("\\u003c/script>");
  expect(JSON.parse(json).url).toBe(url);
});

it("A2: biến rỗng được coi như chưa có địa chỉ gốc", () => {
  vi.stubEnv("BANHCUON_SITE_URL", "");
  expect(siteUrl()).toBeUndefined();
  expect(publicPageMetadata("/")).not.toHaveProperty("alternates");
});
