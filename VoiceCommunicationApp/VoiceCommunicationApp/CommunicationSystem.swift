//
//  CommunicationSystem.swift
//  VoiceCommunicationApp
//
//  Created by Iván Nádor on 2023. 08. 17..
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
    func updatedUsers()
    func receivedError(_ error: Error)
}

class CommunicationSystem {
    weak var delegate: CommunicationDelegate?

    let roomManager: RoomManager
    var room: Room?

    var users: [String] = []

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
        return isConnected && subscribeEnabled && publishEnabled
    }

    private var state: State = .left

    init() {
        let api = SwitchboardAPI(baseURL: Config.switchboardAPIBaseURL)
        roomManager = RoomManager(switchboardAPI: api)
    }

    private func connect(name: String, roomID: String) {
        room = roomManager.createRoom(roomID: "VoiceCommunicationApp-" + roomID)
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
        subscribe()
        publish()
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
            if connState.isConnected, connState.subscribeEnabled, connState.publishEnabled {
                state = .joined
                delegate?.joined()
            }
        } else if state == .leaving {
            if !connState.isConnected, !connState.subscribeEnabled, !connState.publishEnabled {
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
        if !users.contains(where: { usr in
            usr == user
        }) {
            users.append(user)
        }
        delegate?.updatedUsers()
    }

    func room(room _: SwitchboardAgora.Room, userDidLeave user: String) {
        users.removeAll { userItem in
            userItem == user
        }
        delegate?.updatedUsers()
    }

    func room(room _: SwitchboardAgora.Room, userDidMute _: String) {}

    func room(room _: SwitchboardAgora.Room, userDidUnmute _: String) {}

    func room(room _: SwitchboardAgora.Room, videoDidMute _: String) {}

    func room(room _: SwitchboardAgora.Room, videoDidUnmute _: String) {}

    func room(room _: SwitchboardAgora.Room, videoPublisherState _: Bool) {}
}
