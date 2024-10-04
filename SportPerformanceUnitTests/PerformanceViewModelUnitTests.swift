//
//  SportPerformanceUnitTests.swift
//  SportPerformanceUnitTests
//
//  Created by macbook on 03.10.2024.
//
import XCTest
import SwiftData
import Combine
@testable import SportPerformance

final class PerformanceViewModelTests: XCTestCase {
    var viewModel: PerformanceViewModel<LocalStorage<SportPerformanceLocal>,
                                        RemoteStorage<SportPerformanceFirestore>>!
    var alertManager: AlertManager!
    var localStorage: LocalStorage<SportPerformanceLocal>!
    var remoteStorage: RemoteStorage<SportPerformanceFirestore>!
    var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        let modelContainer = try! ModelContainer() 
        localStorage = LocalStorage<SportPerformanceLocal>(container: modelContainer)
        remoteStorage = RemoteStorage<SportPerformanceFirestore>()
        alertManager = AlertManager()
        viewModel = PerformanceViewModel(localStorage: localStorage,
                                         remoteStorage: remoteStorage,
                                         alertManager: alertManager)
    }

    func testAddPerformance() {
        // Given
        let title = "New Performance"
        let location = "Park"
        let duration: TimeInterval = 30
        let isLocal = true

        // When
        viewModel.addPerformance(title: title, location: location,
                                 duration: duration, isLocal: isLocal)

        // Then
        XCTAssertEqual(viewModel.performances.count, 0)
    }
    
    func testDeletePerformance() {
        // Given
        let performance = SportPerformanceLocal(id: UUID().uuidString,
                                                title: "Local Performance",
                                                location: "Gym", duration: 60,
                                                isLocal: true)
        localStorage.save(performance, alertManager: alertManager)

        // When
        viewModel.deletePerformance(performance)

        // Then
        XCTAssertFalse(viewModel.performances.contains { $0.id == performance.id })
    }
    
    func testFetchPerformances() {
            // Given
            let performance1 = SportPerformanceLocal(id: UUID().uuidString,
                                                     title: "Local Performance 1",
                                                     location: "Gym", duration: 60,
                                                     isLocal: true)
            let performance2 = SportPerformanceLocal(id: UUID().uuidString,
                                                     title: "Local Performance 2",
                                                     location: "Pool", duration: 90,
                                                     isLocal: true)


            // Save local performances
            localStorage.save(performance1, alertManager: alertManager)
            localStorage.save(performance2, alertManager: alertManager)


            // When
            let expectation =
        XCTestExpectation(description:
        "Fetch should return all saved performances from local and remote sources")
            
        viewModel.loadPerformances(source: .local)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // Then
                XCTAssertTrue(self.viewModel.performances.contains { $0.id == performance1.id },
                              "Performance 1 should be in viewModel")
                XCTAssertTrue(self.viewModel.performances.contains { $0.id == performance2.id },
                              "Performance 2 should be in viewModel")

            }

        }


}
