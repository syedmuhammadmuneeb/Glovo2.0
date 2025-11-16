import SwiftUI
import AuthenticationServices

struct ContentView: View {
    @State private var phoneNumber: String = ""
    @State private var selectedPrefix: String = "+39"
    @FocusState private var isPhoneFieldFocused: Bool

    @State private var appleSignInStatus: String?
    @State private var showAppleError: Bool = false

    private var glovoGreen: Color { Color.green }
    
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                Color(.systemBackground).ignoresSafeArea()
                
                // Top banner image with bottom corners rounded
                Image("Glovo background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height * 0.32)
                    .clipShape(RoundedCorner(radius: 32, corners: [.bottomLeft, .bottomRight]))
                    .ignoresSafeArea(edges: .top)
                
                // The form, overlapping the image banner
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: geo.size.height * 0.26)
                    
                    VStack(spacing: 0) {
                        Spacer(minLength: 24)
                        // Welcome title and subtitle
                        VStack(spacing: 6) {
                            Text("Welcome")
                                .font(.largeTitle.bold())
                            Text("Let's start with your phone number")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.bottom, 24)
                        // Input Fields
                        HStack(spacing: 12) {
                            Menu {
                                Button("+39 Italy") { selectedPrefix = "+39" }
                                Button("+44 UK") { selectedPrefix = "+44" }
                                Button("+1 USA") { selectedPrefix = "+1" }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(selectedPrefix)
                                        .font(.body.bold())
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                }
                                .foregroundColor(.black)
                                .padding(.horizontal, 14)
                                .frame(height: 48)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .frame(width: 90)
                            TextField("Phone number", text: $phoneNumber)
                                .keyboardType(.numberPad)
                                .focused($isPhoneFieldFocused)
                                .padding(.horizontal, 12)
                                .frame(height: 48)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .accessibilityLabel("Phone number")
                                .onTapGesture { isPhoneFieldFocused = true }
                        }
                        .padding(.horizontal, 36)
                        .padding(.bottom, 20)
                        // WhatsApp & SMS Buttons (side by side)
                        HStack(spacing: 12) {
                            Button {
                                // WhatsApp action
                            } label: {
                                Text("WhatsApp")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity, minHeight: 48)
                            }
                            .buttonStyle(.bordered)
                            .foregroundColor(.black)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.black.opacity(0.15), lineWidth: 1)
                            )
                            Button {
                                // SMS action
                            } label: {
                                Text("SMS")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity, minHeight: 48)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(glovoGreen)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                        .padding(.horizontal, 36)
                        .padding(.bottom, 24)
                        // Divider with "or with"
                        HStack {
                            Rectangle().frame(height: 1)
                                .foregroundColor(.secondary.opacity(0.3))
                            Text("or with")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Rectangle().frame(height: 1)
                                .foregroundColor(.secondary.opacity(0.3))
                        }
                        .padding(.horizontal, 48)
                        .padding(.bottom, 20)
                        // Only Apple Sign-In Button
                        VStack(spacing: 14) {
                            SignInWithAppleButton(.signIn,
                                onRequest: { request in
                                    // Optionally add requested scopes:
                                    request.requestedScopes = [.fullName, .email]
                                },
                                onCompletion: { result in
                                    switch result {
                                    case .success(let authResults):
                                        if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                                            // You can now use credential fields for your flow
                                            let userIdentifier = appleIDCredential.user
                                            let email = appleIDCredential.email ?? "No email (existing user)"
                                            let fullName = appleIDCredential.fullName?.formatted() ?? "No name"
                                            appleSignInStatus = "Signed in! ID: \(userIdentifier)\nEmail: \(email)\nName: \(fullName)"
                                        }
                                    case .failure(let error):
                                        appleSignInStatus = "Sign in with Apple failed: \(error.localizedDescription)"
                                        showAppleError = true
                                    }
                                }
                            )
                                .signInWithAppleButtonStyle(.black)
                                .frame(height: 48)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                        .padding(.horizontal, 36)
                        .padding(.bottom, 12)
                        Spacer()
                        // Footer disclaimer
                        Text("By continuing, you automatically accept our Terms & Conditions, Privacy Policy and Cookies Policy.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .padding(.bottom, 20)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        Color.white
                            .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
                            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: -2)
                    )
                }
            }
        }
        .alert(isPresented: $showAppleError) {
            Alert(
                title: Text("Sign in with Apple Error"),
                message: Text(appleSignInStatus ?? "Unknown error"),
                dismissButton: .default(Text("OK"))
            )
        }
        .preferredColorScheme(.light)
    }
}

// Helper for only selected corners rounded
struct RoundedCorner: Shape {
    var radius: CGFloat = 12.0
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    ContentView()
}
