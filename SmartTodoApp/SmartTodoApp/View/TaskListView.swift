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
    @State private var filter: TaskFilter = .all
    @State private var searchText = ""
    @State private var sortByPriority = false
    
    var filteredTasks: [Task] {
        var result = tasks
        
        //Filter
        switch filter {
        case .pending: result = result.filter{ !$0.isCompleted }
        case .completed: result = result.filter{ $0.isCompleted }
        default: break
        }
        
        //Search
        if !searchText.isEmpty {
            result = result.filter{ $0.title.localizedCaseInsensitiveContains(searchText) || $0.detail?.localizedCaseInsensitiveContains(searchText) ?? false }
        }
        
        //Sort
        if sortByPriority {
            result = result.sorted{ $0.priority.rawValue > $1.priority.rawValue }
        } else {
            result = result.sorted { $0.createdAt > $1.createdAt }
        }
        
        return result
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                //Counter
                Text("Pending: \(tasks.filter{ !$0.isCompleted }.count) / Completed: \(tasks.filter{ $0.isCompleted }.count)")
                    .font(.caption)
                    .padding(.vertical, 4)
                
                //Filter Picker
                HStack {
                    Picker("Filter", selection: $filter) {
                        ForEach(TaskFilter.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.leading)
                    
                    //Sorting in ascending and descending order.
                    Button {
                        sortByPriority.toggle()
                    } label: {
                        Label("", systemImage: sortByPriority ? "arrow.up" : "arrow.down")
                    }
                }
            }
            
            List {
                //List all the filtered and sorted tasks.
                ForEach(filteredTasks) { task in
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
            .searchable(text: $searchText)
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
                modelContext.delete(filteredTasks[index])
                try? modelContext.save()
            }
        }
    }
}

#Preview {
    TaskListView()
        .modelContainer(for: Task.self, inMemory: true)
}
