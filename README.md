# Smart-Todo-App

A modern iOS Todo app built with SwiftUI and SwiftData, following MVVM architecture.

## Features

Task Management: Add, edit, delete, and mark tasks complete/incomplete.
Persistence: Tasks stored locally with SwiftData, survive app restarts.
Filtering & Search: Filter by status (All/Pending/Completed), search by title/description.

Smart Features:

Priority levels (High/Medium/Low with color coding)
Due dates with overdue indicators
Categories/Tags for organization
Task counter (pending vs completed)

UI/UX:

Clean SwiftUI interface
Floating Action Button for adding tasks
Swipe gestures for quick actions
Empty/Loading states


#Architecture

MVVM pattern (Views ↔ ViewModels ↔ SwiftData models).
State management using SwiftUI’s @State, @Observable, @Environment.
Async/await for data operations.
Input validation & error handling.

## Tech

SwiftUI + SwiftData
MVVM pattern
XCTest (unit tests for filtering, search, counters, overdue logic)

## Testing

Unit tests are implemented with XCTest. An in-memory SwiftData container is used to test persistence safely. Business logic (filters, search, sorting, counters, overdue detection) is tested through the ViewModel.

## Requirements

iOS 17+
Xcode 15+
Swift 5.9+


## How to Run

Clone the repo:
git clone https://github.com/UtkarshUpadhyay1703/Smart-Todo-App.git
Open in Xcode.
Run on Simulator or physical iPhone.
