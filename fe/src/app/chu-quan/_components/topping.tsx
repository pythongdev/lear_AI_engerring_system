"use client";

// Trang Topping (T-210, master_plan/shop-facts.md §8.9 *QUẢN LÝ TOPPING*): thêm lựa chọn vào nhóm có sẵn — phụ thu là mức
// cho MỖI phần nhận nhân, máy nhân theo suất — tích nhóm mà lựa chọn mở (như Lượng nhân); ẩn · bật lại có lý do.
// Màn không tính giá, không gieo sẵn lựa chọn; mọi con số là chuỗi backend trả.
import { zodResolver } from "@hookform/resolvers/zod";
import { useId, useState } from "react";
import { useForm, useWatch } from "react-hook-form";
import { z } from "zod";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { FormMenu, OMenu, chuMenu } from "./form-menu";
import { tienMenu } from "./du-lieu-danh-muc-combo";
import { useTopping, useThemLuaChon, useAnLuaChon, loiTopping, oLoiTopping, type NhomTopping, type LuaChonTopping } from "./du-lieu-topping";

type Bao = (message: string) => void;
const themSchema = z.object({
  name: chuMenu,
  surcharge_vnd: z.number({ error: "Nhập số đồng, từ 0 trở lên." }).int("Nhập số nguyên.").min(0, "Nhập số từ 0 trở lên."),
  enables_option_group_ids: z.array(z.number()),
});
const lyDoSchema = z.object({ reason: chuMenu });

function FormThemLuaChon({ nhom, nhomKhac, bao }: { nhom: NhomTopping; nhomKhac: NhomTopping[]; bao: Bao }) {
  const luu = useThemLuaChon(nhom.option_group_id);
  const form = useForm<{ name: string; surcharge_vnd: number; enables_option_group_ids: number[] }>({
    resolver: zodResolver(themSchema), defaultValues: { name: "", surcharge_vnd: NaN, enables_option_group_ids: [] } });
  const mo = useWatch({ control: form.control, name: "enables_option_group_ids" });
  return <FormMenu form={form} ten={`Thêm lựa chọn vào ${nhom.name}`} nut="Thêm lựa chọn" gui={luu.mutateAsync}
    cacO={["name", "surcharge_vnd", "enables_option_group_ids"]} loi={loiTopping} oLoi={oLoiTopping}
    daLuu={(data) => { form.reset({ name: "", surcharge_vnd: NaN, enables_option_group_ids: [] }); bao(`Đã thêm ${data.name} vào ${nhom.name}.`); }}>
    <OMenu form={form} o="name" nhan="Tên lựa chọn" />
    <OMenu form={form} o="surcharge_vnd" nhan="Phụ thu mỗi phần nhận nhân (đồng)" so />
    {nhomKhac.length > 0 && <fieldset className="space-y-2">
      <legend className="text-sm font-medium">Lựa chọn này cho chọn thêm</legend>
      {nhomKhac.map((g) => <label key={g.option_group_id} className="flex items-center gap-2">
        <input type="checkbox" checked={mo.includes(g.option_group_id)} onChange={(e) => form.setValue("enables_option_group_ids",
          e.target.checked ? [...mo, g.option_group_id] : mo.filter((x) => x !== g.option_group_id))} />
        {g.name}
      </label>)}
    </fieldset>}
  </FormMenu>;
}
function FormLyDo({ luaChon, an, dong, bao }: { luaChon: LuaChonTopping; an: boolean; dong: () => void; bao: Bao }) {
  const luu = useAnLuaChon(luaChon.menu_option_id, an);
  const form = useForm<{ reason: string }>({ resolver: zodResolver(lyDoSchema), defaultValues: { reason: "" } });
  return <FormMenu form={form} ten={`${an ? "Ẩn" : "Bật lại"} ${luaChon.name}`} nut={an ? "Xác nhận ẩn" : "Xác nhận bật lại"}
    gui={luu.mutateAsync} cacO={["reason"]} loi={loiTopping} oLoi={oLoiTopping} dong={dong}
    daLuu={() => { bao(an ? `Đã ẩn ${luaChon.name}.` : `Đã bật lại ${luaChon.name}.`); dong(); }}>
    {an && <p>Khách không chọn được lựa chọn này nữa; đơn cũ giữ nguyên.</p>}
    <OMenu form={form} o="reason" nhan="Lý do" />
  </FormMenu>;
}
function DongLuaChon({ o, moNhom, bao }: { o: LuaChonTopping; moNhom: string[]; bao: Bao }) {
  const [sua, setSua] = useState(false);
  const an = o.hidden_at === null;
  return <li className="space-y-2 border-b py-3 last:border-0">
    <div className="flex flex-wrap items-center justify-between gap-3">
      <span>
        {o.name} · +{tienMenu(o.surcharge_vnd)} mỗi phần nhận nhân
        {o.is_default && <span className="ml-2 text-sm text-muted-foreground">Mặc định</span>}
        {!an && <span className="ml-2 text-sm text-muted-foreground">Đã ẩn</span>}
        {moNhom.length > 0 && <span className="ml-2 text-sm text-muted-foreground">Cho chọn {moNhom.join(", ")}</span>}
      </span>
      {!sua && !(an && o.is_default) && <Button variant="outline" aria-label={`${an ? "Ẩn" : "Bật lại"} ${o.name}`}
        onClick={() => setSua(true)}>{an ? "Ẩn" : "Bật lại"}</Button>}
    </div>
    {sua && <FormLyDo luaChon={o} an={an} dong={() => setSua(false)} bao={bao} />}
  </li>;
}
function KhoiNhom({ nhom, tatCa, bao }: { nhom: NhomTopping; tatCa: NhomTopping[]; bao: Bao }) {
  const id = useId();
  const moNhom = (o: LuaChonTopping) => tatCa.filter((g) => g.prerequisite_option_ids.includes(o.menu_option_id)).map((g) => g.name);
  return <section aria-labelledby={id}><Card>
    <CardHeader><CardTitle><h2 id={id}>{nhom.name}</h2></CardTitle></CardHeader>
    <CardContent className="space-y-4">
      {nhom.options.length === 0 ? <p>Chưa có lựa chọn.</p>
        : <ul>{nhom.options.map((o) => <DongLuaChon key={o.menu_option_id} o={o} moNhom={moNhom(o)} bao={bao} />)}</ul>}
      <FormThemLuaChon nhom={nhom} nhomKhac={tatCa.filter((g) => g.option_group_id !== nhom.option_group_id)} bao={bao} />
    </CardContent>
  </Card></section>;
}
export function TrangTopping() {
  const query = useTopping();
  const data = query.data;
  const [thongBao, bao] = useState<string | null>(null);
  return <div className="mx-auto w-full max-w-4xl space-y-6 p-4 sm:p-6">
    <h1 className="text-2xl font-semibold">Topping</h1>
    <p className="text-sm text-muted-foreground">Phụ thu là mức cho mỗi phần nhận nhân; máy tự nhân theo suất.</p>
    {query.isPending && <p role="status">{query.fetchStatus === "paused" ? "Đang chờ kết nối." : "Đang đọc topping…"}</p>}
    {query.isError && <Alert role="alert"><AlertDescription>Chưa đọc được topping.
      {data ? ` Đang hiện bản đọc trước, lúc ${new Date(query.dataUpdatedAt).toLocaleTimeString("vi-VN")}.` : " Hãy thử lại."}
    </AlertDescription></Alert>}
    <Button variant="outline" disabled={query.isFetching} onClick={() => void query.refetch()}>Đọc lại danh sách</Button>
    {thongBao && <p role="status">{thongBao}</p>}
    {data && <>
      {data.option_groups.length === 0 && <p>Chưa có nhóm tuỳ chọn.</p>}
      {data.option_groups.map((g) => <KhoiNhom key={g.option_group_id} nhom={g} tatCa={data.option_groups} bao={bao} />)}
    </>}
  </div>;
}
