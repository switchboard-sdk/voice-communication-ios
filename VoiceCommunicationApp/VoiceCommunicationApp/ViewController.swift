//
//  ViewController.swift
//  VoiceCommunicationApp
//
//  Created by Iván Nádor on 2023. 08. 15..
//

import UIKit
import SwitchboardAgora

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    let communicationSystem = CommunicationSystem()
    var audioSystem: AudioSystem!

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var roomNameField: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var loader: UIView!
    @IBOutlet weak var userList: UITableView!

    @IBOutlet weak var activeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        audioSystem = AudioSystem(roomManager: communicationSystem.roomManager)
        communicationSystem.delegate = self

        joinButton.isEnabled = false

        usernameField.delegate = self
        roomNameField.delegate = self

        userList.delegate = self
        userList.dataSource = self

        activeLabel.isHidden = true

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

    @IBAction func usernameEdited(_ sender: Any) {
        joinButton.isEnabled = checkIfCanJoin()
    }

    @IBAction func roomNameEdited(_ sender: Any) {
        joinButton.isEnabled = checkIfCanJoin()
    }

    @IBAction func joinTapped(_ sender: Any) {
        loader.isHidden = false

        if communicationSystem.joined {
            communicationSystem.leave()
        } else {
            communicationSystem.join(name: usernameField.text!, roomID: roomNameField.text!)
        }
    }

    func setJoinedState() {
        loader.isHidden = true
        usernameField.isEnabled = false
        roomNameField.isEnabled = false
        joinButton.setTitle("Leave", for: .normal)

        activeLabel.text = "Room \(roomNameField.text!) active"
        activeLabel.isHidden = false
    }

    func setLeftState() {
        loader.isHidden = true
        usernameField.isEnabled = true
        roomNameField.isEnabled = true
        joinButton.setTitle("Join", for: .normal)

        activeLabel.isHidden = true
    }

    func checkIfCanJoin() -> Bool {
        return usernameField.hasText && roomNameField.hasText
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return communicationSystem.users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserListTableViewCell") as! UserListTableViewCell
        cell.userLabel.text = communicationSystem.users[indexPath.row]
        return cell
    }
}

extension ViewController : CommunicationDelegate {
    func joined() {
        setJoinedState()
    }

    func left() {
        setLeftState()
    }

    func updatedUsers() {
        userList.reloadData()
    }

    func receivedError(_ error: Error) {
        setLeftState()
        let alertView = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertView, animated: true)
    }
}
