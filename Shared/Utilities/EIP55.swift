//
//  EIP55.swift
//  William Checkspeare
//
//  Created by Marvin Zwolsman on 04/03/2023.
//
import Foundation
import CryptoSwift

// NOTE: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-55.md
public struct EIP55 {
    public static func encode(_ address: String) -> String {
        let address = address.deletingPrefix("0x").lowercased()
        let hash = address.data(using: .ascii)!.sha3(.keccak256).toHexString()
        
        return "0x" + zip(address, hash)
            .map { a, h -> String in
                switch (a, h) {
                case ("0", _), ("1", _), ("2", _), ("3", _), ("4", _), ("5", _), ("6", _), ("7", _), ("8", _), ("9", _):
                    return String(a)
                case (_, "8"), (_, "9"), (_, "a"), (_, "b"), (_, "c"), (_, "d"), (_, "e"), (_, "f"):
                    return String(a).uppercased()
                default:
                    return String(a).lowercased()
                }
            }
            .joined()
    }
}

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}
