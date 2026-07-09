# Roadmap: Swift Concurrency / SwiftData / SPM — trước phỏng vấn iOS

CV đã được cập nhật để liệt kê **Swift Concurrency (async/await, Actors)**, **SwiftData**, và **Swift Package Manager (SPM)** như kỹ năng chuyên môn. Roadmap này giúp biến điều đó thành sự thật trước ngày phỏng vấn — không chỉ đọc lý thuyết mà có 1 dự án demo thật để dẫn chứng khi được hỏi "cho ví dụ cụ thể bạn từng dùng ở đâu".

**Nguyên tắc khi trả lời phỏng vấn:** nếu bị hỏi "bạn dùng cái này bao lâu rồi / ở dự án nào production", hãy trả lời trung thực kiểu: *"Tôi áp dụng sâu nhất ở dự án cá nhân gần đây, còn ở công ty tôi chủ yếu dùng Core Data/completion handler nên đang chủ động chuyển sang stack mới này"*. Trung thực về mức độ + chứng minh được hiểu bản chất qua demo sẽ đáng tin hơn nhiều so với nói dối là đã dùng lâu năm rồi bị hỏi vặn lộ ra.

## Dự án demo: "TripLogKit"

Một app SwiftUI nhỏ, bám theo đúng domain Sơn đã làm (travel/navigation ở Axon Active) nên vừa học kỹ năng mới vừa có câu chuyện liền mạch khi kể trong CV/phỏng vấn.

- **Tính năng**: ghi lại các điểm dừng (checkpoint) trong 1 chuyến đi, mỗi checkpoint lấy thời tiết hiện tại qua API công khai (Open-Meteo, không cần key).
- **Kiến trúc**:
  - Data layer tách thành local Swift Package tên `TripLogKit` (SPM) → chứng minh khả năng modularize, đúng với điểm CV đang claim.
  - Model `Checkpoint` lưu bằng **SwiftData** thay vì Core Data.
  - Gọi API thời tiết bằng **async/await**, không dùng completion handler.
  - Một **actor** `WeatherCache` giữ cache trong bộ nhớ + giới hạn số request đồng thời, chứng minh hiểu race condition / data isolation — đúng trọng tâm hay bị hỏi về Actors.

### Ngày 1–2: Swift Concurrency

Đọc/nghe trước (tìm trên developer.apple.com hoặc YouTube theo tên session, không cần link cụ thể):
- WWDC21 — "Meet async/await in Swift"
- WWDC21 — "Protect mutable state with Swift actors"
- WWDC21 — "Explore structured concurrency in Swift"

Code mẫu cần tự gõ lại và hiểu, không copy-paste:

```swift
actor WeatherCache {
    private var cache: [String: WeatherSnapshot] = [:]

    func snapshot(for city: String) async throws -> WeatherSnapshot {
        if let cached = cache[city] { return cached }
        let fresh = try await WeatherAPI.fetch(city: city)
        cache[city] = fresh
        return fresh
    }
}

func loadCheckpointWeather(_ checkpoint: Checkpoint) async {
    do {
        checkpoint.weather = try await weatherCache.snapshot(for: checkpoint.city)
    } catch {
        checkpoint.weatherError = error.localizedDescription
    }
}
```

Câu hỏi phỏng vấn thường gặp — tự trả lời được trước khi đi phỏng vấn:
1. Actor khác gì với class thông thường về thread-safety? (trả lời: actor tự serialize access vào mutable state, tránh data race mà không cần lock thủ công)
2. `async let` khác gì `await` tuần tự? (song song hoá độc lập các task, không chờ lần lượt)
3. Khi nào dùng `Task {}` vs `Task.detached {}`? (detached không kế thừa context/priority của task cha)
4. Structured concurrency là gì, tại sao an toàn hơn GCD thô?

### Ngày 3–4: SwiftData

Đọc trước:
- WWDC23 — "Meet SwiftData"
- WWDC23 — "Model your schema with SwiftData"

Code mẫu:

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

Câu hỏi thường gặp:
1. SwiftData khác Core Data ở kiến trúc nào? (SwiftData là lớp trừu tượng Swift-native trên CloudKit/Core Data, dùng macro `@Model` thay vì `.xcdatamodeld`)
2. `@Query` hoạt động thế nào, có tự động refresh UI không? (có, tích hợp trực tiếp với SwiftUI qua Observation)
3. Migration schema trong SwiftData xử lý ra sao? (dùng `SchemaMigrationPlan`, biết khái niệm là đủ, không cần thuộc lòng API)

### Ngày 5: Swift Package Manager (SPM)

Thao tác thực hành, không chỉ đọc:
1. Trong Xcode: File → New → Package → tạo `TripLogKit` làm local package trong cùng workspace.
2. Chuyển `Checkpoint`, `WeatherCache`, `WeatherAPI` vào package đó, expose qua `public`.
3. Thêm package vào app target qua "Frameworks, Libraries, and Embedded Content".
4. Thử build ra `.xcframework` cho package này (Product → Archive hoặc `swift build` + `xcodebuild -create-xcframework`) — để có thể trả lời câu hỏi về đóng gói/phân phối SDK nếu bị hỏi (liên quan đến kinh nghiệm VibeARMap trong CV).

Câu hỏi thường gặp:
1. SPM khác CocoaPods/Carthage ở điểm nào? (tích hợp thẳng vào Xcode/toolchain của Apple, không cần công cụ ngoài, versioning qua `Package.swift`)
2. Khi nào tách 1 module thành package riêng thay vì để chung target? (tái sử dụng, biên dịch song song nhanh hơn, ranh giới rõ ràng theo Clean Architecture)
3. XCFramework dùng để làm gì? (đóng gói binary đa kiến trúc để phân phối cho bên thứ ba mà không lộ source)

### Ngày 6–7: Ráp nối + tự kể lại câu chuyện

- Ráp cả 3 phần thành app chạy được, quay màn hình demo ngắn hoặc chụp screenshot để lưu làm bằng chứng.
- Push lên GitHub (repo riêng), có thể thêm link vào mục Projects trên CV nếu muốn tăng độ tin cậy.
- Tự luyện nói 60 giây: "Tôi vừa chủ động chuyển một phần kiến trúc sang Swift Concurrency + SwiftData + SPM qua dự án TripLogKit vì công ty hiện tại vẫn dùng completion handler/Core Data — đây là hướng tôi đang đẩy mạnh."

## Nếu chỉ còn 2–3 ngày trước phỏng vấn

Ưu tiên theo thứ tự:
1. Actor + async/await cơ bản (Ngày 1–2, rút gọn) — khả năng bị hỏi cao nhất vì là core Swift 5.5+.
2. SwiftData model + `@Query` cơ bản (Ngày 3, rút gọn) — không cần migration.
3. SPM: chỉ cần thao tác tạo local package 1 lần để có thể mô tả đúng quy trình (Ngày 5, rút gọn) — bỏ qua phần XCFramework nếu thiếu thời gian.

## Talking Points — 2 câu hỏi nóng nhất chắc chắn sẽ gặp

### A. "Đã 5 năm từ công việc Native iOS thuần cuối cùng (Axon Active, kết thúc 05/2021) — anh làm gì để giữ kỹ năng cập nhật?"

Đừng chỉ trả lời "tôi có dự án cá nhân" — dùng 2 lớp, ưu tiên lớp 1 trước:

**Lớp 1 (bằng chứng có sẵn trong CV, dẫn ra ngay được):** Native chưa từng biến mất khỏi công việc — ở mỗi công ty sau Axon đều có phần cầu nối Native do chính mình phụ trách:
- Hill Tech: viết native module tải/giải nén/verify Mini App bundle bằng giải mã đối xứng
- Webkom: viết native module thay thế WebView để phát livestream trực tiếp, tăng performance

**Lớp 2 (bổ sung, không phải toàn bộ câu trả lời):** thiếu thời gian làm 1 app SwiftUI/UIKit trọn vẹn bằng stack mới nhất, nên gần đây chủ động làm dự án cá nhân (TripLogKit) áp dụng Swift Concurrency + SwiftData để lấp khoảng đó.

**Script mẫu:**
> "Thực ra Native chưa bao giờ rời khỏi công việc của tôi — ở Hill Tech tôi viết module native để tải, giải nén và verify Mini App bundle; ở Webkom tôi viết module native thay WebView để phát livestream mượt hơn. Nhưng đúng là 5 năm qua tôi không làm 1 app SwiftUI/UIKit trọn vẹn với stack mới nhất, nên gần đây tôi chủ động làm 1 dự án cá nhân dùng Swift Concurrency và SwiftData để cập nhật lại phần đó."

Lưu ý: nếu bị hỏi tiếp "dự án cá nhân bắt đầu từ khi nào" — trả lời đúng thời điểm thật, không nói đã làm lâu năm nếu mới bắt đầu gần ngày phỏng vấn.

### B. "Anh có thể giải thích chi tiết cơ chế xác thực Mini App bundle không?"

**Tin tốt: cơ chế thực tế (asymmetric signature + checksum) đã đúng chuẩn ngành** — không phải điểm yếu cần chữa cháy, mà là điểm mạnh cần trình bày rõ ràng, mạch lạc để ghi điểm.

**Vì sao đây là cách làm đúng:** server giữ private key (không rời server) để ký vào checksum/hash của bundle; app chỉ cần public key nhúng sẵn để verify. Vì public key lộ ra ngoài cũng không sao (biết public key chỉ verify được, không tự tạo được chữ ký hợp lệ), nên kể cả app bị dịch ngược, attacker vẫn không thể tự ký một bundle giả mà app chấp nhận được. Đây chính là cơ chế Apple code signing, Android APK signing, Sparkle updater... đều dùng — vì bên verify (client) chạy trên thiết bị không đáng tin cậy tuyệt đối.

**Script trả lời — trình bày rõ luồng xử lý đầy đủ:**
> "Server ký vào checksum/hash của bundle bằng private key, kết quả chữ ký được encode base64 để truyền kèm bundle qua API. Khi app tải bundle về, nó tự tính lại checksum của bundle vừa tải, rồi dùng public key nhúng sẵn trong app để verify chữ ký đó có khớp với checksum không. Nếu hợp lệ mới cho giải nén và thực thi; nếu bundle bị sửa dù chỉ 1 byte, checksum sẽ khác và verify thất bại ngay. Vì server giữ private key nên kể cả ai đó dịch ngược app lấy được public key, họ cũng không thể tự ký một bundle giả để app chấp nhận."

**Câu hỏi mở rộng có thể gặp:** *"Vậy nội dung bundle có bị lộ không vì không mã hoá?"*
> "Đúng, mục tiêu ở đây là integrity/authenticity chứ không phải confidentiality — nội dung bundle không phải bí mật cần giấu, chỉ cần đảm bảo không bị chỉnh sửa/giả mạo. Nếu cần bảo mật nội dung thì có thể thêm 1 lớp mã hoá riêng, tách biệt với việc ký xác thực."

## Nếu chỉ còn 2–3 ngày trước phỏng vấn (nhắc lại ưu tiên)

Nếu thời gian rất gấp, ưu tiên học thuộc 2 script ở mục Talking Points trước — đây là 2 câu gần như chắc chắn gặp và không cần code demo mới trả lời được, trong khi phần code Swift Concurrency/SwiftData chỉ cần hiểu khái niệm cơ bản là đủ đối phó câu hỏi mức screening.

## Lưu ý về CV bản tải xuống (PDF/DOCX)

Website đã được cập nhật định vị iOS-first, nhưng file CV tải về (`document/NguyenNgocSon_CV.pdf`, `document/NguyenNgocSon_CV_Orange_Full.docx`) là file tĩnh, **không tự động đồng bộ** với nội dung website. Cần chỉnh sửa thủ công 2 file này để khớp với định vị mới, nếu không nhà tuyển dụng sẽ thấy 2 bản CV không khớp nhau (một bản web nói "iOS Developer", một bản PDF vẫn nói "Mobile Developer").
