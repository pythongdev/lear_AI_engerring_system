import type { Metadata } from "next";
import { TrangMenuGia as TrangMenu } from "../_components/menu-gia";

export const metadata: Metadata = { title: "Menu & giá" };

export default function Page() {
  return <TrangMenu />;
}
