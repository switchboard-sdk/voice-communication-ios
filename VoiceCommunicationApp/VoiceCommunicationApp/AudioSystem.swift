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

    init(roomManager: RoomManager) {
        audioEngine.microphoneEnabled = true

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
        audioEngine.stop()
    }
}
