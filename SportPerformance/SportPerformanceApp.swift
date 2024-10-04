//
//  SportPerformanceApp.swift
//  SportPerformance
//
//  Created by macbook on 30.09.2024.
//
import SwiftUI
import SwiftData
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct SportPerformanceApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var alertManager = AlertManager()
    // Declare modelContainer as a property
    var modelContainer: ModelContainer {
        do {
            return try ModelContainer(for: SportPerformanceLocal.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error.localizedDescription)")
        }
    }
    var body: some Scene {
        let localStorage = LocalStorage<SportPerformanceLocal>(container: modelContainer)
        let remoteStorage = RemoteStorage<SportPerformanceFirestore>()

        WindowGroup {
            MainTabView(localStorage: localStorage, remoteStorage: remoteStorage)
                .environmentObject(alertManager)
               
        }
        .modelContainer(modelContainer)
    }
}
