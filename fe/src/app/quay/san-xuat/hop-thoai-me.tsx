"use client";
import { useId, useRef, useState, type FormEvent } from "react";
import { useQuery } from "@tanstack/react-query";
import { LoaderCircle } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { Dialog, DialogContent, DialogTitle, DialogDescription, DialogTrigger } from "@/components/ui/dialog";
import { Field, FieldLabel, FieldError } from "@/components/ui/field";
import { call, type ApiResult } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import { canDocLai, loiMe, type ViecTram } from "./du-lieu-me";

type ThaoTac = { loai: "bam"; viec: ViecTram[] } | { loai: "lui" | "chuyen" | "sai"; id: number };
type NhanViec = { station_job_id: number; dining_table_id: number | null; sales_order_id: number };
export function HopThoaiMe({ thaoTac, ten, disabled, nhan, bao, docLai }: {
  thaoTac: ThaoTac; ten: string; disabled?: boolean; nhan: (v: NhanViec) => string;
  bao: (s: string) => void; docLai: () => Promise<boolean>;
}) {
  const api = useApi(), idO = useId();
  const chot = useRef(false);
  const [mo, setMo] = useState(false), [ban, setBan] = useState(false);
  const [loi, setLoi] = useState<string | null>(null), [loiO, setLoiO] = useState<string | null>(null);
  const [chon, setChon] = useState<number[]>([]), [note, setNote] = useState("");
  const [viecNhap, setViecNhap] = useState<ViecTram[]>([]);
  const nguon = thaoTac.loai === "chuyen" ? thaoTac.id : null;
  const ungVien = useQuery({ queryKey: ["station-jobs", nguon, "transfer-candidates"], enabled: mo && nguon !== null,
    retry: false, staleTime: 0, queryFn: async () => {
      const r = await call(api.GET("/station-jobs/{id}/transfer-candidates", { params: { path: { id: nguon! } } }));
      if (!r.ok) throw r.failure;
      return r.data;
    } });
  const nut = { bam: "Ghi mẻ", lui: "Xác nhận lùi mẻ", chuyen: "Chuyển", sai: "Ghi làm sai" }[thaoTac.loai];
  async function gui(e: FormEvent) {
    e.preventDefault();
    if (chot.current) return;
    setLoi(null); setLoiO(null);
    if (thaoTac.loai === "bam" && !chon.length) { setLoi("Chọn ít nhất một việc."); return; }
    if (thaoTac.loai === "chuyen") {
      if (ungVien.isError || ungVien.isFetching || !ungVien.data?.candidates.length) return;
      if (!chon.length) { setLoi("Chọn việc nhận."); return; }
    }
    if (thaoTac.loai === "sai" && note !== "" && !note.trim()) { setLoiO("Ghi chú phải có chữ hoặc để trống."); return; }
    chot.current = true; setBan(true);
    try {
      let r: ApiResult<unknown>, thanhCong: string;
      switch (thaoTac.loai) {
        case "bam": {
          const kq = await call(api.POST("/production-batches", { body: { station_job_ids: [...chon].sort((a, b) => a - b) } }));
          r = kq; thanhCong = kq.ok ? `Đã ghi mẻ ${kq.data.production_batch_id}.` : ""; break;
        }
        case "lui":
          r = await call(api.POST("/production-batches/{id}/rollback", { params: { path: { id: thaoTac.id } } }));
          thanhCong = `Đã lùi mẻ ${thaoTac.id}.`; break;
        case "chuyen":
          r = await call(api.POST("/station-job-transfers", { body: { transfers: [{ from_station_job_id: thaoTac.id, to_station_job_id: chon[0] }] } }));
          thanhCong = `Đã chuyển việc ${thaoTac.id} sang việc ${chon[0]}.`; break;
        case "sai":
          r = await call(api.POST("/wrong-make-notes", { body: { station_job_id: thaoTac.id, ...(note !== "" ? { note } : {}) } }));
          thanhCong = `Đã ghi làm sai việc ${thaoTac.id}.`; break;
      }
      if (r.ok) {
        setMo(false); bao(thanhCong);
        if (!await docLai()) bao(`${thanhCong} Đã lưu nhưng chưa đọc lại được.`);
      } else {
        const chu = loiMe(r.failure); setLoi(chu);
        if (r.failure.kind === "rejected" && r.failure.field === "note") setLoiO(chu);
        if (canDocLai(r.failure)) await docLai();
      }
    } finally { chot.current = false; setBan(false); }
  }
  return <Dialog open={mo} onOpenChange={(open) => {
    if (chot.current) return;
    if (open) { setChon([]); setNote(""); setLoi(null); setLoiO(null); setViecNhap(thaoTac.loai === "bam" ? thaoTac.viec : []); }
    setMo(open);
  }}>
    <DialogTrigger asChild><Button variant="outline" className="min-h-11" disabled={disabled}>{ten}</Button></DialogTrigger>
    <DialogContent showCloseButton={false} className="max-h-[90vh] overflow-y-auto">
      <DialogTitle>{ten}</DialogTitle><DialogDescription>{thaoTac.loai === "lui" ? "Xác nhận lùi toàn bộ mẻ này về chờ làm." : "Kiểm tra việc trước khi ghi."}</DialogDescription>
      <form onSubmit={gui} noValidate className="space-y-4">
        <fieldset disabled={ban} className="space-y-3">
          {thaoTac.loai === "bam" && viecNhap.map((v) => <Field key={v.station_job_id} orientation="horizontal">
            <Checkbox id={`${idO}-${v.station_job_id}`} checked={chon.includes(v.station_job_id)} disabled={ban}
              onCheckedChange={(checked) => setChon((cu) => checked === true ? [...cu, v.station_job_id] : cu.filter((id) => id !== v.station_job_id))} />
            <FieldLabel htmlFor={`${idO}-${v.station_job_id}`}>{nhan(v)}</FieldLabel>
          </Field>)}
          {thaoTac.loai === "chuyen" && <>
            {ungVien.isPending && <p role="status">Đang tải việc nhận…</p>}
            {ungVien.isError && <p role="alert">{loiMe(ungVien.error as unknown as import("@/lib/api/client").ApiFailure)}</p>}
            {!ungVien.isError && ungVien.data?.candidates.length === 0 && <p>Không có việc nào đang chờ để nhận.</p>}
            {!ungVien.isError && ungVien.data?.candidates.map((v) => <Field key={v.station_job_id} orientation="horizontal">
              <input type="radio" name={idO} id={`${idO}-${v.station_job_id}`} checked={chon[0] === v.station_job_id} onChange={() => setChon([v.station_job_id])} />
              <FieldLabel htmlFor={`${idO}-${v.station_job_id}`}>{nhan(v)}</FieldLabel>
            </Field>)}
          </>}
          {thaoTac.loai === "sai" && <Field data-invalid={!!loiO}>
            <FieldLabel htmlFor={idO}>Ghi chú (không bắt buộc)</FieldLabel>
            <textarea id={idO} className="min-h-24 rounded-md border p-3" value={note} onChange={(e) => setNote(e.target.value)} aria-invalid={!!loiO} aria-describedby={loiO ? `${idO}-loi` : undefined} />
            {loiO && <FieldError id={`${idO}-loi`}>{loiO}</FieldError>}
          </Field>}
        </fieldset>
        {loi && <p role="alert">{loi}</p>}
        <div className="flex gap-2"><Button type="submit" className="min-h-11" disabled={ban || (thaoTac.loai === "chuyen" && (ungVien.isFetching || ungVien.isError || !ungVien.data?.candidates.length))}>
          {ban && <LoaderCircle aria-hidden className="animate-spin" />}{ban ? "Đang lưu…" : nut}</Button>
          <Button type="button" variant="outline" className="min-h-11" disabled={ban} onClick={() => setMo(false)}>Huỷ</Button></div>
      </form>
    </DialogContent>
  </Dialog>;
}
