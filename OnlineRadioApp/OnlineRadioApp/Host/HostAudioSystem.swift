//
//  HostAudioSystem.swift
//  OnlineRadioApp
//
//  Created by Iván Nádor on 2023. 08. 29..
//

import SwitchboardSDK
import SwitchboardAgora

class HostAudioSystem {
    let audioEngine = SBAudioEngine()
    let audioGraph = SBAudioGraph()

    let agoraResampledSinkNode = SBResampledSinkNode()

    let musicPlayerNode = SBAudioPlayerNode()
    let effectsPlayerNode = SBAudioPlayerNode()
    let playerMixerNode = SBMixerNode()

    let inputSplitterNode = SBBusSplitterNode()
    let inputMultiChannelToMonoNode = SBMultiChannelToMonoNode()

    let musicDuckingNode = SBMusicDuckingNode()
    let duckingSplitterNode = SBBusSplitterNode()

    let agoraOutputMixerNode = SBMixerNode()
    let multiChannelToMonoNode = SBMultiChannelToMonoNode()

    var isPlaying: Bool {
        musicPlayerNode.isPlaying
    }

    init(roomManager: RoomManager) {
        audioEngine.microphoneEnabled = true
        audioEngine.voiceProcessingEnabled = true

        agoraResampledSinkNode.sinkNode = roomManager.sinkNode
        agoraResampledSinkNode.internalSampleRate = roomManager.audioBus.getSampleRate()

        let music = Bundle.main.url(forResource: "EMH-My_Lover", withExtension: "mp3")!
        let effect = Bundle.main.url(forResource: "airhorn", withExtension: "mp3")!

        musicPlayerNode.isLoopingEnabled = true
        musicPlayerNode.load(music.absoluteString, withFormat: .apple)
        effectsPlayerNode.load(effect.absoluteString, withFormat: .apple)

        audioGraph.addNode(agoraResampledSinkNode)
        audioGraph.addNode(musicPlayerNode)
        audioGraph.addNode(effectsPlayerNode)
        audioGraph.addNode(playerMixerNode)
        audioGraph.addNode(inputSplitterNode)
        audioGraph.addNode(inputMultiChannelToMonoNode)
        audioGraph.addNode(musicDuckingNode)
        audioGraph.addNode(duckingSplitterNode)
        audioGraph.addNode(agoraOutputMixerNode)
        audioGraph.addNode(multiChannelToMonoNode)

        audioGraph.connect(effectsPlayerNode, to: playerMixerNode)

        audioGraph.connect(musicPlayerNode, to: playerMixerNode)
        audioGraph.connect(playerMixerNode, to: musicDuckingNode)

        audioGraph.connect(audioGraph.inputNode, to: inputSplitterNode)
        audioGraph.connect(inputSplitterNode, to: inputMultiChannelToMonoNode)
        audioGraph.connect(inputMultiChannelToMonoNode, to: musicDuckingNode)

        audioGraph.connect(musicDuckingNode, to: duckingSplitterNode)

        audioGraph.connect(inputSplitterNode, to: agoraOutputMixerNode)
        audioGraph.connect(duckingSplitterNode, to: agoraOutputMixerNode)
        audioGraph.connect(agoraOutputMixerNode, to: multiChannelToMonoNode)
        audioGraph.connect(multiChannelToMonoNode, to: agoraResampledSinkNode)

        audioGraph.connect(duckingSplitterNode, to: audioGraph.outputNode)
    }

    func start() {
        audioEngine.start(audioGraph)
    }

    func stop() {
        audioEngine.stop()
    }

    func playMusic() {
        musicPlayerNode.play()
    }

    func pauseMusic() {
        musicPlayerNode.pause()
    }

    func playSoundEffect() {
        effectsPlayerNode.stop()
        effectsPlayerNode.play()
    }
}
