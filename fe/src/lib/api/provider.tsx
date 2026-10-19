"use client";
// Một client API và một QueryClient cho cả cây màn (ADR-102 điểm 3). Test bọc màn bằng ApiProvider với
// `fetch` giả để không cần backend. Giữ mặc định đọc lại khi quay lại cửa sổ — dữ liệu không giữ cũ (T-202).
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { createContext, useContext, useState, type ReactNode } from "react";

import { createApi, type ApiClient, type ApiOptions } from "./client";

const ApiContext = createContext<ApiClient | null>(null);

export function ApiProvider({ children, fetch }: { children: ReactNode; fetch?: ApiOptions["fetch"] }) {
  const [api] = useState(() => createApi({ baseUrl: fetch ? "http://fe.test/api" : "/api", fetch }));
  const [queries] = useState(
    () => new QueryClient({ defaultOptions: { queries: { retry: false } } }),
  );
  return (
    <ApiContext.Provider value={api}>
      <QueryClientProvider client={queries}>{children}</QueryClientProvider>
    </ApiContext.Provider>
  );
}

export function useApi(): ApiClient {
  const api = useContext(ApiContext);
  if (api === null) throw new Error("useApi phải nằm trong ApiProvider");
  return api;
}
