import type { Metadata } from "next";
import { TrangDanhMuc } from "../_components/danh-muc";

export const metadata: Metadata = { title: "Danh mục" };

export default function Page() {
  return <TrangDanhMuc />;
}
