//
//  DCErrorAlertModifier.swift
//  DeviceCluster
//
//  Created by Daniyar Kurmanbayev on 2025-08-26.
//

import SwiftUI

struct DCErrorAlertModifier: ViewModifier {
    @Binding var error: String?
    
    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: Binding<Bool>(
                get: { error != nil },
                set: { if !$0 { error = nil } }
            )) {
                Button("Ok", role: .cancel) {
                    error = nil
                }
            } message: {
                if let error {
                    Text(error)
                }
            }
    }
}

extension View {
    func errorAlert(error: Binding<String?>) -> some View {
        self.modifier(DCErrorAlertModifier(error: error))
    }
}

