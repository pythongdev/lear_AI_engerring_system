"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useId, useState } from "react";
import { useForm } from "react-hook-form";
import { useRouter, useSearchParams } from "next/navigation";
import { z } from "zod";
import { Button } from "@/components/ui/button";
import { Field, FieldError, FieldLabel } from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import { FormMenu, OMenu, chuMenu } from "./form-menu";
import { useNguyenLieu, useSoNguyenLieu, useThemNguyenLieu, useDatDonVi, useGhiConSo, useSuaConSo,
  loiNguyenLieu, oLoiNguyenLieu, type KieuNguyenLieu } from "./du-lieu-nguyen-lieu";

const loi = { loi: loiNguyenLieu, oLoi: oLoiNguyenLieu };
const measure = z.string().trim().regex(/^(0|[1-9][0-9]{0,8})(\.[0-9]{1,3})?$/, "Nhập số không âm, tối đa 9 chữ số nguyên; dùng dấu chấm, tối đa 3 chữ số lẻ.");
const them = z.object({ name: chuMenu, purchase_unit: z.string().trim() });
const donVi = z.object({ purchase_unit: chuMenu });
const ghi = z.object({ entry_date: chuMenu, kind: z.enum(["purchased", "used"], { error: "Chọn loại con số." }), measure });
const sua = z.object({ measure, reason: chuMenu });
type Bao = (s: string) => void;

function Them({ bao }: { bao: Bao }) {
  const luu = useThemNguyenLieu();
  const form = useForm<z.infer<typeof them>>({ resolver: zodResolver(them), defaultValues: { name: "", purchase_unit: "" } });
  return <FormMenu {...loi} form={form} ten="Thêm nguyên liệu" nut="Thêm nguyên liệu" cacO={["name", "purchase_unit"]}
    gui={({ name, purchase_unit }) => luu.mutateAsync(purchase_unit ? { name, purchase_unit } : { name })}
    daLuu={() => { form.reset(); bao("Đã thêm nguyên liệu."); }}>
    <h2 className="text-lg font-semibold">Thêm nguyên liệu</h2>
    <OMenu form={form} o="name" nhan="Tên nguyên liệu" />
    <OMenu form={form} o="purchase_unit" nhan="Đơn vị mua (tuỳ chọn)" />
  </FormMenu>;
}
function DatDonVi({ thu, bao }: { thu: KieuNguyenLieu["SupplyItem"]; bao: Bao }) {
  const [mo, setMo] = useState(false);
  const luu = useDatDonVi(thu.supply_item_id);
  const form = useForm<z.infer<typeof donVi>>({ resolver: zodResolver(donVi), defaultValues: { purchase_unit: "" } });
  if (!mo) return <Button variant="outline" onClick={() => setMo(true)} aria-label={`Đặt đơn vị ${thu.name}`}>Đặt đơn vị</Button>;
  return <FormMenu {...loi} form={form} ten={`Đặt đơn vị ${thu.name}`} nut="Lưu đơn vị" cacO={["purchase_unit"]}
    gui={luu.mutateAsync} dong={() => setMo(false)} daLuu={() => { bao("Đã đặt đơn vị."); setMo(false); }}>
    <OMenu form={form} o="purchase_unit" nhan="Đơn vị mua" />
  </FormMenu>;
}
function Ghi({ id, bao }: { id: number; bao: Bao }) {
  const luu = useGhiConSo();
  const form = useForm<z.infer<typeof ghi>>({ resolver: zodResolver(ghi), defaultValues: { entry_date: "", measure: "" } });
  const uid = useId();
  return <FormMenu {...loi} form={form} ten="Ghi con số" nut="Ghi con số" cacO={["entry_date", "kind", "measure"]}
    gui={(body) => luu.mutateAsync({ ...body, supply_item_id: id })} daLuu={() => { form.reset(); bao("Đã ghi con số."); }}>
    <h3 className="font-semibold">Ghi con số</h3>
    {(["entry_date", "kind"] as const).map((o) => {
      const error = form.formState.errors[o]?.message;
      const props = { id: `${uid}-${o}`, "aria-invalid": !!error, "aria-describedby": error ? `${uid}-${o}-loi` : undefined, ...form.register(o) };
      return <Field key={o} data-invalid={!!error}>
        <FieldLabel htmlFor={props.id}>{o === "entry_date" ? "Ngày" : "Loại"}</FieldLabel>
        {o === "entry_date" ? <Input {...props} type="date" /> : <select {...props} className="h-9 w-full rounded-md border bg-background px-3" defaultValue="">
          <option value="">Chọn loại</option><option value="purchased">Mua vào</option><option value="used">Đã dùng</option>
        </select>}
        {error && <FieldError id={`${uid}-${o}-loi`}>{error}</FieldError>}
      </Field>;
    })}
    <OMenu form={form} o="measure" nhan="Con số" />
    <p>Dùng dấu chấm, tối đa 3 chữ số lẻ.</p>
  </FormMenu>;
}
function Dong({ dong, unit, bao }: { dong: KieuNguyenLieu["SupplyDayEntry"]; unit: string | null; bao: Bao }) {
  const [mo, setMo] = useState(false);
  const luu = useSuaConSo(dong.supply_day_entry_id);
  const form = useForm<z.infer<typeof sua>>({ resolver: zodResolver(sua), defaultValues: { measure: dong.measure, reason: "" } });
  return <li className="space-y-3 border-b py-3">
    <p>{dong.entry_date} · {dong.kind === "purchased" ? "Mua vào" : "Đã dùng"} · {dong.measure} {unit ?? "chưa có đơn vị"} · {dong.person_name}</p>
    {!mo ? <Button variant="outline" onClick={() => { form.reset({ measure: dong.measure, reason: "" }); setMo(true); }}>Sửa</Button> :
      <FormMenu {...loi} form={form} ten="Sửa con số" nut="Lưu con số" cacO={["measure", "reason"]} gui={luu.mutateAsync}
        dong={() => setMo(false)} daLuu={() => { bao("Đã sửa con số."); setMo(false); }}>
        <OMenu form={form} o="measure" nhan="Con số" /><p>Dùng dấu chấm, tối đa 3 chữ số lẻ.</p>
        <OMenu form={form} o="reason" nhan="Lý do" />
      </FormMenu>}
  </li>;
}
function TrangThai({ query, daGhi }: { query: { isPending: boolean; isError: boolean; isFetching: boolean; fetchStatus: string; dataUpdatedAt: number }; daGhi: boolean }) {
  return <>
    {query.isPending && <p role="status">{query.fetchStatus === "paused" ? "Đang chờ kết nối." : "Đang đọc nguyên liệu…"}</p>}
    {query.isError && <p role="alert">Chưa đọc được dữ liệu. {query.dataUpdatedAt > 0 && `Đang hiện bản đọc trước, lúc ${new Date(query.dataUpdatedAt).toLocaleTimeString("vi-VN")}.`} {daGhi && "Đã ghi, chưa cập nhật được dữ liệu."}</p>}
    {!query.isPending && query.isFetching && <p role="status">Đang đọc lại…</p>}
  </>;
}
function So({ id }: { id: number }) {
  const query = useSoNguyenLieu(id);
  const [bao, setBao] = useState("");
  if (query.error?.kind === "rejected" && query.error.code === "supply_item_not_found") return <p role="alert">Không tìm thấy nguyên liệu này</p>;
  const thu = query.data;
  return <section aria-label="Sổ nguyên liệu" className="space-y-4 rounded-md border p-4">
    <TrangThai query={query} daGhi={!!bao} />
    <Button variant="outline" disabled={query.isFetching} onClick={() => void query.refetch()}>Đọc lại sổ</Button>
    {bao && <p role="status">{bao}</p>}
    {thu && <><h2 className="text-xl font-semibold">Sổ {thu.name}</h2>
      {thu.entries.length === 0 ? <p>Chưa ghi con số nào.</p> : <ul>{thu.entries.map((dong) => <Dong key={dong.supply_day_entry_id} dong={dong} unit={thu.purchase_unit} bao={setBao} />)}</ul>}
      <Ghi id={id} bao={setBao} />
    </>}
  </section>;
}
export function TrangNguyenLieu() {
  const query = useNguyenLieu();
  const router = useRouter();
  const params = useSearchParams();
  const thu = params.get("thu");
  // Chỉ đổi định danh URL sang kiểu ID của hợp đồng; con số ghi sổ luôn là chuỗi.
  const id = thu !== null && /^[1-9][0-9]*$/.test(thu) ? +thu : 0;
  const hopLe = id > 0 && id <= 9007199254740991;
  const [bao, setBao] = useState("");
  function mo(id?: number) {
    const next = new URLSearchParams(params.toString());
    if (id === undefined) next.delete("thu"); else next.set("thu", String(id));
    router.replace(`/chu-quan/nguyen-lieu${next.size ? `?${next}` : ""}`);
  }
  return <div className="mx-auto w-full max-w-4xl space-y-6 p-4 sm:p-6">
    <h1 className="text-2xl font-semibold">Nguyên liệu</h1>
    <TrangThai query={query} daGhi={!!bao} />
    <Button variant="outline" disabled={query.isFetching} onClick={() => void query.refetch()}>Đọc lại danh sách</Button>
    {bao && <p role="status">{bao}</p>}
    {query.data && <>
      {query.data.supply_items.length === 0 ? <p>Chưa có nguyên liệu nào.</p> : <ul aria-label="Danh mục nguyên liệu">{query.data.supply_items.map((item) =>
        <li key={item.supply_item_id} className="space-y-3 border-b py-3">
          <div className="flex flex-wrap items-center gap-3"><Button variant="link" onClick={() => mo(item.supply_item_id)}>{item.name}</Button><span>{item.purchase_unit ?? "Chưa có đơn vị"}</span></div>
          {item.purchase_unit === null && <DatDonVi thu={item} bao={setBao} />}
        </li>)}</ul>}
      <Them bao={setBao} />
    </>}
    {thu !== null && <><Button variant="outline" onClick={() => mo()}>Đóng sổ</Button>
      {hopLe ? <So key={id} id={id} /> : <p role="alert">Không tìm thấy nguyên liệu này</p>}
    </>}
  </div>;
}
