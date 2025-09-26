//
//  DCScreenLoader.swift
//  DeviceCluster
//
//  Created by Daniyar Kurmanbayev on 2025-08-22.
//

import SwiftUI

struct DCScreenLoader: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.25).ignoresSafeArea()

            ProgressView()
            .scaleEffect(1.3)
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

struct DCScreenLoadingModifier: ViewModifier {
    @Binding var isPresented: Bool
    var message: String?

    func body(content: Content) -> some View {
        content
            .allowsHitTesting(!isPresented)
            .overlay(alignment: .center) {
                if isPresented {
                    DCScreenLoader()
                        .transition(.opacity)
                        .animation(.snappy(duration: 0.18), value: isPresented)
                }
            }
    }
}

extension View {
    func loadingOverlay(isPresented: Binding<Bool>) -> some View {
        modifier(DCScreenLoadingModifier(isPresented: isPresented))
    }
}

#Preview {
    @Previewable @State var isLoading = true

    VStack {
        Spacer()
        Button("Toggle Loading") {
            isLoading.toggle()
        }
        Spacer()
        VStack {
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .loadingOverlay(isPresented: $isLoading)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.white)
}

