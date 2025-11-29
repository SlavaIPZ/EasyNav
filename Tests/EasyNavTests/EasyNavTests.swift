import XCTest
@testable import EasyNav

// Test Route implementation
enum TestRoute: NavigationRoute {
    case home
    case detail(Int)
    case settings
}

final class EasyNavTests: XCTestCase {
    func testRouterInitialization() throws {
        let router = Router<TestRoute>()
        XCTAssertTrue(router.currentPath().isEmpty)
        XCTAssertNil(router.presentedSheet)
    }

    func testRouterPush() throws {
        let router = Router<TestRoute>()

        router.push(.home)
        XCTAssertEqual(router.currentPath().count, 1)
        XCTAssertEqual(router.currentPath(), [.home])

        router.push(.detail(123))
        XCTAssertEqual(router.currentPath().count, 2)
        XCTAssertEqual(router.currentPath(), [.home, .detail(123)])
    }

    func testRouterPop() throws {
        let router = Router<TestRoute>()

        router.push(.home)
        router.push(.detail(123))
        router.push(.settings)

        XCTAssertEqual(router.currentPath().count, 3)

        router.pop()
        XCTAssertEqual(router.currentPath().count, 2)
        XCTAssertEqual(router.currentPath(), [.home, .detail(123)])

        router.pop()
        XCTAssertEqual(router.currentPath().count, 1)
        XCTAssertEqual(router.currentPath(), [.home])
    }

    func testRouterPopToRoot() throws {
        let router = Router<TestRoute>()

        router.push(.home)
        router.push(.detail(123))
        router.push(.settings)

        router.popToRoot()
        XCTAssertTrue(router.currentPath().isEmpty)
        XCTAssertEqual(router.path.count, 0)
    }

    func testRouterPopToSpecificRoute() throws {
        let router = Router<TestRoute>()

        router.push(.home)
        router.push(.detail(123))
        router.push(.settings)

        router.pop(to: .detail(123))
        XCTAssertEqual(router.currentPath().count, 2)
        XCTAssertEqual(router.currentPath(), [.home, .detail(123)])
    }

    func testRouterSheetPresentation() throws {
        let router = Router<TestRoute>()

        XCTAssertNil(router.presentedSheet)

        router.sheet(.settings)
        XCTAssertEqual(router.presentedSheet, .settings)

        router.dismissSheet()
        XCTAssertNil(router.presentedSheet)
    }

    func testDeepLinkingWithSetPath() throws {
        let router = Router<TestRoute>()

        let deepLinkRoutes: [TestRoute] = [.home, .detail(42), .settings]
        router.setPath(routes: deepLinkRoutes)

        XCTAssertEqual(router.currentPath().count, 3)
        XCTAssertEqual(router.currentPath(), deepLinkRoutes)
        XCTAssertEqual(router.path.count, 3)
    }

    func testNavigationRouteProtocolConformance() throws {
        let route1 = TestRoute.home
        let route2 = TestRoute.home
        let route3 = TestRoute.detail(123)

        XCTAssertEqual(route1, route2)
        XCTAssertNotEqual(route1, route3)

        // Test Hashable conformance
        var hasher1 = Hasher()
        route1.hash(into: &hasher1)
        var hasher2 = Hasher()
        route2.hash(into: &hasher2)
        XCTAssertEqual(hasher1.finalize(), hasher2.finalize())
    }
}
