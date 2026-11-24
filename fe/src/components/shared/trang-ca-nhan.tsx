"use client";

import { useQuery } from "@tanstack/react-query";
import Link from "next/link";

import { Button } from "@/components/ui/button";
import { call } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import type { Session } from "@/lib/auth/khung";
import { usePhien } from "@/lib/auth/session";
import { BaoNghi } from "./bao-nghi";

// Giữ nhãn như màn Nhân viên; tầng shared không import từ app/<route>.
const TEN_VAI: Record<Session["role_code"], string> = {
  owner: "Chủ quán",
  quay: "Người đứng quầy",
  trang_banh: "Người tráng bánh",
  gap_banh: "Người gấp bánh",
  canh_don_ban: "Người canh & dọn",
};
const gioVietNam = new Intl.DateTimeFormat("vi-VN", {
  timeZone: "Asia/Ho_Chi_Minh",
  year: "numeric", month: "2-digit", day: "2-digit",
  hour: "2-digit", minute: "2-digit", hourCycle: "h23",
});

export function TrangCaNhan({ khung }: { khung: "/quay" | "/tram" }) {
  const api = useApi();
  const phien = usePhien();
  const s = phien.data?.ok ? phien.data.data : null;
  const personId = s?.person_id;
  const viec = useQuery({
    queryKey: ["assigned-tasks", "mine", personId], enabled: !!s, retry: false,
    queryFn: async () => {
      const r = await call(api.GET("/assigned-tasks/mine"));
      if (!r.ok) throw r.failure;
      return r.data;
    },
  });

  // Layout KhungTheoVai xử lý phiên lỗi, hết hạn và chuyển khung.
  if (!s) return null;
  const danhSach = viec.data?.assigned_tasks ?? [];
  const sapXep = [...danhSach.filter((v) => !v.done), ...danhSach.filter((v) => v.done)];
  const bayGio = new Date().getTime();

  return <div className="mx-auto max-w-3xl space-y-6">
    <Link href={khung} className="inline-flex min-h-11 items-center underline">
      {khung === "/quay" ? "Về màn quầy" : "Về bảng trạm"}
    </Link>
    <header className="space-y-1">
      <h1 className="text-2xl font-semibold">Cá nhân</h1>
      <p className="font-medium">{s.display_name}</p>
      <p>{TEN_VAI[s.role_code]}</p>
      {s.counter_duty_id !== 0 && <p>Đang đứng quầy</p>}
    </header>

    <section aria-label="Việc được giao" className="space-y-3 rounded border p-4">
      <h2 className="text-lg font-semibold">Việc được giao</h2>
      {viec.isPending && <p role="status">Đang đọc việc được giao…</p>}
      {viec.isError && <div role="alert">
        <p>Chưa đọc được việc được giao.{viec.data && " Đang hiện bản cũ."}</p>
        <Button type="button" className="min-h-11" onClick={() => void viec.refetch()}>Đọc lại</Button>
      </div>}
      {viec.data && (sapXep.length === 0 ? <p>Chưa có việc nào được giao</p> :
        <ul aria-label="Việc được giao" className="space-y-3">
          {sapXep.map((v) => <li key={v.assigned_task_id} className="space-y-2 rounded border p-3">
            <h3 className="whitespace-pre-wrap break-words font-medium">{v.content}</h3>
            <p>Người giao: {v.assigned_by_name}</p>
            <p>{v.due_at === null ? "Chưa có hạn" : <>Hạn: <time dateTime={v.due_at}>{gioVietNam.format(new Date(v.due_at))}</time></>}</p>
            <p>{v.done ? "Xong" : "Chưa xong"}</p>
            {!v.done && v.due_at !== null && new Date(v.due_at).getTime() < bayGio &&
              <p className="font-medium text-destructive">Quá hạn</p>}
            {v.guides.length > 0 && <div className="space-y-1">
              <p className="font-medium">Hướng dẫn</p>
              {v.guides.map((g, i) => <p key={i} className="whitespace-pre-wrap break-words">{g.body}</p>)}
            </div>}
          </li>)}
        </ul>)}
    </section>

    <section aria-label="Ngày nghỉ của tôi" className="space-y-3 rounded border p-4">
      <h2 className="text-lg font-semibold">Ngày nghỉ của tôi</h2>
      <BaoNghi key={s.person_id} khung={khung} personId={s.person_id} mo />
    </section>

    <section aria-label="Tài khoản" className="space-y-3 rounded border p-4">
      <h2 className="text-lg font-semibold">Tài khoản</h2>
      <Link href="/doi-mat-khau" className="inline-flex min-h-11 items-center underline">Đổi mật khẩu</Link>
    </section>
  </div>;
}
