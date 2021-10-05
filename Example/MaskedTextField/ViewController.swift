//
//  ViewController.swift
//  MaskedTextField
//
//  Created by kunass2 on 02/24/2021.
//  Copyright (c) 2021 kunass2. All rights reserved.
//

import UIKit
import MaskedTextField
import SnapKit
import RxSwift
import RxCocoa

class ViewController: UIViewController, UITextFieldDelegate {
    private let bag = DisposeBag()
    private let textField: MaskedTextField = {
        let textField = MaskedTextField()
        textField.patternMask = " ___/___/___"
        textField.placeholderCharacter = "_"
        textField.prefix = "+68"
        textField.allowedCharactersForUnmaskedText = ["/"]
        textField.textColor = .white
        textField.backgroundColor = .darkGray
        textField.keyboardType = .numberPad
        textField.textAlignment = .center
        textField.tintColor = .white
        return textField
    }()
    private let unmaskedTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    private let unmaskedTextFullLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(textField)
        textField.snp.makeConstraints { maker in
            maker.width.equalTo(300)
            maker.height.equalTo(40)
            maker.centerX.equalToSuperview()
            maker.top.equalTo(100)
        }
        view.addSubview(unmaskedTextLabel)
        unmaskedTextLabel.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.top.equalTo(textField.snp.bottom).offset(20)
            maker.height.equalTo(40)
        }
        view.addSubview(unmaskedTextFullLabel)
        unmaskedTextFullLabel.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.top.equalTo(unmaskedTextLabel.snp.bottom).offset(20)
            maker.height.equalTo(40)
        }
        textField.rx.controlEvent([.editingChanged]).asObservable().subscribe { [weak self] _ in
            self?.unmaskedTextLabel.text = self?.textField.unmaskedText
            self?.unmaskedTextFullLabel.text = self?.textField.unmaskedTextWithAllowedCharacters
        }.disposed(by: bag)
        
        textField.unmaskedText = "111/222/333"
        textField.sendActions(for: .editingChanged)
    }
}
