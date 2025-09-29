//
//  Item.swift
//  SmartTodoApp
//
//  Created by Utkarsh Upadhyay on 24/09/25.
//

import Foundation
import SwiftData

@Model
class Task {
    var id: UUID
    var title: String
    var detail: String?
    var isCompleted: Bool
    var priority: Priority
    var dueDate: Date?
    var createdAt: Date
    var tags: [String]
    
    init(title: String, detail: String? = nil, priority: Priority = .medium, dueDate: Date? = nil, tags: [String] = []) {
        self.id = UUID()
        self.title = title
        self.detail = detail
        self.isCompleted = false
        self.priority = priority
        self.dueDate = dueDate
        self.createdAt = Date()
        self.tags = tags
    }
}

extension String {
    func truncated(to length: Int) -> String {
        if self.count > length {
            let endIndex = self.index(self.startIndex, offsetBy: length)
            return String(self[..<endIndex]) + "..."
        } else {
            return self
        }
    }
}

