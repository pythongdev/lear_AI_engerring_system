import type { Metadata } from "next";
import { redirect } from "next/navigation";

export const metadata: Metadata = { title: "Nguyên liệu" };
export default async function Page({ searchParams }: { searchParams: Promise<{ thu?: string | string[] }> }) {
  const { thu } = await searchParams;
  const valid = typeof thu === "string" && /^[1-9][0-9]*$/.test(thu) && (thu.length < 16 || (thu.length === 16 && thu <= "9007199254740991"));
  redirect(`/chu-quan/khoan-chi${valid ? `?thu=${thu}` : ""}`);
}
