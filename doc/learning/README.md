# Learning Notes — cấu trúc & cách dùng

Folder này chứa bản "đúc kết" cho từng chủ đề trong [`../LEARNING_PROGRESS.md`](../LEARNING_PROGRESS.md). Mục tiêu không phải chép lại docs của Apple, mà là **giữ lại đúng phần dễ quên nhất**: vì sao cách làm cũ có vấn đề, cách mới giải quyết nó ra sao, và một câu "khẩu quyết" để nhớ lâu mà không cần đọc lại code.

## Mỗi bài đi theo đúng 5 phần (đọc theo thứ tự này khi ôn nhanh trước phỏng vấn)

| Ký hiệu | Phần | Mục đích |
|---|---|---|
| 🧩 | **Vấn đề cũ** | Cách làm trước đây, vì sao lúc đó hợp lý, và giới hạn/lỗi nó gây ra |
| 🔧 | **Giải pháp / Refactor** | Cách làm mới, migrate như thế nào, vì sao nó giải quyết đúng vấn đề ở trên |
| 🧠 | **Đúc kết — nhớ lâu** | Nguyên tắc cốt lõi, mẹo phân biệt các khái niệm dễ nhầm, khẩu quyết 1 câu |
| 🎯 | **Phỏng vấn** | Câu hỏi hay gặp nhất + câu trả lời chuẩn, ngắn, nói được ngay không cần xem note |
| 📁 | **Bằng chứng** | File thật trong project + cách tự verify lại (Instruments, script, build log) |

## Trạng thái

- ✅ **Đã demo trong code** — bài có ví dụ before/after thật, đã build/verify.
- 📝 **Kế hoạch (chưa code)** — bài giữ chỗ, có code mẫu tham khảo nhưng chưa ráp vào project này. Đừng nói đã làm nếu ở trạng thái này.

## Danh sách bài (theo đúng thứ tự học đề xuất)

1. [00-project-context.md](00-project-context.md) — vì sao có dự án `TripLogKit`, nguyên tắc trả lời trung thực khi phỏng vấn
2. [01-retain-cycle-instruments.md](01-retain-cycle-instruments.md) — ✅ Timer + closure retain cycle, Instruments
3. [02-observable-macro.md](02-observable-macro.md) — ✅ `ObservableObject` → `@Observable`
4. [03-async-await.md](03-async-await.md) — ✅ completion handler → `async/await`, `.task(id:)`
5. [04-actor-sendable.md](04-actor-sendable.md) — ✅ race condition → `actor`
6. [05-swift6-strict-concurrency.md](05-swift6-strict-concurrency.md) — 📝 Swift 6 strict concurrency mode
7. [06-swiftdata-model-query.md](06-swiftdata-model-query.md) — 📝 `@Model` / `@Query`
8. [07-swift-language-misc.md](07-swift-language-misc.md) — 📝 Macros, typed throws, `~Copyable`
9. [08-swift-testing.md](08-swift-testing.md) — 📝 Swift Testing (`@Test`, `#expect`)
10. [09-spm-modularization.md](09-spm-modularization.md) — 📝 SPM local package + XCFramework
11. [10-interview-talking-points.md](10-interview-talking-points.md) — 2 script trả lời câu hỏi nóng nhất + lưu ý CV

## Khi thêm bài mới

Copy đúng khung 5 phần ở trên. Nếu chưa có code demo, ghi rõ 📝 ở đầu file và chỉ điền phần 🧩/🔧 bằng kế hoạch + code mẫu tham khảo — không bịa phần 📁 (bằng chứng) khi chưa có gì để trỏ tới.
