//
//  ViewOne.swift
//  StoreScreenshotGenerator
//
//  Created by Shunzhe Ma on 8/22/20.
//  Copyright © 2020 Shunzhe Ma. All rights reserved.
//

import SwiftUI
import SwiftUICompatible
import SwiftUILibrary
import PhotosUI

struct stepOneView: View {
    
    @State var pickedImage: UIImage? = nil
    
    @State private var showPhotoPicker = false
    @State private var showSecondView = false
    
    var body: some View {
        
        VStack {
            
            HStack {
                Image(systemName: "1.square.fill")
                    .font(.system(size: 50))
                    .padding(.top, 20)
                    .padding(.leading, 30)
                Spacer()
            }
            
            Text("まずはじめにお使いになりたいスクリーンショットをお選びください。")
                .font(.title)
                .padding()
                .onAppear(perform: {
                    FileManager().clearTmpDirectory()
                })
            
            Text("スクリーンショットを撮った端末と同じ端末上でこのアプリケーションを動作させる必要があります。")
                .padding()
            
            Spacer()
            
            BigRoundedButton(systemIconName: "apps.iphone", buttonName: "スクリーンショットを選ぶ", buttonColor: Color.blue)
                .onTapGesture {
                    self.showPhotoPicker = true
                }
                .padding(.bottom, 30)
                .sheet(isPresented: $showPhotoPicker, content: {
                    ImagePicker { (image) in
                        self.pickedImage = image
                        self.showSecondView = true
                    } onCancelled: {
                        return
                    }

                })
            
            NavigationLink(destination: ViewTwo(pickedImage: self.pickedImage), isActive: $showSecondView, label: {
                EmptyView()
            })
            
        }
        
    }
    
}
