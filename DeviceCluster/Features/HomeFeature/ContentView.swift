//
//  ContentView.swift
//  DeviceCluster
//
//  Created by Daniyar Kurmanbayev on 2025-09-24.
//

import SwiftUI

struct ContentView: View {
    let peerService: PeerService
    
    init(peerService: PeerService) {
        self.peerService = peerService
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            peerService.start()
        }
    }
}

#Preview {
    ContentView(peerService: PeerServiceFakeImpl())
}
