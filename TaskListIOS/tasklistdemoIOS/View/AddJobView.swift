//
//  AddTaskView.swift
//  tasklistdemoIOS
//
//  Created by Carolina Morales Aguayo on 31/8/23.
//

import SwiftUI

struct AddTaskView: View {

    @EnvironmentObject var realmRepo: RealmRepo
    @State private var title: String = ""
    @Environment(\.dismiss)  var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing:20)
        {
            Text("Create a new job").font(.title3).bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("Enter your job here", text: $title)
                .textFieldStyle(.roundedBorder)
            
            Button {
                if title != "" {
                    realmRepo.addJob(jobTitle: title)
                }
                dismiss()
            } label: {
                Text("Add job").foregroundColor(.white)
                    .padding()
                    .padding(.horizontal)
                    .background(Color(hue: 0.328, saturation:0.796, brightness:0.408))
                    .cornerRadius(30)
            }
            Spacer()
        }
        .padding(.top, 40)
        .padding(.horizontal)

    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView().environmentObject(RealmRepo())
    }
}
