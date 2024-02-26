//
//  TaskRow.swift
//  tasklistdemoIOS
//
//  Created by Carolina Morales Aguayo on 31/8/23.
//

import SwiftUI

struct JobRow: View {
    var name: String
    var status: status_enum
    
    var body: some View {
        HStack(spacing: 20){
            Text(name)
            Text(status.rawValue)
        }
    }
}

struct TaskRow_Previews: PreviewProvider {
    static var previews: some View {
        JobRow(name: "Do laundry", status: status_enum.todo)
    }
}
