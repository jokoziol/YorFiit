import Foundation
import SwiftUI
import ActivityKit
import WidgetKit

struct WorkoutLiveTrackerView: View {

    let context: ActivityViewContext<WorkoutLiveTrackerAttributes>

    var body: some View {
        VStack {
            Spacer().frame(height: 8.0)

            HStack {
                Text(context.state.startDate, style: .timer).font(.title.bold())
                Text("\(context.attributes.name)").font(.title.bold())
            }


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
                .padding(.horizontal)
    }
}
