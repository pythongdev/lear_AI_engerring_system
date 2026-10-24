"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useId, useRef, useState, type ReactNode } from "react";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import { useForm, type UseFormRegisterReturn } from "react-hook-form";
import { z } from "zod";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogTitle, DialogDescription, DialogTrigger } from "@/components/ui/dialog";
import { Plus, RotateCw } from "lucide-react";
import "./giao-viec.css";
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

function HopThoai({ mo, dong, ten, children, nut }: { mo: boolean; dong: () => void; ten: string; children: ReactNode; nut: ReactNode }) {
  return <Dialog open={mo} onOpenChange={(open) => { if (!open) dong(); }}>
    <DialogTrigger asChild>{nut}</DialogTrigger>
    <DialogContent className="gv-dialog" showCloseButton={false}>
      <div><p className="gv-eyebrow">GIAO VIỆC</p><DialogTitle>{ten}</DialogTitle></div>
      <DialogDescription>Ghi rõ việc cần làm và chọn người nhận.</DialogDescription>
      {children}
    </DialogContent>
  </Dialog>;
}
function NoiDung({ o, error }: { o: UseFormRegisterReturn<"content">; error?: string }) {
  const id = useId();
  return <div className="gv-content-field"><label htmlFor={id}>Nội dung</label>
    <textarea id={id} {...o} placeholder="Ví dụ: Chuẩn bị bàn ghế trước giờ mở cửa"
      aria-invalid={!!error} aria-describedby={error ? `${id}-loi` : undefined} />
    {error && <p id={`${id}-loi`} className="text-destructive">{error}</p>}
  </div>;
}
function FormTao({ nguoi, dong, daLuu }: Chung) {
  const luu = useTaoViec();
  const form = useForm<TaoViec>({ resolver: zodResolver(taoSchema), defaultValues: { content: "" } });
  return <FormMenu form={form} ten="Giao việc mới" nut="Giao việc" gui={luu.mutateAsync} cacO={["content", "assignee_person_id"]}
    dong={dong} daLuu={daLuu} {...loi}>
    <NoiDung o={form.register("content")} error={form.formState.errors.content?.message} />
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
    <NoiDung o={form.register("content")} error={form.formState.errors.content?.message} />
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
  return <li className="gv-task">
    <div className="gv-task-title"><h2>{t.content}</h2><small>CV-{String(t.assigned_task_id).padStart(3, "0")}</small></div>
    <p className="gv-person"><span className="gv-avatar" aria-hidden="true">{t.assignee_name.split(" ").filter(Boolean).map((n) => n[0]).slice(-2).join("")}</span><span><span className="gv-mobile-label">Người nhận: </span>{t.assignee_name}</span><span className="sr-only"> · </span></p>
    <p><span className="gv-mobile-label">Người giao: </span>{t.person_name}<span className="sr-only"> · </span></p>
    <p><span className="gv-mobile-label">Lúc giao: </span>{luc(t.created_at)}</p>
    <p><span className={`gv-badge ${t.done ? "" : "gv-pending"}`}>{t.done ? "Đã xong" : "Chưa xong"}</span></p>
    <p className="gv-last-mark">{cuoi ? <>Đánh dấu gần nhất: {cuoi.person_name} · {luc(cuoi.created_at)}</> : "—"}</p>
    <div className="gv-task-actions">
      <HopThoai mo={sua === "sua"} dong={dong} ten="Sửa công việc" nut={<Button variant="outline" disabled={danhDau.isPending} onClick={() => setSua("sua")} aria-label={`Sửa ${t.content}`}>Sửa</Button>}>
        <FormSua bao={bao} t={t} nguoi={nguoi} dong={dong} daLuu={() => { bao("Đã sửa việc."); dong(); }} />
      </HopThoai>
      <Button variant="outline" disabled={danhDau.isPending} onClick={() => void danh()}>{t.done ? "Bỏ đánh dấu xong" : "Đánh dấu xong"}</Button>
      <HopThoai mo={sua === "an"} dong={dong} ten="Xoá công việc" nut={<Button variant="outline" disabled={danhDau.isPending} onClick={() => setSua("an")} aria-label={`Xoá ${t.content}`}>Xoá việc</Button>}>
        <FormAn bao={bao} t={t} dong={dong} daLuu={() => { bao("Đã xoá việc khỏi danh sách."); dong(); }} />
      </HopThoai>
    </div>
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
  const [trangThai, setTrangThai] = useState("all");
  const [tim, setTim] = useState("");
  const tasks = query.data?.assigned_tasks ?? [];
  const shown = tasks.filter((t) => (trangThai === "all" || t.done === (trangThai === "done"))
    && t.content.toLocaleLowerCase("vi").includes(tim.trim().toLocaleLowerCase("vi")));
  const doneCount = tasks.filter((t) => t.done).length;
  return <div className="gv-page">
    <header className="gv-header"><div><p className="gv-eyebrow">CON NGƯỜI / GIAO VIỆC</p>
      <h1>Giao việc</h1><p className="gv-muted">Việc rõ ràng, cùng nhau hoàn thành.</p></div>
      <div className="gv-header-actions"><Button variant="outline" aria-label="Đọc lại danh sách" disabled={query.isFetching || nguoi.isFetching}
        onClick={() => { void query.refetch(); void nguoi.refetch(); }}><RotateCw aria-hidden="true" />Đọc lại</Button>
        <HopThoai mo={tao} dong={() => setTao(false)} ten="Thêm công việc" nut={<Button onClick={() => setTao(true)} aria-label="Giao việc mới"><Plus aria-hidden="true" />Thêm</Button>}>
          <FormTao bao={bao} nguoi={nguoi.data?.people ?? []} dong={() => setTao(false)} daLuu={() => { bao("Đã giao việc."); setTao(false); }} />
        </HopThoai>
      </div>
    </header>
    <section className="gv-overview" aria-label="Tóm tắt công việc">
      {[["Tổng công việc", tasks.length, assignee ? "Của người nhận đang chọn" : "Trong danh sách công việc"],
        ["Chưa xong", tasks.length - doneCount, "Cần tiếp tục thực hiện"],
        ["Đã xong", doneCount, "Đã được đánh dấu hoàn thành"]].map(([label, count, note], i) =>
        <article className={`gv-metric ${i === 1 ? "gv-attention" : ""}`} key={label}><h2>{label}</h2><strong>{query.data ? count : "—"}</strong><p>{note}</p></article>)}
    </section>
    <section className="gv-list" aria-labelledby={`${id}-title`}>
    <div className="gv-section-intro"><h2 id={`${id}-title`}>Danh sách công việc</h2><small>{query.data ? `${shown.length} công việc` : "Đang đọc…"}</small></div>
    <div className="gv-toolbar"><div className="gv-tabs" role="group" aria-label="Lọc trạng thái">
      {[["all", "Tất cả"], ["pending", "Chưa xong"], ["done", "Đã xong"]].map(([value, label]) =>
        <Button key={value} variant="outline" aria-pressed={trangThai === value} onClick={() => setTrangThai(value)}>{label}</Button>)}
    </div><div className="gv-filters"><input type="search" aria-label="Tìm nội dung công việc" placeholder="Tìm công việc…" value={tim} onChange={(e) => setTim(e.target.value)} />
    <label htmlFor={id} className="sr-only">Lọc người nhận</label>
    <select id={id} value={assignee ?? ""} className="h-9 rounded-md border bg-background px-3" onChange={(e) => {
      const next = new URLSearchParams(params.toString());
      if (e.target.value) next.set("assignee_person_id", e.target.value); else next.delete("assignee_person_id");
      router.replace(`${pathname}${next.size ? `?${next}` : ""}`, { scroll: false });
    }}>
      <option value="">Mọi người</option>
      {(nguoi.data?.people ?? []).map((p) => <option key={p.person_id} value={p.person_id}>{p.display_name}</option>)}
    </select></div></div>
    {nguoi.isPending && <p role="status">Đang đọc danh sách người…</p>}
    {nguoi.isError && <Alert role="alert"><AlertDescription>Chưa đọc được danh sách người.
      {nguoi.data && ` Đang hiện bản đọc trước, lúc ${luc(nguoi.dataUpdatedAt)}.`}
    </AlertDescription></Alert>}
    {thongBao && <p role="status">{thongBao}</p>}
    {query.isPending && <p role="status">{query.fetchStatus === "paused" ? "Đang chờ kết nối." : "Đang đọc danh sách việc…"}</p>}
    {query.isError && <Alert role="alert"><AlertDescription>Chưa đọc được danh sách việc.
      {query.data && ` Đang hiện bản đọc trước, lúc ${luc(query.dataUpdatedAt)}.`}
      {thongBao?.startsWith("Đã ") && " Đã ghi, chưa cập nhật được dữ liệu."}
    </AlertDescription></Alert>}
    {query.data && <>
      {query.isFetching && <p role="status">Đang đọc lại danh sách việc…</p>}
      {tasks.length === 0 ? <p className="gv-empty">Chưa có việc nào.</p> : shown.length === 0 ? <p className="gv-empty">Không có công việc phù hợp.</p> : <>
        <div className="gv-columns" aria-hidden="true"><span>Nội dung công việc</span><span>Người nhận</span><span>Người giao</span><span>Lúc giao</span><span>Trạng thái</span><span>Đánh dấu gần nhất</span><span>Thao tác</span></div>
        <ul aria-label="Công việc">{shown.map((t) => <TheViec key={t.assigned_task_id} t={t} nguoi={nguoi.data?.people ?? []} bao={bao} />)}</ul>
      </>}
    </>}
    </section>
  </div>;
}
