//
//  PasswordListView.swift
//  PasswordGenerator
//
//  Created by Iliane Zedadra on 06/05/2021.
//

import SwiftUI
import SwiftUIX
import Security
import KeychainSwift

struct PasswordListView: View {
    
    @ObservedObject var passwordViewModel: PasswordListViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showPasswordView = false
    @State private var chosenKey = ""
    @State private var addSheetIsShowing = false
    @State private var password = ""
    @ObservedObject var settings:SettingsViewModel
    @State private var currentUsername = ""
    @State private var showAnimation = false
    @State private var searchText = ""
    
    var body: some View {
        
        NavigationView {
            
            
            
            VStack {
               
                SearchBar("Rechercher un mot de passe", text: $searchText)
                ZStack {
                    
                    if passwordViewModel.keys.isEmpty {

                        VStack {
                        Spacer()
                        Text("Aucun mot de passe a l'horizon...")
                        Spacer()
                        }

                    }
                    
                    if passwordViewModel.keys.isEmpty == false {
                        
                    Form {
                        
                        Section(header: Text("Total : \( self.passwordViewModel.keys.filter {  self.searchText.isEmpty ? true : $0.contains(self.searchText) }.count )")) {
                            List {
                                ForEach(self.passwordViewModel.keys.filter {  self.searchText.isEmpty ? true : $0.contains(self.searchText) }, id: \.self) { key in
                                    
                                let username = key.components(separatedBy: passwordViewModel.separator)
                                HStack {
                                    Button(action: {
                                            chosenKey = key
                                            showPasswordView.toggle()
                                            currentUsername = username[1]
                                    },
                                    label: Text("\(username[1])").foregroundColor(settings.appAppearance == "Nuit" ? .white : .black))
                                }
                            }
                        }
                    }
                }
            }
                    VStack{}
                    .sheet(isPresented: $addSheetIsShowing, content: {
                        SavePasswordView(password: $password, sheetIsPresented: $addSheetIsShowing, generatedPasswordIsPresented: false, viewModel: passwordViewModel, settings: settings).environment(\.colorScheme, colorScheme)
                            .accentColor(settings.colors[settings.accentColorIndex])
                    })
                    .onAppear(perform: {
                        passwordViewModel.getAllKeys()
                        passwordViewModel.getAllUsernames()
                    })
                    .navigationBarTitle("Coffre fort")
                    .navigationBarItems(trailing: Button(action: { addSheetIsShowing.toggle() }, label: {
                        Image(systemName: "plus")
                    }))
                    
                    
                    if passwordViewModel.showAnimation {
                        
                        SavePasswordAnimation(settings: settings)
                            .onAppear(perform: { animationDisappear() })
                            .animation(.easeInOut(duration: 0.5))
        
                    }
                    
                    }
                
               
                    
                .sheet(isPresented: $showPasswordView, content: {
                    PasswordView(key: $chosenKey, viewModel: passwordViewModel, isPresented: $showPasswordView, settings: settings, username: $currentUsername)
                        .environment(\.colorScheme, colorScheme)
                        .accentColor(settings.colors[settings.accentColorIndex])
            })
            }
            
        }
        
    }
    func animationDisappear() {
       DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
           passwordViewModel.showAnimation = false
           print("Show animation")
               }
   }
}


struct PasswordListView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordListView(passwordViewModel: PasswordListViewModel(), settings: SettingsViewModel())
    }
}
