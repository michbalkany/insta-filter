//
//  ContentView.swift
//  instaFilter
//
//  Created by Mich balkany on 12/25/23.
//
import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI

import SwiftUI

struct ContentView: View {
    @State private var processedImage: Image?
    @State private var filterIntesity = 0.5
    @State private var selectedItem: PhotosPickerItem?
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    @State private var showingFilters = false
    
    let context = CIContext()
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                PhotosPicker(selection: $selectedItem) {
                    if let processedImage {
                        processedImage
                            .resizable()
                            .scaledToFit()
                    } else {
                        ContentUnavailableView("No picture", systemImage: "photo.badge.plus", description:Text("Tap to import a photo"))
                    }
                }
                .buttonStyle(.plain)
                .onChange(of: selectedItem, loadImage)
                
                Spacer()
                
                HStack {
                    Text("Intensity")
                    Slider(value: $filterIntesity)
                        .onChange(of: filterIntesity, applyProcessing)
                }
                
                
                HStack {
                    Button("Change Filter", action: changeFilter)
                    Spacer()
                    
                    if let processedImage {
                        ShareLink(item: processedImage, preview: SharePreview("InstaFilter image", image: processedImage))
                    }
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("InstaFilter")
            .confirmationDialog("Select a filter", isPresented: $showingFilters) {
                Button("Crystalize") { setFilter(CIFilter.crystallize() )}
                Button("Edges") { setFilter(CIFilter.edges() )}
                Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur() )}
                Button("Pixellate") { setFilter(CIFilter.pixellate() )}
                Button("Sepia Tone") { setFilter(CIFilter.sepiaTone() )}
                Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask() )}
                Button("Vignette") { setFilter(CIFilter.vignette() )}
                Button("Cancel", role: .cancel) { }
            }
        }
    }
    
    func changeFilter() {
        showingFilters = true
    }
    
    func loadImage() {
        Task {
            guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else { return }
            
            guard let inputImage = UIImage(data: imageData) else { return }
            
            let beginImage = CIImage(image: inputImage)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            applyProcessing()
        }
    }
        
        func applyProcessing() {
            let inputKeys = currentFilter.inputKeys
            if inputKeys.contains(kCIInputIntensityKey) {
                currentFilter.setValue(filterIntesity, forKey: kCIInputIntensityKey)
            }
            if inputKeys.contains(kCIInputRadiusKey) {
                currentFilter.setValue(filterIntesity * 200, forKey: kCIInputRadiusKey)
            }
            if inputKeys.contains(kCIInputScaleKey) {
                currentFilter.setValue(filterIntesity * 10, forKey: kCIInputScaleKey)
            }
            
            guard let outputImage  = currentFilter.outputImage else { return }
            guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
                    else { return }
            
            let uiImage = UIImage(cgImage: cgImage)
            processedImage = Image(uiImage: uiImage)
        
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
}

#Preview {
    ContentView()
}
