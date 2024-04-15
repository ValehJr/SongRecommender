//
//  PaddedTextField.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 08.04.24.
//

import Foundation
import UIKit

protocol PaddedTextFieldDelegate: AnyObject {
    func textFieldDidDelete()
}


class PaddedTextField: UITextField {

    weak var myDelegate: PaddedTextFieldDelegate?

    override func deleteBackward() {
        super.deleteBackward()
        myDelegate?.textFieldDidDelete()
    }

    let screenSize:CGRect = UIScreen.main.bounds

    private var dynamicPadding: UIEdgeInsets {
        var padding: UIEdgeInsets
        if screenSize.height < 700 {
            padding = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
        } else {
            padding = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
        }

        return padding
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: dynamicPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: dynamicPadding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40))
    }
}
