# 05 — Swift 6 strict concurrency mode

**Trạng thái:** 📝 Kế hoạch — chưa bật, chưa demo

## TL;DR
Strict concurrency check tại **compile-time**: mọi type không `Sendable` đi qua ranh giới actor/Task đều bị báo lỗi (không chỉ warning). Project hiện tại vẫn build ở Swift 5 mode nên **chưa thấy** warning Sendable nào ở [`ScoreCounter.swift`](../../TripLogKit/ScoreCounter.swift)/[`ActorRaceDemoView.swift`](../../TripLogKit/ActorRaceDemoView.swift) — bật mode này lên là bước "soi lại" toàn bộ phần concurrency đã viết.

## 🧩 Vấn đề cũ
Swift 5 concurrency checking chỉ ở mức **cảnh báo tùy chọn** (`-warn-concurrency`) hoặc im lặng hoàn toàn nếu không bật cờ. Code có thể vô tình truyền 1 `class` không an toàn qua actor boundary mà không ai biết cho tới khi crash hoặc lỗi khó tái hiện xảy ra ở production.

## 🔧 Giải pháp / Refactor (kế hoạch)
1. Bật `SWIFT_STRICT_CONCURRENCY = complete` (hoặc target Swift language mode 6) trong build settings.
2. Build lại toàn project, đọc từng lỗi — không tắt bằng `@unchecked Sendable` bừa để qua loa, ưu tiên hiểu vì sao compiler flag.
3. Làm **cuối cùng** trong roadmap (sau khi đã xong async/await, actor, SwiftData) vì nó sẽ soi lỗi trên toàn bộ code viết trước đó — bật sớm sẽ nhiễu, không phân biệt được lỗi thật với lỗi do code chưa hoàn chỉnh.

## 🧠 Đúc kết — nhớ lâu
- **Nguyên tắc:** Swift 6 mode không thêm tính năng mới — nó biến các quy tắc Sendable/actor isolation *đã tồn tại* từ optional-warning thành **compile error bắt buộc**. Nói cách khác: code đúng chuẩn concurrency từ đầu thì bật lên không phát sinh gì; code có lỗ hổng ẩn mới lộ ra.
- **Mẹo tránh sai lầm khi fix:** đừng phản xạ thêm `@unchecked Sendable` để dập lỗi nhanh — đó là cách tự tắt chính cái lưới an toàn vừa được compiler bật lên. Chỉ dùng khi tự chứng minh được type đó thực sự an toàn theo cách compiler không nhìn thấy (ví dụ tự lock nội bộ).
- **Khẩu quyết:** *"Swift 6 không tạo luật mới — nó chỉ ngừng tha thứ."*

## 🎯 Phỏng vấn
**Q: Swift 6 strict concurrency thay đổi gì so với Swift 5?**
A: Biến các cảnh báo Sendable/actor isolation vốn optional thành lỗi compile bắt buộc — buộc mọi type đi qua ranh giới concurrency phải chứng minh an toàn tại compile-time thay vì phát hiện race condition lúc runtime.

**Q: Khi nào nên dùng `@unchecked Sendable` thay vì để compiler tự suy luận?**
A: Chỉ khi tự đảm bảo được an toàn bằng cơ chế mà compiler không thấy được (ví dụ tự đồng bộ hóa nội bộ bằng lock) — không dùng để "tắt lỗi" cho nhanh mà không hiểu nguyên nhân.

## 📁 Bằng chứng
Chưa có — đây là mục kế hoạch. Khi thực hiện, cập nhật phần này với: build log trước/sau khi bật strict mode, danh sách lỗi gặp phải và cách fix từng lỗi.
