//
//  SignInView.swift
//  Squared
//

import SwiftUI

struct SignInView: View {
    @State private var viewModel: SignInViewModel
    let onSignedIn: (User) -> Void

    init(authService: AuthServiceProtocol, onSignedIn: @escaping (User) -> Void) {
        _viewModel = State(initialValue: SignInViewModel(authService: authService))
        self.onSignedIn = onSignedIn
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Squared")
                .font(.largeTitle.bold())

            TextField("Email", text: $viewModel.email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $viewModel.password)
                .textContentType(.password)
                .textFieldStyle(.roundedBorder)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            // Spinner belongs on the button itself — it reflects an in-flight
            // action the user just triggered, not data loading.
            Button {
                Task {
                    if let user = await viewModel.signIn() {
                        onSignedIn(user)
                    }
                }
            } label: {
                if viewModel.isSigningIn {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isSigningIn)
        }
        .padding()
    }
}

#Preview {
    SignInView(authService: AuthService(apiClient: MockAPIClient()), onSignedIn: { _ in })
}
