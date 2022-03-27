//
//  MetricsView.swift
//  MyWorksOuts WatchKit Extension
//
//  Created by kitano hajime on 2022/03/26.
//

import SwiftUI
import HealthKit

struct MetricsView: View {
    @EnvironmentObject var workoutManager: WorkoutManager

    var body: some View {
        TimelineView(
            MetricsTimelineSchedule(from: workoutManager.builder?.startDate ?? Date())) { context in
                VStack(alignment: .leading) {
                    // MARK: TIME
                    ElapesdTimeView(elapedTime: workoutManager.builder?.elapsedTime ?? 0,
                                    showSubseconds: context.cadence == .live)
                        .foregroundColor(.yellow)
                    // MARK: CALORIES
                    Text( Measurement(value: workoutManager.activeEnergy,
                                      unit: UnitEnergy.kilocalories)
                        .formatted(
                            .measurement(width: .abbreviated,
                                         usage: .workout,
                                         numberFormatStyle: .number.precision(.fractionLength(0)))
                          ))
                    // MARK: HR
                    Text(workoutManager.heartRate
                        .formatted(.number.precision(.fractionLength(0))) + "bpm" )
                    // MARK: DISTANCE
                    Text(
                        Measurement(value: workoutManager.distance,
                                    unit: UnitLength.meters)
                            .formatted(
                                .measurement(width: .abbreviated,
                                             usage: .road)
                            )
                    )
                }
                .font(.system(.title, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)
                .ignoresSafeArea(edges: .bottom)
                .scenePadding()
            }
    }
}

private struct MetricsTimelineSchedule: TimelineSchedule {
    typealias Entries = PeriodicTimelineSchedule.Entries
    var startDate: Date
    init(from startDate: Date) {
        self.startDate = startDate
    }

    func entries(from startDate: Date, mode: Mode) -> PeriodicTimelineSchedule.Entries {
        PeriodicTimelineSchedule(from: self.startDate, by: (mode == .lowFrequency ? 1.0 : 1.0 / 30.0))
            .entries(from: startDate, mode: mode)
    }
}

struct MetricsView_Previews: PreviewProvider {
    static var previews: some View {
        MetricsView()
    }
}
