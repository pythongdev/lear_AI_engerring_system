// T-212 — POS giao việc và ghi đào tạo từ quầy (U-089 · U-090): hai route trong khung /quay dùng lại trang của chủ quán.
// Giữ: POS thấy hai lối vào ở /quay; trang nằm trong khung Quầy; chủ quán mở route quầy thì về /chu-quan (khung là tiện,
// backend vẫn chặn); đổi bộ lọc ở /quay/dao-tao giữ đường dẫn của quầy.
import { cleanup, fireEvent, screen, waitFor } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

import { voiBackend } from "@/components/tai-khoan/test-utils";

import QuayPage from "./page";
import GiaoViecPage from "./giao-viec/page";
import DaoTaoPage from "./dao-tao/page";

const replace = vi.fn();
let duongDan = "/quay";
vi.mock("next/navigation", () => ({
  useRouter: () => ({ replace, push: vi.fn() }),
  usePathname: () => duongDan,
  useSearchParams: () => new URLSearchParams(),
}));
beforeEach(() => replace.mockReset());
afterEach(cleanup);

const phien = (chuQuan: boolean) => ({ person_id: 7, display_name: "Lan", role_code: chuQuan ? "owner" : "quay",
  is_owner: chuQuan, must_change_password: false, counter_duty_id: chuQuan ? 0 : 3 });
const nguoi = [{ person_id: 7, display_name: "Lan" }, { person_id: 9, display_name: "Mai" }];
function mo(ui: React.ReactElement, chuQuan = false) {
  return voiBackend(ui, (g) => {
    if (g.path === "/sessions/current") return { status: 200, body: phien(chuQuan) };
    if (g.path === "/people") return { status: 200, body: { people: nguoi } };
    if (g.path.startsWith("/assigned-tasks")) return { status: 200, body: { assigned_tasks: [] } };
    if (g.path.startsWith("/training-records")) return { status: 200, body: { training_records: [] } };
    return { status: 599, body: { code: "khong_co_trong_hop_dong" } };
  });
}

describe("khung quầy — giao việc và đào tạo (T-212)", () => {
  it("POS thấy hai lối vào ở /quay", async () => {
    duongDan = "/quay";
    mo(<QuayPage />);
    const nav = await screen.findByRole("navigation", { name: "Việc ở quầy" });
    expect(nav.querySelector('a[href="/quay/giao-viec"]')?.textContent).toBe("Giao việc");
    expect(nav.querySelector('a[href="/quay/dao-tao"]')?.textContent).toBe("Đào tạo");
  });
  it("/quay/giao-viec bày trang giao việc trong khung Quầy, đọc cửa sẵn có", async () => {
    duongDan = "/quay/giao-viec";
    const g = mo(<GiaoViecPage />);
    expect(await screen.findByRole("heading", { name: "Giao việc" })).toBeTruthy();
    expect(screen.getByText("Quầy")).toBeTruthy();
    await waitFor(() => expect(g.some((x) => x.path.startsWith("/assigned-tasks"))).toBe(true));
    expect(replace).not.toHaveBeenCalled();
  });
  it("chủ quán mở route quầy thì về /chu-quan", async () => {
    duongDan = "/quay/giao-viec";
    mo(<GiaoViecPage />, true);
    await waitFor(() => expect(replace).toHaveBeenCalledWith("/chu-quan"));
  });
  it("/quay/dao-tao: đổi bộ lọc giữ đường dẫn của quầy", async () => {
    duongDan = "/quay/dao-tao";
    mo(<DaoTaoPage />);
    expect(await screen.findByRole("heading", { name: "Đào tạo" })).toBeTruthy();
    const loc = await screen.findByLabelText("Lọc người");
    await waitFor(() => expect((loc as HTMLSelectElement).options.length).toBeGreaterThan(1));
    fireEvent.change(loc, { target: { value: "9" } });
    expect(replace).toHaveBeenCalledWith("/quay/dao-tao?nguoi=9", { scroll: false });
  });
});
