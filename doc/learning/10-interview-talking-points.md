# 10 — Talking points: 2 câu hỏi nóng nhất chắc chắn sẽ gặp

**Trạng thái:** kịch bản trả lời, học thuộc trước cả phần code nếu gấp thời gian.

## TL;DR
Đây không phải kiến thức kỹ thuật cần "hiểu bản chất" như các bài trước — là 2 câu chuyện cần **nói trôi chảy không cần xem note**. Ưu tiên học 2 script này trước nếu chỉ còn 2-3 ngày.

---

## A. "Đã 5 năm từ công việc Native iOS thuần cuối cùng (Axon Active, kết thúc 05/2021) — anh làm gì để giữ kỹ năng cập nhật?"

### 🧩 Vấn đề của câu trả lời "yếu"
Trả lời ngay "tôi có dự án cá nhân" nghe như đang chữa cháy cho 1 khoảng trống — vì nó bỏ qua sự thật là Native chưa từng biến mất khỏi công việc thật.

### 🔧 Cách trả lời đúng — 2 lớp, ưu tiên lớp 1 trước
**Lớp 1 (bằng chứng có sẵn trong CV, dẫn ra ngay được):** ở mỗi công ty sau Axon đều có phần cầu nối Native do chính mình phụ trách:
- Hill Tech: viết native module tải/giải nén/verify Mini App bundle bằng giải mã đối xứng.
- Webkom: viết native module thay thế WebView để phát livestream trực tiếp, tăng performance.

**Lớp 2 (bổ sung, không phải toàn bộ câu trả lời):** thiếu thời gian làm 1 app SwiftUI/UIKit trọn vẹn bằng stack mới nhất, nên gần đây chủ động làm dự án cá nhân (`TripLogKit`) áp dụng Swift Concurrency + SwiftData để lấp khoảng đó.

### 🧠 Script mẫu (học thuộc)
> "Thực ra Native chưa bao giờ rời khỏi công việc của tôi — ở Hill Tech tôi viết module native để tải, giải nén và verify Mini App bundle; ở Webkom tôi viết module native thay WebView để phát livestream mượt hơn. Nhưng đúng là 5 năm qua tôi không làm 1 app SwiftUI/UIKit trọn vẹn với stack mới nhất, nên gần đây tôi chủ động làm 1 dự án cá nhân dùng Swift Concurrency và SwiftData để cập nhật lại phần đó."

**Lưu ý bắt buộc:** nếu bị hỏi tiếp "dự án cá nhân bắt đầu từ khi nào" — trả lời đúng thời điểm thật, **không** nói đã làm lâu năm nếu mới bắt đầu gần ngày phỏng vấn. Xem nguyên tắc trung thực đầy đủ ở [00-project-context.md](00-project-context.md).

---

## B. "Anh có thể giải thích chi tiết cơ chế xác thực Mini App bundle không?"

### 🧩 Đây KHÔNG phải điểm yếu cần chữa cháy
Cơ chế thực tế (asymmetric signature + checksum) đã đúng chuẩn ngành — là điểm mạnh cần trình bày rõ ràng, mạch lạc để ghi điểm, không phải phòng thủ.

### 🔧 Vì sao đây là cách làm đúng
Server giữ **private key** (không rời server) để ký vào checksum/hash của bundle; app chỉ cần **public key** nhúng sẵn để verify. Vì public key lộ ra ngoài cũng không sao (biết public key chỉ verify được, không tự tạo được chữ ký hợp lệ), nên kể cả app bị dịch ngược, attacker vẫn không thể tự ký một bundle giả mà app chấp nhận. Đây chính là cơ chế Apple code signing, Android APK signing, Sparkle updater đều dùng — vì bên verify (client) chạy trên thiết bị không đáng tin cậy tuyệt đối.

### 🧠 Script trả lời — trình bày rõ luồng xử lý đầy đủ
> "Server ký vào checksum/hash của bundle bằng private key, kết quả chữ ký được encode base64 để truyền kèm bundle qua API. Khi app tải bundle về, nó tự tính lại checksum của bundle vừa tải, rồi dùng public key nhúng sẵn trong app để verify chữ ký đó có khớp với checksum không. Nếu hợp lệ mới cho giải nén và thực thi; nếu bundle bị sửa dù chỉ 1 byte, checksum sẽ khác và verify thất bại ngay. Vì server giữ private key nên kể cả ai đó dịch ngược app lấy được public key, họ cũng không thể tự ký một bundle giả để app chấp nhận."

**Câu hỏi mở rộng có thể gặp:** *"Vậy nội dung bundle có bị lộ không vì không mã hoá?"*
> "Đúng, mục tiêu ở đây là integrity/authenticity chứ không phải confidentiality — nội dung bundle không phải bí mật cần giấu, chỉ cần đảm bảo không bị chỉnh sửa/giả mạo. Nếu cần bảo mật nội dung thì có thể thêm 1 lớp mã hoá riêng, tách biệt với việc ký xác thực."

### Khẩu quyết chung cho cả 2 câu
*"Trả lời trung thực về mức độ (câu A) và trình bày tự tin về cái đã làm đúng (câu B) — đừng lẫn 2 tinh thần này vào nhau."*

---

## Nếu chỉ còn 2-3 ngày trước phỏng vấn
Ưu tiên học thuộc 2 script trên trước — đây là 2 câu gần như chắc chắn gặp và không cần code demo mới trả lời được, trong khi phần code Swift Concurrency/SwiftData chỉ cần hiểu khái niệm cơ bản là đủ đối phó câu hỏi mức screening. Xem thứ tự ưu tiên đầy đủ ở [`../LEARNING_PROGRESS.md`](../LEARNING_PROGRESS.md).

## Lưu ý về CV bản tải xuống (PDF/DOCX)
Website đã được cập nhật định vị iOS-first, nhưng file CV tải về (`document/NguyenNgocSon_CV.pdf`, `document/NguyenNgocSon_CV_Orange_Full.docx`) là file tĩnh, **không tự động đồng bộ** với nội dung website. Cần chỉnh sửa thủ công 2 file này để khớp với định vị mới — nếu không, nhà tuyển dụng sẽ thấy 2 bản CV không khớp nhau (một bản web nói "iOS Developer", một bản PDF vẫn nói "Mobile Developer").
