//
//  PerformanceRouter.swift
//  SportPerformance
//
//  Created by macbook on 01.09.2025.
//

import SwiftUI

@Observable
final class Coordinator {

    var path: NavigationPath = NavigationPath()
    var sheet: Sheet?
    var fullScreenCover: FullScreenCover?
    var sheetDetent: Set<PresentationDetent> = [.fraction(0.6)]
    
    func push(page: AppPages) {
        path.append(page)
    }

    func pop() {
        path.removeLast()
    }

    func popToRoot() {
        if !path.isEmpty {
            path.removeLast(path.count)
        }
    }

    func presentSheet(_ sheet: Sheet, detent: PresentationDetent = .medium) {
        self.sheet = sheet
        self.sheetDetent =  [detent]
    }

    func presentFullScreenCover(_ cover: FullScreenCover) {
        fullScreenCover = cover
    }

    func dismissSheet() {
        self.sheet = nil
    }

    func dismissCover() {
        fullScreenCover = nil
    }

    @ViewBuilder
       func build(page: AppPages) -> some View {
           switch page {
           case .addPerformance:
               AddPerformanceView()
           case .mainTabBar:
               MainTabView()
           case .performanceList:
               PerformanceListView()
           }
       }
}
