//
//  ScoreCounter.swift
//  TripLogKit
//
//  Demo actor & Sendable: 2 cách implement 1 counter dùng chung giữa
//  nhiều Task chạy đồng thời — 1 bản không an toàn (race condition,
//  mất update), 1 bản dùng actor (Swift tự serialize mọi truy cập).
//

import Foundation

/// Class thường: không có gì bảo vệ `score` khỏi bị đọc/ghi đồng thời
/// từ nhiều Task. Đây chính xác là lý do actor tồn tại.
final class UnsafeScoreCounter {
    private(set) var score = 0

    /// Cố tình chèn `await Task.yield()` giữa đọc và ghi để "mở rộng"
    /// race window một cách ổn định cho demo (data race thật ngoài đời
    /// không cần yield mới xảy ra — máy đa nhân tự nhiên đã đủ để 2 Task
    /// đọc cùng giá trị cũ trước khi cả hai ghi đè lên nhau).
    func increment() async {
        let old = score
        await Task.yield()
        score = old + 1
    }
}

/// actor: Swift tự đảm bảo chỉ 1 Task được thực thi code bên trong actor
/// tại một thời điểm (serialized), nên `score += 1` không bao giờ bị
/// interleave bởi Task khác — không cần lock/mutex thủ công.
actor ScoreCounter {
    private(set) var score = 0

    func increment() {
        score += 1
    }
}
