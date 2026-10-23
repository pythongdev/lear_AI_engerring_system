"use client";
// Thanh điều hướng khung chủ quán — tầng 3 (01-khung-fe.md §4). Mục khớp đúng đường dẫn mang aria-current.

import Link from "next/link";
import { usePathname } from "next/navigation";

import { mucChuQuan } from "./muc-chu-quan";

export function ThanhDieuHuong() {
  const duongDan = usePathname();

  return (
    <nav aria-label="Trang chủ quán" className="mb-3 border-b pb-2">
      <ul className="flex flex-wrap gap-x-1 gap-y-1 text-sm">
        {mucChuQuan.map((muc) => (
          <li key={muc.route}>
            <Link
              href={muc.route}
              aria-current={duongDan === muc.route ? "page" : undefined}
              className="block rounded-md px-2 py-1 hover:bg-muted aria-[current=page]:bg-muted aria-[current=page]:font-semibold"
            >
              {muc.nhan}
            </Link>
          </li>
        ))}
      </ul>
    </nav>
  );
}
