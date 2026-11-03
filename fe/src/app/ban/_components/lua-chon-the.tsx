"use client";

import { useState } from "react";
import { ChevronDown } from "lucide-react";
import { chonNhom } from "@/components/shared/bo-soan-mon";
import type { components } from "@/lib/api/schema";

type Nhom = components["schemas"]["MenuOptionGroup"];

export function LuaChonThe({ groups, ids, name, onChange, honHop }: {
  groups: Nhom[]; ids: number[]; name: string; onChange: (ids: number[]) => void;
  honHop?: { active: boolean; onChange: (active: boolean) => void };
}) {
  const [mo, setMo] = useState(false);
  const hien = groups.filter((g) => !g.prerequisite_option_ids.length || g.prerequisite_option_ids.some((id) => ids.includes(id)));
  if (!hien.length) return null;
  return <div className="menu-options">
    <button type="button" className="menu-chip menu-choice" aria-expanded={mo} aria-controls={`${name}-options`} onClick={() => setMo(!mo)}>
      <strong>{hien.map((g) => g.option_group_name === "Nhân" && honHop?.active ? "Mộc nhĩ và thịt" : g.options.find((o) => ids.includes(o.menu_option_id))?.option_name ?? "Chọn").join(" · ")}</strong>
      <ChevronDown aria-hidden="true" size={12} />
    </button>
    <div id={`${name}-options`} className="menu-panel" data-open={mo} aria-hidden={!mo} inert={!mo}><div>
      <div className="menu-option-groups">
        {hien.map((g) => <fieldset key={g.option_group_id}>
          <legend>{g.option_group_name}:</legend>
          <div className="menu-option-grid">{g.options.map((o) => <label className="menu-option" key={o.menu_option_id}>
            <input type="radio" name={`${name}-${g.option_group_id}`} checked={!(g.option_group_name === "Nhân" && honHop?.active) && ids.includes(o.menu_option_id)} onChange={() => {
              if (g.option_group_name === "Nhân") honHop?.onChange(false);
              onChange(chonNhom(groups, [...ids.filter((id) => !g.options.some((v) => v.menu_option_id === id)), o.menu_option_id])); }} />
            <span>{o.option_name}</span>
          </label>)}{g.option_group_name === "Nhân" && honHop && <label className="menu-option">
            <input type="radio" name={`${name}-${g.option_group_id}`} checked={honHop.active} onChange={() => honHop.onChange(true)} />
            <span>Mộc nhĩ và thịt</span>
          </label>}</div>
        </fieldset>)}
      </div>
    </div></div>
  </div>;
}
