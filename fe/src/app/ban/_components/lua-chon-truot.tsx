"use client";

import { useState } from "react";
import { ChevronDown } from "lucide-react";
import { chonNhom } from "@/components/shared/bo-soan-mon";
import type { components } from "@/lib/api/schema";

type Nhom = components["schemas"]["MenuOptionGroup"];

// Mỗi nhóm là một nút; bấm thì danh sách lựa chọn trượt xuống ngay trong thẻ, như "Chi tiết".
export function LuaChonTruot({ groups, ids, name, onChange }: {
  groups: Nhom[]; ids: number[]; name: string; onChange: (ids: number[]) => void;
}) {
  const [mo, setMo] = useState<number | null>(null);
  return groups.filter((g) => !g.prerequisite_option_ids.length || g.prerequisite_option_ids.some((id) => ids.includes(id))).map((g) => {
    const daChon = g.options.find((o) => ids.includes(o.menu_option_id));
    const open = mo === g.option_group_id;
    const panel = `${name}-${g.option_group_id}-ds`;
    return <div className="choice" key={g.option_group_id}>
      <button type="button" className="choice-trigger" aria-expanded={open} aria-controls={panel} onClick={() => setMo(open ? null : g.option_group_id)}>
        {g.option_group_name}: <strong>{daChon?.option_name ?? "Chọn"}</strong> <ChevronDown aria-hidden="true" size={11} />
      </button>
      <div id={panel} className="detail" data-open={open} aria-hidden={!open} inert={!open}>
        <fieldset className="choice-list">
          <legend className="sr-only">{g.option_group_name}</legend>
          {g.options.map((o) => <label className="choice-option" key={o.menu_option_id}>
            <input type="radio" name={`${name}-${g.option_group_id}`} checked={ids.includes(o.menu_option_id)} onChange={() => {
              onChange(chonNhom(groups, [...ids.filter((id) => !g.options.some((v) => v.menu_option_id === id)), o.menu_option_id]));
              setMo(null);
            }} onClick={() => { if (ids.includes(o.menu_option_id)) setMo(null); }} />
            {o.option_name}
          </label>)}
        </fieldset>
      </div>
    </div>;
  });
}
