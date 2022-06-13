//
//  TestView.swift
//  FirebaseComms
//
//  Created by Peter Gao on 6/10/22.
//

import SwiftUI
import FirebaseFirestore

struct TestView: View {
    let data = ["email": "testEmail", "id": -1, "name": "testName", "description": "testDescription", "startDate": Date(), "endDate": Date(), "location": "testLocation", "timestamp": Timestamp()] as [String: Any]
    
    var body: some View {
        VStack {
            Text("\(data.description)")
                .padding()
            
            Text("\(Broadcast(str: Broadcast(data: data).toString()).data.description)")
                .padding()
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
