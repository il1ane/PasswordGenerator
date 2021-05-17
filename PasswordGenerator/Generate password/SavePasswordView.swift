//
//  SavePasswordView.swift
//  PasswordGenerator
//
//  Created by Iliane Zedadra on 07/05/2021.
//

import SwiftUI
import SwiftUIX
import KeychainSwift

struct SavePasswordView: View {
    
    @Binding var password: String
    @Binding var sheetIsPresented: Bool
    @ObservedObject var editedPassword = TextBindingManager(limit: 30)
    @State private var username = ""
    @State private var isEditingPassword = false
    @State private var showKeyboard = false
    @State private var passwordLenght = ""
    @State private var showMissingTitleAlert = false
    @State private var showMissingPasswordAlert = false
    @State private var showMissingPasswordAndTitleAlert = false
    @State private var showTitleMissingFooter = false
    @State var generatedPasswordIsPresented: Bool
    @ObservedObject var viewModel = PasswordListViewModel()
    @ObservedObject var settings:SettingsViewModel
    let keyboard = Keyboard()
    let keychain = KeychainSwift()
    
    var body: some View {
        NavigationView {
            
            VStack {
                
                Form {
                    Section(header: Text("Mot de passe").foregroundColor(.gray), footer: passwordLenght.isEmpty ? Text("Le mot de passe ne peut pas être vide").foregroundColor(.red) : nil) {
                        HStack {
                            Spacer()
                            
                            if !isEditingPassword {
                                Text(editedPassword.text)
                                    .foregroundColor(.gray).font(editedPassword.characterLimit > 25 ? .system(size: 15) : .body)
                                
                            } else {
                                
                                CocoaTextField(password, text: $editedPassword.text)
                                    .keyboardType(.asciiCapable)
                                    .isFirstResponder(true)
                                    .disableAutocorrection(true)
                                
                            }
                            Spacer()
                            
                            if !isEditingPassword {
                                
                                Button(action: {
                                    withAnimation {
                                        isEditingPassword.toggle()
                                        showKeyboard = keyboard.isShowing
                                    }
                                    
                                }, label: {
                                    Text("Edit")
                                })
                                .buttonStyle(PlainButtonStyle())
                                .foregroundColor(settings.colors[settings.accentColorIndex])
                                
                            }
                            else {
                                Button(action: {
                                    withAnimation(.default) {
                                        isEditingPassword.toggle()
                                        //showKeyboard doesn't change anything but Xcode stop complaining
                                        //not always working
                                        showKeyboard = keyboard.isShowing
                                    }
                                    
                                }, label: {
                                    Image(systemName: "checkmark")
                                })
                                .buttonStyle(PlainButtonStyle())
                                .foregroundColor(settings.colors[settings.accentColorIndex])
                            }
                        }.alert(isPresented: $showMissingPasswordAlert, content: {
                            Alert(title: Text("Mot de passe invalide"), message: Text("Le champ mot de passe ne peut pas être vide."), dismissButton: .cancel(Text("OK!")))
                            
                        })
                    }
                    
                    Section(header: Text("Nom de compte").foregroundColor(.gray), footer: showTitleMissingFooter ? Text("Champ obligatoire").foregroundColor(.red) : nil ) {
                        TextField("ex: Facebook", text: $username)
                    }.alert(isPresented: $showMissingTitleAlert, content: {
                        Alert(title: Text("Champ manquant"), message: Text("Vous devez au moins donner un nom de compte a votre mot de passe."), dismissButton: .cancel(Text("OK!")))
                        
                    })
                    
                }.alert(isPresented: $showMissingPasswordAndTitleAlert, content: {
                    Alert(title: Text("Champs vides"), message: Text("Le champ mot de passe et intitulé ne peuvent pas être vides."), dismissButton: .cancel(Text("OK!")))
                })
                .navigationBarTitle("Enregistrement")
                .navigationBarItems(leading: Button(action: {
                    
                    sheetIsPresented.toggle()
                    
                }, label: {
                    Image(systemName: "xmark")
                }), trailing: Button(action: {
                    
                    if !isEditingPassword {
                        if username.isEmpty && editedPassword.text.isEmpty {
                            showMissingPasswordAndTitleAlert.toggle()
                            print("Password and title missing")
                        } else if username.isEmpty && editedPassword.text.isEmpty == false {
                            print("Username missing")
                            showTitleMissingFooter = true
                            showMissingTitleAlert.toggle()
                        }
                        else if editedPassword.text.isEmpty && username.isEmpty == false {
                            showMissingPasswordAlert.toggle()
                            print("Password missing")
                        }
                        else {
                            sheetIsPresented.toggle()
                            viewModel.saveToKeychain(password: editedPassword.text, username: username)
                            viewModel.getAllKeys()
                        }
                    }
                    
                }, label: {
                    Image(systemName: "tray.and.arrow.down")
                }).disabled(isEditingPassword ? true : false)
                )
                
            }.onChange(of: editedPassword.text.count, perform: { _ in
                passwordLenght = editedPassword.text
            })
        }.onAppear(perform: {
            if !generatedPasswordIsPresented {
                isEditingPassword = true
            }
            editedPassword.text = password
            passwordLenght = password
        })
    }
}

struct SavePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        SavePasswordView(password: .constant("MotDePasseExtremementCompliqué"), sheetIsPresented: .constant(true), generatedPasswordIsPresented: true, viewModel: PasswordListViewModel(), settings: SettingsViewModel()).accentColor(.green)
    }
}
