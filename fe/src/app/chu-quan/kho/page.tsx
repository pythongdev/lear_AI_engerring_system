import type { Metadata } from "next";
import { redirect } from "next/navigation";

export const metadata: Metadata = { title: "Kho" };
export default function Page() { redirect("/chu-quan/khoan-chi"); }
