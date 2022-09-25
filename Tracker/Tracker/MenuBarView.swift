//
//  MenuBarView.swift
//  Tracker
//
//  Created by Paweł Brzozowski on 18/09/2022.
//

import SwiftUI

struct MenuBarView: View {
    @ObservedObject var viewModel: MenuBarViewModel
    var body: some View {
        HStack (spacing: 4) {
            Image(systemName: "circle.fill")
                .foregroundColor(viewModel.color)
            VStack(alignment: .trailing, spacing: -2) {
                Text(viewModel.name.capitalized)
                Text(viewModel.value)
            }
            .font(.caption)
        }
        .onAppear {
            viewModel.subscribeToService()
        }
    }
}

struct MenuBarView_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarView(viewModel: .init(name: "Bitcoin", value: "$20,000", color: .green))
    }
}
