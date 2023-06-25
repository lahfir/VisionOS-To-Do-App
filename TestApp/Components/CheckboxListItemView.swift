//
//  CheckboxListItemView.swift
//  TestApp
//
//  Created by Lahfir on 25/06/23.
//

import SwiftUI
struct CheckboxListItemView: View {
    @State private var isChecked = false
    var toDoItem: ToDoItem
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Button(action: {
                    isChecked.toggle()
                }) {
                    Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.yellow)
            }
                Text(toDoItem.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(5)
                    .foregroundColor(isChecked ? .gray : .primary)
                    .strikethrough(isChecked, color: .gray)
            }.transition(.move(edge: .leading))
            
            HStack{
                if toDoItem.isNotifyFiveMinutesBefore || toDoItem.isNotifyAtStart || toDoItem.isNotifyAtEnd {
                Image(systemName: "bell")
                    .foregroundColor(.blue)
                }
                
                HStack{
                    Image(systemName: "clock")
                        .foregroundColor(.gray)
                    
                    Text(toDoItem.duration.shortenedStringValue)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                HStack{
                    Image(systemName: "time")
                        .foregroundColor(.gray)
                    
                    Text(formatTime(toDoItem.time))
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: date)
    }
}

extension DurationOption {
    var shortenedStringValue: String {
        switch self {
        case .fifteenMinutes:
            return "15M"
        case .thirtyMinutes:
            return "30M"
        case .oneHour:
            return "1H"
        case .oneAndHalfHours:
            return "1.5H"
        case .custom(let hours, let minutes):
            return "\(hours)H \(minutes)M"
        }
    }
}
