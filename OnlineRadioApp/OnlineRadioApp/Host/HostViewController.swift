//
//  HostViewController.swift
//  OnlineRadioApp
//
//  Created by Iván Nádor on 2023. 08. 29..
//

import UIKit

class HostViewController: UIViewController, UITextFieldDelegate {
    let communicationSystem = CommunicationSystem(isHost: true)
    var audioSystem: HostAudioSystem!

    @IBOutlet weak var channelNameField: UITextField!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var channelActiveLabel: UILabel!
    @IBOutlet weak var musicButton: UIButton!
    @IBOutlet weak var loader: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        audioSystem = HostAudioSystem(roomManager: communicationSystem.roomManager)
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
            communicationSystem.join(name: "host", roomID: channelNameField.text!)
        }
    }

    func setJoinedState() {
        loader.isHidden = true
        channelNameField.isEnabled = false
        actionButton.setTitle("Stop Broadcast", for: .normal)

        channelActiveLabel.text = "Broadcasting in channel \(channelNameField.text!)"
        channelActiveLabel.isHidden = false
    }

    func setLeftState() {
        loader.isHidden = true
        channelNameField.isEnabled = false
        actionButton.setTitle("Start Broadcast", for: .normal)

        channelActiveLabel.isHidden = true
    }

    func checkIfCanJoin() -> Bool {
        return channelNameField.hasText
    }

    @IBAction func musicButtonTapped(_ sender: Any) {
        if (audioSystem.isPlaying) {
            audioSystem.pauseMusic()
            musicButton.setTitle("Play Music", for: .normal)
        } else {
            audioSystem.playMusic()
            musicButton.setTitle("Pause Music", for: .normal)
        }
    }

    @IBAction func soundEffectButtonTapped(_ sender: Any) {
        audioSystem.playSoundEffect()
    }
}

extension HostViewController : CommunicationDelegate {
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
