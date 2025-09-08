//
//  AddPerformanceView.swift
//  SportPerformance
//
//  Created by macbook on 30.09.2024.
//
import SwiftUI

struct AddPerformanceView: View {

    @Environment(AlertManager.self) var alertManager
    @Environment(Coordinator.self) var coordinator
    @Environment(AppState.self) var appState
    @Environment(PerformanceViewModel<
           LocalStorage<SportPerformanceLocal>,
           RemoteStorage<SportPerformanceFirestore>
       >.self) var viewModel

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Performance Details")) {
                    TextField("Workout Title", text: .twoWay(\.title, on: viewModel))
                        .textContentType(.name)
                    
                    TextField("Location", text: .twoWay(\.location, on: viewModel))
                        .textContentType(.location)
                    
                    HStack {
                        Text("Duration")
                        Spacer()
                        TextField("Minutes", value: .twoWay(\.duration, on: viewModel), formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("min")
                            .foregroundColor(.secondary)
                    }
                }
                Section(
                    header: Text(
                        "Storage Preference"
                    ),
                    footer: Text(
                        viewModel.isLocal ?
                        "Saved locally on your device" :
                            "Saved in the cloud (accessible from any device)"
                    )
                ) {
                    Toggle(isOn: .twoWay(\.isLocal, on: viewModel)) {
                        HStack {
                            Image(systemName: viewModel.isLocal ? "iphone" : "cloud")
                                .foregroundColor(viewModel.isLocal ? .blue : .green)
                            Text(viewModel.isLocal ? "Local Storage" : "Cloud Storage")
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                
                Section {
                    Button("Save") {
                        Task {
                            await viewModel.addPerformance(
                                title: viewModel.title,
                                location: viewModel.location,
                                duration: viewModel.duration * 60,
                                isLocal: viewModel.isLocal
                            )
                            viewModel.title = ""
                            viewModel.location = ""
                            viewModel.duration = 0
                            appState.selectedTab = .list
                        }
                    }
                    .disabled(!viewModel.isValid)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                }
            }
            .navigationTitle("Add Performance")
            .alert(isPresented: .twoWay(\.isPresented, on: alertManager)) {
                Alert(
                    title: Text(alertManager.alertTitle),
                    message: Text(alertManager.alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}
