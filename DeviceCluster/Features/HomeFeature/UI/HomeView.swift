//
//  HomeView.swift
//  DeviceCluster
//
//  Created by Daniyar Kurmanbayev on 2025-09-24.
//

import SwiftUI

struct HomeView: View {
    @State private var vm: HomeViewModel
    
    init(vm: HomeViewModel) {
        _vm = State(initialValue: vm)
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        VStack {
            ForEach(vm.peers, id: \.self) { peer in
                Text(peer.id)
            }
        }
        .padding()
        .onAppear(perform: vm.willAppear)
        .onDisappear(perform: vm.didDisappear)
    }
}

#Preview {
    HomeView(vm: .init(router: .init(),
                       startObservingPeers: StartObservingPeersUseCaseFakeImpl(),
                       observePeers: ObservePeersUseCaseFakeImpl(),
                       connectWithPeer: ConnectWithPeerUseCaseFakeImpl()))
}
