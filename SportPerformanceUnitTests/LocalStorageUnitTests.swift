//
//  LocalStorageUnitTests.swift
//  SportPerformance
//
//  Created by macbook on 03.10.2024.
//
import XCTest
import Combine
import SwiftData
@testable import SportPerformance

final class LocalStorageTests: XCTestCase {
    var localStorage: LocalStorage<SportPerformanceLocal>!
    var alertManager: AlertManager!
    var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        let modelContainer = try! ModelContainer(for: SportPerformanceLocal.self)
        localStorage = LocalStorage<SportPerformanceLocal>(container: modelContainer)
        alertManager = AlertManager()
    }

    func testSavePerformance() {
        // Given
        let performance = SportPerformanceLocal(id: UUID().uuidString,
                                                title: "Local Performance",
                                                location: "Gym", duration: 60,
                                                isLocal: true)

        // When
        localStorage.save(performance, alertManager: alertManager)

        // Then
        // Fetch the performance back and assert that it exists
        localStorage.fetch(alertManager: alertManager)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Fetch should not fail.")
                }
            }, receiveValue: { performances in
                XCTAssertTrue(performances.contains { $0.id == performance.id })
            })
            .store(in: &cancellables)
    }
    
    func testDeletePerformance() {
        // Given
        let performance = SportPerformanceLocal(id: UUID().uuidString,
                                                title: "Local Performance",
                                                location: "Gym", duration: 60,
                                                isLocal: true)
        localStorage.save(performance, alertManager: alertManager)

        // When
        localStorage.delete(performance, alertManager: alertManager)

        // Then
        localStorage.fetch(alertManager: alertManager)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Fetch should not fail.")
                }
            }, receiveValue: { performances in
                XCTAssertFalse(performances.contains { $0.id == performance.id })
            })
            .store(in: &cancellables)
    }
}
