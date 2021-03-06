//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import Foundation

class ETHTransactionDTO: NSObject {
    var gasLimit = BigInt.zero()
    var gasPrice =  BigInt.zero()
    
    var feeAmount: BigInt {
        return gasPrice * gasLimit
    }
}
