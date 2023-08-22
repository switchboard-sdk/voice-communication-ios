//
//  AudioSystem.swift
//  DuckingAndSoundEffectsApp
//
//  Created by Iván Nádor on 2023. 08. 16..
//

import SwitchboardSDK
import SwitchboardAgora

class AudioSystem {
    let audioEngine = SBAudioEngine()
    let audioGraph = SBAudioGraph()
    
    let agoraResampledSourceNode = SBResampledSourceNode()
    let agoraResampledSinkNode = SBResampledSinkNode()
    
    let musicPlayerNode = SBAudioPlayerNode()
    let effectsPlayerNode = SBAudioPlayerNode()
    let effectsSplitterNode = SBBusSplitterNode()
    let playerMixerNode = SBMixerNode()
    
    let inputSplitterNode = SBBusSplitterNode()
    let inputMultiChannelToMonoNode = SBMultiChannelToMonoNode()
    
    let monoToMultiChannelNode = SBMonoToMultiChannelNode()

    let musicDuckingNode = SBMusicDuckingNode()
    
    let agoraOutputMixerNode = SBMixerNode()
    let multiChannelToMonoNode = SBMultiChannelToMonoNode()
    
    let agoraSourceSplitterNode = SBBusSplitterNode()
    let speakerMixerNode = SBMixerNode()
    
    
    var isPlaying: Bool {
        musicPlayerNode.isPlaying
    }

    init(roomManager: RoomManager) {
        audioEngine.microphoneEnabled = true
        audioEngine.voiceProcessingEnabled = true

        agoraResampledSourceNode.sourceNode = roomManager.sourceNode
        agoraResampledSinkNode.sinkNode = roomManager.sinkNode
        
        agoraResampledSourceNode.internalSampleRate = roomManager.audioBus.getSampleRate()
        agoraResampledSinkNode.internalSampleRate = roomManager.audioBus.getSampleRate()
        
        let music = Bundle.main.url(forResource: "EMH-My_Lover", withExtension: "mp3")!
        let effect = Bundle.main.url(forResource: "airhorn", withExtension: "mp3")!
        
        musicPlayerNode.isLoopingEnabled = true
        musicPlayerNode.load(music.absoluteString, withFormat: .apple)
        effectsPlayerNode.load(effect.absoluteString, withFormat: .apple)
        
        audioGraph.addNode(agoraResampledSourceNode)
        audioGraph.addNode(agoraResampledSinkNode)
        audioGraph.addNode(musicPlayerNode)
        audioGraph.addNode(effectsPlayerNode)
        audioGraph.addNode(effectsSplitterNode)
        audioGraph.addNode(playerMixerNode)
        audioGraph.addNode(inputSplitterNode)
        audioGraph.addNode(inputMultiChannelToMonoNode)
        audioGraph.addNode(monoToMultiChannelNode)
        audioGraph.addNode(musicDuckingNode)
        audioGraph.addNode(agoraOutputMixerNode)
        audioGraph.addNode(multiChannelToMonoNode)
        audioGraph.addNode(agoraSourceSplitterNode)
        audioGraph.addNode(speakerMixerNode)
        
        audioGraph.connect(effectsPlayerNode, to: effectsSplitterNode)
        audioGraph.connect(effectsSplitterNode, to: playerMixerNode)
        
        audioGraph.connect(musicPlayerNode, to: playerMixerNode)
        audioGraph.connect(playerMixerNode, to: musicDuckingNode)

        audioGraph.connect(audioGraph.inputNode, to: inputSplitterNode)
        audioGraph.connect(inputSplitterNode, to: inputMultiChannelToMonoNode)
        audioGraph.connect(inputMultiChannelToMonoNode, to: musicDuckingNode)
        
        audioGraph.connect(inputSplitterNode, to: agoraOutputMixerNode)
        audioGraph.connect(effectsSplitterNode, to: agoraOutputMixerNode)
        audioGraph.connect(agoraOutputMixerNode, to: multiChannelToMonoNode)
        audioGraph.connect(multiChannelToMonoNode, to: agoraResampledSinkNode)
        
        audioGraph.connect(agoraResampledSourceNode, to: agoraSourceSplitterNode)
        audioGraph.connect(agoraSourceSplitterNode, to: musicDuckingNode)
        audioGraph.connect(agoraSourceSplitterNode, to: monoToMultiChannelNode)
        audioGraph.connect(monoToMultiChannelNode, to: speakerMixerNode)
        
        audioGraph.connect(musicDuckingNode, to: speakerMixerNode)
        audioGraph.connect(speakerMixerNode, to: audioGraph.outputNode)
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
