//
//  PerformanceStorage.swift
//  SportPerformance
//
//  Created by macbook on 30.09.2024.
//
import Foundation
import Combine

protocol PerformanceStorage {
    associatedtype T: Identifiable // Define an associated type T that conforms to Identifiable

    func save(_ performance: T, alertManager: AlertManager)
    func fetch(alertManager: AlertManager) -> AnyPublisher<[T], Error> // Returning a publisher for async data fetching
    func delete(_ item: T, alertManager: AlertManager)
}
