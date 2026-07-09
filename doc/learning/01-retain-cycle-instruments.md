# 01 — Retain cycle qua Timer + cách Instruments phát hiện

**Trạng thái:** ✅ Đã demo + fix trong code

## TL;DR
Closure của `Timer` giữ `self` mạnh theo mặc định; `self` cũng giữ `Timer` qua property → vòng tham chiếu (retain cycle). Cắt bằng `[weak self]`, nhưng vẫn phải `invalidate()` tường minh vì `RunLoop` giữ `Timer` sống **độc lập** với `self`.

## 🧩 Vấn đề cũ
Bản đầu tiên của `AutoShuffleManager` tạo `Timer.scheduledTimer` ngay trong `init`, closure bên trong đọc/ghi `self.tick` mà không đánh dấu capture list:

```swift
// Before — leak
final class AutoShuffleManager: ObservableObject {
    @Published var tick = 0
    private var timer: Timer?

    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.tick += 1   // capture self mạnh (default)
        }
    }
}
```

Chuỗi giữ tham chiếu: `self` → `timer` (property) → `timer`'s closure → `self` (capture mạnh). Vòng này tự nó không thoát được bằng ARC thông thường. Nghiêm trọng hơn: `Timer` được `RunLoop` giữ sống **bất kể** `self` còn ai giữ hay không, nên kể cả nếu phá được cycle mà không gọi `invalidate()`, Timer vẫn chạy vô thời hạn, tốn CPU vô ích.

**Cách phát hiện đúng cách (không đoán bằng mắt):** dùng Instruments — Leaks (tự báo cycle) hoặc Allocations/Memory Graph Debugger (xem instance count của `AutoShuffleManager` theo thời gian). Mở màn `AutoShuffleDetailView` rồi back nhiều lần: nếu leak, instance count tăng dần không bao giờ giảm.

## 🔧 Giải pháp / Refactor
```swift
// After — AutoShuffleManager.swift
init() {
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
        self?.tick += 1
    }
}

func stop() {
    timer?.invalidate()
    timer = nil
}

deinit {
    stop()
}
```
và ở view, gọi `stop()` khi view biến mất:
```swift
// AutoShuffleDetailView.swift
.onDisappear { manager.stop() }
```

Hai thay đổi độc lập, **cả hai đều cần**:
1. `[weak self]` — phá cycle, cho phép `self` được giải phóng khi không còn ai giữ mạnh.
2. `invalidate()` (gọi từ cả `deinit` lẫn `.onDisappear`) — dừng hẳn Timer, vì `RunLoop` giữ nó sống độc lập với `self`.

## 🧠 Đúc kết — nhớ lâu
- **Nguyên tắc:** closure capture `self` mạnh theo mặc định; nếu object mà closure đó thuộc về (ở đây là `Timer`) có thể sống lâu hơn `self` *định* sống, phải `weak` để tránh cycle.
- **Mẹo phân biệt dễ nhầm:** `[weak self]` chỉ ngăn *self* bị giữ mạnh — nó **không** tự dừng Timer. Thiếu `invalidate()` thì Timer vẫn chạy "vô chủ" (orphaned), tốn CPU dù `self` đã kịp giải phóng. Đây là 2 vấn đề khác nhau, sửa 1 không tự sửa cái kia.
- **Khẩu quyết:** *"Weak để không giữ nhau chết, invalidate để không chạy hoài vô ích."*
- **Chỗ khác cũng dễ dính lỗi này:** `NotificationCenter.addObserver(forName:...:using:)` (block-based), completion handler lưu vào property, delegate không khai `weak var`.

## 🎯 Phỏng vấn
**Q: Vì sao chỉ `[weak self]` là chưa đủ, còn cần `invalidate()`?**
A: Vì `Timer` được `RunLoop` giữ sống độc lập với `self`. `weak self` chỉ tránh `self` bị leak; muốn dừng hẳn Timer phải gọi `invalidate()` tường minh.

**Q: Dùng công cụ gì để tìm retain cycle, tìm như thế nào?**
A: Instruments — template Leaks (tự phát hiện cycle) hoặc Allocations/Memory Graph Debugger để xem instance count của class nghi ngờ có giảm về đúng số lượng sau khi rời màn hình nhiều lần hay không.

**Q: Sao biết đã fix đúng, không chỉ "có vẻ đúng"?**
A: Mở/back màn hình nhiều lần trong Instruments, xác nhận instance count trở về 0 (hoặc số lượng đúng) sau mỗi lần back, và log trong `deinit` thực sự được gọi.

## 📁 Bằng chứng
- [`AutoShuffleManager.swift`](../../TripLogKit/AutoShuffleManager.swift) — dòng 23-38 (`init`, `stop()`, `deinit`)
- [`AutoShuffleDetailView.swift`](../../TripLogKit/AutoShuffleDetailView.swift) — `.onDisappear { manager.stop() }`
- Verify lại: mở "Auto Shuffle Demo" từ `ContentView`, back nhiều lần, profile bằng Instruments (Leaks/Allocations) để xác nhận instance count không tăng dần.
