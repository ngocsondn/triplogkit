//
//  FunFactService.swift
//  TripLogKit
//
//  Demo async/await cơ bản: network call giả lập bằng Task.sleep,
//  thỉnh thoảng throw lỗi để có chỗ demo try/catch thật.
//

import Foundation

enum FunFactError: LocalizedError {
    case simulatedFailure

    var errorDescription: String? {
        "Server giả lập bị lỗi, thử lại xem."
    }
}

enum FunFactService {
    static func fetchFunFact(for activity: String) async throws -> String {
        // Task.sleep ném CancellationError nếu Task bị huỷ giữa chừng
        // (vd. view biến mất trong lúc đang chờ) — đây là cách Swift
        // concurrency propagate cancellation một cách hợp tác (cooperative).
        try await Task.sleep(for: .seconds(1.5))

        guard Int.random(in: 0..<10) != 0 else {
            throw FunFactError.simulatedFailure
        }

        let facts = [
            "\(activity) được chơi hoặc luyện tập ở hàng chục quốc gia trên thế giới.",
            "\(activity) đòi hỏi sự kết hợp giữa kỹ thuật và phản xạ nhanh.",
            "Nhiều vận động viên \(activity) chuyên nghiệp tập luyện hơn 20 giờ mỗi tuần.",
            "\(activity) có lịch sử phát triển thú vị qua nhiều thế kỷ.",
        ]
        return facts.randomElement() ?? "\(activity) là một môn thể thao thú vị."
    }
}
