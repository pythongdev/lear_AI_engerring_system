import type { Metadata } from "next";

import { TrangTongQuan } from "./_components/tong-quan";

export const metadata: Metadata = { title: "Chủ quán" };

export default function Page() {
  return <TrangTongQuan />;
}
