// Địa chỉ backend chỉ đọc ở phía server (ADR-102 điểm 6): trình duyệt không biết nó.
// Không đặt tiền tố NEXT_PUBLIC_ — tiền tố ấy đưa biến vào gói gửi xuống trình duyệt.
// Mặc định khớp cổng mặc định của be/cmd/server (BANHCUON_ADDR ":8080") trên máy phát triển.
export function backendUrl(): string {
  return (process.env.BANHCUON_BE_URL ?? "http://127.0.0.1:8080").replace(/\/+$/, "");
}
