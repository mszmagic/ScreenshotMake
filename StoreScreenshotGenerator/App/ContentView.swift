//
//  ContentView.swift
//  StoreScreenshotGenerator
//
//  Created by Shunzhe Ma on 8/22/20.
//  Copyright © 2020 Shunzhe Ma. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        
        NavigationView {
            stepOneView()
                .navigationBarTitle("ステップ1", displayMode: .inline)
        }
        .statusBar(hidden: true)
        .navigationViewStyle(StackNavigationViewStyle())
        
    }
    
}
