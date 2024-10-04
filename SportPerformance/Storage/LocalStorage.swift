//
//  LocalStorage.swift
//  SportPerformance
//
//  Created by macbook on 30.09.2024.
//
import Combine
import SwiftData
import SwiftUI

class LocalStorage<T: PersistentModel>: PerformanceStorage, ObservableObject {
    var modelContext: ModelContext
    
    init(container: ModelContainer) {
        modelContext = ModelContext(container)
    }
}

// MARK: - Save Operations
extension LocalStorage {
    func save(_ item: T, alertManager: AlertManager) {
        modelContext.insert(item)
        do {
            try modelContext.save()
        } catch {
            alertManager.show(title: AppError.saveError.localizedDescription, message: "")
        }
    }
}

// MARK: - Fetch Operations
extension LocalStorage {
    // Fetch items from local storage
    func fetch(alertManager: AlertManager) -> AnyPublisher<[T], Error> {
        let fetchDescriptor = FetchDescriptor<T>()
        
        return Future { promise in
            do {
                let items = try self.modelContext.fetch(fetchDescriptor)
                promise(.success(items))
            } catch {
                alertManager.show(title: AppError.fetchError.localizedDescription, message: "")
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Delete Operations
extension LocalStorage {
    func delete(_ item: T, alertManager: AlertManager) {
        modelContext.delete(item)
        do {
            try modelContext.save()
        } catch {
            alertManager.show(title: AppError.deleteError.localizedDescription, message: "")
        }
    }
}
