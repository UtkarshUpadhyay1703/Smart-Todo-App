//
//  Enums.swift
//  SmartTodoApp
//
//  Created by Utkarsh Upadhyay on 24/09/25.
//

import Foundation

enum Priority: Int, Codable, CaseIterable {
    case low, medium, high
    
    var color: String {
        switch self {
        case .low:
            return "green"
        case .medium:
            return "orange"
        case .high:
            return "red"
        }
    }
    
    var label: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }
}
