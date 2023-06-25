//
//  CustomDurationPicker.swift
//  TestApp
//
//  Created by Lahfir on 25/06/23.
//

import Foundation
import SwiftUI

struct CustomDurationPicker: View {
    @Binding var selectedDuration: DurationOption
    @Binding var isCustomDurationActive: Bool
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    let onClose: () -> Void // Closure for closing the pop-up

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    onClose()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }
            }

            Text("Enter custom duration:")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                TextField("Hours", value: $hours, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Text("hrs")
                    .padding(.horizontal, 4)

                TextField("Minutes", value: $minutes, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Text("min")
                    .padding(.horizontal, 4)
            }
            .padding(.bottom, 16)

            Button(action: {
                let totalMinutes = hours * 60 + minutes
                if totalMinutes > 0 {
                    selectedDuration = .custom(hours: hours, minutes: minutes)
                }
                isCustomDurationActive = false
            }) {
                Text("Set Duration")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)

                    .cornerRadius(8)
            }
        }
        .padding()
        .cornerRadius(16)
        .padding(16)
        .onAppear {
            hours = selectedDuration.customHours
            minutes = selectedDuration.customMinutes
        }
    }
}


enum DurationOption: Equatable {
    case fifteenMinutes
    case thirtyMinutes
    case oneHour
    case oneAndHalfHours
    case custom(hours: Int, minutes: Int)
    
    var customHours: Int {
        if case let .custom(hours, _) = self {
            return hours
        }
        return 0
    }
    
    var customMinutes: Int {
        if case let .custom(_, minutes) = self {
            return minutes
        }
        return 0
    }
}

extension DurationOption: Hashable {}
