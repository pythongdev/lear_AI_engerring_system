import type { Metadata } from "next";
import { TrangCombo } from "../_components/combo";

export const metadata: Metadata = { title: "Combo" };

export default function Page() {
  return <TrangCombo />;
}
