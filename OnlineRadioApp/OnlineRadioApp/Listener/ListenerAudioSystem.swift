//
//  ListenerAudioSystem.swift
//  OnlineRadioApp
//
//  Created by Iván Nádor on 2023. 08. 29..
//

import SwitchboardSDK
import SwitchboardAgora

class ListenerAudioSystem {
    var engineID: String = ""

    private static let graphJSON = """
    {
        "type": "Realtime",
        "config": {
            "graph": {
                "nodes": [
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
