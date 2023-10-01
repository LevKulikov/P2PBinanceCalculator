//
//  SettingsSingleAPIAccountView.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 29.09.2023.
//

import SwiftUI

struct SettingsSingleAPIAccountView: View {
    enum AccountAction: Equatable, Hashable {
        case create
        case update(_ account: APIAccount)
    }
    
    //MARK: - Properties
    let action: AccountAction
    @Binding var didChangeApi: Bool
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State var emptyFieldErrorFlag = false
    @State private var accountName = ""
    @State private var apiKey = ""
    @State private var secretKey = ""
    @State private var instructionAlert = false
    @FocusState private var nameFieldFocused: Bool
    @FocusState private var apiKeyFieldFocused: Bool
    @FocusState private var secretKeyFieldFocused: Bool
    private var currentDevice: UIUserInterfaceIdiom {
        UIDevice.current.userInterfaceIdiom
    }
    
    //MARK: - Body
    var body: some View {
        VStack {
            nameTextField
                .padding()
            
            apiKeyTextField
                .padding(.horizontal)
                .padding(.bottom)
            
            secretKeyTextField
                .padding(.horizontal)
                .padding(.bottom, 40)
            
            if action == .create {
                instructioneLink
            }
            
            Spacer()
            
            saveButton
                .padding(.top, -100)
        }
        .navigationTitle("Binance API")
        .onAppear {
            onAppearMethod()
        }
        .background(.background)
        .onTapGesture {
            nameFieldFocused = false
            apiKeyFieldFocused = false
            secretKeyFieldFocused = false
        }
        .toolbar(currentDevice == .phone ? .hidden : .automatic, for: .tabBar)
    }
    
    //MARK: - View properties
    private var nameTextField: some View {
        LabeledContent {
            TextField("Name", text: $accountName, prompt: Text("Any name"))
                .font(.title2)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .submitLabel(.next)
                .focused($nameFieldFocused)
                .onSubmit {
                    apiKeyFieldFocused.toggle()
                }
        } label: {
            Text("Name")
                .font(.title3)
                .bold()
        }
    }
    
    private var apiKeyTextField: some View {
        LabeledContent {
            TextField("API Key", text: $apiKey, prompt: Text("6PnRGU..."))
                .font(.title2)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.none)
                .submitLabel(.next)
                .focused($apiKeyFieldFocused)
                .onSubmit {
                    secretKeyFieldFocused.toggle()
                }
        } label: {
            Text("API Key")
                .font(.title3)
                .bold()
        }
    }
    
    private var secretKeyTextField: some View {
        LabeledContent {
            TextField("Secret Key", text: $secretKey, prompt: Text("mUdRm..."))
                .font(.title2)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.none)
                .submitLabel(.done)
                .focused($secretKeyFieldFocused)
        } label: {
            Text("Secret Key")
                .font(.title3)
                .bold()
        }
    }
    
    private var instructioneLink: some View {
        Text("How to create Binance API")
            .foregroundColor(.blue)
            .confirmationDialog(#"Only "Enable Reading" is needed to be set in API restrictions"#, isPresented: $instructionAlert, titleVisibility: .visible) {
                Link("Open instruction", destination: URL(string: "https://www.binance.com/en-BH/support/faq/how-to-create-api-360002502072")!)
            }
            .onTapGesture {
                instructionAlert.toggle()
            }
    }
    
    private var saveButton: some View {
        Button() {
            checkFieldsAndSave { _ in
                dismiss()
                didChangeApi.toggle()
            }
        } label: {
            Text("Save")
                .foregroundColor(Color(uiColor: UIColor.systemBackground))
                .bold()
                .font(.title3)
                .frame(width: 200)
        }
        .alert("There is at least one empty field", isPresented: $emptyFieldErrorFlag) {
            Text("Ok")
        }
        .tint(SettingsStorage.pickedAppColor)
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
    
    //MARK: - Task methods
    private func onAppearMethod() {
        switch action {
        case .create:
            break
        case .update(let account):
            accountName = account.name
            apiKey = account.apiKey
            secretKey = account.secretKey
        }
    }
    
    private func checkFieldsAndSave(successHandler: (APIAccount) -> Void) {
        if accountName.isEmpty || apiKey.isEmpty || secretKey.isEmpty {
            emptyFieldErrorFlag.toggle()
        } else {
            let newAccount = APIAccount(name: accountName, apiKey: apiKey, secretKey: secretKey)
            switch action {
            case .create:
                settingsViewModel.addAPIAccount(newAccount, completionHandler: nil)
            case .update(let prevAccount):
                settingsViewModel.updateAccount(prevAccount, to: newAccount, completionHandler: nil)
            }
            
            successHandler(newAccount)
        }
    }
}

#Preview {
    let accountToUpdate = APIAccount(name: "Fizz", apiKey: "testAPIKey", secretKey: "testSecretKey")
    
    return SettingsSingleAPIAccountView(action: .update(accountToUpdate), didChangeApi: .constant(false))
        .environmentObject(SettingsViewModel(
            settingsStorage: SettingsStorageMock(),
            dataStorage: DataStorageMock()
        ))
}
