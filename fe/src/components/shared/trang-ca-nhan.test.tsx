import { cleanup, fireEvent, screen, waitFor, within } from "@testing-library/react";
import type { ReactElement, ReactNode } from "react";
import { afterEach, describe, expect, it, vi } from "vitest";

import TrangQuay from "@/app/quay/ca-nhan/page";
import TrangTram from "@/app/tram/ca-nhan/page";
import { voiBackend, type GoiDen } from "@/components/tai-khoan/test-utils";
import type { components } from "@/lib/api/schema";
import type { Session } from "@/lib/auth/khung";
import { TrangCaNhan } from "./trang-ca-nhan";

vi.mock("next/link", () => ({ default: ({ href, children }: { href: string; children: ReactNode }) => <a href={href}>{children}</a> }));

afterEach(() => { cleanup(); vi.useRealTimers(); });

type Viec = components["schemas"]["MyAssignedTask"];
const phien: Session = {
  person_id: 7, display_name: "Lan", role_code: "quay", is_owner: false,
  must_change_password: false, counter_duty_id: 0,
};
const viec = (sua: Partial<Viec> = {}): Viec => ({
  assigned_task_id: 1, content: "Chuẩn bị bánh", due_at: "2026-11-24T23:30:00Z",
  created_at: "2026-11-23T08:00:00+07:00", assigned_by_name: "Cô Thanh", done: false,
  guides: [{ body: "Xếp bánh vào khay.\nĐậy kín." }, { body: "Để khay lên kệ." }], ...sua,
});

function moTrang(ui: ReactElement, viecDuocGiao: Viec[] = [], suaPhien: Partial<Session> = {},
  docViec?: () => { status: number; body: unknown }) {
  return voiBackend(ui, (g) => {
    if (g.method !== "GET") throw new Error(`Cửa ghi ngoài dự kiến: ${g.method} ${g.path}`);
    if (g.path === "/sessions/current") return { status: 200, body: { ...phien, ...suaPhien } };
    if (g.path === "/assigned-tasks/mine") return docViec?.() ?? { status: 200, body: { assigned_tasks: viecDuocGiao } };
    if (g.path === "/leave-notices/mine") return { status: 200, body: { leave_notices: [] } };
    throw new Error(`Cửa đọc ngoài dự kiến: ${g.path}`);
  });
}

function chiDocViec(goi: GoiDen[]) {
  const yeuCauViec = goi.filter((g) => g.path.startsWith("/assigned-tasks"));
  expect(yeuCauViec.length).toBeGreaterThan(0);
  expect(yeuCauViec.every((g) => g.method === "GET" && g.path === "/assigned-tasks/mine" && g.body === undefined)).toBe(true);
}

describe("trang Cá nhân của người làm", () => {
  it.each([
    { khung: "/quay", Trang: TrangQuay, role_code: "quay", tenVai: "Người đứng quầy", ve: "Về màn quầy", counter_duty_id: 4 },
    { khung: "/tram", Trang: TrangTram, role_code: "trang_banh", tenVai: "Người tráng bánh", ve: "Về bảng trạm", counter_duty_id: 0 },
  ] as const)("$khung: hiện danh tính, nhãn vai, BaoNghi và các lối về / đổi mật khẩu", async ({ khung, Trang, role_code, tenVai, ve, counter_duty_id }) => {
    const goi = moTrang(<Trang />, [], { role_code, counter_duty_id });
    await screen.findByText("Chưa có việc nào được giao");
    expect(screen.getByRole("heading", { name: "Cá nhân", level: 1 })).toBeTruthy();
    expect(screen.getByText("Lan")).toBeTruthy();
    expect(screen.getByText(tenVai)).toBeTruthy();
    expect(!!screen.queryByText("Đang đứng quầy")).toBe(counter_duty_id !== 0);
    expect(screen.getByRole("link", { name: ve }).getAttribute("href")).toBe(khung);
    expect(within(screen.getByRole("region", { name: "Tài khoản" })).getByRole("link", { name: "Đổi mật khẩu" }).getAttribute("href")).toBe("/doi-mat-khau");
    const ngayNghi = within(screen.getByRole("region", { name: "Ngày nghỉ của tôi" }));
    expect(ngayNghi.getByRole("form", { name: "Soạn báo nghỉ" })).toBeTruthy();
    expect(await ngayNghi.findByText("Chưa có báo nghỉ.")).toBeTruthy();
    expect(goi.some((g) => g.method === "GET" && g.path === "/leave-notices/mine")).toBe(true);
    chiDocViec(goi);
  });

  it.each([
    ["gap_banh", "Người gấp bánh"],
    ["canh_don_ban", "Người canh & dọn"],
  ] as const)("hiện nhãn tiếng Việt cho vai %s", async (role_code, tenVai) => {
    moTrang(<TrangCaNhan khung="/tram" />, [], { role_code });
    expect(await screen.findByText(tenVai)).toBeTruthy();
  });

  it("giữ thứ tự backend trong từng nhóm, chưa xong trước; hiện người giao, hạn giờ Việt Nam, hướng dẫn; chỉ đọc việc", async () => {
    const goi = moTrang(<TrangCaNhan khung="/quay" />, [
      viec({ assigned_task_id: 9, content: "Xong trước", done: true }),
      viec({ assigned_task_id: 3, content: "Chưa xong trước" }),
      viec({ assigned_task_id: 8, content: "Xong sau", done: true }),
      viec({ assigned_task_id: 5, content: "Chưa xong sau" }),
    ]);
    const danhSach = await screen.findByRole("list", { name: "Việc được giao" });
    const dong = within(danhSach).getAllByRole("listitem");
    expect(dong.map((d) => within(d).getByRole("heading").textContent)).toEqual([
      "Chưa xong trước", "Chưa xong sau", "Xong trước", "Xong sau",
    ]);
    expect(within(dong[0]).getByText("Người giao: Cô Thanh")).toBeTruthy();
    expect(dong[0].querySelector("time")?.textContent).toBe("06:30 25/11/2026");
    expect(dong[0].querySelector("time")?.getAttribute("dateTime")).toBe("2026-11-24T23:30:00Z");
    expect(within(dong[0]).getByText("Chưa xong", { exact: true })).toBeTruthy();
    expect(within(dong[2]).getByText("Xong", { exact: true })).toBeTruthy();
    expect(within(dong[0]).getByText("Xếp bánh vào khay. Đậy kín.").textContent).toBe("Xếp bánh vào khay.\nĐậy kín.");
    expect(within(dong[0]).getByText("Để khay lên kệ.")).toBeTruthy();
    expect(within(screen.getByRole("region", { name: "Việc được giao" })).queryAllByRole("button")).toEqual([]);
    chiDocViec(goi);
  });

  it("giờ giả: chỉ việc chưa xong có hạn đã qua mang nhãn Quá hạn; due_at null hiện Chưa có hạn", async () => {
    vi.useFakeTimers({ toFake: ["Date"] });
    vi.setSystemTime(new Date("2026-11-24T10:00:00+07:00"));
    moTrang(<TrangCaNhan khung="/tram" />, [
      viec({ assigned_task_id: 1, content: "Trễ", due_at: "2026-11-24T09:59:00+07:00" }),
      viec({ assigned_task_id: 2, content: "Vừa tới hạn", due_at: "2026-11-24T03:00:00Z" }),
      viec({ assigned_task_id: 3, content: "Còn hạn", due_at: "2026-11-24T10:01:00+07:00" }),
      viec({ assigned_task_id: 4, content: "Chưa nhập hạn", due_at: null, guides: [] }),
      viec({ assigned_task_id: 5, content: "Xong rồi", due_at: "2026-11-24T09:59:00+07:00", done: true }),
    ], { role_code: "gap_banh" });
    const danhSach = await screen.findByRole("list", { name: "Việc được giao" });
    const dong = within(danhSach).getAllByRole("listitem");
    expect(within(dong[0]).getByText("Quá hạn")).toBeTruthy();
    for (const d of dong.slice(1)) expect(within(d).queryByText("Quá hạn")).toBeNull();
    expect(within(dong[3]).getByText("Chưa có hạn")).toBeTruthy();
    expect(dong[3].querySelector("time")).toBeNull();
    expect(within(dong[3]).queryByText("Hướng dẫn")).toBeNull();
  });

  it("danh sách rỗng hiện Chưa có việc nào được giao", async () => {
    moTrang(<TrangCaNhan khung="/quay" />);
    expect(await screen.findByText("Chưa có việc nào được giao")).toBeTruthy();
    expect(screen.queryByRole("list", { name: "Việc được giao" })).toBeNull();
  });

  it("lỗi đọc hiện câu lỗi; Đọc lại gọi GET và hiện kết quả, không request ghi tới assigned-tasks", async () => {
    let soLanDoc = 0;
    const goi = moTrang(<TrangCaNhan khung="/tram" />, [], { role_code: "canh_don_ban" }, () => {
      soLanDoc++;
      return soLanDoc === 1
        ? { status: 500, body: { code: "internal_error" } }
        : { status: 200, body: { assigned_tasks: [viec()] } };
    });
    const loi = await screen.findByRole("alert");
    expect(loi.textContent).toContain("Chưa đọc được việc được giao.");
    expect(screen.queryByText("Chưa có việc nào được giao")).toBeNull();
    expect(soLanDoc).toBe(1);
    fireEvent.click(within(loi).getByRole("button", { name: "Đọc lại" }));
    await screen.findByRole("heading", { name: "Chuẩn bị bánh" });
    await waitFor(() => expect(screen.queryByRole("alert")).toBeNull());
    expect(soLanDoc).toBe(2);
    chiDocViec(goi);
  });
});
