//
//  RemoteStorage.swift
//  SportPerformance
//
//  Created by macbook on 30.09.2024.
//
import SwiftUI
import FirebaseFirestore
import Combine

class RemoteStorage<T: Identifiable & Codable>: PerformanceStorage, ObservableObject {
    private let db = Firestore.firestore()
}

// MARK: - Save Operations
extension RemoteStorage {
    
    // Save an item to Firestore
    func save(_ item: T, alertManager: AlertManager) {
        do {
            // Attempt to save the item to Firestore
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
    // Fetch items from Firestore
    func fetch(alertManager: AlertManager) -> AnyPublisher<[T], Error> {
        Future { promise in
            self.db.collection("performances")
                .getDocuments { (querySnapshot, error) in
                if let error = error {
                    alertManager.show(title: AppError.fetchError.localizedDescription, message: "")
                    promise(.failure(error)) // Propagate the error to the subscriber
                    return
                }
                
                var items = [T]()
                querySnapshot?.documents.forEach { document in
                    if let item = try? document.data(as: T.self) {
                        items.append(item)
                    }
                }
                promise(.success(items)) // Return the successfully fetched items
            }
        }
        .eraseToAnyPublisher() // Convert Future to AnyPublisher
    }
}

// MARK: - Delete Operations
extension RemoteStorage {
    
    // Delete an item from Firestore
    func delete(_ item: T, alertManager: AlertManager) {
        db.collection("performances").document(item.id as? String ?? UUID().uuidString).delete { error in
            if let _ = error {
                alertManager.show(title: AppError.deleteError.localizedDescription, message: "")
            }
        }
    }
}
