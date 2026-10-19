"use client";
// Thanh điều hướng khung chủ quán — tầng 3 (01-khung-fe.md §4). Mục khớp đúng đường dẫn mang aria-current.

import Link from "next/link";
import { usePathname } from "next/navigation";

import { mucChuQuan } from "./muc-chu-quan";

export function ThanhDieuHuong() {
  const duongDan = usePathname();

  return (
    <nav aria-label="Trang chủ quán" className="mb-6 border-b pb-3">
      <ul className="flex flex-wrap gap-4">
        {mucChuQuan.map((muc) => (
          <li key={muc.route}>
            <Link
              href={muc.route}
              aria-current={duongDan === muc.route ? "page" : undefined}
              className="underline-offset-4 hover:underline aria-[current=page]:font-semibold aria-[current=page]:underline"
            >
              {muc.nhan}
            </Link>
          </li>
        ))}
      </ul>
    </nav>
  );
}
