import Foundation

extension Int {
    var seconds: Int {
        ((self % 3600) % 60)
    }
    var minutes: Int {
        ((self % 3600) / 60)
    }
    var hours: Int {
        (self / 3600)
    }
}