//
//  EditableFields.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 2/19/24.
//

import Foundation
import SwiftUI


struct EditableTextField : View {
    @State var label: String
    @Binding var text: String
    @Binding var isEdit: Bool
    
    var body: some View {
        if !isEdit {
            TextLabel(label, text: text)
        } else {
            SolTextField(label, text: $text)
        }
    }
}




struct EditablePicker : View {
    @State var label: String
    @State var selection: String
    @State var items: [String]
    @Binding var isEdit: Bool
    
    var body: some View {
        if !isEdit {
            TextLabel(label, text: selection)
        } else {
            Picker(label, selection: $selection) {
                ForEach(items, id: \.self) { item in
                    Text("\(item)").tag(item)
                }
            }
        }
    }
}
