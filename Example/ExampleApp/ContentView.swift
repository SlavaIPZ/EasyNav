import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            OldWayNavigationView()
                .tabItem {
                    Label("Old Way", systemImage: "arrow.right.circle")
                }
            EasyNavNavigationView()
                .tabItem {
                    Label("EasyNav Way", systemImage: "arrow.right.circle.fill")
                }
        }
        .tint(.blue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
