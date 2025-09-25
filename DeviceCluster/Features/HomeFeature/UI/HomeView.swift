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
        
        VStack(spacing: 0) {
            Text("Device Cluster")
                .font(.title)
            Spacer(minLength: 16)
            VStack(alignment: .leading) {
                Text("Found Device IDs")
                    .font(.headline)
                    .padding(.horizontal, 16)
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(vm.peers, id: \.self) { peer in
                            Button(action: {
                                vm.peerIdClicked(peer.id)
                            }, label: {
                                HStack {
                                    Text(peer.id)
                                        .font(.callout)
                                    Spacer(minLength: 16)
                                    if peer.isConnected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                    }
                                }
                            })
                            .frame(height: 36)
                            .padding(.horizontal, 8)
                            Divider()
                        }
                    }
                    .padding(.vertical, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.gray.opacity(0.3))
                .cornerRadius(16)
                .padding(.horizontal, 16)
            }
            Spacer(minLength: 16)
            if vm.hasConnectedPeer {
                Button(action: { vm.sendTestAudioTapped() }) {
                    Text("Send Test Audio")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .onAppear(perform: vm.willAppear)
        .onDisappear(perform: vm.didDisappear)
        .loadingOverlay(isPresented: $vm.isLoading)
        .errorAlert(error: $vm.error)
    }
}

#Preview {
    HomeView(vm: .init(router: .init(),
                       startObservingPeers: StartObservingPeersUseCaseFakeImpl(),
                       observePeers: ObservePeersUseCaseFakeImpl(),
                       connectWithPeer: ConnectWithPeerUseCaseFakeImpl(),
                       sendTestAudio: SendTestAudioUseCaseFakeImpl()))
}
