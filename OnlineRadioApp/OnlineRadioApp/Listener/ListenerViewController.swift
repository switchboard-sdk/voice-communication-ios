//
//  ListenerViewController.swift
//  OnlineRadioApp
//
//  Created by Iván Nádor on 2023. 08. 29..
//

import UIKit

class ListenerViewController: UIViewController, UITextFieldDelegate {
    let communicationSystem = CommunicationSystem(isHost: false)
    var audioSystem: ListenerAudioSystem!

    @IBOutlet weak var channelNameField: UITextField!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var channelActiveLabel: UILabel!
    @IBOutlet weak var loader: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        audioSystem = ListenerAudioSystem(roomManager: communicationSystem.roomManager)
        communicationSystem.delegate = self

        actionButton.isEnabled = false
        channelNameField.delegate = self
        channelActiveLabel.isHidden = true

        audioSystem.start()
    }

    deinit {
        communicationSystem.leave()
        audioSystem.stop()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func channelNameEdited(_ sender: Any) {
        actionButton.isEnabled = checkIfCanJoin()
    }

    @IBAction func actionButtonTapped(_ sender: Any) {
        loader.isHidden = false

        if communicationSystem.joined {
            communicationSystem.leave()
        } else {
            communicationSystem.join(name: "listener-\(Int.random(in: 1 ... 1000))", roomID: channelNameField.text!)
        }
    }

    func setJoinedState() {
        loader.isHidden = true
        channelNameField.isEnabled = false
        actionButton.setTitle("Stop", for: .normal)

        channelActiveLabel.text = "Listening to channel \(channelNameField.text!)"
        channelActiveLabel.isHidden = false
    }

    func setLeftState() {
        loader.isHidden = true
        channelNameField.isEnabled = false
        actionButton.setTitle("Listen", for: .normal)

        channelActiveLabel.isHidden = true
    }

    func checkIfCanJoin() -> Bool {
        return channelNameField.hasText
    }
}

extension ListenerViewController : CommunicationDelegate {
    func joined() {
        setJoinedState()
    }

    func left() {
        setLeftState()
    }

    func receivedError(_ error: Error) {
        setLeftState()
        let alertView = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertView, animated: true)
    }
}
