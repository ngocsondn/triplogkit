# 06 — `@Model` / `@Query` (SwiftData)

**Trạng thái:** 📝 Kế hoạch — chưa ráp vào project này

## TL;DR
SwiftData là lớp trừu tượng Swift-native thay Core Data: khai báo model bằng macro `@Model` thay file `.xcdatamodeld`, và `@Query` tích hợp trực tiếp với SwiftUI qua Observation để tự refresh UI khi data đổi — không cần `NSFetchedResultsController`.

## 🧩 Vấn đề cũ (Core Data)
Core Data yêu cầu: định nghĩa entity qua file `.xcdatamodeld` (editor riêng, không phải code Swift thuần), tự quản lý `NSManagedObjectContext`, và muốn UI tự cập nhật theo data phải bắc cầu qua `NSFetchedResultsController` hoặc tự publish thủ công — nhiều lớp gián tiếp, khó đọc nếu không quen ngay từ đầu.

## 🔧 Giải pháp / Refactor (kế hoạch, theo đúng spec dự án `TripLogKit`)
```swift
@Model
final class Checkpoint {
    var city: String
    var visitedAt: Date
    var weather: WeatherSnapshot?

    init(city: String, visitedAt: Date = .now) {
        self.city = city
        self.visitedAt = visitedAt
    }
}

// Trong App:
.modelContainer(for: Checkpoint.self)

// Trong View:
@Query(sort: \Checkpoint.visitedAt, order: .reverse)
var checkpoints: [Checkpoint]
```
`@Model` biến 1 class Swift thuần thành entity có thể persist — không cần file mapping riêng. `@Query` tự chạy lại và refresh View khi dữ liệu underlying đổi, nhờ tích hợp thẳng với Observation framework (cùng cơ chế đứng sau [`@Observable`](02-observable-macro.md)).

## 🧠 Đúc kết — nhớ lâu
- **Nguyên tắc:** SwiftData không phải "Core Data đổi tên" — nó là 1 lớp Swift-native (macro-based) *chạy trên* engine tương tự Core Data/CloudKit, mục tiêu là loại bỏ toàn bộ boilerplate khai báo tách rời khỏi code Swift.
- **Mẹo phân biệt dễ nhầm:** `@Query` tự refresh UI (giống cơ chế `@Observable`) — khác với việc tự `fetch()` thủ công rồi gán vào `@State` (cách đó KHÔNG tự cập nhật khi data đổi từ nơi khác).
- **Khẩu quyết:** *"@Model thay file mapping, @Query thay FetchedResultsController — cả hai đều là 'nói với SwiftUI bằng chính ngôn ngữ của nó'."*
- **Migration:** dùng `SchemaMigrationPlan` khi đổi cấu trúc model giữa các version — chỉ cần biết khái niệm tồn tại, không cần thuộc lòng API nếu đang gấp thời gian.

## 🎯 Phỏng vấn
**Q: SwiftData khác Core Data ở kiến trúc nào?**
A: SwiftData là lớp trừu tượng Swift-native trên CloudKit/Core Data, dùng macro `@Model` để khai báo entity trực tiếp bằng code Swift thay vì file `.xcdatamodeld` riêng.

**Q: `@Query` hoạt động thế nào, có tự động refresh UI không?**
A: Có — tích hợp trực tiếp với SwiftUI qua Observation framework, tự re-run và cập nhật View khi dữ liệu underlying thay đổi, không cần tự fetch lại thủ công.

**Q: Migration schema trong SwiftData xử lý ra sao?**
A: Qua `SchemaMigrationPlan` — biết khái niệm và khi nào cần dùng là đủ ở mức screening interview, không cần thuộc lòng chi tiết API nếu chưa có thời gian thực hành sâu.

## 📁 Bằng chứng
Chưa có — mục kế hoạch. Khi ráp vào project: cập nhật với file `Checkpoint.swift` thật, screenshot `@Query` chạy trong app, và ghi lại có dùng `SchemaMigrationPlan` thật hay chỉ demo cơ bản.
