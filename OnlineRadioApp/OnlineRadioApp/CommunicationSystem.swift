//
//  CommunicationSystem.swift
//  OnlineRadioApp
//
//  Created by Iván Nádor on 2023. 08. 29..
//

import UIKit
import SwitchboardSDK
import SwitchboardAgora

enum State {
    case joining
    case joined
    case leaving
    case left
}

protocol CommunicationDelegate: AnyObject {
    func joined()
    func left()
    func receivedError(_ error: Error)
}

class CommunicationSystem {
    weak var delegate: CommunicationDelegate?

    let roomManager: RoomManager
    var room: Room?

    let isHost: Bool

    var isConnected: Bool {
        return room?.state.isConnected ?? false
    }

    var subscribeEnabled: Bool {
        return room?.state.subscribeEnabled ?? false
    }

    var publishEnabled: Bool {
        return room?.state.publishEnabled ?? false
    }

    var joined: Bool {
        var roleConnected = false
        if isHost {
            roleConnected = publishEnabled
        } else {
            roleConnected = subscribeEnabled
        }
        return isConnected && roleConnected
    }

    private var state: State = .left

    init(isHost: Bool) {
        let api = SwitchboardAPI(baseURL: Config.switchboardAPIBaseURL)
        roomManager = RoomManager(switchboardAPI: api)
        self.isHost = isHost
    }

    private func connect(name: String, roomID: String) {
        room = roomManager.createRoom(roomID: "OnlineRadioApp-" + roomID)
        room?.delegate = self
        room?.join(userID: name)
    }

    private func disconnect() {
        room?.leave()
    }

    private func subscribe() {
        room?.subscribe()
    }

    private func unsubscribe() {
        room?.unsubscribe()
    }

    private func publish() {
        room?.publish()
    }

    private func unpublish() {
        room?.unpublish()
    }

    func join(name: String, roomID: String) {
        state = .joining
        connect(name: name, roomID: roomID)
        if (isHost) {
            publish()
        } else {
            subscribe()
        }
    }

    func leave() {
        state = .leaving
        unpublish()
        unsubscribe()
        disconnect()
    }
}

extension CommunicationSystem: RoomDelegate {
    func room(room _: SwitchboardAgora.Room, didUpdateConnectionState connState: SwitchboardAgora.RoomConnectionState) {
        if state == .joining {
            var roleConnected = false
            if isHost {
                roleConnected = connState.publishEnabled
            } else {
                roleConnected = connState.subscribeEnabled
            }
            if connState.isConnected, roleConnected {
                state = .joined
                delegate?.joined()
            }
        } else if state == .leaving {
            var roleDisconnected = false
            if isHost {
                roleDisconnected = !connState.publishEnabled
            } else {
                roleDisconnected = !connState.subscribeEnabled
            }
            if !connState.isConnected, roleDisconnected {
                state = .left
                delegate?.left()
            }
        }
    }

    func room(room _: SwitchboardAgora.Room, didFailToJoinWithError error: Error) {
        delegate?.receivedError(error)
    }

    func room(room _: SwitchboardAgora.Room, didFailToPublishWithError error: Error) {
        delegate?.receivedError(error)
    }

    func room(room _: SwitchboardAgora.Room, didFailToSubscribeWithError error: Error) {
        delegate?.receivedError(error)
    }

    func room(room _: SwitchboardAgora.Room, didUpdatePublisherVideoView _: UIView?) {}

    func room(room _: SwitchboardAgora.Room, didUpdateSubscriberVideoViews _: [SwitchboardAgora.SubscriberVideoView]) {}

    func room(room _: SwitchboardAgora.Room, didUpdatePublisherAudioLevel _: Float) {}

    func room(room _: SwitchboardAgora.Room, didUpdateSubscriberAudioLevel _: Float, forUser _: String?) {}

    func room(room _: SwitchboardAgora.Room, userDidJoin user: String) {
        print("SHITTYFLUTE \(user)")
    }

    func room(room _: SwitchboardAgora.Room, userDidLeave user: String) {}

    func room(room _: SwitchboardAgora.Room, userDidMute _: String) {}

    func room(room _: SwitchboardAgora.Room, userDidUnmute _: String) {}

    func room(room _: SwitchboardAgora.Room, videoDidMute _: String) {}

    func room(room _: SwitchboardAgora.Room, videoDidUnmute _: String) {}

    func room(room _: SwitchboardAgora.Room, videoPublisherState _: Bool) {}
}
