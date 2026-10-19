"use client";

import { useId, type ReactNode } from "react";
import { useForm, useWatch, type FieldValues, type FieldPath, type UseFormReturn } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Field, FieldError, FieldLabel } from "@/components/ui/field";
import { FormMenu, OMenu, chuMenu, soMenu } from "./form-menu";
import { type K, daDoi, loiDaoTao, oLoiDaoTao, useThemGhiNhan, useSuaGhiNhan, useGanHuongDan, useSuaHuongDan } from "./du-lieu-dao-tao";
import type { ApiResult } from "@/lib/api/client";

const loi = { loi: loiDaoTao, oLoi: oLoiDaoTao };
export type Bao = (s: string) => void;
const danhGia = z.enum(["", "pass", "not_yet"]);
const noiDung = { remark: z.string().trim(), rating: danhGia };
const coNoiDung = (v: { remark: string; rating: string }) => !!v.remark || !!v.rating;
const canNoiDung = { path: ["remark"], message: "Cần ít nhất một nhận xét hoặc đánh giá." };
const taoSchema = z.object({ ...noiDung, trainee_person_id: soMenu }).refine(coNoiDung, canNoiDung);
const suaSchema = z.object({ ...noiDung, reason: chuMenu }).refine(coNoiDung, canNoiDung);

function OChon<T extends FieldValues>({ form, o, nhan, children, textarea = false, accept }: {
  form: UseFormReturn<T>; o: FieldPath<T>; nhan: string; children?: ReactNode; textarea?: boolean; accept?: string;
}) {
  const id = useId();
  const error = form.getFieldState(o, form.formState).error?.message;
  const props = { id, "aria-invalid": !!error, "aria-describedby": error ? `${id}-loi` : undefined, ...form.register(o) };
  return <Field data-invalid={!!error}><FieldLabel htmlFor={id}>{nhan}</FieldLabel>
    {accept ? <input {...props} type="file" accept={accept} /> : textarea ? <textarea {...props} className="min-h-24 w-full rounded-md border p-2" />
      : <select {...props} className="h-9 rounded-md border bg-background px-3">{children}</select>}
    {error && <FieldError id={`${id}-loi`}>{error}</FieldError>}
  </Field>;
}
function CacOGhiNhan<T extends { remark: string; rating: string }>({ form }: { form: UseFormReturn<T> }) {
  return <><OChon form={form} o={"remark" as FieldPath<T>} nhan="Nhận xét" textarea />
    <OChon form={form} o={"rating" as FieldPath<T>} nhan="Đánh giá">
      <option value="">Chưa đánh giá</option><option value="pass">Làm được</option><option value="not_yet">Chưa làm được</option>
    </OChon></>;
}
export function ThemGhiNhan({ nguoi, bao }: { nguoi: K["Person"][]; bao: Bao }) {
  const luu = useThemGhiNhan();
  const form = useForm<z.infer<typeof taoSchema>>({ resolver: zodResolver(taoSchema), defaultValues: { remark: "", rating: "" } });
  return <FormMenu form={form} ten="Thêm ghi nhận" nut="Thêm ghi nhận" cacO={["trainee_person_id", "remark", "rating"]} {...loi}
    gui={({ trainee_person_id, remark, rating }) => luu.mutateAsync({ trainee_person_id, ...(remark ? { remark } : {}), ...(rating ? { rating } : {}) })}
    daLuu={() => { form.reset(); bao("Đã thêm ghi nhận."); }}>
    <OMenu form={form} o="trainee_person_id" nhan="Người" options={nguoi.map((p) => ({ id: p.person_id, ten: p.display_name }))} />
    <CacOGhiNhan form={form} />
  </FormMenu>;
}
export function SuaGhiNhan({ t, bao, dong }: { t: K["TrainingRecord"]; bao: Bao; dong: () => void }) {
  const luu = useSuaGhiNhan(t.training_record_id);
  const form = useForm<z.infer<typeof suaSchema>>({ resolver: zodResolver(suaSchema), defaultValues: { remark: t.remark ?? "", rating: t.rating ?? "", reason: "" } });
  return <FormMenu form={form} ten={`Sửa ghi nhận ${t.training_record_id}`} nut="Lưu thay đổi" cacO={["remark", "rating", "reason"]} {...loi} dong={dong}
    gui={async ({ remark, rating, reason }) => {
      const r = await luu.mutateAsync({ remark: remark || null, rating: rating || null, reason });
      if (!r.ok && daDoi(r.failure)) bao(loiDaoTao(r.failure));
      return r;
    }} daLuu={() => { bao("Đã sửa ghi nhận."); dong(); }}>
    <CacOGhiNhan form={form} /><OMenu form={form} o="reason" nhan="Lý do" />
  </FormMenu>;
}
const anSchema = z.object({ reason: chuMenu });
export function AnDaoTao<R>({ ten, gui, dong, bao }: { ten: string; gui: (b: K["HideTrainingItem"]) => Promise<ApiResult<R>>; dong: () => void; bao: Bao }) {
  const form = useForm<K["HideTrainingItem"]>({ resolver: zodResolver(anSchema), defaultValues: { reason: "" } });
  return <FormMenu form={form} ten={ten} nut="Ẩn" cacO={["reason"]} {...loi} dong={dong}
    gui={async (b) => { const r = await gui(b); if (!r.ok && daDoi(r.failure)) bao(loiDaoTao(r.failure)); return r; }}
    daLuu={() => { bao("Đã ẩn, vết vẫn giữ."); dong(); }}>
    <p>Mục này sẽ ẩn khỏi danh sách, vết vẫn giữ.</p><OMenu form={form} o="reason" nhan="Lý do" />
  </FormMenu>;
}
const ganSchema = z.object({ kind: z.enum(["text", "image", "video"]), body: z.string().trim(), file: z.custom<FileList>().optional() }).superRefine((v, ctx) => {
  if (v.kind === "text" && !v.body) ctx.addIssue({ code: "custom", path: ["body"], message: "Nhập nội dung hướng dẫn." });
  if (v.kind !== "text" && !v.file?.length) ctx.addIssue({ code: "custom", path: ["file"], message: "Chọn tệp hướng dẫn." });
});
export function GanHuongDan({ viec, bao }: { viec: number; bao: Bao }) {
  const luu = useGanHuongDan(viec);
  const form = useForm<z.infer<typeof ganSchema>>({ resolver: zodResolver(ganSchema), defaultValues: { kind: "text", body: "" } });
  const kind = useWatch({ control: form.control, name: "kind" });
  return <FormMenu form={form} ten="Gắn hướng dẫn" nut="Gắn hướng dẫn" cacO={["kind", "body", "file"]} {...loi}
    gui={async (b) => {
      const r = await luu.mutateAsync(b.kind === "text" ? { kind: b.kind, body: b.body } : { kind: b.kind, file: b.file![0] });
      if (!r.ok && daDoi(r.failure)) bao(loiDaoTao(r.failure));
      return r;
    }} daLuu={() => { form.reset(); bao("Đã gắn hướng dẫn."); }}>
    <OChon form={form} o="kind" nhan="Loại"><option value="text">Chữ</option><option value="image">Ảnh</option><option value="video">Video</option></OChon>
    {kind === "text" ? <OChon form={form} o="body" nhan="Nội dung hướng dẫn" textarea />
      : <OChon key={kind} form={form} o="file" nhan="Tệp" accept={kind === "image" ? "image/jpeg,image/png,image/webp" : "video/mp4,video/webm,video/quicktime"} />}
  </FormMenu>;
}
const chuSchema = z.object({ body: chuMenu, reason: chuMenu });
export function SuaHuongDan({ t, bao, dong }: { t: K["AssignedTaskGuide"]; bao: Bao; dong: () => void }) {
  const luu = useSuaHuongDan(t.assigned_task_guide_id);
  const form = useForm<K["UpdateAssignedTaskGuide"]>({ resolver: zodResolver(chuSchema), defaultValues: { body: t.body ?? "", reason: "" } });
  return <FormMenu form={form} ten={`Sửa hướng dẫn ${t.assigned_task_guide_id}`} nut="Lưu thay đổi" cacO={["body", "reason"]} {...loi} dong={dong}
    gui={async (b) => { const r = await luu.mutateAsync(b); if (!r.ok && daDoi(r.failure)) bao(loiDaoTao(r.failure)); return r; }}
    daLuu={() => { bao("Đã sửa hướng dẫn."); dong(); }}>
    <OChon form={form} o="body" nhan="Nội dung hướng dẫn" textarea /><OMenu form={form} o="reason" nhan="Lý do" />
  </FormMenu>;
}
