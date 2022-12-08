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

### Workout id

Each workout must have a unique id. The id of each new workout is: `last workout id` + 1.

Example: There are 2 workouts. Walking (id: 0) and running (id: 1). The new workout (cycling) gets the id 3.

Here is a list of all workouts so far:

|           Workout | ID  |
|------------------:|-----|
|           Walking | 0   |
|           Running | 1   |
|           Cycling | 2   |
|              HIIT | 3   |
| Strength Training | 4   |
|            Hiking | 5   |
|          Swimming | 6   |
|        Kickboxing | 7   |
|            Boxing | 8   |
|           Skating | 9   |
|      Snowboarding | 10  |

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

- `name` is displayed in the app. The name must be localized
- `usesLocation` calculates the distance in meters and returns a list of coordinates
- `usesDistance` calculates the distance in meters and **not** returns a list of coordinates
- `metValue` cannot be smaller then zero
- `activityType` is a constant of `HKWorkoutActivityType`
