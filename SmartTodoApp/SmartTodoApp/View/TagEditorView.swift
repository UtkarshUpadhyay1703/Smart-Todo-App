//
//  TagEditorView.swift
//  SmartTodoApp
//
//  Created by Utkarsh Upadhyay on 27/09/25.
//

import SwiftUI

struct TagEditorView: View {
    @Binding var tags: [String]
    @State private var newTag: String = ""
    var body: some View {
        if !tags.isEmpty {
        VStack(alignment: .leading) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(tags, id: \.self) { tag in
                            Text(tag)
                                .padding(6)
                                .background( Color.blue.opacity(0.2) )
                                .clipShape(Capsule())
                            
                            Button {
                                tags.removeAll { $0 == tag }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                }
            }
        }
        
        HStack {
            TextField("New Tag", text: $newTag)
            Button("Add") {
                guard !newTag.isEmpty else { return }
                if !tags.contains(newTag) {
                    tags.append(newTag)
                }
                newTag = ""
            }
        }
    }
}

//#Preview {
//    TagEditorView()
//}
