//
//  ToDoTests.swift
//  ToDoTests
//
//  Created by Serhii Striuk on 27.02.2023.
//

import XCTest
import ComposableArchitecture
@testable import ToDo

class TodosTests: XCTestCase {
    
    func testCompletingTodo() {
        let store = TestStore(
            initialState: AppState(
                todos: [
                    Todo(
                        description: "Milk",
                        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                        isComplete: false
                    )
                ]
            ),
            reducer: appReducer,
            environment: AppEnvironment(
                uuid: { fatalError("unimplemented") }
            )
        )
        
        store.send(.todo(index: 0, action: .checkboxTapped)) {
            $0.todos[0].isComplete = true
        }
    }
    
    func testAddTodo() {
        let store = TestStore(
            initialState: AppState(),
            reducer: appReducer,
            environment: AppEnvironment(
                uuid: { UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")! }
            )
        )
        
        store.send(.addButtonTapped) {
            $0.todos = [
                Todo(
                    description: "",
                    id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!,
                    isComplete: false
                )
            ]
        }
    }
    
    func testTodoSorting() {
        let store = TestStore(
            initialState: AppState(
                todos: [
                    Todo(
                        description: "Milk",
                        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                        isComplete: false
                    ),
                    Todo(
                        description: "Eggs",
                        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                        isComplete: false
                    )
                ]
            ),
            reducer: appReducer,
            environment: AppEnvironment(
                uuid: { fatalError("unimplemented") }
            )
        )
        
        store.send(.todo(index: 0, action: .checkboxTapped)) {
            $0.todos[0].isComplete = true
            $0.todos = [
                $0.todos[1],
                $0.todos[0],
            ]
        }
    }
}
