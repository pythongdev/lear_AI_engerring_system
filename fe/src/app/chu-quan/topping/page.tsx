import type { Metadata } from "next";
import { TrangTopping } from "../_components/topping";

export const metadata: Metadata = { title: "Topping" };

export default function Page() {
  return <TrangTopping />;
}
