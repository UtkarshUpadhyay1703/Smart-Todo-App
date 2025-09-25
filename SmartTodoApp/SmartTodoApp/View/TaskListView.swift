//
//  ContentView.swift
//  SmartTodoApp
//
//  Created by Utkarsh Upadhyay on 24/09/25.
//

import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Task.createdAt, order: .reverse) private var tasks: [Task]
    
    @State private var showingForm: Bool = false
    @State private var editingTask: Task?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(tasks) { task in
                    HStack {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .onTapGesture {
                                task.isCompleted.toggle()
                                try? modelContext.save()
                            }
                        VStack(alignment: .leading) {
                            Text(task.title)
                                .strikethrough(task.isCompleted)
                            if let due = task.dueDate {
                                Text("Due: \(due.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption)
                                    .foregroundStyle(due < Date() && !task.isCompleted ? .red : .secondary)
                            }
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingTask = task
                    }
                }
                .onDelete(perform: deleteTasks)
            }
            .navigationTitle("Todo List")
            .toolbar {
                ToolbarItem {
                    Button(action: { showingForm = true }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingForm) {
                TaskFormView(task: Task(title: ""), isNew: true)
            }
            .sheet(item: $editingTask) { task in
                TaskFormView(task: task)
            }
        }
        .onAppear {
            let allTasks = try! modelContext.fetch(FetchDescriptor<Task>())
            print("Total tasks: \(allTasks.count)")
        }
    }
    
    private func deleteTasks(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(tasks[index])
                try? modelContext.save()
            }
        }
    }
}

#Preview {
    TaskListView()
        .modelContainer(for: Task.self, inMemory: true)
}
