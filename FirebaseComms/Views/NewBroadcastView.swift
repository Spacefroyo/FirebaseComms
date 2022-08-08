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
    @State var isEvent = false
    @State var name = ""
    @State var description = ""
    @State var startDate = Date()
    @State var endDate = Date()
    @State var location = ""
    @State var id = -1
    @AppStorage("view_Id") var view_Id = 2
    @State var from: ExpandedBroadcastView? = nil
    var body: some View {
        NavigationView {
            ScrollView {
                if id == -1 {
                    VStack (spacing: 16){
                        Picker(selection: $isEvent, label: Text("Picker here")) {
                            Text("Announcement")
                                .tag(false)
                            Text("Event")
                                .tag(true)
                        }.pickerStyle(SegmentedPickerStyle())
                    }
                    .padding()
                }
                
                if isEvent {
                    newEvent
                        .padding()
                } else {
                    newAnnouncement
                        .padding()
                }
                
                if id != -1 {
                    Button {
                        changeBroadcast(broadcast: Broadcast(data: ["id": id]))
                        from?.expand = false
                        from?.from?.expand = false
//                        group.notify(queue: .main) {
//                            from?.from?.from?.setBroadcastViews()
//                        }
                    } label: {
                        Text("Delete")
                    }
                }
            }
            .navigationTitle(isEvent ? "New Event" : "New Announcement")
                    .background(Color(.init(white: 0, alpha: 0.05))
                                                .ignoresSafeArea())
        }
    }
    
    private var newAnnouncement : some View {
        VStack (spacing: 16){
            TextField("Announcement", text: $name)
                .frame(height: 100, alignment: .top)
                .padding()
                .background(Color.white)
            
            Spacer()
            
            Button {
                storeBroadcastInformation(name: name)
                if id != -1 {
                    from?.expand = false
                    from?.from?.expand = false
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
                TextField("Description (Optional)", text: $description)
                    .frame(height: 100, alignment: .top)
            }
            .padding()
            .background(Color.white)
            
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
            
            DatePicker(
                "End Date",
                selection: $endDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            
            TextField("Location or Video Call Link", text: $location)
                .padding()
                .background(Color.white)
            
            Text("Attachments")
            
            Spacer()
            
            Button {
                storeBroadcastInformation(name: name, description: description, startDate: Timestamp(date: startDate), endDate: Timestamp(date: endDate), location: location)
                if id != -1 {
                    from?.expand = false
                    from?.from?.expand = false
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
            FirebaseManager.shared.firestore.collection("broadcasts")
                .document(email).collection("sent").document("\(id)").setData(announcement.data) { err in
                    if let err = err {
                        print(err)
                        return
                    }
                }
        } else {
            fetchId()
            group.notify(queue: .main) {
                let announcement = Broadcast(data: ["email": email, "id": id, "name": name, "timestamp": Timestamp()] as [String: Any])
                storeBroadcast(broadcast: announcement)
                FirebaseManager.shared.firestore.collection("broadcasts")
                    .document(email).collection("sent").document("\(id)").setData(announcement.data) { err in
                        if let err = err {
                            print(err)
                            return
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
            FirebaseManager.shared.firestore.collection("broadcasts")
                .document(email).collection("sent").document("\(id)").setData(event.data) { err in
                    if let err = err {
                        print(err)
                        return
                    }
                }
        } else {
            fetchId()
            group.notify(queue: .main) {
                let event = Broadcast(data: ["email": email, "id": id, "name": name, "description": description, "startDate": startDate, "endDate": endDate, "location": location, "timestamp": Timestamp()] as [String: Any])
                storeBroadcast(broadcast: event)
                FirebaseManager.shared.firestore.collection("broadcasts")
                    .document(email).collection("sent").document("\(id)").setData(event.data) { err in
                        if let err = err {
                            print(err)
                            return
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
        NewBroadcastView()
    }
}
