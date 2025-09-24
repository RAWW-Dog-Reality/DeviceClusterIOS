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
    func start()
    func stop()
}

final class PeerServiceFakeImpl: PeerService {
    func start() {}
    func stop() {}
}

final class PeerServiceImpl: NSObject, PeerService, ObservableObject {
    private let secureStorage: SecureStorage
    
    private var myPeer: MCPeerID?
    private var session: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?

    @Published var state: MCSessionState = .notConnected

    init(secureStorage: SecureStorage) {
        self.secureStorage = secureStorage
        
        super.init()
        
        Task { await setup() }
    }
    
    deinit {
        stop()
    }
    
    private func setup() async {
        do {
            let peer = try await getPeerID()
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
        } catch {
            Logger.log("Failed to initialize PeerService — error=\(error.localizedDescription)", level: .error)
        }
    }
    
    private func getPeerID() async throws -> MCPeerID {
        do {
            let peerID = try await secureStorage.getString(Constants.Storage.Keys.peerID)
            return MCPeerID(displayName: peerID)
        } catch {
            let suffix = UUID().uuidString.prefix(25)
            let name = "DC-MPC-\(suffix)"
            try await secureStorage.putString(name, key: Constants.Storage.Keys.peerID)
            return MCPeerID(displayName: name)
        }
    }
    
    func start() {
        Logger.log("Starting advertising and browsing")
        guard isInitialized() else {
            Logger.log("Peer service not initialized yet, retrying in 1s")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.start()
            }
            return
        }
        advertiser?.startAdvertisingPeer()
        browser?.startBrowsingForPeers()
        Logger.log("Started advertising and browsing")
    }
    
    func stop() {
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        Logger.log("Stopped advertising and browsing")
    }
    
    private func isInitialized() -> Bool {
        myPeer != nil && session != nil && advertiser != nil && browser != nil
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
        guard let myPeer = myPeer, let session = session else { return }
        if peerID != myPeer {
            Logger.log("Found peer=\(peerID.displayName). Inviting…")
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 20)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        Logger.log("Browser failed to start — error=\(error.localizedDescription)", level: .error)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        Logger.log("Lost peer=\(peerID.displayName)")
    }
}

extension PeerServiceImpl: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        Logger.log("MCSession state changed — peer=\(peerID.displayName) state=\(state.description)")
        self.state = state
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didReceive stream: InputStream, withName: String, fromPeer: MCPeerID) { }
    func session(_ session: MCSession, didStartReceivingResourceWithName: String, fromPeer: MCPeerID, with: Progress) { }
    func session(_ session: MCSession, didFinishReceivingResourceWithName: String, fromPeer: MCPeerID, at: URL?, withError: Error?) { }
}
