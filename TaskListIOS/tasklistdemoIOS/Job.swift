//
//  Task.swift
//  tasklistdemoIOS
//
//  Created by Carolina Morales Aguayo on 31/8/23.
//

import Foundation
import RealmSwift

class Job: Object, ObjectKeyIdentifiable{
    @Persisted(primaryKey: true) var _id: ObjectId = .generate();
    @Persisted var name = ""
    @Persisted var currentStatus = status_enum.todo
    @Persisted var userid = 0;
    @Persisted var history: RealmSwift.List<Status>
    
    /*override init()
    {
        super.init()
        self._id = ObjectId()
    }*/
}

enum status_enum: String, PersistableEnum, CaseIterable
{
    case todo = "TODO"
    case pending = "PENDING"
    case done = "DONE"
}

class Status: EmbeddedObject, ObjectKeyIdentifiable{
    @Persisted var status = status_enum.todo
    @Persisted var date = Date()
}

extension CaseIterable where Self: Equatable {
    func next() -> Self {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let next = all.index(after: idx)
        return all[next == all.endIndex ? all.startIndex : next]
    }
}

