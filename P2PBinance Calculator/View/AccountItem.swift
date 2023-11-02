//
//  AccountItem.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 18.08.2023.
//

import SwiftUI

struct AccountItem: View {
    let account: APIAccount
    
    var body: some View {
        HStack {
            Text(account.name)
                .font(.title3)
            
            Spacer()
            
            
        }
    }
}

struct AccountItem_Previews: PreviewProvider {
    static var previews: some View {
        AccountItem(account: APIAccount(name: "Fizz", apiKey: "dfasklhfslkdfja;lfk", secretKey: "rejhk23j4h3k2j4h"))
    }
}
