//
//  Broadcast.swift
//  FirebaseComms
//
//  Created by Peter Gao on 6/10/22.
//

//import Firebase
//import FirebaseFirestore
//
//class User {
//    var data: [String: Any]
//
//    init(data: [String: Any]) {
//        self.data = data
//    }
//
//    init(data: Data) {
//        self.data = [:]
//        self.data = fromData(data: data)
//    }
//
//    init(str: String) {
//        self.data = [:]
//        self.data = fromData(data: str.data(using: .utf8) ?? Data())
//    }
//
//    func fromData(data: Data) -> [String: Any] {
//        guard let strData = try? JSONDecoder().decode([String:String].self, from: data ) else { return [:] }
//        var ret : [String: Any] = [:]
//        ret["email"] = strData["email"]
//        ret["givenName"] = strData["givenName"]
//        ret["familyName"] = strData["familyName"]
//        ret["profilePicUrl"] = URL(string: strData["profilePicUrl"] ?? "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/976px-Apple_logo_black.svg.png?20211218170823")
//        return ret
//    }
//
//    func toData() -> Data {
//        let strData: [String: String] = data.mapValues { String(describing: $0) }
//        guard let encodedBroadcast = try? JSONEncoder().encode(strData) else { return Data() }
//        return encodedBroadcast
//    }
//
//    func toString() -> String {
//        return String(data: toData(), encoding: .utf8) ?? ""
//    }
//}
