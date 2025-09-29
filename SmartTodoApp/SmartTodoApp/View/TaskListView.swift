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
    let tagColors: [Color] = [.blue, .purple, .pink, .teal, .indigo, .orange]
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Spacer()
                    
                    Text("Pending: \(viewModel.pendingCount(allTasks)) / Completed: \(viewModel.completedCount(allTasks))")
                        .font(.caption)
                        .padding(.vertical, 4)
                    
                    Spacer()
                    
                    Button {
                        viewModel.sortByPriority.toggle()
                    } label: {
                        Label("", systemImage: viewModel.sortByPriority ? "arrow.up.arrow.down.circle.fill" : "arrow.up.arrow.down.circle")
                            .font(.title2.bold())
                    }
                }
                
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
                                    Text(task.title.truncated(to: 25))
                                        .strikethrough(task.isCompleted)
                                    
                                    HStack {
                                        if let due = task.dueDate {
                                            Text("Due: \(due.formatted(date: .abbreviated, time: .omitted))")
                                                .font(.caption)
                                                .foregroundStyle(due < Date() && !task.isCompleted ? .red : .secondary)
                                        }
                                        ForEach(Array(task.tags.enumerated()), id: \.element) { index, tag in
                                            Text(String(tag).truncated(to: 10))
                                                .font(.caption2)
                                                .padding(6)
                                                .background(tagColors[index % tagColors.count].opacity(0.2))
                                                .foregroundColor(tagColors[index % tagColors.count])
                                                .clipShape(Capsule())
                                        }
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
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    viewModel.toggleCompletion(task)
                                } label: {
                                    Label(task.isCompleted ? "Undo" : "Complete",
                                          systemImage: task.isCompleted ? "arrow.uturn.left" : "checkmark.circle.fill")
                                }
                                .tint(.green)
                            }
                            
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(task.isCompleted ? Color.gray.opacity(0.1) : task.priority.color.opacity(0.1))
                                    .shadow(color: task.priority.color.opacity(0.3), radius: 3, x: 0, y: 2)
                            )
                            .padding(.vertical, 4)
                        }
                        .onDelete { indexSet in
                            indexSet.map { viewModel.filteredTasks(allTasks: allTasks)[$0] }
                                .forEach(viewModel.delete)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                    .animation(.spring(), value: viewModel.filter)
                }
            }
            .overlay {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingForm = true }) {
                            Image(systemName: "plus")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        .clipShape(Circle())
                                )
                                .shadow(color: .purple.opacity(0.5), radius: 6, x: 0, y: 4)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Todo List")
            .background(
                LinearGradient(colors: [.blue.opacity(0.35), .purple.opacity(0.35)],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                .ignoresSafeArea()
            )
            .searchable(text: $viewModel.searchText)
            .sheet(isPresented: $showingForm) { TaskFormView(task: Task(title: ""), isNew: true) }
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
            Image(systemName: "tray.fill")
                .font(.system(size: 56))
                .foregroundColor(.gray.opacity(0.5))
            Text("No tasks yet!")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Tap + to create your first task")
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
