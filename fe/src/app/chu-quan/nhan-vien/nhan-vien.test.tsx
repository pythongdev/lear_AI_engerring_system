// Test hồi quy P4A-06 (nhân viên) — Claude viết TRƯỚC khi có code (L2). Người thi công làm cho xanh, KHÔNG sửa điều kiện kiểm.
// Giữ: người làm tự đăng ký, chủ quán duyệt và gán một trong BỐN vai trạm (shop-facts §3; không có `owner` — ADR-109 điểm 3
// Sửa đổi), từ chối, khoá người nghỉ, mở lại kèm mật khẩu tạm (ADR-109 điểm 9); trang KHÔNG bày mật khẩu và không có cửa
// xoá — tài khoản khoá vẫn nằm trong danh sách (QD không xoá cứng); duyệt chỉ gắn vào người chưa có tài khoản và không phải
// chủ quán (cờ chủ quán không có đường qua màn duyệt); không tự khoá chính mình; ghi chờ backend xác nhận rồi đọc lại,
// không ghi tay cache (ADR-102 điểm 2); bấm hai lần gửi một lệnh.
import { cleanup, fireEvent, screen, waitFor, within } from "@testing-library/react";
import { afterEach, describe, expect, it, vi } from "vitest";

import { voiBackend, type GoiDen } from "@/components/tai-khoan/test-utils";
import type { components } from "@/lib/api/schema";

import Page from "./page";

type TaiKhoan = components["schemas"]["Accounts"]["accounts"][number];

vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: vi.fn(), replace: vi.fn() }),
  usePathname: () => "/chu-quan/nhan-vien",
  useSearchParams: () => new URLSearchParams(),
}));

afterEach(cleanup);

function tk(account_id: number, display_name: string, status: TaiKhoan["status"], person_id: number | null = null,
  role_code: string | null = null): TaiKhoan {
  return {
    account_id, username: display_name.toLowerCase().replace(/\s+/g, ""), email: `tk${account_id}@gmail.com`,
    display_name, status, role_code, person_id, created_at: "2026-10-18T02:00:00Z",
  };
}

// Thứ tự backend cố ý trộn trạng thái: trang chia nhóm, giữ thứ tự trong nhóm.
const mauTaiKhoan = {
  accounts: [
    tk(1, "Chủ Lan", "hoat_dong", 1, "owner"),
    tk(2, "Minh", "cho_duyet"),
    tk(3, "Hoa", "hoat_dong", 3, "trang_banh"),
    tk(4, "Tuấn", "khoa", 4, "quay"),
    tk(5, "Bình", "cho_duyet"),
    tk(6, "Nam", "tu_choi"),
  ],
};
// Người 1 là chủ quán có tài khoản; người 3 đã có tài khoản; người 8 là chủ quán chưa có tài khoản; người 9 trống.
const mauNguoi = {
  people: [
    { person_id: 1, display_name: "Chủ Lan", is_owner: true },
    { person_id: 3, display_name: "Hoa", is_owner: false },
    { person_id: 8, display_name: "Chủ Hai", is_owner: true },
    { person_id: 9, display_name: "Cô Mai", is_owner: false },
  ],
};
const phien = { person_id: 1, display_name: "Chủ Lan", role_code: "owner", is_owner: true, must_change_password: false, counter_duty_id: 0 };

type TraLoi = { status: number; body?: unknown };
function moTrang(tl: { doc?: (lan: number) => TraLoi; nguoi?: () => TraLoi; ghi?: (g: GoiDen) => TraLoi } = {}) {
  let lan = 0;
  return voiBackend(<Page />, (g) => {
    if (g.method === "GET" && g.path === "/accounts") {
      lan += 1;
      return tl.doc ? tl.doc(lan) : { status: 200, body: mauTaiKhoan };
    }
    if (g.method === "GET" && g.path === "/people") return tl.nguoi ? tl.nguoi() : { status: 200, body: mauNguoi };
    if (g.method === "GET" && g.path === "/sessions/current") return { status: 200, body: phien };
    if (g.method !== "GET") return tl.ghi ? tl.ghi(g) : { status: 599, body: { code: "khong_co_trong_hop_dong" } };
    return { status: 599, body: { code: "khong_co_trong_hop_dong" } };
  });
}
const soLanDoc = (g: GoiDen[], path = "/accounts") => g.filter((x) => x.method === "GET" && x.path === path).length;
const ghi = (g: GoiDen[]) => g.filter((x) => x.method !== "GET");
const ketQua = (account_id: number, status: string, person_id?: number) => ({ status: 200, body: { account_id, status, person_id } });

function go(o: HTMLElement, nhan: string, giaTri: string) {
  fireEvent.change(within(o).getByLabelText(nhan), { target: { value: giaTri } });
}
const oSai = (o: HTMLElement, nhan: string) => within(o).getByLabelText(nhan).getAttribute("aria-invalid");
async function mo(nhanNut: string) {
  fireEvent.click(await screen.findByRole("button", { name: nhanNut }));
  return screen.getByRole("form", { name: nhanNut });
}
const nhom = (ten: string) => screen.findByRole("region", { name: ten });
const tenTrong = (vung: HTMLElement) => within(vung).getAllByRole("listitem").map((li) => li.querySelector("h3")?.textContent);

describe("trang nhân viên — danh sách", () => {
  it("đọc mọi tài khoản một lần, chia bốn nhóm theo thứ tự, giữ thứ tự backend trong nhóm", async () => {
    const goi = moTrang();
    const cho = await nhom("Chờ duyệt");
    const dangLam = screen.getByRole("region", { name: "Đang làm" });
    const khoa = screen.getByRole("region", { name: "Đã khoá" });
    const tuChoi = screen.getByRole("region", { name: "Đã từ chối" });
    expect(tenTrong(cho)).toEqual(["Minh", "Bình"]);
    expect(tenTrong(dangLam)).toEqual(["Chủ Lan", "Hoa"]);
    expect(tenTrong(khoa)).toEqual(["Tuấn"]);
    expect(tenTrong(tuChoi)).toEqual(["Nam"]);
    for (const [a, b] of [[cho, dangLam], [dangLam, khoa], [khoa, tuChoi]]) {
      expect(a.compareDocumentPosition(b) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    }
    // Không lọc theo trạng thái ở backend: một lần đọc cho cả bốn nhóm.
    expect(soLanDoc(goi)).toBe(1);
  });

  it("mỗi tài khoản bày tên đăng nhập, Gmail và vai theo tên của quán; không bày mật khẩu", async () => {
    moTrang();
    const dangLam = await nhom("Đang làm");
    const hoa = within(dangLam).getAllByRole("listitem")[1];
    expect(hoa.textContent).toContain("hoa");
    expect(hoa.textContent).toContain("tk3@gmail.com");
    expect(hoa.textContent).toContain("Người tráng bánh");
    const khoa = screen.getByRole("region", { name: "Đã khoá" });
    expect(khoa.textContent).toContain("Người đứng quầy");
    expect(document.body.textContent ?? "").not.toMatch(/mật khẩu/i);
  });

  it("không có nút xoá, sửa tên, đổi vai hay đặt lại mật khẩu; tài khoản từ chối không có nút nào", async () => {
    moTrang();
    const tuChoi = await nhom("Đã từ chối");
    expect(screen.queryByRole("button", { name: /xoá|xóa|sửa|đổi vai|đặt lại/i })).toBeNull();
    expect(within(tuChoi).queryByRole("button")).toBeNull();
  });

  it("nút đúng theo trạng thái; không có nút khoá chính tài khoản đang đăng nhập", async () => {
    moTrang();
    await nhom("Chờ duyệt");
    expect(screen.getByRole("button", { name: "Duyệt Minh" })).toBeTruthy();
    expect(screen.getByRole("button", { name: "Từ chối Minh" })).toBeTruthy();
    expect(screen.getByRole("button", { name: "Khoá Hoa" })).toBeTruthy();
    expect(screen.getByRole("button", { name: "Mở lại Tuấn" })).toBeTruthy();
    await waitFor(() => expect(screen.queryByRole("button", { name: "Khoá Chủ Lan" })).toBeNull());
    expect(screen.queryByRole("button", { name: "Khoá Tuấn" })).toBeNull();
    expect(screen.queryByRole("button", { name: "Mở lại Hoa" })).toBeNull();
  });

  it("nhóm trống nói không có", async () => {
    moTrang({ doc: () => ({ status: 200, body: { accounts: [tk(1, "Chủ Lan", "hoat_dong", 1, "owner")] } }) });
    const cho = await nhom("Chờ duyệt");
    expect(cho.textContent).toMatch(/Không có tài khoản nào/);
  });

  it("đọc lỗi: báo không đọc được", async () => {
    moTrang({ doc: () => ({ status: 500, body: { code: "internal_error" } }) });
    await waitFor(() => expect(screen.getByRole("alert").textContent ?? "").toMatch(/Chưa đọc được danh sách tài khoản/));
  });
});

describe("trang nhân viên — duyệt", () => {
  it("vai chỉ bốn vai trạm, không có chủ quán", async () => {
    moTrang();
    const f = await mo("Duyệt Minh");
    const vai = within(f).getByLabelText("Vai") as HTMLSelectElement;
    expect([...vai.options].filter((o) => o.value !== "").map((o) => [o.value, o.textContent])).toEqual([
      ["quay", "Người đứng quầy"], ["trang_banh", "Người tráng bánh"], ["gap_banh", "Người gấp bánh"],
      ["canh_don_ban", "Người canh & dọn"],
    ]);
  });

  it("người gắn được: mặc định tạo người mới; chỉ người chưa có tài khoản và không phải chủ quán", async () => {
    moTrang();
    const f = await mo("Duyệt Minh");
    const nguoi = within(f).getByLabelText("Người trong quán") as HTMLSelectElement;
    await waitFor(() => expect(nguoi.options.length).toBe(2));
    expect(nguoi.value).toBe("");
    expect(nguoi.options[0].textContent).toContain("Minh");
    expect([...nguoi.options].map((o) => o.value)).toEqual(["", "9"]);
  });

  it("chưa chọn vai: không gửi, đánh dấu ô Vai", async () => {
    const goi = moTrang();
    const f = await mo("Duyệt Minh");
    fireEvent.click(within(f).getByRole("button", { name: "Xác nhận duyệt" }));
    await waitFor(() => expect(oSai(f, "Vai")).toBe("true"));
    expect(ghi(goi)).toEqual([]);
  });

  it("tạo người mới: gửi đúng vai, không gửi person_id; báo, đọc lại tài khoản và người", async () => {
    const goi = moTrang({ ghi: () => ketQua(2, "hoat_dong", 10) });
    const f = await mo("Duyệt Minh");
    go(f, "Vai", "gap_banh");
    fireEvent.click(within(f).getByRole("button", { name: "Xác nhận duyệt" }));
    expect(await screen.findByText("Đã duyệt Minh.")).toBeTruthy();
    expect(ghi(goi)).toEqual([{ method: "POST", path: "/accounts/2/approval", body: { role_code: "gap_banh" } }]);
    await waitFor(() => expect(soLanDoc(goi)).toBe(2));
    await waitFor(() => expect(soLanDoc(goi, "/people")).toBe(2));
  });

  it("gắn người sẵn có: gửi person_id số nguyên", async () => {
    const goi = moTrang({ ghi: () => ketQua(5, "hoat_dong", 9) });
    const f = await mo("Duyệt Bình");
    await waitFor(() => expect((within(f).getByLabelText("Người trong quán") as HTMLSelectElement).options.length).toBe(2));
    go(f, "Vai", "canh_don_ban");
    go(f, "Người trong quán", "9");
    fireEvent.click(within(f).getByRole("button", { name: "Xác nhận duyệt" }));
    expect(await screen.findByText("Đã duyệt Bình.")).toBeTruthy();
    expect(ghi(goi)).toEqual([{ method: "POST", path: "/accounts/5/approval", body: { role_code: "canh_don_ban", person_id: 9 } }]);
  });

  it("đã có người khác duyệt (409 account_not_pending): nói trạng thái đã đổi, đọc lại", async () => {
    const goi = moTrang({ ghi: () => ({ status: 409, body: { code: "account_not_pending" } }) });
    const f = await mo("Duyệt Minh");
    go(f, "Vai", "quay");
    fireEvent.click(within(f).getByRole("button", { name: "Xác nhận duyệt" }));
    await waitFor(() => expect(f.textContent ?? "").toMatch(/Trạng thái tài khoản đã đổi/));
    await waitFor(() => expect(soLanDoc(goi)).toBe(2));
  });

  // T-203 (F-071): backend từ chối gắn vào người mang cờ chủ quán — lời gắn đúng ô, nói rõ lý do, đọc lại.
  it("gắn vào người chủ quán bị từ chối (409 account_person_is_owner, field person_id): gắn ô Người trong quán, đọc lại", async () => {
    const goi = moTrang({ ghi: () => ({ status: 409, body: { code: "account_person_is_owner", field: "person_id" } }) });
    const f = await mo("Duyệt Bình");
    await waitFor(() => expect((within(f).getByLabelText("Người trong quán") as HTMLSelectElement).options.length).toBe(2));
    go(f, "Vai", "quay");
    go(f, "Người trong quán", "9");
    fireEvent.click(within(f).getByRole("button", { name: "Xác nhận duyệt" }));
    await waitFor(() => expect(oSai(f, "Người trong quán")).toBe("true"));
    expect(f.textContent ?? "").toMatch(/chủ quán/i);
    await waitFor(() => expect(soLanDoc(goi, "/people")).toBe(2));
  });

  it("phản hồi lạ: nói chưa xác nhận được kết quả, không tự gửi lại", async () => {
    const goi = moTrang({ ghi: () => ({ status: 500, body: { khong: "phai Error" } }) });
    const f = await mo("Duyệt Minh");
    go(f, "Vai", "quay");
    fireEvent.click(within(f).getByRole("button", { name: "Xác nhận duyệt" }));
    await waitFor(() => expect(f.textContent ?? "").toMatch(/chưa xác nhận được kết quả/i));
    expect(ghi(goi)).toHaveLength(1);
  });

  it("bấm gửi hai lần liền chỉ gửi một lệnh", async () => {
    const goi = moTrang({ ghi: () => ketQua(2, "hoat_dong", 10) });
    const f = await mo("Duyệt Minh");
    go(f, "Vai", "quay");
    const nut = within(f).getByRole("button", { name: "Xác nhận duyệt" });
    fireEvent.click(nut);
    fireEvent.click(nut);
    expect(await screen.findByText("Đã duyệt Minh.")).toBeTruthy();
    expect(ghi(goi)).toHaveLength(1);
  });
});

describe("trang nhân viên — từ chối, khoá, mở lại", () => {
  it("từ chối qua bước xác nhận; huỷ thì không gửi", async () => {
    const goi = moTrang({ ghi: () => ketQua(5, "tu_choi") });
    let f = await mo("Từ chối Bình");
    fireEvent.click(within(f).getByRole("button", { name: "Huỷ" }));
    expect(ghi(goi)).toEqual([]);
    f = await mo("Từ chối Bình");
    fireEvent.click(within(f).getByRole("button", { name: "Xác nhận từ chối" }));
    expect(await screen.findByText("Đã từ chối Bình.")).toBeTruthy();
    expect(ghi(goi)).toEqual([{ method: "POST", path: "/accounts/5/rejection", body: undefined }]);
    await waitFor(() => expect(soLanDoc(goi)).toBe(2));
  });

  it("khoá: nói mọi phiên kết thúc ngay; gửi đúng tài khoản, báo, đọc lại", async () => {
    const goi = moTrang({ ghi: () => ketQua(3, "khoa", 3) });
    const f = await mo("Khoá Hoa");
    expect(f.textContent ?? "").toMatch(/phiên.*kết thúc ngay/);
    fireEvent.click(within(f).getByRole("button", { name: "Xác nhận khoá" }));
    expect(await screen.findByText("Đã khoá tài khoản Hoa.")).toBeTruthy();
    expect(ghi(goi)).toEqual([{ method: "POST", path: "/accounts/3/lock", body: undefined }]);
    await waitFor(() => expect(soLanDoc(goi)).toBe(2));
  });

  it("mở lại: mật khẩu tạm dưới 8 ký tự thì không gửi, đánh dấu ô; ô là ô mật khẩu", async () => {
    const goi = moTrang();
    const f = await mo("Mở lại Tuấn");
    const o = within(f).getByLabelText("Mật khẩu tạm") as HTMLInputElement;
    expect(o.type).toBe("password");
    go(f, "Mật khẩu tạm", "1234567");
    fireEvent.click(within(f).getByRole("button", { name: "Xác nhận mở lại" }));
    await waitFor(() => expect(oSai(f, "Mật khẩu tạm")).toBe("true"));
    expect(ghi(goi)).toEqual([]);
  });

  it("mở lại: gửi mật khẩu tạm, báo người ấy phải đổi, đọc lại, không bày lại mật khẩu", async () => {
    const goi = moTrang({ ghi: () => ketQua(4, "hoat_dong", 4) });
    const f = await mo("Mở lại Tuấn");
    go(f, "Mật khẩu tạm", "tam-12345");
    fireEvent.click(within(f).getByRole("button", { name: "Xác nhận mở lại" }));
    expect(await screen.findByText(/Đã mở lại tài khoản Tuấn\..*đổi/)).toBeTruthy();
    expect(ghi(goi)).toEqual([{ method: "POST", path: "/accounts/4/unlock", body: { temporary_password: "tam-12345" } }]);
    await waitFor(() => expect(soLanDoc(goi)).toBe(2));
    expect(document.body.textContent ?? "").not.toContain("tam-12345");
  });

  it("mở lại bị từ chối password_too_short: gắn ô mật khẩu tạm", async () => {
    moTrang({ ghi: () => ({ status: 400, body: { code: "password_too_short" } }) });
    const f = await mo("Mở lại Tuấn");
    go(f, "Mật khẩu tạm", "abcdefgh");
    fireEvent.click(within(f).getByRole("button", { name: "Xác nhận mở lại" }));
    await waitFor(() => expect(oSai(f, "Mật khẩu tạm")).toBe("true"));
  });

  it("khoá tài khoản đã bị khoá ở máy khác (409 account_not_active): nói trạng thái đã đổi, đọc lại", async () => {
    const goi = moTrang({ ghi: () => ({ status: 409, body: { code: "account_not_active" } }) });
    const f = await mo("Khoá Hoa");
    fireEvent.click(within(f).getByRole("button", { name: "Xác nhận khoá" }));
    await waitFor(() => expect(f.textContent ?? "").toMatch(/Trạng thái tài khoản đã đổi/));
    await waitFor(() => expect(soLanDoc(goi)).toBe(2));
  });
});
