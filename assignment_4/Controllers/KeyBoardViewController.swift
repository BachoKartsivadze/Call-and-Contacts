//
//  KeyBoardViewController.swift
//  assignment_4
//
//  Created by bacho kartsivadze on 24.12.22.
//

import UIKit

struct keyPadConstants {
    let numbersAsStrings = ["1","2","3","4","5","6","7","8","9","*","0","#","","",""]
    let lettersAsStrings = ["","ABC","DEF","GHI","JKL","MNO","PQRS","TUV","WXYZ","","+","","","",""]
    let numberOfButtons = 15
    let maxLengthOfDialNumber: Int = 16
    let minLengthOfDialNumber: Int = 0
}

class KeyBoardViewController: UIViewController {
    
    private let constants = keyPadConstants()
    
    var dbContext = DBManager.shared.persistentContainer.viewContext
    
    private var buttons: [reusableButton] = []
    
    private let textField = UITextField()
    
    private let addButton = UIButton()
    
    private var dialNumber = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        createAndAddButtons()
        addTextFieldAndAddButton()
        addGestures()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyConstraints()
        for button in buttons {
            button.layer.cornerRadius = button.frame.height / 2
        }
    }

    private func addGestures() {
        
        for index in 0...buttons.count-1 {
            if index < 12 {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapButton(gesture:)))
                buttons[index].addGestureRecognizer(tapGesture)
            } else if index == 13 {
                // handle tap call
            } else if index == 14 {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDeleteButton(gesture:)))
                buttons[index].addGestureRecognizer(tapGesture)
            }
        }
    }
    
    @objc func handleTapButton(gesture: UITapGestureRecognizer) {
        if dialNumber.count == constants.maxLengthOfDialNumber { return }
        
        switch gesture.state {
        case .ended:
            if let button = gesture.view as? reusableButton {
                dialNumber += button.getNumber()
                textField.text = dialNumber
                
                button.alpha = 0.5
                UIView.animate(
                    withDuration: 0.2,
                    animations: {
                        button.alpha = 1
                    }
                )
            }
        default: break
        }
    }
    
    @objc func handleDeleteButton(gesture: UITapGestureRecognizer) {
        if dialNumber.count == constants.minLengthOfDialNumber { return }
        
        // animation
        gesture.view!.alpha = 0.5
        UIView.animate(
            withDuration: 0.2,
            animations: {
                gesture.view!.alpha = 1
            }
        )
        
        
        switch gesture.state {
        case .ended:
            dialNumber = String(dialNumber.prefix(dialNumber.count-1))
            textField.text = dialNumber
        default: break
        }
    }
    
    
    private func addTextFieldAndAddButton() {
        view.addSubview(textField)
        textField.font = .systemFont(ofSize: 35)
        textField.text = ""
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(addButton)
        addButton.setTitle("Add Number", for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 20)
        addButton.titleLabel?.textAlignment = .center
        addButton.setTitleColor(.systemBlue, for: .normal)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addNumberToContacts), for: .touchUpInside)
    }
    
    @objc func addNumberToContacts() {
        
        // create alert
        let alert = UIAlertController(
            title: "Add Contact",
            message: "input name and number to add new member of the contact list",
            preferredStyle: .alert
        )
        
        
        // add elements to alert
        alert.addTextField {[unowned self] textField in
            textField.placeholder = "Name"
            textField.keyboardType = .default
            textField.addTarget(self, action: #selector(self.nameInputed(textField:)), for: .editingChanged)
        }
        
        alert.addTextField {[unowned self] textField in
            textField.placeholder = "Number"
            textField.keyboardType = .numberPad
            textField.text = dialNumber
            textField.addTarget(self, action: #selector(self.numberInputed(textField:)), for: .editingChanged)
        }
        // actions
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel
            )
        )
        alert.addAction(UIAlertAction(
            title: "Add",
            style: .default,
            handler: {[unowned self] _ in
                let person = Person(context: dbContext)
                person.name = textField.text?.lowercased()
                person.number = dialNumber
                do {
                    try dbContext.save()
                } catch {}
                textField.text = dialNumber
            }
        )
        )
        present(alert, animated: true)
    }
    
    @objc func nameInputed(textField: UITextField) {
        self.textField.text = textField.text
    }
    
    @objc func numberInputed(textField: UITextField) {
        dialNumber = textField.text ?? dialNumber
    }
    
    
    
    func createAndAddButtons() {
        
        for index in 0...(constants.numberOfButtons-1) {
            let button = reusableButton()
            let model = reusableButtonModel(number: constants.numbersAsStrings[index], letters: constants.lettersAsStrings[index])
            button.configure(with: model)
            button.frame = CGRect(origin: .zero, size: CGSize(width: 90, height: 90))
            buttons.append(button)
            
            if index < 3 {
                stack123.addArrangedSubview(button)
            } else if index < 6 {
                stack456.addArrangedSubview(button)
            } else if index < 9 {
                stack789.addArrangedSubview(button)
            }else if index < 12 {
                stack0.addArrangedSubview(button)
            } else {
                callStack.addArrangedSubview(button)
            }
        }
        
        configureCallStackViews()
        
        createandAddStackViews()
        
    }
    
    private func configureCallStackViews() {
        let callImigeView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        callImigeView.image = UIImage(systemName: "phone.fill")
        callImigeView.backgroundColor = .green
        callImigeView.tintColor = .white
        callImigeView.contentMode = .scaleAspectFit
        buttons[13].addSubview(callImigeView)
        buttons[13].backgroundColor = .green
        callImigeView.translatesAutoresizingMaskIntoConstraints = false
        callImigeView.centerXAnchor.constraint(equalTo: buttons[13].centerXAnchor).isActive = true
        callImigeView.centerYAnchor.constraint(equalTo: buttons[13].centerYAnchor).isActive = true
        callImigeView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        callImigeView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        let deleteImigeView = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 30))
        deleteImigeView.image = UIImage(systemName: "delete.left")
        deleteImigeView.tintColor = .darkGray
        deleteImigeView.contentMode = .scaleAspectFit
        buttons[14].addSubview(deleteImigeView)
        buttons[14].backgroundColor = .clear
        deleteImigeView.translatesAutoresizingMaskIntoConstraints = false
        deleteImigeView.centerXAnchor.constraint(equalTo: buttons[14].centerXAnchor).isActive = true
        deleteImigeView.centerYAnchor.constraint(equalTo: buttons[14].centerYAnchor).isActive = true
        deleteImigeView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        deleteImigeView.widthAnchor.constraint(equalToConstant: 45).isActive = true
        
        buttons[12].backgroundColor = .clear
    }
    
    private func createandAddStackViews() {
        mainStack.addArrangedSubview(stack123)
        mainStack.addArrangedSubview(stack456)
        mainStack.addArrangedSubview(stack789)
        mainStack.addArrangedSubview(stack0)
        mainStack.addArrangedSubview(callStack)
        
        view.addSubview(mainStack)
    }
    
    
    let stack123: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let stack456: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let stack789: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let stack0: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let callStack: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    let mainStack: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    private func applyConstraints() {
        
        let textFieldConstraints = [
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            textField.topAnchor.constraint(equalTo: view.topAnchor, constant: 110)
        ]
        NSLayoutConstraint.activate(textFieldConstraints)
        
        let addButtonConstraints = [
            addButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        NSLayoutConstraint.activate(addButtonConstraints)
        
        let mainStackConstraints = [
            mainStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -90),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            mainStack.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 50)
        ]
        NSLayoutConstraint.activate(mainStackConstraints)
        
        let secondaryStacksConstraints = [
            stack123.widthAnchor.constraint(equalTo: mainStack.widthAnchor),
            stack456.widthAnchor.constraint(equalTo: mainStack.widthAnchor),
            stack789.widthAnchor.constraint(equalTo: mainStack.widthAnchor),
            stack0.widthAnchor.constraint(equalTo: mainStack.widthAnchor),
            callStack.widthAnchor.constraint(equalTo: mainStack.widthAnchor)
        ]
        NSLayoutConstraint.activate(secondaryStacksConstraints)
        
        // set button sizes
        for button in buttons {
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 90).isActive = true
            button.widthAnchor.constraint(equalToConstant: 90).isActive = true
            
        }
        
    }
    
}
