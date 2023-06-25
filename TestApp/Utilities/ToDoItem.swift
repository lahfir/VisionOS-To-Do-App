//
//  ToDoItem.swift
//  TestApp
//
//  Created by Lahfir on 25/06/23.
//

import Foundation
import SwiftUI

struct ToDoItem: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let date: Date
    let time: Date
    let duration: DurationOption
    let isNotifyFiveMinutesBefore: Bool
    let isNotifyAtStart: Bool
    let isNotifyAtEnd: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ToDoItem, rhs: ToDoItem) -> Bool {
        return lhs.id == rhs.id
    }
}
