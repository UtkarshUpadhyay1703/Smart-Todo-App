//
//  TaskListViewModel.swift
//  SmartTodoApp
//
//  Created by Utkarsh Upadhyay on 27/09/25.
//

import SwiftUI
import SwiftData

//@Observable
class TaskListViewModel: ObservableObject {
    var context: ModelContext!
    
    @Published var filter: TaskFilter = .all
    @Published var searchText = ""
    @Published var sortByPriority = false
    
    init () { }
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func toggleCompletion(_ task: Task) {
        task.isCompleted.toggle()
        try? context.save()
    }
    
    func delete(_ task: Task) {
        context.delete(task)
        try? context.save()
    }
    
    //Testable
    func filteredTasks(allTasks: [Task]) -> [Task] {
        var result = allTasks
        
        switch filter {
        case .pending:
            result = result.filter { !$0.isCompleted }
        case .completed:
            result = result.filter { $0.isCompleted }
        case .all:
            break
        }
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                ($0.detail?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        if sortByPriority {
            result = result.sorted { $0.priority.rawValue > $1.priority.rawValue }
        } else {
            result = result.sorted { $0.createdAt > $1.createdAt }
        }
        
        return result
    }
    
    func pendingCount(_ tasks: [Task]) -> Int {
        tasks.filter { !$0.isCompleted }.count
    }
    
    func completedCount(_ tasks: [Task]) -> Int {
        tasks.filter { $0.isCompleted }.count
    }
}
