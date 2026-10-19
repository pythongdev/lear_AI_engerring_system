"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useId, useRef, useState } from "react";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { useNguoi, type Nguoi } from "./du-lieu-nhan-vien";
import { FormMenu, OMenu, chuMenu, soMenu } from "./form-menu";
import { daDoi, useViec, useTaoViec, useSuaViec, useAnViec, useDanhDau, loiGiaoViec, oLoiGiaoViec,
  type Viec, type TaoViec, type SuaViec, type AnViec } from "./du-lieu-giao-viec";

const taoSchema = z.object({ content: chuMenu, assignee_person_id: soMenu });
const suaSchema = taoSchema.extend({ reason: chuMenu });
const anSchema = z.object({ reason: chuMenu });
const loi = { loi: loiGiaoViec, oLoi: oLoiGiaoViec };
const luc = (iso: string | number) => new Date(iso).toLocaleString("vi-VN", { timeZone: "Asia/Ho_Chi_Minh" });
type Chung = { bao: (s: string) => void; nguoi: Nguoi[]; dong: () => void; daLuu: () => void };
const options = (nguoi: Nguoi[]) => nguoi.map((p) => ({ id: p.person_id, ten: p.display_name }));

function FormTao({ nguoi, dong, daLuu }: Chung) {
  const luu = useTaoViec();
  const form = useForm<TaoViec>({ resolver: zodResolver(taoSchema), defaultValues: { content: "" } });
  return <FormMenu form={form} ten="Giao việc mới" nut="Giao việc" gui={luu.mutateAsync} cacO={["content", "assignee_person_id"]}
    dong={dong} daLuu={daLuu} {...loi}>
    <OMenu form={form} o="content" nhan="Nội dung" />
    <OMenu form={form} o="assignee_person_id" nhan="Người nhận" options={options(nguoi)} />
  </FormMenu>;
}
function FormSua({ t, nguoi, dong, daLuu, bao }: Chung & { t: Viec }) {
  const luu = useSuaViec(t.assigned_task_id);
  const form = useForm<SuaViec>({ resolver: zodResolver(suaSchema), defaultValues: {
    content: t.content, assignee_person_id: t.assignee_person_id, reason: "",
  } });
  return <FormMenu form={form} ten={`Sửa ${t.content}`} nut="Lưu thay đổi" gui={async (body) => {
      const r = await luu.mutateAsync(body);
      if (!r.ok && daDoi(r.failure)) bao(loiGiaoViec(r.failure));
      return r;
    }}
    cacO={["content", "assignee_person_id", "reason"]} dong={dong} daLuu={daLuu} {...loi}>
    <OMenu form={form} o="content" nhan="Nội dung" />
    <OMenu form={form} o="assignee_person_id" nhan="Người nhận" options={options(nguoi)} />
    <OMenu form={form} o="reason" nhan="Lý do" />
  </FormMenu>;
}
function FormAn({ t, dong, daLuu, bao }: { bao: (s: string) => void; t: Viec; dong: () => void; daLuu: () => void }) {
  const luu = useAnViec(t.assigned_task_id);
  const form = useForm<AnViec>({ resolver: zodResolver(anSchema), defaultValues: { reason: "" } });
  return <FormMenu form={form} ten={`Xoá ${t.content}`} nut="Xác nhận xoá" gui={async (body) => {
      const r = await luu.mutateAsync(body);
      if (!r.ok && daDoi(r.failure)) bao(loiGiaoViec(r.failure));
      return r;
    }}
    cacO={["reason"]} dong={dong} daLuu={daLuu} {...loi}>
    <p>Việc sẽ biến khỏi danh sách, vết vẫn giữ.</p>
    <OMenu form={form} o="reason" nhan="Lý do" />
  </FormMenu>;
}
function TheViec({ t, nguoi, bao }: { t: Viec; nguoi: Nguoi[]; bao: (s: string) => void }) {
  const [sua, setSua] = useState<"sua" | "an" | null>(null);
  const danhDau = useDanhDau(t.assigned_task_id);
  const chot = useRef(false);
  const cuoi = t.marks.at(-1);
  const dong = () => setSua(null);
  async function danh() {
    if (chot.current) return;
    chot.current = true;
    try {
      const r = await danhDau.mutateAsync({ mark: t.done ? "undone" : "done" });
      bao(r.ok ? "Đã lưu đánh dấu." : loiGiaoViec(r.failure));
    } finally { chot.current = false; }
  }
  return <li className="space-y-3 border-b py-4 last:border-0">
    <h2 className="font-semibold">{t.content}</h2>
    <p>Người nhận: {t.assignee_name} · Người giao: {t.person_name} · Lúc giao: {luc(t.created_at)}</p>
    <p>{t.done ? "Đã xong" : "Chưa xong"}</p>
    {cuoi && <p>Đánh dấu gần nhất: {cuoi.person_name} · {luc(cuoi.created_at)}</p>}
    {!sua && <div className="flex flex-wrap gap-2">
      <Button variant="outline" disabled={danhDau.isPending} onClick={() => setSua("sua")} aria-label={`Sửa ${t.content}`}>Sửa</Button>
      <Button variant="outline" disabled={danhDau.isPending} onClick={() => void danh()}>{t.done ? "Bỏ đánh dấu xong" : "Đánh dấu xong"}</Button>
      <Button variant="outline" disabled={danhDau.isPending} onClick={() => setSua("an")} aria-label={`Xoá ${t.content}`}>Xoá việc</Button>
    </div>}
    {sua === "sua" && <FormSua bao={bao} t={t} nguoi={nguoi} dong={dong} daLuu={() => { bao("Đã sửa việc."); dong(); }} />}
    {sua === "an" && <FormAn bao={bao} t={t} dong={dong} daLuu={() => { bao("Đã xoá việc khỏi danh sách."); dong(); }} />}
  </li>;
}

export function TrangGiaoViec() {
  const params = useSearchParams();
  const router = useRouter();
  const pathname = usePathname();
  const raw = params.get("assignee_person_id");
  const assignee = raw && /^\d+$/.test(raw) && Number(raw) > 0 ? Number(raw) : undefined;
  const query = useViec(assignee);
  const nguoi = useNguoi();
  const [tao, setTao] = useState(false);
  const [thongBao, bao] = useState<string | null>(null);
  const id = useId();
  return <div className="mx-auto w-full max-w-4xl space-y-6 p-4 sm:p-6">
    <h1 className="text-2xl font-semibold">Giao việc</h1>
    <label htmlFor={id}>Lọc người nhận</label>
    <select id={id} value={assignee ?? ""} className="h-9 rounded-md border bg-background px-3" onChange={(e) => {
      const next = new URLSearchParams(params.toString());
      if (e.target.value) next.set("assignee_person_id", e.target.value); else next.delete("assignee_person_id");
      router.replace(`${pathname}${next.size ? `?${next}` : ""}`, { scroll: false });
    }}>
      <option value="">Mọi người</option>
      {(nguoi.data?.people ?? []).map((p) => <option key={p.person_id} value={p.person_id}>{p.display_name}</option>)}
    </select>
    {nguoi.isPending && <p role="status">Đang đọc danh sách người…</p>}
    {nguoi.isError && <Alert role="alert"><AlertDescription>Chưa đọc được danh sách người.
      {nguoi.data && ` Đang hiện bản đọc trước, lúc ${luc(nguoi.dataUpdatedAt)}.`}
    </AlertDescription></Alert>}
    <div className="flex gap-2">
      <Button variant="outline" disabled={query.isFetching || nguoi.isFetching}
        onClick={() => { void query.refetch(); void nguoi.refetch(); }}>Đọc lại danh sách</Button>
      {!tao && <Button onClick={() => setTao(true)}>Giao việc mới</Button>}
    </div>
    {tao && <FormTao bao={bao} nguoi={nguoi.data?.people ?? []} dong={() => setTao(false)} daLuu={() => { bao("Đã giao việc."); setTao(false); }} />}
    {thongBao && <p role="status">{thongBao}</p>}
    {query.isPending && <p role="status">{query.fetchStatus === "paused" ? "Đang chờ kết nối." : "Đang đọc danh sách việc…"}</p>}
    {query.isError && <Alert role="alert"><AlertDescription>Chưa đọc được danh sách việc.
      {query.data && ` Đang hiện bản đọc trước, lúc ${luc(query.dataUpdatedAt)}.`}
      {thongBao?.startsWith("Đã ") && " Đã ghi, chưa cập nhật được dữ liệu."}
    </AlertDescription></Alert>}
    {query.data && <Card><CardContent>
      {query.isFetching && <p role="status">Đang đọc lại danh sách việc…</p>}
      {query.data.assigned_tasks.length === 0 ? <p>Chưa có việc nào.</p> : <ul>{query.data.assigned_tasks.map((t) =>
        <TheViec key={t.assigned_task_id} t={t} nguoi={nguoi.data?.people ?? []} bao={bao} />)}</ul>}
    </CardContent></Card>}
  </div>;
}
