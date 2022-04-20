//
//  Transaction.swift
//  Bombastic
//
//  Created by Marvin Zwolsman on 17/04/2022.
//

import Foundation

struct Transaction : Equatable, Codable  {
    var txId: String
    let type: TransactionType
    let amount: Int
    let timestamp: Date
    let confirmed: Bool
    
    enum TransactionType: String, Codable
    {
        case deposit = "DEPOSIT"
        case withdraw = "WITHDRAW"
    }
}
