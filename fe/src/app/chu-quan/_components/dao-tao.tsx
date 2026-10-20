"use client";

import { useState } from "react";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { useNguoi } from "./du-lieu-nhan-vien";
import { useViec } from "./du-lieu-giao-viec";
import { useGhiNhan, useHuongDan, useAnGhiNhan, useAnHuongDan, type K } from "./du-lieu-dao-tao";
import { ThemGhiNhan, SuaGhiNhan, AnDaoTao, GanHuongDan, SuaHuongDan, type Bao } from "./dao-tao-form";

const luc = (iso: string | number) => new Date(iso).toLocaleString("vi-VN", { timeZone: "Asia/Ho_Chi_Minh" });
const soDuong = (s: string | null) => s !== null && /^\d+$/.test(s) && Number.isSafeInteger(Number(s)) && Number(s) > 0 ? Number(s) : undefined;
function TrangThai({ q, ten, daGhi = false }: { q: { isPending: boolean; isError: boolean; isFetching: boolean; fetchStatus: string; data: unknown; dataUpdatedAt: number }; ten: string; daGhi?: boolean }) {
  return <>
    {q.isPending && <p role="status">{q.fetchStatus === "paused" ? "Đang chờ kết nối." : `Đang đọc ${ten}…`}</p>}
    {q.isFetching && !q.isPending && <p role="status">Đang đọc lại {ten}…</p>}
    {q.isError && <Alert role="alert"><AlertDescription>Chưa đọc được {ten}.
      {q.data !== undefined && ` Đang hiện bản đọc trước, lúc ${luc(q.dataUpdatedAt)}.`}
      {daGhi && " Đã ghi, chưa cập nhật được dữ liệu."}
    </AlertDescription></Alert>}
  </>;
}
function GhiNhan({ t, bao }: { t: K["TrainingRecord"]; bao: Bao }) {
  const [mo, setMo] = useState<"sua" | "an" | null>(null);
  const an = useAnGhiNhan(t.training_record_id);
  const dong = () => setMo(null);
  return <li className="space-y-3 border-b py-4">
    <h3 className="font-semibold">{t.trainee_name}</h3>
    <p className="whitespace-pre-wrap">{t.remark ?? "—"}</p>
    <p>{t.rating === "pass" ? "Làm được" : t.rating === "not_yet" ? "Chưa làm được" : "Chưa đánh giá"}</p>
    <p>Người ghi: {t.person_name} · Lúc ghi: {luc(t.created_at)}</p>
    {t.hidden_at ? <p>Đã ẩn bởi {t.hidden_by_name}</p> : <>
      {!mo && <div className="flex gap-2"><Button variant="outline" aria-label={`Sửa ghi nhận ${t.training_record_id}`} onClick={() => setMo("sua")}>Sửa</Button>
        <Button variant="outline" aria-label={`Ẩn ghi nhận ${t.training_record_id}`} onClick={() => setMo("an")}>Ẩn</Button></div>}
      {mo === "sua" && <SuaGhiNhan t={t} bao={bao} dong={dong} />}
      {mo === "an" && <AnDaoTao ten={`Ẩn ghi nhận ${t.training_record_id}`} gui={an.mutateAsync} bao={bao} dong={dong} />}
    </>}
  </li>;
}
function HuongDan({ t, bao }: { t: K["AssignedTaskGuide"]; bao: Bao }) {
  const [mo, setMo] = useState<"sua" | "an" | null>(null);
  const an = useAnHuongDan(t.assigned_task_guide_id);
  const dong = () => setMo(null);
  const src = `/api/assigned-task-guides/${t.assigned_task_guide_id}/file`;
  return <li className="space-y-3 border-b py-4">
    {t.kind === "text" ? <p className="whitespace-pre-wrap">{t.body}</p> : t.kind === "image"
      // Tệp có cookie phiên, phát qua cùng origin; không qua bộ tối ưu ảnh của Next.
      // eslint-disable-next-line @next/next/no-img-element
      ? <img src={src} alt={`Hướng dẫn bằng ảnh do ${t.person_name} gắn cho việc ${t.assigned_task_id}`} className="max-h-96 max-w-full" />
      : <video controls src={src} aria-label={`Hướng dẫn bằng video do ${t.person_name} gắn`} className="max-h-96 max-w-full" />}
    <p>Người gắn: {t.person_name} · Lúc gắn: {luc(t.created_at)}</p>
    {t.hidden_at ? <p>Đã ẩn bởi {t.hidden_by_name}</p> : <>
      {!mo && <div className="flex gap-2">{t.kind === "text" && <Button variant="outline" aria-label={`Sửa hướng dẫn ${t.assigned_task_guide_id}`} onClick={() => setMo("sua")}>Sửa</Button>}
        <Button variant="outline" aria-label={`Ẩn hướng dẫn ${t.assigned_task_guide_id}`} onClick={() => setMo("an")}>Ẩn</Button></div>}
      {mo === "sua" && t.kind === "text" && <SuaHuongDan t={t} bao={bao} dong={dong} />}
      {mo === "an" && <AnDaoTao ten={`Ẩn hướng dẫn ${t.assigned_task_guide_id}`} gui={an.mutateAsync} bao={bao} dong={dong} />}
    </>}
  </li>;
}
function DanhSachHuongDan({ viec, an }: { viec: number; an: boolean }) {
  const q = useHuongDan(viec, an);
  const [thongBao, bao] = useState("");
  const khongCo = q.error?.kind === "rejected" && q.error.code === "assigned_task_not_found";
  return <div className="space-y-4">
    <Button variant="outline" disabled={q.isFetching} onClick={() => void q.refetch()}>Đọc lại hướng dẫn</Button>
    {thongBao && <p role="status">{thongBao}</p>}
    {khongCo ? <p role="alert">Không tìm thấy việc này</p> : <>
      <TrangThai q={q} ten="hướng dẫn" daGhi={thongBao.startsWith("Đã ")} />
      {q.data && (q.data.guides.length === 0 ? <p>Việc này chưa có hướng dẫn.</p> : <ul aria-label="Danh sách hướng dẫn">{q.data.guides.map((t) => <HuongDan key={t.assigned_task_guide_id} t={t} bao={bao} />)}</ul>)}
      <GanHuongDan viec={viec} bao={bao} />
    </>}
  </div>;
}
export function TrangDaoTao() {
  const params = useSearchParams();
  const router = useRouter();
  const nguoi = soDuong(params.get("nguoi"));
  const an = params.get("an") === "1";
  const rawViec = params.get("viec");
  const viec = soDuong(rawViec);
  const anHD = params.get("an-hd") === "1";
  const q = useGhiNhan(nguoi, an);
  const people = useNguoi();
  const tasks = useViec();
  const [thongBao, bao] = useState("");
  // T-212: cùng trang chạy ở /chu-quan/dao-tao và /quay/dao-tao — giữ đường dẫn đang mở.
  const pathname = usePathname();
  function doi(key: string, value: string) {
    const next = new URLSearchParams(params.toString());
    if (value) next.set(key, value); else next.delete(key);
    router.replace(`${pathname}${next.size ? `?${next}` : ""}`, { scroll: false });
  }
  return <div className="mx-auto w-full max-w-4xl space-y-8 p-4 sm:p-6">
    <h1 className="text-2xl font-semibold">Đào tạo</h1>
    <section aria-label="Ghi nhận đào tạo" className="space-y-4">
      <h2 className="text-xl font-semibold">Ghi nhận đào tạo</h2>
      <label className="block">Lọc người <select value={nguoi ?? ""} onChange={(e) => doi("nguoi", e.target.value)} className="rounded-md border bg-background p-2">
        <option value="">Mọi người</option>{(people.data?.people ?? []).map((p) => <option key={p.person_id} value={p.person_id}>{p.display_name}</option>)}
      </select></label>
      <label className="block"><input type="checkbox" checked={an} onChange={(e) => doi("an", e.target.checked ? "1" : "")} /> Kèm ghi nhận đã ẩn</label>
      <TrangThai q={people} ten="danh sách người" />
      <Button variant="outline" disabled={q.isFetching || people.isFetching} onClick={() => { void q.refetch(); void people.refetch(); }}>Đọc lại ghi nhận</Button>
      {thongBao && <p role="status">{thongBao}</p>}
      <TrangThai q={q} ten="ghi nhận" daGhi={thongBao.startsWith("Đã ")} />
      {q.data && (q.data.training_records.length === 0 ? <p>Chưa có ghi nhận nào.</p> : <ul aria-label="Danh sách ghi nhận">{q.data.training_records.map((t) => <GhiNhan key={t.training_record_id} t={t} bao={bao} />)}</ul>)}
      <ThemGhiNhan nguoi={people.data?.people ?? []} bao={bao} />
    </section>
    <section aria-label="Hướng dẫn theo việc" className="space-y-4">
      <h2 className="text-xl font-semibold">Hướng dẫn theo việc</h2>
      <TrangThai q={tasks} ten="danh sách việc" />
      <Button variant="outline" disabled={tasks.isFetching} onClick={() => void tasks.refetch()}>Đọc lại danh sách việc</Button>
      <label className="block">Việc được giao <select value={viec ?? ""} onChange={(e) => doi("viec", e.target.value)} className="max-w-full rounded-md border bg-background p-2">
        <option value="">Chọn việc</option>
        {viec && !tasks.data?.assigned_tasks.some((t) => t.assigned_task_id === viec) && <option value={viec}>Việc {viec}</option>}
        {(tasks.data?.assigned_tasks ?? []).map((t) => <option key={t.assigned_task_id} value={t.assigned_task_id}>{t.content} — {t.assignee_name}</option>)}
      </select></label>
      <label className="block"><input type="checkbox" checked={anHD} onChange={(e) => doi("an-hd", e.target.checked ? "1" : "")} /> Kèm hướng dẫn đã ẩn</label>
      {rawViec === null ? <p>Chọn một việc để xem hướng dẫn.</p> : viec === undefined ? <p role="alert">Không tìm thấy việc này</p>
        : <DanhSachHuongDan key={viec} viec={viec} an={anHD} />}
    </section>
  </div>;
}
