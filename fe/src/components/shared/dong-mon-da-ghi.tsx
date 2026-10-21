import type { components } from "@/lib/api/schema";

export const tien = (so: number) => new Intl.NumberFormat("vi-VN").format(so) + "đ";

export function DongMonDaGhi({ lines, total }: { lines: components["schemas"]["PriceLine"][]; total: number }) {
  return <div className="space-y-2">
    {lines?.map((dong, i) => <div key={i}><p>{dong.item_name} · {dong.options.map((o) => o.option_name).join(", ")} · Số lượng {dong.quantity} · {tien(dong.line_total_vnd)}</p>
      {dong.portions?.map((p, k) => <p key={k} className="pl-4">{p.item_name} · {p.options.map((o) => o.option_name).join(", ")} · Số suất {p.quantity}</p>)}
    </div>)}
    <p>Tổng {tien(total)}</p>
  </div>;
}
