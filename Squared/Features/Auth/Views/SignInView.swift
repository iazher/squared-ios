//
//  SignInView.swift
//  Squared
//

import AuthenticationServices
import SwiftUI

struct SignInView: View {
    @State private var viewModel: SignInViewModel
    let onSignedIn: (User) -> Void

    init(authService: AuthServiceProtocol, onSignedIn: @escaping (User) -> Void) {
        _viewModel = State(initialValue: SignInViewModel(authService: authService))
        self.onSignedIn = onSignedIn
    }

    var body: some View {
        // Fixed-height block, centered via the outer .frame(maxHeight: .infinity).
        VStack(spacing: 0) {
            Image("SquaredApplogo")
                .resizable()
                .scaledToFit()
                .frame(width: 156, height: 156)

            Text("Get squared up.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                // Nudged right to align with the logo's optical center.
                .offset(x: 8)
                .padding(.top, 16)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .padding(.top, 16)
            }

            // Native button — no custom spinner; disable instead while signing in.
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                Task {
                    if let user = await viewModel.handleAuthorization(result) {
                        onSignedIn(user)
                    }
                }
            }
            .signInWithAppleButtonStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .disabled(viewModel.isSigningIn)
            .padding(.top, 48)

            Text("By continuing, you agree to our Terms of Service and Privacy Policy.")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.top, 16)

            #if DEBUG
            // Guaranteed fallback if the real button's completion handler never fires.
            Button("DEBUG: Skip Sign In") {
                onSignedIn(MockData.currentUser)
            }
            .font(.caption2)
            .foregroundStyle(.white.opacity(0.35))
            .padding(.top, 20)
            #endif
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("AppBackground").ignoresSafeArea())
    }
}

#Preview {
    SignInView(authService: AuthService(apiClient: MockAPIClient()), onSignedIn: { _ in })
}
