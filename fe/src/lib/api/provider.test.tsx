import { focusManager, useQuery } from "@tanstack/react-query";
import { act, cleanup, render, screen, waitFor } from "@testing-library/react";
import { afterEach, expect, it, vi } from "vitest";

import { ApiProvider, useApi } from "./provider";

afterEach(() => {
  cleanup();
  focusManager.setFocused(undefined);
});

function People() {
  const api = useApi();
  const query = useQuery({
    queryKey: ["people"],
    queryFn: () => api.GET("/people"),
  });
  return <p>{query.isSuccess ? "Đã đọc" : "Đang đọc"}</p>;
}

it("ApiProvider đọc lại query khi quay lại cửa sổ (ADR-102 điểm 3)", async () => {
  const fetch = vi.fn(async () => new Response(JSON.stringify([]), {
    status: 200,
    headers: { "content-type": "application/json" },
  }));

  render(<ApiProvider fetch={fetch}><People /></ApiProvider>);
  await screen.findByText("Đã đọc");
  expect(fetch).toHaveBeenCalledTimes(1);

  act(() => {
    focusManager.setFocused(false);
    focusManager.setFocused(true);
  });

  await waitFor(() => expect(fetch).toHaveBeenCalledTimes(2));
});
