//
//  LogoView.swift
//  iPark2
//
//  Created by Yotam Krikov on 4/28/26.
//
//  Creates the iPark logo
//

import SwiftUI

struct LogoView: View {
    var body: some View {
        Text("\(Text("i").foregroundStyle(.blue))\(Text("Park"))")
            .font(.largeTitle.bold())
    }
}
