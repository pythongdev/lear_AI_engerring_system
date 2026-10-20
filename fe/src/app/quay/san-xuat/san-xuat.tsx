"use client";
import { useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { BangSanXuat } from "@/components/shared/bang-san-xuat";
import { khoaPhan, khoaSanXuat, useSanXuat, type PhanSanXuat } from "@/components/shared/du-lieu-san-xuat";
import { Button } from "@/components/ui/button";
import { HopThoaiRaBan } from "./hop-thoai-ra-ban";

export function ManSanXuat() {
  const duLieu = useSanXuat();
  const qc = useQueryClient();
  const [thongBao, bao] = useState<string | null>(null);
  const rows = duLieu.bang.data?.rows ?? [];
  const phan = new Map<string, PhanSanXuat>();
  rows.forEach((h) => h.parts.forEach((p) => phan.set(khoaPhan(p), p)));
  async function docLai() {
    const r = await Promise.allSettled(khoaSanXuat.map((queryKey) => qc.invalidateQueries({ queryKey }, { throwOnError: true })));
    return r.every((x) => x.status === "fulfilled");
  }
  return <div className="mx-auto w-full max-w-4xl space-y-6 p-4 sm:p-6">
    <h1 className="text-2xl font-semibold">Sản xuất</h1>
    <BangSanXuat duLieu={duLieu} />
    <Button variant="outline" className="min-h-11" disabled={duLieu.bang.isFetching} onClick={() => void docLai()}>Đọc lại bảng</Button>
    {thongBao && <p role="status">{thongBao}</p>}
    <div className="flex flex-wrap gap-2">{[...phan].map(([key, p]) => <HopThoaiRaBan key={key} phan={p} ten={duLieu.tenPhan(p)}
      hang={rows.filter((h) => h.parts.some((part) => khoaPhan(part) === key))} tenHang={duLieu.tenHang} bao={bao} docLai={docLai} />)}</div>
  </div>;
}
