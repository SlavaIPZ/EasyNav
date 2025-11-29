# EasyNav

A powerful, type-safe navigation framework for SwiftUI that implements the Coordinator/Router pattern. EasyNav provides programmatic navigation control with minimal boilerplate and maximum flexibility.

## Features

- ✅ **Type-Safe Navigation** - Define routes as enums with compile-time safety
- ✅ **Programmatic Control** - Navigate from anywhere using `router.push()`, `router.pop()`, etc.
- ✅ **Deep Linking Support** - Restore navigation state with `router.setPath()`
- ✅ **Sheet/Modal Presentation** - Built-in support for modal presentations
- ✅ **Decoupled Views** - Views don't need to know about other views
- ✅ **Testable** - Router logic can be easily unit tested
- ✅ **iOS 16+** - Built on modern SwiftUI `NavigationStack`

## Installation

### Swift Package Manager

Add EasyNav to your project using Xcode:
1. File → Add Package Dependencies...
2. Enter the repository URL
3. Select the version you want to use

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/EasyNav.git", from: "1.0.0")
]
```

## Quick Start

### 1. Define Your Routes

Create an enum that conforms to `NavigationRoute`:

```swift
import EasyNav

enum AppRoute: NavigationRoute {
    case home
    case detail(String)
    case profile
    case settings
}
```

### 2. Set Up RouterView

In your root view, wrap your content with `RouterView`:

```swift
struct ContentView: View {
    @StateObject private var router = Router<AppRoute>()
    
    var body: some View {
        RouterView(router: router) {
            HomeView()
        } destination: { route in
            switch route {
            case .home:
                AnyView(HomeView())
            case .detail(let id):
                AnyView(DetailView(itemId: id))
            case .profile:
                AnyView(ProfileView())
            case .settings:
                AnyView(SettingsView())
            }
        }
    }
}
```

### 3. Navigate Programmatically

In any view, access the router via `@EnvironmentObject`:

```swift
struct HomeView: View {
    @EnvironmentObject private var router: Router<AppRoute>
    
    var body: some View {
        VStack {
            Button("Go to Detail") {
                router.push(.detail("item_123"))
            }
            
            Button("Show Profile") {
                router.push(.profile)
            }
            
            Button("Show Settings Sheet") {
                router.sheet(.settings)
            }
        }
    }
}
```

## API Documentation

### Router

The `Router` class is the central navigation controller.

#### Methods

- **`push(_ route: Route)`** - Pushes a new route onto the navigation stack
- **`pop()`** - Pops the top route from the navigation stack
- **`popToRoot()`** - Pops all routes and returns to root
- **`pop(to route: Route)`** - Pops to a specific route in the stack
- **`sheet(_ route: Route)`** - Presents a route as a sheet/modal
- **`dismissSheet()`** - Dismisses the currently presented sheet
- **`setPath(routes: [Route])`** - Sets the navigation path (deep linking)
- **`currentPath() -> [Route]`** - Returns the current navigation path

#### Properties

- **`path: NavigationPath`** - The current navigation path (used by NavigationStack)
- **`presentedSheet: Route?`** - The currently presented sheet route

### RouterView

The main navigation container view.

**Initialization:**
```swift
RouterView(router: router) {
    // Root content
} destination: { route in
    // Destination builder
}
```

Or with automatic router creation:
```swift
RouterView {
    HomeView()
} destination: { route in
    // Destination builder
}
```

### RouterHost

An alternative API that provides the router to the root view.

```swift
RouterHost { router in
    HomeView(router: router)
} destinationBuilder: { route in
    // Destination builder
}
```

## Advanced Usage

### Deep Linking

Restore navigation state programmatically:

```swift
let deepLinkRoutes: [AppRoute] = [
    .detail("item_1"),
    .profile,
    .settings
]
router.setPath(routes: deepLinkRoutes)
```

### Sheet Presentation

Present routes as modals:

```swift
router.sheet(.settings)

// Later, dismiss it
router.dismissSheet()
```

In your SettingsView, handle both navigation and sheet presentation:

```swift
struct SettingsView: View {
    @EnvironmentObject private var router: Router<AppRoute>
    
    var body: some View {
        Button("Close") {
            if router.presentedSheet != nil {
                router.dismissSheet()
            } else {
                router.popToRoot()
            }
        }
    }
}
```

### Popping to Specific Route

Navigate back to a specific screen in the stack:

```swift
router.pop(to: .profile)
```

### Custom Navigation Controls

Display current path and custom navigation buttons:

```swift
struct NavigationControlsView: View {
    @EnvironmentObject private var router: Router<AppRoute>
    
    var body: some View {
        VStack {
            Text("Path: \(router.currentPath().count) screens")
            
            Button("Back") {
                router.pop()
            }
            
            Button("Home") {
                router.popToRoot()
            }
        }
    }
}
```

## Example App

The repository includes a complete example app demonstrating:

- Basic navigation flows
- Parameter passing
- Deep linking
- Sheet presentation
- Navigation controls

To run the example:
1. Open `Example/ExampleApp.xcodeproj`
2. Build and run on iOS 16+ simulator or device

## Requirements

- iOS 16.0+ / macOS 13.0+
- Swift 5.9+
- Xcode 15.0+

## Architecture

EasyNav implements the **Coordinator/Router Pattern**:

- **Route** - Enum describing all possible screens
- **Router** - ObservableObject managing navigation state
- **RouterView** - Container view binding Router to NavigationStack
- **DestinationBuilder** - Closure mapping routes to views

This pattern provides:
- **Type Safety** - Compile-time guarantees about navigation
- **Decoupling** - Views don't depend on each other
- **Testability** - Router logic can be unit tested
- **Maintainability** - Centralized navigation logic

## Why EasyNav?

### Without EasyNav (Traditional SwiftUI)

```swift
struct HomeView: View {
    @State private var showDetail = false
    @State private var showProfile = false
    
    var body: some View {
        VStack {
            NavigationLink("Detail", destination: DetailView(), isActive: $showDetail)
            NavigationLink("Profile", destination: ProfileView(), isActive: $showProfile)
        }
    }
}
```

**Problems:**
- Tight coupling between views
- Scattered navigation state
- Difficult to test
- No programmatic control
- Complex deep linking

### With EasyNav

```swift
struct HomeView: View {
    @EnvironmentObject private var router: Router<AppRoute>
    
    var body: some View {
        Button("Detail") {
            router.push(.detail("123"))
        }
        Button("Profile") {
            router.push(.profile)
        }
    }
}
```

**Benefits:**
- Clean, declarative code
- Centralized navigation logic
- Easy to test
- Full programmatic control
- Simple deep linking

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
