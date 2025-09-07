//
//  LocalStorage.swift
//  SportPerformance
//
//  Created by macbook on 30.09.2024.
//

import SwiftData
import SwiftUI

@Observable
final class LocalStorage<T: PersistentModel>: PerformanceStorage {

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

    @MainActor
    func fetch(alertManager: AlertManager) async throws -> [T] {
        let fetchDescriptor = FetchDescriptor<T>()
        
        do {
            return try await MainActor.run {
                try self.modelContext.fetch(fetchDescriptor)
            }
        } catch {
            await MainActor.run {
                alertManager.show(
                    title: AppError.fetchError.localizedDescription,
                    message: ""
                )
            }
            throw error
        }
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
