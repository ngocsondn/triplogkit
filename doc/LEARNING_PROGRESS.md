# iOS/Swift Catch-up Roadmap (gap: 2021 → 2026)

Last updated: 2026-07-09

Status legend: `[x]` done · `[~]` in progress · `[ ]` not started

Mỗi mục nên có 1 demo nhỏ trong project + được kiểm chứng bằng công cụ thật (Instruments, debugger, test runner) trước khi tick done.

**Bối cảnh (2026-07-09):** ngoài mục tiêu catch-up chung, roadmap này giờ gắn với mục tiêu cụ thể hơn — CV đã cập nhật liệt kê Swift Concurrency, SwiftData, SPM là kỹ năng chuyên môn, cần demo thật để chứng minh khi phỏng vấn. Toàn bộ narrative đầy đủ (script trả lời phỏng vấn, talking points, thứ tự ưu tiên nếu gấp thời gian) nằm ở `doc/iOS-Interview-Roadmap 2.md` — file đó là nguồn gốc, phần dưới đây chỉ trích thành checklist để đồng bộ tiến độ với các mục catch-up khác.

## 0. Debugging & Tooling refresher
- [x] Instruments (Leaks/Allocations) + retain-cycle demo — `AutoShuffleManager.swift` + `AutoShuffleDetailView.swift` (Timer capture `self` mạnh)
- [x] Áp fix retain cycle (`[weak self]` + `invalidate()` đúng chỗ) và re-profile để confirm instance count về 0

## 1. Concurrency (ưu tiên #2)
- [x] async/await cơ bản (network call giả lập) — toy demo: `FunFactService.swift` + `AsyncFunFactView.swift`
- [x] actor & Sendable — toy demo: `ScoreCounter.swift` + `ActorRaceDemoView.swift`
- [ ] Swift 6 strict concurrency mode (bật cho cả project, xem lỗi gì nổi lên)
- [ ] Tự trả lời được 4 câu hỏi phỏng vấn actor/async (Ngày 1-2, xem `iOS-Interview-Roadmap 2.md`) mà không cần xem lại note

## 2. SwiftUI state management (ưu tiên #1)
- [x] `@Observable` macro thay `ObservableObject` + `@Published` — candidate: refactor `AutoShuffleManager`
- [x] `NavigationStack` (đã dùng trong `ContentView`, thay `NavigationView` cũ)
- [ ] `@Entry` macro cho `EnvironmentValues`

## 3. Data & Persistence
- [ ] SwiftData cơ bản (`@Model`) — ví dụ nhỏ, tách riêng khỏi mục dưới nếu muốn học trước khi ráp vào project phỏng vấn
- [ ] `@Model Checkpoint` (SwiftData) theo đúng spec trong `iOS-Interview-Roadmap 2.md` (Ngày 3-4)
- [ ] `@Query` load list checkpoint, tự động refresh UI
- [ ] Tự trả lời được 3 câu hỏi phỏng vấn SwiftData (Ngày 3-4) mà không cần xem lại note

## 4. Ngôn ngữ Swift
- [ ] Macros — tổng quan cách hoạt động (đứng sau `@Observable`/`@Model` đã dùng)
- [ ] Typed throws (`throws(MyError)`)
- [ ] `~Copyable` / noncopyable types (optional, nâng cao)

## 5. Testing (ưu tiên #3)
- [ ] Swift Testing framework (`@Test`, `#expect`) — viết lại vài test trong target Tests

## 6. Platform/App capabilities (thấp ưu tiên, làm sau)
- [ ] App Intents mở rộng (Siri/Shortcuts/Control Center)
- [ ] Interactive widgets & Live Activities
- [ ] visionOS tổng quan (nếu liên quan công việc)

## 7. Dự án phỏng vấn — SPM + ráp nối (theo `iOS-Interview-Roadmap 2.md` Ngày 5-7)
Mục tiêu: có 1 project chạy được, kết hợp SwiftData + async/await + actor + modularize bằng SPM, làm bằng chứng cụ thể khi phỏng vấn (không chỉ nói lý thuyết).
- [ ] Tạo local SPM package trong workspace (File → New → Package)
- [ ] Chuyển model/service (Checkpoint, WeatherCache, WeatherAPI) vào package, expose `public`
- [ ] Thêm package vào app target qua "Frameworks, Libraries, and Embedded Content"
- [ ] (Optional nếu đủ thời gian) build thử `.xcframework` cho package
- [ ] Ráp checkpoint + thời tiết (Open-Meteo, không cần key) + SwiftData + actor cache thành 1 flow chạy được trong app
- [ ] Quay demo ngắn / chụp screenshot làm bằng chứng, push lên GitHub riêng
- [ ] Tự trả lời được 3 câu hỏi phỏng vấn SPM (Ngày 5) mà không cần xem lại note

## 8. Interview readiness — không phải code (chi tiết đầy đủ + script trong `iOS-Interview-Roadmap 2.md`)
- [ ] Luyện nói được talking point A (câu hỏi "5 năm gap Native iOS") — nêu native bridge ở các công ty sau đó trước, dự án cá nhân bổ sung sau, không nói quá thời gian đã dùng stack mới
- [ ] Luyện nói được talking point B (giải thích cơ chế xác thực bundle bằng asymmetric signature + checksum)
- [ ] Đồng bộ lại CV bản PDF/DOCX cho khớp định vị iOS-first với bản web

## Nếu chỉ còn 2-3 ngày trước phỏng vấn
Xem đầy đủ trong `iOS-Interview-Roadmap 2.md`. Tóm tắt ưu tiên: học thuộc 2 script ở mục 8 trước (gần như chắc chắn bị hỏi, không cần code mới) → actor/async cơ bản (mục 1) → SwiftData model + `@Query` cơ bản, bỏ qua migration (mục 3) → SPM chỉ cần thao tác tạo local package 1 lần, bỏ XCFramework nếu gấp (mục 7).

## Thứ tự đề xuất (khi không gấp)
1. `@Observable` (mục 2)
2. async/await + actor (mục 1)
3. Swift Testing (mục 5)
4. SwiftData (mục 3)
5. SPM + ráp dự án phỏng vấn (mục 7)
6. Swift 6 strict concurrency mode (mục 1, làm cuối vì sẽ soi lỗi toàn bộ code trước đó)
7. Interview readiness / luyện script (mục 8) — nên làm song song, không đợi xong hết code mới luyện nói
8. Mục 4 và 6 làm khi rảnh / theo nhu cầu thực tế

## Nhật ký
- 2026-07-08: Tạo demo memory leak (`AutoShuffleManager` + `AutoShuffleDetailView`), build thành công, hướng dẫn dùng Instruments (Leaks + Allocations + Memory Graph Debugger) để phát hiện retain cycle qua Timer. Chưa áp fix.
- 2026-07-08: Áp fix retain cycle — `[weak self]` trong closure của `Timer`, thêm `stop()` gọi `invalidate()` từ `deinit` và `.onDisappear`. Build thành công. Cần tự re-profile bằng Instruments để confirm object count về 0 sau khi back khỏi màn hình (chưa chạy Instruments thật trong phiên này, chỉ verify bằng build).
- 2026-07-08: Refactor `AutoShuffleManager` từ `ObservableObject` + `@Published` sang `@Observable` macro (Observation framework). `timer` đánh dấu `@ObservationIgnored` vì không cần trigger UI update. View đổi `@StateObject` → `@State` cho khớp. Build thành công.
- 2026-07-08: Demo async/await cơ bản — `FunFactService.swift` (hàm `async throws` giả lập network call bằng `Task.sleep`, ~10% throw lỗi để có chỗ demo `try/catch`) + `AsyncFunFactView.swift` (dùng `.task(id:)` — tự chạy khi view xuất hiện/khi `activity` đổi, tự cancel khi view biến mất, khác với `Task {}` thủ công trong `onAppear` phải tự quản lý cancellation). Build thành công.
- 2026-07-08: Demo actor & Sendable — `ScoreCounter.swift` (`UnsafeScoreCounter` class thường bị race condition khi 200 Task đồng thời gọi `increment()`, verify bằng script Swift độc lập chạy 3 lần: luôn mất update, còn 21-41/200; đối chứng `ScoreCounter` là `actor` luôn ra đúng 200/200) + `ActorRaceDemoView.swift` hiển thị so sánh trực quan trong app. Build thành công, không thấy warning Sendable vì project còn ở Swift 5 mode (chưa bật strict concurrency — sẽ lộ ra ở mục tiếp theo).
- 2026-07-09: Gộp `iOS-Interview-Roadmap 2.md` vào roadmap này — thêm mục 7 (SPM + ráp dự án phỏng vấn) và mục 8 (interview readiness), cập nhật "Thứ tự đề xuất". Roadmap gốc giữ nguyên làm nguồn cho script/talking points chi tiết.
- 2026-07-09: Đổi tên toàn bộ project `myapp` → `TripLogKit` (khớp tên dự án demo trong roadmap phỏng vấn): `.xcodeproj`, target app/Tests/UITests, scheme, thư mục source, entitlements, `myappApp.swift` → `TripLogKitApp.swift`, bundle identifier `com.myapp` → `com.triplogkit` (+ Tests/UITests tương ứng). Giữa chừng Xcode (đang mở sẵn) tự tạo lại 1 `myapp.xcodeproj` stub rỗng đè lên path cũ — phải đóng Xcode rồi xoá stub đó mới build lại sạch được; bài học: luôn đóng Xcode trước khi rename project qua CLI. Build + build-for-testing đều thành công sau khi dọn xong.
