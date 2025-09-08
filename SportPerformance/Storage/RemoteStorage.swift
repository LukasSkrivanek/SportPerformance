//
//  RemoteStorage.swift
//  SportPerformance
//
//  Created by macbook on 30.09.2024.
//
import SwiftUI
import FirebaseFirestore

final class RemoteStorage<T: Identifiable & Codable>: PerformanceStorage, ObservableObject {
    private let db = Firestore.firestore()
}

// MARK: - Save Operations
extension RemoteStorage {
    func save(_ item: T, alertManager: AlertManager) {
        do {
            _ = try db.collection("performances")
                .document(item.id as? String ?? UUID().uuidString)
                .setData(from: item)
        } catch {
            alertManager.show(title: AppError.saveError.localizedDescription, message: "")
        }
    }
}

// MARK: - Fetch Operations
extension RemoteStorage {
    func fetch(alertManager: AlertManager) async throws -> [T] {
        do {
            let querySnapshot = try await self.db.collection("performances").getDocuments()
            
            var items: [T] = []
            for document in querySnapshot.documents {
                do {
                    let item = try document.data(as: T.self)
                    items.append(item)
                } catch {
                    print("Error decoding document \(document.documentID): \(error)")
                }
            }
            return items
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
extension RemoteStorage {
    func delete(_ item: T, alertManager: AlertManager) {
        db.collection("performances").document(item.id as? String ?? UUID().uuidString).delete { error in
            if let _ = error {
                alertManager.show(title: AppError.deleteError.localizedDescription, message: "")
            }
        }
    }
}
