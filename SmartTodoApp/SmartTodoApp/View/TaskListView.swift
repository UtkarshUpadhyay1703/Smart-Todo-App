//
//  ContentView.swift
//  SmartTodoApp
//
//  Created by Utkarsh Upadhyay on 24/09/25.
//

import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var context
    @Query(sort: \Task.createdAt, order: .reverse) private var allTasks: [Task]
    
    @State private var showingForm: Bool = false
    @State private var editingTask: Task?
    
    @StateObject private var viewModel: TaskListViewModel = TaskListViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Pending: \(viewModel.pendingCount(allTasks)) / Completed: \(viewModel.completedCount(allTasks))")
                    .font(.caption)
                    .padding(.vertical, 4)
                
                Picker("Filter", selection: $viewModel.filter) {
                    ForEach(TaskFilter.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                if viewModel.filteredTasks(allTasks: allTasks).isEmpty {
                    EmptyStateView()
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.filteredTasks(allTasks: allTasks)) { task in
                            HStack {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .accessibilityLabel(task.isCompleted ? "Completed" : "Pending")
                                    .foregroundColor(task.isCompleted ? .gray : task.priority.color)
                                    .onTapGesture {
                                        viewModel.toggleCompletion(task)
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
                                
                                Spacer()
                                
                                Text(task.priority.label)
                                    .font(.caption2)
                                    .padding(6)
                                    .background(task.priority.color.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                            .contentShape(Rectangle())
                            .onTapGesture { editingTask = task }
                        }
                        .onDelete { indexSet in
                            indexSet.map { viewModel.filteredTasks(allTasks: allTasks)[$0] }
                                .forEach(viewModel.delete)
                        }
                    }
                }
            }
            .navigationTitle("Todo List")
            .searchable(text: $viewModel.searchText)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.sortByPriority.toggle()
                    } label: {
                        Label("Sort", systemImage: viewModel.sortByPriority ? "arrow.up.arrow.down.circle.fill" : "arrow.up.arrow.down.circle")
                    }
                    
                    Button { showingForm = true } label: {
                        Label("Add Task", systemImage: "plus")
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
            viewModel.context = context
        }
        .onChange(of: scenePhase) { _ , newPhase in
            if newPhase == .background {
                try? context.save()
            }
        }
    }
}


struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("No tasks found")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Tap + to add a new task")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}


#Preview {
    TaskListView()
        .modelContainer(for: Task.self, inMemory: true)
}
