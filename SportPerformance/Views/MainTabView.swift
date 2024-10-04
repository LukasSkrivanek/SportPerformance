//
//  MainTabView.swift
//  SportPerformance
//
//  Created by macbook on 30.09.2024.
//
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var alertManager: AlertManager
     var localStorage: LocalStorage<SportPerformanceLocal>
     var remoteStorage: RemoteStorage<SportPerformanceFirestore>
    
    var body: some View {
        TabView {
            PerformanceListView(localStorage: localStorage,
                                remoteStorage: remoteStorage,
                                alertManager: alertManager)
                .tabItem {
                    Label("List", systemImage: "list.dash")
                }
            AddPerformanceView(viewModel: PerformanceViewModel(localStorage: localStorage,
                                                               remoteStorage: remoteStorage,
                                                               alertManager: alertManager))
                .tabItem {
                    Label("Add", systemImage: "plus")
                }
        }
    }
}
