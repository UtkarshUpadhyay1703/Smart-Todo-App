//
//  TaskFormView.swift
//  SmartTodoApp
//
//  Created by Utkarsh Upadhyay on 24/09/25.
//

import SwiftUI

struct TaskFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var task: Task
    @State private var showAlert: Bool = false
    
    var isNew: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.yellow.opacity(0.45), .green.opacity(0.25)],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                .ignoresSafeArea()
                
                Form {
                    Section("Details") {
                        TextField("Title", text: $task.title)
                        TextField("Description", text: Binding($task.detail, default: ""))
                    }
                    
                    Section("Priority") {
                        Picker("Priority", selection: $task.priority) {
                            ForEach(Priority.allCases, id: \.self) { priority in
                                Text(priority.label).tag(priority)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Section("Due Date") {
                        DatePicker("Due Date", selection: Binding($task.dueDate, default: Date()), displayedComponents: .date)
                            .datePickerStyle(.compact)
                    }
                    
                    Section("Tags") {
                        TagEditorView(tags: $task.tags)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard !task.title.isEmpty else {
                            showAlert = true
                            return
                        }
                        
                        if isNew { modelContext.insert(task) }
                        try? modelContext.save()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Title Required", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enter a task title before saving.")
            }
        }
    }
}

extension Binding {
    init(_ source: Binding<Value?>, default defaultValue: Value) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { newValue in
                source.wrappedValue = newValue
            }
        )
    }
}


#Preview {
    TaskFormView(task: Task(title: "God"))
}
