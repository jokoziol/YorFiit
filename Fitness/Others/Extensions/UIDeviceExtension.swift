import Foundation
import SwiftUI

extension UIDevice {

    public func getBatteryLevel() -> Float {

        #if targetEnvironment(simulator)
        return 50.0
        #endif

        isBatteryMonitoringEnabled = true

        let percentage: Float = batteryLevel * 100

        isBatteryMonitoringEnabled = false

        return percentage
    }

    public func getFreeDiskSpace() -> Int64 {

        guard let systemAttributes: [FileAttributeKey: Any] = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
              let space = (systemAttributes[.systemFreeSize] as? NSNumber)?.int64Value
        else {
            return 0
        }

        return space
    }
}