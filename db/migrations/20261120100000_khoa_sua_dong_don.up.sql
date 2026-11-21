-- T-341 — I-034, theo phiếu Claude 2026-11-20.
-- Hai luật dòng combo có ít nhất một suất con và không mang lựa chọn chỉ được trigger xét lúc INSERT.
-- Thu quyền sửa để UPDATE không tách suất con hay chuyển lựa chọn sang dòng combo mà bỏ qua hai luật.
REVOKE UPDATE ON order_line, order_line_option FROM shop_app;
