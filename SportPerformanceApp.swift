//
//  SportPerformanceApp.swift
//  SportPerformance
//
//  Created by macbook on 30.09.2024.
//
import SwiftUI
import SwiftData
import FirebaseCore

@main
struct SportPerformanceApp: App {

    var modelContainer: ModelContainer {
        do {
            return try ModelContainer(for: SportPerformanceLocal.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error.localizedDescription)")
        }
    }
    
    private let viewModel = DependencyContainer.resolve(
           PerformanceViewModel<
               LocalStorage<SportPerformanceLocal>,
               RemoteStorage<SportPerformanceFirestore>
           >.self
       )

    var body: some Scene {
        
        WindowGroup {
            CoordinatorView()
                .environment(DependencyContainer.resolve(Coordinator.self))
                .environment(DependencyContainer.resolve(AppState.self))
                .environment(DependencyContainer.resolve(AlertManager.self))
                .environment(viewModel)
        }
    }
}


@Observable
final class AppState {
    var selectedTab: Tab = .list
}

enum Tab {
    case list
    case add
}
