//
//  MultipeerConnectivity.swift
//  AR tests
//
//  Created by Yu Wang on 1/7/19.
//  Copyright © 2019 Illumination. All rights reserved.
//



import MultipeerConnectivity

enum serviceTypes:String{
    case bbFree = "bb-free"
    case bbTime = "bb-time"
    case bbBall = "bb-ball"
    case pp = "pp"
}

/// - Tag: MultipeerSession
class MultipeerSession: NSObject {
    //bb: basketball free:freemode
    static let serviceType = serviceTypes.bbFree.rawValue
    
    let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    var session: MCSession!
    var advertiser: MCAdvertiserAssistant!
    var browser: MCBrowserViewController!
    
    var receivedDataHandler: (Data, MCPeerID) -> Void
    var sendWorldMap:()->Void
    let dissmissHandler:()->Void
    let connectedHandler:()->Void
    var showNotification:(String)->Void
    var sendData:()->Void
    
    var isHost = false

    /// - Tag: MultipeerSetup
    init(receivedDataHandler: @escaping (Data, MCPeerID) -> Void, dissmissHandler: @escaping () -> Void, connectedHandler: @escaping () -> Void, sendWorldMap: @escaping () -> Void, showNotification: @escaping (String) -> Void, sendData: @escaping () -> Void) {
        self.receivedDataHandler = receivedDataHandler
        self.dissmissHandler = dissmissHandler
        self.connectedHandler = connectedHandler
        self.sendWorldMap = sendWorldMap
        self.showNotification = showNotification
        self.sendData = sendData
        
        super.init()
        
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        
        advertiser = MCAdvertiserAssistant(serviceType: MultipeerSession.serviceType, discoveryInfo: nil, session: session)
        advertiser.delegate = self
        
        browser = MCBrowserViewController(serviceType: MultipeerSession.serviceType, session: session)
        browser.delegate = self
    }
    
    func sendToAllPeers(_ data: Data) {
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("error sending data to peers: \(error.localizedDescription)")
        }
    }
    
    var connectedPeers: [MCPeerID] {
        return session.connectedPeers
    }
}

extension MultipeerSession: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            DispatchQueue.main.async {
                self.showNotification("\(peerID.displayName) has joined")
                if !self.isHost{
                    self.browserViewControllerDidFinish(self.browser)
                }
            }
        case .notConnected:
            break
        case .connecting:
            break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        receivedDataHandler(data, peerID)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        fatalError("This service does not send/receive streams.")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        fatalError("This service does not send/receive resources.")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        fatalError("This service does not send/receive resources.")
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
    
}

extension MultipeerSession: MCBrowserViewControllerDelegate {
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        if session.connectedPeers.count<=1{
            self.dissmissHandler()
            self.connectedHandler()
        }else{
            browserViewController.showAlert(title: "This Game Only Supports 2 Players", message: "Wait until someone in leaves this game or you can host your only game", buttonTitle: "OK", showCancel: false) { (action) in
                self.dissmissHandler()
                
            }
        }
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dissmissHandler()
    }
}

extension MultipeerSession: MCAdvertiserAssistantDelegate {
    
}
