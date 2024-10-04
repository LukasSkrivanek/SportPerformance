//
//  RemoteStorageUnitTests.swift
//  SportPerformance
//
//  Created by macbook on 03.10.2024.
//
import XCTest
import FirebaseFirestore
import Combine
@testable import SportPerformance

final class RemoteStorageTests: XCTestCase {
    var remoteStorage: RemoteStorage<SportPerformanceFirestore>!
    var alertManager: AlertManager!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        remoteStorage = RemoteStorage<SportPerformanceFirestore>()
        alertManager = AlertManager()
        cancellables = Set<AnyCancellable>()
    }

    func testSaveRemotePerformance() {
        // Given
        let performance = SportPerformanceFirestore(id: UUID().uuidString,
                                                    title: "Remote Performance",
                                                    location: "Stadium", duration: 120,
                                                    isLocal: false)

        // When
        remoteStorage.save(performance, alertManager: alertManager)

        // Then
        remoteStorage.fetch(alertManager: alertManager)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Fetch should not fail.")
                }
            }, receiveValue: { performances in
                XCTAssertTrue(performances.contains { $0.id == performance.id })
            })
            .store(in: &cancellables)
    }
    
    func testDeleteRemotePerformance() {
        // Given
        let performance = SportPerformanceFirestore(id: UUID().uuidString,
                                                    title: "Remote Performance", location: "Stadium",
                                                    duration: 120, isLocal: false)
        remoteStorage.save(performance, alertManager: alertManager)

        // When
        remoteStorage.delete(performance, alertManager: alertManager)

        // Then
        remoteStorage.fetch(alertManager: alertManager)
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

