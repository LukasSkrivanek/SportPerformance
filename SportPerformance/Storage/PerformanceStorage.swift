//
//  PerformanceStorage.swift
//  SportPerformance
//
//  Created by macbook on 30.09.2024.
//

import Foundation

protocol PerformanceStorage {
    associatedtype T: Identifiable

    func save(_ performance: T, alertManager: AlertManager)
    func fetch(alertManager: AlertManager) async throws -> [T]
    func delete(_ item: T, alertManager: AlertManager)
}
