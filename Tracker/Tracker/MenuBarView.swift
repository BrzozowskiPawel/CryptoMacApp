//
//  MenuBarView.swift
//  Tracker
//
//  Created by Paweł Brzozowski on 18/09/2022.
//

import SwiftUI

struct MenuBarView: View {
    var body: some View {
        HStack (spacing: 4) {
            Image(systemName: "dollarsign.circle")
                .foregroundColor(.green)
            VStack(alignment: .leading, spacing: -2) {
                Text("Coin")
                Text("$2137")
            }
            .font(.caption)
        }
    }
}

struct MenuBarView_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarView()
    }
}
