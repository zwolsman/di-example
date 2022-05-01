//
//  TransactionsScene.swift
//  Bombastic (iOS)
//
//  Created by Marvin Zwolsman on 19/04/2022.
//

import SwiftUI

struct TransactionsScene: View {
    @ObservedObject private(set) var viewModel: ViewModel
    
    let inspection = Inspection<Self>()
    
    var body: some View {
        content
            .navigationBarTitle("Manage bits")
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(inspection.notice) {
                inspection.visit(self, $0)
            }
    }
    
    @ViewBuilder
    var content: some View {
        switch viewModel.profile {
        case .notRequested:
            notRequestedView
        case .isLoading:
            loadingView
        case let .loaded(profile):
            loadedView(profile)
        case let .failed(error):
            Text(error.localizedDescription)
        }
    }
    
    var notRequestedView: some View {
        Text("").onAppear(perform: viewModel.loadTransactions)
    }
    
    var loadingView: some View {
        HStack {
            ProgressView()
                .padding()
            Text("Loading transactions")
                .foregroundColor(.secondary)
        }
    }
    
    func loadedView(_ profile: ProfileWithTransactions) -> some View {
        List {
            Section(footer: Text("Your deposit address is private. Send only Bitcoin (BTC) to this address. Sending any other coins may reuslt in permanent loss. After 1 confirmation the bits will be added to your account.")) {
                VStack(spacing: 8) {
                    Text("Marvin Zwolsman")
                        .fontWeight(.semibold)
                    
                    Link(profile.address, destination: profile.addressUrl)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .buttonStyle(.plain)
                    
                    Button(action: viewModel.qrImageAction) {
                        Image(uiImage: QrCodeImage.generateQRCode(from: "bitcoin:\(profile.address)"))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 148, height: 148)
                            .padding()
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
                .padding()
                
            }
            
            Section(header: Text("Recent transactions")) {
                if profile.transactions.isEmpty {
                    Text("")
                } else {
                    ForEach(profile.transactions, id: \.txId, content: TransactionRow.init(transaction:))
                }
            }
            Section(footer: Text("You cannot cash out until all deposit transactions have at least 3 confirmations. You can check the deposits and number of confirmations by visiting blockchain.info and search for your deposit address.")) {
                Button("Withdraw") {
                    
                }
            }
        }
    }
}

extension ProfileWithTransactions {
    var addressUrl: URL {
        URL(string: "https://www.blockchain.com/btc-testnet/address/\(address)")!
    }
}

struct QrCodeImage {
    static let context = CIContext()
    static let filter = CIFilter(name: "CIQRCodeGenerator")!
    
    static func generateQRCode(from text: String) -> UIImage {
        var qrImage = UIImage(systemName: "xmark.circle") ?? UIImage()
        let data = Data(text.utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        let transform = CGAffineTransform(scaleX: 20, y: 20)
        if let outputImage = filter.outputImage?.transformed(by: transform) {
            if let image = context.createCGImage(
                outputImage,
                from: outputImage.extent) {
                qrImage = UIImage(cgImage: image)
            }
        }
        return qrImage
    }
}

struct TransactionsScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TransactionsScene(viewModel: .init(container: .preview, profile: .loaded(ProfileWithTransactions.mock)))
        }
        
        NavigationView {
            TransactionsScene(viewModel: .init(container: .preview, profile: .loaded(ProfileWithTransactions.mock)))
        }.preferredColorScheme(.dark)
    }
}
