import Foundation

extension String {

    func localized() -> String {
        NSLocalizedString(self, tableName: "Localizable", bundle: .main, value: self, comment: self)
    }

    func localized(_ comment: CVarArg...) -> String {
        String(format: localized(), locale: .current, comment)
    }
}