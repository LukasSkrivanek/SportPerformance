//
//  LocalStorageUnitTests.swift
//  SportPerformance
//
//  Created by macbook on 03.10.2024.
//

import XCTest
import SwiftData
@testable import SportPerformance

final class LocalStorageTests: XCTestCase {
    var localStorage: LocalStorage<SportPerformanceLocal>!
    var alertManager: AlertManager!
    var modelContainer: ModelContainer!

    override func setUp() {
           super.setUp()
           do {
               let schema = Schema([SportPerformanceLocal.self])
               let configuration = ModelConfiguration(
                   isStoredInMemoryOnly: true,
                   cloudKitDatabase: .none
               )
               modelContainer = try ModelContainer(
                   for: schema,
                   configurations: [configuration]
               )
               
               localStorage = LocalStorage<SportPerformanceLocal>(container: modelContainer)
               alertManager = AlertManager()
           } catch {
               XCTFail("Failed to set up test: \(error)")
           }
       }

    override func tearDown() {
        localStorage = nil
        alertManager = nil
        modelContainer = nil
        super.tearDown()
    }


    @MainActor
    func testSavePerformance() async {
        // Given
        let performance = SportPerformanceLocal(
            id: UUID().uuidString,
            title: "Local Performance",
            location: "Gym",
            duration: 60,
            isLocal: true
        )

        // When
        localStorage.save(performance, alertManager: alertManager)

        // Then 
        do {
            let performances = try await localStorage.fetch(alertManager: alertManager)
            XCTAssertTrue(performances.contains { $0.id == performance.id })
            XCTAssertEqual(performances.count, 1)
            XCTAssertEqual(performances.first?.title, "Local Performance")
        } catch {
            XCTFail("Fetch should not fail: \(error)")
        }
    }
    
    @MainActor
    func testDeletePerformance() async {
        // Given
        let performance = SportPerformanceLocal(
            id: UUID().uuidString,
            title: "Local Performance",
            location: "Gym",
            duration: 60,
            isLocal: true
        )
        localStorage.save(performance, alertManager: alertManager)

        do {
            var performances = try await localStorage.fetch(alertManager: alertManager)
            XCTAssertTrue(performances.contains { $0.id == performance.id })
        } catch {
            XCTFail("Initial fetch failed: \(error)")
        }

        // When
        localStorage.delete(performance, alertManager: alertManager)

        // Then
        do {
            let performances = try await localStorage.fetch(alertManager: alertManager)
            XCTAssertFalse(performances.contains { $0.id == performance.id })
            XCTAssertEqual(performances.count, 0)
        } catch {
            XCTFail("Fetch after delete should not fail: \(error)")
        }
    }

    @MainActor
    func testFetchMultiplePerformances() async {
        // Given
        let performance1 = SportPerformanceLocal(
            id: UUID().uuidString,
            title: "Performance 1",
            location: "Gym",
            duration: 60,
            isLocal: true
        )
        
        let performance2 = SportPerformanceLocal(
            id: UUID().uuidString,
            title: "Performance 2",
            location: "Pool",
            duration: 90,
            isLocal: true
        )

        localStorage.save(performance1, alertManager: alertManager)
        localStorage.save(performance2, alertManager: alertManager)

        // When
        do {
            let performances = try await localStorage.fetch(alertManager: alertManager)

            // Then
            XCTAssertEqual(performances.count, 2)
            XCTAssertTrue(performances.contains { $0.id == performance1.id })
            XCTAssertTrue(performances.contains { $0.id == performance2.id })
            
            let titles = performances.map { $0.title }.sorted()
            XCTAssertEqual(titles, ["Performance 1", "Performance 2"])
            
        } catch {
            XCTFail("Fetch should not fail: \(error)")
        }
    }

    @MainActor
    func testFetchEmptyStorage() async {
        // When
        do {
            let performances = try await localStorage.fetch(alertManager: alertManager)
            // Then
            XCTAssertTrue(performances.isEmpty)
        } catch {
            XCTFail("Fetch should not fail for empty storage: \(error)")
        }
    }

    @MainActor
    func testSaveAndFetchProperties() async {
        // Given
        let performance = SportPerformanceLocal(
            id: "test-id-123",
            title: "Test Title",
            location: "Test Location",
            duration: 120.5,
            isLocal: true
        )

        // When
        localStorage.save(performance, alertManager: alertManager)

        // Then
        do {
            let performances = try await localStorage.fetch(alertManager: alertManager)
            let fetchedPerformance = performances.first
            
            XCTAssertNotNil(fetchedPerformance)
            XCTAssertEqual(fetchedPerformance?.id, "test-id-123")
            XCTAssertEqual(fetchedPerformance?.title, "Test Title")
            XCTAssertEqual(fetchedPerformance?.location, "Test Location")
            XCTAssertEqual(fetchedPerformance?.duration, 120.5)
            XCTAssertEqual(fetchedPerformance?.isLocal, true)
            
        } catch {
            XCTFail("Fetch should not fail: \(error)")
        }
    }
}
