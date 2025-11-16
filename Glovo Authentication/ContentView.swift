import SwiftUI
import AuthenticationServices

struct ContentView: View {
    @State private var phoneNumber: String = ""
    @State private var selectedPrefix: String = "+39"
    @FocusState private var isPhoneFieldFocused: Bool

    @State private var appleSignInStatus: String?
    @State private var showAppleError: Bool = false

    private var glovoGreen: Color { Color.green }

    @State private var showTabs: Bool = false // Navigation trigger

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                GeometryReader { geo in
                    ZStack(alignment: .top) {
                        // Image fills the top, behind everything (including skip button)
                        Image("Glovo background")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height * 0.36)
                            .clipped()
                            .ignoresSafeArea(edges: .top)

                        // The floating white sheet (card), overlapping the image
                        VStack(spacing: 0) {
                            Spacer(minLength: 0)
                            VStack(spacing: 0) {
                                Spacer(minLength: 36)
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
                                            request.requestedScopes = [.fullName, .email]
                                        },
                                        onCompletion: { result in
                                            switch result {
                                            case .success(let authResults):
                                                if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
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

                                Spacer() // Keep content from crowding the top within the sheet

                                // If you don't want duplication, you can remove this inner footer:
                                // Text("By continuing, you automatically accept our Terms & Conditions, Privacy Policy and Cookies Policy.")
                                //     .font(.footnote)
                                //     .foregroundStyle(.secondary)
                                //     .multilineTextAlignment(.center)
                                //     .padding(.horizontal, 32)
                                //     .padding(.bottom, 20)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            .background(
                                Color.white
                                    .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
                                    .shadow(color: .black.opacity(0.09), radius: 18, y: -2)
                            )
                        }
                        .frame(maxWidth: .infinity, maxHeight: geo.size.height * 0.6, alignment: .top)
                        .offset(y: geo.size.height * 0.25) // Sheet floats up and overlaps the image
                    }
                }
            }
            // Place the Skip button absolutely at the top right of the entire screen
            .overlay(
                Button(action: { showTabs = true }) {
                    Text("Skip")
                        .font(.footnote)
                        .foregroundColor(.black)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.05), radius: 1, y: 1)
                }
                .padding(.top, 4) // Status bar height for iPhone, adjust if needed
                .padding(.trailing, 10),
                alignment: .topTrailing
            )
            // Footer pinned to the bottom of the screen (always at device bottom)
            .overlay(
                VStack {
                    Text("By continuing, you automatically accept our Terms & Conditions, Privacy Policy and Cookies Policy.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 12)
                .background(Color.clear)
                , alignment: .bottom
            )
            .safeAreaInset(edge: .bottom) {
                // Optional: ensure it sits above the home indicator if needed
                Color.clear.frame(height: 0)
            }
            .alert(isPresented: $showAppleError) {
                Alert(
                    title: Text("Sign in with Apple Error"),
                    message: Text(appleSignInStatus ?? "Unknown error"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .preferredColorScheme(.light)
            .navigationDestination(isPresented: $showTabs) {
                MainTabView(showTabs: $showTabs)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

// Helper for only selected corners rounded
struct RoundedCorner: Shape {
    var radius: CGFloat = 12.0
    var corners: UIRectCorner = [.allCorners]

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
