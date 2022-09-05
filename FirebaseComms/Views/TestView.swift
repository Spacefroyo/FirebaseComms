//
//  TestView.swift
//  FirebaseComms
//
//  Created by Peter Gao on 9/1/22.
//

import SwiftUI

struct TestView: View {
    @State var _public: Bool = true
    var body: some View {
        VStack {
            Picker(selection: $_public, label: Text("Picker here")) {
                Text("Public")
                    .tag(true)
                HStack {
                    Text("Private")
                    Image(systemName: "a.circle.fill")
                    
                    //Circle doesn't show up
                    Circle()
                        .foregroundColor(.red)
                        .frame(width:12, height:12)
                }
                .tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Text("public: \(_public.description)")
            
            HStack {
                Text("Private")
                
                //Circle shows up here
                Circle()
                    .foregroundColor(.red)
                    .frame(width:12, height:12)
            }
        }
    }
    
    
//    @Environment(\.dismiss) private var dismiss
//
//    @State var _public: Bool = true
//    @State var commentString: String = ""
//    var body: some View {
//        VStack {
////            VStack {
//            HStack {
//                ZStack (alignment: .topLeading){
//                    Text("Add Private Comment")
//                        .foregroundColor(Color.theme.accent)
//                        .padding()
//                        .opacity(commentString == "" ? 1 : 0)
//
//                    TextEditor(text: $commentString)
//                        .padding([.leading, .trailing], 11)
//                        .padding([.top, .bottom], 8)
////                            .lineLimit(5)
////                            .frame(maxHeight: 100)
//                }
//
//                Spacer()
//
//
//                Button {
//
//                } label: {
//                    Image(systemName: "arrow.right")
//                }
//                .disabled(commentString.isEmpty)
//                .padding([.top, .bottom], 2)
//                .padding([.trailing])
//            }
//
//            Spacer()
//
//            Divider()
//                .padding(.bottom)
//
//            ScrollView {
//                VStack {
//                    ForEach(0..<5, id: \.self) { i in
//                        VStack(alignment:.leading) {
//
//                            Image(systemName: "arrow.right")
//
//                            Divider()
//                                .padding(.vertical, 8)
//                        }
//                    }
//                }
//            }
////            }
//        }
//        .navigationBarTitleDisplayMode(.inline)
//        .foregroundColor(Color.theme.foreground)
//        .navigationBarBackButtonHidden(true)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                BackButtonView(dismiss: self.dismiss)
//            }
//        }
//        .background(Color.theme.background)
        
        
//    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
