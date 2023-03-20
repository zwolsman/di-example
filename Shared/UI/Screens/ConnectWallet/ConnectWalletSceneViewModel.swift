//
//  ConnectSceneViewModel.swift
//  William Checkspeare
//
//  Created by Marvin Zwolsman on 24/02/2023.
//

import Foundation
import Combine
import UIKit
import Moya
import metamask_ios_sdk

// MARK: - Routing

extension ConnectWalletScene {
    struct Routing: Equatable {
        
    }
}

extension ConnectWalletScene {
    class ViewModel: ObservableObject {
        // State
        @Published var routingState: Routing
        @Published var authenticated: Loadable<Bool>
        
        var problem: Problem?
        
        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()
        private let ethereum = MetaMaskSDK.shared.ethereum
        private let dapp = Dapp(name: "Checkpot", url: "https://williamcheckspeare.com")
        
        init(container: DIContainer, authenticated: Loadable<Bool> = .notRequested) {
            self.container = container
            let appState = container.appState
            _routingState = .init(initialValue: appState.value.routing.connectWalletScene)
            _authenticated = .init(initialValue: authenticated)
            
            cancelBag.collect {
                $routingState
                    .removeDuplicates()
                    .sink {
                        appState[\.routing.connectWalletScene] = $0
                    }
                
                $authenticated
                    .removeDuplicates()
                    .filter {
                        if case Loadable.isLoading = $0 {
                            return false
                        } else {
                            return true
                        }
                    }
                    .sink {
                        appState[\.userData.authenticated] = $0
                    }
                
                appState.updates(for: \.routing.connectWalletScene)
                    .weakAssign(to: \.routingState, on: self)
            }
        }
        
        func connectMetamask() {
            guard let publisher = ethereum.connect(dapp) else { return }
            authenticated.setIsLoading(cancelBag: cancelBag)
            
            publisher
                .compactMap {
                    guard let address = $0 as? String else { return nil}
                    return EIP55.encode(address)
                }
                .mapError { MoyaError.underlying($0, nil) } // TODO? WTF??
                .flatMap { wallet in
                    self.container
                        .services
                        .authService
                        .siwe(address: wallet)
                        .delay(for: 2, scheduler: RunLoop.main)
                        .flatMap { message -> AnyPublisher<(String, String), MoyaError> in
                            let req = EthereumRequest(method: .personalSign, params: ["0x" + message.data(using: .utf8)!.toHexString(), wallet])
                            let resp = self.ethereum.request(req) ?? Empty<Any, RequestError>().eraseToAnyPublisher()
                            
                            return resp
                                .mapError { MoyaError.underlying($0, nil) } // TODO? WTF??
                                .compactMap { (response: Any) -> (String, String)? in
                                    guard let signature = response as? String else { return nil }
                                    return (message, signature)
                                }
                                .eraseToAnyPublisher()
                        }
                }
                .flatMap { (message, signature) in
                    self.container
                        .services
                        .authService
                        .verify(message: message, signature: signature)
                }
                .sinkToLoadable { accessToken in
                    print(accessToken)
                    if let token = accessToken.value {
                        self.onAccessToken(accessToken: token)
                    }
                    
                    self.authenticated = accessToken.map { _ in true }
                }
                .store(in: cancelBag)
        }
        
        private func onAccessToken(accessToken: String) {
            print("Received access token from api")
            container.appState[\.userData.accessToken] = accessToken
        }
    }
    
}
