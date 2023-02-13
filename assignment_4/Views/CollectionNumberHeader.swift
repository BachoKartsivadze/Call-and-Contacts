//
//  CollectionNumberHeader.swift
//  assignment_4
//
//  Created by bacho kartsivadze on 21.12.22.
//

import UIKit

protocol CollectionNumberHeaderDelegate: AnyObject {
    func didTapAppendButton(header: CollectionNumberHeader, model: NumberCellHeaderViewModel)
}

class CollectionNumberHeader: UICollectionReusableView {
    
    static let identifier = "CollectionNumberHeader"
    
    
    private let charachterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    var appendButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle("Collapse", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    weak var delegate: CollectionNumberHeaderDelegate?
    
    var isAppended = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupheader()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupheader() {
        backgroundColor = .systemGray5
        addSubview(charachterLabel)
        addSubview(appendButton)
        appendButton.addTarget(self, action: #selector(handleTapButton), for: .touchUpInside)
        apllyConstraints()
    }
    
    @objc func handleTapButton(){
        let model = NumberCellHeaderViewModel(charachter: charachterLabel.text ?? "wrong!")
        self.delegate?.didTapAppendButton(header: self, model: model)
    }
    
    public func configure(with model: NumberCellHeaderViewModel) {
        charachterLabel.text = model.charachter.uppercased()
        
        if model.isAppended {
            appendButton.setTitle("Collapse", for: .normal)
        } else {
            appendButton.setTitle("Append", for: .normal)
        }
    }
    
    private func apllyConstraints() {
        let charachterLabelConstraints = [
            charachterLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            charachterLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        
        let appendButtonConstraints = [
            appendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            appendButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(appendButtonConstraints)
        NSLayoutConstraint.activate(charachterLabelConstraints)
    }
}
