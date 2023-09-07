//
//  TaskView.swift
//  tasklistdemoIOS
//
//  Created by Carolina Morales Aguayo on 31/8/23.
//

import SwiftUI

struct TaskView: View {
    @EnvironmentObject var realmRepo: RealmRepo
    var body: some View {
       
        VStack {
            Text("My tasks").font(.title3).bold()
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            List {
                ForEach(realmRepo.jobs) {
                job in
                    //if !task.isInvalidated {
                    JobRow(name: job.name, status: job.currentStatus)
                            .onTapGesture {
                                realmRepo.updateJob(_id: job._id)
                            }
                            .swipeActions(edge: .trailing){
                                Button (role: .destructive){
                                    realmRepo.deleteJob(_id: job._id)
                                }label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        //}
                    }
                .listRowSeparator(.hidden)
            }.onAppear {
                UITableView.appearance().backgroundColor = UIColor.clear
                UITableViewCell.appearance().backgroundColor = UIColor.clear
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
    
    }
}

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        TaskView().environmentObject(RealmRepo())
    }
}
