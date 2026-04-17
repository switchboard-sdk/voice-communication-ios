//
//  AudioSystem.swift
//  DuckingAndSoundEffectsApp
//
//  Created by Iván Nádor on 2023. 08. 16..
//

import SwitchboardSDK
import SwitchboardAgora

class AudioSystem {
    var engineID: String = ""

    private static let graphJSON = """
    {
        "type": "Realtime",
        "config": {
            "microphoneEnabled": true,
            "voiceProcessingEnabled": true,
            "graph": {
                "nodes": [
                    {"id": "musicPlayerNode", "type": "AudioPlayer"},
                    {"id": "effectsPlayerNode", "type": "AudioPlayer"},
                    {"id": "effectsSplitterNode", "type": "BusSplitter"},
                    {"id": "playerMixerNode", "type": "Mixer"},
                    {"id": "inputSplitterNode", "type": "BusSplitter"},
                    {"id": "inputMultiChannelToMonoNode", "type": "MultiChannelToMono"},
                    {"id": "duckingSignalMixerNode", "type": "Mixer"},
                    {"id": "musicDuckingNode", "type": "MusicDucking"},
                    {"id": "agoraOutputMixerNode", "type": "Mixer"},
                    {"id": "multiChannelToMonoNode", "type": "MultiChannelToMono"},
                    {
                        "id": "agoraResampledSinkNode",
                        "type": "ResampledSink",
                        "config": {
                            "sampleRate": 48000,
                            "node": {
                                "id": "agoraSinkNode",
                                "type": "Agora.Sink"
                            }
                        }
                    },
                    {
                        "id": "agoraResampledSourceNode",
                        "type": "ResampledSource",
                        "config": {
                            "sampleRate": 48000,
                            "node": {
                                "id": "agoraSourceNode",
                                "type": "Agora.Source"
                            }
                        }
                    },
                    {"id": "agoraSourceSplitterNode", "type": "BusSplitter"},
                    {"id": "monoToMultiChannelNode", "type": "MonoToMultiChannel"},
                    {"id": "speakerMixerNode", "type": "Mixer"}
                ],
                "connections": [
                    {"sourceNode": "effectsPlayerNode", "destinationNode": "effectsSplitterNode"},
                    {"sourceNode": "effectsSplitterNode", "destinationNode": "playerMixerNode"},
                    {"sourceNode": "musicPlayerNode", "destinationNode": "playerMixerNode"},
                    {"sourceNode": "playerMixerNode", "destinationNode": "musicDuckingNode"},
                    {"sourceNode": "inputNode", "destinationNode": "inputSplitterNode"},
                    {"sourceNode": "inputSplitterNode", "destinationNode": "inputMultiChannelToMonoNode"},
                    {"sourceNode": "inputMultiChannelToMonoNode", "destinationNode": "duckingSignalMixerNode"},
                    {"sourceNode": "duckingSignalMixerNode", "destinationNode": "musicDuckingNode"},
                    {"sourceNode": "inputSplitterNode", "destinationNode": "agoraOutputMixerNode"},
                    {"sourceNode": "effectsSplitterNode", "destinationNode": "agoraOutputMixerNode"},
                    {"sourceNode": "agoraOutputMixerNode", "destinationNode": "multiChannelToMonoNode"},
                    {"sourceNode": "multiChannelToMonoNode", "destinationNode": "agoraResampledSinkNode"},
                    {"sourceNode": "agoraResampledSourceNode", "destinationNode": "agoraSourceSplitterNode"},
                    {"sourceNode": "agoraSourceSplitterNode", "destinationNode": "duckingSignalMixerNode"},
                    {"sourceNode": "agoraSourceSplitterNode", "destinationNode": "monoToMultiChannelNode"},
                    {"sourceNode": "monoToMultiChannelNode", "destinationNode": "speakerMixerNode"},
                    {"sourceNode": "musicDuckingNode", "destinationNode": "speakerMixerNode"},
                    {"sourceNode": "speakerMixerNode", "destinationNode": "outputNode"}
                ]
            }
        }
    }
    """

    var isPlaying: Bool {
        Switchboard.getValueForKey("isPlaying", object: "musicPlayerNode").value as? Bool ?? false
    }

    init() {
        let result = Switchboard.createEngine(withJSON: Self.graphJSON)
        guard result.success else {
            fatalError("Failed to create audio engine: \(result.error!)")
        }
        engineID = result.value! as String

        let music = Bundle.main.url(forResource: "EMH-My_Lover", withExtension: "mp3")!
        let effect = Bundle.main.url(forResource: "airhorn", withExtension: "mp3")!

        Switchboard.setValue(true, forKey: "isLoopingEnabled", onObject: "musicPlayerNode")
        Switchboard.callAction(withObject: "musicPlayerNode", actionName: "load", params: ["audioFilePath": music.absoluteString, "codec": "apple"])
        Switchboard.callAction(withObject: "effectsPlayerNode", actionName: "load", params: ["audioFilePath": effect.absoluteString, "codec": "apple"])
    }

    func start() {
        Switchboard.callAction(withObject: engineID, actionName: "start", params: nil)
    }

    func stop() {
        Switchboard.callAction(withObject: engineID, actionName: "stop", params: nil)
    }

    func playMusic() {
        Switchboard.callAction(withObject: "musicPlayerNode", actionName: "play", params: nil)
    }

    func pauseMusic() {
        Switchboard.callAction(withObject: "musicPlayerNode", actionName: "pause", params: nil)
    }

    func playSoundEffect() {
        Switchboard.callAction(withObject: "effectsPlayerNode", actionName: "stop", params: nil)
        Switchboard.callAction(withObject: "effectsPlayerNode", actionName: "play", params: nil)
    }
}
