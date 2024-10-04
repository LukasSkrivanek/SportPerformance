//
//  PerformanceStorage.swift
//  SportPerformance
//
//  Created by macbook on 30.09.2024.
//
import Foundation
import Combine

protocol PerformanceStorage {
    associatedtype T: Identifiable

    func save(_ performance: T, alertManager: AlertManager)
    func fetch(alertManager: AlertManager) -> AnyPublisher<[T], Error>
    func delete(_ item: T, alertManager: AlertManager)
}
