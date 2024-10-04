//
//  AlertManagerTests.swift
//  SportPerformance
//
//  Created by macbook on 03.10.2024.
//
import XCTest
import Combine
import SwiftUI
@testable import SportPerformance

final class AlertManagerTests: XCTestCase {
    var alertManager: AlertManager!

    override func setUp() {
        super.setUp()
        alertManager = AlertManager()
    }

    func testShowAlert() {
        // Given
        let title = "Test Title"
        let message = "Test Message"

        // When
        alertManager.show(title: title, message: message)

        // Then
        XCTAssertTrue(alertManager.isPresented)
        XCTAssertEqual(alertManager.alertTitle, title)
        XCTAssertEqual(alertManager.alertMessage, message)
    }
}
