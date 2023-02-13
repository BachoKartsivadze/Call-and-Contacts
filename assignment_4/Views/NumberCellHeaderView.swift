//
//  NumberCellHeaderView.swift
//  assignment_4
//
//  Created by bacho kartsivadze on 18.12.22.
//

import UIKit

protocol NumberCellHeaderViewDelegate: AnyObject {
    func didTapAppendButton(header: NumberCellHeaderView, model: NumberCellHeaderViewModel)
}

class NumberCellHeaderView: UITableViewHeaderFooterView {
    
    static let identifier = "NumberCellHeaderView"
    
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
    
    weak var delegate: NumberCellHeaderViewDelegate?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupheader()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupheader() {
        contentView.backgroundColor = .systemGray5
        contentView.addSubview(charachterLabel)
        contentView.addSubview(appendButton)
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
            charachterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
            charachterLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        
        let appendButtonConstraints = [
            appendButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            appendButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(appendButtonConstraints)
        NSLayoutConstraint.activate(charachterLabelConstraints)
    }
}
