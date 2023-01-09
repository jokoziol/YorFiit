import Foundation

enum StorageKeys: String {

    case temporaryDistance = "temporaryDistance"

    case temporaryTime = "temporaryTime"

    case temporaryWorkoutType = "temporaryWorkoutType"

    case dailyDistance = "dailyDistance"

    case dailySteps = "dailySteps"

    case dailyTime = "dailyTime"

    case saveWorkoutDistance = "savedTrainingDistance"

    case saveWorkoutTime = "savedWorkoutTime"

    case saveWorkoutType = "savedWorkoutType"

    case saveWorkoutLocation = "savedWorkoutLocation"

    case timerStartTime = "timerStartTime"

    case workoutKeys = "workoutKeys" //TODO delete
    
    case workoutKey = "workoutKey"

    case locationKeys = "locationKeys"

    case geofencingKeys = "geofencingKey"

    case geofencing = "geofencing"

    case workoutLocation = "location"

    case coordinates = "coordinates"

    case saveCoordinates = "canSaveCoordinates"

    case latitude = "latitude"

    case longitude = "longitude"

    case address = "address"

    case publicKey = "publicKey"

    case userSettings = "profile"

    case username = "username"

    case height = "height"

    case weight = "weight"

    case launchedForFirstTime = "launchedForFirstTime"

    case resetInProgress = "resetInProgress"

    case showHeartRate = "showHeartRate"

    case showLastWorkout = "showLastWorkout"

    case showBestWorkout = "showBestWorkout"

    case showWorkout = "showWorkout"

    case getBodyMass = "canGetBodyMass"
}
