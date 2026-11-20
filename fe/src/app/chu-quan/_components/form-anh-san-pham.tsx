"use client";

import { useEffect, useState, type FormEvent } from "react";
import Image from "next/image";
import { Button } from "@/components/ui/button";
import { useCapNhatAnhMon, loiSanPham } from "./du-lieu-san-pham";

export function FormAnhSanPham({ monId, ten, daLuu }: { monId: number; ten: string; daLuu: () => void }) {
  const luu = useCapNhatAnhMon(monId);
  const [file, setFile] = useState<File | null>(null);
  const [xemTruoc, setXemTruoc] = useState<string | null>(null);
  const [reason, setReason] = useState("");
  const [loi, setLoi] = useState("");
  useEffect(() => () => {
    if (xemTruoc) URL.revokeObjectURL(xemTruoc);
  }, [xemTruoc]);
  async function gui(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const form = e.currentTarget;
    setLoi("");
    if (!file) { setLoi("Hãy chọn ảnh."); return; }
    if (!["image/jpeg", "image/png", "image/webp"].includes(file.type)) { setLoi("Chỉ nhận ảnh JPEG, PNG hoặc WebP."); return; }
    if (file.size > 5 * 1024 * 1024) { setLoi("Ảnh tối đa 5 MiB."); return; }
    if (!reason.trim()) { setLoi("Hãy nhập lý do cập nhật."); return; }
    const result = await luu.mutateAsync({ file, reason: reason.trim() });
    if (!result.ok) {
      setLoi(result.failure.kind === "rejected" && result.failure.code === "invalid_request" && result.failure.field === "file"
        ? "Tệp không phải ảnh JPEG, PNG hoặc WebP hợp lệ." : loiSanPham(result.failure));
      return;
    }
    form.reset();
    setFile(null);
    setXemTruoc(null);
    setReason("");
    daLuu();
  }
  return <form aria-label={`Cập nhật ảnh ${ten}`} onSubmit={(e) => { void gui(e); }} className="space-y-2">
    <label className="block">Ảnh mới (JPEG, PNG, WebP; tối đa 5 MiB)
      <input type="file" accept="image/jpeg,image/png,image/webp" onChange={(e) => {
        const selected = e.target.files?.[0] ?? null;
        setFile(selected);
        setXemTruoc(selected && typeof URL.createObjectURL === "function" ? URL.createObjectURL(selected) : null);
      }} />
    </label>
    {xemTruoc && <Image src={xemTruoc} alt={`Xem trước ảnh ${ten}`} width={320} height={200} unoptimized className="max-h-48 w-full rounded-lg object-contain" />}
    <label className="block">Lý do cập nhật
      <input value={reason} onChange={(e) => setReason(e.target.value)} />
    </label>
    {loi && <p role="alert">{loi}</p>}
    <Button type="submit" disabled={luu.isPending}>{luu.isPending ? "Đang lưu ảnh…" : "Lưu ảnh"}</Button>
  </form>;
}
