# 07 — Ngôn ngữ Swift: Macros, typed throws, `~Copyable`

**Trạng thái:** 📝 Kế hoạch — chưa demo

## TL;DR
Ba khái niệm đứng sau các tính năng đã dùng: `@Observable`/`@Model` (đã demo) chính là **macro** do Apple viết; `throws(MyError)` là bản có kiểu cụ thể của `throws`; `~Copyable` là kiểu dữ liệu không cho phép copy ngầm (nâng cao, ít gặp trong SwiftUI app thông thường).

## 🧩 + 🔧 (gộp vì đây là 3 mục kiến thức rời, chưa có code before/after riêng)

### Macros
Đứng sau `@Observable` ([bài 02](02-observable-macro.md)) và `@Model` ([bài 06](06-swiftdata-model-query.md)) đã dùng — macro là code Swift **sinh thêm code Swift** tại compile-time (khác với C macro chỉ là text substitution). Trước khi có macro, muốn có hành vi tương tự `@Observable` phải tự viết tay toàn bộ boilerplate tracking cho từng property.

### Typed throws — `throws(MyError)`
```swift
// Trước: throws chung, không biết trước loại lỗi nào
func fetch() throws -> Data { ... }

// Typed throws: khai báo rõ chỉ throw đúng 1 loại lỗi
func fetch() throws(FunFactError) -> Data { ... }
```
Lợi ích: caller biết chắc chắn loại lỗi mà không cần cast `as?` trong `catch`, hữu ích khi API có domain lỗi rõ ràng (như `FunFactError` đã dùng ở [bài 03](03-async-await.md)).

### `~Copyable` (noncopyable types)
Struct/enum thông thường trong Swift luôn copy được (value semantics). `~Copyable` đánh dấu 1 type **không** cho phép copy ngầm — dùng khi muốn đảm bảo tại compile-time chỉ có đúng 1 "chủ sở hữu" tại một thời điểm (tương tự `move`/ownership trong Rust). Nâng cao, hiếm gặp trong SwiftUI app thông thường — biết khái niệm tồn tại là đủ trừ khi vai trò đòi hỏi hệ thống/performance-critical code.

## 🧠 Đúc kết — nhớ lâu
- **Khẩu quyết Macro:** *"Macro không chạy lúc app chạy — nó viết code hộ mình lúc compile."*
- **Mẹo phân biệt typed throws:** chỉ nên dùng khi 1 function thực sự chỉ throw **đúng 1 loại lỗi** cụ thể; nếu vẫn có thể throw nhiều loại lỗi khác nhau, `throws` thường (untyped) vẫn hợp lý hơn.
- **Khẩu quyết `~Copyable`:** *"Copyable là mặc định vì Swift ưu tiên value semantics — `~Copyable` là lúc mình chủ động đòi lại quyền kiểm soát 'ai giữ bản duy nhất'."*

## 🎯 Phỏng vấn
**Q: Macro trong Swift hoạt động ở giai đoạn nào?**
A: Compile-time — macro sinh thêm code Swift dựa trên code viết tay, không có overhead runtime nào từ việc "generate" đó (khác hoàn toàn cơ chế reflection runtime).

**Q: Typed throws giải quyết vấn đề gì?**
A: Cho caller biết trước chính xác loại lỗi có thể xảy ra ngay tại signature của function, không cần ép kiểu (`as?`) trong `catch` để biết đang xử lý lỗi gì.

**Q: `~Copyable` dùng khi nào?**
A: Khi cần đảm bảo tại compile-time một giá trị chỉ có đúng 1 chủ sở hữu tại một thời điểm (ví dụ quản lý resource độc quyền) — ít gặp trong app UI thông thường, phổ biến hơn ở code hệ thống/performance-critical.

## 📁 Bằng chứng
Chưa có — mục kế hoạch, chưa có demo code trong project này.
