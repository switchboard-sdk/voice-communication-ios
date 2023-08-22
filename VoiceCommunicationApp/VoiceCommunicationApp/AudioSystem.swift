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
    let multiChannelToMonoNode = SBMultiChannelToMonoNode()
    let agoraResampledSourceNode = SBResampledSourceNode()
    let agoraResampledSinkNode = SBResampledSinkNode()
    let monoToMultiChannelNode = SBMonoToMultiChannelNode()

    init(roomManager: RoomManager) {
        audioEngine.microphoneEnabled = true
        audioEngine.voiceProcessingEnabled = true

        agoraResampledSourceNode.sourceNode = roomManager.sourceNode
        agoraResampledSinkNode.sinkNode = roomManager.sinkNode
        
        agoraResampledSourceNode.internalSampleRate = roomManager.audioBus.getSampleRate()
        agoraResampledSinkNode.internalSampleRate = roomManager.audioBus.getSampleRate()

        audioGraph.addNode(multiChannelToMonoNode)
        audioGraph.addNode(agoraResampledSourceNode)
        audioGraph.addNode(agoraResampledSinkNode)
        audioGraph.addNode(monoToMultiChannelNode)

        audioGraph.connect(audioGraph.inputNode, to: multiChannelToMonoNode)
        audioGraph.connect(multiChannelToMonoNode, to: agoraResampledSinkNode)

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
