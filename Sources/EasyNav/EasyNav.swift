import SwiftUI

// MARK: - NavigationRoute Protocol

/// A protocol that defines a navigation route.
/// Routes must be hashable to work with SwiftUI's NavigationStack.
/// This protocol allows client code to define their own route enums.
@available(iOS 13.0, *)
public protocol NavigationRoute: Hashable {}

// MARK: - Router

/// The central router that manages navigation state and provides programmatic navigation control.
/// This is the "brain" of the navigation system - it manages the NavigationPath and provides methods
/// for manipulating the navigation stack.
@available(iOS 16.0, *)
public class Router<Route: NavigationRoute>: ObservableObject {
    /// The current navigation path containing all pushed routes
    @Published public var path = NavigationPath()

    /// The currently presented sheet/modal route (if any)
    @Published public var presentedSheet: Route?

    /// Internal storage of routes for programmatic access and deep linking
    private var routes: [Route] = []

    /// Creates a new router instance
    public init() {}

    /// Pushes a new route onto the navigation stack
    /// - Parameter route: The route to push
    public func push(_ route: Route) {
        routes.append(route)
        path.append(route)
    }

    /// Pops the top route from the navigation stack
    public func pop() {
        guard !path.isEmpty
        else {
            return
        }
        if !routes.isEmpty {
            routes.removeLast()
        }
        path.removeLast()
    }

    /// Pops all routes and returns to the root view
    public func popToRoot() {
        routes.removeAll()
        path = NavigationPath()
    }

    /// Pops to a specific route in the navigation stack
    /// - Parameter route: The route to pop to (must exist in current path)
    public func pop(to route: Route) {
        guard let index = routes.firstIndex(of: route)
        else {
            return
        }
        let routesToRemove = routes.count - (index + 1)
        routes.removeLast(routesToRemove)
        path.removeLast(routesToRemove)
    }

    /// Presents a sheet/modal with the given route
    /// - Parameter route: The route to present as a sheet
    public func sheet(_ route: Route) {
        presentedSheet = route
    }

    /// Dismisses the currently presented sheet/modal
    public func dismissSheet() {
        presentedSheet = nil
    }

    /// Sets the navigation path from an array of routes (Deep Linking support)
    /// - Parameter routes: Array of routes to set as the navigation path
    public func setPath(routes: [Route]) {
        self.routes = routes
        path = NavigationPath()
        routes.forEach { route in
            path.append(route)
        }
    }

    /// Gets the current navigation path as an array of routes
    /// - Returns: Array of routes currently in the navigation stack
    public func currentPath() -> [Route] {
        return routes
    }
}

// MARK: - RouterView

/// A SwiftUI View that provides centralized navigation handling using NavigationStack.
/// This is the navigation container that replaces the standard NavigationStack.
/// It binds the Router's state to the NavigationStack and handles both push navigation and modal presentations.
@available(iOS 16.0, *)
public struct RouterView<Route: NavigationRoute, Content: View>: View {
    @StateObject private var router: Router<Route>
    private let rootContent: () -> Content
    @ViewBuilder private let destination: (Route) -> AnyView

    /// Creates a new RouterView with a custom router
    /// - Parameters:
    ///   - router: The router instance to use for navigation
    ///   - rootContent: A closure that builds the root/home screen content
    ///   - destination: A closure that builds destination views for each route (DestinationBuilder)
    public init(
        router: Router<Route>,
        @ViewBuilder rootContent: @escaping () -> Content,
        @ViewBuilder destination: @escaping (Route) -> AnyView
    ) {
        self._router = StateObject(wrappedValue: router)
        self.rootContent = rootContent
        self.destination = destination
    }

    /// Creates a new RouterView with an automatically created router
    /// - Parameters:
    ///   - rootContent: A closure that builds the root/home screen content
    ///   - destination: A closure that builds destination views for each route (DestinationBuilder)
    public init(
        @ViewBuilder rootContent: @escaping () -> Content,
        @ViewBuilder destination: @escaping (Route) -> AnyView
    ) {
        self._router = StateObject(wrappedValue: Router<Route>())
        self.rootContent = rootContent
        self.destination = destination
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            rootContent()
                .navigationDestination(for: Route.self) { route in
                    destination(route)
                        .environmentObject(router)
                }
        }
        .sheet(isPresented: Binding(
            get: { router.presentedSheet != nil },
            set: { if !$0 { router.presentedSheet = nil } }
        )) {
            if let route = router.presentedSheet {
                destination(route)
                    .environmentObject(router)
            }
        }
        .environmentObject(router)
    }
}

// MARK: - RouterHost (Alternative API)

/// An alternative API for RouterView that accepts the root view separately.
/// This provides more flexibility when you need to pass the router to the root view.
@available(iOS 16.0, *)
public struct RouterHost<Route: NavigationRoute, RootView: View>: View {
    @StateObject private var router: Router<Route>
    private let rootView: (Router<Route>) -> RootView
    private let destinationBuilder: (Route) -> AnyView

    /// Creates a new RouterHost with a custom router
    /// - Parameters:
    ///   - router: The router instance to use for navigation
    ///   - rootView: A closure that builds the root view, receiving the router as parameter
    ///   - destinationBuilder: A closure that builds destination views for each route
    public init(
        router: Router<Route>,
        @ViewBuilder rootView: @escaping (Router<Route>) -> RootView,
        @ViewBuilder destinationBuilder: @escaping (Route) -> AnyView
    ) {
        self._router = StateObject(wrappedValue: router)
        self.rootView = rootView
        self.destinationBuilder = destinationBuilder
    }

    /// Creates a new RouterHost with an automatically created router
    /// - Parameters:
    ///   - rootView: A closure that builds the root view, receiving the router as parameter
    ///   - destinationBuilder: A closure that builds destination views for each route
    public init(
        @ViewBuilder rootView: @escaping (Router<Route>) -> RootView,
        @ViewBuilder destinationBuilder: @escaping (Route) -> AnyView
    ) {
        self._router = StateObject(wrappedValue: Router<Route>())
        self.rootView = rootView
        self.destinationBuilder = destinationBuilder
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            rootView(router)
                .navigationDestination(for: Route.self) { route in
                    destinationBuilder(route)
                        .environmentObject(router)
                }
        }
        .sheet(isPresented: Binding(
            get: { router.presentedSheet != nil },
            set: { if !$0 { router.presentedSheet = nil } }
        )) {
            if let route = router.presentedSheet {
                destinationBuilder(route)
                    .environmentObject(router)
            }
        }
        .environmentObject(router)
    }
}

// MARK: - Typealias for Backward Compatibility

@available(iOS 16.0, *)
public typealias EasyNavHost<Route: NavigationRoute, RootView: View> = RouterHost<Route, RootView>

// MARK: - Convenience Extensions

extension View {
    /// Sets the router as an environment object for child views
    /// - Parameter router: The router to provide to child views
    /// - Returns: A view with the router set as environment object
    public func withRouter<Route: NavigationRoute>(_ router: Router<Route>) -> some View {
        self.environmentObject(router)
    }
}
