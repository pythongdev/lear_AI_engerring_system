import type { components } from "@/lib/api/schema";

export const tien = (so: number) => new Intl.NumberFormat("vi-VN").format(so) + "đ";

export function DongMonDaGhi({ lines, total }: { lines: components["schemas"]["PriceLine"][]; total: number }) {
  return <div className="space-y-2">
    {lines?.map((dong, i) => <p key={i}>{dong.item_name} · {dong.options.map((o) => o.option_name).join(", ")} · Số lượng {dong.quantity} · {tien(dong.line_total_vnd)}</p>)}
    <p>Tổng {tien(total)}</p>
  </div>;
}
