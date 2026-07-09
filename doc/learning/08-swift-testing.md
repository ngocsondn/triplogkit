# 08 — Swift Testing (`@Test`, `#expect`)

**Trạng thái:** 📝 Kế hoạch — target Tests hiện tại vẫn ở dạng cũ (XCTest), chưa viết lại bằng Swift Testing

## TL;DR
Swift Testing là framework test mới (thay thế dần XCTest) dùng macro `@Test` đánh dấu function test (không cần tên bắt đầu bằng `test`), và `#expect(...)` thay `XCTAssert...` — cho message lỗi rõ ràng hơn vì macro capture được cả expression gốc.

## 🧩 Vấn đề cũ (XCTest)
```swift
// XCTest — quy ước cứng: class kế thừa XCTestCase, method bắt đầu bằng "test"
final class TripLogKitTests: XCTestCase {
    func testExample() throws {
        XCTAssertEqual(1 + 1, 2)
    }
}
```
Giới hạn: phải nhớ đúng naming convention (`test` prefix) để runner nhận diện, message lỗi của `XCTAssertEqual` không luôn hiển thị rõ giá trị thực tế hai bên khi fail, và khó parametrize test (chạy cùng 1 test với nhiều input) mà không viết thêm boilerplate.

## 🔧 Giải pháp / Refactor (kế hoạch)
```swift
import Testing

@Test func fetchFunFactReturnsNonEmptyString() async throws {
    let fact = try await FunFactService.fetchFunFact(for: "Archery")
    #expect(!fact.isEmpty)
}

@Test(arguments: ["Archery", "Boxing", "Golf"])
func fetchFunFactMentionsActivity(activity: String) async throws {
    let fact = try await FunFactService.fetchFunFact(for: activity)
    #expect(fact.contains(activity))
}
```
`@Test` không ràng buộc naming convention hay kế thừa `XCTestCase`. `#expect` là macro nên khi fail sẽ in ra chính expression + giá trị thực tế, không cần chọn đúng `XCTAssertEqual`/`XCTAssertTrue`/... cho từng trường hợp. `arguments:` cho phép parametrize test trực tiếp mà không cần loop thủ công.

## 🧠 Đúc kết — nhớ lâu
- **Nguyên tắc:** Swift Testing tận dụng macro (cùng cơ chế đứng sau `@Observable`/`@Model`) để framework "hiểu" được expression gốc trong `#expect`, chứ không chỉ đơn thuần đổi tên hàm assert.
- **Mẹo phân biệt:** `#expect` — test tiếp tục chạy dù assertion fail (ghi nhận lỗi, không dừng function). `#require` — dừng ngay function test nếu điều kiện fail (tương đương `XCTUnwrap`/early return khi cần giá trị đó để test tiếp).
- **Khẩu quyết:** *"expect là ghi nhận rồi đi tiếp, require là không đúng thì dừng luôn."*

## 🎯 Phỏng vấn
**Q: Swift Testing khác XCTest ở điểm nào đáng chú ý nhất?**
A: Dùng macro (`@Test`, `#expect`) nên không ràng buộc naming convention/kế thừa `XCTestCase`, message lỗi rõ ràng hơn vì capture được expression gốc, và hỗ trợ parametrize test (`arguments:`) trực tiếp mà không cần viết loop thủ công.

**Q: `#expect` khác `#require` thế nào?**
A: `#expect` ghi nhận lỗi nhưng function test vẫn tiếp tục chạy; `#require` dừng function ngay nếu điều kiện không thỏa — dùng khi cần giá trị đó (ví dụ unwrap optional) để các bước sau trong test có thể chạy tiếp.

## 📁 Bằng chứng
Chưa có — target Tests hiện tại vẫn dùng XCTest. Khi thực hiện: viết lại ít nhất `TripLogKitTests.swift` bằng Swift Testing và ghi lại kết quả build-for-testing.
