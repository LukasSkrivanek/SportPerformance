//
//  DependencyContainer.swift
//  SportPerformance
//
//  Created by macbook on 07.09.2025.
//

import Swinject
import SwiftUI
import SwiftData
import Firebase

final class DependencyContainer {

    static let shared = DependencyContainer()
    let container: Container
    
    private init() {
        container = Container()
        
        ensureFirebaseIsConfigured()
        
        // ModelContainer
        container.register(ModelContainer.self) { _ in
            try! ModelContainer(for:  SportPerformanceLocal.self)
        }.inObjectScope(.container)
        
        container.register(Coordinator.self) { _ in
            Coordinator()
        }.inObjectScope(.container)
        
        container.register(AppState.self) { _ in
            AppState()
        }
        
        // LocalStorage
        container.register(LocalStorage<SportPerformanceLocal>.self) { resolver in
            LocalStorage(container: resolver.resolve(ModelContainer.self)!)
        }.inObjectScope(.container)
        
        // RemoteStorage
        container.register(RemoteStorage<SportPerformanceFirestore>.self) { _ in
            RemoteStorage<SportPerformanceFirestore>()
        }.inObjectScope(.container)
        
        //  PerformanceViewModel
        container.register(PerformanceViewModel<
            LocalStorage<SportPerformanceLocal>,
            RemoteStorage<SportPerformanceFirestore>
        >.self) { resolver in
            let localStorage = resolver.resolve(LocalStorage<SportPerformanceLocal>.self)!
            let remoteStorage = resolver.resolve(RemoteStorage<SportPerformanceFirestore>.self)!
            let alertManager = resolver.resolve(AlertManager.self)!
            
            return MainActor.assumeIsolated {
                PerformanceViewModel(
                    localStorage: localStorage,
                    remoteStorage: remoteStorage,
                    alertManager: alertManager
                )
            }
        }.inObjectScope(.container)
        
        container.register(AlertManager.self) { _ in
            AlertManager()
        }.inObjectScope(.container)
    }
    
    private func ensureFirebaseIsConfigured() {
            if FirebaseApp.app() == nil {
                FirebaseApp.configure()
                print("✅ Firebase configured in DependencyContainer")
            }
        }

    static func resolve<T>(_ type: T.Type) -> T {
        guard let dependency = shared.container.resolve(type) else {
            fatalError("Dependency for \(type) not found. Check Swinject registrations.")
        }
        return dependency
    }
}
