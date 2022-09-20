//
//  CoinService.swift
//  Tracker
//
//  Created by Paweł Brzozowski on 18/09/2022.
//

import Combine
import Foundation
import Network

class CoinService: NSObject {
    
    private let session = URLSession(configuration: .default)
    private var webSocketTask: URLSessionWebSocketTask?
    
    private let coinDictionarySubject = CurrentValueSubject<[String: Coin], Never>([:])
    private var coinDictionary: [String: Coin] { coinDictionarySubject.value }
    
    private let connectionStateSubject = CurrentValueSubject<Bool, Never>(false)
    private var isConnected: Bool { connectionStateSubject.value }
    
    func connect() {
        let coins = CoinType.allCases
            .map { $0.rawValue }
            .joined(separator: ",")
        // could be assets=ALL
        let url = URL(string: "wss://ws.coincap.io/prices?assets=\(coins)")!
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.delegate = self
        webSocketTask?.resume()
        self.reciveMessage()
        
    }
    
    private func reciveMessage() {
        webSocketTask?.receive(completionHandler: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Recived text message: \(text)")
                    if let data = text.data(using: .utf8) {
                        self.onReciveData(data)
                    }
                case .data(let data):
                    print("Recived binary message: \(data)")
                    self.onReciveData(data)
                default: break
                }
                self.reciveMessage()
            case .failure(let error):
                print("Failed to recive message: \(error.localizedDescription)")
            }
        })
    }
    
    private func onReciveData(_ data: Data) {
        guard let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String:String] else { return }
        
        var newDictionary = [String: Coin]()
        
        dictionary.forEach { (key, value) in
            let value = Double(value) ?? 0
            newDictionary[key] = Coin(name: key, value: value)
        }
        
        let mergedDictionary = coinDictionary.merging(newDictionary) { $1 }
        coinDictionarySubject.send(mergedDictionary)
    
    }
    
    deinit {
        coinDictionarySubject.send(completion: .finished)
        connectionStateSubject.send(completion: .finished)
    }
}

extension CoinService: URLSessionWebSocketDelegate {
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        
    }
}
