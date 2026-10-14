// Trang giữ chỗ của khung P4-02 — chưa có màn nghiệp vụ nào (docs/product/4-fe/01-khung-fe.md §1).
import { publicPageMetadata, restaurantJsonLd, siteUrl } from "@/lib/seo";

export const metadata = publicPageMetadata("/");

export default function Home() {
  return (
    <main className="p-6">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: restaurantJsonLd(siteUrl()) }}
      />
      <p>Bánh cuốn Bà Thanh</p>
    </main>
  );
}
