//
//  Broadcast.swift
//  FirebaseComms
//
//  Created by Peter Gao on 6/10/22.
//

import Firebase
import FirebaseFirestore

class Comment {
    var data: [String: Any]
    
    init(data: [String: Any]) {
        self.data = data
    }
    
    init(data: Data) {
        self.data = [:]
        self.data = fromData(data: data)
    }
    
    init(str: String) {
        self.data = [:]
        self.data = fromData(data: str.data(using: .utf8) ?? Data())
    }
    
    func fromData(data: Data) -> [String: Any] {
        guard let strData = try? JSONDecoder().decode([String:String].self, from: data ) else { return [:] }
        var ret : [String: Any] = [:]
        ret["email"] = strData["email"]
        ret["id"] = Int(strData["id"] ?? "")
        ret["name"] = strData["name"]
        let arr = strData["timestamp"]?.components(separatedBy: ";")
        ret["timestamp"] = Timestamp(seconds: Int64(arr?[0] ?? "") ?? 0, nanoseconds: Int32(arr?[1] ?? "") ?? 0)
        return ret
    }
    
    func toData() -> Data {
        var strData: [String: String] = data.mapValues { String(describing: $0) }
        let timestamp: Timestamp = (data["timestamp"] as! Timestamp)
        strData["timestamp"] = "\(timestamp.seconds);\(timestamp.nanoseconds)"
        guard let encodedBroadcast = try? JSONEncoder().encode(strData) else { return Data() }
        return encodedBroadcast
    }
    
    func toString() -> String {
        return String(data: toData(), encoding: .utf8) ?? ""
    }
}
