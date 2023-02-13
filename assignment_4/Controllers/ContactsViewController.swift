//
//  ContactsViewController.swift
//  assignment_4
//
//  Created by bacho kartsivadze on 18.12.22.
//

import UIKit
import CoreData

class ContactsViewController: UIViewController {
    
    private var layoutIsNormal = true
    
    
    private var data: [SectionModel] = []
    
    // coredata
    var dbContext = DBManager.shared.persistentContainer.viewContext

    
    private let constant = constants()
    
    private var currentName = ""
    private var currentNumber = ""
    
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(NormalNumberCell.self, forCellReuseIdentifier: NormalNumberCell.identifier)
        table.register(NumberCellHeaderView.self, forHeaderFooterViewReuseIdentifier: NumberCellHeaderView.identifier)
        return table
    }()
    
    private let collectioView: UICollectionView = {

        // create layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let itemWidth = 100
        let itemHeight = 100
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        
        // create collectionView
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(CollectionNumberCell.self, forCellWithReuseIdentifier: CollectionNumberCell.identifier)
        collection.register(CollectionNumberHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionNumberHeader.identifier)
        collection.isHidden = true
        collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        
        return collection
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavBar()
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        collectioView.delegate = self
        collectioView.dataSource = self
        view.addSubview(collectioView)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchPeople()
    }
    
    func fetchPeople() {
        data = []
        for char in "abcdefghijklmnopqrstuvwxyz" {
            let request = Person.fetchRequest() as NSFetchRequest<Person>
            
            let preicate = NSPredicate(format: "name BEGINSWITH %@", "\(char)")
            let sort = NSSortDescriptor(key: "name", ascending: true)
            
            request.predicate = preicate
            request.sortDescriptors = [sort]
            do {
                let numberCells = try dbContext.fetch(request)
                if numberCells.count == 0 {continue}
                let newHeaderModel = NumberCellHeaderViewModel(charachter: "\(char)")
                let newSectionModel = SectionModel(headerModel: newHeaderModel, numberCells: numberCells)
                data.append(newSectionModel)
            } catch {
                fatalError()
            }
        }
        tableView.reloadData()
        collectioView.reloadData()
    }
    
    


    private func configureNavBar() {
        navigationItem.title = "Contacts"
        navigationController?.navigationBar.backgroundColor = .systemGray6
        
        let leftImige = UIImage(systemName: "plus")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: leftImige, style: .done, target: self, action: #selector(addContact))
        
        let rightImige = UIImage(systemName: "square.grid.3x3.fill")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: rightImige, style: .done, target: self, action: #selector(changeLayout))
    }
    
    
    @objc func addContact() {
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
            textField.addTarget(self, action: #selector(self.numberInputed(textField:)), for: .editingChanged)
        }
        
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: { [unowned self] _ in
                    currentName = ""
                    currentNumber = ""
                }
            )
        )
        alert.addAction(UIAlertAction(
            title: "Add",
            style: .default,
            handler: {[unowned self] _ in
                let person = Person(context: dbContext)
                person.name = currentName.lowercased()
                person.number = currentNumber
                do {
                    try dbContext.save()
                    fetchPeople()
                } catch {}
            }
        )
        )
        present(alert, animated: true)
    }
    
    
    
    private func takeFirstCharacter(from word: String) -> String {
        let result = word.first!.uppercased()
        return "\(result)"
    }
    
    @objc func nameInputed(textField: UITextField) {
        currentName = textField.text ?? ""
    }
    
    @objc func numberInputed(textField: UITextField) {
        currentNumber = textField.text ?? ""
    }
    
    @objc func changeLayout() {
        if layoutIsNormal {
            layoutIsNormal.toggle()
            navigationItem.rightBarButtonItem?.image = UIImage(systemName: "line.3.horizontal")
            tableView.isHidden = true
            collectioView.isHidden = false
            fetchPeople()
        } else {
            layoutIsNormal.toggle()
            navigationItem.rightBarButtonItem?.image = UIImage(systemName: "square.grid.3x3.fill")
            collectioView.isHidden = true
            tableView.isHidden = false
            fetchPeople()
        }
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        collectioView.frame = view.bounds
    }
}

//`````````````````````````````````````````````````````````````````````````````````````````````````````````````````````

extension ContactsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !data[section].isApended {
            return 0
        }
        return data[section].numberCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NormalNumberCell.identifier) as? NormalNumberCell else {
            return UITableViewCell()
        }
        
        cell.namelabel.text = data[indexPath.section].numberCells[indexPath.row].name ?? "Error"
        cell.numberLabel.text = data[indexPath.section].numberCells[indexPath.row].number ?? "Error"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return constant.tableViewCellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NumberCellHeaderView.identifier) as? NumberCellHeaderView else {
            return UITableViewHeaderFooterView()
        }
        
        var model = NumberCellHeaderViewModel(charachter: data[section].headerModel.charachter)
        model.isAppended = data[section].headerModel.isAppended
        header.configure(with: model)
        header.delegate = self
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return constant.headerHeight
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete", handler: {[unowned self] _,_,_ in
            deleteCell(at: indexPath)
        })
        
        let configuration = UISwipeActionsConfiguration(actions: [delete])
        return configuration
    }
    
    private func deleteCell(at indexPath: IndexPath) {
        // delete from coreData
        let person = data[indexPath.section].numberCells[indexPath.row]
        dbContext.delete(person)

        do {
            try dbContext.save()
           fetchPeople()
        } catch {}
        
//        if data[indexPath.section].numberCells.count > 1 {
//            let index = indexPath.row
//            data[indexPath.section].numberCells.remove(at: index)
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//            collectioView.deleteItems(at: [indexPath])
//        } else {
//            let index = indexPath.section
//            data.remove(at: index)
//            tableView.deleteSections(IndexSet(integer: index), with: .automatic)
//            collectioView.deleteSections(IndexSet(integer: index))
//        }
    }
    
    @objc func handleDelete(longpressGestureRecognizer: UILongPressGestureRecognizer) {
        if (longpressGestureRecognizer.state == .began) {
            let location = longpressGestureRecognizer.location(in: collectioView)
            if let indexPath = collectioView.indexPathForItem(at: location) {
                let alert = UIAlertController(
                           title: "Delete?",
                           message: "Are you sure you want to delete \(data[indexPath.section].numberCells[indexPath.row].name ?? "Error!") from your contacts?",
                           preferredStyle: .actionSheet
                       )
               
                       alert.addAction(UIAlertAction(
                           title: "Delete",
                           style: .destructive,
                           handler:  {[unowned self] _ in
               
                               
                               let person = data[indexPath.section].numberCells[indexPath.row]
                               dbContext.delete(person)

                               do {
                                   try dbContext.save()
                                  fetchPeople()
                               } catch {}
//                               if data[indexPath.section].numberCells.count > 1 {
//                                   let index = indexPath.row
//                                   data[indexPath.section].numberCells.remove(at: index)
//                                   tableView.deleteRows(at: [indexPath], with: .automatic)
//                                   collectioView.deleteItems(at: [indexPath])
//                               } else {
//                                   let index = indexPath.section
//                                   data.remove(at: index)
//                                   tableView.deleteSections(IndexSet(integer: index), with: .automatic)
//                                   collectioView.deleteSections(IndexSet(integer: index))
//                               }
                           }
                       )
                       )
               
                       alert.addAction(UIAlertAction(title: "Cancel", style: .default))
               
                       present(alert, animated: true)
            }
        }
    }
    
}

extension ContactsViewController: NumberCellHeaderViewDelegate {
    func didTapAppendButton(header: NumberCellHeaderView, model: NumberCellHeaderViewModel) {
        
        for sectionIndex in 0...data.count-1 {
            if data[sectionIndex].headerModel.charachter.uppercased() == model.charachter {
                data[sectionIndex].isApended.toggle()
                data[sectionIndex].headerModel.isAppended.toggle()
                header.configure(with: data[sectionIndex].headerModel)
                tableView.reloadSections(IndexSet(integer: sectionIndex), with: .automatic)
                collectioView.reloadSections(IndexSet(integer: sectionIndex))
                return
            }
        }
    }
}


extension ContactsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !data[section].isApended {
            return 0
        }
        return data[section].numberCells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionNumberCell.identifier, for: indexPath) as? CollectionNumberCell else {
            return UICollectionViewCell()
            
        }
    
        cell.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleDelete)))
        
        
        let cellModel = data[indexPath.section].numberCells[indexPath.row]
        cell.namelabel.text = cellModel.name
        cell.numberLabel.text = cellModel.number
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionNumberHeader.identifier, for: indexPath) as? CollectionNumberHeader else {
            return UICollectionReusableView()
        }
        
        var model = NumberCellHeaderViewModel(charachter: data[indexPath.section].headerModel.charachter)
        model.isAppended = data[indexPath.section].headerModel.isAppended
        header.configure(with: model)
        header.delegate = self
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: constant.headerHeight)
    }
}



extension ContactsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if data[section].isApended {
            return UIEdgeInsets(top: constant.layoutInsets, left: constant.layoutInsets, bottom: constant.layoutInsets, right: constant.layoutInsets)
        } else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return constant.collectionViewItemSize
    }
}



extension ContactsViewController: CollectionNumberHeaderDelegate {
    func didTapAppendButton(header: CollectionNumberHeader, model: NumberCellHeaderViewModel) {
        for sectionIndex in 0...data.count-1 {
            if data[sectionIndex].headerModel.charachter.uppercased() == model.charachter {
                data[sectionIndex].isApended.toggle()
                data[sectionIndex].headerModel.isAppended.toggle()
                header.configure(with: data[sectionIndex].headerModel)
                tableView.reloadSections(IndexSet(integer: sectionIndex), with: .automatic)
                collectioView.reloadSections(IndexSet(integer: sectionIndex))
                return
            }
        }
    }
}

