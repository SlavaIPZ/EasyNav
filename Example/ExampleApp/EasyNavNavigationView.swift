import SwiftUI
import EasyNav

enum AppRoute: NavigationRoute {
    case home
    case detail(String)
    case profile
    case settings
    case deepLinkDemo
}

struct EasyNavNavigationView: View {
    @StateObject private var router = Router<AppRoute>()

    var body: some View {
        RouterView(router: router) {
            HomeView()
        } destination: { (route: AppRoute) -> AnyView in
            let view: AnyView
            switch route {
            case .home:
                view = AnyView(HomeView())
            case .detail(let itemId):
                view = AnyView(DetailView(itemId: itemId))
            case .profile:
                view = AnyView(ProfileView())
            case .settings:
                view = AnyView(SettingsView())
            case .deepLinkDemo:
                view = AnyView(DeepLinkDemoView())
            }
            return view
        }
    }
}

struct HomeView: View {
    @EnvironmentObject private var router: Router<AppRoute>

    var body: some View {
        ScrollView {
            VStack {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("The EasyNav Way")
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)

                        Text("Clean separation of navigation and UI")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 100)
                    .padding(.horizontal, 20)

                    VStack(spacing: 16) {
                        Button {
                            router.push(.detail("item_1"))
                        } label: {
                            Text("Go to Detail 1")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button {
                            router.push(.detail("item_2"))
                        } label: {
                            Text("Go to Detail 2")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button {
                            performDeepLink()
                        } label: {
                            Text("Deep Link Demo (3 screens)")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button {
                            router.push(.profile)
                        } label: {
                            Text("Go to Profile")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button {
                            router.sheet(.settings)
                        } label: {
                            Text("Show Settings (Sheet)")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.pink)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func performDeepLink() {
        let deepLinkRoutes: [AppRoute] = [.detail("deep_link_item"), .profile, .settings]
        router.setPath(routes: deepLinkRoutes)
    }
}

struct DetailView: View {
    let itemId: String
    @EnvironmentObject private var router: Router<AppRoute>

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Detail View")
                        .font(.largeTitle)
                        .bold()

                    Text("Item: \(itemId)")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)

                VStack(spacing: 16) {
                    Button {
                        router.push(.profile)
                    } label: {
                        Text("Go to Profile")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button {
                        router.push(.deepLinkDemo)
                    } label: {
                        Text("Complex Action")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)

                if !router.currentPath().isEmpty {
                    NavigationControlsView()
                }
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

struct ProfileView: View {
    @EnvironmentObject private var router: Router<AppRoute>

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Profile View")
                        .font(.largeTitle)
                        .bold()

                    Text("User profile information")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)

                VStack(spacing: 16) {
                    Button {
                        router.push(.settings)
                    } label: {
                        Text("Go to Settings")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)

                if !router.currentPath().isEmpty {
                    NavigationControlsView()
                }
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

struct SettingsView: View {
    @EnvironmentObject private var router: Router<AppRoute>

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Settings View")
                        .font(.largeTitle)
                        .bold()

                    Text("App settings")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)

                VStack(spacing: 16) {
                    Button {
                        if router.presentedSheet != nil {
                            router.dismissSheet()
                        } else {
                            router.popToRoot()
                        }
                    } label: {
                        Text(router.presentedSheet != nil ? "Dismiss" : "Back to Home")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(router.presentedSheet != nil ? Color.orange : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)

                if !router.currentPath().isEmpty {
                    NavigationControlsView()
                }
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

struct DeepLinkDemoView: View {
    @EnvironmentObject private var router: Router<AppRoute>

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Text("Deep Link Demo")
                        .font(.largeTitle)
                        .bold()

                    Text("This view was reached via deep linking!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Text("Current path depth: \(router.currentPath().count)")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.top, 8)
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)

                VStack(spacing: 16) {
                    Button {
                        router.popToRoot()
                    } label: {
                        Text("Back to Home")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)

                if !router.currentPath().isEmpty {
                    NavigationControlsView()
                }
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("Deep Link Demo")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

struct NavigationControlsView: View {
    @EnvironmentObject private var router: Router<AppRoute>

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 8) {
                Text("Current Path:")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                Text(router.currentPath().map { routeDescription($0) }.joined(separator: " → "))
                    .font(.caption)
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)

            HStack(spacing: 12) {
                Button {
                    router.pop()
                } label: {
                    Text("Back")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button {
                    router.popToRoot()
                } label: {
                    Text("Home")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private func routeDescription(_ route: AppRoute) -> String {
        switch route {
        case .home: return "Home"
        case .detail(let id): return "Detail(\(id))"
        case .profile: return "Profile"
        case .settings: return "Settings"
        case .deepLinkDemo: return "DeepLink"
        }
    } 
}

struct EasyNavNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        EasyNavNavigationView()
    }
}
