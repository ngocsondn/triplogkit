# 09 — SPM: local package + XCFramework

**Trạng thái:** 📝 Kế hoạch — chưa tách package, chưa build XCFramework

## TL;DR
Tách data layer (`Checkpoint`, `WeatherCache`, `WeatherAPI`) ra 1 local Swift Package trong cùng workspace — chứng minh khả năng modularize đúng như CV đang claim, và là bước cần để đóng gói `.xcframework` nếu muốn nói về phân phối SDK (liên quan kinh nghiệm VibeARMap).

## 🧩 Vấn đề cũ (mọi thứ nằm 1 target)
Hiện tại toàn bộ code (`AutoShuffleManager`, `FunFactService`, `ScoreCounter`, ...) nằm chung 1 app target `TripLogKit`. Cách này đơn giản cho demo nhỏ, nhưng không chứng minh được kỹ năng modularize khi bị hỏi trực tiếp — mọi thứ compile chung, không có ranh giới `public`/`internal` rõ ràng, biên dịch lại toàn bộ mỗi lần đổi bất kỳ file nào.

## 🔧 Giải pháp / Refactor (kế hoạch, theo đúng spec)
1. Trong Xcode: **File → New → Package** → tạo local package tên `TripLogKit` ngay trong workspace hiện tại.
2. Chuyển `Checkpoint` (SwiftData model), `WeatherCache` (actor), `WeatherAPI` vào package đó, expose qua `public`.
3. Thêm package vào app target qua **"Frameworks, Libraries, and Embedded Content"**.
4. (Nếu đủ thời gian) build thử `.xcframework` cho package: `Product → Archive` hoặc `swift build` + `xcodebuild -create-xcframework` — để trả lời được câu hỏi về đóng gói/phân phối SDK.

```swift
// Ví dụ actor sẽ nằm trong package, thể hiện đúng data isolation đã học ở bài 04
actor WeatherCache {
    private var cache: [String: WeatherSnapshot] = [:]

    func snapshot(for city: String) async throws -> WeatherSnapshot {
        if let cached = cache[city] { return cached }
        let fresh = try await WeatherAPI.fetch(city: city)
        cache[city] = fresh
        return fresh
    }
}
```

## 🧠 Đúc kết — nhớ lâu
- **Nguyên tắc:** SPM tích hợp thẳng vào Xcode/toolchain của Apple (không cần công cụ ngoài như CocoaPods/Carthage), versioning khai báo qua `Package.swift` — đây là điểm khác biệt lớn nhất khi so sánh.
- **Khi nào tách package thay vì để chung target:** cần tái sử dụng ở nhiều target/app, muốn biên dịch song song nhanh hơn (module biên dịch độc lập), hoặc muốn ranh giới rõ ràng theo Clean Architecture (ép buộc chỉ expose đúng API cần qua `public`).
- **XCFramework dùng để làm gì:** đóng gói binary đa kiến trúc (device + simulator, nhiều chip) để phân phối cho bên thứ ba mà không lộ source — khác với chỉ share source package.
- **Khẩu quyết:** *"Tách package không phải để 'cho gọn' — mà để ép chính mình chỉ được đi qua đúng cửa `public`."*

## 🎯 Phỏng vấn
**Q: SPM khác CocoaPods/Carthage ở điểm nào?**
A: Tích hợp thẳng vào Xcode/toolchain của Apple, không cần công cụ ngoài; versioning và dependency khai báo trực tiếp qua `Package.swift`.

**Q: Khi nào nên tách 1 module thành package riêng thay vì để chung target?**
A: Khi cần tái sử dụng giữa nhiều target/app, muốn biên dịch song song nhanh hơn nhờ ranh giới module rõ ràng, hoặc muốn ép kiến trúc kiểu Clean Architecture (chỉ expose đúng API cần thiết qua `public`).

**Q: XCFramework dùng để làm gì, khác gì so với chia sẻ source package trực tiếp?**
A: Đóng gói binary đa kiến trúc (device/simulator, nhiều chip) để phân phối cho bên thứ ba mà không lộ source code — cần khi muốn phân phối SDK đóng gói sẵn thay vì chia sẻ mã nguồn.

## 📁 Bằng chứng
Chưa có — mục kế hoạch. Khi thực hiện: cập nhật với cấu trúc `Package.swift` thật, ảnh chụp "Frameworks, Libraries, and Embedded Content" đã thêm package, và log build XCFramework nếu làm tới bước đó.
