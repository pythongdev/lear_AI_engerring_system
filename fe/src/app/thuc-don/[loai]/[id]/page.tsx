import Link from "next/link";
import { notFound } from "next/navigation";
import { ArrowLeft, Package, UtensilsCrossed } from "lucide-react";
import { backendUrl } from "@/lib/api/backend-url";
import type { components } from "@/lib/api/schema";
import { tien } from "@/components/shared/dong-mon-da-ghi";
import { ChonMonChiTiet } from "../../chon-mon-chi-tiet";
import "../../../ban/_components/thuc-don-khach.css";

type Nhom = components["schemas"]["MenuOptionGroup"];
const tenLuaChon = (nhom: Nhom, ten: string) => nhom.option_group_name === "Lượng nhân" && ten === "Thường" ? "Vừa" : ten;
const toHop = (groups: Nhom[], ids: number[]) => groups.flatMap((g) => g.options.filter((o) => ids.includes(o.menu_option_id)).map((o) => tenLuaChon(g, o.option_name))).join(" · ");

export default async function ChiTietMonPage({ params, searchParams }: {
  params: Promise<{ loai: string; id: string }>;
  searchParams: Promise<{ ban?: string | string[] }>;
}) {
  const { loai, id } = await params;
  const { ban } = await searchParams;
  if (!['combo', 'mon'].includes(loai) || !/^[1-9]\d*$/.test(id) || !Number.isSafeInteger(Number(id))) notFound();
  const veMenu = typeof ban === "string" && ban ? `/ban/${encodeURIComponent(ban)}` : "/dat-mon";
  let menu: components["schemas"]["Menu"] | undefined;
  try {
    const response = await fetch(`${backendUrl()}/menu`, { cache: "no-store" });
    if (response.ok) menu = await response.json();
  } catch { /* Hiện lời lỗi đọc, không suy ra món đã ngừng bán. */ }
  const quayLai = <Link href={veMenu} className="inline-flex min-h-11 items-center gap-2 text-[var(--accent)]"><ArrowLeft size={18} aria-hidden="true" />Quay lại menu</Link>;
  if (!menu) return <main className="khach-menu min-h-dvh bg-[var(--bg)] p-4 text-[var(--text)]">{quayLai}<p role="alert">Chưa đọc được chi tiết món. Bạn vui lòng tải lại trang.</p></main>;
  const combo = loai === "combo" ? menu.combos.find((c) => c.menu_combo_id === Number(id)) : undefined;
  const mon = loai === "mon" ? menu.items.find((m) => m.menu_item_id === Number(id)) : undefined;
  if (!combo && !mon) notFound();
  const ten = combo ? combo.name : mon!.item_name;
  const groups = combo
    ? Array.from(new Map(combo.items.flatMap((m) => m.option_groups).map((g) => [g.option_group_id, g])).values())
    : mon!.option_groups;
  return <main className="khach-menu min-h-dvh bg-[var(--page)] text-[var(--text)]">
    <article className="mx-auto min-h-dvh max-w-[472px] bg-[var(--bg)] p-4">
      {quayLai}
      <div className="my-4 grid h-48 place-items-center rounded-2xl bg-[var(--field)] text-[var(--muted)]">
        {combo ? <Package size={64} aria-hidden="true" /> : <UtensilsCrossed size={64} aria-hidden="true" />}
      </div>
      <p className="text-xs text-[var(--muted)]">{combo ? "COMBO" : "MÓN LẺ"}</p>
      <h1 className="mt-2 text-2xl font-semibold">{ten}</h1>
      {combo && <>
        <p className="mt-3 text-xl text-[var(--accent)]">Giá combo {tien(combo.price_vnd)}</p>
        <p className="mt-1 text-sm text-[var(--muted)]">Giá theo lựa chọn được cập nhật trong giỏ hàng.</p>
        <section className="mt-6"><h2 className="font-semibold">Các món trong combo</h2>
          <ul className="mt-2 divide-y divide-[var(--line)]">{combo.items.map((m) => <li key={m.menu_item_id} className="flex items-center justify-between gap-3 py-3">
            <Link className="text-[var(--accent)]" href={`/thuc-don/mon/${m.menu_item_id}${typeof ban === "string" && ban ? `?ban=${encodeURIComponent(ban)}` : ""}`}>{m.item_name}</Link><span>×{m.quantity}</span>
          </li>)}</ul>
        </section>
      </>}
      {mon && <section className="mt-6"><h2 className="font-semibold">Giá theo lựa chọn</h2>
        <ul className="mt-2 divide-y divide-[var(--line)]">{mon.prices.map((p) => <li key={p.option_ids.join(",")} className="flex justify-between gap-3 py-3 text-sm">
          <span>{toHop(mon.option_groups, p.option_ids) || mon.item_name}</span><span className="shrink-0 text-[var(--accent)]">{tien(p.unit_price_vnd)}</span>
        </li>)}</ul>
        {!mon.prices.length && <p className="mt-2 text-sm">Chưa có giá cho món này.</p>}
      </section>}
      <ChonMonChiTiet key={`${loai}-${id}`} menu={menu} mon={mon} combo={combo} groups={groups} maBan={typeof ban === "string" && ban ? ban : undefined} />
      <Link href={veMenu} className="mt-6 flex min-h-12 items-center justify-center rounded-xl border border-[var(--accent)] px-3 text-[var(--accent)]">Về menu xem giỏ hàng</Link>
    </article>
  </main>;
}
