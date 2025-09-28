//
//  SmartTodoAppTests.swift
//  SmartTodoAppTests
//
//  Created by Utkarsh Upadhyay on 24/09/25.
//

import XCTest
import SwiftData
@testable import SmartTodoApp

final class SmartTodoAppTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext?
    var viewModel:TaskListViewModel!
    
    @MainActor
    override func setUp() {
        super.setUp()
        do {
            container = try ModelContainer(for: Task.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
            context = container.mainContext
            viewModel = TaskListViewModel(context: context!)
        } catch {
            XCTFail("Failed to create in-memory SwiftData container: \(error)")
        }
    }
    
    override func tearDown() {
        container = nil
        context = nil
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: Persistence Tests
    
    func testAddTaskPersists() throws {
        let task = Task(title: "Buy me a cofee", priority: .high)
        context?.insert(task)
        try context?.save()
        
        let tasks = try context?.fetch(FetchDescriptor<Task>())
        XCTAssertEqual(tasks?.count, 1)
        XCTAssertEqual(tasks?.first?.title, "Buy me a cofee")
    }
    
    func testDeleteTaskRemovesIt() throws {
        let task = Task(title: "Walk a dog")
        context?.insert(task)
        try context?.save()
        
        context?.delete(task)
        try context?.save()
        
        let tasks = try context?.fetch(FetchDescriptor<Task>())
        XCTAssertTrue(tasks?.isEmpty ?? true)
        XCTAssertEqual(tasks?.count, 0)
    }
    
    // MARK: - Business Logic Tests
        
        func testFilterPendingTasks() {
            let t1 = Task(title: "Pending Task 1")
            let t2 = Task(title: "Completed Task")
            t2.isCompleted = true
            
            let tasks = [t1, t2]
            viewModel.filter = .pending
            
            let result = viewModel.filteredTasks(allTasks: tasks)
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result.first?.title, "Pending Task 1")
        }
        
        func testFilterCompletedTasks() {
            let t1 = Task(title: "Pending Task")
            let t2 = Task(title: "Completed Task")
            t2.isCompleted = true
            
            let tasks = [t1, t2]
            viewModel.filter = .completed
            
            let result = viewModel.filteredTasks(allTasks: tasks)
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result.first?.title, "Completed Task")
        }
        
        func testSearchTasks() {
            let t1 = Task(title: "Buy milk")
            let t2 = Task(title: "Walk the dog")
            
            let tasks = [t1, t2]
            viewModel.searchText = "dog"
            
            let result = viewModel.filteredTasks(allTasks: tasks)
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result.first?.title, "Walk the dog")
        }
        
        func testSortByPriority() {
            let low = Task(title: "Low Priority", priority: .low)
            let high = Task(title: "High Priority", priority: .high)
            
            let tasks = [low, high]
            viewModel.sortByPriority = true
            
            let result = viewModel.filteredTasks(allTasks: tasks)
            XCTAssertEqual(result.first?.priority, .high)
        }
        
        func testTaskCounters() {
            let t1 = Task(title: "Pending Task")
            let t2 = Task(title: "Completed Task")
            t2.isCompleted = true
            
            let tasks = [t1, t2]
            
            XCTAssertEqual(viewModel.pendingCount(tasks), 1)
            XCTAssertEqual(viewModel.completedCount(tasks), 1)
        }
        
        func testOverdueIndicatorLogic() {
            let overdue = Task(title: "Late Task", dueDate: Date().addingTimeInterval(-3600))
            overdue.isCompleted = false
            let upcoming = Task(title: "Future Task", dueDate: Date().addingTimeInterval(3600))
            
            XCTAssertTrue(overdue.dueDate! < Date())
            XCTAssertFalse(upcoming.dueDate! < Date())
        }
}
