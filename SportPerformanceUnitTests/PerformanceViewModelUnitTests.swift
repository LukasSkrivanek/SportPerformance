//
//  SportPerformanceUnitTests.swift
//  SportPerformanceUnitTests
//
//  Created by macbook on 03.10.2024.
//
//

import XCTest
import SwiftData
@testable import SportPerformance

final class PerformanceViewModelTests: XCTestCase {
    var viewModel: PerformanceViewModel<LocalStorage<SportPerformanceLocal>,
                                        RemoteStorage<SportPerformanceFirestore>>!
    var alertManager: AlertManager!
    var localStorage: LocalStorage<SportPerformanceLocal>!
    var remoteStorage: RemoteStorage<SportPerformanceFirestore>!
    
    @MainActor
    override func setUp() {
        super.setUp()
        let modelContainer = try! ModelContainer(for: SportPerformanceLocal.self)
        localStorage = LocalStorage<SportPerformanceLocal>(container: modelContainer)
        remoteStorage = RemoteStorage<SportPerformanceFirestore>()
        alertManager = AlertManager()
        viewModel = PerformanceViewModel(
            localStorage: localStorage,
            remoteStorage: remoteStorage,
            alertManager: alertManager
        )
    }
    
    @MainActor
    override func tearDown() {
        viewModel = nil
        localStorage = nil
        remoteStorage = nil
        alertManager = nil
        super.tearDown()
    }
    
    @MainActor
    func testAddPerformance() async {
        // Given
        let title = "New Performance"
        let location = "Park"
        let duration: TimeInterval = 30
        let isLocal = true
        
        // When
        await viewModel.addPerformance(
            title: title,
            location: location,
            duration: duration,
            isLocal: isLocal
        )
        
        // Then
        XCTAssertEqual(viewModel.performances.first?.title, title)
        XCTAssertEqual(viewModel.performances.first?.location, location)
        XCTAssertEqual(viewModel.performances.first?.duration, duration)
        XCTAssertEqual(viewModel.performances.first?.isLocal, isLocal)
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
        
        // First add the performance
        localStorage.save(performance, alertManager: alertManager)
        await viewModel.loadPerformances(source: .local)
        XCTAssertTrue(viewModel.performances.contains { $0.id == performance.id })
        
        // When
        await viewModel.deletePerformance(performance)
        
        // Then
        XCTAssertFalse(viewModel.performances.contains { $0.id == performance.id })
    }
    
    @MainActor
    func testFetchLocalPerformances() async {
        // Given
        let performance1 = SportPerformanceLocal(
            id: UUID().uuidString,
            title: "Local Performance 1",
            location: "Gym",
            duration: 60,
            isLocal: true
        )
        let performance2 = SportPerformanceLocal(
            id: UUID().uuidString,
            title: "Local Performance 2",
            location: "Pool",
            duration: 90,
            isLocal: true
        )
        
        // Save local performances
        localStorage.save(performance1, alertManager: alertManager)
        localStorage.save(performance2, alertManager: alertManager)
        
        // When
        await viewModel.loadPerformances(source: .local)
        
        // Then
        XCTAssertTrue(viewModel.performances.contains { $0.id == performance1.id })
        XCTAssertTrue(viewModel.performances.contains { $0.id == performance2.id })
    }
    
    @MainActor
    func testIsValidProperty() async {
        // Given
        viewModel.title = "Test Title"
        viewModel.location = "Test Location"
        viewModel.duration = 30
        
        // Then
        XCTAssertTrue(viewModel.isValid)
        
        // When
        viewModel.title = ""
        
        // Then
        XCTAssertFalse(viewModel.isValid)
        
        // When
        viewModel.title = "Test Title"
        viewModel.location = ""
        
        // Then
        XCTAssertFalse(viewModel.isValid)
        
        // When
        viewModel.location = "Test Location"
        viewModel.duration = 0
        
        // Then
        XCTAssertFalse(viewModel.isValid)
    }
}

