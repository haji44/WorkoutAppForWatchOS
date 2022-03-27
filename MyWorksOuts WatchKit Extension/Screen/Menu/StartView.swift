//
//  StartView.swift
//  MyWorksOuts WatchKit Extension
//
//  Created by kitano hajime on 2022/03/16.
//

import SwiftUI
import HealthKit

struct StartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    var workoutTypes: [HKWorkoutActivityType] = [.cycling, .running, .swimming]

    var body: some View {
        List(workoutTypes) { workoutType in
            NavigationLink(workoutType.name, destination: SessionPagingView(),
                           tag: workoutType, selection: $workoutManager.selectedWorkout)
                .padding(EdgeInsets(top: 15, leading: 5, bottom: 15, trailing: 5))
        }
        .listStyle(.carousel)
        .navigationBarTitle("Workout")
        .onAppear {
            workoutManager.requestAuthorization()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}


extension HKWorkoutActivityType: Identifiable {
    public var id: UInt {
        rawValue
    }

    var name: String {
        switch self {
        case .running:
            return "Run"
        case .cycling:
            return "Cycling"
        case .swimming:
            return "Swim"
        default:
            return "Nothing"
        }
    }
}
