//
//  BinanceAccountView.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 18.08.2023.
//

import SwiftUI

struct BinanceAccountView: View {
    enum AccountAction: Equatable {
        case create
        case update(_ account: APIAccount)
    }
    
    //MARK: - Properties
    let action: AccountAction
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: GeneralViewModel
    @Binding var isPresented: Bool
    @Binding var didChangeAPI: Bool
    @State var emptyFieldErrorFlag = false
    @State private var accountName = ""
    @State private var apiKey = ""
    @State private var secretKey = ""
    @State private var exchange: ExchangeConnection.Exchange = .binance
    @State private var instructionAlert = false
    @FocusState private var nameFieldFocused: Bool
    @FocusState private var apiKeyFieldFocused: Bool
    @FocusState private var secretKeyFieldFocused: Bool
    
    //MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack {
                    nameTextField
                        .padding()
                    
                    apiKeyTextField
                        .padding(.horizontal)
                        .padding(.bottom)
                    
                    secretKeyTextField
                        .padding(.horizontal)
                        .padding(.bottom)
                    
                    exchangePicker
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    
                    if action == .create {
                        instructionLink
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                if !nameFieldFocused {
                    keyboardToolbarPasteButton
                }
            }
            
            saveButton
                .padding(.top, -100)
        }
        .ignoresSafeArea(.keyboard)
        .navigationTitle("Account API")
        .onAppear {
            onAppearTask()
        }
        .background(.background)
        .onTapGesture {
            onTapBackgroundTask()
        }
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
    
    private var exchangePicker: some View {
        LabeledContent {
            Picker("Exchange", selection: $exchange) {
                ForEach(ExchangeConnection.Exchange.allCases, id: \.self) { exch in
                    Text(exch.rawValue)
                        .tag(exch)
                }
            }
            .pickerStyle(.menu)
        } label: {
            Text("Exchange")
                .font(.title3)
                .bold()
        }
    }
    
    private var instructionLink: some View {
        Text("How to create API keys")
            .foregroundColor(.blue)
            .confirmationDialog(#"Only "Enable Reading" is needed to be set in API restrictions"#, isPresented: $instructionAlert, titleVisibility: .visible) {
                Link("Create Binance API", destination: URL(string: "https://www.binance.com/en-BH/support/faq/how-to-create-api-360002502072")!)
                Link("Create Commex API (russian)", destination: URL(string: "https://fsr-develop.ru/blog_cscalp/tpost/kak-sozdat-kljuchi-api-na-birzhe-commex")!)
            }
            .onTapGesture {
                instructionAlert.toggle()
            }
    }
    
    private var saveButton: some View {
        Button() {
            checkFieldsAndSave { newAccount in
                didChangeAPI = true
                dismiss()
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
        .contextMenu(menuItems: {
            Button {
                checkFieldsAndSave { newAccount in
                    viewModel.selectedAccount = newAccount
                    didChangeAPI = true
                    isPresented = false
                }
            } label: {
                Label("Save and select", systemImage: "checkmark.circle")
            }

        })
        .tint(SettingsStorage.pickedAppColor)
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
    
    private var keyboardToolbarPasteButton: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            
            PasteButton(payloadType: String.self) { strings in
                guard let string = strings.first else { return }
                if apiKeyFieldFocused {
                    apiKey = string
                } else if secretKeyFieldFocused {
                    secretKey = string
                }
            }
            .tint(SettingsStorage.pickedAppColor)
        }
    }
    
    //MARK: - Methods
    private func onAppearTask() {
        switch action {
        case .create:
            break
        case .update(let account):
            accountName = account.name
            apiKey = account.apiKey
            secretKey = account.secretKey
            exchange = account.exchange
        }
    }
    
    private func onTapBackgroundTask() {
        nameFieldFocused = false
        apiKeyFieldFocused = false
        secretKeyFieldFocused = false
    }
    
    private func checkFieldsAndSave(successHandler: (APIAccount) -> Void) {
        if accountName.isEmpty || apiKey.isEmpty || secretKey.isEmpty {
            emptyFieldErrorFlag.toggle()
        } else {
            let newAccount = APIAccount(
                name: accountName,
                apiKey: apiKey,
                secretKey: secretKey,
                exchange: exchange
            )
            switch action {
            case .create:
                viewModel.addAPIAccount(newAccount, completionHandler: nil)
            case .update(let prevAccount):
                viewModel.updateAccount(prevAccount, to: newAccount, completionHandler: nil)
            }
            
            successHandler(newAccount)
        }
    }
}

struct BinanceAccountView_Previews: PreviewProvider {
    static let action: BinanceAccountView.AccountAction = .update(APIAccount(name: "Fizz", apiKey: "kfhhl23kh23", secretKey: "32kj4hkjf2ekf"))
    
    static var previews: some View {
        BinanceAccountView(action: BinanceAccountView_Previews.action, isPresented: .constant(true), didChangeAPI: .constant(true))
            .environmentObject(GeneralViewModelMock(dataStorage: DataStorageMock()) as GeneralViewModel)
    }
}
