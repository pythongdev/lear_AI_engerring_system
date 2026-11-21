"use client";

import Link from "next/link";
import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { call, type ApiFailure } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import { hetPhien } from "@/lib/khach/session";
import { KHOA, useGhiYeuThich, type Dong, type DongGui } from "./yeu-thich/du-lieu";

type DongTim = Pick<DongGui, "menu_item_id" | "option_ids" | "menu_combo_id" | "portions">;
const tapChon = (ids: number[] = []) => [...new Set(ids)].sort((a, b) => a - b).join(",");
function gopSuat(portions: DongGui["portions"] = []) {
  const gop = new Map<string, number>();
  for (const p of portions) {
    const key = `${p.menu_item_id}:${tapChon(p.option_ids)}`;
    gop.set(key, (gop.get(key) ?? 0) + p.quantity);
  }
  return gop;
}
function cungDong(daLuu: Dong, dong: DongTim) {
  if (dong.menu_combo_id === undefined) return daLuu.menu_combo_id === null
    && daLuu.menu_item_id === dong.menu_item_id && tapChon(daLuu.option_ids) === tapChon(dong.option_ids);
  if (daLuu.menu_combo_id !== dong.menu_combo_id) return false;
  const cu = gopSuat(daLuu.portions); const moi = gopSuat(dong.portions);
  // Dòng tim có thể chứa nhiều combo; so số suất của từng tổ hợp trong một combo.
  return cu.size === moi.size && [...moi].every(([key, so]) => cu.get(key) === so * daLuu.quantity);
}

export function NutTim({ dong, ten }: { dong: DongTim; ten: string }) {
  const api = useApi();
  const [moiDangNhap, setMoiDangNhap] = useState(false);
  const [baoLoiDoc, setBaoLoiDoc] = useState(false);
  const doc = useQuery({ queryKey: KHOA, retry: false, queryFn: async () => {
    const r = await call(api.GET("/customer-accounts/current/favourites"));
    if (!r.ok) throw r.failure;
    if (!Array.isArray(r.data?.lines)) throw { kind: "unexpected", status: 200 } satisfies ApiFailure;
    return r.data;
  } });
  const ghi = useGhiYeuThich(() => setMoiDangNhap(true));
  const loiDoc = doc.error as ApiFailure | null;
  const canDangNhap = moiDangNhap || hetPhien(loiDoc);
  const daLuu = canDangNhap || loiDoc ? undefined : doc.data?.lines.find((d) => cungDong(d, dong));
  function bam() {
    if (canDangNhap) { setMoiDangNhap(true); return; }
    if (loiDoc) { setBaoLoiDoc(true); void doc.refetch(); return; }
    if (!doc.data) return;
    void ghi.gui(() => daLuu
      ? call(api.POST("/customer-accounts/current/favourites/{favourite_line_id}/removal", { params: { path: { favourite_line_id: daLuu.favourite_line_id } } }))
      : call(api.POST("/customer-accounts/current/favourites", { body: { ...dong, quantity: 1 } })));
  }
  return <div className="space-y-2">
    <button type="button" aria-pressed={!!daLuu} aria-label={daLuu ? `Bỏ ${ten} khỏi yêu thích` : `Thêm ${ten} vào yêu thích`}
      disabled={ghi.busy || doc.isPending} onClick={bam}
      className="inline-flex min-h-11 min-w-11 items-center justify-center rounded-full border border-[var(--border)] bg-[var(--background)] text-2xl text-[var(--foreground)] focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[var(--ring)] disabled:opacity-50">
      {daLuu ? "♥" : "♡"}
    </button>
    {moiDangNhap && <div role="status"><p>Đăng nhập để lưu món yêu thích.</p><Link className="inline-flex min-h-11 items-center underline" href="/khach/dang-nhap">Đăng nhập</Link></div>}
    {baoLoiDoc && !canDangNhap && (loiDoc || doc.isFetching) && <p role="alert">Chưa đọc được danh sách yêu thích. Hãy thử lại.</p>}
    {ghi.loi && <p role="alert">{ghi.loi}</p>}
    {ghi.bao && <p role="status">{ghi.bao}</p>}
  </div>;
}
