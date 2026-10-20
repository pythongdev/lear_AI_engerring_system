"use client";
// Khuôn hộp thoại sửa có lý do (P4-05): mở bằng nút, focus vào ô đầu và trả về nút khi đóng (Radix Dialog); lý do bắt buộc;
// lời từ chối có field gắn đúng ô; một lần bấm một lời gọi; ghi xong chỉ làm mất hiệu lực rồi đọc lại (ADR-102 điểm 2).
// Hợp đồng không có đường đọc giờ bán nên lời nhắc đổi thành phần suất luôn hiện (03-ham-gia.md §4, suy ra 2026-10-20).

import { useId, useRef, useState, type FormEvent } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { LoaderCircle } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogTitle, DialogDescription, DialogTrigger } from "@/components/ui/dialog";
import { Field, FieldLabel, FieldError } from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import { canDocLaiGia, loiMenuGia, useDocLaiMenuGia, useLenhGia, type LenhGia } from "./du-lieu-menu-gia";

const cauHinh = {
  gia: { dong: "Đổi giá gốc", o: "base_price_vnd", nhan: "Giá gốc mới (đồng)" },
  "phu-thu": { dong: "Đổi phụ thu", o: "surcharge_vnd", nhan: "Phụ thu mới (đồng)" },
  "so-luong": { dong: "Đổi số lượng", o: "quantity", nhan: "Số lượng mới" },
  ngung: { dong: "Ngừng bán", o: "", nhan: "" },
} as const;

export function HopThoaiSuaCoLyDo({ lenh, ten, hienTai, bao }: {
  lenh: LenhGia; ten: string; hienTai?: number; bao: (message: string) => void;
}) {
  const [mo, setMo] = useState(false);
  const [thongBao, setThongBao] = useState<string | null>(null);
  const chot = useRef(false);
  const id = useId();
  const ghi = useLenhGia();
  const docLai = useDocLaiMenuGia();
  const c = cauHinh[lenh.loai];
  const schema = z.object({
    so: z.string().refine((v) => lenh.loai === "ngung" ||
      (/^\d+$/.test(v) && Number.isSafeInteger(Number(v)) && Number(v) >= (lenh.loai === "so-luong" ? 1 : 0)), "Nhập số nguyên hợp lệ."),
    reason: z.string().trim().min(1, "Nhập lý do."),
  });
  const form = useForm<{ so: string; reason: string }>({ resolver: zodResolver(schema),
    defaultValues: { so: String(hienTai ?? ""), reason: "" } });
  const ban = form.formState.isSubmitting;
  async function gui(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    if (chot.current) return;
    chot.current = true;
    try {
      await form.handleSubmit(async ({ so, reason }) => {
        setThongBao(null);
        const r = await ghi(lenh, reason, Number(so));
        if (r.ok) {
          setMo(false);
          bao(`Đã ${c.dong.toLocaleLowerCase("vi-VN")} ${ten}.`);
          if (!await docLai(lenh.loai === "ngung")) bao("Đã lưu nhưng chưa đọc lại được. Đang hiện bản đọc trước; hãy đọc lại menu.");
        } else {
          const message = loiMenuGia(r.failure);
          const field = r.failure.kind === "rejected" ? r.failure.field : undefined;
          if (field === "reason") form.setError("reason", { message });
          else if (field && field === c.o) form.setError("so", { message });
          else setThongBao(message);
          if (canDocLaiGia(r.failure)) {
            setThongBao(message);
            await docLai(lenh.loai === "ngung");
          }
        }
      })(e);
    } finally { chot.current = false; }
  }
  return <Dialog open={mo} onOpenChange={(open) => {
    if (chot.current) return;
    if (open) { form.reset({ so: String(hienTai ?? ""), reason: "" }); setThongBao(null); }
    setMo(open);
  }}>
    <DialogTrigger asChild><Button variant="outline" className="min-h-11" aria-label={`${c.dong} ${ten}`}>{c.dong}</Button></DialogTrigger>
    <DialogContent showCloseButton={false}>
      <DialogTitle>{c.dong} {ten}</DialogTitle>
      <DialogDescription>{lenh.loai === "so-luong" ? "Nếu quán đang trong giờ bán, số lượng mới áp ngay cho các lượt gọi sau khi lưu; đơn đã đặt giữ số cũ." : "Nhập lý do cho thay đổi này."}</DialogDescription>
      <form onSubmit={gui} noValidate className="space-y-4">
        <fieldset disabled={ban} className="space-y-3">
          {([...(lenh.loai === "ngung" ? [] : [["so", c.nhan]]), ["reason", "Lý do"]] as ["so" | "reason", string][]).map(([o, nhan]) => {
            const loi = form.formState.errors[o]?.message;
            return <Field key={o} data-invalid={!!loi}>
              <FieldLabel htmlFor={`${id}-${o}`}>{nhan}</FieldLabel>
              <Input id={`${id}-${o}`} inputMode={o === "so" ? "numeric" : undefined} aria-invalid={!!loi}
                aria-describedby={loi ? `${id}-${o}-loi` : undefined} {...form.register(o)} />
              {loi && <FieldError id={`${id}-${o}-loi`}>{loi}</FieldError>}
            </Field>;
          })}
        </fieldset>
        {thongBao && <p role="alert">{thongBao}</p>}
        <div className="flex gap-2">
          <Button type="submit" disabled={ban} className="min-h-11">{ban && <LoaderCircle aria-hidden className="animate-spin" />}{ban ? "Đang lưu…" : lenh.loai === "ngung" ? "Ngừng bán" : "Lưu"}</Button>
          <Button type="button" variant="outline" disabled={ban} className="min-h-11" onClick={() => setMo(false)}>Huỷ</Button>
        </div>
      </form>
    </DialogContent>
  </Dialog>;
}
