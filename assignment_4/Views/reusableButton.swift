//
//  reusableButton.swift
//  assignment_4
//
//  Created by bacho kartsivadze on 24.12.22.
//

import UIKit

class reusableButton: UIView {
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 35)
        return label
    }()
    
    private let letterslabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupButton() {
        backgroundColor = .systemGray5
        let stack = configureStackView()
        addSubview(stack)
        
        applyConstraintsToStack(stackView: stack)
    }
    
    
    private func configureStackView() -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [numberLabel,letterslabel])
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .center
        return stack
    }
    
    private func applyConstraintsToStack(stackView: UIStackView) {
        let stackViewConstraints = [
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(stackViewConstraints)
    }
    
    public func configure(with model: reusableButtonModel) {
        numberLabel.text = model.number
        letterslabel.text = model.letters
    }
    
    public func getNumber() -> String {
        return numberLabel.text ?? ""
    }
    
}
