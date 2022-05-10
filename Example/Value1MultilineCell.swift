//
//  Value1MultilineCell.swift
//  Chipper
//
//  Created by Brian Cooke on 9/11/20.
//  Modified by Eduardo Janicas on 09/05/22
//  Copyright © 2020 Stripe. All rights reserved.
//

import Static

/**
 Same as Static.Value1Cell, but supports wrapping in the text label if needed.
 */
class Value1MultilineCell: UITableViewCell, Cell {
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        self.textLabel?.numberOfLines = 0
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
