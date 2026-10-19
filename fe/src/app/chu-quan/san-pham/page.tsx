import type { Metadata } from "next";
import { TrangSanPham } from "../_components/san-pham";

export const metadata: Metadata = { title: "Sản phẩm" };

export default function Page() {
  return <TrangSanPham />;
}
