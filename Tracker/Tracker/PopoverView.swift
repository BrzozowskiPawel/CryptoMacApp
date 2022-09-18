//
//  PopoverView.swift
//  Tracker
//
//  Created by Paweł Brzozowski on 18/09/2022.
//

import SwiftUI

struct PopoverView: View {
    var body: some View {
        VStack(spacing: 16) {
            VStack {
            Text("Coin").font(.largeTitle)
            Text("$30,000").font(.title.bold())
            }
            
            Divider()
            
            Button("Close App") {
                NSApp.terminate(self)
            }
        }
    }
}

struct PopoverView_Previews: PreviewProvider {
    static var previews: some View {
        PopoverView()
    }
}
