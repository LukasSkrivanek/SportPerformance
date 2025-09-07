//
//  PerformanceListVIew.swift
//  SportPerformance
//
//  Created by macbook on 30.09.2024.
//
import SwiftUI

struct PerformanceListView: View {

    @Environment(AlertManager.self) var alertManager
    @Environment(Coordinator.self) var coordinator
    @Environment(PerformanceViewModel<
           LocalStorage<SportPerformanceLocal>,
           RemoteStorage<SportPerformanceFirestore>
       >.self) var viewModel

    var body: some View {
        VStack {
            Picker("Filter", selection: .twoWay(\.filter, on: viewModel)) {
                ForEach(PerformanceFilter.allCases, id: \.self) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            List {
                ForEach(viewModel.filteredPerformances, id: \.id) { performance in
                    PerformanceRow(performance: performance)
                        .listRowSeparator(.hidden)
                        .swipeActions {
                            Button(role: .destructive) {
                                Task { [viewModel] in
                                    await viewModel.deletePerformance(performance)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .task {
            await viewModel.loadPerformances()
        }
        .refreshable {
           await viewModel.loadPerformances()
        }
        .alert(isPresented: .twoWay(\.isPresented, on: alertManager)) {
            Alert(title: Text(alertManager.alertTitle),
                  message: Text(alertManager.alertMessage),
                  dismissButton: .default(Text("OK")))
        }
        .overlay {
            if viewModel.filteredPerformances.isEmpty {
                ContentUnavailableView.search(text: viewModel.filter.rawValue)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Sport Performances")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    coordinator.push(page: .addPerformance)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}
