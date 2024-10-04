//
//  PerformanceListVIew.swift
//  SportPerformance
//
//  Created by macbook on 30.09.2024.
//
import SwiftUI

struct PerformanceListView: View {
    @EnvironmentObject var alertManager: AlertManager
    @StateObject private var viewModel: PerformanceViewModel<LocalStorage<SportPerformanceLocal>,
                                                             RemoteStorage<SportPerformanceFirestore>>
    init(localStorage: LocalStorage<SportPerformanceLocal>,
         remoteStorage: RemoteStorage<SportPerformanceFirestore>,
         alertManager: AlertManager) {
        _viewModel = StateObject(wrappedValue: PerformanceViewModel(localStorage: localStorage,
                                                                    remoteStorage: remoteStorage,
                                                                    alertManager: alertManager))}
    var body: some View {
        NavigationView {
            VStack {
                Picker("Filter", selection: $viewModel.filter) {
                    Text("All").tag("All")
                    Text("Local").tag("Local")
                    Text("Remote").tag("Remote")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                List {
                    ForEach(viewModel.filteredPerformances, id: \.id) { performance in
                        PerformanceRow(performance: performance)
                            .listRowSeparator(.hidden)
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewModel.deletePerformance(performance)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .alert(isPresented: $alertManager.isPresented) {
                            Alert(title: Text(alertManager.alertTitle),
                                  message: Text(alertManager.alertMessage),
                                  dismissButton: .default(Text("OK")))
                        }
            .listStyle(.plain)
            .navigationTitle("Sport Performances")
            .toolbar {
                NavigationLink(destination: AddPerformanceView(viewModel: viewModel)) {
                    Image(systemName: "plus")
                }
            }
            
        }
    }
}
