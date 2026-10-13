import type { NextConfig } from "next";

// QC-18 · ADR-102 điểm 3: không cơ chế cache nào của Next bọc dữ liệu server —
// create-next-app 16.4 bật sẵn cacheComponents và partialPrefetching, tắt ở đây.
// compress tắt để tầng chuyển tiếp không đệm luồng text/event-stream (ADR-102 điểm 6 · 7).
const nextConfig: NextConfig = {
  cacheComponents: false,
  partialPrefetching: false,
  compress: false,
  turbopack: {
    rules: {
      "*.css": {
        loaders: ["@tailwindcss/turbopack"],
        as: "*.css",
      },
    },
  },
};

export default nextConfig;
