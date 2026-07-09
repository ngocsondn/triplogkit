# Bối cảnh: vì sao có `TripLogKit`

CV đã liệt kê **Swift Concurrency (async/await, Actors)**, **SwiftData**, và **Swift Package Manager (SPM)** như kỹ năng chuyên môn. Dự án demo này tồn tại để biến điều đó thành sự thật trước ngày phỏng vấn — không chỉ đọc lý thuyết mà có ví dụ chạy được để dẫn chứng khi bị hỏi "cho ví dụ cụ thể bạn từng dùng ở đâu".

## Nguyên tắc trả lời phỏng vấn: trung thực về mức độ

Nếu bị hỏi *"anh dùng cái này bao lâu rồi / ở dự án production nào"*, trả lời trung thực kiểu:

> "Tôi áp dụng sâu nhất ở dự án cá nhân gần đây, còn ở công ty tôi chủ yếu dùng Core Data/completion handler nên đang chủ động chuyển sang stack mới này."

**🧠 Đúc kết:** trung thực về mức độ + chứng minh hiểu bản chất qua demo đáng tin hơn nhiều so với nói đã dùng lâu năm rồi bị hỏi vặn lộ ra. Người phỏng vấn giỏi luôn hỏi tiếp 1-2 lớp sâu hơn — chỉ cần thật sẽ không bị đuối.

## Ý tưởng dự án đầy đủ (mục tiêu cuối, xem [09-spm-modularization.md](09-spm-modularization.md) để biết tiến độ thật)

App SwiftUI nhỏ, bám domain travel/navigation (khớp kinh nghiệm Axon Active) để có câu chuyện liền mạch khi kể trong CV/phỏng vấn:

- **Tính năng:** ghi lại các điểm dừng (checkpoint) trong 1 chuyến đi, mỗi checkpoint lấy thời tiết hiện tại qua API công khai (Open-Meteo, không cần key).
- **Kiến trúc dự kiến:**
  - Data layer tách thành local Swift Package `TripLogKit` (SPM) → chứng minh khả năng modularize.
  - Model `Checkpoint` lưu bằng **SwiftData** thay Core Data.
  - Gọi API thời tiết bằng **async/await**, không dùng completion handler.
  - Một **actor** `WeatherCache` giữ cache trong bộ nhớ + giới hạn request đồng thời — chứng minh hiểu race condition/data isolation, đúng trọng tâm hay bị hỏi về Actors.

**Trạng thái thật hiện tại:** phần concurrency (async/await, actor) và phần refactor state management (`@Observable`) đã có demo độc lập trong app (xem [ContentView.swift](../../TripLogKit/ContentView.swift)). Phần `Checkpoint`/`WeatherCache`/SwiftData/SPM **chưa ráp** — vẫn ở mức kế hoạch, đừng nói đã làm nếu chưa làm.

## Câu chuyện 60 giây (dùng khi được hỏi tổng quan)

> "Tôi vừa chủ động chuyển một phần kiến trúc sang Swift Concurrency + SwiftData + SPM qua dự án `TripLogKit`, vì công ty hiện tại vẫn dùng completion handler/Core Data — đây là hướng tôi đang đẩy mạnh."

Chi tiết 2 câu hỏi phỏng vấn "nóng" nhất (gap 5 năm Native + cơ chế xác thực bundle) nằm ở [10-interview-talking-points.md](10-interview-talking-points.md) — nên học trước cả phần code nếu gấp thời gian.
