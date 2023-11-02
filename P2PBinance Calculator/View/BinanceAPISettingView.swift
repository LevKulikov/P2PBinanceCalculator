//
//  BinanceAPISettingView.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 11.08.2023.
//

import SwiftUI

struct BinanceAPISettingView: View {
    //MARK: Properties
    @EnvironmentObject var viewModel: GeneralViewModel
    @Binding var isPresented: Bool
    @Binding var didChangeAPI: Bool
    @State var emptyFieldErrorFlag = false
    @State private var apiKey = ""
    @State private var secretKey = ""
    @State private var instructionAlert = false
    @FocusState private var apiKeyFieldFocused: Bool
    @FocusState private var secretKeyFieldFocused: Bool
    
    //MARK: Body
    var body: some View {
        VStack {
            LabeledContent {
                TextField("API Key", text: $apiKey, prompt: Text("6PnRGU..."))
                    .font(.title3)
                    .textFieldStyle(.roundedBorder)
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
            .padding()
            
            LabeledContent {
                TextField("Secret Key", text: $secretKey, prompt: Text("mUdRm..."))
                    .font(.title3)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.done)
                    .focused($secretKeyFieldFocused)
            } label: {
                Text("Secret Key")
                    .font(.title3)
                    .bold()
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
            
            Text("How to create Binance API")
                .foregroundColor(.blue)
                .confirmationDialog(#"Only "Enable Reading" is needed to be set in API restrictions"#, isPresented: $instructionAlert, titleVisibility: .visible) {
                    Link("Open instruction", destination: URL(string: "https://www.binance.com/en-BH/support/faq/how-to-create-api-360002502072")!)
                }
                .onTapGesture {
                    instructionAlert.toggle()
                }
            
            Spacer()
            
            Button() {
                if apiKey.isEmpty || secretKey.isEmpty {
                    emptyFieldErrorFlag.toggle()
                } else {
                    viewModel.setAPIData(apiKey: apiKey, secretKey: secretKey)
                    didChangeAPI = true
                    isPresented = false
                }
            } label: {
                Text("Save and select")
                    .bold()
                    .font(.title3)
                    .frame(width: 200)
            }
            .alert("There is at least one empty field", isPresented: $emptyFieldErrorFlag) {
                Text("Ok")
            }
            .tint(Color("binanceColor"))
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top, -100)
        }
        .navigationTitle("Binance API")
        .onAppear {
            apiKey = viewModel.getAPIKey() ?? ""
            secretKey = viewModel.getSecretKey() ?? ""
        }
        .background(.background)
        .onTapGesture {
            apiKeyFieldFocused = false
            secretKeyFieldFocused = false
        }
    }
    
    //MARK: Methods
}

struct BinanceAPISettingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BinanceAPISettingView(isPresented: .constant(true), didChangeAPI: .constant(false))
                .environmentObject(GeneralViewModelMock(dataStorage: DataStorageMock()) as GeneralViewModel)
        }
    }
}
