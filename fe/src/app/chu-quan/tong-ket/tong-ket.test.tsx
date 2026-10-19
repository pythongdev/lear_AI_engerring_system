// Test hồi quy P4A-03 — Claude viết TRƯỚC khi có code (L2). Người thi công làm cho xanh, KHÔNG sửa điều kiện kiểm.
// Giữ: ngày xem là ngày bán — mặc định lấy sale_date backend trả, ngày chọn đi trên URL, không suy từ đồng hồ máy
// (01-khung-fe.md §2, 02-thoi-gian-ngay-ban.md); mọi số tiền là số backend trả, frontend không cộng trừ (ADR-086);
// món và người giữ đúng thứ tự backend, người làm là số đếm — không chấm điểm, không xếp hạng (shop-facts §8.6);
// nhắc kiểm tra nguyên liệu là kết quả hiện tại, không phải ảnh của ngày đang xem (hợp đồng 0.40.0).
import { cleanup, fireEvent, screen, waitFor, within } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

import { voiBackend, type GoiDen } from "@/components/tai-khoan/test-utils";
import type { components } from "@/lib/api/schema";

import Page from "./page";

type SaleDaySummary = components["schemas"]["SaleDaySummary"];

const push = vi.fn();
const replace = vi.fn();
let thamSo = "";
vi.mock("next/navigation", () => ({
  useRouter: () => ({ push, replace }),
  usePathname: () => "/chu-quan/tong-ket",
  useSearchParams: () => new URLSearchParams(thamSo),
}));

beforeEach(() => {
  push.mockReset();
  replace.mockReset();
  thamSo = "";
});
afterEach(cleanup);

// Chỉ các trường trang này đọc từ tổng quan: sale_date là "hôm nay" theo backend.
const tongQuan = { sale_date: "2026-10-19", read_at: "2026-10-19T06:21:37Z" };

function tongKet(p: Partial<SaleDaySummary> = {}): SaleDaySummary {
  return {
    revenue: {
      table_session_vnd: 1200000, standalone_vnd: 300000, refunds_vnd: 50000,
      // Cố ý không bằng 1200000 + 300000 - 50000: trang phải bày đúng số backend trả, không tự tính.
      total_vnd: 1449000,
      reconciliation_status: null, paper_entries_pending: 0,
    },
    best_sellers: {
      // Cố ý không theo quantity giảm dần: trang giữ thứ tự backend, không tự xếp.
      items: [
        { menu_item_id: 1, name: "Bánh cuốn thịt", quantity: 3 },
        { menu_item_id: 2, name: "Bánh cuốn trứng", quantity: 7 },
      ],
      combos: [{ menu_combo_id: 9, name: "Combo sáng", quantity: 4 }],
    },
    supply_reminders: {
      read_at: "2026-10-19T07:05:09Z", // 14:05:09 giờ quán
      items: [{ supply_item_id: 1, name: "Bột gạo", purchase_unit: "kg" }],
    },
    staff: [
      { person_id: 1, display_name: "Hoa", worked: true, counter_orders: 2, deliveries: 0, cancellations: 0, refunds: 0 },
      { person_id: 2, display_name: "Lan", worked: false, counter_orders: 40, deliveries: 6, cancellations: 3, refunds: 1 },
    ],
    ...p,
  };
}

type TraLoi = { status: number; body?: unknown };
function moTrang(tl: { tongKet?: (g: GoiDen) => TraLoi } = {}) {
  return voiBackend(<Page />, (g) => {
    if (g.path === "/owner-overview") return { status: 200, body: tongQuan };
    if (g.path.startsWith("/sale-days/")) return tl.tongKet ? tl.tongKet(g) : { status: 200, body: tongKet() };
    return { status: 599, body: { code: "khong_co_trong_hop_dong" } };
  });
}
const docTongKet = (g: GoiDen[]) => g.filter((x) => x.method === "GET" && x.path.startsWith("/sale-days/")).map((x) => x.path);

describe("trang tổng kết theo ngày bán", () => {
  it("không có ngày trên URL: đọc ngày bán backend trả, không theo đồng hồ máy", async () => {
    vi.useFakeTimers({ toFake: ["Date"] });
    vi.setSystemTime(new Date("2031-01-01T00:00:00Z"));
    try {
      const goi = moTrang();
      expect(await screen.findByRole("region", { name: "Doanh thu" })).toBeTruthy();
      expect(docTongKet(goi)).toEqual(["/sale-days/2026-10-19/summary"]);
      expect((screen.getByLabelText("Ngày bán") as HTMLInputElement).value).toBe("2026-10-19");
      expect(document.body.textContent ?? "").not.toMatch(/2031/);
    } finally {
      vi.useRealTimers();
    }
  });

  it("ngày trên URL: đọc đúng ngày ấy", async () => {
    thamSo = "ngay=2026-10-15";
    const goi = moTrang();
    await screen.findByRole("region", { name: "Doanh thu" });
    expect(docTongKet(goi)).toEqual(["/sale-days/2026-10-15/summary"]);
    expect((screen.getByLabelText("Ngày bán") as HTMLInputElement).value).toBe("2026-10-15");
  });

  it("chọn ngày khác: ngày mới đi lên URL", async () => {
    moTrang();
    await screen.findByRole("region", { name: "Doanh thu" });
    fireEvent.change(screen.getByLabelText("Ngày bán"), { target: { value: "2026-10-12" } });
    expect(push).toHaveBeenCalledWith("/chu-quan/tong-ket?ngay=2026-10-12");
  });

  it("doanh thu: bày đúng bốn số backend trả, tổng không tự tính, kèm trạng thái chưa đối soát", async () => {
    moTrang();
    const muc = await screen.findByRole("region", { name: "Doanh thu" });
    const chu = muc.textContent ?? "";
    expect(chu).toMatch(/Phiên bàn[^\d]*1\.200\.000\s?đ/);
    expect(chu).toMatch(/Đơn lẻ[^\d]*300\.000\s?đ/);
    expect(chu).toMatch(/Hoàn tiền[^\d]*50\.000\s?đ/);
    expect(chu).toMatch(/Tổng[^\d]*1\.449\.000\s?đ/);
    expect(chu).not.toMatch(/1\.450\.000/);
    expect(within(muc).getByText(/Chưa đối soát/)).toBeTruthy();
  });

  it("doanh thu âm, đã đối soát, còn sổ giấy chờ: bày đúng như backend trả", async () => {
    moTrang({
      tongKet: () => ({
        status: 200,
        body: tongKet({
          revenue: {
            table_session_vnd: 0, standalone_vnd: 0, refunds_vnd: 80000, total_vnd: -80000,
            reconciliation_status: "reconciled", paper_entries_pending: 2,
          },
        }),
      }),
    });
    const muc = await screen.findByRole("region", { name: "Doanh thu" });
    expect(muc.textContent ?? "").toMatch(/Tổng[^\d-]*-80\.000\s?đ/);
    expect(within(muc).getByText(/Đã đối soát/)).toBeTruthy();
    expect(within(muc).getByText(/2 mục sổ giấy còn chờ/)).toBeTruthy();
  });

  it("món bán chạy: món và combo tách riêng, giữ đúng thứ tự backend", async () => {
    moTrang();
    const muc = await screen.findByRole("region", { name: "Món bán chạy" });
    const mon = within(muc).getByRole("group", { name: "Món" });
    const chuMon = mon.textContent ?? "";
    expect(chuMon).toMatch(/Bánh cuốn thịt[^\d]*3/);
    expect(chuMon.indexOf("Bánh cuốn thịt")).toBeLessThan(chuMon.indexOf("Bánh cuốn trứng"));
    expect(within(within(muc).getByRole("group", { name: "Combo" })).getByText(/Combo sáng/)).toBeTruthy();
    expect(within(mon).queryByText(/Combo sáng/)).toBeNull();
  });

  it("ngày chưa bán gì: nói chưa có, không lỗi", async () => {
    moTrang({ tongKet: () => ({ status: 200, body: tongKet({ best_sellers: { items: [], combos: [] }, staff: [] }) }) });
    const muc = await screen.findByRole("region", { name: "Món bán chạy" });
    expect(within(muc).getByText(/Chưa bán món nào trong ngày/)).toBeTruthy();
    expect(screen.queryByRole("alert")).toBeNull();
  });

  it("người làm: số đếm theo thứ tự backend, không điểm, không hạng", async () => {
    moTrang();
    const muc = await screen.findByRole("region", { name: "Hiệu suất nhân viên" });
    const chu = muc.textContent ?? "";
    expect(chu.indexOf("Hoa")).toBeLessThan(chu.indexOf("Lan"));
    expect(chu).toMatch(/Đơn ghi ở quầy[^\d]*40/);
    expect(chu).toMatch(/Lần đi giao[^\d]*6/);
    expect(chu).toMatch(/Lần huỷ[^\d]*3/);
    expect(chu).toMatch(/Lần hoàn tiền[^\d]*1/);
    expect(chu).toMatch(/Không đi làm/);
    expect(chu).not.toMatch(/hạng|điểm|top|#\s?\d/i);
  });

  it("nhắc kiểm tra nguyên liệu: là kết quả hiện tại có mốc đọc, nói rõ khi ngày xem không phải hôm nay", async () => {
    thamSo = "ngay=2026-10-15";
    moTrang();
    const muc = await screen.findByRole("region", { name: "Cảnh báo sắp hết" });
    expect(within(muc).getByText(/Bột gạo/)).toBeTruthy();
    const chu = muc.textContent ?? "";
    expect(chu).toMatch(/hiện tại/i);
    expect(chu).toMatch(/14:05:09/);
    expect(chu).toMatch(/không phải của ngày 15\/10\/2026/);
  });

  it("nhắc kiểm tra khi xem hôm nay: không có câu 'không phải của ngày'", async () => {
    moTrang();
    const muc = await screen.findByRole("region", { name: "Cảnh báo sắp hết" });
    expect(muc.textContent ?? "").toMatch(/hiện tại/i);
    expect(muc.textContent ?? "").not.toMatch(/không phải của ngày/);
  });

  it("ngày trên URL sai: backend từ chối, trang báo ngày không hợp lệ", async () => {
    thamSo = "ngay=2026-13-40";
    moTrang({ tongKet: () => ({ status: 400, body: { code: "invalid_request", field: "sale_date" } }) });
    await waitFor(() => expect(screen.getByRole("alert").textContent ?? "").toMatch(/Ngày không hợp lệ/));
    expect(screen.queryByRole("region", { name: "Doanh thu" })).toBeNull();
  });

  it("đang đọc lần đầu: có chữ chỉ báo", () => {
    moTrang();
    expect(screen.getByText(/Đang đọc tổng kết…/)).toBeTruthy();
  });
});
