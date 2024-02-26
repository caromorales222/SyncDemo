//
//  ContentView.swift
//  tasklistdemoIOS
//
//  Created by Carolina Morales Aguayo on 31/8/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var realmRepo = RealmRepo()
    @State private var showAddTaskView = false
    
    var body: some View {
        
        VStack {
            ZStack(alignment: .bottomTrailing){
                TaskView().environmentObject(realmRepo)
                
                SmallAddButton()
                    .padding()
                    .onTapGesture{
                        showAddTaskView.toggle()
                    }
            }
            .sheet(isPresented: $showAddTaskView)
            {
                AddTaskView().environmentObject(realmRepo)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .background(Color(hue:0.086, saturation:0.141, brightness:0.972))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
