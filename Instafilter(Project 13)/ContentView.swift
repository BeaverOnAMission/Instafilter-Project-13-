//
//  ContentView.swift
//  Instafilter(Project 13)
//
//  Created by mac on 06.05.2023.
//


import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ContentView: View {
    @State private var image: Image?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var filterIntensity = 0.5
    @State private var currentFilter:CIFilter = CIFilter.crystallize()
    let context = CIContext()
    @State private var showFilterSheet = false
    @State private var processedImage: UIImage?
    var body: some View {
        NavigationView{
            VStack {
                ZStack{
                    Rectangle().opacity(0)
                    Text("Tap to select a picture")
                    image?
                        .resizable()
                        .scaledToFit()
                       
                } .onTapGesture{
                    showingImagePicker = true
                }
                HStack{
                    Text("Intensity")
                    Slider(value: $filterIntensity)
                        .onChange(of: filterIntensity){_ in
                            applyProccesing()
                        }
                }.disabled(image == nil)
                HStack{
                    
                    Button("Change Filter") {
                        showFilterSheet = true
                    }
                    
                    Spacer()
                    
                    Button("Save", action: save)
                        .disabled(image == nil)
                }
            }
            .navigationTitle("Instafilter")
            .padding([.horizontal, .bottom])
        }
         .sheet(isPresented: $showingImagePicker){
            ImagePicker(image: $inputImage)
            }
         .confirmationDialog("select Filter", isPresented: $showFilterSheet){
             Button("Crystallize") {setFilter(CIFilter.crystallize())}
             Button("Pixellate") {setFilter(CIFilter.pixellate())}
             Button("Vignete") {setFilter(CIFilter.vignette())}
             Button("Gaussin Blur") {setFilter(CIFilter.gaussianBlur())}
             Button("Edges") {setFilter(CIFilter.edges())}
             Button("Sepia Tone") {setFilter(CIFilter.sepiaTone())}
             Button("Cancel", role: .cancel) { }
         }
        .onChange(of: inputImage) { _ in
            loadImage() 
        }
        
    }
    func applyProccesing() {
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey){
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey){
            currentFilter.setValue(filterIntensity*200, forKey: kCIInputRadiusKey)
        }
            if inputKeys.contains(kCIInputScaleKey){
                currentFilter.setValue(filterIntensity*100, forKey: kCIInputScaleKey)
        }
        guard let outputImage = currentFilter.outputImage else {return}
        
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent){
            let uiImage = UIImage(cgImage: cgImage)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else {return}
       
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProccesing()
        }
    
    func save() {
        guard let processedImage = processedImage else {return}
        let imageSaver = imageSaver()
        imageSaver.writeToPhotoAlbum(image: processedImage)
        imageSaver.sucessHandler = {
            print("Sucess")
        }
        imageSaver.errorHandler = {
            print("Oops! \($0.localizedDescription)")
        }
        }
    func setFilter(_ filter:CIFilter) {
        currentFilter = filter
        loadImage()
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
