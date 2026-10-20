// Dữ liệu mẫu cho test P4-09 (không phải file test — không chạy riêng). Hình theo hợp đồng 0.45.0.
import type { components } from "@/lib/api/schema";

type S = components["schemas"];

// Cố ý: trạm "cuon" đứng trước "canh" (không theo chữ cái) — màn giữ thứ tự backend.
export const bangMau: S["ProductionBoard"] = {
  read_at: "2026-10-20T02:30:00Z",
  poll_interval_seconds: 20,
  rows: [
    {
      station_code: "cuon", menu_component_id: 101, component_name: "Bánh cuốn", filling_option_ids: [51],
      ordered: 6, pending: 2, made: 3, served: 1, missing: 5,
      parts: [
        { dining_table_id: 3, sales_order_id: null, ordered: 4, pending: 1, made: 2, served: 1, missing: 3 },
        { dining_table_id: null, sales_order_id: 77, ordered: 2, pending: 1, made: 1, served: 0, missing: 2 },
      ],
    },
    {
      station_code: "canh", menu_component_id: null, component_name: "Nước chấm", filling_option_ids: [],
      ordered: 1, pending: 0, made: 1, served: 0, missing: 1,
      parts: [{ dining_table_id: 3, sales_order_id: null, ordered: 1, pending: 0, made: 1, served: 0, missing: 1 }],
    },
  ],
};

export const banMau: S["DiningTables"] = {
  tables: [{ dining_table_id: 3, label: "Bàn 3", state: "in_session", table_session_id: 9, table_session_status: "serving" }],
};

export const menuMau: S["Menu"] = {
  items: [{
    menu_item_id: 1, item_name: "Bánh cuốn",
    option_groups: [{ option_group_id: 5, option_group_name: "Nhân", prerequisite_option_ids: [],
      options: [{ menu_option_id: 51, option_name: "Thịt", is_default: true }] }],
    prices: [{ option_ids: [51], unit_price_vnd: 35000 }],
  }],
  combos: [],
};
