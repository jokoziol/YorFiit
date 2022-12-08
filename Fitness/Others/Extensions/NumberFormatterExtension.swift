import Foundation

extension NumberFormatter {

    public func formatNumber(_ from: String) -> Double {

        let filteredString: String = from.filter {
            "1234567890., ".contains($0)
        }

        let numberFormatter: NumberFormatter = self
        numberFormatter.locale = .current
        numberFormatter.numberStyle = .decimal

        guard let formattedNumber: NSNumber = numberFormatter.number(from: filteredString) else {
            return 0.0
        }

        return Double(truncating: formattedNumber)
    }

}