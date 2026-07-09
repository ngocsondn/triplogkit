# 02 — `ObservableObject` → `@Observable` macro

**Trạng thái:** ✅ Đã demo trong code (refactor `AutoShuffleManager`)

## TL;DR
`ObservableObject` + `@Published` publish qua Combine theo **toàn object**: bất kỳ `@Published` nào đổi, mọi View đang observe object đó re-evaluate body, dù có đọc property vừa đổi hay không. `@Observable` (Observation framework) track ở **read-time**: chỉ View nào thực sự đọc property đó trong body mới bị re-render khi nó đổi.

## 🧩 Vấn đề cũ
```swift
// Before
final class AutoShuffleManager: ObservableObject {
    @Published var tick = 0
    private var timer: Timer?
    // ...
}

struct AutoShuffleDetailView: View {
    @StateObject private var manager = AutoShuffleManager()
    // ...
}
```
Cách này hoạt động đúng, nhưng có 2 giới hạn:
1. **Không fine-grained:** Combine publish sự kiện "object đổi" chung, không phân biệt property nào đổi — View re-render toàn bộ dù chỉ cần 1 phần nhỏ của UI phụ thuộc property đó.
2. **Boilerplate:** mỗi field muốn observe phải tự đánh dấu `@Published`, dễ quên.

## 🔧 Giải pháp / Refactor
```swift
// After — AutoShuffleManager.swift
import Observation

@Observable
final class AutoShuffleManager {
    var tick = 0
    @ObservationIgnored private var timer: Timer?
    // ...
}
```
```swift
// AutoShuffleDetailView.swift
@State private var manager = AutoShuffleManager()
```
Đổi `@StateObject` → `@State` vì `@Observable` không còn cần `ObservableObject`/Combine — SwiftUI theo dõi trực tiếp qua Observation framework, `@State` giờ dùng được cho cả reference type nếu class đó là `@Observable`.

`timer` được đánh dấu `@ObservationIgnored` vì nó không cần trigger UI update — chỉ là state nội bộ để quản lý lifecycle, không phải data hiển thị.

## 🧠 Đúc kết — nhớ lâu
- **Nguyên tắc:** Combine (`ObservableObject`) track ở **write-time**, broadcast toàn object; Observation (`@Observable`) track ở **read-time**, chỉ "tag" đúng View đã đọc property đó lúc render. Đây là khác biệt gốc, không phải chỉ là cú pháp gọn hơn.
- **Mẹo phân biệt property wrapper dễ nhầm:** trước Observation, `@State` chỉ dùng cho *value type*. Từ khi có `@Observable`, `@State` dùng được cho *cả reference type* nếu class đó là `@Observable` — nhớ nhầm sẽ dễ để sót `@StateObject` không cần thiết.
- **Khi nào dùng `@ObservationIgnored`:** field đổi giá trị nhưng không ảnh hưởng gì đến UI cần re-render (ví dụ Timer, cache nội bộ) — tránh overhead track vô nghĩa.
- **Khẩu quyết:** *"Combine la làng cho cả object nghe, Observable chỉ thì thầm cho ai đang đọc."*

## 🎯 Phỏng vấn
**Q: `@Observable` khác `ObservableObject` ở điểm nào về performance?**
A: `@Observable` track fine-grained theo property thực sự được đọc trong body của từng View, nên chỉ View đó re-render khi property ấy đổi. `ObservableObject` qua Combine publish sự kiện đổi cho toàn object, khiến mọi subscriber re-evaluate dù không đọc property vừa đổi.

**Q: Khi nào vẫn cần `@ObservationIgnored`?**
A: Khi field không cần SwiftUI theo dõi để cập nhật UI — state nội bộ thuần túy (timer, task handle, cache riêng) — tránh chi phí theo dõi không cần thiết.

**Q: `@Observable` yêu cầu OS tối thiểu nào?**
A: iOS 17 / macOS 14 trở lên (Observation framework).

## 📁 Bằng chứng
- [`AutoShuffleManager.swift`](../../TripLogKit/AutoShuffleManager.swift) — dòng 18-21 (`@Observable`, `@ObservationIgnored`)
- [`AutoShuffleDetailView.swift`](../../TripLogKit/AutoShuffleDetailView.swift) — `@State private var manager`
- Verify lại: build project, mở "Auto Shuffle Demo", xác nhận `tick` vẫn cập nhật UI mỗi giây như trước khi refactor.
