//
//  MainTabView.swift
//  SportPerformance
//
//  Created by macbook on 30.09.2024.
//
import SwiftUI

struct MainTabView: View {

    @Environment(Coordinator.self) var coordinator
    @Environment(AppState.self) var appState

    var body: some View {
        TabView(selection: .twoWay(\.selectedTab, on: appState)) {
            coordinator.build(page: .performanceList)
                .tabItem {
                    Label("List", systemImage: "list.dash")
                }
                .tag(Tab.list)

            coordinator.build(page: .addPerformance)
            .tabItem {
                Label("Add", systemImage: "plus")
            }
            .tag(Tab.add)
        }
    }
}

