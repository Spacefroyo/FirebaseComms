//
//  Broadcast.swift
//  FirebaseComms
//
//  Created by Peter Gao on 6/10/22.
//

import Firebase
import FirebaseFirestore

class Broadcast {
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
        let arr4 = strData["images"]?.components(separatedBy: " ")
        var tempArr3: [String] = []
        for str in arr4! {
            if str != "" {
                tempArr3.append(str)
            }
        }
        ret["images"] = tempArr3
        if strData.count != 5 {
            ret["description"] = strData["description"]
            let arr1 = strData["startDate"]?.components(separatedBy: ";")
            ret["startDate"] = Timestamp(seconds: Int64(arr1?[0] ?? "") ?? 0, nanoseconds: Int32(arr1?[1] ?? "") ?? 0)
//            ret["startDate"] = ISO8601DateFormatter().date(from:strData["startDate"] ?? "") ?? Date()
            let arr2 = strData["endDate"]?.components(separatedBy: ";")
            ret["endDate"] = Timestamp(seconds: Int64(arr2?[0] ?? "") ?? 0, nanoseconds: Int32(arr2?[1] ?? "") ?? 0)
//            ret["endDate"] = ISO8601DateFormatter().date(from:strData["endDate"] ?? "") ?? Date()
            ret["location"] = strData["location"]
            let arr3 = strData["attachments"]?.components(separatedBy: " ")
            var tempArr: [String] = []
            for str in arr3! {
                if str != "" {
                    tempArr.append(str)
                }
            }
            ret["attachments"] = tempArr
            var tempArr2: [String] = []
            if !tempArr.isEmpty {
                for i in 0...tempArr.count-1 {
                    tempArr2.append(strData["attachmentNames\(i)"] ?? "")
                }
            }
            ret["attachmentNames"] = tempArr2
//            print(ret.description)
//            print(strData.description)
        }
        return ret
    }
    
    func toData() -> Data {
        var strData: [String: String] = data.mapValues { String(describing: $0) }
        let timestamp: Timestamp = (data["timestamp"] as! Timestamp)
        strData["timestamp"] = "\(timestamp.seconds);\(timestamp.nanoseconds)"
        let images = data["images"] as? [String] ?? []
        var concat2 = ""
        for image in images {
            concat2 += "\(image) "
        }
        strData["images"] = concat2
        if strData.count != 5 {
            let startDate: Timestamp = (data["startDate"] as! Timestamp)
            strData["startDate"] = "\(startDate.seconds);\(startDate.nanoseconds)"
            let endDate: Timestamp = (data["endDate"] as! Timestamp)
            strData["endDate"] = "\(endDate.seconds);\(endDate.nanoseconds)"
            let attachments = data["attachments"] as? [String] ?? []
            var concat = ""
            for attachment in attachments {
                concat += "\(attachment) "
            }
            strData["attachments"] = concat
            let arr = data["attachmentNames"] as? [String] ?? []
            if !arr.isEmpty {
                for i in 0...arr.count-1 {
                    strData["attachmentNames\(i)"] = arr[i]
                }
            }
        }
        guard let encodedBroadcast = try? JSONEncoder().encode(strData) else { return Data() }
        return encodedBroadcast
    }
    
    func toString() -> String {
        return String(data: toData(), encoding: .utf8) ?? ""
    }
}
//
//class Announcement: Broadcast {
//    init(uid: String, id: Int, name: String, timestamp: Timestamp) {
//        super.init(data: ["uid": uid, "id": id, "name": name, "timestamp": timestamp])
//    }
//}
