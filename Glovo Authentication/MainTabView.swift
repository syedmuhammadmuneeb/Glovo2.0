import SwiftUI
import AuthenticationServices

struct MainTabView: View {
    @Binding var showTabs: Bool

    @State private var selectedTab: Tab = .home
    @State private var isSignedIn: Bool = false
    @State private var showLoginSheet: Bool = false
    @State private var pendingProtectedTab: Tab?

    enum Tab: Hashable {
        case home
        case cart
        case profile
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(showTabs: $showTabs)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)

            CartView()
                .tabItem {
                    Label("Cart", systemImage: "cart.fill")
                }
                .tag(Tab.cart)
                .onAppear {
                    guard !isSignedIn else { return }
                    pendingProtectedTab = .cart
                    selectedTab = .home
                    showLoginSheet = true
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
                .tag(Tab.profile)
                .onAppear {
                    guard !isSignedIn else { return }
                    pendingProtectedTab = .profile
                    selectedTab = .home
                    showLoginSheet = true
                }
        }
        .sheet(isPresented: $showLoginSheet) {
            LoginSheetView(isPresented: $showLoginSheet, isSignedIn: $isSignedIn) {
                if let target = pendingProtectedTab {
                    selectedTab = target
                    pendingProtectedTab = nil
                }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

// A compact login sheet (no hero image), reusing the same fields/actions conceptually.
struct LoginSheetView: View {
    @Binding var isPresented: Bool
    @Binding var isSignedIn: Bool
    var onSignedIn: () -> Void

    @State private var phoneNumber: String = ""
    @State private var selectedPrefix: String = "+39"
    @FocusState private var isPhoneFieldFocused: Bool
    @State private var showAppleError: Bool = false
    @State private var appleSignInStatus: String?

    private var glovoGreen: Color { Color.green }

    var body: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 0)

            VStack(spacing: 6) {
                Text("Sign in to continue")
                    .font(.title2.bold())
                Text("Use your phone number or Apple to sign in.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

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
                    .frame(height: 44)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .frame(width: 90)

                TextField("Phone number", text: $phoneNumber)
                    .keyboardType(.numberPad)
                    .focused($isPhoneFieldFocused)
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .accessibilityLabel("Phone number")
            }
            .padding(.horizontal)

            HStack(spacing: 12) {
                Button {
                    completeSignIn()
                } label: {
                    Text("WhatsApp")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.bordered)
                .foregroundColor(.black)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.black.opacity(0.15), lineWidth: 1)
                )

                Button {
                    completeSignIn()
                } label: {
                    Text("SMS")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .tint(glovoGreen)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 22))
            }
            .padding(.horizontal)

            HStack {
                Rectangle().frame(height: 1)
                    .foregroundColor(.secondary.opacity(0.3))
                Text("or with")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Rectangle().frame(height: 1)
                    .foregroundColor(.secondary.opacity(0.3))
            }
            .padding(.horizontal)

            SignInWithAppleButton(.signIn,
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    switch result {
                    case .success:
                        completeSignIn()
                    case .failure(let error):
                        appleSignInStatus = "Sign in with Apple failed: \(error.localizedDescription)"
                        showAppleError = true
                    }
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .padding(.horizontal)

            Text("By continuing, you accept our Terms & Conditions, Privacy Policy and Cookies Policy.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer(minLength: 8)
        }
        .padding(.top, 8)
        .alert(isPresented: $showAppleError) {
            Alert(
                title: Text("Sign in with Apple Error"),
                message: Text(appleSignInStatus ?? "Unknown error"),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func completeSignIn() {
        isSignedIn = true
        isPresented = false
        onSignedIn()
    }
}

struct HomeView: View {
    @Binding var showTabs: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            VStack {
                Image(systemName: "house.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.green)
                Text("Home")
                    .font(.title)
                    .padding(.top, 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure it fills available space
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill the tab’s area
        .ignoresSafeArea(edges: .top) // So the button can sit close to the top if desired
        // Glassy circular back button at the very top-left
        .overlay(alignment: .topLeading) {
            Button {
                showTabs = false
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle().stroke(Color.black.opacity(0.12), lineWidth: 0.5)
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 6, y: 2)

                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
            .padding(.leading, 12)
        }
    }
}

struct CartView: View {
    var body: some View {
        VStack {
            Image(systemName: "cart.fill")
                .font(.system(size: 64))
                .foregroundColor(.orange)
            Text("Cart")
                .font(.title)
                .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ProfileView: View {
    var body: some View {
        VStack {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.blue)
            Text("Profile")
                .font(.title)
                .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MainTabView(showTabs: .constant(true))
}
