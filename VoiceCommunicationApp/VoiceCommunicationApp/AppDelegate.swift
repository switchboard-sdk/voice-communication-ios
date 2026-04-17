//
//  AppDelegate.swift
//  VoiceCommunicationApp
//
//  Created by Iván Nádor on 2023. 08. 15..
//

import UIKit
import SwitchboardSDK
import SwitchboardAgora

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        SBAgoraExtension.loadExtension()
        let initConfig: [String: Any] = [
            "appID": Config.clientID,
            "appSecret": Config.clientSecret,
            "extensions": ["Agora": ["agoraAppID": Config.agoraAppID]],
        ]
        let result = Switchboard.initialize(withConfig: initConfig)
        guard result.success else {
            fatalError("Switchboard SDK initialization failed.")
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

