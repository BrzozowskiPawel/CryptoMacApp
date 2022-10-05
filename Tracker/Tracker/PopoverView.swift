//
//  PopoverView.swift
//  Tracker
//
//  Created by Paweł Brzozowski on 18/09/2022.
//

import SwiftUI

struct PopoverView: View {
    
    @ObservedObject var viewModel: PopoverViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            VStack {
                Text(viewModel.title.capitalized).font(.largeTitle)
                Text(viewModel.subtitle).font(.title.bold())
            }
            
            Divider()
            
            Picker("Select Coin", selection: $viewModel.selectedCoinType) {
                ForEach(viewModel.coinTypes) { type in
                    HStack {
                        Text(type.description).font(.headline)
                        Spacer()
                        Text(viewModel.valueText(for: type))
                            .frame(alignment: .trailing)
                            .font(.body)
                        Link(destination: type.url) {
                            Image(systemName: "safari")
                        }
                    }
                    .tag(type)
                }
            }
            .pickerStyle(RadioGroupPickerStyle())
            .labelsHidden()
            
            Divider()
            
            Button("Close App") {
                NSApp.terminate(self)
            }
        }.onAppear {
            viewModel.subscribeToService()
        }
        .onChange(of: viewModel.selectedCoinType) { _ in
            viewModel.updateView()
        }
    }
}

struct PopoverView_Previews: PreviewProvider {
    static var previews: some View {
        PopoverView(viewModel: .init(title: "Bitcoin", subtitle: "$30,000") )
    }
}
