//
//  ContentView.swift
//  Cloud Storage
//
//  Created by Veturi, Shreyas (HJRM) on 14/06/2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var newTodo: String = ""
    @State private var todos: [Todo] = []
    
    private let firebaseManager = FirebaseManager.shared
    
    var body: some View {
        NavigationStack {
            List {
                if todos.isEmpty {
                    Text("Add your first todo below")
                }
                else {
                    ForEach(todos, id:\.id) { todo in
                        VStack(alignment: .leading) {
                            Text(todo.content)
                            Text(todo.createdAt, style: .date)
                                .foregroundStyle(.gray)
                                .font(.caption)
                        }
                    }
                    .onDelete(perform: { indexSet in
                        indexSet.forEach { index in
                            firebaseManager.deleteTodo(id: todos[index].id) { error in
                                if let error = error {
                                    print("Error: \(error.localizedDescription)")
                                }
                            }
                        }
                        todos.remove(atOffsets: indexSet)
                    })
                }
            }
            .listStyle(.plain)
            
            Divider()
            
            TextField("Enter a ToDo...", text: $newTodo)
                .onSubmit {
                    if newTodo.count > 0 {
                        firebaseManager.saveTodo(todo: newTodo)
                        newTodo = ""
                        
                        firebaseManager.getTodos { todos, error in
                            if let error = error {
                                print("Error: \(error.localizedDescription)")
                            }
                            else {
                                guard let todos = todos else {
                                    print("Something's gone wrong")
                                    return
                                }
                                
                                self.todos = todos.sorted {
                                    $0.createdAt < $1.createdAt
                                }
                            }
                        }
                    }
                }
                .padding()
                .navigationTitle("Firefly")
                
                
        }
        .onAppear {
            firebaseManager.getTodos { todos, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                else {
                    guard let todos = todos else {
                        print("Something's gone wrong")
                        return
                    }
                    
                    self.todos = todos.sorted {
                        $0.createdAt < $1.createdAt
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
