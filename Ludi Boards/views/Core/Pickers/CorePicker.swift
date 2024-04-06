//
//  SolPicker.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/29/24.
//

import Foundation
import SwiftUI
import CoreEngine

struct CorePicker: View {
    @Binding var selection: String
    @Binding var isEdit: Bool
    @State var data: [String]
    @State var title: String
    
    
    init(selection: Binding<String>, data: [String], title: String, isEdit: Binding<Bool>) {
        self._selection = selection
        self._isEdit = isEdit
        self.data = data
        self.title = title
    }
    
    var body: some View {
        
        if !isEdit {
            TextLabel(title, text: selection)
        } else {
            Picker(title, selection: $selection) {
                ForEach(data, id: \.self) { item in
                    Text(item)
                        .tag(item)
                }
            }
            .foregroundColor(.blue)
            .onAppear() {
                if selection.isEmpty {
                    if let first = data.first {
                        selection = first
                    }
                }
            }
        }
    }
}


struct CorePickerView_Previews: PreviewProvider {
    static var previews: some View {
        CorePicker(selection: .constant(""), data: [""], title: "Title", isEdit: .constant(true))
    }
}
