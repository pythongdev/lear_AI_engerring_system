"use client";
// Thanh điều hướng khung chủ quán — tầng 3 (01-khung-fe.md §4). Mục khớp đúng đường dẫn mang aria-current.

import { useEffect, useId, useRef, useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { ChevronDown } from "lucide-react";

import { mucChuQuan } from "./muc-chu-quan";

const nhomQuanLy = [
  { ma: "ban_hang", nhan: "Bán hàng" },
  { ma: "nhan_su", nhan: "Nhân sự" },
  { ma: "kho_chi", nhan: "Kho & chi" },
] as const;
type MaNhom = typeof nhomQuanLy[number]["ma"];
const lopMuc = "inline-flex min-h-9 items-center gap-1 rounded-lg px-3 py-1.5 text-sm hover:bg-muted focus-visible:outline-2 focus-visible:outline-offset-2";

export function ThanhDieuHuong() {
  const duongDan = usePathname();
  const [mo, setMo] = useState<{ duongDan: string; ma: MaNhom } | null>(null);
  const dangMo = mo?.duongDan === duongDan ? mo.ma : null;
  const navRef = useRef<HTMLElement>(null);
  const nutMo = useRef<HTMLButtonElement>(null);
  const panelId = useId();
  const mucHienTai = mucChuQuan.find((muc) => muc.route === duongDan);

  useEffect(() => {
    if (!dangMo) return;
    const bamNgoai = (event: PointerEvent) => {
      if (event.target instanceof Node && !navRef.current?.contains(event.target)) setMo(null);
    };
    const bamPhim = (event: KeyboardEvent) => {
      if (event.key === "Escape") {
        setMo(null);
        nutMo.current?.focus();
      }
    };
    document.addEventListener("pointerdown", bamNgoai);
    document.addEventListener("keydown", bamPhim);
    return () => {
      document.removeEventListener("pointerdown", bamNgoai);
      document.removeEventListener("keydown", bamPhim);
    };
  }, [dangMo]);

  return (
    <nav ref={navRef} aria-label="Trang chủ quán" className="mb-3 min-w-0 border-b pb-2">
      <ul className="flex flex-wrap items-center gap-1">
        {mucChuQuan.filter((muc) => muc.nhom === "truc_tiep").map((muc) => (
          <li key={muc.route}>
            <Link
              href={muc.route}
              aria-current={duongDan === muc.route ? "page" : undefined}
              onClick={() => setMo(null)}
              className={`${lopMuc} aria-[current=page]:bg-muted aria-[current=page]:font-semibold`}
            >
              {muc.nhan}
            </Link>
          </li>
        ))}
        {nhomQuanLy.map((nhom) => {
          const dangO = mucHienTai?.nhom === nhom.ma;
          return <li key={nhom.ma}>
            <button
              type="button"
              aria-label={`${nhom.nhan}${dangO ? ` · ${mucHienTai.nhan}` : ""}`}
              aria-expanded={dangMo === nhom.ma}
              aria-controls={panelId}
              onClick={(event) => {
                nutMo.current = event.currentTarget;
                setMo(dangMo === nhom.ma ? null : { duongDan, ma: nhom.ma });
              }}
              className={`${lopMuc} ${dangO || dangMo === nhom.ma ? "bg-muted font-semibold" : ""}`}
            >
              {nhom.nhan}{dangO && <span className="font-normal text-muted-foreground">· {mucHienTai.nhan}</span>}
              <ChevronDown aria-hidden="true" className={`size-4 transition-transform ${dangMo === nhom.ma ? "rotate-180" : ""}`} />
            </button>
          </li>;
        })}
      </ul>
      <div id={panelId} hidden={!dangMo} className="mt-2 rounded-lg border bg-background p-2 shadow-sm">
        {nhomQuanLy.filter((nhom) => nhom.ma === dangMo).map((nhom) => <div key={nhom.ma}>
          <p className="px-2 pb-1 text-xs font-medium text-muted-foreground">{nhom.nhan}</p>
          <ul className="grid grid-cols-2 gap-1 sm:grid-cols-3 lg:grid-cols-5">
            {mucChuQuan.filter((muc) => muc.nhom === nhom.ma).map((muc) => <li key={muc.route} className="min-w-0">
              <Link href={muc.route} aria-current={duongDan === muc.route ? "page" : undefined} onClick={() => setMo(null)}
                className="block min-h-9 rounded-md px-2 py-2 text-sm hover:bg-muted focus-visible:outline-2 focus-visible:outline-offset-2 aria-[current=page]:bg-muted aria-[current=page]:font-semibold">
                {muc.nhan}
              </Link>
            </li>)}
          </ul>
        </div>)}
      </div>
    </nav>
  );
}
