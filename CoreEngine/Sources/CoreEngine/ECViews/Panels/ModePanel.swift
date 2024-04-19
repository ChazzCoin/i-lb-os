//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/9/24.
//

import Foundation
import SwiftUI
import Combine

public class PanelModeController: ObservableObject, ObservablePanel {
    
    @ObservedObject public var gps = GlobalPositioningSystem(.global)
    public let id: String = CoreName.Views.Panel.mode.name
    @Published public var isVisible = false
    @Published public var title: String
    @Published public var subTitle: String
    @Published public var showButton: Bool = true
    @Published public var showImage: Bool = false
    @Published public var imageName: String = ""
    @Published public var isFlashing: Bool = false
    
    @Published public var parentGeo: GeometryProxy?
    @Published public var childGeo: GeometryProxy?

    public var cancellables = Set<AnyCancellable>()
    
    public required init(title: String, subtitle: String) {
        self.title = title
        self.subTitle = subtitle
    }
    
    @ViewBuilder
    public func Display(_ position: ScreenArea = .topCenter) -> some View {
        if isVisible {
            GeometryReader { pGeo in
                ModePanel(title: self.title, subTitle: self.subTitle, showButton: self.showButton) { self.isVisible = false }
                    .measure { cGeo in self.parentGeo = pGeo; self.childGeo = cGeo }
                    .position(using: self.gps, at: position, with: self.childGeo)
            }
        }
    }
    public func toggleView() { self.isVisible.toggle() }
    
    public init(title: String="Mode Alert!", subTitle: String="", showButton: Bool = true, showImage: Bool = false, imageName: String = "play", isFlashing: Bool = false) {
        self.title = title
        self.subTitle = subTitle
        self.showButton = showButton
        self.showImage = showImage
        self.imageName = imageName
        self.isFlashing = isFlashing
        
        NotificationCenter.default.publisher(for: Notification.Name(id))
            .receive(on: RunLoop.main)
            .compactMap { notification in
                notification.userInfo?["isVisible"] as? Bool
            }
            .assign(to: &self.$isVisible)
    }
    
    public func updateTitle(title: String) { self.title = title }
    public func updateSubTitle(subtitle: String) { self.subTitle = subtitle }
}

struct ModePanelModel: View {
    @ObservedObject var viewModel: PanelModeController
    var onStop: () -> Void = {}

    var body: some View {
        if viewModel.isVisible {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(viewModel.title)
                            .font(.headline)

                        Text(viewModel.subTitle)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    Spacer()
                    
                    if viewModel.showImage {
                        Image(systemName: viewModel.imageName)
                            .resizable()
                            .frame(width: 15, height: 15)
                            .opacity(viewModel.isFlashing ? 1 : 0)
                            .onAppear {
                                withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                                    self.viewModel.isFlashing.toggle()
                                }
                            }
                    } else {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 15, height: 15)
                            .opacity(viewModel.isFlashing ? 1 : 0)
                            .onAppear {
                                withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                                    self.viewModel.isFlashing.toggle()
                                }
                            }
                    }
                }
                if viewModel.showButton {
                    Button(action: {
                        
                    }) {
                        Text("Stop")
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                }
                
            }
            .padding()
            .frame(maxWidth: 300, maxHeight: UIScreen.main.bounds.height * 0.3)
            .background(RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 4))
            .padding()
        }
    }
}


public struct ModePanel: View {
    @State public var title: String
    @State public var subTitle: String
    @State public var showButton: Bool
    public var onStop: () -> Void
    @State public var showImage: Bool = false
    @State public var imageName: String = "play"
    @State public var isFlashing = false
    
    public init(title: String, subTitle: String, showButton: Bool, onStop: @escaping () -> Void = {}, isFlashing: Bool = false) {
        self.title = title
        self.subTitle = subTitle
        self.showButton = showButton
        self.onStop = onStop
        self.isFlashing = isFlashing
    }

    public init(title: String, subTitle: String, showButton: Bool, showImage: Bool, imageName: String = "play", onStop: @escaping () -> Void = {}, isFlashing: Bool = false) {
        self.title = title
        self.subTitle = subTitle
        self.showButton = showButton
        self.showImage = showImage
        self.imageName = imageName
        self.onStop = onStop
        self.isFlashing = isFlashing
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline)
                    
                    Text(subTitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()
                
                if showImage {
                    Image(systemName: imageName)
                        .resizable()
                        .frame(width: 15, height: 15)
                        .opacity(isFlashing ? 1 : 0)
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                                isFlashing.toggle()
                            }
                        }
                } else {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 15, height: 15)
                        .opacity(isFlashing ? 1 : 0)
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                                isFlashing.toggle()
                            }
                        }
                }
                
            }
            if showButton {
                Button(action: {
                    onStop()
                }) {
                    Text("Stop")
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(8)
                }
            }
            
        }
        .padding()
        .frame(maxWidth: 300)
        .background(RoundedRectangle(cornerRadius: 12)
            .fill(Color(UIColor.systemBackground))
            .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 4))
        .padding()
//        .offset(y: self.isExpanded ? 0 : -150)
    }
}
