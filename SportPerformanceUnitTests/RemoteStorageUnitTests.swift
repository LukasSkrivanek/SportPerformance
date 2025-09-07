//
//  RemoteStorageUnitTests.swift
//  SportPerformance
//
//  Created by macbook on 03.10.2024.

import XCTest
@testable import SportPerformance

final class RemoteStorageTests: XCTestCase {
    var remoteStorage: MockRemoteStorage!
    var alertManager: AlertManager!

    override func setUp() {
        super.setUp()
        remoteStorage = MockRemoteStorage()
        alertManager = AlertManager()
    }

    override func tearDown() {
        remoteStorage = nil
        alertManager = nil
        super.tearDown()
    }

    func testSaveRemotePerformance() async {
        // Given
        let performance = SportPerformanceFirestore(
            id: UUID().uuidString,
            title: "Remote Performance",
            location: "Stadium",
            duration: 120,
            isLocal: false
        )

        // When
        remoteStorage.save(performance, alertManager: alertManager)

        // Then
        do {
            let performances = try await remoteStorage.fetch(alertManager: alertManager)
            XCTAssertTrue(performances.contains { $0.id == performance.id })
            XCTAssertEqual(performances.count, 1)
            XCTAssertEqual(performances.first?.title, "Remote Performance")
        } catch {
            XCTFail("Fetch should not fail: \(error)")
        }
    }
    
    func testDeleteRemotePerformance() async {
        // Given
        let performance = SportPerformanceFirestore(
            id: UUID().uuidString,
            title: "Remote Performance",
            location: "Stadium",
            duration: 120,
            isLocal: false
        )
        
        // Save to mock
        remoteStorage.save(performance, alertManager: alertManager)
        
        // Verify it was saved
        do {
            let performances = try await remoteStorage.fetch(alertManager: alertManager)
            XCTAssertTrue(performances.contains { $0.id == performance.id })
            XCTAssertEqual(performances.count, 1)
        } catch {
            XCTFail("Initial fetch failed: \(error)")
            return
        }

        // When
        remoteStorage.delete(performance, alertManager: alertManager)

        // Then
        do {
            let performances = try await remoteStorage.fetch(alertManager: alertManager)
            XCTAssertFalse(performances.contains { $0.id == performance.id })
            XCTAssertEqual(performances.count, 0)
        } catch {
            XCTFail("Fetch after delete should not fail: \(error)")
        }
    }

    func testUpdateRemotePerformance() async {
        // Given
        let performance = SportPerformanceFirestore(
            id: "test-id-123",
            title: "Original Title",
            location: "Stadium",
            duration: 120,
            isLocal: false
        )
        
        remoteStorage.save(performance, alertManager: alertManager)

        // When - Update with same ID
        let updatedPerformance = SportPerformanceFirestore(
            id: "test-id-123",
            title: "Updated Title",
            location: "Arena",
            duration: 150,
            isLocal: false
        )
        
        remoteStorage.save(updatedPerformance, alertManager: alertManager)

        // Then
        do {
            let performances = try await remoteStorage.fetch(alertManager: alertManager)
            XCTAssertEqual(performances.count, 1)
            XCTAssertEqual(performances.first?.title, "Updated Title")
            XCTAssertEqual(performances.first?.location, "Arena")
            XCTAssertEqual(performances.first?.duration, 150)
        } catch {
            XCTFail("Fetch should not fail: \(error)")
        }
    }

    func testFetchEmptyStorage() async {
        // When
        do {
            let performances = try await remoteStorage.fetch(alertManager: alertManager)
            
            // Then
            XCTAssertTrue(performances.isEmpty)
        } catch {
            XCTFail("Fetch should not fail for empty storage: \(error)")
        }
    }
}

class MockRemoteStorage: PerformanceStorage {
    typealias T = SportPerformanceFirestore
    
    private var performances: [SportPerformanceFirestore] = []
    
    func save(_ item: SportPerformanceFirestore, alertManager: AlertManager) {
        // Remove if exists (update)
        performances.removeAll { $0.id == item.id }
        performances.append(item)
    }
    
    func fetch(alertManager: AlertManager) async throws -> [SportPerformanceFirestore] {
        return performances
    }
    
    func delete(_ item: SportPerformanceFirestore, alertManager: AlertManager) {
        performances.removeAll { $0.id == item.id }
    }
}
