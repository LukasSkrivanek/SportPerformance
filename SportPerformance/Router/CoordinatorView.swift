//
//  CoordinatorView.swift
//  SportPerformance
//
//  Created by macbook on 01.09.2025.
//

import SwiftUI
import SwiftData

struct CoordinatorView: View {

    @Environment(\.colorScheme) private var colorScheme
    @Environment(Coordinator.self) private var coordinator
    @Environment(AlertManager.self) var alertManager
    @Environment(AppState.self) var appState
    @Environment(PerformanceViewModel<
           LocalStorage<SportPerformanceLocal>,
           RemoteStorage<SportPerformanceFirestore>
       >.self) var viewModel

    var body: some View {
        NavigationStack(path: .twoWay(\Coordinator.path, on: coordinator)) {
            coordinator.build(page: .mainTabBar)
                .navigationDestination(for: AppPages.self) { page in
                    coordinator.build(page: page)
                }
        }
    }
}
