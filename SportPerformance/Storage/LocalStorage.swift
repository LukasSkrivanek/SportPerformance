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
    // Save an item to local storage
    func save(_ item: T, alertManager: AlertManager) {
        modelContext.insert(item)  // Insert item into context
        do {
            try modelContext.save() // Save changes to the context
        } catch {
            alertManager.show(title: AppError.saveError.localizedDescription, message: "")
        }
    }
}

// MARK: - Fetch Operations
extension LocalStorage {
    // Fetch items from local storage
    func fetch(alertManager: AlertManager) -> AnyPublisher<[T], Error> {
        let fetchDescriptor = FetchDescriptor<T>() // You may add filters, sorting, etc. as needed
        
        return Future { promise in
            do {
                // Fetch the items using the model context
                let items = try self.modelContext.fetch(fetchDescriptor) // Fetching items
                promise(.success(items)) // Return the successfully fetched items
            } catch {
                alertManager.show(title: AppError.fetchError.localizedDescription, message: "")
                promise(.failure(error)) // Propagate the error to the subscriber
            }
        }
        .eraseToAnyPublisher() // Convert Future to AnyPublisher for Combine use
    }
}

// MARK: - Delete Operations
extension LocalStorage {
    // Delete an item from local storage
    func delete(_ item: T, alertManager: AlertManager) {
        modelContext.delete(item)  // Remove item from context
        do {
            try modelContext.save()  // Save changes
        } catch {
            alertManager.show(title: AppError.deleteError.localizedDescription, message: "")
        }
    }
}
