import Foundation

class WorkoutStore: ObservableObject {
    @Published var workoutItems = [WorkoutItem]()

    func load() {

        workoutItems.removeAll()

        var workoutList = [String]()

        for item in KeychainService.getAll(targetService: StorageKeys.workoutKey.rawValue) {
            if item != "" {
                workoutList.append(item)
            }
        }

        let sortedList = workoutList.sorted {
            $0 > $1
        }

        for item in sortedList {
            
            guard let json = KeychainService.load(service: StorageKeys.workoutKey.rawValue, account: item) else{
                continue
            }
            
            guard let workout = JsonHelper().toObject(type: WorkoutItem.self, json: json) else{
                continue
            }
            
            workoutItems.append(workout)
        }
    }

    func remove(_ workoutId: String) {

        for index in 0...workoutItems.count - 1 {

            if workoutItems[index].workoutId == workoutId {
                workoutItems.remove(at: index)
                return
            }
        }
    }
}
