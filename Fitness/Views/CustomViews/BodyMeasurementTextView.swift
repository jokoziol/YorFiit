import SwiftUI

public struct BodyMeasurementTextView: View {

    private var completion: (Double) -> Void

    private let usableCharacters: String = "0123456789., "
    private let textFieldHint: String
    private let measurementUnit: String

    @State private var textFieldText: String

    public init(_ textFieldHint: String, _ defaultValue: String = "0.0", _ bodyMeasurement: BodyMeasurement, newValue: @escaping (Double) -> Void) {
        self.textFieldHint = textFieldHint

        textFieldText = String(format: "%.02f", locale: .current, NumberFormatter().formatNumber(defaultValue))
        completion = newValue

        if Locale.current.measurementSystem == Locale.MeasurementSystem.metric {
            measurementUnit = (bodyMeasurement == .weight ? "kg" : "m")
        } else {
            measurementUnit = (bodyMeasurement == .weight ? "lb" : "ft")
        }
    }

    public var body: some View {

        HStack {

            TextField(text: $textFieldText) {
                Text(textFieldHint)
            }
                    .keyboardType(.decimalPad)
                    .onChange(of: textFieldText) {

                        let decimalPoints = $0.filter {
                                    $0 == (useCommaForDecimal() ? "," : ".")
                                }
                                .count

                        if decimalPoints > 1 {
                            var result = $0
                            result.removeLast()

                            textFieldText = result
                            return
                        }

                        completion(NumberFormatter().formatNumber($0))
                    }

            Text(measurementUnit)
        }
    }


    private func useCommaForDecimal() -> Bool {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = .current

        guard let _ = numberFormatter.number(from: "12,34") else {
            return false
        }

        return true
    }
}