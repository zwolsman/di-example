//
//  TransactionsScene.swift
//  Bombastic (iOS)
//
//  Created by Marvin Zwolsman on 19/04/2022.
//

import SwiftUI

struct TransactionsScene: View {
    
    let address = "mrWmFpVs4eijT6PLrRYszX3xQroyxLpokG"
    var body: some View {
        List {
            Section(footer: Text("Your deposit address is private. Send only Bitcoin (BTC) to this address. Sending any other coins may reuslt in permanent loss. After 1 confirmation the bits will be added to your account.")) {
                VStack(spacing: 8) {
                    Text("Marvin Zwolsman")
                        .fontWeight(.semibold)
                    
                    Text(address)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    Image(uiImage: QrCodeImage.generateQRCode(from: "bitcoin:\(address)"))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 148, height: 148)
                    .padding()
                    
                }
                .frame(maxWidth: .infinity)
                .padding()
                
            }
            
            Section(header: Text("Recent transactions")) {
                TransactionRow(transaction: Transaction.mockDeposit)
                TransactionRow(transaction: Transaction.mockDeposit)
                TransactionRow(transaction: Transaction.mockDeposit)
            }
            Section(footer: Text("You cannot cash out until all deposit transactions have at least 3 confirmations. You can check the deposits and number of confirmations by clicking visiting blockchain.info and search for your deposit address.")) {
                Button("Withdraw") {
                    
                }
            }
        }
        .navigationTitle("Manage bits")
            .navigationBarTitleDisplayMode(.inline)
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
            TransactionsScene()
        }
        
        NavigationView {
            TransactionsScene()
        }.preferredColorScheme(.dark)
    }
}
