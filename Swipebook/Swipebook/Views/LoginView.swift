//
//  LoginView.swift
//  Swipebook
//
//  Created by Vincent Wisnata on 14/05/25.
//

import SwiftUI
import SwiftData

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct LoginView: View {
    @StateObject private var controller = LoginController()
    
    var body: some View {
        VStack() {
            // Login Title
            VStack(alignment: .leading){
                Text("Login")
                    .foregroundColor(Color.white)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Login to book a session/room")
                    .font(.caption).foregroundColor(Color.textGray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider().frame(height: 1).background(Color.textGray).padding(.top, 4)
            
            // Form Fields
            VStack(spacing: 16) {
                // Email Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.footnote).foregroundColor(Color.textGray)
                    
                    TextField("Enter your email", text: $controller.email)
                        .foregroundColor(Color.white)
                        .placeholder(when: controller.email.isEmpty) {
                            Text("Enter your email").foregroundColor(Color.white.opacity(0.7))
                        }
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding().background(
                            RoundedRectangle(cornerRadius: 999).fill(Color.inputGray)
                        )
                    
                    
                    
                }
                
                // Password Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.footnote).foregroundColor(Color.textGray)
                    
                    HStack {
                        if controller.isShowingPassword {
                            TextField(
                                "Enter your password",
                                text: $controller.password
                            )
                            .foregroundColor(Color.white)
                            .placeholder(when: controller.password.isEmpty) {
                                Text("Enter your password").foregroundColor(Color.white.opacity(0.7))
                            }
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        } else {
                            SecureField("Enter your password", text: $controller.password)
                                .foregroundColor(Color.white)
                                .placeholder(when: controller.password.isEmpty) {
                                    Text("Enter your password").foregroundColor(Color.white.opacity(0.7))
                                }
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        
                        Button(action: {
                            controller.isShowingPassword.toggle()
                        }) {
                            Image(systemName: controller.isShowingPassword ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 999).fill(Color.inputGray)
                    )
                }
                                
            }
            .frame(width: Double.infinity).padding(.vertical, 16)
            
            Spacer()
            
            // Continue Button
            Button(action: {
                controller.isLoading = true
                
                Task {
                    let response = await controller.login()
                    
                    // Update UI on main thread
                    await MainActor.run {
                        controller.isLoading = false
                        controller.handleLoginResponse(response)
                    }
                }
            }) {
                if controller.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Continue").foregroundColor(Color.background)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.primaryOrange)
            .foregroundColor(.white)
            .cornerRadius(999)
            .padding(.horizontal)
            .disabled(controller.email.isEmpty || controller.password.isEmpty || controller.isLoading)
            .opacity((controller.email.isEmpty || controller.password.isEmpty || controller.isLoading) ? 0.3 : 1)
            
            // Collab Only
            HStack {
                Text("I Want To Check Availability")
                    .font(.subheadline)
                    .foregroundColor(Color .white)
                    .foregroundColor(.textGray)
                Button("Click Here") {
                }
                .fontWeight(.medium)
                .foregroundColor(.white)
            }
            .padding(.bottom, 30)
        }
        .padding(.horizontal, 30)
        .alert(isPresented: $controller.showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(controller.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview {
    LoginView()                    .background(Color.background)

}
