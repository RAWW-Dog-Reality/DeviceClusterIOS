//
//  PeerService.swift
//  DeviceCluster
//
//  Created by Daniyar Kurmanbayev on 2025-09-24.
//

import SwiftUI
import MultipeerConnectivity
import Combine

protocol PeerService {
    func start(myPeerID: String)
    func stop()
    func connect(with peerID: String) async throws
    func peersStream() -> AsyncStream<[PeerDTO]>
}

@MainActor
final class PeerServiceImpl: NSObject, PeerService, ObservableObject {
    private var myPeer: MCPeerID?
    private var session: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?

    @Published private var peers: [PeerDTO] = []
    
    func start(myPeerID: String) {
        let peer = MCPeerID(displayName: myPeerID)
        
        self.myPeer = peer

        let session = MCSession(peer: peer, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        self.session = session

        let advertiser = MCNearbyServiceAdvertiser(peer: peer,
                                                   discoveryInfo: nil,
                                                   serviceType: Constants.AppConfiguration.serviceName)
        advertiser.delegate = self
        self.advertiser = advertiser

        let browser = MCNearbyServiceBrowser(peer: peer,
                                             serviceType: Constants.AppConfiguration.serviceName)
        browser.delegate = self
        self.browser = browser

        Logger.log("PeerService initialized — peer=\(peer.displayName), service=\(Constants.AppConfiguration.serviceName)")
        
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
        
        Logger.log("Started advertising and browsing")
    }
    
    func stop() {
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        Logger.log("Stopped advertising and browsing")
    }
    
    func connect(with peerID: String) async throws {
        guard let session = session,
              let peer = peers.first(where: { $0.getID() == peerID })
        else { return }
        
        let timeout = 20
        var timeElapsed = 0
        
        browser?.invitePeer(peer.peerID, to: session, withContext: nil, timeout: 20)
        
        while true {
            if timeElapsed >= timeout {
                Logger.log("Timed out waiting to connect to peer=\(peer.getID())", level: .error)
                throw DataError.failedToConnectWithPeer
            }
            
            let peer = peers.first(where: { $0.getID() == peer.getID() })
            
            if peer?.isConnected ?? false {
                break
            } else {
                try await Task.sleep(for: .seconds(1))
                timeElapsed += 1
            }
        }
    }
    
    func peersStream() -> AsyncStream<[PeerDTO]> {
        AsyncStream { continuation in
            let cancellable = $peers.sink { value in
                continuation.yield(value)
            }
            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }
}

extension PeerServiceImpl: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        if let session = session {
            Logger.log("Received invitation from peer=\(peerID.displayName) — accepting")
            invitationHandler(true, session)
        } else {
            Logger.log("Received invitation from peer=\(peerID.displayName) — no session yet, declining")
            invitationHandler(false, nil)
        }
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        Logger.log("Advertiser failed to start — error=\(error.localizedDescription)", level: .error)
    }
}

extension PeerServiceImpl: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo: [String : String]?) {
        guard let myPeer = myPeer, peerID != myPeer else { return }
        
        if !peers.contains(where: { $0.getID() == peerID.displayName }) {
            peers.append(.init(peerID: peerID))
        }
        
        Logger.log("Found peer=\(peerID.displayName)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        Logger.log("Browser failed to start — error=\(error.localizedDescription)", level: .error)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        if let idIndex = peers.firstIndex(where: { $0.getID() == peerID.displayName }) {
            peers.remove(at: idIndex)
        }
        
        Logger.log("Lost peer=\(peerID.displayName)")
    }
}

extension PeerServiceImpl: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        Logger.log("MCSession state changed — peer=\(peerID.displayName) state=\(state.description)")
        if let peerIndex = peers.firstIndex(where: { $0.getID() == peerID.displayName }) {
            switch state {
            case .connected:
                peers[peerIndex].isConnected = true
            default:
                peers[peerIndex].isConnected = false
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didReceive stream: InputStream, withName: String, fromPeer: MCPeerID) { }
    func session(_ session: MCSession, didStartReceivingResourceWithName: String, fromPeer: MCPeerID, with: Progress) { }
    func session(_ session: MCSession, didFinishReceivingResourceWithName: String, fromPeer: MCPeerID, at: URL?, withError: Error?) { }
}
