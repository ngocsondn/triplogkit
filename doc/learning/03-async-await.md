# 03 — Completion handler → `async/await` + `.task(id:)`

**Trạng thái:** ✅ Đã demo trong code

## TL;DR
Completion handler bắt buộc tự quản lý cancellation (giữ reference tới task để `.cancel()`) và dễ callback hell khi chain nhiều call. `async/await` cho phép dùng `try/catch` tự nhiên, còn `.task(id:)` trong SwiftUI tự cancel Task cũ + tự chạy lại khi tham số đổi, tự cancel khi View biến mất — không cần code thủ công.

## 🧩 Vấn đề cũ (mô hình completion handler)
```swift
// Before — kiểu completion handler
func fetchFunFact(for activity: String, completion: @escaping (Result<String, Error>) -> Void) {
    // tự schedule, tự gọi completion đúng lúc, tự nhớ gọi trên main thread nếu cần update UI
}

// Ở View: phải tự giữ reference để cancel khi view biến mất
var currentTask: URLSessionTask?

func load() {
    currentTask?.cancel()
    currentTask = service.fetchFunFact(for: activity) { result in
        // phải tự switch thread, tự xử lý nếu view đã biến mất mà completion vẫn gọi về
    }
}
```
Vấn đề: (1) phải tự giữ handle để cancel — dễ quên, dẫn tới cập nhật UI cho 1 view không còn tồn tại; (2) lỗi truyền qua `Result`/tham số riêng, không dùng được `try/catch`; (3) chain nhiều call lồng nhau → callback hell, khó đọc.

## 🔧 Giải pháp / Refactor
```swift
// After — FunFactService.swift
enum FunFactService {
    static func fetchFunFact(for activity: String) async throws -> String {
        try await Task.sleep(for: .seconds(1.5)) // ném CancellationError nếu Task bị huỷ
        guard Int.random(in: 0..<10) != 0 else { throw FunFactError.simulatedFailure }
        // ...
    }
}
```
```swift
// After — AsyncFunFactView.swift
.task(id: activity) {
    await load()
}

private func load() async {
    isLoading = true
    do {
        fact = try await FunFactService.fetchFunFact(for: activity)
    } catch {
        errorMessage = error.localizedDescription
    }
    isLoading = false
}
```
`.task(id:)` tạo 1 Task gắn với lifecycle của View: tự chạy khi View xuất hiện, tự **cancel Task cũ và chạy lại** mỗi khi `activity` đổi, tự cancel khi View biến mất. Không còn property nào phải tự giữ để gọi `.cancel()` thủ công.

## 🧠 Đúc kết — nhớ lâu
- **Nguyên tắc cancellation:** Swift concurrency dùng **cooperative cancellation** — Task bị đánh dấu `isCancelled = true` nhưng không có gì "ngắt cứng" giữa 2 dòng code không suspend. Chỉ tại các điểm `await` (như `Task.sleep`, network call) mới có cơ hội ném `CancellationError` hoặc tự kiểm tra qua `Task.checkCancellation()`.
- **Mẹo phân biệt 3 kiểu hay nhầm:**
  - `.task(id:)` — re-run mỗi khi `id` đổi, cancel task cũ trước, tự cancel khi view biến mất. Dùng khi load lại theo tham số.
  - `.task { }` — chỉ chạy **1 lần** khi view xuất hiện (giống `onAppear`), không tự re-run khi state đổi.
  - `onAppear { Task { ... } }` — phải tự lưu Task và tự `.cancel()` trong `onDisappear`, dễ quên.
- **`Task {}` vs `Task.detached {}`:** `Task {}` kế thừa actor context, priority, task-local values của nơi gọi; `Task.detached {}` không kế thừa gì — dùng khi cần chạy hoàn toàn độc lập (hiếm khi cần trong SwiftUI).
- **Khẩu quyết:** *"await là điểm có thể bị huỷ — không await thì không ai cancel được giữa đường."*

## 🎯 Phỏng vấn
**Q: `async/await` giải quyết vấn đề gì so với completion handler?**
A: Loại bỏ callback hell (code đọc tuần tự như đồng bộ), cho phép xử lý lỗi bằng `try/catch` tự nhiên, và tích hợp với structured concurrency để quản lý lifecycle/cancellation tự động thay vì phải tự giữ handle để hủy thủ công.

**Q: `.task(id:)` khác `.task {}` và `onAppear { Task {} }` thế nào?**
A: `.task(id:)` tự cancel Task cũ + chạy lại khi `id` đổi và tự cancel khi view biến mất; `.task {}` chỉ chạy một lần lúc view xuất hiện; `onAppear { Task {} }` yêu cầu tự lưu Task và tự gọi `.cancel()` trong `onDisappear`, dễ bị bỏ sót.

**Q: Cancellation trong Swift concurrency hoạt động ra sao, có "ngắt cứng" ngay lập tức không?**
A: Không. Đây là cơ chế hợp tác (cooperative) — Task được đánh dấu đã hủy, nhưng code phải tự kiểm tra hoặc đi qua 1 API tôn trọng cancellation (như `Task.sleep`) ở điểm `await` mới thực sự dừng.

**Q: `async let` khác gì gọi `await` tuần tự?**
A: `async let` khởi động các task con **song song, độc lập**, chỉ chờ (`await`) khi thực sự cần kết quả; gọi `await` tuần tự nhiều lần nghĩa là chờ xong task này mới bắt đầu task kia.

## 📁 Bằng chứng
- [`FunFactService.swift`](../../TripLogKit/FunFactService.swift) — dòng 20-24 (`async throws`, `Task.sleep`)
- [`AsyncFunFactView.swift`](../../TripLogKit/AsyncFunFactView.swift) — dòng 46-48 (`.task(id: activity)`)
- Verify lại: mở "Async/Await Demo", đổi `activity` liên tục (bấm "Try again" ở ContentView rồi mở lại), quan sát request cũ tự bị bỏ và luôn hiển thị fact khớp đúng `activity` hiện tại — không bị "trả kết quả trễ của lần load trước".
