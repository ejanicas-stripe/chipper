//
//  DiscoveryMethodViewController.swift
//  Chipper
//
//  Created by Ben Guo on 9/13/18.
//  Modified by Eduardo Janicas on 09/05/22
//  Copyright © 2018 Stripe. All rights reserved.
//

import Foundation
import StripeTerminal
import Static

class DiscoveryMethodViewController: TableViewController {

    var onSelectedMethod: (DiscoveryMethod) -> Void = { _ in }
    let method: DiscoveryMethod

    init(method: DiscoveryMethod) {
        self.method = method
        super.init(style: .grouped)
        title = "Discovery Method"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addKeyboardDisplayObservers()
        updateContent()
    }

    private func updateContent() {
        dataSource.sections = [
            Section(header: "", rows: [
                Row(text: "Bluetooth Proximity", selection: { [unowned self] in
                    self.onSelectedMethod(.bluetoothProximity)
                    self.navigationController?.popViewController(animated: true)
                    }, accessory: (method == .bluetoothProximity ? .checkmark : .none))
            ], footer: "Discover a reader by holding it next to the iOS device (only supported for the BBPOS Chipper 2X BT and Stripe M2).\n\nNote: the Stripe Terminal SDK can discover supported readers automatically – you should not connect to the reader in the iOS Settings > Bluetooth page."),
        ]
    }

}
