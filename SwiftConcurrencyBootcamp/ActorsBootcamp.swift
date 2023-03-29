//
//  ActorsBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Kimleng Hor on 3/28/23.
//

import SwiftUI

class MyDataManager {
    static let instance = MyDataManager()
    private init() { }
    
    var data = [String]()
    private let lock = DispatchQueue(label: "com.MyApp.MyDataManager")
    
    func getRandomData(completionHandler: @escaping (_ title: String?) -> ()) {
        lock.async {
            self.data.append(UUID().uuidString)
            completionHandler(self.data.randomElement())
        }
    }
}

actor MyActorDataManager {
    static let instance = MyActorDataManager()
    private init() { }
    
    var data = [String]()
    
    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        return self.data.randomElement()
    }
    
    nonisolated func getSavedData() -> String {
        return "NEW DATA"
    }
}

struct HomeView: View {
    
    let manager = MyActorDataManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.1, on: .main, in: .common, options: nil).autoconnect()
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.8).ignoresSafeArea()
            Text(text)
                .font(.headline)
        }
        .onAppear {
            let newString = manager.getSavedData()
            self.text = newString
        }
        .onReceive(timer) { _ in
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run(body: {
                        self.text = data
                    })
                }
            }
//            DispatchQueue.global(qos: .default).async {
//                manager.getRandomData(completionHandler: { title in
//                    DispatchQueue.main.async {
//                        self.text = title ?? ""
//                    }
//                })
//            }
        }
    }
}

struct BrowseView: View {
    
    let manager = MyActorDataManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.1, on: .main, in: .common, options: nil).autoconnect()
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.8).ignoresSafeArea()
            Text(text)
                .font(.headline)
        }.onReceive(timer) { _ in
//            DispatchQueue.global(qos: .default).async {
//                manager.getRandomData(completionHandler: { title in
//                    DispatchQueue.main.async {
//                        self.text = title ?? ""
//                    }
//                })
//            }
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run(body: {
                        self.text = data
                    })
                }
            }
        }

    }
}

struct ActorsBootcamp: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}

struct ActorsBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        ActorsBootcamp()
    }
}
