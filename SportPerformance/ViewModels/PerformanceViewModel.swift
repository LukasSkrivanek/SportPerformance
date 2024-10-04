//
//  PerformanceViewModel.swift
//  SportPerformance
//
//  Created by macbook on 30.09.2024.
//
import SwiftUI
import Combine

class PerformanceViewModel<LocalStorage: PerformanceStorage,
                           RemoteStorage: PerformanceStorage>: ObservableObject
where LocalStorage.T == SportPerformanceLocal,
      RemoteStorage.T == SportPerformanceFirestore {
    @Published var performances: [any Performance] = []
    @Published  var filter: String = "All"
    // AddPerformance variables
    @Published var title: String = ""
    @Published var location: String = ""
    @Published var duration: TimeInterval = 0
    @Published var isLocal: Bool = true
    
    private var localStorage: LocalStorage
    private var remoteStorage: RemoteStorage
    private var alertManager: AlertManager
    private var cancellables = Set<AnyCancellable>()
    
    init(localStorage: LocalStorage,
         remoteStorage: RemoteStorage,
         alertManager: AlertManager) {
        self.localStorage = localStorage
        self.remoteStorage = remoteStorage
        self.alertManager = alertManager
        loadPerformances()
    }
}

// MARK: - Add Operations
extension PerformanceViewModel {
    
    func addPerformance(title: String,
                        location: String,
                        duration: TimeInterval,
                        isLocal: Bool) {
        if isLocal {
            let newLocalPerformance = SportPerformanceLocal(id: UUID().uuidString,
                                                            title: title,
                                                            location: location,
                                                            duration: duration,
                                                            isLocal: isLocal)
            localStorage.save(newLocalPerformance, alertManager: alertManager)
        } else {
            let newRemotePerformance = SportPerformanceFirestore(id: UUID().uuidString,
                                                                 title: title,
                                                                 location: location,
                                                                 duration: duration,
                                                                 isLocal: false)
            remoteStorage.save(newRemotePerformance, alertManager: alertManager)
        }
        loadPerformances() 
    }
}

// MARK: - Load Operations
extension PerformanceViewModel {
    
    func loadPerformances(source: PerformanceSource = .both) {
        switch source {
        case .local:
            fetchPerformances(from: localStorage
                .fetch(alertManager: alertManager),
                              update: { self.performances = $0 })
        case .remote:
            fetchPerformances(from: remoteStorage
                .fetch(alertManager: alertManager),
                              update: { self.performances = $0 })
        case .both:
            let localFetch = localStorage.fetch(alertManager: alertManager)
            let remoteFetch = remoteStorage.fetch(alertManager: alertManager)
            
            localFetch
                .combineLatest(remoteFetch)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: handleCompletion, receiveValue: { localPerformances,
                    remotePerformances in
                    self.performances = localPerformances + remotePerformances
                })
                .store(in: &cancellables)
        }
        
    }
}

// MARK: - Delete Operations
extension PerformanceViewModel {
    
    func deletePerformance(_ performance: any Performance) {
        if let localPerformance = performance as? SportPerformanceLocal {
            localStorage.delete(localPerformance, alertManager: alertManager)
        } else if let remotePerformance = performance as? SportPerformanceFirestore {
            remoteStorage.delete(remotePerformance, alertManager: alertManager)
        }
        loadPerformances()
    }
}

// MARK: - Helpers:
extension PerformanceViewModel {
    var isValid: Bool {
           return !title.isEmpty && !location.isEmpty && duration > 0
       }
    var filteredPerformances: [any Performance] {
        switch filter {
        case "Local":
            return performances.filter { $0.isLocal }
        case "Remote":
            return performances.filter { !$0.isLocal }
        case "All":
            return performances
        default:
            return performances
        }
    }
    
    func fetchPerformances<PerformanceType>(from publisher: AnyPublisher<[PerformanceType], Error>,
                                            update: @escaping ([PerformanceType]) -> Void) {
        publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleCompletion, receiveValue: update)
            .store(in: &cancellables)
    }
    
    func handleCompletion(_ completion: Subscribers.Completion<Error>) {
        if case .failure(let error) = completion {
            self.alertManager.show(title: "Error", message: error.localizedDescription)
        }
    }
}

    enum PerformanceSource {
        case local
        case remote
        case both
    }
