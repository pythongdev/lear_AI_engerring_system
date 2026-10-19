"use client";
// Form hai số tối thiểu của ngày bán backend trả (PUT /daily-minimums/{sale_date}). Chốt đồng bộ chặn bấm gửi hai
// lần trước lần render (fe-02 §3); lời từ chối có field gắn đúng ô.

import { zodResolver } from "@hookform/resolvers/zod";
import { useRef, useState, type FormEvent } from "react";
import { useForm } from "react-hook-form";
import { z } from "zod";

import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Field, FieldError, FieldLabel } from "@/components/ui/field";
import { Input } from "@/components/ui/input";

import { loiGhi, useLuuToiThieu, type SoToiThieu, type TongQuan } from "./du-lieu-tong-quan";

const soNguyen = z.number({ error: "Nhập số nguyên từ 1 trở lên." }).int("Nhập số nguyên.").min(1, "Nhập số từ 1 trở lên.");
const schema = z.object({ minimum_banh: soNguyen, minimum_workers: soNguyen });

export function FormToiThieu({ data }: { data: TongQuan }) {
  const luu = useLuuToiThieu(data.sale_date);
  const chot = useRef(false);
  const [thongBao, setThongBao] = useState<string | null>(null);
  const form = useForm<SoToiThieu>({
    resolver: zodResolver(schema),
    defaultValues: {
      minimum_banh: data.sales_progress.status === "available" ? data.sales_progress.minimum_banh : undefined,
      minimum_workers: data.shortages.workers.minimum_workers,
    },
  });

  async function gui(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (chot.current) return;
    chot.current = true;
    try {
      await form.handleSubmit(async (vao) => {
        setThongBao(null);
        const r = await luu.mutateAsync(vao);
        if (r.ok) {
          setThongBao("Đã lưu số tối thiểu.");
          return;
        }
        const message = loiGhi(r.failure);
        if (r.failure.kind === "rejected" && (r.failure.field === "minimum_banh" || r.failure.field === "minimum_workers")) {
          form.setError(r.failure.field, { type: "server", message });
        } else {
          setThongBao(message);
        }
      })(event);
    } finally {
      chot.current = false;
    }
  }

  return (
    <form onSubmit={gui} noValidate className="flex max-w-lg flex-col gap-4" aria-label="Số tối thiểu của ngày">
      <h2 className="text-lg font-semibold">Số tối thiểu của ngày</h2>
      {([ ["minimum_banh", "Số bánh tối thiểu"], ["minimum_workers", "Số người tối thiểu"] ] as const).map(([ten, nhan]) => {
        const loi = form.formState.errors[ten]?.message;
        return (
          <Field key={ten} data-invalid={loi ? true : undefined}>
            <FieldLabel htmlFor={ten}>{nhan}</FieldLabel>
            <Input id={ten} type="number" min={1} step={1} aria-invalid={loi ? true : undefined}
              aria-describedby={loi ? `${ten}-loi` : undefined}
              {...form.register(ten, { valueAsNumber: true })} />
            {loi && <FieldError id={`${ten}-loi`}>{loi}</FieldError>}
          </Field>
        );
      })}
      {thongBao && <Alert role="status"><AlertDescription>{thongBao}</AlertDescription></Alert>}
      <Button type="submit" disabled={form.formState.isSubmitting || luu.isPending}>
        {form.formState.isSubmitting || luu.isPending ? "Đang lưu…" : "Lưu số tối thiểu"}
      </Button>
    </form>
  );
}
