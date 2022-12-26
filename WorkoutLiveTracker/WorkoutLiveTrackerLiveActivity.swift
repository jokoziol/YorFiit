import ActivityKit
import WidgetKit
import SwiftUI

struct WorkoutLiveTrackerLiveActivity: Widget {

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutLiveTrackerAttributes.self) { context in
            WorkoutLiveTrackerView(context: context)

        } dynamicIsland: { context in
            DynamicIsland {

                DynamicIslandExpandedRegion(.leading) {
                    Text(context.state.startDate, style: .timer).font(.title.bold())
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.attributes.name)").font(.title.bold())
                }
                DynamicIslandExpandedRegion(.bottom) {

                    GeometryReader { geometryProxy in
                        HStack {
                            if context.state.caloriesString != nil {
                                Text(context.state.caloriesString ?? "").frame(width: (geometryProxy.size.width / 3.0) - 8.0, alignment: .leading)
                            }

                            if context.state.distanceString != nil {
                                Text(context.state.distanceString ?? "").frame(width: (geometryProxy.size.width / 3.0) - 8.0, alignment: .center)
                            }

                            if context.state.paceString != nil {
                                Text(context.state.paceString ?? "").frame(width: (geometryProxy.size.width / 3.0) - 8.0, alignment: .trailing)
                            }
                        }
                    }

                    Spacer().frame(height: 16.0)
                }
            } compactLeading: {
                Image(systemName: "figure.walk")
            } compactTrailing: {
            } minimal: {
                Image(systemName: "figure.walk")
            }
                    .keylineTint(Color.cyan)
        }
    }
}
