//
//  AudioSystem.swift
//  VoiceCommunicationApp
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
                    {"id": "monoToMultiChannelNode", "type": "MonoToMultiChannel"}
                ],
                "connections": [
                    {"sourceNode": "inputNode", "destinationNode": "multiChannelToMonoNode"},
                    {"sourceNode": "multiChannelToMonoNode", "destinationNode": "agoraResampledSinkNode"},
                    {"sourceNode": "agoraResampledSourceNode", "destinationNode": "monoToMultiChannelNode"},
                    {"sourceNode": "monoToMultiChannelNode", "destinationNode": "outputNode"}
                ]
            }
        }
    }
    """

    init() {
        let result = Switchboard.createEngine(withJSON: Self.graphJSON)
        guard result.success else {
            fatalError("Failed to create audio engine: \(result.error!)")
        }
        engineID = result.value! as String
    }

    func start() {
        Switchboard.callAction(withObject: engineID, actionName: "start", params: nil)
    }

    func stop() {
        Switchboard.callAction(withObject: engineID, actionName: "stop", params: nil)
    }
}
