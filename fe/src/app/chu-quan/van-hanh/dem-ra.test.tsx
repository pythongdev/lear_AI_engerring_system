// T-228 — test viết trước bởi Claude (2026-10-21). Người thi công làm cho xanh, không sửa file này; thấy sai thì báo.
import { cleanup, fireEvent, screen, waitFor, within } from "@testing-library/react";
import { afterEach, describe, expect, it } from "vitest";
import { voiBackend, type GoiDen } from "@/components/tai-khoan/test-utils";
import type { components } from "@/lib/api/schema";
import type { ThuVanHanh } from "../_components/cot-van-hanh";
import type { BangVanHanh } from "../_components/du-lieu-van-hanh";
import Page from "./page";

afterEach(cleanup);
type Hang = components["schemas"]["ProductionRow"];
const thu = (menu_component_id: number, component_name: string, nhan: string | null, extra: Partial<ThuVanHanh> = {}): ThuVanHanh => ({
  menu_component_id, component_name, filling_option_ids: nhan ? [11] : [], options: nhan ? [{ option_group_name: "Nhân", option_name: nhan }] : [],
  extra_filling: false, ordered: 5, served: 1, missing: 4, ...extra,
});
const thit = thu(81, "Bánh cuốn", "Thịt");
const thitNhieu = thu(81, "Bánh cuốn", "Thịt", { filling_option_ids: [11, 15], extra_filling: true, ordered: 2, served: 0, missing: 2 });
const trungTai = thu(83, "Trứng tái", null, { ordered: 1, served: 0, missing: 1 });
const phien = (id: number, tables: { dining_table_id: number; label: string }[], items: ThuVanHanh[]): BangVanHanh["sessions"][number] => ({
  table_session_id: id, session_status: "open", service_group: "serving", tables, order_total_vnd: 50000, served_amount_vnd: 10000, items,
});
const data: BangVanHanh = {
  sale_date: "2025-02-03", read_at: "2025-02-03T03:17:29Z",
  sessions: [phien(1, [{ dining_table_id: 21, label: "Bàn 01" }], [thit, thitNhieu, trungTai]),
    phien(2, [{ dining_table_id: 22, label: "Bàn 02" }, { dining_table_id: 23, label: "Bàn 03" }], [thu(81, "Bánh cuốn", "Thịt")])],
  empty_tables: [], serve_history: [],
};
const part = (dining_table_id: number, made: number) => ({ dining_table_id, sales_order_id: null, ordered: 5, pending: 0, made, served: 1, missing: 4 });
const hang = (station_code: string, x: Pick<ThuVanHanh, "menu_component_id" | "component_name" | "filling_option_ids">, parts: Hang["parts"]): Hang => ({
  station_code, menu_component_id: x.menu_component_id, component_name: x.component_name, filling_option_ids: x.filling_option_ids,
  ordered: 5, pending: 0, made: 0, served: 1, missing: 4, parts,
});
// Bánh cuốn thịt của Bàn 01: tráng xong 3, gấp xong 2 ⇒ đem ra được nhiều nhất 2. Hàng nhiều nhân và bàn khác không được lẫn vào.
const board = { read_at: "2025-02-03T03:17:30Z", poll_interval_seconds: 20 as const, rows: [
  hang("trang_banh", thit, [part(21, 3), part(22, 5)]), hang("gap_banh", thit, [part(21, 2)]),
  hang("trang_banh", thitNhieu, [part(21, 2)]), hang("gap_banh", thitNhieu, [part(21, 2)]),
] };
const phienDangNhap = (counter_duty_id: number | null) => ({ person_id: 7, display_name: "Chủ", role_code: "chu_quan", is_owner: true, must_change_password: false, counter_duty_id });

type TraLoi = { status: number; body?: unknown };
function mo({ quay = 3 as number | null, bang = () => ({ status: 200, body: board }) as TraLoi, ghi = () => ({ status: 200, body: { station_job_ids: [1, 2, 3, 4], completed_order_ids: [] } }) as TraLoi } = {}) {
  return voiBackend(<Page />, (g: GoiDen): TraLoi => {
    if (g.path === "/sessions/current") return { status: 200, body: phienDangNhap(quay) };
    if (g.path === "/service-board") return { status: 200, body: data };
    if (g.path === "/production-board") return bang();
    if (g.path === "/served-marks") return ghi();
    return { status: 404, body: { code: "not_found" } };
  });
}
const vung = async () => within(await screen.findByRole("region", { name: "Bảng tổng thiếu" }));
const posts = (g: GoiDen[]) => g.filter((x) => x.method === "POST");
async function chon(ten: string, so: string) {
  fireEvent.click((await vung()).getByRole("button", { name: ten }));
  const hop = await screen.findByRole("dialog", { name: new RegExp(`${ten.replace("Đem ra ", "")}: đã đem ra mấy\\?`) });
  fireEvent.click(within(hop).getByRole("button", { name: so }));
}

describe("Vận hành — bấm ô số ghi đã đem ra (T-228)", () => {
  it("đứng quầy: mỗi thứ còn thiếu của phiên một bàn là một nút riêng; thịt thường và thịt nhiều tách dòng", async () => {
    mo(); const b = await vung();
    for (const ten of ["Đem ra Bàn 01 · Thịt", "Đem ra Bàn 01 · Thịt nhiều", "Đem ra Bàn 01 · Trứng tái"]) expect(b.getByRole("button", { name: ten })).toBeTruthy();
    expect(screen.getByText("Bấm vào một ô số để báo đã đem ra.")).toBeTruthy();
  });
  it("không đứng quầy: không nút số, có câu nói rõ vì sao, không gọi cửa ghi", async () => {
    const g = mo({ quay: null }); const b = await vung();
    await waitFor(() => expect(screen.getByText(/Chỉ người đang đứng quầy ghi được đem ra/)).toBeTruthy());
    expect(b.queryAllByRole("button", { name: /^Đem ra / })).toHaveLength(0);
    expect(posts(g)).toHaveLength(0);
  });
  it("phiên ghép nhiều bàn: ô chỉ đọc, có câu chỉ sang màn Sản xuất của quầy", async () => {
    mo(); const b = await vung();
    expect(b.queryByRole("button", { name: /^Đem ra Bàn 02 \+ Bàn 03/ })).toBeNull();
    expect(screen.getByText(/Bàn 02 \+ Bàn 03.*màn Sản xuất của quầy/)).toBeTruthy();
  });
  it("ô chọn đọc bảng sản xuất lúc bấm: số lớn nhất = min(thiếu, đã làm ở từng trạm của bàn ấy) và nói phần chưa làm xong", async () => {
    const g = mo(); fireEvent.click((await vung()).getByRole("button", { name: "Đem ra Bàn 01 · Thịt" }));
    const hop = await screen.findByRole("dialog", { name: "Bàn 01 · Thịt: đã đem ra mấy?" });
    expect(within(hop).getAllByRole("button").map((x) => x.textContent)).toEqual(["0", "1", "2"]);
    expect(hop.textContent).toContain("Còn 2 cái chưa làm xong.");
    expect(g.filter((x) => x.path === "/production-board")).toHaveLength(1);
  });
  it("chọn 0 đóng ô, không ghi; chọn số rồi Huỷ ở hộp xác nhận cũng không ghi", async () => {
    const g = mo(); await chon("Đem ra Bàn 01 · Thịt", "0");
    await waitFor(() => expect(screen.queryByRole("dialog")).toBeNull());
    await chon("Đem ra Bàn 01 · Thịt", "2");
    const xn = await screen.findByRole("dialog", { name: "Xác nhận đem ra" });
    fireEvent.click(within(xn).getByRole("button", { name: "Huỷ" }));
    await waitFor(() => expect(screen.queryByRole("dialog")).toBeNull());
    expect(posts(g)).toHaveLength(0);
  });
  it("xác nhận nhắc lại số cái, bàn, thiếu trước → sau; gửi một hàng mỗi trạm của đúng khoá gom và đọc lại bảng", async () => {
    const g = mo(); await chon("Đem ra Bàn 01 · Thịt", "2");
    const xn = await screen.findByRole("dialog", { name: "Xác nhận đem ra" });
    expect(xn.textContent).toContain("Quán đã đem ra 2 cái Thịt cho Bàn 01. Còn thiếu sẽ từ 4 xuống 2.");
    const truoc = g.filter((x) => x.path === "/service-board").length;
    fireEvent.click(within(xn).getByRole("button", { name: "Xác nhận" }));
    await waitFor(() => expect(posts(g)).toHaveLength(1));
    expect(posts(g)[0]).toEqual({ method: "POST", path: "/served-marks", body: { dining_table_id: 21, items: [
      { station_code: "trang_banh", menu_component_id: 81, filling_option_ids: [11], quantity: 2 },
      { station_code: "gap_banh", menu_component_id: 81, filling_option_ids: [11], quantity: 2 },
    ] } });
    expect((await screen.findByRole("status", { name: "Kết quả đem ra" })).textContent).toBe("Đã ghi đem ra 2 cái Thịt cho Bàn 01.");
    await waitFor(() => expect(g.filter((x) => x.path === "/service-board").length).toBe(truoc + 1));
  });
  it("hàng nhiều nhân gửi đúng khoá gom của nó, không lẫn hàng thịt thường", async () => {
    const g = mo(); await chon("Đem ra Bàn 01 · Thịt nhiều", "1");
    fireEvent.click(within(await screen.findByRole("dialog", { name: "Xác nhận đem ra" })).getByRole("button", { name: "Xác nhận" }));
    await waitFor(() => expect(posts(g)).toHaveLength(1));
    expect((posts(g)[0].body as { items: unknown[] }).items).toEqual([
      { station_code: "trang_banh", menu_component_id: 81, filling_option_ids: [11, 15], quantity: 1 },
      { station_code: "gap_banh", menu_component_id: 81, filling_option_ids: [11, 15], quantity: 1 },
    ]);
  });
  it("bấm Xác nhận hai lần chỉ gửi một lần", async () => {
    const g = mo(); await chon("Đem ra Bàn 01 · Thịt", "1");
    const nut = within(await screen.findByRole("dialog", { name: "Xác nhận đem ra" })).getByRole("button", { name: "Xác nhận" });
    fireEvent.click(nut); fireEvent.click(nut);
    await waitFor(() => expect(screen.queryByRole("dialog")).toBeNull());
    expect(posts(g)).toHaveLength(1);
  });
  it.each([
    ["served_quantity_exceeds_made", 409, "Số ra bàn vượt số đã làm", true],
    ["not_on_counter_duty", 403, "chưa đứng quầy", false],
  ])("cửa từ chối %s: báo theo mã, không báo đã ghi", async (code, status, text, docLai) => {
    const g = mo({ ghi: () => ({ status, body: { code, message: "x" } }) });
    await chon("Đem ra Bàn 01 · Thịt", "1");
    const truoc = g.filter((x) => x.path === "/service-board").length;
    fireEvent.click(within(await screen.findByRole("dialog", { name: "Xác nhận đem ra" })).getByRole("button", { name: "Xác nhận" }));
    expect((await screen.findByRole("alert")).textContent).toContain(text);
    expect(screen.queryByText(/^Đã ghi đem ra/)).toBeNull();
    if (docLai) await waitFor(() => expect(g.filter((x) => x.path === "/service-board").length).toBe(truoc + 1));
  });
  it("đọc bảng sản xuất lỗi: ô chọn báo lỗi, không có nút số nào ngoài đóng", async () => {
    mo({ bang: () => ({ status: 500, body: { code: "internal", message: "x" } }) });
    fireEvent.click((await vung()).getByRole("button", { name: "Đem ra Bàn 01 · Thịt" }));
    const hop = await screen.findByRole("dialog", { name: "Bàn 01 · Thịt: đã đem ra mấy?" });
    expect((await within(hop).findByRole("alert")).textContent).toContain("Chưa đọc được số đã làm");
    expect(within(hop).queryByRole("button", { name: "1" })).toBeNull();
  });
});
