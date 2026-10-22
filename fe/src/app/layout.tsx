import type { Metadata } from "next";
import { ApiProvider } from "@/lib/api/provider";
import { SITE_DESCRIPTION, SITE_NAME, siteUrl } from "@/lib/seo";
import { ChuyenGiaoDien } from "@/components/shared/chuyen-giao-dien";
import { scriptGiaoDien } from "@/lib/giao-dien";
import "./globals.css";

const baseUrl = siteUrl();

export const metadata: Metadata = {
  title: { default: SITE_NAME, template: `%s · ${SITE_NAME}` },
  description: SITE_DESCRIPTION,
  openGraph: {
    locale: "vi_VN",
    siteName: SITE_NAME,
    type: "website",
    title: SITE_NAME,
    description: SITE_DESCRIPTION,
  },
  robots: { index: false, follow: false },
  ...(baseUrl ? { metadataBase: new URL(baseUrl) } : {}),
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html lang="vi" className="font-sans" suppressHydrationWarning>
      <head>
        <script dangerouslySetInnerHTML={{ __html: scriptGiaoDien }} />
      </head>
      <body>
        <ApiProvider>{children}</ApiProvider>
        <ChuyenGiaoDien />
      </body>
    </html>
  );
}
