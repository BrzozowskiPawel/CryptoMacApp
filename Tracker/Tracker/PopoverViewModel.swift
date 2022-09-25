//
//  PopoverViewModel.swift
//  Tracker
//
//  Created by Paweł Brzozowski on 25/09/2022.
//

import Foundation
import Combine
import SwiftUI

class PopoverViewModel: ObservableObject {
    @Published private(set) var title: String
    @Published private(set) var subtitle: String
    @Published private(set) var coinTypes: [CoinType]
    
    @AppStorage("SelectedCoinType") var selectedCoinType = CoinType.bitcoin
    
    private let service: CoinService
    private var subscriptiopns = Set<AnyCancellable>()
    
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.currencyCode = "USD"
        return formatter
    }()
    
    init(title: String = "", subtitle: String = "", coinTypes: [CoinType] = CoinType.allCases, service: CoinService = .init()) {
        self.title = title
        self.subtitle = subtitle
        self.coinTypes = coinTypes
        self.service = service
    }
    
    func subscribeToService() {
        service.coinDictionarySubject.sink { [weak self] _ in
            self?.updateView()
        }
        .store(in: &subscriptiopns)
    }
    
    func updateView() {
        let coin = self.service.coinDictionary[selectedCoinType.rawValue]
        self.title = coin?.name ?? selectedCoinType.description
        
        if let coin = coin, let value = self.currencyFormatter.string(from: NSNumber(value: coin.value)) {
            self.subtitle = value
        } else {
            self.subtitle = "Updating..."
        }
    }
    
    func valueText(for coinType: CoinType) -> String {
        if let coin = service.coinDictionary[coinType.rawValue], let value = self.currencyFormatter.string(from: NSNumber(value: coin.value)) {
            return value
        } else {
           return "Updating..."
        }
    }
}
