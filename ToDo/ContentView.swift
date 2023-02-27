//
//  ContentView.swift
//  ToDo
//
//  Created by Serhii Striuk on 26.02.2023.
//

import SwiftUI
import ComposableArchitecture

struct AppState: Equatable {
    var todos: [Todo] = []
}

enum AppAction: Equatable {
    case addButtonTapped
    case todo(index: Int, action: TodoAction)
    case todoDelayCompleted
}

struct AppEnvironment {
    var uuid: () -> UUID
}

let appReducer = AnyReducer<AppState, AppAction, AppEnvironment>.combine(
    todoReducer.forEach(
        state: \AppState.todos,
        action: /AppAction.todo(index:action:),
        environment: { _ in TodoEnvironment() }
    ),
    AnyReducer { state, action, environment in
        switch action {
        case .addButtonTapped:
            state.todos.insert(Todo(id: environment.uuid()), at: 0)
            return .none
            
        case .todo(index: _, action: .checkboxTapped):
            struct CancelDelayId: Hashable {}
            
            return EffectTask(value: AppAction.todoDelayCompleted)
                .delay(for: 1, scheduler: DispatchQueue.main)
                .eraseToEffect()
                .cancellable(id: CancelDelayId(), cancelInFlight: true)
            
        case .todo(index: let index, action: let action):
            return .none
            
        case .todoDelayCompleted:
            
            state.todos = state.todos
                .enumerated()
                .sorted { lhs, rhs in
                    (!lhs.element.isComplete && rhs.element.isComplete)
                    || lhs.offset < rhs.offset
                }
                .map(\.element)
            
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
                environment: AppEnvironment(
                    uuid: UUID.init
                )
            )
        )
    }
}
