//
//  View+ButtonStyle.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import SwiftUI

extension View {
    func buttonStyle<S: ButtonStyle>(_ style: S, isLoading: Binding<Bool>) -> some View {
        self.buttonStyle(style).environment(\.isLoading, isLoading)
    }
}
