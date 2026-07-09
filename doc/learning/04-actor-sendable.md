# 04 — Race condition → `actor` (+ `Sendable`)

**Trạng thái:** ✅ Đã demo trong code

## TL;DR
Mutable state dùng chung giữa nhiều `Task` chạy đồng thời trên `class` thường bị **data race**: đọc-sửa-ghi (read-modify-write) không atomic → mất update. Trước đây phải tự lock (`NSLock`/serial `DispatchQueue`), dễ quên hoặc dùng sai chỗ. `actor` để compiler tự đảm bảo chỉ 1 `Task` được thực thi code bên trong actor tại một thời điểm — không cần lock thủ công.

## 🧩 Vấn đề cũ (không có actor)
```swift
// Before / đối chứng trong demo — UnsafeScoreCounter
final class UnsafeScoreCounter {
    private(set) var score = 0

    func increment() async {
        let old = score
        await Task.yield()   // "mở rộng" race window để lộ rõ vấn đề khi demo
        score = old + 1
    }
}
```
Khi 200 `Task` cùng gọi `increment()` đồng thời: hai `Task` có thể cùng đọc `score` ở giá trị cũ trước khi cả hai ghi đè lên nhau → 1 trong 2 lần tăng bị mất. Trong demo, kết quả luôn ra thấp hơn 200 (thường 21-41/200 khi chạy thật). Ngoài đời không cần chèn `Task.yield()` mới có race — máy đa nhân tự nhiên đã đủ để trigger, `yield()` chỉ giúp demo lộ ra **ổn định** hơn để quan sát.

Cách cũ để tránh: tự dùng `NSLock`, `DispatchSemaphore`, hoặc serial `DispatchQueue` quanh mọi chỗ đọc/ghi `score` — đúng nhưng dễ quên lock ở 1 nhánh code, hoặc dễ deadlock nếu lock lồng sai thứ tự.

## 🔧 Giải pháp / Refactor
```swift
// After — ScoreCounter.swift
actor ScoreCounter {
    private(set) var score = 0

    func increment() {
        score += 1
    }
}
```
`actor` tự có 1 "hàng đợi" (serial executor) riêng: mọi lệnh gọi vào actor từ bên ngoài phải xếp hàng, chỉ 1 lệnh được thực thi tại một thời điểm → `score += 1` không bao giờ bị interleave bởi Task khác, không cần `await Task.yield()` để "mở rộng race window" vì đơn giản là **không có race để mở**.

Verify trong demo bằng cách chạy song song 200 Task trên cả 2 counter (`withTaskGroup`) và so sánh kết quả — `actor` luôn ra đúng 200/200:
```swift
await withTaskGroup(of: Void.self) { group in
    for _ in 0..<iterations {
        group.addTask { await safeCounter.increment() }
    }
}
```

## 🧠 Đúc kết — nhớ lâu
- **Nguyên tắc:** `actor` = "class + tự động hàng đợi hóa truy cập". Không có gì thay thế lock thủ công tốt hơn cơ chế được compiler enforce.
- **Mẹo phân biệt cần `await` hay không:** gọi property/method của actor từ **ngoài** actor luôn cần `await` (có thể phải đợi tới lượt trong hàng đợi). Gọi lẫn nhau giữa các method **bên trong cùng** actor thì **không** cần `await` — code đó đã ở "khu vực an toàn" đó rồi.
- **`Sendable` là gì:** marker protocol báo hiệu 1 type an toàn để truyền qua ranh giới concurrency (giữa actor/Task khác nhau) mà không gây race. `struct`/`enum` immutable tự động `Sendable` nếu mọi field đều `Sendable`; `class` phải tự đảm bảo (thường: `final` + không có mutable state, hoặc tự chịu trách nhiệm đồng bộ hóa và đánh dấu `@unchecked Sendable`).
- **Khẩu quyết:** *"actor không 'canh' race — nó xóa luôn khái niệm song song ở bên trong nó, mọi lệnh vào phải xếp hàng."*
- **Mẹo khi tự demo/giải thích:** muốn lộ rõ race để chứng minh, chèn `await Task.yield()` giữa đọc và ghi trong bản không an toàn — không phải kỹ thuật production, chỉ để giáo cụ trực quan hóa race window.

## 🎯 Phỏng vấn
**Q: `actor` khác `class` thông thường ở điểm nào về thread-safety?**
A: `actor` có executor riêng tự serialize mọi truy cập vào mutable state của nó — tại một thời điểm chỉ 1 đoạn code chạy bên trong actor, tránh data race mà không cần lock/mutex thủ công. `class` thường không có bảo vệ này.

**Q: Vì sao gọi `counter.increment()` từ ngoài actor cần `await`, nhưng bên trong actor gọi method khác của chính nó thì không?**
A: Gọi từ ngoài phải "xin vào hàng đợi" của actor (có thể phải chờ Task khác xong trước). Code đang chạy sẵn bên trong actor thì đã có quyền truy cập, không cần chờ thêm.

**Q: `Sendable` là gì, khi nào một type cần đánh dấu nó?**
A: Là marker protocol cho biết type an toàn để chia sẻ giữa các miền concurrency khác nhau không gây race. Cần khi truyền dữ liệu qua ranh giới actor/Task — value type immutable tự động đủ điều kiện; reference type phải tự đảm bảo an toàn (thường bằng cách loại bỏ mutable state hoặc tự đồng bộ hóa).

**Q: `async let` khác gì `TaskGroup`?**
A: `async let` khai báo số lượng task con cố định, biết trước tại compile-time; `withTaskGroup` dùng khi số lượng task động (ví dụ chạy N task trong loop như trong demo này với 200 iterations).

## 📁 Bằng chứng
- [`ScoreCounter.swift`](../../TripLogKit/ScoreCounter.swift) — 2 class đối chứng (`UnsafeScoreCounter` vs `actor ScoreCounter`)
- [`ActorRaceDemoView.swift`](../../TripLogKit/ActorRaceDemoView.swift) — dòng 62-84 (`runRace()`, chạy 200 Task đồng thời qua `withTaskGroup`)
- Verify lại: mở "Actor Demo (Race Condition)", bấm "Chạy race" vài lần — cột "class thường (race)" dao động và luôn < 200, cột "actor (an toàn)" luôn đúng 200/200.
