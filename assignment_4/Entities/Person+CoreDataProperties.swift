//
//  Person+CoreDataProperties.swift
//  assignment_4
//
//  Created by bacho kartsivadze on 21.01.23.
//
//

import Foundation
import CoreData


extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged public var name: String?
    @NSManaged public var number: String?

}

extension Person : Identifiable {

}
