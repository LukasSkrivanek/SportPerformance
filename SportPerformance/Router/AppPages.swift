//
//  AppPages.swift
//  SportPerformance
//
//  Created by macbook on 01.09.2025.
//

import SwiftUI
import SwiftData


enum AppPages: Hashable {
    
    case mainTabBar
    case performanceList
    case addPerformance
}


enum Sheet: String, Identifiable {
    var id: String {
        self.rawValue
    }
    case zero
}

enum FullScreenCover: String, Identifiable {
    var id: String {
        self.rawValue
    }
    case addPerformance
}
