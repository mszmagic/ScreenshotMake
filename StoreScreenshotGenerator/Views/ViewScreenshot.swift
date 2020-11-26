//
//  ViewScreenshot.swift
//  StoreScreenshotGenerator
//
//  Created by Shunzhe Ma on 8/22/20.
//  Copyright © 2020 Shunzhe Ma. All rights reserved.
//

import SwiftUI
import SwiftUICompatible
import SwiftUILibrary

struct ViewScreenshot: View {
    
    private var pickedImage: UIImage?
    
    private var imageWidth: CGFloat = 150
    private var imageHeight: CGFloat = 0
    
    private var screenshotImageResizeFactor: CGFloat = 0.88
    
    private var textColor: Color = .white
    private var backgroundColor: Color = .blue
    
    private var textFont: Font = Font(UIFont.systemFont(ofSize: 15))
    
    private var textContent: String = ""
    
    var deviceMockUpImgName: String = "iPhoneX.png"
    var mockUpOffsetValue: CGFloat = 20
    
    @State var shouldShowGeneratedScreenshot: Bool = false
    
    @State var screenshotImage: UIImage? = nil
    @State var screenshotFilePath: URL? = nil
    @State var shouldShowPreview: Bool = false
    
    // 画像が正常に生成されたら、ユーザーの画像保存を可能にするオプションを表示してください。
    @State var shouldShowSavingOptions: Bool = false
    
    @State var isImageSavedToAlbum: Bool = false
    @State var imageSavingButtonLabel: String = "イメージを保存する"
    @State var imageSavingButtonColor: Color = .blue
    
    var onDismiss: () -> Void
    
    init(pickedImage: UIImage?, device: DeviceType, textContent: String, backgroundColor: Color, textColor: Color, textFontName: String?, textFontSize: Int, onDismiss: @escaping () -> Void) {
        self.pickedImage = pickedImage
        if let image = self.pickedImage {
            let imgSize = image.size
            imageWidth = UIScreen.main.bounds.width * 0.92
            // 好みの幅/高さを計算する
            let heightOverWidth = imgSize.height / imgSize.width
            self.imageHeight = heightOverWidth * imageWidth
        }
        // さまざまなデバイスタイプ用のさまざまなモックアップ画像
        screenshotImageResizeFactor = 0.88
        if device == .iPhoneX {
            deviceMockUpImgName = "iPhoneX.png"
            mockUpOffsetValue = 20
        } else if device == .iPadPro {
            deviceMockUpImgName = "iPadPro.png"
            mockUpOffsetValue = 62
        } else if device == .iPadPro11 {
            deviceMockUpImgName = "iPadPro11.png"
            mockUpOffsetValue = 53
        } else if device == .iPhone8Plus {
            deviceMockUpImgName = "iPhone8.png"
            mockUpOffsetValue = 83
            screenshotImageResizeFactor = 0.725
        }
        // その他の変数
        self.textContent = textContent
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.onDismiss = onDismiss
        // テキストフォント
        if let providedFontName = textFontName,
           providedFontName != "",
           let uiFontObj = UIFont(name: providedFontName, size: CGFloat(textFontSize)) {
            self.textFont = Font(uiFontObj)
        } else {
            self.textFont = Font(UIFont.systemFont(ofSize: CGFloat(textFontSize)))
        }
    }
    
    var body: some View {
        
        if shouldShowGeneratedScreenshot {
            ZStack {
                
                Rectangle()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 20, alignment: .center)
                    .foregroundColor(self.backgroundColor)
                
                VStack {
                    
                    Text(self.textContent)
                        .padding(.top, 100)
                        .frame(width: imageWidth, height: 60, alignment: .center)
                        .foregroundColor(self.textColor)
                        .font(self.textFont)
                        .multilineTextAlignment(.center)
                    
                    ZStack {
                        
                        Image(uiImage: self.pickedImage ?? UIImage())
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageWidth * screenshotImageResizeFactor - 20, height: imageHeight * screenshotImageResizeFactor, alignment: .center)
                        
                        Image(uiImage: UIImage(named: deviceMockUpImgName)!)
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageWidth - self.mockUpOffsetValue, height: imageHeight, alignment: .center)
                        
                    }
                    
                }
                
            }
            
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .statusBar(hidden: true)
            
        }
        
        /*
         生成されたスクリーンショットを保存またはプレビューするオプション。
         */
        
        else if shouldShowSavingOptions {
            
            VStack {
                
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                    .padding()
                
                Text("作成されました！")
                    .font(.largeTitle)
                
                if self.screenshotImage != nil {
                    Image(uiImage: self.screenshotImage!)
                        .resizable()
                        .frame(width: imageWidth / imageHeight * (UIScreen.main.bounds.height * 0.5), height: UIScreen.main.bounds.height * 0.5, alignment: .center)
                        .scaledToFit()
                        .padding()
                }
                
                BigRoundedButton(systemIconName: "square.and.arrow.down.fill", buttonName: imageSavingButtonLabel, buttonColor: imageSavingButtonColor)
                    .onTapGesture(perform: {
                        guard !isImageSavedToAlbum else { return }
                        let haptic = UIImpactFeedbackGenerator(style: .light)
                        haptic.prepare()
                        if let screenshotImg = self.screenshotImage {
                            UIImageWriteToSavedPhotosAlbum(screenshotImg, nil, nil, nil)
                            self.isImageSavedToAlbum = true
                            self.imageSavingButtonColor = .green
                            self.imageSavingButtonLabel = "保存されました"
                            haptic.impactOccurred()
                        }
                    })
                
                BigRoundedButton(systemIconName: "doc.text.viewfinder", buttonName: "イメージをプレビューする", buttonColor: .blue)
                    .onTapGesture(perform: {
                        self.shouldShowPreview = true
                    })
                    .sheet(isPresented: $shouldShowPreview, content: {
                        if self.screenshotFilePath != nil {
                            QuickLookView(urls: [self.screenshotFilePath!], onDismiss: {
                                self.onDismiss()
                            })
                        }
                        else {
                            Text("まだ作成中です。")
                                .onAppear(perform: {
                                    self.shouldShowPreview = false
                                })
                        }
                    })
                
            }
            
        }
        
        
        else {
            
            VStack {
                
                HStack {
                    Image(systemName: "3.square.fill")
                        .font(.system(size: 38))
                    Text("作成する")
                        .font(.title)
                        .padding(.leading, 20)
                }
                .padding(.top, 50)
                
                Text("スクリーンショットを撮るには、「作成する」をクリックしてください。")
                    .padding()
                
                BigRoundedButton(systemIconName: "arrow.right", buttonName: "作成する", buttonColor: .blue)
                    .onTapGesture(perform: {
                        self.shouldShowGeneratedScreenshot = true
                        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (_) in
                            let image = self.takeScreenshot(origin: .zero, size: UIScreen.main.bounds.size)
                            self.screenshotImage = image
                            if let imageData = image.pngData(),
                               let tempPath = saveToTempDirectory(data: imageData as NSData) {
                                self.screenshotFilePath = tempPath
                                self.shouldShowSavingOptions = true
                                self.shouldShowGeneratedScreenshot = false
                            }
                        }
                    })
                
                Spacer()
                
            }
            
        }
        
    }
    
}

func saveToTempDirectory(data: NSData) -> URL? {
    let tempDirectory = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
    let filePath = tempDirectory.appendingPathComponent(UUID().uuidString + ".png")
    do {
        try data.write(to: filePath)
        return filePath
    } catch {
        print(error.localizedDescription)
        return nil
    }
}

extension UIView {
    var renderedImage: UIImage {
        let rect = self.bounds
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        self.layer.render(in: context)
        let capturedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return capturedImage
    }
}

extension View {
    func takeScreenshot(origin: CGPoint, size: CGSize) -> UIImage {
        let window = UIWindow(frame: CGRect(origin: origin, size: size))
        let hosting = UIHostingController(rootView: self)
        hosting.view.frame = window.frame
        window.addSubview(hosting.view)
        window.makeKeyAndVisible()
        return hosting.view.renderedImage
    }
}

extension FileManager {
    func clearTmpDirectory() {
        do {
            let tmpDirectory = try contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach {[unowned self] file in
                let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
                try self.removeItem(atPath: path)
            }
        } catch {
            print(error)
        }
    }
}
