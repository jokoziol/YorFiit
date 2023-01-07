# Contribution

Thank you for contributing to the project.

## Setup

1. Clone the repository

```bash
git clone https://github.com/jokoziol/YorFiit.git
```

2. Open the project

```bash
open Fitness.xcodeproj
```

## Contribution rules

- Use spaces instead of tabs. The new code should have 4 spaces instead of a tab
- View files should contain `View` in the file name. Example:
  `FirstPage.swift` should be renamed to `FirstView.swift`
- Add explicit types to variables. Example:

```swift
let minutes: Int = 10
```

## Workouts

The project was designed to make it easy as possible to add more workouts. To add more workouts edit this
file: `Config/Workout/workoutConfig.json`.

### Workout sections

```json
{
  "workoutSections": [
    {
      "name": "sectionName",
      "workouts": []
    }
  ]
}
```

- `name` is displayed in the app. The name must be localized
- `workouts` is an array of `workout`

### Workout

```json
{
  "workout": [
    {
      "name": "workoutName",
      "usesLocation": true,
      "usesDistance": false,
      "metValue": 0.0,
      "activityType": 0
    }
  ]
}
```

- `name` is displayed in the app. The name must be unique and localized
- `usesLocation` calculates the distance in meters and returns a list of coordinates
- `usesDistance` calculates the distance in meters and **not** returns a list of coordinates
- `metValue` cannot be smaller then zero
- `activityType` is a constant of `HKWorkoutActivityType`
