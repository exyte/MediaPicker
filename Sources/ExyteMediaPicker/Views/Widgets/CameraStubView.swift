//
//  Created by Alex.M on 31.05.2022.
//

#if targetEnvironment(simulator)
import SwiftUI

struct CameraStubView: View {

    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .ignoresSafeArea()
            
            VStack {
                Text("Camera")
                    .font(.largeTitle)
                Text("Unavailable on simulator. Use device for testing")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                Button("Close") {
                    isPresented = false
                }
                .padding()
            }
        }
    }
}

struct CameraStubView_Preview: PreviewProvider {
    static var previews: some View {
        CameraStubView(isPresented: .constant(true))
    }
}

#endif
