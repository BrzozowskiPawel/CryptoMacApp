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
    private var pingCount = 0
    
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
        self.schedulePing()
        
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
    
    private func schedulePing() {
        let identifier = self.webSocketTask?.taskIdentifier ?? -1
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let self = self,
                  let task = self.webSocketTask,
                  task.taskIdentifier == identifier else { return }
            
            if task.state == .running, self.pingCount < 2 {
                self.pingCount += 1
                print("✅ Ping sended, count: \(self.pingCount)")
                task.sendPing { [weak self] error in
                    if let error = error {
                        print("❌ Ping failed: \(error.localizedDescription)")
                    } else if self?.webSocketTask?.taskIdentifier == identifier {
                        self?.pingCount = 0
                    }
                }
                self.schedulePing()
            } else {
                self.reconnect()
            }
            
        }
    }
    
    private func reconnect() {
        self.clearConnection()
        self.connect()
    }
    
    // To disconnect
    func clearConnection() {
        self.webSocketTask?.cancel()
        self.webSocketTask = nil
        self.pingCount = 0
        
        self.connectionStateSubject.send(false)
    }
    
    deinit {
        coinDictionarySubject.send(completion: .finished)
        connectionStateSubject.send(completion: .finished)
    }
}

extension CoinService: URLSessionWebSocketDelegate {
    
    // Succesfully connected to web socket server
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        self.connectionStateSubject.send(true)
    }
    
    // Canceled the currrrent task - disconnect
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.connectionStateSubject.send(false)
    }
}
