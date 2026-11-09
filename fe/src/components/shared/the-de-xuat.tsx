"use client";

import { useRef, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { call, type ApiClient, type ApiResult } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";
import type { Khung } from "@/lib/auth/khung";
import { loiTaiKhoan } from "@/lib/auth/messages";

export type CuaGhi = {
  coDau: boolean;
  manTay?: Partial<Record<Khung, { href: string; ten: string }>>;
  chonNguoi?: string;
  goi: (api: ApiClient, de: { path_params: Record<string, unknown>; body: Record<string, unknown> }) => Promise<ApiResult<unknown>>;
};

const manTayGiaoViec: CuaGhi["manTay"] = {
  "/quay": { href: "/quay/giao-viec", ten: "Xem Giao việc" },
  "/chu-quan": { href: "/chu-quan/giao-viec", ten: "Xem Giao việc" },
};
// ADR-140: mỗi nhóm chỉ thêm cửa màn tay khi có phiếu mở nhóm được duyệt.
export const cuaGhiChat: Readonly<Record<string, CuaGhi>> = Object.freeze({
  createAssignedTask: {
    coDau: false,
    manTay: manTayGiaoViec,
    chonNguoi: "assignee_person_id",
    goi: (api, de) => call(api.POST("/assigned-tasks", { body: de.body as components["schemas"]["CreateAssignedTask"] })),
  },
  updateAssignedTask: {
    coDau: false,
    manTay: manTayGiaoViec,
    goi: (api, de) => call(api.PUT("/assigned-tasks/{assigned_task_id}", {
      params: { path: { assigned_task_id: Number(de.path_params.assigned_task_id) } },
      body: de.body as components["schemas"]["UpdateAssignedTask"],
    })),
  },
  hideAssignedTask: {
    coDau: false,
    manTay: manTayGiaoViec,
    goi: (api, de) => call(api.POST("/assigned-tasks/{assigned_task_id}/hiding", {
      params: { path: { assigned_task_id: Number(de.path_params.assigned_task_id) } },
      body: de.body as components["schemas"]["HideAssignedTask"],
    })),
  },
  markAssignedTask: {
    coDau: false,
    manTay: manTayGiaoViec,
    goi: (api, de) => call(api.POST("/assigned-tasks/{assigned_task_id}/marks", {
      params: { path: { assigned_task_id: Number(de.path_params.assigned_task_id) } },
      body: de.body as components["schemas"]["MarkAssignedTask"],
    })),
  },
});

export const gioNoiBo = new Intl.DateTimeFormat("vi-VN", { timeZone: "Asia/Ho_Chi_Minh", hour: "2-digit", minute: "2-digit", second: "2-digit" });
export const tenNguon: Record<string, string> = { doc_menu: "Thực đơn", tinh_gia: "Bảng giá" };
export const tenNguonNoiBo: Record<string, string> = {
  ...tenNguon,
  doc_bang_tram: "Bảng trạm",
  doc_bang_phuc_vu: "Bảng phục vụ",
  doc_tong_quan: "Tổng quan",
  giao_viec: "Giao việc",
  sua_viec: "Giao việc",
  an_viec: "Giao việc",
  danh_dau_viec: "Giao việc",
};
export const manTay: Record<Khung, { href: string; ten: string }> = {
  "/tram": { href: "/tram", ten: "Xem Bảng trạm" },
  "/quay": { href: "/quay/san-xuat", ten: "Xem Sản xuất" },
  "/chu-quan": { href: "/chu-quan/van-hanh", ten: "Xem Vận hành" },
};

type DeXuat = components["schemas"]["ChatProposal"];
type TrangThai =
  | { loai: "cho" | "dang_ghi" | "da_ghi" | "chua_ro" | "bo" | "het" | "qua_gio" }
  | { loai: "tu_choi"; loi: string };
const MUOI_PHUT = 10 * 60 * 1000;
const chu = {
  dang_ghi: "Đang ghi…",
  da_ghi: "Đã ghi. Thẻ chưa đọc lại số; xem lại trên màn tay.",
  chua_ro: "Chưa rõ kết quả: chưa nhận được trả lời của quán. Xem lại trên màn tay trước khi làm lại.",
  bo: "Đã bỏ đề xuất, không ghi gì.",
  het: "Đề xuất đã hết hiệu lực, không ghi gì.",
  qua_gio: "Đề xuất đã quá 10 phút từ mốc đọc, không ghi gì. Hỏi lại để có số mới.",
};

export function TheDeXuat({ deXuat, khung, nguoiBam, cuaGhi, song }: {
  deXuat: DeXuat;
  khung: Khung;
  nguoiBam?: string;
  cuaGhi: Readonly<Record<string, CuaGhi>>;
  song: boolean;
}) {
  const api = useApi();
  // Chụp cả dòng hiện, người bấm và cửa gọi. Dấu sinh tại đây, không sinh lại khi gửi.
  const [the] = useState(() => {
    const de = structuredClone(deXuat);
    const cua = Object.prototype.hasOwnProperty.call(cuaGhi, de.operation_id) ? { ...cuaGhi[de.operation_id] } : undefined;
    if (cua?.coDau) de.body.submission_code = crypto.randomUUID();
    return { de, cua, nguoiBam, mocDoc: Math.min(...de.lines.map((dong) => Date.parse(dong.read_at))) };
  });
  const [trangThai, setTrangThai] = useState<TrangThai>({ loai: "cho" });
  const [danhSachNguoi, setDanhSachNguoi] = useState<{ people: components["schemas"]["Person"][]; mocDoc: number } | null>(null);
  const [nguoiNhan, setNguoiNhan] = useState<number | null>(null);
  const [hetHieuLuc, setHetHieuLuc] = useState(false);
  const chot = useRef(false);
  const [quaGioLucDung] = useState(() => Date.now() - the.mocDoc >= MUOI_PHUT);
  const biLoai = hetHieuLuc || !song || quaGioLucDung;
  // Loại vĩnh viễn ngay trong render; không đợi effect mới khoá nút.
  if (biLoai && !hetHieuLuc) setHetHieuLuc(true);
  if (biLoai && trangThai.loai === "cho") setTrangThai({ loai: quaGioLucDung ? "qua_gio" : "het" });

  const truongNguoi = the.cua?.chonNguoi;
  const canChonNguoi = !!truongNguoi && the.de.needs_choice.length === 1 && the.de.needs_choice[0] === truongNguoi;
  const nguoi = useQuery({
    queryKey: ["people"],
    enabled: canChonNguoi && !biLoai && trangThai.loai === "cho" && !danhSachNguoi,
    queryFn: async () => {
      const r = await call(api.GET("/people"));
      if (!r.ok) throw r.failure;
      return r.data;
    },
  });
  // Chụp danh sách và mốc đọc cùng nhau; cache màn tay đổi không sửa thẻ đang hiện.
  if (canChonNguoi && !danhSachNguoi && nguoi.isSuccess && !nguoi.isFetching) {
    setDanhSachNguoi({ people: structuredClone(nguoi.data.people), mocDoc: nguoi.dataUpdatedAt });
  }
  const nguoiDuocChon = danhSachNguoi?.people.find((p) => p.person_id === nguoiNhan);
  const lyDo = !the.cua ? "Việc này chưa mở cho trợ lý. Làm trên màn tay."
    : the.de.needs_choice.length > 0 && !canChonNguoi ? `Cần chọn trên màn tay: ${the.de.needs_choice.join(", ")}.`
    : canChonNguoi && !danhSachNguoi && nguoi.isError ? "Chưa đọc được danh sách người. Giao trên màn tay."
    : canChonNguoi && danhSachNguoi?.people.length === 0 ? "Chưa có người để giao. Giao trên màn tay."
    : canChonNguoi && !nguoiDuocChon ? "Chọn người nhận trước khi ghi."
    : the.de.lines.length === 0 ? "Đề xuất thiếu dòng để kiểm, không ghi được từ đây."
    : !the.nguoiBam?.trim() ? "Chưa biết người bấm, không ghi được từ đây."
    : !Number.isFinite(the.mocDoc) ? "Đề xuất có mốc đọc không hợp lệ, không ghi được từ đây."
    : null;
  const duocBam = !biLoai && !lyDo && (trangThai.loai === "cho" || (trangThai.loai === "chua_ro" && the.cua?.coDau));

  async function ghi() {
    if (!duocBam || !the.cua || chot.current) return;
    // Đồng hồ có thể đã qua hạn mà không có lần render nào giữa hai mốc.
    if (Date.now() - the.mocDoc >= MUOI_PHUT) {
      setHetHieuLuc(true);
      if (trangThai.loai === "cho") setTrangThai({ loai: "qua_gio" });
      return;
    }
    chot.current = true;
    setTrangThai({ loai: "dang_ghi" });
    try {
      // Lệnh ghi độc lập với lượt hỏi; đóng chat không huỷ lệnh đã gửi.
      const body = canChonNguoi && truongNguoi && nguoiDuocChon
        ? { ...the.de.body, [truongNguoi]: nguoiDuocChon.person_id } : the.de.body;
      const r = await the.cua.goi(api, structuredClone({ path_params: the.de.path_params, body }));
      if (r.ok) {
        setTrangThai({ loai: "da_ghi" });
      } else if (r.failure.kind === "rejected") {
        setTrangThai({ loai: "tu_choi", loi: `Chưa ghi: ${r.failure.code === "unauthenticated"
          ? loiTaiKhoan(r.failure) : `cửa từ chối (${r.failure.code}).`}` });
      } else {
        setTrangThai({ loai: "chua_ro" });
        chot.current = !the.cua.coDau;
      }
    } catch {
      setTrangThai({ loai: "chua_ro" });
      chot.current = !the.cua.coDau;
    }
  }

  const duongVe = the.cua?.manTay?.[khung] ?? manTay[khung];
  const dangGhi = trangThai.loai === "dang_ghi";
  return <section role="group" aria-label="Đề xuất ghi" className="space-y-2 rounded border bg-background p-3 text-foreground">
    <p>Đề xuất, chưa ghi gì. Kiểm từng dòng trước khi bấm.</p>
    {the.de.lines.map((dong, i) => <p key={i}>{`${dong.label}: ${dong.value} (${tenNguonNoiBo[dong.source] ?? dong.source}, đọc lúc ${Number.isFinite(Date.parse(dong.read_at)) ? gioNoiBo.format(new Date(dong.read_at)) : dong.read_at})`}</p>)}
    {canChonNguoi && <label className="block">Người nhận
      <select value={nguoiNhan ?? ""} disabled={biLoai || trangThai.loai !== "cho" || !danhSachNguoi?.people.length}
        onChange={(e) => {
          if (biLoai || trangThai.loai !== "cho" || chot.current) return;
          setNguoiNhan(e.target.value === "" ? null : Number(e.target.value));
        }} className="block min-h-11 w-full rounded border bg-background px-3 py-2">
        <option value="">Chọn người nhận</option>
        {danhSachNguoi?.people.map((p) => <option key={p.person_id} value={p.person_id}>{p.display_name}</option>)}
      </select>
    </label>}
    {nguoiDuocChon && danhSachNguoi && <p>{`Người nhận: ${nguoiDuocChon.display_name} (Danh sách người, đọc lúc ${gioNoiBo.format(danhSachNguoi.mocDoc)})`}</p>}
    <p>Người bấm: {the.nguoiBam}</p>
    {trangThai.loai === "cho" && lyDo && <p>{lyDo}</p>}
    {trangThai.loai === "tu_choi" ? <p role="alert">{trangThai.loi}</p>
      : trangThai.loai !== "cho" && <p role={trangThai.loai === "chua_ro" ? "alert" : "status"}>{chu[trangThai.loai]}</p>}
    {(duocBam || dangGhi) && <div className="flex flex-wrap gap-2">
      <Button type="button" variant="outline" disabled={dangGhi} onClick={() => void ghi()}>
        {dangGhi ? "Đang ghi…" : trangThai.loai === "chua_ro" ? "Gửi lại" : "Xác nhận ghi"}
      </Button>
      {trangThai.loai === "cho" && <Button type="button" variant="ghost" onClick={() => {
        if (chot.current) return;
        chot.current = true;
        setTrangThai({ loai: "bo" });
      }}>Bỏ</Button>}
    </div>}
    <a href={duongVe.href} className="underline">{duongVe.ten}</a>
  </section>;
}
