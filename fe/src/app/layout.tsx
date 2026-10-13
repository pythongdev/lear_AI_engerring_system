import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Bánh cuốn Bà Thanh",
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html lang="vi" className="font-sans">
      <body>{children}</body>
    </html>
  );
}
