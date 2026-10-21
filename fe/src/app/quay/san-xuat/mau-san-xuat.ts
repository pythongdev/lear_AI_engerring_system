// Dữ liệu mẫu cho test P4-09 (không phải file test — không chạy riêng). Hình theo hợp đồng 0.45.0; viecMau · ungVienMau theo 0.46.0.
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

// GET /counter/station-jobs (T-217, hợp đồng 0.46.0) cho bấm mẻ · lùi mẻ · chuyển · ghi làm sai (P4-09 phần còn lại).
// 11 · 12 chờ (cùng hàng Bánh cuốn · Thịt); 13 · 14 đã làm của đơn đang làm; 20 · 21 đã làm của đơn huỷ — 20 chuyển được,
// 21 đã có ghi làm sai. Mẻ 901 có việc đã ra bàn.
export const viecMau: S["CounterStationJobs"] = {
  read_at: "2026-10-20T02:30:00Z",
  poll_interval_seconds: 20,
  jobs: [
    { station_job_id: 11, sales_order_id: 70, dining_table_id: 3, station_code: "cuon", menu_component_id: 101, component_name: "Bánh cuốn",
      filling_option_ids: [51], status: "pending", order_status: "in_progress", production_batch_id: null, wrong_make_note_id: null, transferable: false },
    { station_job_id: 12, sales_order_id: 77, dining_table_id: null, station_code: "cuon", menu_component_id: 101, component_name: "Bánh cuốn",
      filling_option_ids: [51], status: "pending", order_status: "in_progress", production_batch_id: null, wrong_make_note_id: null, transferable: false },
    { station_job_id: 13, sales_order_id: 70, dining_table_id: 3, station_code: "cuon", menu_component_id: 101, component_name: "Bánh cuốn",
      filling_option_ids: [51], status: "made", order_status: "in_progress", production_batch_id: 900, wrong_make_note_id: null, transferable: false },
    { station_job_id: 14, sales_order_id: 70, dining_table_id: 3, station_code: "canh", menu_component_id: null, component_name: "Nước chấm",
      filling_option_ids: [], status: "served", order_status: "in_progress", production_batch_id: 901, wrong_make_note_id: null, transferable: false },
    { station_job_id: 20, sales_order_id: 80, dining_table_id: null, station_code: "cuon", menu_component_id: 101, component_name: "Bánh cuốn",
      filling_option_ids: [51], status: "made", order_status: "cancelled", production_batch_id: 902, wrong_make_note_id: null, transferable: true },
    { station_job_id: 21, sales_order_id: 81, dining_table_id: null, station_code: "cuon", menu_component_id: 101, component_name: "Bánh cuốn",
      filling_option_ids: [51], status: "made", order_status: "cancelled", production_batch_id: 902, wrong_make_note_id: 5, transferable: false },
  ],
  batches: [
    { production_batch_id: 900, made_at: "2026-10-20T02:20:00Z", station_job_ids: [13], has_served_units: false },
    { production_batch_id: 901, made_at: "2026-10-20T02:21:00Z", station_job_ids: [14], has_served_units: true },
    { production_batch_id: 902, made_at: "2026-10-20T02:22:00Z", station_job_ids: [20, 21], has_served_units: false },
  ],
};

export const ungVienMau: S["TransferCandidates"] = {
  station_job_id: 20,
  candidates: [
    { station_job_id: 11, sales_order_id: 70, dining_table_id: 3 },
    { station_job_id: 12, sales_order_id: 77, dining_table_id: null },
  ],
};
