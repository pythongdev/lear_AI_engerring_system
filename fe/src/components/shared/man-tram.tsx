"use client";
import { BangTram } from "./bang-san-xuat";
import { useSanXuat } from "./du-lieu-san-xuat";

export function ManTram() {
  return <BangTram duLieu={useSanXuat()} />;
}
