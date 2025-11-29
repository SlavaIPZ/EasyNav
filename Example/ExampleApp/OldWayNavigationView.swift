import SwiftUI
import Combine

enum OldWayRoute: Hashable {
    case home
    case detail(String)
    case profile
    case settings
    case deepLinkDemo
}

class OldWayNavigationState: ObservableObject {
    @Published var navigationPath: [OldWayRoute] = []
    @Published var presentedSheet: OldWayRoute?
    @Published var lastPushedRoute: OldWayRoute?
    @Published var lastPoppedRoute: OldWayRoute?
    var previousPathCount: Int = 0
    
    func push(_ route: OldWayRoute) {
        previousPathCount = navigationPath.count
        navigationPath.append(route)
        lastPushedRoute = route
    }
    
    func pop() {
        guard !navigationPath.isEmpty else { return }
        previousPathCount = navigationPath.count
        let poppedRoute = navigationPath.removeLast()
        lastPoppedRoute = poppedRoute
    }
    
    func popToRoot() {
        previousPathCount = navigationPath.count
        navigationPath.removeAll()
        lastPoppedRoute = nil
    }
    
    func pop(to route: OldWayRoute) {
        guard let index = navigationPath.firstIndex(of: route) else { return }
        previousPathCount = navigationPath.count
        let routesToRemove = navigationPath.count - (index + 1)
        if routesToRemove > 0 {
            navigationPath.removeLast(routesToRemove)
            lastPoppedRoute = route
        }
    }
    
    func sheet(_ route: OldWayRoute) {
        presentedSheet = route
    }
    
    func dismissSheet() {
        presentedSheet = nil
    }
    
    func setPath(routes: [OldWayRoute]) {
        previousPathCount = navigationPath.count
        navigationPath = routes
        lastPushedRoute = routes.first
    }
    
    func currentPath() -> [OldWayRoute] {
        return navigationPath
    }
}

struct OldWayNavigationView: View {
    @State private var showDetail = false
    @State private var showProfile = false
    @State private var showSettings = false
    @State private var showDeepLinkDemo = false
    @State private var selectedItem: String?
    @State private var detailItemId: String = ""
    
    @StateObject private var navState = OldWayNavigationState()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("The Old Way")
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)

                        Text("Navigation logic scattered across views")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 100)
                    .padding(.horizontal, 20)

                    VStack(spacing: 16) {
                        Button {
                            navState.push(.detail("item_1"))
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
                            navState.push(.detail("item_2"))
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
                            navState.push(.profile)
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
                            navState.sheet(.settings)
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
                .padding(.bottom, 20)
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        .background(
            Group {
                NavigationLink(
                    destination: OldDetailView(
                        itemId: detailItemId,
                        navState: navState,
                        showProfile: $showProfile,
                        showDeepLinkDemo: $showDeepLinkDemo,
                        showSettings: $showSettings,
                        onPopToRoot: {
                            resetAllNavigation()
                        }
                    ),
                    isActive: $showDetail
                ) {
                    EmptyView()
                }
                
                NavigationLink(
                    destination: OldProfileView(
                        navState: navState,
                        showSettings: $showSettings,
                        onPopToRoot: {
                            resetAllNavigation()
                        }
                    ),
                    isActive: $showProfile
                ) {
                    EmptyView()
                }
            }
        )
        .background(
            Group {
                NavigationLink(
                    destination: OldSettingsView(
                        navState: navState,
                        onPopToRoot: {
                            resetAllNavigation()
                        }
                    ),
                    isActive: $showSettings
                ) {
                    EmptyView()
                }
                
                NavigationLink(
                    destination: OldDeepLinkDemoView(
                        navState: navState,
                        onPopToRoot: {
                            resetAllNavigation()
                        }
                    ),
                    isActive: $showDeepLinkDemo
                ) {
                    EmptyView()
                }
            }
        )
            .sheet(isPresented: Binding(
                get: { navState.presentedSheet == .settings },
                set: { if !$0 { navState.dismissSheet() } }
            )) {
                OldSettingsView(
                    navState: navState,
                    onPopToRoot: {
                        resetAllNavigation()
                    }
                )
            }
            .onChange(of: navState.lastPushedRoute) { pushedRoute in
                if let route = pushedRoute {
                    handleRoutePush(route)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.navState.lastPushedRoute = nil
                    }
                }
            }
            .onChange(of: navState.lastPoppedRoute) { poppedRoute in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if self.navState.navigationPath.isEmpty {
                        self.resetAllNavigation()
                    } else {
                        let path = self.navState.navigationPath
                        
                        var shouldShowDetail = false
                        var shouldShowProfile = false
                        var shouldShowSettings = false
                        var shouldShowDeepLink = false
                        var newDetailId = self.detailItemId
                        
                        for route in path {
                            switch route {
                            case .detail(let itemId):
                                shouldShowDetail = true
                                newDetailId = itemId
                            case .profile:
                                shouldShowProfile = true
                            case .settings:
                                shouldShowSettings = true
                            case .deepLinkDemo:
                                shouldShowDeepLink = true
                            case .home:
                                break
                            }
                        }
                        
                        switch poppedRoute {
                        case .settings:
                            self.showSettings = false
                        case .profile:
                            self.showProfile = false
                        case .detail:
                            self.showDetail = false
                        case .deepLinkDemo:
                            self.showDeepLinkDemo = false
                        case .home, .none:
                            break
                        }
                        
                        if shouldShowDetail && !self.showDetail {
                            self.detailItemId = newDetailId
                            self.showDetail = true
                        }
                        if shouldShowProfile && !self.showProfile {
                            self.showProfile = true
                        }
                        if shouldShowSettings && !self.showSettings {
                            self.showSettings = true
                        }
                        if shouldShowDeepLink && !self.showDeepLinkDemo {
                            self.showDeepLinkDemo = true
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.navState.lastPoppedRoute = nil
                    }
                }
            }
            .onChange(of: navState.navigationPath) { newPath in
                if newPath.isEmpty {
                    resetAllNavigation()
                } else if navState.lastPushedRoute == nil && navState.lastPoppedRoute == nil {
                    let wasEmpty = navState.previousPathCount == 0
                    let isDeepLink = newPath.count > 1 && wasEmpty && !showDetail && !showProfile && !showSettings && !showDeepLinkDemo
                    if isDeepLink {
                        handleDeepLink(newPath)
                    }
                }
            }
        }
    }
    
    private func performDeepLink() {
        let deepLinkRoutes: [OldWayRoute] = [.detail("deep_link_item"), .profile, .settings]
        navState.setPath(routes: deepLinkRoutes)
    }
    
    private func resetAllNavigation() {
        showDetail = false
        showProfile = false
        showSettings = false
        showDeepLinkDemo = false
    }
    
    private func handleRoutePush(_ route: OldWayRoute) {
        switch route {
        case .detail(let itemId):
            detailItemId = itemId
            if !showDetail {
                showDetail = true
            }
        case .profile:
            if !showProfile {
                showProfile = true
            }
        case .settings:
            if navState.presentedSheet == nil {
                if !showSettings {
                    showSettings = true
                }
            }
        case .deepLinkDemo:
            if !showDeepLinkDemo {
                showDeepLinkDemo = true
            }
        case .home:
            resetAllNavigation()
        }
    }
    
    private func syncBindingsWithPath() {
        let path = navState.navigationPath
        
        if path.isEmpty {
            resetAllNavigation()
            return
        }
        
        let currentDetailId = detailItemId
        var needsDetailId = currentDetailId
        
        var needsDetail = false
        var needsProfile = false
        var needsSettings = false
        var needsDeepLink = false
        
        for route in path {
            switch route {
            case .detail(let itemId):
                needsDetail = true
                needsDetailId = itemId
            case .profile:
                needsProfile = true
            case .settings:
                needsSettings = true
            case .deepLinkDemo:
                needsDeepLink = true
            case .home:
                break
            }
        }
        
        let shouldReset = showDetail != needsDetail || 
                         showProfile != needsProfile || 
                         showSettings != needsSettings || 
                         showDeepLinkDemo != needsDeepLink ||
                         (needsDetail && currentDetailId != needsDetailId)
        
        if !shouldReset {
            return
        }
        
        resetAllNavigation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if needsDetail {
                self.detailItemId = needsDetailId
                self.showDetail = true
                
                if needsProfile {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        self.showProfile = true
                        
                        if needsSettings {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                self.showSettings = true
                            }
                        }
                        
                        if needsDeepLink {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                self.showDeepLinkDemo = true
                            }
                        }
                    }
                } else if needsDeepLink {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        self.showDeepLinkDemo = true
                    }
                }
            } else if needsProfile {
                self.showProfile = true
                
                if needsSettings {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        self.showSettings = true
                    }
                }
            } else if needsSettings {
                self.showSettings = true
            } else if needsDeepLink {
                self.showDeepLinkDemo = true
            }
        }
    }
    
    private func handleDeepLink(_ routes: [OldWayRoute]) {
        resetAllNavigation()
        
        guard !routes.isEmpty else { return }
        
        func processRoute(at index: Int) {
            guard index < routes.count else { return }
            
            let route = routes[index]
            let delay = Double(index) * 0.4 + 0.3
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                switch route {
                case .detail(let itemId):
                    self.detailItemId = itemId
                    self.showDetail = true
                    if index + 1 < routes.count {
                        processRoute(at: index + 1)
                    }
                case .profile:
                    self.showProfile = true
                    if index + 1 < routes.count {
                        processRoute(at: index + 1)
                    }
                case .settings:
                    self.showSettings = true
                    if index + 1 < routes.count {
                        processRoute(at: index + 1)
                    }
                case .deepLinkDemo:
                    self.showDeepLinkDemo = true
                    if index + 1 < routes.count {
                        processRoute(at: index + 1)
                    }
                case .home:
                    if index + 1 < routes.count {
                        processRoute(at: index + 1)
                    }
                }
            }
        }
        
        processRoute(at: 0)
    }
}

struct OldDetailView: View {
    let itemId: String
    @ObservedObject var navState: OldWayNavigationState
    @Binding var showProfile: Bool
    @Binding var showDeepLinkDemo: Bool
    @Binding var showSettings: Bool
    var onPopToRoot: () -> Void

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
                        navState.push(.profile)
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
                        navState.push(.deepLinkDemo)
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

                if !navState.currentPath().isEmpty {
                    OldWayNavigationControlsView(
                        navState: navState,
                        onPopToRoot: onPopToRoot
                    )
                }
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .background(
            NavigationLink(
                destination: OldProfileView(
                    navState: navState,
                    showSettings: $showSettings,
                    onPopToRoot: onPopToRoot
                ),
                isActive: $showProfile
            ) {
                EmptyView()
            }
        )
        .background(
            NavigationLink(
                destination: OldDeepLinkDemoView(
                    navState: navState,
                    onPopToRoot: onPopToRoot
                ),
                isActive: $showDeepLinkDemo
            ) {
                EmptyView()
            }
        )
        .onChange(of: navState.lastPushedRoute) { pushedRoute in
            if let route = pushedRoute {
                handleRoutePushInDetail(route)
            }
        }
    }
    
    private func handleRoutePushInDetail(_ route: OldWayRoute) {
        switch route {
        case .profile:
            if !showProfile {
                showProfile = true
            }
        case .deepLinkDemo:
            if !showDeepLinkDemo {
                showDeepLinkDemo = true
            }
        default:
            break
        }
    }
}

struct OldProfileView: View {
    @ObservedObject var navState: OldWayNavigationState
    @Binding var showSettings: Bool
    var onPopToRoot: () -> Void

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
                        navState.push(.settings)
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

                if !navState.currentPath().isEmpty {
                    OldWayNavigationControlsView(
                        navState: navState,
                        onPopToRoot: onPopToRoot
                    )
                }
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .background(
            NavigationLink(
                destination: OldSettingsView(
                    navState: navState,
                    onPopToRoot: onPopToRoot
                ),
                isActive: $showSettings
            ) {
                EmptyView()
            }
        )
        .onChange(of: navState.lastPushedRoute) { pushedRoute in
            if let route = pushedRoute {
                if route == .settings && !showSettings {
                    showSettings = true
                }
            }
        }
    }
}

struct OldSettingsView: View {
    @ObservedObject var navState: OldWayNavigationState
    var onPopToRoot: () -> Void

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
                        if navState.presentedSheet != nil {
                            navState.dismissSheet()
                        } else {
                            navState.popToRoot()
                            onPopToRoot()
                        }
                    } label: {
                        Text(navState.presentedSheet != nil ? "Dismiss" : "Back to Home")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(navState.presentedSheet != nil ? Color.orange : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)

                if !navState.currentPath().isEmpty {
                    OldWayNavigationControlsView(
                        navState: navState,
                        onPopToRoot: onPopToRoot
                    )
                }
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

struct OldDeepLinkDemoView: View {
    @ObservedObject var navState: OldWayNavigationState
    var onPopToRoot: () -> Void

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

                    Text("Current path depth: \(navState.currentPath().count)")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.top, 8)
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)

                VStack(spacing: 16) {
                    Button {
                        navState.popToRoot()
                        onPopToRoot()
                    } label: {
                        Text("Back to Home")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)

                if !navState.currentPath().isEmpty {
                    OldWayNavigationControlsView(
                        navState: navState,
                        onPopToRoot: onPopToRoot
                    )
                }
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("Deep Link Demo")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

struct OldWayNavigationControlsView: View {
    @ObservedObject var navState: OldWayNavigationState
    var onPopToRoot: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 8) {
                Text("Current Path:")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                Text(navState.currentPath().map { routeDescription($0) }.joined(separator: " → "))
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
                    navState.pop()
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
                    navState.popToRoot()
                    onPopToRoot()
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
    
    private func routeDescription(_ route: OldWayRoute) -> String {
        switch route {
        case .home: return "Home"
        case .detail(let id): return "Detail(\(id))"
        case .profile: return "Profile"
        case .settings: return "Settings"
        case .deepLinkDemo: return "DeepLink"
        }
    }
}

struct OldWayNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        OldWayNavigationView()
    }
}
