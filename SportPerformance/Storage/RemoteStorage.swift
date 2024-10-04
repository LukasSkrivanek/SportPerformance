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
    func fetch(alertManager: AlertManager) -> AnyPublisher<[T], Error> {
        Future { promise in
            self.db.collection("performances")
                .getDocuments { (querySnapshot, error) in
                if let error = error {
                    alertManager.show(title: AppError.fetchError.localizedDescription, message: "")
                    promise(.failure(error))
                    return
                }
                
                var items = [T]()
                querySnapshot?.documents.forEach { document in
                    if let item = try? document.data(as: T.self) {
                        items.append(item)
                    }
                }
                promise(.success(items))
            }
        }
        .eraseToAnyPublisher()
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
