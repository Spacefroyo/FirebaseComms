//
//  NewAnnouncementView.swift
//  FirebaseComms
//
//  Created by Peter Gao on 6/7/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct NewBroadcastView: View {
    @State var broadcastType = "announcement"
    @State var name = ""
    @State var description = ""
    @State var startDate = Date()
    @State var endDate = Date().addingTimeInterval(2 * 60 * 60)
    @State var location = ""
    @State var id = -1
    @AppStorage("view_Id") var view_Id = 2
    @State var from: ExpandedBroadcastView? = nil
    @Environment(\.dismiss) private var dismiss
    @State var posted: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()
                ScrollView {
                    if id == -1 {
                        VStack (spacing: 16){
                            Picker(selection: $broadcastType, label: Text("Picker here")) {
                                Text("Announcement")
//                                    .foregroundColor(Color.theme.foreground)
                                    .tag("announcement")
                                Text("Event")
//                                    .foregroundColor(Color.theme.foreground)
                                    .tag("event")
                            }.pickerStyle(SegmentedPickerStyle())
//                                .foregroundColor(Color.theme.accent)
                        }
                        .padding()
                    }
                    
                    switch broadcastType {
                    case "announcement":
                        newAnnouncement
                            .padding()
                    case "event":
                        newEvent
                            .padding()
                    default:
                        Text("Unrecognized broadcast type")
                            .font(.system(size:24, weight:.bold))
                            .foregroundColor(Color.red)
                            .padding([.leading, .trailing, .bottom])
                    }
//                    if isEvent {
//                        newEvent
//                            .padding()
//                    } else {
//                        newAnnouncement
//                            .padding()
//                    }
                    
                    if id != -1 {
                        Button {
                            changeBroadcast(broadcast: Broadcast(data: ["id": id]))
                            from?.posted = true
                            self.dismiss()
//                            from?.from?.expand = false
    //                        group.notify(queue: .main) {
    //                            from?.from?.from?.setBroadcastViews()
    //                        }
                        } label: {
                            Text("Delete")
                                .foregroundColor(Color.red)
                        }
                    }
                }
                .navigationTitle("New \(broadcastType.capitalized)")
                .foregroundColor(Color.theme.foreground)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        id != -1 ? BackButtonView(dismiss: self.dismiss) : nil
                    }
                }
            }
        }
    }
    
    private var newAnnouncement : some View {
        VStack (spacing: 16){
            ZStack (alignment: .topLeading){
                
                
                Text("Announcement")
                    .foregroundColor(Color.theme.foreground)
//                    .padding(.leading, 18)
                    .padding()
                    .opacity(description == "" ? 0.4 : 0)
                
                TextEditor(text: $description)
//                        .lineLimit(5)
                    .frame(height: 100, alignment: .top)
                    .padding([.leading, .trailing], 11)
                    .padding([.top, .bottom], 8)
                    
            }
            .background(Color.theme.accent)
//                    .foregroundColor(Color.theme.foreground)
            .cornerRadius(15)
//            .padding()
//            TextField("Announcement", text: $name)
//                .frame(height: 100, alignment: .top)
//                .padding()
//                .background(Color.theme.accent)
//                .foregroundColor(Color.theme.foreground)
//                .cornerRadius(15)
            
            Spacer()
            
            Button {
                storeBroadcastInformation(name: name)
                if id != -1 {
//                    from?.posted = true
                    self.dismiss()
//                    from?.expand = false
//                    from?.from?.expand = false
//                    group.notify(queue: .main) {
//                        from?.from?.from?.setBroadcastViews()
//                    }
                }
                view_Id = 0
            } label: {
                Text("Post Announcement")
            }
        }
    }
    
    private var newEvent : some View {
        VStack (spacing: 16){
            Group {
                TextField("Event Name", text: $name)
                    .padding()
//                TextField("Description (Optional)", text: $description)
//                    .frame(height: 100, alignment: .top)
                
                ZStack (alignment: .topLeading){
                    Text("Description (Optional)")
                        .foregroundColor(Color.theme.foreground)
//                        .padding(.leading, 18)
                        .opacity(description == "" ? 0.4 : 0)
                        .padding()
                    
                    TextEditor(text: $description)
//                        .lineLimit(5)
                        .padding([.leading, .trailing], 11)
                        .padding([.top, .bottom], 8)
                        .frame(height: 100, alignment: .top)
                }
            }
            
            .background(Color.theme.accent)
            .foregroundColor(Color.theme.foreground)
            .cornerRadius(15)
            
            HStack {
                Text("Event Information")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding(.top)
            
            DatePicker(
                "Start Date",
                selection: $startDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            .colorMultiply(Color.theme.foreground)
            .foregroundColor(Color.theme.foreground)
            
            
            DatePicker(
                "End Date",
                selection: $endDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            .colorMultiply(Color.theme.foreground)
            .foregroundColor(Color.theme.foreground)
            
            
            TextField("Location or Video Call Link", text: $location)
                .padding()
                .background(Color.theme.accent)
                .foregroundColor(Color.theme.foreground)
                .cornerRadius(15)
            
            Text("Attachments")
            
            Spacer()
            
            Button {
                storeBroadcastInformation(name: name, description: description, startDate: Timestamp(date: startDate), endDate: Timestamp(date: endDate), location: location)
                if id != -1 {
//                    from?.posted = true
                    self.dismiss()
//                    from?.expand = false
//                    from?.from?.expand = false
//                    group.notify(queue: .main) {
//                        from?.from?.from?.setBroadcastViews()
//                    }
                }
                view_Id = 0
            } label: {
                Text("Post Event")
            }
        }
    }
    
    private func storeBroadcastInformation(name: String) {
//        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let email = FirebaseManager.shared.auth.currentUser?.email else { return }
        if id != -1 {
            let announcement = Broadcast(data: ["email": email, "id": id, "name": name, "timestamp": Timestamp()] as [String: Any])
            changeBroadcast(broadcast: announcement)
            let document = FirebaseManager.shared.firestore.collection("broadcasts")
                .document(email).collection("sent").document("\(id)")
            document.setData(announcement.data) { err in
                if let err = err {
                    print(err)
                    return
                }
            }
            FirebaseManager.shared.firestore.collection("connections").document(email).getDocument { snapshot, error in
                if let error = error {
                    print("Failed to fetch current user: ", error)
                    return
                }
                let followers = snapshot?.data()?["followers"] as? [String] ?? []
                for follower in followers {
                    document.collection("privateChannels").document(follower).setData(["read": false], merge: true)
                }
            }
            from?.broadcast = announcement
        } else {
            fetchId()
            group.notify(queue: .main) {
                let announcement = Broadcast(data: ["email": email, "id": id, "name": name, "timestamp": Timestamp()] as [String: Any])
                storeBroadcast(broadcast: announcement)
                let document = FirebaseManager.shared.firestore.collection("broadcasts")
                    .document(email).collection("sent").document("\(id)")
                document.setData(announcement.data) { err in
                    if let err = err {
                        print(err)
                        return
                    }
                }
                FirebaseManager.shared.firestore.collection("connections").document(email).getDocument { snapshot, error in
                    if let error = error {
                        print("Failed to fetch current user: ", error)
                        return
                    }
                    let followers = snapshot?.data()?["followers"] as? [String] ?? []
                    for follower in followers {
                        document.collection("privateChannels").document(follower).setData(["read": false, "commentsReadBySender": true, "commentsReadByReceiver": true])
                    }
                }
            }
        }
    }
    
    private func storeBroadcastInformation(name: String, description: String, startDate: Timestamp, endDate: Timestamp, location: String) {
//        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let email = FirebaseManager.shared.auth.currentUser?.email else { return }
        if id != -1 {
            let event = Broadcast(data: ["email": email, "id": id, "name": name, "description": description, "startDate": startDate, "endDate": endDate, "location": location, "timestamp": Timestamp()] as [String: Any])
            changeBroadcast(broadcast: event)
            let document = FirebaseManager.shared.firestore.collection("broadcasts")
                .document(email).collection("sent").document("\(id)")
            document.setData(event.data) { err in
                if let err = err {
                    print(err)
                    return
                }
            }
            FirebaseManager.shared.firestore.collection("connections").document(email).getDocument { snapshot, error in
                if let error = error {
                    print("Failed to fetch current user: ", error)
                    return
                }
                let followers = snapshot?.data()?["followers"] as? [String] ?? []
                for follower in followers {
                    document.collection("privateChannels").document(follower).setData(["read": false], merge: true)
                }
            }
            from?.broadcast = event
        } else {
            fetchId()
            group.notify(queue: .main) {
                let event = Broadcast(data: ["email": email, "id": id, "name": name, "description": description, "startDate": startDate, "endDate": endDate, "location": location, "timestamp": Timestamp()] as [String: Any])
                storeBroadcast(broadcast: event)
                let document = FirebaseManager.shared.firestore.collection("broadcasts")
                    .document(email).collection("sent").document("\(id)")
                document.setData(event.data) { err in
                    if let err = err {
                        print(err)
                        return
                    }
                }
                FirebaseManager.shared.firestore.collection("connections").document(email).getDocument { snapshot, error in
                    if let error = error {
                        print("Failed to fetch current user: ", error)
                        return
                    }
                    let followers = snapshot?.data()?["followers"] as? [String] ?? []
                    for follower in followers {
                        document.collection("privateChannels").document(follower).setData(["attendance": 0, "read": false, "commentsReadBySender": true, "commentsReadByReceiver": true])
                    }
                }
            }
        }
    }
    
    private let group = DispatchGroup()
    private func fetchId(){
        group.enter()
        DispatchQueue.main.async {
//            if id != -1 {
//                group.leave()
//                return
//            }
            let document = FirebaseManager.shared.firestore.collection("data").document("broadcastId")
            document.getDocument { snapshot, error in
                if let error = error {
                    print("Failed to fetch broadcastId document: ", error)
                    return
                }
                
                guard let data = snapshot?.data() else {return}
                id = data["id"] as? Int ?? 0
                document.setData(["id": id+1]) { err in
                    if let err = err {
                        print(err)
                        return
                    }
                    group.leave()
                }
                
            }
        }
    }
    
    @AppStorage("sentBroadcasts") var sentBroadcasts: String?
    private func storeBroadcast(broadcast: Broadcast) {
        sentBroadcasts = "\(broadcast.toString())~\(sentBroadcasts ?? "")"
    }
    
    private func changeBroadcast(broadcast: Broadcast) {
        let arr: [String] = sentBroadcasts?.components(separatedBy: constants.seperator) ?? []
        var loadedSentBroadcasts: [Broadcast] = []
        for str in arr {
            if !str.isEmpty {
                let thisBroadcast: Broadcast = Broadcast(str: str)
                if thisBroadcast.data["id"] as? Int ?? -1 == broadcast.data["id"] as? Int ?? -1 {
                    if broadcast.data.count != 1 {
                        loadedSentBroadcasts.append(broadcast)
                    }
                } else {
                    loadedSentBroadcasts.append(thisBroadcast)
                }
            }
        }
        if broadcast.data.count == 1 {
            deleteBroadcast(broadcast: broadcast)
        }
//        loadedSentBroadcasts[broadcast.data["id"] as? Int ?? 0] = broadcast
        sentBroadcasts = ""
        for broadcast in loadedSentBroadcasts {
            storeBroadcast(broadcast: broadcast)
        }
    }
    
    func deleteBroadcast(broadcast: Broadcast) {
        let email = FirebaseManager.shared.auth.currentUser?.email ?? ""
        FirebaseManager.shared.firestore.collection("broadcasts")
            .document(email).collection("sent").document("\(id)").delete() { err in
                if let err = err {
                    print(err)
                    return
                }
            }
    }
}

struct NewAnnouncementView_Previews: PreviewProvider {
    static var previews: some View {
        NewBroadcastView(broadcastType: "event").preferredColorScheme(.dark)
    }
}
