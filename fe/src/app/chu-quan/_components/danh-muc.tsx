"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useId, useState } from "react";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { useSanPham, type DanhSachMon, type Mon } from "./du-lieu-san-pham";
import { useThemDanhMuc, useDoiTenDanhMuc, useAnDanhMuc, useXepDanhMuc, type KieuMenu } from "./du-lieu-danh-muc-combo";
import { FormMenu, OMenu, chuMenu, soMenu } from "./form-menu";

type DanhMuc = KieuMenu["MenuCategory"];
type Bao = (message: string) => void;
const themSchema = z.object({ name: chuMenu });
const tenSchema = z.object({ name: chuMenu, reason: chuMenu });
const anSchema = z.object({ reason: chuMenu });

function FormThemDanhMuc({ bao }: { bao: Bao }) {
  const luu = useThemDanhMuc();
  const form = useForm<KieuMenu["CreateMenuCategory"]>({ resolver: zodResolver(themSchema), defaultValues: { name: "" } });
  return <FormMenu form={form} ten="Thêm danh mục" nut="Thêm danh mục" gui={luu.mutateAsync} cacO={["name"]}
    daLuu={(data) => { form.reset({ name: "" }); bao(`Đã thêm danh mục ${data.name}.`); }}>
    <h2 className="text-lg font-semibold">Thêm danh mục</h2>
    <OMenu form={form} o="name" nhan="Tên danh mục" />
  </FormMenu>;
}
function FormDoiTenDanhMuc({ c, dong, bao }: { c: DanhMuc; dong: () => void; bao: Bao }) {
  const luu = useDoiTenDanhMuc(c.menu_category_id);
  const form = useForm<KieuMenu["UpdateMenuCategory"]>({ resolver: zodResolver(tenSchema), defaultValues: { name: c.name, reason: "" } });
  return <FormMenu form={form} ten={`Đổi tên danh mục ${c.name}`} nut="Lưu tên" gui={luu.mutateAsync}
    cacO={["name", "reason"]} dong={dong} daLuu={(data) => { bao(`Đã đổi tên danh mục thành ${data.name}.`); dong(); }}>
    <OMenu form={form} o="name" nhan="Tên mới" />
    <OMenu form={form} o="reason" nhan="Lý do" />
  </FormMenu>;
}
function FormAnDanhMuc({ c, dong, bao }: { c: DanhMuc; dong: () => void; bao: Bao }) {
  const luu = useAnDanhMuc(c.menu_category_id);
  const form = useForm<KieuMenu["HideMenuCategory"]>({ resolver: zodResolver(anSchema), defaultValues: { reason: "" } });
  return <FormMenu form={form} ten={`Ẩn danh mục ${c.name}`} nut="Xác nhận ẩn" gui={luu.mutateAsync}
    cacO={["reason"]} dong={dong} daLuu={(data) => { bao(`Đã ẩn danh mục ${data.name}.`); dong(); }}>
    <p>Các món sẽ về nhóm Chưa xếp danh mục.</p>
    <OMenu form={form} o="reason" nhan="Lý do" />
  </FormMenu>;
}
function FormXepMon({ mon, hienTai, categories, dong, bao }: {
  mon: Mon; hienTai?: number; categories: DanhSachMon["categories"]; dong: () => void; bao: Bao;
}) {
  const luu = useXepDanhMuc(mon.menu_item_id);
  const chuyen = hienTai !== undefined;
  // Món "chưa xếp" có thể thuộc danh mục đã ẩn — dòng xếp cũ còn, backend đòi lý do mà phản hồi đọc không cho biết.
  // Nên ô Lý do luôn có: bắt buộc khi chuyển, không bắt buộc khi xếp; để trống thì không gửi.
  const schema = z.object({ menu_category_id: soMenu, reason: z.string().trim() }).superRefine((body, ctx) => {
    if (chuyen && !body.reason) ctx.addIssue({ code: "custom", path: ["reason"], message: "Nhập lý do." });
  });
  const form = useForm<{ menu_category_id: number; reason: string }>({ resolver: zodResolver(schema),
    defaultValues: { menu_category_id: NaN, reason: "" } });
  const gui = ({ menu_category_id, reason }: { menu_category_id: number; reason: string }) =>
    luu.mutateAsync(reason ? { menu_category_id, reason } : { menu_category_id });
  return <FormMenu form={form} ten={`${chuyen ? "Chuyển" : "Xếp"} danh mục ${mon.item_name}`} nut="Lưu"
    gui={gui} cacO={["menu_category_id", "reason"]} dong={dong}
    daLuu={(data) => { bao(chuyen ? `Đã chuyển ${mon.item_name} sang ${data.name}.` : `Đã xếp ${mon.item_name} vào ${data.name}.`); dong(); }}>
    <OMenu form={form} o="menu_category_id" nhan="Danh mục đích"
      options={categories.filter((c) => c.menu_category_id !== hienTai).map((c) => ({ id: c.menu_category_id, ten: c.name }))} />
    <OMenu form={form} o="reason" nhan="Lý do" />
    {!chuyen && <p className="text-sm text-muted-foreground">Cần lý do nếu món từng thuộc một danh mục đã ẩn.</p>}
  </FormMenu>;
}
function DongMon({ mon, hienTai, categories, bao }: { mon: Mon; hienTai?: number; categories: DanhSachMon["categories"]; bao: Bao }) {
  const [sua, setSua] = useState(false);
  return <li className="space-y-3 border-b py-3 last:border-0">
    <div className="flex flex-wrap items-center justify-between gap-3">
      <span>{mon.item_name}{mon.discontinued && <span className="ml-2 text-sm text-muted-foreground">Ngừng bán</span>}</span>
      {!sua && <Button variant="outline" aria-label={`${hienTai === undefined ? "Xếp" : "Chuyển"} danh mục ${mon.item_name}`}
        onClick={() => setSua(true)}>{hienTai === undefined ? "Xếp danh mục" : "Chuyển danh mục"}</Button>}
    </div>
    {sua && <FormXepMon mon={mon} hienTai={hienTai} categories={categories} bao={bao} dong={() => setSua(false)} />}
  </li>;
}
function NhomDanhMuc({ c, items, categories, bao }: { c?: DanhMuc; items: Mon[]; categories: DanhSachMon["categories"]; bao: Bao }) {
  const id = useId();
  const [sua, setSua] = useState<"ten" | "an" | null>(null);
  return <section aria-labelledby={id}><Card>
    <CardHeader><CardTitle><h2 id={id}>{c?.name ?? "Chưa xếp danh mục"}</h2></CardTitle></CardHeader>
    <CardContent className="space-y-4">
      {c && !sua && <div className="flex gap-2">
        <Button variant="outline" aria-label={`Đổi tên danh mục ${c.name}`} onClick={() => setSua("ten")}>Đổi tên</Button>
        <Button variant="outline" aria-label={`Ẩn danh mục ${c.name}`} onClick={() => setSua("an")}>Ẩn</Button>
      </div>}
      {c && sua === "ten" && <FormDoiTenDanhMuc c={c} dong={() => setSua(null)} bao={bao} />}
      {c && sua === "an" && <FormAnDanhMuc c={c} dong={() => setSua(null)} bao={bao} />}
      {items.length === 0 ? <p>Chưa có món</p> : <ul>{items.map((mon) =>
        <DongMon key={mon.menu_item_id} mon={mon} hienTai={c?.menu_category_id} categories={categories} bao={bao} />)}</ul>}
    </CardContent>
  </Card></section>;
}
export function TrangDanhMuc() {
  const query = useSanPham();
  const data = query.data;
  const [thongBao, bao] = useState<string | null>(null);
  return <div className="mx-auto w-full max-w-4xl space-y-6 p-4 sm:p-6">
    <h1 className="text-2xl font-semibold">Danh mục</h1>
    {query.isPending && <p role="status">{query.fetchStatus === "paused" ? "Đang chờ kết nối." : "Đang đọc danh mục…"}</p>}
    {query.isError && <Alert role="alert"><AlertDescription>Chưa đọc được danh mục.
      {data ? ` Đang hiện bản đọc trước, lúc ${new Date(query.dataUpdatedAt).toLocaleTimeString("vi-VN")}.` : " Hãy thử lại."}
      {thongBao && " Đã ghi, chưa cập nhật được dữ liệu."}
    </AlertDescription></Alert>}
    <Button variant="outline" disabled={query.isFetching} onClick={() => void query.refetch()}>Đọc lại danh sách</Button>
    {thongBao && <p role="status">{thongBao}</p>}
    {data && <>
      {query.isFetching && <p role="status">Đang đọc lại danh mục…</p>}
      {data.categories.length === 0 && <p>Chưa có danh mục.</p>}
      {data.categories.map((c) => <NhomDanhMuc key={c.menu_category_id} c={c} items={c.items} categories={data.categories} bao={bao} />)}
      <NhomDanhMuc items={data.uncategorized_items} categories={data.categories} bao={bao} />
      <Card><CardContent><FormThemDanhMuc bao={bao} /></CardContent></Card>
    </>}
  </div>;
}
