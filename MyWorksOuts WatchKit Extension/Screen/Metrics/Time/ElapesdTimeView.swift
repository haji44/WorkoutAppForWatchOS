//
//  ElapesdTimeView.swift
//  MyWorksOuts WatchKit Extension
//
//  Created by kitano hajime on 2022/03/27.
//

import SwiftUI

struct ElapesdTimeView: View {
    var elapedTime: TimeInterval = 0
    var showSubseconds: Bool = true
    @State private var timeFormatter = ElapesedTImeFormatter()

    var body: some View {
        Text(NSNumber(value: elapedTime), formatter: timeFormatter)
            .fontWeight(.semibold)
            .onChange(of: showSubseconds) {
                timeFormatter.showSubseconds = $0
            }        
    }
}

struct ElapesdTimeView_Previews: PreviewProvider {
    static var previews: some View {
        ElapesdTimeView()
    }
}

class ElapesedTImeFormatter: Formatter {
    let componentFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    var showSubseconds = true

    override func string(for obj: Any?) -> String? {
        //
        guard let time = obj as? TimeInterval else { return nil }

        guard let formattedString = componentFormatter.string(from: time) else {
            return nil
        }

        if showSubseconds {
            let hunredths = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
            let decimalSperator = Locale.current.decimalSeparator ?? "."
            return String(format: "%@%@%0.2d", formattedString, decimalSperator, hunredths)
        }
        return formattedString
    }

}
