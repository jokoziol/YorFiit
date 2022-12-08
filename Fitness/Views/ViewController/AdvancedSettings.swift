import SwiftUI

struct AdvancedSettingsView: View {

    private let titleList: [String] = ["settingsHeartRate",
                                       "settingsLastWorkout",
                                       "settingsShowBestWorkout",
                                       "settingsShowWorkout",
                                       "settingsBodyMass",
                                       "settingsLocation"]

    @State private var switchList: [Bool] = [SettingsInformation.showHeartRate(),
                                             SettingsInformation.showLastTraining(),
                                             SettingsInformation.showBestWorkout(),
                                             SettingsInformation.showWorkout(),
                                             SettingsInformation.canGetBodyMass(),
                                             SettingsInformation.canSaveCoordinates()]

    var body: some View {
        VStack {
            Form {

                Section {
                    Toggle(titleList[0].localized(), isOn: $switchList[0])
                            .onChange(of: switchList[0]) { _ in
                                persistSettings(0)
                            }
                    Toggle(titleList[1].localized(), isOn: $switchList[1])
                            .onChange(of: switchList[1]) { _ in
                                persistSettings(1)
                            }
                } header: {
                    Text("settingsSectionHome".localized())
                }

                Section {
                    Toggle(titleList[2].localized(), isOn: $switchList[2])
                            .onChange(of: switchList[2]) { _ in
                                persistSettings(2)
                            }
                    Toggle(titleList[3].localized(), isOn: $switchList[3])
                            .onChange(of: switchList[3]) { _ in
                                persistSettings(3)
                            }
                } header: {
                    Text("settingsSectionStatistics".localized())
                }

                Section {
                    Toggle(titleList[4].localized(), isOn: $switchList[4])
                            .onChange(of: switchList[4]) { _ in
                                persistSettings(4)
                            }
                    Toggle(titleList[5].localized(), isOn: $switchList[5])
                            .onChange(of: switchList[5]) { _ in
                                persistSettings(5)
                            }
                } header: {
                    Text("settingsSectionProfile".localized())
                }
            }
        }
                .navigationTitle("advancedSettings".localized())
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    self.switchList = [SettingsInformation.showHeartRate(),
                                       SettingsInformation.showLastTraining(),
                                       SettingsInformation.showBestWorkout(),
                                       SettingsInformation.showWorkout(),
                                       SettingsInformation.canGetBodyMass(),
                                       SettingsInformation.canSaveCoordinates()]
                }
    }

    private func persistSettings(_ item: Int) {

        switch item {
        case 0: SettingsInformation.persistShowHeartRate(switchList[item])
        case 1: SettingsInformation.persistShowLastTraining(switchList[item])
        case 2: SettingsInformation.persistShowBestWorkout(switchList[item])
        case 3: SettingsInformation.persistShowWorkout(switchList[item])
        case 4: SettingsInformation.persistGetBodyMass(switchList[item])
        case 5: SettingsInformation.persistCanSaveCoordinates(switchList[item])
        default: return
        }

        if item == 0 {
            HealthStore.requestHeartRatePermission()
        }
        if item == 4 {
            HealthStore.requestBodyWeightPermission()
        }
    }
}