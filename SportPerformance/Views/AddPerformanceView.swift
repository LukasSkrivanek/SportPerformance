//
//  AddPerformanceView.swift
//  SportPerformance
//
//  Created by macbook on 30.09.2024.
//
import SwiftUI

struct AddPerformanceView: View {
    @EnvironmentObject var alertManager: AlertManager
    @ObservedObject  var viewModel: PerformanceViewModel<LocalStorage<SportPerformanceLocal>,
                                                            RemoteStorage<SportPerformanceFirestore>>
    @Environment(\.presentationMode) private var presentationMode
    var body: some View {
        Form {
            Section(header: Text("Performance Info")) {
                TextField("Title", text: $viewModel.title)
                TextField("Location", text: $viewModel.location)
                TextField("Duration (in minutes)", value: $viewModel.duration, formatter: NumberFormatter())
                    .keyboardType(.decimalPad) 
            }
            Section(header: Text("Storage Type")) {
                Toggle("Save Locally", isOn: $viewModel.isLocal)
            }
            Button("Save") {
                viewModel.addPerformance(title: viewModel.title,
                                         location: viewModel.location,
                                         duration: viewModel.duration * 60,
                                         isLocal: viewModel.isLocal)
                viewModel.title = ""
                viewModel.location = ""
                viewModel.duration = 0
                presentationMode.wrappedValue.dismiss()
            }
            .disabled(!viewModel.isValid)
        }
        .alert(isPresented: $alertManager.isPresented) {
                        Alert(title: Text(alertManager.alertTitle), message: Text(alertManager.alertMessage), dismissButton: .default(Text("OK")))
                    }
        .navigationTitle("Add Performance")
    }
}
