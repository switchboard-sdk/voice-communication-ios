//
//  ListenerAudioSystem.swift
//  OnlineRadioApp
//
//  Created by Iván Nádor on 2023. 08. 29..
//

import SwitchboardSDK
import SwitchboardAgora

class ListenerAudioSystem {
    let audioEngine = SBAudioEngine()
    let audioGraph = SBAudioGraph()
    let agoraResampledSourceNode = SBResampledSourceNode()
    let monoToMultiChannelNode = SBMonoToMultiChannelNode()

    init(roomManager: RoomManager) {
        agoraResampledSourceNode.sourceNode = roomManager.sourceNode
        agoraResampledSourceNode.internalSampleRate = roomManager.audioBus.getSampleRate()

        audioGraph.addNode(agoraResampledSourceNode)
        audioGraph.addNode(monoToMultiChannelNode)

        audioGraph.connect(agoraResampledSourceNode, to: monoToMultiChannelNode)
        audioGraph.connect(monoToMultiChannelNode, to: audioGraph.outputNode)
    }

    func start() {
        audioEngine.start(audioGraph)
    }

    func stop() {
        audioEngine.stop()
    }
}
