//
//  PerformanceViewModel.swift
//  SportPerformance
//
//  Created by macbook on 30.09.2024.
//
import SwiftUI
import Observation

enum PerformanceFilter: String, CaseIterable {
    case all = "All"
    case local = "Local"
    case remote = "Remote"
}

@MainActor @Observable
final class PerformanceViewModel<
    LocalStorage: PerformanceStorage,
    RemoteStorage: PerformanceStorage
>
where LocalStorage.T == SportPerformanceLocal,
      RemoteStorage.T == SportPerformanceFirestore {
    
    var performances: [any Performance] = []
    var filter: PerformanceFilter = .all
    var title = ""
    var location = ""
    var duration: TimeInterval = 0
    var isLocal = true
    
    private var localStorage: LocalStorage
    private var remoteStorage: RemoteStorage
    private var alertManager: AlertManager
    
    init(localStorage: LocalStorage,
         remoteStorage: RemoteStorage,
         alertManager: AlertManager) {
        self.localStorage = localStorage
        self.remoteStorage = remoteStorage
        self.alertManager = alertManager
        Task {
            await loadPerformances()
        }
    }
}

// MARK: - Add Operations
extension PerformanceViewModel {
    
    func addPerformance(title: String,
                        location: String,
                        duration: TimeInterval,
                        isLocal: Bool) async {
        do {
            if isLocal {
                let newLocalPerformance = SportPerformanceLocal(
                    id: UUID().uuidString,
                    title: title,
                    location: location,
                    duration: duration,
                    isLocal: isLocal
                )
                localStorage.save(newLocalPerformance, alertManager: alertManager)
            } else {
                let newRemotePerformance = SportPerformanceFirestore(
                    id: UUID().uuidString,
                    title: title,
                    location: location,
                    duration: duration,
                    isLocal: false
                )
                remoteStorage.save(newRemotePerformance, alertManager: alertManager)
            }
            await loadPerformances()
        }
    }
}

// MARK: - Load Operations
extension PerformanceViewModel {
    
    func loadPerformances(source: PerformanceSource = .both) async {
        do {
            switch source {
            case .local:
                performances = try await localStorage.fetch(alertManager: alertManager)
            case .remote:
                performances = try await remoteStorage.fetch(alertManager: alertManager)
            case .both:
                async let localPerformances = localStorage.fetch(alertManager: alertManager)
                async let remotePerformances = remoteStorage.fetch(alertManager: alertManager)
                
                let (local, remote) = try await (localPerformances, remotePerformances)
                performances = local + remote
            }
        } catch {
            print("Failed to fetch performances: \(error)")
        }
    }
}

// MARK: - Delete Operations
extension PerformanceViewModel {
    
    func deletePerformance(_ performance: any Performance) async {
        do {
            if let localPerformance = performance as? SportPerformanceLocal {
                localStorage.delete(localPerformance, alertManager: alertManager)
            } else if let remotePerformance = performance as? SportPerformanceFirestore {
               remoteStorage.delete(remotePerformance, alertManager: alertManager)
            }
            await loadPerformances()
        }
    }
}

// MARK: - Helpers:
extension PerformanceViewModel {
    var isValid: Bool {
        return !title.isEmpty && !location.isEmpty && duration > 0
    }
    
    var filteredPerformances: [any Performance] {
        switch filter {
        case .local: performances.filter { $0.isLocal }
        case .remote: performances.filter { !$0.isLocal }
        case .all: performances
        }
    }
}

enum PerformanceSource {
    case local
    case remote
    case both
}
