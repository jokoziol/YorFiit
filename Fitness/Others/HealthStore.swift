import HealthKit
import Foundation

class HealthStore {

    private static let healthStore: HKHealthStore = HKHealthStore()

    //MARK: - Request Permissions

    class func requestPermission() {

        if !HKHealthStore.isHealthDataAvailable() {
            return
        }

        let typesToShare = Set([HKQuantityType.workoutType()])

        let typesToRead = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!,
                               HKObjectType.quantityType(forIdentifier: .stepCount)!])

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { _, _ in
        }
    }

    class func requestHeartRatePermission() {

        if !HKHealthStore.isHealthDataAvailable() {
            return
        }

        let heartRate = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!])
        let healthStore = HKHealthStore()

        healthStore.requestAuthorization(toShare: [], read: heartRate) { _, _ in
        }
    }

    class func requestStepCountPermission() {

        if !HKHealthStore.isHealthDataAvailable() {
            return
        }

        let stepCount = Set([HKObjectType.quantityType(forIdentifier: .stepCount)!])

        healthStore.requestAuthorization(toShare: [], read: stepCount) { _, _ in
        }
    }

    class func requestBodyWeightPermission() {

        if !HKHealthStore.isHealthDataAvailable() {
            return
        }

        let bodyMass = Set([HKObjectType.quantityType(forIdentifier: .bodyMass)!])

        healthStore.requestAuthorization(toShare: [], read: bodyMass) { _, _ in
        }
    }

    //MARK: -

    class func getSteps(startDate: Date, endDate: Date, completion: @escaping (Double) -> Void) {

        let stepCountType: HKQuantityType = HKObjectType.quantityType(forIdentifier: .stepCount)!

        let predicate: NSPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let query: HKStatisticsQuery = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { statisticQuery, statisticResult, error in

            guard let _ = statisticResult,
                  let sum: HKQuantity = statisticResult?.sumQuantity()
            else {

                completion(0.0)
                return
            }

            completion(sum.doubleValue(for: HKUnit.count()))
        }

        healthStore.execute(query)
    }

    class func getHeartRate(startDate: Date, endDate: Date, completion: @escaping (Double) -> Void) {

        let heartRateType: HKQuantityType = HKObjectType.quantityType(forIdentifier: .heartRate)!

        let predicate: NSPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let query: HKStatisticsQuery = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: .mostRecent) { statisticQuery, statisticResult, error in

            guard let _ = statisticResult,
                  let bpm: Double = statisticResult?.mostRecentQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            else {

                completion(0.0)
                return
            }

            completion(bpm)
        }

        healthStore.execute(query)
    }

    class func getBodyMass(completion: @escaping (Double) -> Void) {

        let bodyMassType: HKQuantityType = HKObjectType.quantityType(forIdentifier: .bodyMass)!

        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        let query: HKSampleQuery = HKSampleQuery(sampleType: bodyMassType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, results, error) in

            guard let result = results?.first as? HKQuantitySample else {
                completion(0.0)
                return
            }
            let bodyMass: Double = result.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))

            completion(bodyMass)
        }

        healthStore.execute(query)
    }

    //MARK: -

    class func persistStepsFromCurrentDay(completion: @escaping () -> Void) {
        getSteps(startDate: Calendar.current.startOfDay(for: Date()), endDate: Date()) { (steps: Double) in

            guard steps >= 0.0 else {
                completion()
                return
            }

            WorkoutTime.saveTimerStartTime(timeInSeconds: Int(Date().timeIntervalSince1970))

            WorkoutSteps.persistDailySteps(steps: WorkoutSteps.getDailySteps() * (-1))
            WorkoutSteps.persistDailySteps(steps: steps)

            completion()
        }
    }

    class func persistAllSteps() {

        let startTime: Int = WorkoutTime.getTimerStartTime()
        let startDate: Date = Date(timeIntervalSince1970: TimeInterval(startTime))

        WorkoutTime.saveTimerStartTime(timeInSeconds: Int(Date().timeIntervalSince1970))

        let component: DateComponents = Calendar.current.dateComponents([.day], from: startDate, to: Date())

        guard let days: Int = component.day else {
            return
        }

        for index in 0...days + 1 {
            let item: Date = startDate.addingTimeInterval(Double(index) * 3600 * 24)

            let (startDate1, endDate): (startDate: Date, endDate: Date) = item.getFullDay()

            getSteps(startDate: startDate1, endDate: endDate) { steps in
                WorkoutSteps.persistDailySteps(date: item.getDateString(), steps: WorkoutSteps.getDailySteps(dateString: item.getDateString()) * (-1))
                WorkoutSteps.persistDailySteps(date: item.getDateString(), steps: steps)
            }
        }
    }

    class func persistWorkout(_ workoutItem: WorkoutItem) {

        let startDate: Date = workoutItem.startDate
        let endDate: Date = Date(timeIntervalSince1970: (startDate.timeIntervalSince1970 + Double(workoutItem.timeInSeconds)))

        let quantity: HKQuantity = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: workoutItem.calories)
        let distanceQuantity: HKQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: workoutItem.distanceInMeters)

        let workout: HKWorkout = HKWorkout(activityType: getWorkoutActivityTypeType(workoutType: workoutItem.type),
                start: startDate,
                end: endDate,
                duration: (startDate.timeIntervalSince(endDate)),
                totalEnergyBurned: quantity,
                totalDistance: distanceQuantity,
                metadata: nil)

        healthStore.save(workout) { _, _ in
        }
    }

    class func getWorkoutActivityTypeType(workoutType: Int) -> HKWorkoutActivityType {
        return HKWorkoutActivityType(rawValue: WorkoutType.getWorkout(type: workoutType)?.activityType ?? 3000) ?? .other
    }
}
