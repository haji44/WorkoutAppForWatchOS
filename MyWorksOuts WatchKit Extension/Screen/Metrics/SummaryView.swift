//
//  SummaryView.swift
//  MyWorksOuts WatchKit Extension
//
//  Created by kitano hajime on 2022/03/27.
//

import SwiftUI
import HealthKit

struct SummaryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading) {
                SummaryMetricView(title: "Total Time", value: durationFormatter.string(from: 30 * 60 ) ?? "")
                    .accentColor(.yellow)
                SummaryMetricView(title: "Total Distance",
                                  value: Measurement(value: 1624, unit: UnitLength.meters).formatted(
                                    .measurement(width: .abbreviated, usage: .road)
                                  ))
                    .accentColor(.yellow)
                SummaryMetricView(title: "Total Calories",
                                  value: Measurement(value: 332, unit: UnitEnergy.kilocalories).formatted(
                                    .measurement(width: .abbreviated, usage: .workout, numberFormatStyle: .number.precision(.fractionLength(0)))
                                  ))
                    .accentColor(.pink)
                SummaryMetricView(title: "Avg Heart Rate",
                                  value: 154.formatted() + "bpm")
                .accentColor(Color.red)
                Text("Acitivity Rings")
                ActivityRingsView(healthStore: HKHealthStore())
                    .frame(width: 50, height: 50)
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                }
            }
            .scenePadding()
        }
        .navigationTitle("Summary")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
    }
}

struct SummaryMetricView: View {
    var title: String
    var value: String

    var body: some View {
        Text(title)
        Text(value)
            .font(.system(.title2, design: .rounded)
                .lowercaseSmallCaps()
            )
            .foregroundColor(.accentColor)
        Divider()
    }
}
