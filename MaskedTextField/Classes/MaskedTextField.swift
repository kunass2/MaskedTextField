//
//  MaskedTextField.swift
//  PlusPay
//
//  Created by Bartłomiej Semańczyk on 23/02/2021.
//  Copyright © 2021 MS Leopard. All rights reserved.
//
import UIKit

public protocol MaskedTextFieldDelegate: AnyObject {
    func replacedText(for text: String, type: UITextContentType?) -> String?
}

open class MaskedTextField: UITextField, UITextFieldDelegate {
    public weak var maskedTextFieldDelegate: MaskedTextFieldDelegate?
    private var localUnmaskedText = ""

    /// array of characters which will be returned as unmaskedTextWithAllowedCharacters
    ///
    /// EXAMPLE:
    /// if you use "A ___ + ___" as a patternMask, "_" as placeholderCharacter and ["A", "+"] for allowedCharactersForUnmaskedText
    /// then you will be returned "A___+___" from unmaskedTextWithAllowedCharacters instead of "______"
    public var allowedCharactersForUnmaskedText = [String]()

    /// property to indicate what characters will be replaced by user while typing in text field
    /// default: "_"
    ///
    /// EXAMPLE:
    /// if you use "___ + ___" as a patternMask and "_" as placeholderCharacter
    /// then you will be replacing only places with "_" from the pattern
    public var placeholderCharacter = "_"
    override open var delegate: UITextFieldDelegate? {
        didSet {
            guard delegate is MaskedTextField else {
                fatalError("You cannot use delegate for Masked Text Field.")
            }
        }
    }

    private var isMaskingTurnedOn: Bool {
        !patternMask.isEmpty && !placeholderCharacter.isEmpty
    }

    private var maximumPrefix: String {
        var value = prefix
        for character in patternMask {
            let char = String(character)
            if char != placeholderCharacter {
                value += char
            } else {
                break
            }
        }
        return value
    }

    private var unmaskedTextWithoutPrefix: String {
        if localUnmaskedText.hasPrefix(prefix) {
            return String(localUnmaskedText.dropFirst(prefix.count))
        }
        return localUnmaskedText
    }

    private var maximumCountForUnmaskedText: Int {
        (prefix + patternMask.filter { String($0) == placeholderCharacter }).count
    }

    /// returns if all characters defined as placeholderCharacter was filled in patternMark
    public var isFinished: Bool {
        unmaskedText.count == maximumCountForUnmaskedText
    }

    /// returns unmaskedText, only characters defined as placeholderCharacter in patternMask
    public var unmaskedText: String {
        get {
            if isMaskingTurnedOn {
                return localUnmaskedText
            } else {
                return text ?? ""
            }
        }
        set {
            var temporaryUnmaskedText = newValue
            for character in allowedCharactersForUnmaskedText {
                temporaryUnmaskedText = temporaryUnmaskedText.replacingOccurrences(of: String(character), with: "")
            }
            localUnmaskedText = temporaryUnmaskedText
            if isMaskingTurnedOn {
                updateText()
                setCursorPositionToActivePlace()
            } else {
                text = localUnmaskedText
            }
        }
    }

    /// returns unmaskedText with allowed additional characters from patternMask
    ///
    /// EXAMPLE:
    /// if you use "A ___ + ___" as a patternMask, "_" as placeholderCharacter and ["A", "+"] for allowedCharactersForUnmaskedText
    /// then you will be returned "A___+___" from unmaskedTextWithAllowedCharacters instead of "______"
    public var unmaskedTextWithAllowedCharacters: String {
        if !isMaskingTurnedOn {
            return unmaskedText
        }
        var value = prefix
        var temporaryUnmaskedText = unmaskedTextWithoutPrefix
        for character in patternMask {
            let char = String(character)
            if char != placeholderCharacter {
                if allowedCharactersForUnmaskedText.contains(char) {
                    value += char
                }
            } else {
                if let char = temporaryUnmaskedText.first {
                    temporaryUnmaskedText.removeFirst()
                    value += String(char)
                }
            }
        }
        return value
    }

    /// prefix for starting value, always included, cannot be changed or removed while typing
    public var prefix = "" {
        didSet {
            unmaskedText = prefix
        }
    }

    /// defines how to fill your text field
    public var patternMask = "" {
        didSet {
            unmaskedText = prefix
        }
    }

    // MARK: - Initialization

    public required init() {
        super.init(frame: .zero)
        setupActions()
    }

    public required init?(coder _: NSCoder) {
        nil
    }

    // MARK: - Private

    private func updateText() {
        if !isMaskingTurnedOn {
            return
        }
        var value = prefix
        var temporaryUnmaskedText = unmaskedTextWithoutPrefix
        for character in patternMask {
            if String(character) == placeholderCharacter, !temporaryUnmaskedText.isEmpty {
                value += String(temporaryUnmaskedText.removeFirst())
            } else {
                value += String(character)
                if !temporaryUnmaskedText.isEmpty, String(character) == String(temporaryUnmaskedText.first!) {
                    temporaryUnmaskedText.removeFirst()
                }
            }
        }
        text = value
    }

    private func setCursorPositionToActivePlace() {
        if !isMaskingTurnedOn {
            return
        }
        var currentValue = unmaskedTextWithoutPrefix
        var offset = prefix.count
        for character in patternMask {
            if String(character) == placeholderCharacter {
                if !currentValue.isEmpty {
                    currentValue.removeFirst()
                    offset += 1
                } else {
                    break
                }
            } else {
                offset += 1
            }
        }
        if let position = position(from: beginningOfDocument, offset: offset) {
            selectedTextRange = textRange(from: position, to: position)
        }
    }

    private func setupActions() {
        delegate = self
        addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }

    @objc
    private func editingChanged(for _: UITextField) {
        updateText()
        setCursorPositionToActivePlace()
    }

    // MARK: - Internal

    open func focus() {
        becomeFirstResponder()
        setCursorPositionToActivePlace()
    }

    // MARK: - UITextFieldDelegate

    public func textField(
        _: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if string.count > 1 {
            localUnmaskedText = maskedTextFieldDelegate?.replacedText(for: string, type: textContentType) ?? string
            return true
        }
        let value = text!.replacingCharacters(in: Range(range, in: text!)!, with: string)
        let shouldChange = value.hasPrefix(maximumPrefix) && string.count <= 1
        if shouldChange {
            if string.isEmpty {
                _ = localUnmaskedText.popLast()
            } else if localUnmaskedText.count + 1 <= maximumCountForUnmaskedText {
                localUnmaskedText.append(string)
            }
        }
        return shouldChange || !isMaskingTurnedOn
    }

    public func textFieldDidChangeSelection(_: UITextField) {
        setCursorPositionToActivePlace()
    }

    public func textFieldDidBeginEditing(_: UITextField) {
        updateText()
        setCursorPositionToActivePlace()
    }
}
