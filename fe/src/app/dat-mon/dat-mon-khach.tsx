"use client";

import Link from "next/link";
import { ThanhTabKhach } from "@/components/khach/thanh-tab-khach";
import type { components } from "@/lib/api/schema";
import { usePhienKhach } from "@/lib/khach/session";
import { PhieuKhach } from "../ban/_components/phieu-khach";

export function DatMonKhach({ initialMenu }: { initialMenu: components["schemas"]["Menu"] }) {
  const phien = usePhienKhach();
  // Chờ lần đọc đầu để initialDelivery thực sự là giá trị khởi tạo. Refetch không ghi đè nháp.
  return <><div className="pb-[calc(9rem+env(safe-area-inset-bottom))]">
    {phien.isPending ? <section className="mx-auto max-w-lg space-y-3 px-4" aria-label="Thực đơn">
      <h1 className="text-xl font-semibold">Đặt món</h1>
      <p role="status">Đang đọc thông tin giao…</p>
      {initialMenu.combos.map((m) => <p key={`combo-${m.menu_combo_id}`}><Link href={`/thuc-don/combo/${m.menu_combo_id}`}>{m.name}</Link></p>)}
      {initialMenu.items.map((m) => <p key={m.menu_item_id}><Link href={`/thuc-don/mon/${m.menu_item_id}`}>{m.item_name}</Link></p>)}
    </section> : <>
      {phien.error && <p role="alert">Chưa đọc được thông tin đã nhớ. Bạn vẫn có thể nhập thông tin để đặt món.</p>}
      <PhieuKhach key={phien.data?.customer_account_id ?? "an-danh"} initialMenu={initialMenu} initialDelivery={phien.data ?? undefined} />
    </>}
  </div><ThanhTabKhach /></>;
}
