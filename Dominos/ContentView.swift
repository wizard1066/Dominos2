//
//  ContentView.swift
//  Dominos
//
//  Created by localadmin on 07.04.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import SwiftUI

enum DragState {
  case inactive
  case dragging(translation: CGSize)
}

struct Fonts {
    static func sanFranciscoDisplayBold (size:CGFloat) -> Font{
        return Font.custom("SanFranciscoDisplay-Bold",size: size)
    }
}

struct ContentView: View {
  @State var flipped = false

  
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
            .font(Fonts.sanFranciscoDisplayBold(size: 128))
            .opacity(0.2)
          }
        }
        HStack {
          ForEach((0 ..< 7), id: \.self) { column in
            DominoWrapper(highImage: "image_part_011", lowImage: "image_part_011", spin: 0)
          }
        }
      }
      
    }
  }
}

struct DominoWrapper: View {
  @State var highImage:String
  @State var lowImage:String
  @State var spin:Double
  @State var xpin:Double = -180
  @State var dragOffset = CGSize.zero
  @State var accumulated = CGSize.zero
  @State var rotateAngle:Double = 0
  @State var hideBack = false

  
  var body: some View {
    ZStack {
      Back(spin: -spin).onTapGesture {
      withAnimation(Animation.easeInOut(duration: 1.5).delay(0)) {
        self.spin = 180
      }
    }.rotation3DEffect(.degrees(spin), axis: (x: 0, y: 1, z: 0))
    .opacity(hideBack ? 0:1)
    if self.spin == 180 {
      Domino(highImage: highImage, lowImage: lowImage, spin: xpin).onAppear {
        withAnimation(Animation.easeInOut(duration: 1.5).delay(0)) {
          self.xpin = 0
        }
      }.rotation3DEffect(.degrees(xpin), axis: (x: 0, y: 1, z: 0))
        .gesture(LongPressGesture()
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
          self.hideBack = true
        })
        .onEnded { ( value ) in
          self.dragOffset = CGSize(width: value.translation.width + self.accumulated.width, height: value.translation.height + self.accumulated.height)
          self.accumulated = self.dragOffset
        }
    )
    
  }
}

struct Domino: View {
  @State var highImage:String
  @State var lowImage:String
  @State var spin:Double
  
  var body: some View {
    Rectangle()
      .fill(Color.clear)
      .frame(width: 48, height: 96, alignment: .center)
      .background(
        VStack{
          Image(highImage)
            .resizable()
            .frame(width: 32, height: 32, alignment: .top)
            .padding(4)
          Divider()
            .frame(width: 24, height: 2, alignment: .center)
          Image(lowImage)
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
          Image("image_part_001")
            .resizable()
            .frame(width: 32, height: 32, alignment: .top)
            .padding(4)
          Divider()
            .frame(width: 24, height: 2, alignment: .center)
          Image("image_part_001")
            .resizable()
            .frame(width: 32, height: 32, alignment: .bottom)
            .padding(4)
        }
    ).overlay(RoundedRectangle(cornerRadius: 8)
          .stroke(lineWidth: 2))
          .rotation3DEffect(.degrees(spin), axis: (x: 0, y: 1, z: 0))
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}


