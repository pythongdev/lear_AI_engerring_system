"use client";
// Sản phẩm: thứ tự và trạng thái từ /menu-categories, từng giá từ /menu; không tính giá tại FE.

import { useId, useState } from "react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { useSanPham, type Mon } from "./du-lieu-san-pham";
import { useMenuGia, tienGia } from "./du-lieu-menu-gia";
import { FormDoiTenMon } from "./form-doi-ten-mon";
import { FormThemMon } from "./form-them-mon";

type GiaQuery = ReturnType<typeof useMenuGia>;

function GiaMon({ mon, gia }: { mon: Mon; gia: GiaQuery }) {
  if (mon.discontinued) return "—";
  if (gia.isError) return "Chưa đọc được giá";
  if (gia.isPending) return "…";
  const item = gia.data.items.find((i) => i.menu_item_id === mon.menu_item_id);
  if (!item || item.prices.length === 0) return "Chưa có giá";
  const options = new Map(item.option_groups.flatMap((g) => g.options.map((o) => [o.menu_option_id, o.option_name] as const)));
  return item.prices.map((p, i) => <div key={i}>
    {p.option_ids.length > 0 && <>{p.option_ids.map((id) => options.get(id)).join(" · ")} </>}
    <span className="sp-price">{tienGia(p.unit_price_vnd)}</span>
  </div>);
}

function DongMon({ mon, danhMuc, gia, bao }: { mon: Mon; danhMuc: string; gia: GiaQuery; bao: (s: string) => void }) {
  const [sua, setSua] = useState(false);
  return <tr>
    <td>{mon.item_name}</td><td>{danhMuc}</td>
    <td>{mon.discontinued ? <span className="sp-badge sp-discontinued">Ngừng bán</span> : "Đang bán"}</td>
    <td><GiaMon mon={mon} gia={gia} /></td>
    <td><Dialog open={sua} onOpenChange={setSua}>
      <DialogTrigger asChild><Button variant="outline" onClick={() => bao("")} aria-label={`Đổi tên ${mon.item_name}`}>Đổi tên</Button></DialogTrigger>
      <DialogContent className="trang-san-pham sp-drawer" aria-describedby={undefined}>
        <DialogTitle>Đổi tên {mon.item_name}</DialogTitle>
        <FormDoiTenMon mon={mon} dong={() => setSua(false)} daLuu={(ten) => {
          setSua(false); bao(`Đã đổi tên thành ${ten}.`);
        }} />
      </DialogContent>
    </Dialog></td>
  </tr>;
}

function DanhMuc({ ten, items, gia, bao, chuaXep = false }: {
  ten: string; items: Mon[]; gia: GiaQuery; bao: (s: string) => void; chuaXep?: boolean;
}) {
  const id = useId();
  return <section aria-labelledby={id} className="sp-panel">
    <h2 id={id}>{ten}</h2>
    {items.length === 0 ? <p className="sp-empty">Chưa có món</p> :
      <div className="sp-table-scroll" role="region" aria-label={`Bảng món ${ten}`} tabIndex={0}>
        <table><thead><tr>{["Món", "Danh mục", "Trạng thái", "Giá", "Thao tác"].map((c) => <th key={c} scope="col">{c}</th>)}</tr></thead>
          <tbody>{items.map((mon) => <DongMon key={mon.menu_item_id} mon={mon} danhMuc={chuaXep ? "Chưa xếp" : ten} gia={gia} bao={bao} />)}</tbody>
        </table>
      </div>}
  </section>;
}

export function TrangSanPham() {
  const query = useSanPham();
  const gia = useMenuGia();
  const data = query.data;
  const [thongBao, setThongBao] = useState("");
  const soMon = data && data.categories.reduce((n, c) => n + c.items.length, data.uncategorized_items.length);
  return <div className="trang-san-pham mx-auto w-full min-w-0 max-w-[1200px] space-y-3">
    <header className="flex flex-wrap items-center justify-between gap-3">
      <h1>Sản phẩm {data && <span className="sp-badge">{soMon} món</span>}</h1>
      <div className="flex flex-wrap items-center gap-2">
        <Button variant="outline" disabled={query.isFetching || gia.isFetching} onClick={() => {
          void query.refetch(); void gia.refetch();
        }}>Đọc lại danh sách</Button>
        {!!data?.categories.length && <Dialog>
          <DialogTrigger asChild><Button className="sp-primary">Thêm món</Button></DialogTrigger>
          <DialogContent className="trang-san-pham sp-drawer" aria-describedby={undefined}>
            <DialogTitle>Thêm món</DialogTitle>
            <FormThemMon categories={data.categories} />
          </DialogContent>
        </Dialog>}
      </div>
    </header>
    {query.isPending && <p role="status">{query.fetchStatus === "paused" ? "Đang chờ kết nối." : "Đang đọc danh sách món…"}</p>}
    {query.isError && <Alert role="alert"><AlertDescription>
      Chưa đọc được danh sách món.{data ? " Đang hiện bản đọc trước." : " Hãy thử lại."}
    </AlertDescription></Alert>}
    {thongBao && <p role="status">{thongBao}</p>}
    {data && <>
      {query.isFetching && <p role="status">Đang đọc lại danh sách…</p>}
      {data.categories.map((c) => <DanhMuc key={c.menu_category_id} ten={c.name} items={c.items} gia={gia} bao={setThongBao} />)}
      <DanhMuc ten="Chưa xếp danh mục" items={data.uncategorized_items} gia={gia} bao={setThongBao} chuaXep />
      {data.categories.length === 0 && <p>Chưa có danh mục. Hãy thêm danh mục trước khi thêm món.</p>}
    </>}
    <style>{`
      .trang-san-pham {
        --sp-bg:#FFFFFF; --sp-card:#F3F4F6; --sp-line:#E5E7EB; --sp-muted:#6B7280;
        --sp-accent:#EA6A0C; --sp-field:#E5E7EB; --sp-text:#111827; --sp-badge:#FDECDC; --sp-on-accent:#fff;
        background:var(--sp-bg); color:var(--sp-text); font-size:12px; line-height:1.45;
      }
      .dark .trang-san-pham {
        --sp-bg:#000000; --sp-card:#1F2937; --sp-line:#2D3748; --sp-muted:#9CA3AF;
        --sp-accent:#FF7A1A; --sp-field:#374151; --sp-text:#F9FAFB; --sp-badge:#3a2a18;
      }
      .trang-san-pham h1 { font-size:20px; font-weight:600; }
      .trang-san-pham h2 { font-size:14px; font-weight:500; }
      .trang-san-pham .sp-panel { min-width:0; padding:12px; border:1px solid var(--sp-line); border-radius:10px; background:var(--sp-card); }
      .trang-san-pham .sp-badge { padding:1px 5px; border-radius:5px; font-size:10px; font-weight:400; white-space:nowrap; vertical-align:middle; background:var(--sp-badge); color:var(--sp-accent); }
      .trang-san-pham .sp-discontinued { background:var(--sp-field); color:var(--sp-muted); }
      .trang-san-pham .sp-empty { padding:12px 0; color:var(--sp-muted); }
      .trang-san-pham .sp-table-scroll { min-width:0; max-width:100%; overflow-x:auto; }
      .trang-san-pham table { width:100%; border-collapse:collapse; text-align:left; margin-top:6px; }
      .trang-san-pham th, .trang-san-pham td { padding:8px; border-bottom:1px solid var(--sp-line); vertical-align:top; }
      .trang-san-pham th { font-weight:400; color:var(--sp-muted); white-space:nowrap; }
      .trang-san-pham tr:last-child td { border-bottom:0; }
      .trang-san-pham td:last-child, .trang-san-pham th:last-child { text-align:right; }
      .trang-san-pham .sp-price { color:var(--sp-accent); white-space:nowrap; font-variant-numeric:tabular-nums; }
      .trang-san-pham button { border:1px solid var(--sp-line); border-radius:7px; background:transparent; color:inherit; font:inherit; padding:6px 10px; box-shadow:none; }
      .trang-san-pham button:hover { filter:brightness(1.15); }
      .trang-san-pham .sp-primary, .trang-san-pham [role="checkbox"][data-state="checked"] { background:var(--sp-accent); border-color:var(--sp-accent); color:var(--sp-on-accent); }
      .trang-san-pham button:disabled { color:var(--sp-muted); cursor:default; }
      .trang-san-pham :focus-visible { outline:2px solid var(--sp-accent); outline-offset:3px; box-shadow:none; }
      .trang-san-pham input, .trang-san-pham select { min-width:0; background:var(--sp-field); color:var(--sp-text); border:1px solid var(--sp-line); border-radius:7px; font:inherit; }
      .trang-san-pham fieldset { min-width:0; border-color:var(--sp-line); }
      .trang-san-pham [role="checkbox"] { padding:0; }
      .trang-san-pham [role="alert"], .trang-san-pham [data-slot="alert"] { background:var(--sp-card); color:var(--sp-text); border-color:var(--sp-line); }
      /* Portal mang cùng lớp trang để nhận token ở cả hai giao diện. */
      .trang-san-pham.sp-drawer {
        top:0; right:0; bottom:auto; left:auto; transform:none; translate:none;
        width:min(380px,100%); max-width:380px; height:100dvh; max-height:100dvh;
        overflow-y:auto; overscroll-behavior:contain; display:flex; flex-direction:column;
        border:1px solid var(--sp-line); border-radius:12px 0 0 12px; background:var(--sp-card); padding:18px;
        animation:none;
      }
      .trang-san-pham.sp-drawer > h2 { padding-right:24px; padding-bottom:12px; border-bottom:1px solid var(--sp-line); }
    `}</style>
  </div>;
}
