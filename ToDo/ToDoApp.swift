//
//  ToDoApp.swift
//  ToDo
//
//  Created by Serhii Striuk on 26.02.2023.
//

import SwiftUI
import ComposableArchitecture

@main
struct ToDoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: Store(
                    initialState: AppState(
                        todos: [
                            Todo(
                                description: "Milk",
                                id: UUID(),
                                isComplete: false
                            ),
                            Todo(
                                description: "Eggs",
                                id: UUID(),
                                isComplete: false
                            ),
                            Todo(
                                description: "Hand Soap",
                                id: UUID(),
                                isComplete: true
                            ),
                        ]),
                    reducer: appReducer,
                    environment: AppEnvironment(mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                                                uuid: UUID.init)
                )
            )
        }
    }
}
