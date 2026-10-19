"use client";
// Trang Sản phẩm của chủ quán (P4A-04): món theo danh mục đúng thứ tự backend, thêm món, đổi tên có lý do. Sửa giá,
// thành phần và ngừng bán thuộc P4-05 — trang này không có nút ấy và không bày giá.

import { useId, useState } from "react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { useSanPham, type Mon } from "./du-lieu-san-pham";
import { FormDoiTenMon } from "./form-doi-ten-mon";
import { FormThemMon } from "./form-them-mon";

function DongMon({ mon }: { mon: Mon }) {
  const [sua, setSua] = useState(false);
  const [thongBao, setThongBao] = useState<string | null>(null);
  return <li className="space-y-3 border-b py-3 last:border-0">
    <div className="flex flex-wrap items-center justify-between gap-3">
      <span>{mon.item_name}{mon.discontinued && <span className="ml-2 text-sm text-muted-foreground">Ngừng bán</span>}</span>
      {!sua && <Button variant="outline" onClick={() => { setThongBao(null); setSua(true); }} aria-label={`Đổi tên ${mon.item_name}`}>Đổi tên</Button>}
    </div>
    {sua && <FormDoiTenMon mon={mon} dong={() => setSua(false)} daLuu={(ten) => {
      setSua(false); setThongBao(`Đã đổi tên thành ${ten}.`);
    }} />}
    {thongBao && <p role="status">{thongBao}</p>}
  </li>;
}

function DanhMuc({ ten, items }: { ten: string; items: Mon[] }) {
  const id = useId();
  return <section aria-labelledby={id}><Card>
    <CardHeader><CardTitle><h2 id={id}>{ten}</h2></CardTitle></CardHeader>
    <CardContent>{items.length === 0 ? <p>Chưa có món</p>
      : <ul>{items.map((mon) => <DongMon key={mon.menu_item_id} mon={mon} />)}</ul>}
    </CardContent>
  </Card></section>;
}

export function TrangSanPham() {
  const query = useSanPham();
  const data = query.data;
  return <div className="mx-auto w-full max-w-4xl space-y-6 p-4 sm:p-6">
    <h1 className="text-2xl font-semibold">Sản phẩm</h1>
    {query.isPending && <p role="status">{query.fetchStatus === "paused" ? "Đang chờ kết nối." : "Đang đọc danh sách món…"}</p>}
    {query.isError && <Alert role="alert"><AlertDescription>
      Chưa đọc được danh sách món.{data ? " Đang hiện bản đọc trước." : " Hãy thử lại."}
    </AlertDescription></Alert>}
    <Button variant="outline" disabled={query.isFetching} onClick={() => void query.refetch()}>Đọc lại danh sách</Button>
    {data && <>
      {query.isFetching && <p role="status">Đang đọc lại danh sách…</p>}
      {data.categories.map((c) => <DanhMuc key={c.menu_category_id} ten={c.name} items={c.items} />)}
      <DanhMuc ten="Chưa xếp danh mục" items={data.uncategorized_items} />
      {data.categories.length === 0 ? <p>Chưa có danh mục. Hãy thêm danh mục trước khi thêm món.</p>
        : <Card><CardContent><FormThemMon categories={data.categories} /></CardContent></Card>}
    </>}
  </div>;
}
