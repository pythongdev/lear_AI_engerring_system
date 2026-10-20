import type { Metadata } from "next";
import { ManTram } from "@/components/shared/man-tram";

export const metadata: Metadata = { title: "Trạm" };

export default function Page() {
  return <ManTram />;
}
