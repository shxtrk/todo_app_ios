//
//  ContentView.swift
//  ToDo
//
//  Created by Serhii Striuk on 26.02.2023.
//

import SwiftUI
import ComposableArchitecture

struct Todo: Equatable, Identifiable {
    var description = ""
    let id: UUID
    var isComplete = false
}

enum TodoAction: Equatable {
    case checkboxTapped
    case textFieldChanged(String)
}

struct TodoEnvironment { }

let todoReducer = AnyReducer<Todo, TodoAction, TodoEnvironment> { state, action, environment in
    switch action {
    case .checkboxTapped:
        state.isComplete.toggle()
        return .none
    case .textFieldChanged(let text):
        state.description = text
        return .none
    }
}

struct AppState: Equatable {
    var todos: [Todo] = []
}

enum AppAction: Equatable {
    case addButtonTapped
    case todo(index: Int, action: TodoAction)
}

struct AppEnvironment { }

let appReducer = AnyReducer<AppState, AppAction, AppEnvironment>.combine(
    todoReducer.forEach(
        state: \AppState.todos,
        action: /AppAction.todo(index:action:),
        environment: { _ in TodoEnvironment() }
    ),
    AnyReducer { state, action, environment in
        switch action {
        case .addButtonTapped:
            state.todos.insert(Todo(id: UUID()), at: 0)
            return .none
        case .todo(index: let index, action: let action):
            return .none
        }
    }
)
    .debug()

struct ContentView: View {
    let store: Store<AppState, AppAction>
    
    var body: some View {
        NavigationView {
            WithViewStore(self.store) { viewStore in
                List {
                    ForEachStore(
                        self.store.scope(state: \.todos, action: AppAction.todo(index:action:)),
                        content: TodoView.init(store:)
                    )
                }
                .navigationBarTitle("Todos")
                .navigationBarItems(trailing: Button("Add") {
                    viewStore.send(.addButtonTapped)
                })
            }
        }
    }
}

struct TodoView: View {
    let store: Store<Todo, TodoAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack {
                Button(action: { viewStore.send(.checkboxTapped) }) {
                    Image(systemName: viewStore.isComplete ? "checkmark.square" : "square")
                }
                .buttonStyle(PlainButtonStyle())
                
                TextField(
                    "Untitled todo",
                    text: viewStore.binding(
                        get: \.description,
                        send: TodoAction.textFieldChanged
                    )
                )
            }
            .foregroundColor(viewStore.isComplete ? .gray : nil)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
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
                    ]
                ),
                reducer: appReducer,
                environment: AppEnvironment()
            )
        )
    }
}
