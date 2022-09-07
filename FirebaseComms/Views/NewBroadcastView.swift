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
    @State var newAttachment = ""
    @State var newAttachmentName = ""
    @State var attachments: [URL?] = []
    @State var attachmentNames: [String] = []
    @State var images: [UIImage] = []
    @State var image: UIImage?
    @State var presentImagePicker: Bool = false
    @State var id = -1
    @State var imageId = -1
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
            
            Text("Images")
            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    if !images.isEmpty {
                        ForEach(0..<images.count, id: \.self) { i in
                            VStack {
                                Image(uiImage: images[i])
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipped()
                                    .frame(height: 256)
                                
                                Button {
                                    images.remove(at: i)
                                } label: {
                                    Image(systemName: "x.circle.fill")
                                }
                            }
                        }
                    }
                    Button {
                        presentImagePicker = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .padding()
            .background(Color.theme.accent)
            .fullScreenCover(isPresented: $presentImagePicker) {
                ImagePicker(image: $image)
                    .ignoresSafeArea()
                    .onDisappear {
                        if let image = image {
                            images.append(image)
                            self.image = nil
                        }
                    }
            }
            
            Spacer()
            
            Button {
                if images.isEmpty {
                    storeBroadcastInformation(name: description, imageUrls: [])
                } else {
                    persistImageToStorage { imageUrls in
                        storeBroadcastInformation(name: description, imageUrls: imageUrls)
                    }
                }
                
                if id != -1 {
                    self.dismiss()
                }
//                view_Id = 0
            } label: {
                Text(loading ? "Uploading announcement... (Do not exit app)" : "Post Announcement")
            }
            .disabled(description == "")
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
            
            Group {
                Text("Images")
                ScrollView(.horizontal) {
                    HStack(spacing: 20) {
                        if !images.isEmpty {
                            ForEach(0..<images.count, id: \.self) { i in
                                VStack {
                                    Image(uiImage: images[i])
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipped()
                                        .frame(height: 256)
                                    
                                    Button {
                                        images.remove(at: i)
                                    } label: {
                                        Image(systemName: "x.circle.fill")
                                    }
                                }
                            }
                        }
                        Button {
                            presentImagePicker = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                }
                .padding()
                .background(Color.theme.accent)
                .fullScreenCover(isPresented: $presentImagePicker) {
                    ImagePicker(image: $image)
                        .ignoresSafeArea()
                        .onDisappear {
                            if let image = image {
                                images.append(image)
                                self.image = nil
                            }
                        }
                }
            }
            
            HStack {
                Text("Event Information")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding(.top)
            
            Group {
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
            }
            
            TextField("Location or Video Call Link", text: $location)
                .padding()
                .background(Color.theme.accent)
                .foregroundColor(Color.theme.foreground)
                .cornerRadius(15)
            
            Text("Attachments")
            Divider()
            VStack {
                if !attachments.isEmpty {
                    ForEach(0...attachments.count-1, id: \.self) { i in
                        VStack {
                            HStack {
                                Text(attachmentNames[i])
                                    .padding()
                                    .background(Color.theme.accent)
                                    .foregroundColor(Color.theme.foreground)
                                    .cornerRadius(15)
                                Spacer()
                                Button {
                                    attachmentNames.remove(at: i)
                                    attachments.remove(at: i)
                                } label: {
                                    Image(systemName: "x.circle.fill")
                                }
                            }
                            HStack {
                                Text("↳")
                                    .padding()
                                    .foregroundColor(Color.theme.accent)
                                Text(attachments[i]?.absoluteString ?? "URL Error")
                                    .padding()
                                    .background(Color.theme.accent)
                                    .foregroundColor(Color.theme.foreground)
                                    .cornerRadius(15)
                                Spacer()
                            }
                        }
                    }
                }
                    
                VStack {
                    HStack {
                        TextField("New Attachment Display Name", text: $newAttachmentName)
                            .padding()
                            .background(Color.theme.accent)
                            .foregroundColor(Color.theme.foreground)
                            .cornerRadius(15)
                        Button {
                            attachmentNames.append(newAttachmentName == "" ? newAttachment : newAttachmentName)
                            newAttachmentName = ""
                            attachments.append(URL(string: newAttachment))
                            newAttachment = ""
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                    HStack {
                        Text("↳")
                            .padding()
                            .foregroundColor(Color.theme.accent)
                        TextField("New Attachment Link", text: $newAttachment)
                            .padding()
                            .background(Color.theme.accent)
                            .foregroundColor(Color.theme.foreground)
                            .cornerRadius(15)
                    }
                }
            }
            
            Spacer()
            
            Button {
                if images.isEmpty {
                    storeBroadcastInformation(name: name, description: description, startDate: Timestamp(date: startDate), endDate: Timestamp(date: endDate), location: location, attachments: attachments, attachmentNames: attachmentNames, imageUrls: [])
                } else {
                    persistImageToStorage { imageUrls in
                        storeBroadcastInformation(name: name, description: description, startDate: Timestamp(date: startDate), endDate: Timestamp(date: endDate), location: location, attachments: attachments, attachmentNames: attachmentNames, imageUrls: imageUrls)
                    }
                }
                
                if id != -1 {
//                    from?.posted = true
                    self.dismiss()
//                    from?.expand = false
//                    from?.from?.expand = false
//                    group.notify(queue: .main) {
//                        from?.from?.from?.setBroadcastViews()
//                    }
                }
                
            } label: {
                Text(loading ? "Uploading event... (Do not exit app)" : "Post Event")
            }
            .disabled(name == "")
        }
    }
    
    @State var loading: Bool = false
    private func persistImageToStorage(after: @escaping ([String]) -> Void) {
        loading = true
        fetchImageId(increment: images.count)
        imageGroup.notify(queue: .main) {
            var imageUrls: [String] = []
            let urlGroup = DispatchGroup()
            for image in images {
                urlGroup.enter()
                let ref = FirebaseManager.shared.storage.reference(withPath: "\(imageId)")
                guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
                ref.putData(imageData, metadata: nil) { metadata, err in
                    if let err = err {
                        print("Failed to push image to Storage: \(err)")
                        return
                    }

                    ref.downloadURL { url, err in
                        if let err = err {
                            print("Failed to retrieve downloadURL: \(err)")
                            return
                        }
                        
                        imageUrls.append(url?.absoluteString ?? constants.defaultUrlString)
                        urlGroup.leave()
                    }
                }
                imageId += 1
            }
            urlGroup.notify(queue: .main) {
                after(imageUrls)
                loading = false
            }
        }
    }
    
    private func storeBroadcastInformation(name: String, imageUrls: [String]) {
//        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let email = FirebaseManager.shared.auth.currentUser?.email else { return }
        if id != -1 {
            let announcement = Broadcast(data: ["email": email, "id": id, "name": name, "images": imageUrls, "timestamp": Timestamp()] as [String: Any])
            changeBroadcast(broadcast: announcement)
            let document = FirebaseManager.shared.firestore.collection("broadcasts")
                .document(email).collection("sent").document("\(id)")
            document.setData(announcement.data) { err in
                if let err = err {
                    print(err)
                    return
                }
                view_Id = 0
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
                let announcement = Broadcast(data: ["email": email, "id": id, "name": name, "images": imageUrls, "timestamp": Timestamp()] as [String: Any])
                storeBroadcast(broadcast: announcement)
                let document = FirebaseManager.shared.firestore.collection("broadcasts")
                    .document(email).collection("sent").document("\(id)")
                document.setData(announcement.data) { err in
                    if let err = err {
                        print(err)
                        return
                    }
                    view_Id = 0
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
    
    private func storeBroadcastInformation(name: String, description: String, startDate: Timestamp, endDate: Timestamp, location: String, attachments: [URL?], attachmentNames: [String], imageUrls: [String]) {
//        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let email = FirebaseManager.shared.auth.currentUser?.email else { return }
        let attachments2 = attachments.filter { $0?.absoluteString ?? "" != "" }
        var attachments3: [String] = []
        for attachment in attachments2 {
            attachments3.append(attachment?.absoluteString ?? "")
        }
        if id != -1 {
            let event = Broadcast(data: ["email": email, "id": id, "name": name, "description": description, "startDate": startDate, "endDate": endDate, "location": location, "attachments": attachments3, "attachmentNames": attachmentNames, "images": imageUrls, "timestamp": Timestamp()] as [String: Any])
            changeBroadcast(broadcast: event)
            let document = FirebaseManager.shared.firestore.collection("broadcasts")
                .document(email).collection("sent").document("\(id)")
            document.setData(event.data) { err in
                if let err = err {
                    print(err)
                    return
                }
                view_Id = 0
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
                let event = Broadcast(data: ["email": email, "id": id, "name": name, "description": description, "startDate": startDate, "endDate": endDate, "location": location, "attachments": attachments3, "attachmentNames": attachmentNames, "images": imageUrls, "timestamp": Timestamp()] as [String: Any])
                storeBroadcast(broadcast: event)
                let document = FirebaseManager.shared.firestore.collection("broadcasts")
                    .document(email).collection("sent").document("\(id)")
                document.setData(event.data) { err in
                    if let err = err {
                        print(err)
                        return
                    }
                    view_Id = 0
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
    
    private let imageGroup = DispatchGroup()
    private func fetchImageId(increment: Int){
        imageGroup.enter()
        DispatchQueue.main.async {
            let document = FirebaseManager.shared.firestore.collection("data").document("imageId")
            document.getDocument { snapshot, error in
                if let error = error {
                    print("Failed to fetch broadcastId document: ", error)
                    return
                }
                
                guard let data = snapshot?.data() else {return}
                imageId = data["id"] as? Int ?? 0
                document.setData(["id": imageId+increment]) { err in
                    if let err = err {
                        print(err)
                        return
                    }
                    imageGroup.leave()
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
