import Foundation

extension Date {

    func getFullDay() -> (startDate: Date, endDate: Date) {

        var startDate: Date = self
        var length: TimeInterval = TimeInterval()
        var _ = Calendar.current.dateInterval(of: .day, start: &startDate, interval: &length, for: startDate)

        let endDate: Date = startDate.addingTimeInterval(length)

        return (startDate, endDate)
    }

    func getDateString() -> String {
        let calendar: Calendar = Calendar.current

        let year: Int = calendar.component(.year, from: self)
        let month: Int = calendar.component(.month, from: self)
        let day: Int = calendar.component(.day, from: self)

        return String(year) + "-" + String(month) + "-" + String(day)
    }

    func getDaysFromMonth(_ from: Int) -> [Date] {

        var currentDate: Date = getPreviousMonth(from)
        var dateList: [Date] = []

        while currentDate < self {
            dateList.append(currentDate)
            currentDate = getNextDay(date: currentDate)
        }

        return dateList
    }

    func getDaysFromWeek() -> [Date] {

        let calendar: Calendar = Calendar(identifier: .iso8601)
        let startComponent: DateComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        let startComponentDate: Date = calendar.date(from: startComponent)!

        var startDate: Date = Calendar.current.date(byAdding: .day, value: 0, to: startComponentDate)!

        let endComponent: DateComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        let endComponentDate: Date = calendar.date(from: endComponent)!

        let endDate: Date = Calendar.current.date(byAdding: .day, value: 6, to: endComponentDate)!

        var dateList: [Date] = []

        while startDate <= endDate {
            dateList.append(startDate)
            startDate = getNextDay(date: startDate)
        }

        return dateList
    }

    private func getNextDay(date: Date) -> Date {
        var components: DateComponents = DateComponents()
        components.day = 1

        return Calendar.current.date(byAdding: components, to: date)!
    }

    func getPreviousMonth(_ from: Int) -> Date {

        let calendar: Calendar = Calendar.current
        var component: DateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        component.second = 0

        guard let endDate: Date = calendar.date(from: component) else {
            return Date()
        }

        guard let startDate: Date = calendar.date(byAdding: .month, value: (from * (-1)), to: endDate) else {
            return Date()
        }

        return startDate
    }

    func getPreviousDay(_ from: Int) -> Date {

        let calendar: Calendar = Calendar.current
        var component: DateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        component.second = 0

        guard let endDate: Date = calendar.date(from: component) else {
            return Date()
        }

        guard let startDate: Date = calendar.date(byAdding: .day, value: (from * (-1)), to: endDate) else {
            return Date()
        }

        return startDate
    }
}