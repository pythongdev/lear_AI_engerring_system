"use client";

import Image from "next/image";
import { useEffect, useRef, useState, type FormEvent } from "react";
import { Button } from "@/components/ui/button";
import { loiMenu, useCapNhatAnhCombo, type KieuMenu } from "./du-lieu-danh-muc-combo";

export function FormAnhCombo({ c, bao, dong }: {
  c: KieuMenu["MenuCombo"]; bao: (message: string) => void; dong: () => void;
}) {
  const luu = useCapNhatAnhCombo(c.menu_combo_id);
  const [anh, setAnh] = useState<{ file: File; preview: string } | null>(null);
  const [reason, setReason] = useState("");
  const [loi, setLoi] = useState<string | null>(null);
  const dangGui = useRef(false);
  useEffect(() => () => { if (anh) URL.revokeObjectURL(anh.preview); }, [anh]);
  async function gui(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    if (dangGui.current) return;
    if (!anh) { setLoi("Hãy chọn ảnh JPEG, PNG hoặc WebP."); return; }
    if (!reason.trim()) { setLoi("Hãy nhập lý do cập nhật ảnh."); return; }
    dangGui.current = true;
    setLoi(null);
    try {
      const result = await luu.mutateAsync({ file: anh.file, reason: reason.trim() });
      if (!result.ok) { setLoi(loiMenu(result.failure)); return; }
      bao(`Đã cập nhật ảnh ${c.name}.`);
      dong();
    } finally { dangGui.current = false; }
  }
  return <form aria-label={`Cập nhật ảnh ${c.name}`} onSubmit={(e) => { void gui(e); }} className="space-y-3">
    <label className="block">Ảnh mới (JPEG, PNG, WebP; tối đa 5 MiB)
      <input type="file" accept="image/jpeg,image/png,image/webp" disabled={luu.isPending} onChange={(e) => {
        const file = e.target.files?.[0];
        setLoi(null);
        if (!file) { setAnh(null); return; }
        if (file.size > 5 * 1024 * 1024 || !["image/jpeg", "image/png", "image/webp"].includes(file.type)) {
          setAnh(null); setLoi("Chọn ảnh JPEG, PNG hoặc WebP không quá 5 MiB."); return;
        }
        setAnh({ file, preview: URL.createObjectURL(file) });
      }} />
    </label>
    {anh && <Image src={anh.preview} alt={`Xem trước ảnh ${c.name}`} width={400} height={300} unoptimized className="cb-preview" />}
    <label className="block">Lý do cập nhật ảnh
      <input value={reason} onChange={(e) => setReason(e.target.value)} disabled={luu.isPending} />
    </label>
    {loi && <p role="alert">{loi}</p>}
    <Button type="submit" disabled={luu.isPending}>{luu.isPending ? "Đang lưu ảnh…" : "Lưu ảnh"}</Button>
  </form>;
}
