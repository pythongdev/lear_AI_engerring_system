# Sổ finding — lane BA

> Cập nhật **2026-08-19** · Lane sở hữu: **BA** · Sổ **finding** của riêng lane này.
> Sổ **task** của lane: [task_BA.md](task_BA.md). Lane chưa tách vẫn dùng [/finding.md](../../finding.md).
> **File này đo *đúng / sai*, không đo *xong / chưa*** — việc chưa tới lượt xây đi sổ task ([§7](../../CLAUDE.md)).
> Mức, trạng thái, luật đóng: dùng nguyên khuôn ở [/finding.md §Quy ước](../../finding.md) — **không chép về đây** ([§2.1](../../CLAUDE.md)).

## Cửa vào — dòng nào được nằm ở sổ này

Hai câu hỏi, phải trả lời **có** cả hai:

1. **Đang sai ngay bây giờ?** Chạy hết [ke-hoach.md](ke-hoach.md) + [task_BA.md](task_BA.md) y như nó viết —
   dòng này còn không? **Còn** ⇒ finding. **Mất** ⇒ task, về [task_BA.md](task_BA.md).
   Câu mở đầu bằng *"chưa có X"* gần như luôn là task ([F-65](../../finding.md#f-65)).
2. **Lane BA là lane phải sửa?** Nhà của một finding là **sổ của lane sở hữu vùng phải sửa**, không phải
   lane phát hiện ra nó. Sai lệch trong `code/be/migrations/` ⇒ sổ lane DB; trong `00-scope.md` ⇒ sổ chung.
   Finding chạm 2 lane ⇒ **sống ở sổ của lane phải sửa**, lane kia chỉ **đặt link** — không mở dòng thứ hai.

**ID:** `F-BA-xx`, đánh số tăng dần trong file này, độc lập với `F-xx` của sổ chung. Số kế tiếp:
`grep -o 'F-BA-[0-9]*' design/BA/finding_BA.md | sort -u | tail -1`.

## Bảng tổng hợp

| ID | Mức | Finding | Trạng thái | Chặn việc gì | Context |
|---|---|---|---|---|---|
| [F-BA-01](#f-ba-01) | 🟠 | *Bàn trống* và *không còn phiên chưa đóng* là **hai nguồn sự thật cho cùng một mệnh đề**, và chưa ai chọn nguồn nào thắng | 🔓 MỞ | `T-BA-07` · bảng bất biến của pha 1 | **Nạp:** [prompt-fullstack §6.2](../../project_preparation/prompt-fullstack.md) dòng `I8` · **Đã chốt:** đây là **quyết định nghiệp vụ**, không phải chuyện kỹ thuật — quán quyết bàn trống nghĩa là gì · **Đóng đúng:** một câu chọn nguồn + query đối chiếu ra 0 dòng · **Bẫy:** chọn "đồng bộ cả hai" là không chọn |
| [F-BA-02](#f-ba-02) | 🟡 | Dòng trống giữa bảng *Đối chiếu finding → task* ở [task_BA.md](task_BA.md) **cắt bảng làm hai** — 2 trong 4 dòng đối chiếu không render thành bảng | 🔓 MỞ | không chặn task nào; chặn **owner đọc đúng** sổ đối chiếu | phát hiện khi gộp bảng task 2026-08-19 |

## F-BA-01

**Mệnh đề đang sai.** [prompt-fullstack §6.2](../../project_preparation/prompt-fullstack.md) liệt kê 8 bất
biến, mỗi bất biến 3 cột. Dòng `I8` — *bàn `free` ⟺ không còn phiên chưa đóng* — bỏ trống cột **bảo vệ bằng**
và ghi thẳng vào đó: *"phải chọn một nguồn sự thật"*. Tức tài liệu tự khai là **có hai nguồn cho một mệnh đề
và chưa ai chọn**. Bảy bất biến kia đã có cơ chế; riêng dòng này còn là câu hỏi.

**Vì sao là finding chứ không phải task.** Áp phép thử ở [§7](../../CLAUDE.md): chạy hết
[ke-hoach.md](ke-hoach.md) y như nó viết — dòng này vẫn còn, vì không bước nào trong kế hoạch nói tới `I8`.
Nó không tự mất đi. Và nó **đang** mâu thuẫn: hai nguồn cùng tồn tại thì có lúc chúng lệch nhau.

**Hỏng thành cái gì ở quán.** Bàn 5 hiện *trống* trên sơ đồ POS nhưng phiên của nó chưa đóng ⇒ khách mới ngồi
xuống, quét QR, gọi món, và món đó rơi vào **hoá đơn của lượt khách trước**. Hoặc ngược lại: bàn hiện *có khách*
mà thực ra đã thanh toán xong ⇒ nhân viên không dám xếp khách, quán mất chỗ giữa giờ cao điểm. Cả hai đều không
có lệnh nào báo, vì mỗi nguồn tự nó đều nhất quán.

**Đóng đúng.** Một câu trả lời dứt khoát *nguồn nào thắng* (viết ở `01-thiet-ke.md` bằng ngôn ngữ quán, không
tên bảng), **và** một query đối chiếu ra 0 dòng khi hai nguồn lệch. Chọn *"đồng bộ cả hai chiều"* **không phải
là chọn** — đó là giữ nguyên hai nguồn và thêm một chỗ hỏng thứ ba.

**Cần ai.** Owner. *"Bàn trống"* là khái niệm của quán, không phải của hệ thống: bàn đã trả tiền nhưng chưa dọn
thì có tính là trống không — chỉ người bán hàng trả lời được, và câu trả lời đó quyết định trạm `don_ban`
đứng ở đâu trong luồng.

## F-BA-02

**Mệnh đề đang sai.** Trong [task_BA.md](task_BA.md) mục *Đối chiếu finding → task*, giữa dòng `F-68` và dòng
`F-05` có **một dòng trống**. Markdown coi dòng trống là **kết thúc bảng**, nên 2 dòng cuối (`F-05`, `F-06`+`F-07`)
render thành **văn bản thô ngoài bảng**, không phải hàng của bảng đối chiếu. Kiểm bằng:
`awk 'NR>=46 && NR<=54 && $0==""{print NR": TRỐNG"}' design/BA/task_BA.md` → ra 1 dòng.

**Vì sao là finding chứ không phải task.** Phép thử [§7](../../CLAUDE.md): chạy hết [ke-hoach.md](ke-hoach.md) +
[task_BA.md](task_BA.md) y như chúng viết — dòng này vẫn còn, vì không bước nào nói tới cách render sổ đối chiếu.
Nó **đang** sai ngay bây giờ, không tự mất đi.

**Hỏng thành cái gì.** Mục đối chiếu tồn tại để trả lời *"finding nào chưa task nào nhận"* — chính nó tự khai
`Finding của lane BA mà không task nào nhận ⇒ lỗi của file này`. Nửa bảng rơi ra ngoài thì owner đọc lướt sẽ
thấy **2 dòng** thay vì 4, và đúng 2 dòng bị mất là 2 dòng chặn lane khác (`F-05`, `F-06`/`F-07` → `T-BA-14`,
`T-BA-15`). Cùng loại lỗi này vừa được sửa ngay trong bảng task khi gộp bảng, nên nó **không phải cá biệt**:
mọi bảng dài trong repo đều dính được.

**Cách sửa đề xuất.** Xoá dòng trống ở giữa bảng, và thêm vào [04 §4](04-yeu-cau.md) một lệnh gác chung cho
mọi bảng markdown trong `design/BA/`: in ra mọi dòng trống nằm **giữa** hai dòng bắt đầu bằng `|` —
`awk 'FNR==1{prev=blank=0} /^\|/{if(blank && prev)print FILENAME": "FNR-1; blank=0; prev=1; next} {if(prev && $0=="")blank=1; else{prev=0;blank=0}}' design/BA/*.md`
→ phải rỗng. Việc thuộc lane BA, mở task ở [task_BA.md](task_BA.md).

**Đóng đúng.** Lệnh gác trên ra rỗng trên toàn `design/BA/*.md`, **và** lệnh đó có mặt trong [04 §4](04-yeu-cau.md)
để session sau chạy lại được.

## Luật đóng của lane này

Dùng nguyên 5 luật đóng ở [/finding.md](../../finding.md) + [quality/finding_guiline.md](../../quality/finding_guiline.md).
Ba điều nhắc lại vì lane BA hay vướng nhất:

1. **Đóng cần bằng chứng chạy được.** Lane này không có compiler ⇒ bằng chứng là **lệnh đọc lại** ở [04 §4](04-yeu-cau.md).
   Đóng vì *"đọc lại thấy ổn"* ⇒ cấm.
2. **Khai mấy vế thì đóng mấy vế.** Bóp nhỏ finding cho vừa cái đã làm cũng cấm.
3. **Đóng phải để lại một dòng `**Bài học giữ lại:**`** — luật nào đổi để nó không tái phát. Rút không ra luật
   ⇒ chưa hiểu nguyên nhân, chưa được đóng.
