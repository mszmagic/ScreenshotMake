//
//  ViewTwo.swift
//  StoreScreenshotGenerator
//
//  Created by Shunzhe Ma on 8/22/20.
//  Copyright © 2020 Shunzhe Ma. All rights reserved.
//

import SwiftUI
import SwiftUILibrary
import FontSelector

enum DeviceType {
    case iPhoneX
    case iPadPro
    case iPadPro11
    case iPhone8Plus
    case unknown
}

struct ViewTwo: View {
    
    var iPhoneXScreenSizeValues: [CGFloat] = [1125, 2436, 1242, 2688, 828, 1792]
    var iPadProScreenSizeValues: [CGFloat] = [2388, 1668, 2732, 2048]
    var iPhone8PlusSizeValues: [CGFloat] = [1242, 2208]
    
    private var pickedImage: UIImage?
    private var deviceModel: DeviceType = .unknown
    private var isPortrait: Bool = true
    
    private var imageWidth: CGFloat = 100
    private var imageHeight: CGFloat = 0
    
    @State private var shouldShowThirdView: Bool = false
    
    @State private var textContent: String = "Text"
    @State private var textColor: Color = Color.white
    @State private var backgroundColor: Color = Color.blue
    
    @State private var textFontName: String = ""
    @State private var showingFontSelector = false
    
    @State private var textFontSize = 32
    
    init(pickedImage: UIImage?) {
        self.pickedImage = pickedImage
        if let image = self.pickedImage {
            let imgSize = image.size
            imageWidth = 100
            // 好みの幅/高さを計算する
            let heightOverWidth = imgSize.height / imgSize.width
            self.imageHeight = heightOverWidth * imageWidth
            // デバイスの種類を検出する
            if iPhoneXScreenSizeValues.contains(imgSize.width) &&
                iPhoneXScreenSizeValues.contains(imgSize.height) {
                // iPhone 11
                self.deviceModel = .iPhoneX
            } else if iPadProScreenSizeValues.contains(imgSize.width) && iPadProScreenSizeValues.contains(imgSize.height) {
                // iPad Pro
                if imgSize.width == 1668 && imgSize.height == 2388 {
                    self.deviceModel = .iPadPro11
                } else {
                    self.deviceModel = .iPadPro
                }
            } else if iPhone8PlusSizeValues.contains(imgSize.width) &&
                        iPhone8PlusSizeValues.contains(imgSize.height) {
                self.deviceModel = .iPhone8Plus
            }
            // ポートレート/ランドスケープモードを確認する
            if imgSize.height > imgSize.width {
                self.isPortrait = true
            } else {
                self.isPortrait = false
            }
        }
    }
    
    var body: some View {
        
        VStack {
            
            HStack {
                Image(systemName: "2.square.fill")
                    .font(.system(size: 38))
                Text("詳細を確認")
                    .font(.title)
                    .padding(.leading, 20)
            }
            .padding(.top, 10)
            .onAppear(perform: {
                FileManager().clearTmpDirectory()
            })
            
            Image(uiImage: self.pickedImage ?? UIImage())
                .resizable()
                .scaledToFit()
                .frame(width: imageWidth, height: imageHeight, alignment: .center)
                .padding(.bottom, 20)
            
            Form {
                
                HStack {
                    Text("テキストコンテンツ")
                        .font(.headline)
                    TextField("Text", text: $textContent)
                        .multilineTextAlignment(.trailing)
                        .onTapGesture(perform: {
                            self.textContent = ""
                        })
                }
                
                HStack {
                    Text("背景の色")
                        .font(.headline)
                    ColorPicker("", selection: $backgroundColor)
                }
                
                HStack {
                    Text("テキストカラー")
                        .font(.headline)
                    ColorPicker("", selection: $textColor)
                }
                
                HStack {
                    Text("フォント")
                        .font(.headline)
                    Spacer()
                    Button((self.textFontName == "") ? "既定" : self.textFontName) {
                        self.showingFontSelector = true
                    }
                    .sheet(isPresented: $showingFontSelector, content: {
                        if self.textContent == "" {
                            FontSelector(onFontSelected: { selectedFontName in
                                self.textFontName = selectedFontName
                            })
                        } else {
                            FontSelector(onFontSelected: { selectedFontName in
                                self.textFontName = selectedFontName
                            }, demoText: self.textContent)
                        }
                    })
                }
                
                HStack {
                    Text("テキストのサイズ")
                        .font(.headline)
                    Spacer()
                    Stepper(String(textFontSize), value: $textFontSize, in: 1...100)
                }
                
                VStack {
                    HStack {
                        Text("デバイスモデル")
                            .font(.headline)
                            .padding(.top, 5)
                        Spacer()
                        if self.deviceModel == .iPhoneX {
                            Text("iPhone X")
                        } else if self.deviceModel == .iPadPro {
                            Text("iPad Pro")
                        } else if self.deviceModel == .iPadPro11 {
                            Text("iPad Pro 11 inch")
                        } else if self.deviceModel == .iPhone8Plus {
                            Text("iPhone 8 Plus")
                        }
                    }
                }
                
            }
            
            // デバイスのモデルが利用可能かどうかを確認する
            if self.deviceModel != DeviceType.unknown {
                // ポートレートモードであるかどうかを確認する
                if self.isPortrait {
                    // Check device model match
                    if (UIScreen.main.bounds.width == 2048 &&
                            UIScreen.main.bounds.height == 2732 &&
                            self.deviceModel == DeviceType.iPadPro) ||
                        (UIScreen.main.bounds.width == 1024 &&
                            UIScreen.main.bounds.height == 1366 &&
                            self.deviceModel == DeviceType.iPadPro)  ||
                        (UIScreen.main.bounds.width == 1668 &&
                            UIScreen.main.bounds.height == 2388 &&
                            self.deviceModel == DeviceType.iPadPro11)
                        || (UIDevice.current.userInterfaceIdiom == .phone &&
                                self.deviceModel == DeviceType.iPhoneX)
                        || (UIScreen.main.bounds.width == 1242 &&
                                UIScreen.main.bounds.height == 2208 &&
                                self.deviceModel == DeviceType.iPhone8Plus)
                        || (UIScreen.main.bounds.width == 414 &&
                                UIScreen.main.bounds.height == 736 &&
                                self.deviceModel == DeviceType.iPhone8Plus) {
                        BigRoundedButton(systemIconName: "arrow.right", buttonName: "継続する", buttonColor: Color.blue)
                            .onTapGesture {
                                self.shouldShowThirdView = true
                            }
                    } else {
                        Text("スクリーンショットを撮った端末と同じ端末上でこのアプリケーションを動作させる必要があります。")
                            .padding()
                    }
                } else {
                    Text("現在はポートレートスクリーンショットのみ処理が可能です。")
                        .padding()
                }
            } else {
                Text("画像の解像度からお使いの機器のモデルを検出できませんでした。機器で直接撮ったスクリーンショットを使用してください。なお、以下のカテゴリーの機器のみに対応しています：iPhone X, iPhone 11, iPad Pro.")
                    .padding()
            }
            
            NavigationLink(destination: ViewScreenshot(
                            pickedImage: self.pickedImage,
                            device: self.deviceModel,
                            textContent: self.textContent,
                            backgroundColor: self.backgroundColor,
                            textColor: self.textColor,
                            textFontName: self.textFontName,
                            textFontSize: self.textFontSize,
                            onDismiss: {
                                self.shouldShowThirdView = false
                            }),
                           isActive: $shouldShowThirdView,
                           label: {
                            EmptyView()
                           })
            
        }
        
    }
    
}
