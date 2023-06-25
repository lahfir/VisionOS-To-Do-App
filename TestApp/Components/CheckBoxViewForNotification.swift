//
//  CheckBoxViewForNotification.swift
//  TestApp
//
//  Created by Lahfir on 25/06/23.
//

import Foundation
import SwiftUI

struct CheckboxView: View {
    @Binding var isChecked: Bool
    let label: String
    
    var body: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            HStack(spacing: 8) {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(isChecked ? .yellow : .gray)
                
                Text(label)
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
