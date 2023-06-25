//
//  ListActions.swift
//  TestApp
//
//  Created by Lahfir on 25/06/23.
//
import SwiftUI

extension ContentView {
    func removeToDoItem(_ item: ToDoItem) {
            if let index = toDoItems.firstIndex(of: item) {
                toDoItems.remove(at: index)
            }
        }
}
