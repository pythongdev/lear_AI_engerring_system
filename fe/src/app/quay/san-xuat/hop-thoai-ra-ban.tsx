"use client";
// Ra bàn theo bàn hay đơn không bàn (P4-09, lời S-5): POS nhập số cái từng thứ; item là khoá gom của bảng.
import { useId, useRef, useState, type FormEvent } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { LoaderCircle } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogTitle, DialogDescription, DialogTrigger } from "@/components/ui/dialog";
import { Field, FieldLabel, FieldError } from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import { call } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import { khoaHang, type HangSanXuat, type PhanSanXuat } from "@/components/shared/du-lieu-san-xuat";
import { loiRaBan } from "./du-lieu-ra-ban";

const schema = z.object({ so: z.array(z.string().refine((v) => v === "" ||
  (/^\d+$/.test(v) && Number.isSafeInteger(Number(v)) && Number(v) >= 1), "Nhập số nguyên từ 1 trở lên.")) });
export function HopThoaiRaBan({ phan, ten, hang, tenHang, bao, docLai }: {
  phan: PhanSanXuat; ten: string; hang: HangSanXuat[]; tenHang: (h: HangSanXuat) => string;
  bao: (s: string) => void; docLai: () => Promise<boolean>;
}) {
  const api = useApi();
  const id = useId();
  const chot = useRef(false);
  const [mo, setMo] = useState(false);
  // Giữ các khoá của biểu mẫu đang nhập khi bảng tự đọc lại.
  const [hangNhap, setHangNhap] = useState(hang);
  const [loi, setLoi] = useState<string | null>(null);
  const form = useForm<{ so: string[] }>({ resolver: zodResolver(schema), defaultValues: { so: [] } });
  const ban = form.formState.isSubmitting;
  async function gui(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    if (chot.current) return;
    chot.current = true;
    setLoi(null);
    try {
      await form.handleSubmit(async ({ so }) => {
        const items = hangNhap.flatMap((h, i) => so[i] ? [{ station_code: h.station_code,
          menu_component_id: h.menu_component_id, filling_option_ids: h.filling_option_ids, quantity: Number(so[i]) }] : []);
        if (!items.length) { setLoi("Nhập số cái của ít nhất một thứ."); return; }
        const r = await call(api.POST("/served-marks", { body: {
          ...(phan.dining_table_id !== null ? { dining_table_id: phan.dining_table_id } : { sales_order_id: phan.sales_order_id! }), items,
        } }));
        if (r.ok) {
          setMo(false);
          bao(`Đã ghi ra bàn ${ten}.`);
          if (!await docLai()) bao(`Đã ghi ra bàn ${ten}. Đã lưu nhưng chưa đọc lại được. Đang hiện bản đọc trước.`);
        } else {
          const message = loiRaBan(r.failure);
          setLoi(message);
          if (r.failure.kind === "rejected") {
            const match = /^items\[(\d+)\]\.quantity$/.exec(r.failure.field ?? "");
            if (match && Number(match[1]) < hangNhap.length) form.setError(`so.${Number(match[1])}`, { message });
            if (r.failure.code === "served_quantity_exceeds_made" || r.failure.code.endsWith("_not_found")) await docLai();
          }
        }
      })(e);
    } finally { chot.current = false; }
  }
  return <Dialog open={mo} onOpenChange={(open) => {
    if (chot.current) return;
    if (open) { setHangNhap(hang); form.reset({ so: hang.map(() => "") }); setLoi(null); }
    setMo(open);
  }}>
    <DialogTrigger asChild><Button variant="outline" className="min-h-11">Ra bàn {ten}</Button></DialogTrigger>
    <DialogContent showCloseButton={false} className="max-h-[90vh] overflow-y-auto">
      <DialogTitle>Ra bàn {ten}</DialogTitle><DialogDescription>Nhập số cái vừa ra bàn của từng thứ. Để trống thứ chưa ghi.</DialogDescription>
      <form onSubmit={gui} noValidate className="space-y-4">
        <fieldset disabled={ban} className="space-y-3">{hangNhap.map((h, i) => {
          const error = form.formState.errors.so?.[i]?.message;
          return <Field key={khoaHang(h)} data-invalid={!!error}>
            <FieldLabel htmlFor={`${id}-${i}`}>Số cái {tenHang(h)}</FieldLabel>
            <Input id={`${id}-${i}`} inputMode="numeric" aria-invalid={!!error} aria-describedby={error ? `${id}-${i}-loi` : undefined} {...form.register(`so.${i}`)} />
            {error && <FieldError id={`${id}-${i}-loi`}>{error}</FieldError>}
          </Field>;
        })}</fieldset>
        {loi && <p role="alert">{loi}</p>}
        <div className="flex gap-2"><Button type="submit" disabled={ban} className="min-h-11">{ban && <LoaderCircle aria-hidden className="animate-spin" />}{ban ? "Đang lưu…" : "Ghi ra bàn"}</Button>
          <Button type="button" variant="outline" disabled={ban} className="min-h-11" onClick={() => setMo(false)}>Huỷ</Button></div>
      </form>
    </DialogContent>
  </Dialog>;
}
