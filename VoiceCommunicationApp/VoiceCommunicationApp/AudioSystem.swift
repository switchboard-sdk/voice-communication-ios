//
//  AudioSystem.swift
//  VoiceCommunicationApp
//
//  Created by Iván Nádor on 2023. 08. 16..
//

import SwitchboardSDK
import SwitchboardAgora

class AudioSystem {
    let audioEngine = SBAudioEngine()
    let audioGraph = SBAudioGraph()
    let agoraSourceNode: SBAgoraSourceNode
    let agoraSinkNode: SBAgoraSinkNode
    let multiChannelToMonoNode = SBMultiChannelToMonoNode()
    let agoraSourceResamplerNode = SBResamplerNode()
    let agoraSinkResamplerNode = SBResamplerNode()
    let monoToMultiChannelNode = SBMonoToMultiChannelNode()

    let roomManager: RoomManager
    var room: Room?

    init() {
        audioEngine.microphoneEnabled = true

        let api = SwitchboardAPI(baseURL: Config.switchboardAPIBaseURL)
        roomManager = RoomManager(switchboardAPI: api)
        agoraSourceNode = roomManager.sourceNode
        agoraSinkNode = roomManager.sinkNode

        agoraSourceResamplerNode.inputSampleRate = roomManager.audioBus.getSampleRate()
        agoraSinkResamplerNode.outputSampleRate = roomManager.audioBus.getSampleRate()

        audioGraph.addNode(agoraSourceNode)
        audioGraph.addNode(agoraSinkNode)
        audioGraph.addNode(multiChannelToMonoNode)
        audioGraph.addNode(agoraSourceResamplerNode)
        audioGraph.addNode(agoraSinkResamplerNode)
        audioGraph.addNode(monoToMultiChannelNode)

        audioGraph.connect(audioGraph.inputNode, to: multiChannelToMonoNode)
        audioGraph.connect(multiChannelToMonoNode, to: agoraSinkResamplerNode)
        audioGraph.connect(agoraSinkResamplerNode, to: agoraSinkNode)

        audioGraph.connect(agoraSourceNode, to: agoraSourceResamplerNode)
        audioGraph.connect(agoraSourceResamplerNode, to: monoToMultiChannelNode)
        audioGraph.connect(monoToMultiChannelNode, to: audioGraph.outputNode)
    }

    func start() {
        audioEngine.start(audioGraph)
    }

    func stop() {
        unpublish()
        unsubscribe()
        disconnect()
        audioEngine.stop()
    }

    func connect(name: String, roomID: String) {
        room = roomManager.createRoom(roomID: roomID)
        room?.delegate = self
        room?.join(userID: name)
    }

    func disconnect() {
        room?.leave()
    }

    func subscribe() {
        room?.subscribe()
    }

    func unsubscribe() {
        room?.unsubscribe()
    }

    func publish() {
        room?.publish()
    }

    func unpublish() {
        room?.unpublish()
    }
}

extension AudioSystem: RoomDelegate {
    func room(room _: SwitchboardAgora.Room, didUpdateConnectionState state: SwitchboardAgora.RoomConnectionState) {}

    func room(room _: SwitchboardAgora.Room, didFailToJoinWithError error: Error) {}

    func room(room _: SwitchboardAgora.Room, didFailToPublishWithError error: Error) {}

    func room(room _: SwitchboardAgora.Room, didFailToSubscribeWithError error: Error) {}

    func room(room _: SwitchboardAgora.Room, didUpdatePublisherVideoView _: UIView?) {}

    func room(room _: SwitchboardAgora.Room, didUpdateSubscriberVideoViews _: [SwitchboardAgora.SubscriberVideoView]) {}

    func room(room _: SwitchboardAgora.Room, didUpdatePublisherAudioLevel _: Float) {}

    func room(room _: SwitchboardAgora.Room, didUpdateSubscriberAudioLevel _: Float, forUser _: String?) {}

    func room(room _: SwitchboardAgora.Room, userDidJoin _: String) {}

    func room(room _: SwitchboardAgora.Room, userDidLeave _: String) {}

    func room(room _: SwitchboardAgora.Room, userDidMute _: String) {}

    func room(room _: SwitchboardAgora.Room, userDidUnmute _: String) {}

    func room(room _: SwitchboardAgora.Room, videoDidMute _: String) {}

    func room(room _: SwitchboardAgora.Room, videoDidUnmute _: String) {}

    func room(room _: SwitchboardAgora.Room, videoPublisherState _: Bool) {}
}
