// Test hồi quy P4-06 (nhiều tab cùng máy, giao 2026-10-19 ở T-202 — ADR-102 Sửa đổi) — Claude viết TRƯỚC khi có code.
// Người thi công làm cho xanh, KHÔNG sửa điều kiện kiểm.
// Giữ: đăng xuất hay đăng nhập (đổi người) ở một tab báo qua BroadcastChannel "banhcuon-phien" bằng
// { loai: "doi-phien", tab }; tab khác đang trong một khung xoá sạch cache dữ liệu server và về /dang-nhap ngay, không
// đợi lần gọi trả 401. Tab nhận lại tin của chính nó thì bỏ qua.
import { act, cleanup, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { useQuery } from "@tanstack/react-query";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

import { KhungTheoVai } from "@/components/tai-khoan/khung-theo-vai";
import { voiBackend } from "@/components/tai-khoan/test-utils";
import { call } from "@/lib/api/client";
import { ApiProvider, useApi } from "@/lib/api/provider";

import { useDangNhap } from "./session";

const replace = vi.fn();
vi.mock("next/navigation", () => ({
  useRouter: () => ({ replace, push: vi.fn() }),
  usePathname: () => "/quay",
  useSearchParams: () => new URLSearchParams(),
}));

let kenh: BroadcastChannel;
let nhan: unknown[];
beforeEach(() => {
  replace.mockReset();
  nhan = [];
  kenh = new BroadcastChannel("banhcuon-phien");
  kenh.onmessage = (e) => nhan.push(e.data);
});
afterEach(() => { kenh.close(); cleanup(); });

const phienQuay = { person_id: 7, display_name: "Lan", role_code: "quay", is_owner: false, must_change_password: false, counter_duty_id: 3 };

function Doc() {
  const api = useApi();
  const q = useQuery({ queryKey: ["people"], queryFn: async () => {
    const r = await call(api.GET("/people"));
    if (!r.ok) throw r.failure;
    return r.data;
  } });
  return <p>{q.data ? "có dữ liệu" : "chưa có"}</p>;
}

function moKhung() {
  return voiBackend(<KhungTheoVai khung="/quay"><Doc /></KhungTheoVai>, (g) => {
    if (g.path === "/sessions/current") return { status: 200, body: phienQuay };
    if (g.path === "/people") return { status: 200, body: { people: [] } };
    if (g.path === "/sessions/current/end") return { status: 200, body: { status: "ok" } };
    return { status: 599, body: { code: "khong_co_trong_hop_dong" } };
  });
}
const soLan = (g: { path: string }[], p: string) => g.filter((x) => x.path === p).length;

describe("nhiều tab cùng máy", () => {
  it("tab khác báo đổi phiên ⇒ xoá cache, về /dang-nhap ngay, không cần lời gọi nào trả 401", async () => {
    const goi = moKhung();
    await screen.findByText("có dữ liệu");
    const docPhien = soLan(goi, "/sessions/current");
    await act(async () => { new BroadcastChannel("banhcuon-phien").postMessage({ loai: "doi-phien", tab: "tab-khac" }); });
    await waitFor(() => expect(replace).toHaveBeenCalledWith("/dang-nhap"));
    // Cache đã xoá: dữ liệu cũ không còn trên màn hay sẽ phải đọc lại.
    await waitFor(() => expect(screen.queryByText("có dữ liệu")).toBeNull());
    expect(goi.filter((g) => g.path !== "/sessions/current" && g.path !== "/people")).toEqual([]);
    expect(soLan(goi, "/sessions/current")).toBeGreaterThanOrEqual(docPhien);
  });

  it("tin lạ trên kênh bị bỏ qua", async () => {
    moKhung();
    await screen.findByText("có dữ liệu");
    await act(async () => { new BroadcastChannel("banhcuon-phien").postMessage({ loai: "khac" }); });
    await new Promise((r) => setTimeout(r, 50));
    expect(replace).not.toHaveBeenCalled();
    expect(screen.getByText("có dữ liệu")).toBeTruthy();
  });

  it("đăng xuất ở tab này báo cho tab khác; tab này không tự xử lý tin của chính nó hai lần", async () => {
    const goi = moKhung();
    await screen.findByText("có dữ liệu");
    fireEvent.click(screen.getByRole("button", { name: "Đăng xuất" }));
    await waitFor(() => expect(nhan).toContainEqual(expect.objectContaining({ loai: "doi-phien", tab: expect.any(String) })));
    await waitFor(() => expect(replace).toHaveBeenCalledWith("/dang-nhap"));
    await new Promise((r) => setTimeout(r, 50));
    expect(replace).toHaveBeenCalledTimes(1);
    expect(soLan(goi, "/sessions/current/end")).toBe(1);
  });

  it("đăng nhập thành công ở tab này báo cho tab khác; đăng nhập thất bại thì không", async () => {
    let ok = false;
    function DangNhap() {
      const dn = useDangNhap();
      return <button type="button" onClick={() => dn.mutate({ username: "lan", password: "matkhau123", at_counter: true })}>vào</button>;
    }
    const fetch = async (req: Request) => {
      const path = new URL(req.url).pathname.replace(/^\/api/, "");
      if (path === "/sessions") {
        return ok
          ? new Response(JSON.stringify(phienQuay), { status: 201, headers: { "content-type": "application/json" } })
          : new Response(JSON.stringify({ code: "invalid_credentials", message: "x" }), { status: 401, headers: { "content-type": "application/json" } });
      }
      return new Response(JSON.stringify({ code: "khong_co_trong_hop_dong" }), { status: 599, headers: { "content-type": "application/json" } });
    };
    render(<ApiProvider fetch={fetch}><DangNhap /></ApiProvider>);
    fireEvent.click(screen.getByRole("button", { name: "vào" }));
    await new Promise((r) => setTimeout(r, 50));
    expect(nhan).toEqual([]);
    ok = true;
    fireEvent.click(screen.getByRole("button", { name: "vào" }));
    await waitFor(() => expect(nhan).toContainEqual(expect.objectContaining({ loai: "doi-phien" })));
  });
});
