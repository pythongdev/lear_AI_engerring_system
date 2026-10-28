"use client";

import Image from "next/image";
import { ImageIcon } from "lucide-react";
import { useState } from "react";

// Tài nguyên trình bày, không sửa dữ liệu món hay hợp đồng API.
const thuMucAnh = "/images/san-pham/";
const anhTheoTen: Record<string, string> = {
  "banh cuon": "banh-cuon.png",
  "gio": "gio.jpeg",
  "gio ban roi": "gio.jpeg",
  "trung": "trung.jpeg",
  "banh trung": "trung.jpeg",
  "canh banh cuon": "banh-cuon-minh-hoa.jpg",
};
const anhCombo: Record<string, string> = {
  "suat gio": "suat-gio.jpeg",
  "suat trung": "suat-trung.jpeg",
  "suat day du": "suat-day-du.jpeg",
  "day du": "suat-day-du.jpeg",
  "day du trung": "suat-day-du.jpeg",
};

export function AnhSanPham({ ten, combo = false, className = "" }: {
  ten: string; combo?: boolean; className?: string;
}) {
  const tenChuan = ten.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "").replace(/đ/g, "d")
    .trim().replace(/\s+/g, " ").replace(/\s*\(ban roi\)$/, "").replace(/\s+(chin|tai|vang)$/, "");
  const tep = combo ? anhCombo[tenChuan.replace(/^combo\s+/, "")] ?? "banh-cuon-minh-hoa.jpg"
    : anhTheoTen[tenChuan];
  const src = tep ? thuMucAnh + tep : null;
  const [anhLoi, setAnhLoi] = useState<string | null>(null);
  const coAnh = src !== null && anhLoi !== src;

  return <span className={`relative flex shrink-0 items-center justify-center overflow-hidden rounded-lg bg-muted text-muted-foreground ${className}`}>
    {coAnh ? <>
      <Image src={src} alt={ten} fill sizes="(max-width: 640px) 100vw, 340px"
        className="object-cover" onError={() => setAnhLoi(src)} />
      {tep === "banh-cuon-minh-hoa.jpg" && <span className="absolute bottom-1 right-1 rounded bg-black/65 px-1.5 py-0.5 text-[9px] text-white">Ảnh minh hoạ</span>}
    </> : <span role="img" aria-label={`Chưa có ảnh ${ten}`} className="flex flex-col items-center gap-1 p-1 text-center">
      <ImageIcon aria-hidden="true" className="size-5 opacity-60" />
      <span className="text-[9px] leading-tight">Chưa có ảnh</span>
    </span>}
  </span>;
}
