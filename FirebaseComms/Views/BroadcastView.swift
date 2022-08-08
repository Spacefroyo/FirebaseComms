//
//  BroadcastView.swift
//  FirebaseComms
//
//  Created by Peter Gao on 6/10/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct BroadcastView: View, Identifiable {
    var id: Int
    
    var broadcast: Broadcast
    var data: [String: Any] //user data
    @State var expand: Bool = false
    @State var from: BroadcastsView? = nil
    
    var body: some View {
        Button {
            expand = true
        } label: {
            VStack {
                HStack(spacing:16) {
                    Image(uiImage: UIImage(data: try! Data(contentsOf: URL(string: data["profilePicUrl"] as? String ?? constants.defaultUrlString)!))!)
                        .resizable()
                        .clipped()
                        .frame(width: 32, height: 32)
                        .cornerRadius(16)
    //                    .padding(8)
                        .overlay(RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black, lineWidth: 1))
                        .padding(.leading)
    //                        .frame(width: 32, height: 32))
                    VStack(alignment:.leading){
                        Text(broadcast.data["name"] as? String ?? "Unknown Content")
                            .font(.system(size:16, weight:.bold))
                            .foregroundColor(Color.black)
                        Text("\(data["givenName"] as? String ?? "Anon") \(data["familyName"] as? String ?? "Anon")")
                            .font(.system(size:14))
                            .foregroundColor(Color(.lightGray))
                    }
                    Spacer()
                    
                    HStack{
                        Circle()
                            .foregroundColor(.red)
                            .frame(width:12, height:12)
                        Text(utils.timeSince(timestamp:broadcast.data["timestamp"] as? Timestamp ?? Timestamp()))
                            .font(.system(size:14, weight:.semibold))
                            .foregroundColor(Color.black)
                            .padding(.trailing)
                    }
                }
                Divider()
                    .padding(.vertical, 8)
            }
        }
        .fullScreenCover(isPresented: $expand) {
            Button {
                expand = false
            } label: {
                Text("< Back")
            }
            
            ExpandedBroadcastView(id: id, broadcast: broadcast, from: self)
        }
    }
}

//struct BroadcastView_Previews: PreviewProvider {
//    static var previews: some View {
//        BroadcastView()
//    }
//}
