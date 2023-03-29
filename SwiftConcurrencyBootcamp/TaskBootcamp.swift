//
//  TaskBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Kimleng Hor on 3/28/23.
//

import SwiftUI

class TaskBootcampViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil
    
    func fetchImage() async {
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        //for long run task, we need to do this in order to throw for the task actually cancelled
//        for x in array {
//            try? Task.checkCancellation()
//        }
        
        do {
            guard let url = URL(string: "https://picsum.photos/200") else { return }
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            await MainActor.run(body: {
                self.image = UIImage(data: data)
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage2() async {
        do {
            guard let url = URL(string: "https://picsum.photos/200") else { return }
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            await MainActor.run(body: {
                self.image2 = UIImage(data: data)
            })
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct TaskBootcampHomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink("Click me!") {
                    TaskBootcamp()
                }
            }
        }
    }
}

struct TaskBootcamp: View {
    
    @StateObject private var viewModel = TaskBootcampViewModel()
//    @State private var fetchImageTask: Task<(), Never>? = nil
    
    var body: some View {
        VStack(spacing: 40) {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            if let image = viewModel.image2 {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
            await viewModel.fetchImage()
        }
//        .onDisappear {
//            fetchImageTask?.cancel()
//        }
//        .onAppear {
//
//            /*priority in with Task
//             1. low -- 3
//             2. medium -- 2
//             3. high -- 1
//             4. background -- 4
//             5. utility -- 3
//             6. userInitiated -- 1
//            */
//
//            //child tasks inherit all metadata from the parent task
//            //use detach child task from the parent task
//            //don't use it if it is possible
//
//            fetchImageTask = Task {
//                //sleep
//                try? await Task.sleep(nanoseconds: 5_000_000_000)
//
//                //give permission for other tasks to finish first
//                await Task.yield()
//                await viewModel.fetchImage()
//            }
//
//            Task {
//                await viewModel.fetchImage2()
//            }
//        }
    }
}

struct TaskBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        TaskBootcampHomeView()
    }
}
