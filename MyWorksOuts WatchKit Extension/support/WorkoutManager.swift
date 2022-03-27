//
//  WorkoutManager.swift
//  MyWorksOuts WatchKit Extension
//
//  Created by kitano hajime on 2022/03/27.
//

import Foundation
import HealthKit

class WorkoutManager: NSObject, ObservableObject {
    var selectedWorkout: HKWorkoutActivityType? {
        didSet {
            guard let selectedWorkout = selectedWorkout else { return }
            starWorkout(workoutType: selectedWorkout)
        }
    }

    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?

    func starWorkout(workoutType: HKWorkoutActivityType) {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = workoutType
        configuration.locationType = .outdoor

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
        } catch {
            return
        }

        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)

        session?.delegate = self
        builder?.delegate = self

        let startDate = Date()
        session?.startActivity(with: startDate)
        builder?.beginCollection(withStart: startDate, completion: { (sucess, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("Work out \(sucess ? "Sucess" : "Failer")")
        })
    }

    @Published var showingSummaryView: Bool = false {
        didSet {
            if showingSummaryView == false {
                resetWorkout()
            }
        }
    }

    func requestAuthorization() {
        // Quantity type to write to the health store
        let typeToShare: Set = [ HKQuantityType.workoutType() ]
        // Read type configuration
        let typeToRead: Set = [
            HKQuantityType.init(.heartRate),
            HKQuantityType.init(.activeEnergyBurned),
            HKQuantityType.init(.distanceWalkingRunning),
            HKQuantityType.init(.distanceCycling),
            HKQuantityType.init(.distanceSwimming),
            HKObjectType.activitySummaryType() // this is used to acitivityring setting
        ]

        healthStore.requestAuthorization(toShare: typeToShare, read: typeToRead) { sucess, error in
            if let error = error {
                print(error.localizedDescription)
            }
            print("Authorization Status: \(sucess)")
        }
    }

    // MARK: -Workout state control
    @Published var running = false

    func pause() {
        session?.pause()
    }

    func resume() {
        session?.resume()
    }

    func togglePause() {
        if running == true {
            pause()
        } else {
            resume()
        }
    }

    func endWorkout() {
        session?.end()
        showingSummaryView = true
    }

    // MARK: -Workout metrics
    @Published var averageHeartRate: Double = 0
    @Published var heartRate: Double = 0
    @Published var activeEnergy: Double = 0
    @Published var distance: Double = 0
    @Published var workout: HKWorkout?

    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else {
            return
        }

        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                self.averageHeartRate = statistics.averageQuantity()?.doubleValue(for: heartRateUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                let energyUnit = HKUnit.kilocalorie()
                self.activeEnergy = statistics.sumQuantity()?.doubleValue(for: energyUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .distanceCycling):
                let meterUnit = HKUnit.meter()
                self.distance = statistics.sumQuantity()?.doubleValue(for: meterUnit) ?? 0
            default:
                return
            }
        }
    }

    func resetWorkout() {
        selectedWorkout = nil
        builder = nil
        session = nil
        workout = nil
        activeEnergy = 0
        averageHeartRate = 0
        heartRate = 0
        distance = 0
    }
}
/*  All the methods are required.
    HealthKit calls these methods on an anonymous serial background queue.
 */
extension WorkoutManager: HKWorkoutSessionDelegate {

    // Tells the delegate that the session’s state has changed.
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        DispatchQueue.main.async {
            self.running = toState == .running
        }

        if toState == .ended {
            builder?.endCollection(withEnd: date, completion: { sucess, error in
                self.builder?.finishWorkout(completion: { workout, error in
                    DispatchQueue.main.async {
                        self.workout = workout
                    }
                })
            })
        }
    }
    // Tells the delegate that the session has failed with an error.
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) { }
}

// MARK: -HKLiveWorkoutBuilderDelegate
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    // Tells the delegate that new data has been added to the builder.
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            // Make sure the type is HKQUantityType
            guard let quantityType = type as? HKQuantityType else { return }
            let statistics = workoutBuilder.statistics(for: quantityType)

            // update the publisher
            updateForStatistics(statistics)
        }
    }
    // Tells the delegate that a new event has been added to the builder.
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {    }
}
