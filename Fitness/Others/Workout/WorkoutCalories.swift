import Foundation

class WorkoutCalories {

    public class func getCaloriesString(workoutType: Int, timeInSeconds: Int, distanceInMeters: Double) -> String? {

        let calories: Double = getCalories(workoutType: workoutType, timeInSeconds: timeInSeconds, distanceInMeters: distanceInMeters)

        if calories < 0.0 {
            return nil
        }

        return "cal".localized(calories)
    }

    public class func getCalories(workoutType: Int, timeInSeconds: Int, distanceInMeters: Double) -> Double {

        let weight: Double = UserInformation.getWeight() == 0.0 ? 75.0 : UserInformation.getWeight()
        let calories: Double = (Double(timeInSeconds) / 60.0) * (getWorkoutTypeMetValue(workoutType) * 3.5 * weight) / 200.0

        return calories
    }

    private class func getWorkoutTypeMetValue(_ workoutType: Int) -> Double {
        return WorkoutType.getWorkout(type: workoutType)?.metValue ?? 0.0
    }
}