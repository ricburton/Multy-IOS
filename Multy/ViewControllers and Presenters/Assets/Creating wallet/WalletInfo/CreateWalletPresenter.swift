//Copyright 2017 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import Firebase

class CreateWalletPresenter: NSObject {
    weak var mainVC: CreateWalletViewController?
    var account : AccountRLM?
    var selectedBlockchainType = BlockchainType.create(currencyID: 0, netType: 0)
    let createdWallet = UserWalletRLM()
//
    func makeAuth(completion: @escaping (_ answer: String) -> ()) {
        if self.account != nil {
            return
        }
        
        DataManager.shared.auth(rootKey: nil) { (account, error) in
//            self.assetsVC?.view.isUserInteractionEnabled = true
//            self.assetsVC?.progressHUD.hide()
            guard account != nil else {
                return
            }
            self.account = account
            DataManager.shared.socketManager.start()
            completion("ok")
        }
    }
    
    func createNewWallet(completion: @escaping (_ dict: Dictionary<String, Any>?) -> ()) {
        if account == nil {
//            print("-------------ERROR: Account nil")
//            return
            self.makeAuth(completion: { (answer) in
                self.create()
            })
        } else {
            self.create()
        }
    }
    
    func create() {
        var binData : BinaryData = account!.binaryDataString.createBinaryData()!
        
        //MARK: topIndex
        let currencyID = selectedBlockchainType.blockchain.rawValue
        let networkID = selectedBlockchainType.net_type
        var currentTopIndex = account!.topIndexes.filter("currencyID = \(currencyID) AND networkID == \(networkID)").first
        
        if currentTopIndex == nil {
//            mainVC?.presentAlert(with: "TopIndex error data!")
            currentTopIndex = TopIndexRLM.createDefaultIndex(currencyID: NSNumber(value: currencyID), networkID: NSNumber(value: networkID), topIndex: NSNumber(value: 0))
        }
        
        let dict = DataManager.shared.createNewWallet(for: &binData, blockchain: selectedBlockchainType, walletID: currentTopIndex!.topIndex.uint32Value)
        let cell = mainVC?.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! CreateWalletNameTableViewCell
        
        createdWallet.chain = NSNumber(value: currencyID)
        createdWallet.chainType = NSNumber(value: networkID)
        createdWallet.name = cell.walletNameTF.text ?? "Wallet"
        createdWallet.walletID = NSNumber(value: dict!["walletID"] as! UInt32)
        createdWallet.addressID = NSNumber(value: dict!["addressID"] as! UInt32)
        createdWallet.address = dict!["address"] as! String
        
        let params = [
            "currencyID"    : currencyID,
            "networkID"     : networkID,
            "address"       : createdWallet.address,
            "addressIndex"  : createdWallet.addressID,
            "walletIndex"   : createdWallet.walletID,
            "walletName"    : createdWallet.name
            ] as [String : Any]
        
        DataManager.shared.addWallet(params: params) { [unowned self] (dict, error) in
            if error == nil {
                self.mainVC!.sendAnalyticsEvent(screenName: screenCreateWallet, eventName: cancelTap)
                self.mainVC!.openNewlyCreatedWallet()
            } else {
                self.mainVC?.progressHUD.hide()
                self.mainVC?.presentAlert(with: "Error while creating wallet!")
            }
        }
    }
}
