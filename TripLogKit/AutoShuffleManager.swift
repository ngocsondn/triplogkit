//
//  AutoShuffleManager.swift
//  TripLogKit
//
//  Fixed: [weak self] phá retain cycle self -> timer -> closure -> self.
//  Vẫn invalidate() tường minh vì RunLoop giữ Timer độc lập với `self`,
//  nếu không invalidate thì Timer vô chủ vẫn chạy tốn CPU dù self đã weak.
//
//  @Observable (Observation framework) thay cho ObservableObject + @Published:
//  không cần property wrapper trên từng field, macro tự sinh tracking dựa trên
//  property nào thực sự được đọc trong body của View (fine-grained hơn Combine,
//  vốn publish toàn bộ view mỗi khi bất kỳ @Published nào đổi).
//

import Foundation
import Observation

@Observable
final class AutoShuffleManager {
    var tick = 0
    @ObservationIgnored private var timer: Timer?

    init() {
        print("🟢 AutoShuffleManager init:", ObjectIdentifier(self))
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
        print("🔴 AutoShuffleManager deinit:", ObjectIdentifier(self))
    }
}
