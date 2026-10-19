// Test hồi quy P4A-02 — Claude viết TRƯỚC khi có code (L2). Người thi công làm cho xanh, KHÔNG sửa điều kiện kiểm.
// Giữ: tiền tạm tính không bày như doanh thu đã đối soát (shop-facts §8.6 hàng 5); số do backend trả, frontend
// không cộng (ADR-086); mục thiếu dữ liệu nói đúng lý do backend trả, không suy số; ngày bán lấy từ backend
// (01-khung-fe.md §2); ghi xong thì đọc lại, lỗi đọc giữ bản cũ kèm cảnh báo (ADR-102 điểm 1 · 2).
import { focusManager } from "@tanstack/react-query";
import { act, cleanup, fireEvent, screen, waitFor, within } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

import { voiBackend, type GoiDen } from "@/components/tai-khoan/test-utils";
import type { components } from "@/lib/api/schema";

import Page from "./page";

type OwnerOverview = components["schemas"]["OwnerOverview"];

vi.mock("next/navigation", () => ({ useRouter: () => ({ replace: vi.fn() }), usePathname: () => "/chu-quan" }));

beforeEach(() => focusManager.setFocused(undefined));
afterEach(() => {
  cleanup();
  focusManager.setFocused(undefined);
});

function tongQuan(p: Partial<OwnerOverview> = {}): OwnerOverview {
  return {
    sale_date: "2026-10-19",
    read_at: "2026-10-19T06:21:37Z", // 13:21:37 giờ quán (Asia/Ho_Chi_Minh, shop-facts §1)
    serving_guests: { status: "available", name: "Bàn đang phục vụ", quantity: 4 },
    served_portions: {
      status: "available",
      read_at: "2026-10-19T06:21:37Z",
      rows: [
        { group: "in_store", station_code: "banh", menu_component_id: 1, component_name: "Bánh cuốn thịt", filling_option_ids: [], quantity: 12 },
        { group: "online", station_code: "banh", menu_component_id: 1, component_name: "Bánh cuốn thịt", filling_option_ids: [], quantity: 3 },
      ],
    },
    missing_portions: {
      status: "available",
      read_at: "2026-10-19T06:21:37Z",
      rows: [{ group: "in_store", station_code: "banh", menu_component_id: 2, component_name: "Bánh cuốn trứng", filling_option_ids: [], quantity: 5 }],
    },
    sales_progress: { status: "available", name: "Tiến độ bán", served_banh: 15, minimum_banh: 200 },
    provisional_sales: { status: "available", name: "Tiền bán tạm tính", amount_vnd: 1234000 },
    workers_present: {
      status: "available", name: "Người đang làm", worker_count: 3, person_id: 2, person_name: "Lan",
      declared_at: "2026-10-19T01:00:00Z",
    },
    shortages: {
      supplies: {
        status: "available",
        items: [
          {
            supply_item_id: 1, name: "Bột gạo", purchase_unit: "kg", purchased_total: "10", used_total: "9", balance: "1",
            reminder_ratio: "0.2", latest_purchase_date: "2026-10-18", latest_purchase_measure: "10",
            reminder_status: "ready", check_reminder: true,
          },
          {
            supply_item_id: 2, name: "Mộc nhĩ", purchase_unit: "kg", purchased_total: "0", used_total: "0", balance: "0",
            reminder_ratio: "0.2", latest_purchase_date: null, latest_purchase_measure: null,
            reminder_status: "no_purchase", check_reminder: null,
          },
        ],
      },
      workers: { status: "available", name: "Thiếu người", worker_count: 3, minimum_workers: 5, short: true, missing_workers: 2 },
      menu_items: { status: "available", items: [{ menu_item_id: 2, menu_combo_id: null, name: "Bánh cuốn trứng", ordered: 8, served: 3 }] },
    },
    ...p,
  } as OwnerOverview;
}

const doc = (g: GoiDen[]) => g.filter((x) => x.method === "GET" && x.path === "/owner-overview");
const ghi = (g: GoiDen[]) => g.filter((x) => x.method === "PUT");

describe("trang tổng quan của chủ quán", () => {
  it("bày ngày bán và mốc đọc do backend trả, không theo đồng hồ máy", async () => {
    vi.useFakeTimers({ toFake: ["Date"] });
    vi.setSystemTime(new Date("2031-01-01T00:00:00Z"));
    try {
      voiBackend(<Page />, () => ({ status: 200, body: tongQuan() }));
      expect(await screen.findByText(/Ngày bán 19\/10\/2026/)).toBeTruthy();
      expect(screen.getByText(/Đọc lúc 13:21:37/)).toBeTruthy();
      expect(screen.queryByText(/2031/)).toBeNull();
    } finally {
      vi.useRealTimers();
    }
  });

  it("tiền tạm tính: đúng số backend trả, nhãn tạm tính, không một chữ 'doanh thu' nào trên trang", async () => {
    voiBackend(<Page />, () => ({ status: 200, body: tongQuan() }));
    const muc = await screen.findByRole("region", { name: "Tiền bán tạm tính" });
    expect(within(muc).getByText(/1\.234\.000\s?đ/)).toBeTruthy();
    expect(within(muc).getByText(/chưa đối soát/i)).toBeTruthy();
    expect(document.body.textContent ?? "").not.toMatch(/doanh thu/i);
  });

  it("bày đủ bảy mục với số backend trả", async () => {
    voiBackend(<Page />, () => ({ status: 200, body: tongQuan() }));
    expect(await screen.findByText(/4 bàn đang phục vụ/)).toBeTruthy();
    const ra = screen.getByRole("region", { name: "Đã ra" });
    expect(within(within(ra).getByRole("group", { name: "Tại quán" })).getByText(/Bánh cuốn thịt × 12/)).toBeTruthy();
    expect(within(within(ra).getByRole("group", { name: "Giao hàng online" })).getByText(/Bánh cuốn thịt × 3/)).toBeTruthy();
    const thieu = screen.getByRole("region", { name: "Còn thiếu" });
    expect(within(thieu).getByText(/Bánh cuốn trứng × 5/)).toBeTruthy();
    expect(within(screen.getByRole("region", { name: "Tiến độ bán" })).getByText(/15\s*\/\s*200 bánh/)).toBeTruthy();
    expect(within(screen.getByRole("region", { name: "Người đang làm" })).getByText(/3 người/)).toBeTruthy();
    const thieuGi = screen.getByRole("region", { name: "Còn thiếu gì" });
    expect(within(thieuGi).getByText(/Thiếu 2 người/)).toBeTruthy();
    expect(within(thieuGi).getByText(/Bánh cuốn trứng: khách đặt 8, đã ra 3/)).toBeTruthy();
  });

  it("nguyên liệu: bày số dư backend trả và lời nhắc, không tự kết luận khi backend chưa biết (U-102)", async () => {
    voiBackend(<Page />, () => ({ status: 200, body: tongQuan() }));
    const thieuGi = await screen.findByRole("region", { name: "Còn thiếu gì" });
    const bot = within(thieuGi).getByText(/Bột gạo/).closest("li") as HTMLElement;
    expect(within(bot).getByText(/Còn 1 kg/)).toBeTruthy();
    expect(within(bot).getByText(/Nên kiểm tra/)).toBeTruthy();
    const mocNhi = within(thieuGi).getByText(/Mộc nhĩ/).closest("li") as HTMLElement;
    expect(within(mocNhi).getByText(/Chưa đủ dữ liệu để nhắc/)).toBeTruthy();
    expect(within(mocNhi).queryByText(/Nên kiểm tra/)).toBeNull();
  });

  it("thiếu số tối thiểu · POS chưa khai: nói đúng lý do backend trả, không bày số nào", async () => {
    voiBackend(<Page />, () => ({
      status: 200,
      body: tongQuan({
        sales_progress: { status: "unavailable", name: "Tiến độ bán", reason: "daily_minimum_missing" },
        workers_present: { status: "unavailable", name: "Người đang làm", reason: "workers_present_missing" },
        shortages: {
          ...tongQuan().shortages,
          workers: { status: "unavailable", name: "Thiếu người", reason: "workers_present_missing" },
        },
      } as Partial<OwnerOverview>),
    }));
    const tienDo = await screen.findByRole("region", { name: "Tiến độ bán" });
    expect(within(tienDo).getByText(/Chưa nhập số tối thiểu của ngày/)).toBeTruthy();
    expect(within(tienDo).queryByText(/\d+\s*\/\s*\d+/)).toBeNull();
    const nguoi = screen.getByRole("region", { name: "Người đang làm" });
    expect(within(nguoi).getByText(/POS chưa khai số người đang làm/)).toBeTruthy();
    expect(within(nguoi).queryByText(/\d+ người/)).toBeNull();
  });

  it("nhập số tối thiểu: một PUT tới ngày bán backend trả, bấm hai lần vẫn một lần gửi, rồi đọc lại tổng quan", async () => {
    const goi = voiBackend(<Page />, (g) => {
      if (g.method === "PUT") return { status: 200, body: { sale_date: "2026-10-19", minimum_banh: 300, minimum_workers: 6, person_id: 1, created_at: "2026-10-19T06:30:00Z" } };
      return { status: 200, body: tongQuan() };
    });
    await screen.findByRole("region", { name: "Tiền bán tạm tính" });
    fireEvent.change(screen.getByLabelText("Số bánh tối thiểu"), { target: { value: "300" } });
    fireEvent.change(screen.getByLabelText("Số người tối thiểu"), { target: { value: "6" } });
    // Hai lần gửi trong CÙNG một lượt, trước khi kịp render lại — nút tắt theo isPending không chặn được ca này,
    // chỉ chốt đồng bộ chặn được (fe-02 §3).
    const form = screen.getByRole("form", { name: "Số tối thiểu của ngày" }) as HTMLFormElement;
    act(() => {
      form.requestSubmit();
      form.requestSubmit();
    });
    await waitFor(() => expect(doc(goi).length).toBe(2));
    expect(ghi(goi)).toEqual([
      { method: "PUT", path: "/daily-minimums/2026-10-19", body: { minimum_banh: 300, minimum_workers: 6 } },
    ]);
  });

  it("ô tối thiểu điền sẵn số đã nhập của ngày khi backend trả", async () => {
    voiBackend(<Page />, () => ({ status: 200, body: tongQuan() }));
    await screen.findByRole("region", { name: "Tiền bán tạm tính" });
    expect((screen.getByLabelText("Số bánh tối thiểu") as HTMLInputElement).value).toBe("200");
    expect((screen.getByLabelText("Số người tối thiểu") as HTMLInputElement).value).toBe("5");
  });

  it("backend từ chối kèm field: chữ lỗi gắn đúng ô (aria-describedby), không đọc lại", async () => {
    const goi = voiBackend(<Page />, (g) =>
      g.method === "PUT" ? { status: 400, body: { code: "invalid_request", field: "minimum_workers" } } : { status: 200, body: tongQuan() },
    );
    await screen.findByRole("region", { name: "Tiền bán tạm tính" });
    fireEvent.change(screen.getByLabelText("Số bánh tối thiểu"), { target: { value: "300" } });
    fireEvent.change(screen.getByLabelText("Số người tối thiểu"), { target: { value: "6" } });
    fireEvent.click(screen.getByRole("button", { name: "Lưu số tối thiểu" }));
    const o = screen.getByLabelText("Số người tối thiểu");
    await waitFor(() => expect(o.getAttribute("aria-invalid")).toBe("true"));
    const moTa = (o.getAttribute("aria-describedby") ?? "").split(" ").map((id) => document.getElementById(id)?.textContent ?? "");
    expect(moTa.join("").trim()).not.toBe("");
    expect(doc(goi).length).toBe(1);
  });

  it("lần đọc lại lỗi: giữ bản cũ kèm cảnh báo và mốc của bản ấy", async () => {
    let lan = 0;
    voiBackend(<Page />, () => {
      lan += 1;
      if (lan === 1) return { status: 200, body: tongQuan() };
      return { status: 503, body: { code: "khong_co_trong_hop_dong" } };
    });
    await screen.findByText(/4 bàn đang phục vụ/);
    act(() => {
      focusManager.setFocused(false);
      focusManager.setFocused(true);
    });
    expect(await screen.findByRole("alert")).toBeTruthy();
    expect(screen.getByRole("alert").textContent).toMatch(/13:21:37/);
    expect(screen.getByText(/4 bàn đang phục vụ/)).toBeTruthy();
  });
});
