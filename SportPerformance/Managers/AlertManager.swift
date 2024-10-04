//
//  AlertManager.swift
//  SportPerformance
//
//  Created by macbook on 03.10.2024.
//
import SwiftUI

enum AppError: LocalizedError {
    case saveError
    case fetchError
    case deleteError
    case invalidData
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .saveError:
            return "Failed to save the item."
        case .fetchError:
            return "Failed to fetch data."
        case .deleteError:
            return "Failed to delete the item."
        case .invalidData:
            return "The data is invalid"
        case .unknownError:
            return "An unknown error occurred."
        }
    }
    var recoverySuggestion: String? {
        return "Please try again later or contact support."
    }
}

class AlertManager: ObservableObject {
    @Published var isPresented: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    
    func show(title: String, message: String) {
        self.alertTitle = title
        self.alertMessage = message
        self.isPresented = true
    }
}

