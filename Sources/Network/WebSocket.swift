//
//  File.swift
//  
//
//  Created by MoneyClip on 2021-03-06.
//

import Foundation

public protocol WebSocketDelegate: class {
    func didReceive(data: Data)
    func didReceive(text: String)
    func didReceive(error: String)
}

@available(iOS 13.0, *)
public class WebSocket: NSObject {
    
    public weak var delegate: WebSocketDelegate?
    
    private let url: URL
    
    public init(url: URL, delegate: WebSocketDelegate) {
        self.url = url
        self.delegate = delegate
        super.init()
        self.task.resume()
    }
    
    private lazy var task: URLSessionWebSocketTask = {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        let webSocketTask = session.webSocketTask(with: self.url)
        return webSocketTask
    }()
    
    public func ping() {
        self.task.sendPing { error in
          if let error = error {
            print("Error when sending PING \(error)")
          } else {
              print("Web Socket connection is alive")
              DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                self.ping()
              }
           }
        }
    }
    
    public func close() {
        let reason = "Closing connection".data(using: .utf8)
        self.task.cancel(with: .goingAway, reason: reason)
    }
    
    public func send() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            self.task.send(.string("New Message")) { error in
              if let error = error {
                print("Error when sending a message \(error)")
              }
            }
        }
    }
    
    public func receive() {
      task.receive { [weak self] result in
        switch result {
        case .success(let message):
          switch message {
          case .data(let data):
            DispatchQueue.main.async {
                self?.delegate?.didReceive(data: data)
            }
          case .string(let text):
            DispatchQueue.main.async {
                self?.delegate?.didReceive(text: text)
            }
          @unknown default:
            fatalError()
          }
        case .failure(let error):
            DispatchQueue.main.async {
                self?.delegate?.didReceive(error: error.localizedDescription)
            }
        }
        self?.receive()
      }
    }
}

@available(iOS 13.0, *)
extension WebSocket: URLSessionWebSocketDelegate  {
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Web Socket did connect")
    }
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Web Socket did disconnect")
    }
}
