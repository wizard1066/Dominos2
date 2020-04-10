//
//  ContentView.swift
//  Dominos
//
//  Created by localadmin on 07.04.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import SwiftUI
import Combine

enum DragState {
  case inactive
  case dragging(translation: CGSize)
}

struct newView:Identifiable {
  var id:UUID? = UUID()
  var highImage:String = ""
  var lowImage:String = ""
}

class newViews: ObservableObject {
  @Published var nouViews: [newView]
  
  init() {
    self.nouViews = allocateImagesV()
  }
}

struct Fonts {
  static func zapfino (size:CGFloat) -> Font{
    return Font.custom("Zapfino",size: size)
  }
}

struct ContentView: View {
  @ObservedObject var novelleViews = newViews()
  
  var body: some View {
    let screenSize = UIScreen.main.bounds
    let screenWidth = screenSize.width
    let screenHeight = screenSize.height
    return VStack {
      ScrollView(Axis.Set.horizontal, showsIndicators: true) {
        VStack {
          ZStack {
            Rectangle()
              .fill(Color.yellow)
              .frame(minWidth: screenWidth * 4, maxHeight: screenHeight * 0.6)
            Text("Dominos with Better Programming")
              .font(Fonts.zapfino(size: 128))
              .opacity(0.2)
          }
        }
        HStack {
          ForEach((0 ..< 7), id: \.self) { column in
            DominoWrapper(novelleViews: self.novelleViews, column: column, spin: 0)
          }
//          ZStack {
            ForEach((6 ..< 33), id: \.self) { column in
              DominoWrapper(novelleViews: self.novelleViews, column: column, spin: 0)
            }
//          }
        }
      }
      
      }
    
  }
}

struct DominoWrapper: View {
  @ObservedObject var novelleViews:newViews
  @State var column:Int
  @State var spin:Double
  @State var xpin:Double = -180
  @State var dragOffset = CGSize.zero
  @State var accumulated = CGSize.zero
  @State var rotateAngle:Double = 0
  @State var hideBack = false
  @State var magnificationEffect: CGFloat = 1
  
  var body: some View {
   
    return Group { ZStack {
      Back(spin: -spin).onTapGesture {
        withAnimation(Animation.easeInOut(duration: 1.0).delay(0)) {
          self.spin = 180
        }
      }.rotation3DEffect(.degrees(spin), axis: (x: 0, y: 1, z: 0))
        .opacity(hideBack ? 0:1)
      if self.spin > 175 {
        Domino(spin: $xpin, novelleViews: novelleViews, index: $column).onAppear {
          withAnimation(Animation.easeInOut(duration: 1.0).delay(0)) {
            self.xpin = 0
            self.hideBack = true
          }
        }.rotation3DEffect(.degrees(xpin), axis: (x: 0, y: 1, z: 0))
          .gesture(TapGesture(count: 2)
            .onEnded({ (_) in
              withAnimation {
                if self.rotateAngle < 360 {
                  self.rotateAngle += 90
                } else {
                  self.rotateAngle = 0
                }
                print("rotateAngle ",self.rotateAngle)
              }
              }
            )
        ).rotationEffect(.degrees(self.rotateAngle), anchor: .center)
      }
      
    }.offset(x: self.dragOffset.width, y: self.dragOffset.height)
      .gesture(DragGesture(coordinateSpace: .global)
        .onChanged({ ( value ) in
          self.dragOffset = CGSize(width: value.translation.width + self.accumulated.width, height: value.translation.height + self.accumulated.height)
        })
        .onEnded { ( value ) in
          self.dragOffset = CGSize(width: value.translation.width + self.accumulated.width, height: value.translation.height + self.accumulated.height)
          self.accumulated = self.dragOffset
        }
    ).scaleEffect(magnificationEffect, anchor: .center)
    .gesture(MagnificationGesture()
    .onChanged { value in
      self.magnificationEffect = value
    })
    }
  }
}

struct Domino: View {
  @Binding var spin:Double
  @ObservedObject var novelleViews:newViews
  @Binding var index:Int
  
  var body: some View {
    Rectangle()
      .fill(Color.clear)
      .frame(width: 48, height: 96, alignment: .center)
      .background(
        VStack{
          Image(self.novelleViews.nouViews[index].highImage)
            .resizable()
            .frame(width: 32, height: 32, alignment: .top)
            .padding(4)
          Divider()
            .frame(width: 24, height: 2, alignment: .center)
          Image(self.novelleViews.nouViews[index].lowImage)
            .resizable()
            .frame(width: 32, height: 32, alignment: .bottom)
            .padding(4)
        }
    ).overlay(RoundedRectangle(cornerRadius: 8)
      .stroke(lineWidth: 2))
      
  }
}

struct Back: View {
  @State var spin:Double
  
  var body: some View {
    Rectangle()
      .fill(Color.clear)
      .frame(width: 48, height: 96, alignment: .center)
      .background(
        VStack{
          Image("image_part_000")
            .resizable()
            .frame(width: 32, height: 32, alignment: .top)
            .padding(4)
          Divider()
            .frame(width: 24, height: 2, alignment: .center)
          Image("image_part_000")
            .resizable()
            .frame(width: 32, height: 32, alignment: .bottom)
            .padding(4)
        }
    ).overlay(RoundedRectangle(cornerRadius: 8)
      .stroke(lineWidth: 2))
    
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(novelleViews: newViews.init())
  }
}

func allocateImagesV() -> [newView] {
  var primaryImages:Set<String> = []
  var secondaryImages:Set<String> = []
  var tiles:Set<String> = []
  
  
  
for _ in 0..<2 {
  for build in 2..<36 {
    primaryImages.insert(String(format: "image_part_%03d",build))
    print(String(format: "image_part_%03d",build))
  }
  repeat {
    let elementA = primaryImages.randomElement()
    primaryImages.remove(elementA!)
    let elementB = primaryImages.randomElement()
    primaryImages.remove(elementB!)
    tiles.insert(elementA! + ":" + elementB!)
    secondaryImages.insert(elementA!)
    secondaryImages.insert(elementB!)
  } while !primaryImages.isEmpty
  }
  
  var answer:[newView] = []
  for tile in tiles {
    var highImage:String!
    var lowImage:String!
    let images = tile.split(separator: ":").map(String.init)
      if images != [] {
        highImage = images[0]
        lowImage = images[1]
      }
    let tileView = newView(id: nil, highImage: highImage, lowImage: lowImage)
    answer.append(tileView)
  }
  return answer
}

func allocateImages() -> [newView] {
  var primaryImages:Set<String> = []
  var secondaryImages:Set<String> = []
  var tiles:Set<String> = []
  
  for build in 2..<37 {
    primaryImages.insert(String(format: "image_part_%03d",build))
    print(String(format: "image_part_%03d",build))
  }
  
  let elementA = primaryImages.randomElement()
  primaryImages.remove(elementA!)
  let elementB = primaryImages.randomElement()
  primaryImages.remove(elementB!)

  tiles.insert(elementA! + ":" + elementB!)
  secondaryImages.insert(elementA!)
  secondaryImages.insert(elementB!)
  repeat {
    let elementC = primaryImages.randomElement()
    primaryImages.remove(elementC!)
    let elementD = secondaryImages.randomElement()
    secondaryImages.remove(elementD!)
    secondaryImages.insert(elementC!)

    tiles.insert(elementC! + ":" + elementD!)
  } while !primaryImages.isEmpty
  let elementE = secondaryImages.removeFirst()
  let elementF = secondaryImages.randomElement()
  tiles.insert(elementE + ":" + elementF!)
  print("tiles ",tiles,secondaryImages.count)
  
  var answer:[newView] = []
  for tile in tiles {
    var highImage:String!
    var lowImage:String!
    let images = tile.split(separator: ":").map(String.init)
      if images != [] {
        highImage = images[0]
        lowImage = images[1]
      }
    let tileView = newView(id: nil, highImage: highImage, lowImage: lowImage)
    answer.append(tileView)
  }
  return answer
}

