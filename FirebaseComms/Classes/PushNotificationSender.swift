//
//  PushNotificationSender.swift
//  FirebaseComms
//
//  Created by Peter Gao on 9/8/22.
//

import Foundation
import UIKit

class PushNotificationSender {
    func sendPushNotification(to token: String, title: String, body: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title, "body" : body]
//                                           "data" : ["user" : "test_id"]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let serverKey = "" //input server key here
        request.setValue("key=\(serverKey)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
    
    func push(emails: [String], title: String, body: String) {
        let group = DispatchGroup()
        var tokens: [String] = []
        for _ in emails {
            group.enter()
        }
        for email in emails {
            print("email \(email)")
            FirebaseManager.shared.firestore.collection("logins").document(email).getDocument { snapshot, error in
                if let error = error {
                    print("Failed to fetch current user: ", error)
                    return
                }
                
                let emailTokens = snapshot?.data()?["tokens"] as? [String] ?? []
                tokens.append(contentsOf: emailTokens)
                group.leave()
            }
        }
        group.notify(queue: .main) {
            for token in tokens {
                self.sendPushNotification(to: token, title: title, body: body)
            }
        }
    }
    
    func pushToFollowers(title: String, body: String) {
        guard let email = FirebaseManager.shared.auth.currentUser?.email else { return }
        FirebaseManager.shared.firestore.collection("connections").document(email).getDocument { snapshot, error in
            if let error = error {
                print("Failed to fetch current user: ", error)
                return
            }
            let followers = snapshot?.data()?["followers"] as? [String] ?? []
            self.push(emails: followers, title: title, body: body)
        }
    }
}
