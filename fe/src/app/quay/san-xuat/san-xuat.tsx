"use client";
import { useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { BangSanXuat } from "@/components/shared/bang-san-xuat";
import { khoaHang, khoaPhan, khoaSanXuat, useSanXuat, type PhanSanXuat } from "@/components/shared/du-lieu-san-xuat";
import { Button } from "@/components/ui/button";
import { HopThoaiRaBan } from "./hop-thoai-ra-ban";

import { khoaViecTram, loiMe, useViecTram, type ViecTram } from "./du-lieu-me";
import { HopThoaiMe } from "./hop-thoai-me";
import type { ApiFailure } from "@/lib/api/client";

export function ManSanXuat() {
  const duLieu = useSanXuat();
  const qc = useQueryClient();
  const viec = useViecTram();
  const hangCho = new Map<string, ViecTram[]>();
  viec.data?.jobs.filter((v) => v.status === "pending").forEach((v) => {
    const key = khoaHang(v);
    hangCho.set(key, [...(hangCho.get(key) ?? []), v]);
  });
  const [thongBao, bao] = useState<string | null>(null);
  const rows = duLieu.bang.data?.rows ?? [];
  const phan = new Map<string, PhanSanXuat>();
  rows.forEach((h) => h.parts.forEach((p) => phan.set(khoaPhan(p), p)));
  async function docLaiBang() {
    const r = await Promise.allSettled(khoaSanXuat.map((queryKey) => qc.invalidateQueries({ queryKey }, { throwOnError: true })));
    return r.every((x) => x.status === "fulfilled");
  }
  async function docLai() {
    const r = await Promise.allSettled([docLaiBang(), qc.invalidateQueries({ queryKey: khoaViecTram }, { throwOnError: true })]);
    return r.every((x) => x.status === "fulfilled" && x.value !== false);
  }
  const chung = { bao, docLai, nhan: (v: Pick<ViecTram, "dining_table_id" | "sales_order_id" | "station_job_id">) => `${duLieu.tenPhan(v)} · việc ${v.station_job_id}` };
  return <div className="mx-auto w-full max-w-4xl space-y-6 p-4 sm:p-6">
    <h1 className="text-2xl font-semibold">Sản xuất</h1>
    <BangSanXuat duLieu={duLieu} />
    <Button variant="outline" className="min-h-11" disabled={duLieu.bang.isFetching} onClick={() => void docLai()}>Đọc lại bảng</Button>
    {thongBao && <p role="status">{thongBao}</p>}
    {viec.isPending && <p role="status">Đang tải việc trạm…</p>}
    {viec.isError && <p role="alert">{loiMe(viec.error as unknown as ApiFailure)}</p>}
    {viec.isFetching && viec.data && <p role="status">Đang cập nhật việc trạm…</p>}
    {!viec.isError && viec.data && <div className="flex flex-wrap gap-2">
      {/* Cùng một thứ có thể chờ ở hai trạm (gấp · tráng): nút bấm mẻ xếp theo trạm để không hai nút trùng tên đứng cạnh nhau. */}
      {[...new Set([...hangCho.values()].map((jobs) => jobs[0].station_code))].map((tram) =>
        <div key={`tram-${tram}`} role="group" aria-label={`Trạm ${tram}`} className="flex w-full flex-wrap items-center gap-2">
          <span className="text-sm font-medium">Trạm {tram}</span>
          {[...hangCho].filter(([, jobs]) => jobs[0].station_code === tram).map(([key, jobs]) =>
            <HopThoaiMe key={key} {...chung} ten={`Bấm mẻ ${duLieu.tenHang(jobs[0])}`} thaoTac={{ loai: "bam", viec: jobs }} />)}
        </div>)}
      {viec.data.batches.map((b) => <HopThoaiMe key={`me-${b.production_batch_id}`} {...chung} ten={`Lùi mẻ ${b.production_batch_id}`} disabled={b.has_served_units} thaoTac={{ loai: "lui", id: b.production_batch_id }} />)}
      {viec.data.jobs.filter((v) => v.transferable).map((v) => <HopThoaiMe key={`chuyen-${v.station_job_id}`} {...chung} ten={`Chuyển việc ${v.station_job_id}`} thaoTac={{ loai: "chuyen", id: v.station_job_id }} />)}
      {viec.data.jobs.filter((v) => v.order_status === "cancelled" && ["made", "served"].includes(v.status) && v.wrong_make_note_id === null).map((v) => <HopThoaiMe key={`sai-${v.station_job_id}`} {...chung} ten={`Ghi làm sai việc ${v.station_job_id}`} thaoTac={{ loai: "sai", id: v.station_job_id }} />)}
    </div>}
    <div className="flex flex-wrap gap-2">{[...phan].map(([key, p]) => <HopThoaiRaBan key={key} phan={p} ten={duLieu.tenPhan(p)}
      hang={rows.filter((h) => h.parts.some((part) => khoaPhan(part) === key))} tenHang={duLieu.tenHang} bao={bao} docLai={docLaiBang} />)}</div>
  </div>;
}
