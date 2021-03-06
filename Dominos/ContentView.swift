//
//  ContentView.swift
//  dominos
//
//  Created by localadmin on 07.04.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import SwiftUI
import Combine

let rotateDominoPublisher = PassthroughSubject<(Int,Double), Never>()
let flipDominoPublisher = PassthroughSubject<(Int,Double), Never>()
let resetPublisher = PassthroughSubject<Void, Never>()

struct Fonts {
  static func zapfino (size:CGFloat) -> Font{
    return Font.custom("Zapfino",size: size)
  }
}

struct newView:Identifiable {
  var id:UUID? = UUID()
  var highImage:String = ""
  var lowImage:String = ""
  var rect:CGRect?
  var offset:CGSize = CGSize.zero
}

class newViews: ObservableObject {
  @Published var nouViews: [newView] {
    // force change when array contents change with willSet
    willSet {
      objectWillChange.send()
    }
  }
  
  init() {
    self.nouViews = allocateImagesV()
  }
}

struct ContentView: View {
  @ObservedObject var novelleViews = newViews()
  @State var disableScrollView = false
  @State var fudge = 0
  @State var fudgeOffset = CGSize.zero
  @State var accumulated = CGSize.zero
  @State private var rect:[CGRect] = []
  @State private var tiles:Int = 0
 
  
  var body: some View {
    let screenSize = UIScreen.main.bounds
    let screenWidth = screenSize.width
    let screenHeight = screenSize.height
    return VStack {
      VStack {
        VStack {
          ZStack {
            Rectangle()
              .fill(Color.yellow)
              .frame(minWidth: screenWidth * 4, maxHeight: screenHeight * 0.6)
            Text("Dominos with Better Programming")
              .font(Fonts.zapfino(size: 128))
              .opacity(0.2)
          }.onAppear {
            // emulate network code
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(16)) {
              //                self.novelleViews.nouViews = allocateImagesV()
            }
          }
        }
        HStack {
          ForEach((0 ..< 25), id: \.self) { column in
            DominoWrapper(novelleViews: self.novelleViews, column: column)
              .offset(self.novelleViews.nouViews[column].offset)
          }
        }
      }.offset(CGSize(width: fudge, height: 0))
        .offset(fudgeOffset)
        .gesture(DragGesture(coordinateSpace: .global)
          .onChanged({ ( value ) in
//            self.fudgeOffset = CGSize(width: value.translation.width + self.accumulated.width, height: value.translation.height + self.accumulated.height)
              self.fudgeOffset = CGSize(width: value.translation.width + self.accumulated.width, height: 0)
          })
          .onEnded { ( value ) in
//            self.fudgeOffset = CGSize(width: value.translation.width + self.accumulated.width, height: value.translation.height + self.accumulated.height)
            self.fudgeOffset = CGSize(width: value.translation.width + self.accumulated.width, height: 0)
            self.accumulated = self.fudgeOffset
          }
      ) // VStack
    }
//    .onReceive(resetPublisher) { (_) in
//      self.novelleViews.nouViews = allocateImagesV()
//    }.onReceive(setTilesPublisher) { ( figure ) in
//      self.tiles = figure
//    }
  }
}

//struct ContentView: View {
//  var body: some View {
//    let screenSize = UIScreen.main.bounds
//    let screenWidth = screenSize.width
//    let screenHeight = screenSize.height
//    return ScrollView(Axis.Set.horizontal, showsIndicators: true) {
//      VStack {
//        ZStack {
//          Rectangle()
//            .fill(Color.yellow)
//            .frame(minWidth: screenWidth * 1.5, maxHeight: screenHeight * 0.6)
//          ZStack {
//          Text("Dominos with")
//            .font(Fonts.zapfino(size: 56))
//            .opacity(0.5)
//            .offset(CGSize(width: 0, height: -60))
//          Text("Better Programming")
//            .font(Fonts.zapfino(size: 56))
//            .opacity(0.5)
//            .offset(CGSize(width: 0, height: 40))
//          }.padding()
//        }
//        HStack {
//          DominoWrapper(highImage: "Image-1", lowImage: "Image-12")
//          DominoWrapper(highImage: "Image-2", lowImage: "Image-13")
//          DominoWrapper(highImage: "Image-3", lowImage: "Image-14")
//        }.padding()
//      }
//    }
//  }
//}
    
var runOnce = true

struct InsideView: View {
  @Binding var rect: [CGRect]
  
  var body: some View {
  
      return VStack {
         GeometryReader { geometry in
          Rectangle()
            .fill(Color.yellow)
            .frame(width: 256, height: 256, alignment: .center)
            .opacity(0.5)
            .onAppear {
              if runOnce {
                self.rect.append(geometry.frame(in: .global))
              }
          }
        }
    }
  }
}

struct DominoWrapper: View {
  @ObservedObject var novelleViews:newViews
  @State var column:Int
  @State var dragOffset = CGSize.zero
  @State var accumulated = CGSize.zero
  @State var newAngle:Double = 0
//  @State var highImage:String = ""
//  @State var lowImage:String = ""
  
  @State var hideBack = false
  @State var spin:Double = 0
  @State var xpin:Double = -180
  
  var body: some View {
    
    return ZStack {
      Back(column: $column).onTapGesture {
        withAnimation(Animation.linear(duration: 2.0).delay(0)) {
          self.spin = 180
        }
      }
      .border(Color.black)
      .rotation3DEffect(.degrees(spin), axis: (x: 0, y: 1, z: 0))
      .rotationEffect(.degrees(self.newAngle), anchor: .center)
      .onReceive(rotateDominoPublisher) { ( tupple ) in
        let (domino,direction) = tupple
        if domino == self.$column.wrappedValue {
          self.newAngle += direction
          print("fuck ",self.newAngle )
        }
      }
      .opacity(hideBack ? 0.3:1)
      
      
      if self.spin == 180 {
        DoDomino(column: column, dragOffset: self.dragOffset, accumulated: self.accumulated, highImage: self.novelleViews.nouViews[column].highImage, lowImage: self.novelleViews.nouViews[column].lowImage).onAppear {
          withAnimation(Animation.linear(duration: 2.0).delay(0)) {
            self.xpin = 0
          }
          DispatchQueue.main.asyncAfter(deadline: .now() + Double(0)) {
            self.hideBack = true
          }
        }
      }
    }.rotation3DEffect(.degrees(xpin), axis: (x: 0, y: 1, z: 0))
    .offset(x: self.dragOffset.width, y: self.dragOffset.height)
      .gesture(DragGesture(coordinateSpace: .global)
        .onChanged({ ( value ) in
          self.dragOffset = CGSize(width: value.translation.width + self.accumulated.width, height: value.translation.height + self.accumulated.height)
        })
        .onEnded { ( value ) in
          self.dragOffset = CGSize(width: value.translation.width + self.accumulated.width, height: value.translation.height + self.accumulated.height)
          self.accumulated = self.dragOffset
        }
    ).onReceive(resetPublisher) { (_) in
        self.dragOffset.width = CGFloat(0)
        self.dragOffset.height = CGFloat(0)
        self.accumulated = CGSize.zero
        self.newAngle = 0
      }
  }
}

struct DoDomino: View {
  @State var column:Int
  @State var dragOffset = CGSize.zero
  @State var accumulated = CGSize.zero
  @State var rotateAngle:Double = 0
  @State var highImage:String
  @State var lowImage:String
  @State var flipper:Double = 0
  
  var body: some View {
    Domino(highImage: $highImage, lowImage: $lowImage, flipper: $flipper, index: $column)
      .border(Color.black)
      .rotationEffect(.degrees(self.rotateAngle), anchor: .center)
      .gesture(LongPressGesture()
        .onEnded({ (_) in
          withAnimation {
            if self.rotateAngle < 360 {
              self.rotateAngle += 90
              self.flipper -= 90
              rotateDominoPublisher.send((self.column,90))
            } else {
              self.rotateAngle = 0
              rotateDominoPublisher.send((self.column,0))
              self.flipper = 0
            }
          }
          }
        )
    )
    .onReceive(flipDominoPublisher, perform: { ( tupple ) in
                let (domino,direction) = tupple
                if domino == self.$column.wrappedValue {
                withAnimation {
                if self.rotateAngle < 360 {
                  self.rotateAngle += direction
                  self.flipper -= direction
                } else {
                  self.rotateAngle = 0
                  self.flipper = 0
                }
              }
              }
        }).onReceive(resetPublisher) { (_) in
            self.flipper = 0
            self.rotateAngle = 0
          }
    
  }
}

struct Domino: View {
  @Binding var highImage:String
  @Binding var lowImage:String
  @Binding var flipper: Double
  @Binding var index:Int
  
  
  var body: some View {
    return RoundedRectangle(cornerRadius: 8)
      .fill(Color.clear)
      .frame(width: 48, height: 96, alignment: .center)
      .background(
        VStack {
          Image(highImage)
            .resizable()
            .frame(width: 32, height: 32, alignment: .top)
            .padding(4)
            .rotationEffect(.degrees(flipper), anchor: .center)
            .onTapGesture(count: 2) {
              flipDominoPublisher.send((self.index, 180))
            }
            
          Divider()
            .frame(width: 24, height: 2, alignment: .center)
          Image(lowImage)
            .resizable()
            .frame(width: 32, height: 32, alignment: .bottom)
            .padding(4)
            .rotationEffect(.degrees(flipper), anchor: .center)
            .onTapGesture(count: 2) {
              flipDominoPublisher.send((self.index, -180))
            }
      })
  }
}

struct Back: View {
  @State var newAngle:Double = 0
  @Binding var column:Int
  
  var body: some View {
    RoundedRectangle(cornerRadius: 8)
      .fill(Color.clear)
      .frame(width: 48, height: 96, alignment: .center)
      .background(
        VStack{
          Image("Image-Back")
            .resizable()
            .frame(width: 32, height: 32, alignment: .top)
            .padding(4)
          Divider()
            .frame(width: 24, height: 2, alignment: .center)
          Image("Image-Back")
            .resizable()
            .frame(width: 32, height: 32, alignment: .bottom)
            .padding(4)
        }
    )
    
  }
}

func allocateImagesV() -> [newView] {
  var primaryImages:Set<String> = []
  var secondaryImages:Set<String> = []
  var tiles:Set<String> = []
  
  
  for _ in 0..<2 {
    for build in 2..<16 {
            primaryImages.insert(String(format: "Image-%d",build))
            secondaryImages.insert(String(format: "Image-%d",build))
//      primaryImages.insert(String(format: "image_part_%03d",build))
//      secondaryImages.insert(String(format: "image_part_%03d",build))
      
    }
    repeat {
      
      let elementA = primaryImages.removeFirst()
      //      primaryImages.remove(elementA)
      
      let elementB = secondaryImages.randomElement()
      secondaryImages.remove(elementB!)
      
      tiles.insert(elementA + ":" + elementB!)
    } while !primaryImages.isEmpty
  }
  
  var count = 0
  for tile in tiles {
    print("tile ",tile,count)
    count += 1
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
    let tileView = newView(highImage: highImage, lowImage: lowImage)
    answer.append(tileView)
  }
  return answer
}

  

//struct dominoView: View {
//  @State var topNo:Int!
//  @State var lowNo:Int!
//
//  var body: some View {
//    return ZStack {
//      RoundedRectangle(cornerRadius: 5)
//        .stroke(Color.black, lineWidth: 2)
//        .frame(width: 48, height: 80, alignment: .top)
//        .background(Color.clear)
//      VStack {
//        HStack {
//          ForEach((0 ..< topNo), id: \.self) { column in
//            Circle()
//              .fill(Color.black)
//              .frame(width: 12, height: 12, alignment: .center)
//              .overlay(
//                RoundedRectangle(cornerRadius: 20)
//                  .stroke(Color.clear, lineWidth: 2)
//                  .frame(width: 32, height: 32, alignment: .center)
//                  .background(Color.clear)
//            )
//          }
//        }
//        Divider()
//          .frame(width: 32, height: 2, alignment: .center)
//        HStack {
//          ForEach((0 ..< lowNo), id: \.self) { column in
//            Circle()
//              .fill(Color.black)
//              .frame(width: 12, height: 12, alignment: .center)
//              .overlay(
//                RoundedRectangle(cornerRadius: 10)
//                  .stroke(Color.clear, lineWidth: 2)
//                  .frame(width: 32, height: 32, alignment: .center)
//                  .background(Color.clear)
//            )
//          }
//        }
//      }
//    }
//  }
//}

extension UIWindow {
  open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    if motion == .motionShake {
//      print("Device shaken")
      resetPublisher.send()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




////
////  ContentView.swift
////  Dominos
////
////  Created by localadmin on 07.04.20.
////  Copyright © 2020 Mark Lucking. All rights reserved.
////
//
//import SwiftUI
//import Combine
//import Introspect
//
//let rotateDominoPublisher = PassthroughSubject<Int, Never>()
//let flipDominoPublisher = PassthroughSubject<(Int,Double), Never>()
//let resetPublisher = PassthroughSubject<Void, Never>()
//let setTilesPublisher = PassthroughSubject<Int, Never>()
//
//enum DragState {
//  case inactive
//  case dragging(translation: CGSize)
//}
//
//
//
//struct newView:Identifiable {
//  var id:UUID? = UUID()
//  var highImage:String = ""
//  var lowImage:String = ""
//  var rect:CGRect?
//  var offset:CGSize = CGSize.zero
//}
//
//class newViews: ObservableObject {
//  @Published var nouViews: [newView] {
//    // force change when array contents change with willSet
//    willSet {
//      objectWillChange.send()
//    }
//  }
//
//  init() {
//    self.nouViews = allocateImagesV()
//  }
//}
//
//struct Fonts {
//  static func zapfino (size:CGFloat) -> Font{
//    return Font.custom("Zapfino",size: size)
//  }
//}
//
//struct ContentView: View {
//  @ObservedObject var novelleViews = newViews()
//  @State var fudge = 0
//  @State var fudgeOffset = CGSize.zero
//  @State var accumulated = CGSize.zero
//  @State private var rect:[CGRect] = []
//  @State private var tiles:Int = 0
//
//
//  var body: some View {
//    let screenSize = UIScreen.main.bounds
//    let screenWidth = screenSize.width
//    let screenHeight = screenSize.height
//    return VStack {
//      VStack {
//        VStack {
//          ZStack {
//            Rectangle()
//              .fill(Color.yellow)
//              .frame(minWidth: screenWidth * 4, maxHeight: screenHeight * 0.6)
//            Text("Dominos with Better Programming")
//              .font(Fonts.zapfino(size: 128))
//              .opacity(0.2)
//          }.onAppear {
//            // emulate network code
//            DispatchQueue.main.asyncAfter(deadline: .now() + Double(16)) {
//              //                self.novelleViews.nouViews = allocateImages()
//            }
//          }
//        }
//        HStack {
////          ForEach((0 ..< 68), id: \.self) { column in
//          ForEach((0 ..< 25), id: \.self) { column in
//            DominoWrapper(novelleViews: self.novelleViews, column: column)
//              .offset(self.novelleViews.nouViews[column].offset)
//          }
//          // ZStack {
//          //            ForEach((6 ..< 67), id: \.self) { column in
//          //              DominoWrapper(novelleViews: self.novelleViews, column: column, spin: 0)
//          //            }
//          //          }
//        }
//        //      } // ScrollView
//      }.offset(CGSize(width: fudge, height: 0))
//        .offset(fudgeOffset)
//        .gesture(DragGesture(coordinateSpace: .global)
//          .onChanged({ ( value ) in
//            self.fudgeOffset = CGSize(width: value.translation.width + self.accumulated.width, height: value.translation.height + self.accumulated.height)
//          })
//          .onEnded { ( value ) in
//            self.fudgeOffset = CGSize(width: value.translation.width + self.accumulated.width, height: value.translation.height + self.accumulated.height)
//            self.accumulated = self.fudgeOffset
//          }
//      ) // VStack
//    }.onReceive(resetPublisher) { (_) in
//      self.novelleViews.nouViews = allocateImagesV()
//    }.onReceive(setTilesPublisher) { ( figure ) in
//      self.tiles = figure
//    }
//  }
//}
//
//struct DominoWrapper: View {
//  @ObservedObject var novelleViews:newViews
//  @State var column:Int
//  @State var spin:Double = 0
//  @State var xpin:Double = -180
//  @State var dragOffset = CGSize.zero
//  @State var accumulated = CGSize.zero
//  @State var rotateAngle:Double = 0
//  @State var hideBack = false
//  @State var magnificationEffect: CGFloat = 1
//  @State var flipper:Double = 0
////  @Binding var rect:[CGRect]
//  @GestureState private var dragState = DragState.inactive
//
//
//  var body: some View {
//
//    return Group { ZStack {
//      Back().onTapGesture {
//        withAnimation(Animation.easeInOut(duration: 1.0).delay(0)) {
//          self.spin = 180
//
//        }
//      }
//      .rotation3DEffect(.degrees(spin), axis: (x: 0, y: 1, z: 0))
//      .opacity(hideBack ? 0.1:1)
//      .rotationEffect(.degrees(self.rotateAngle), anchor: .center)
//
//
//      if self.spin > 179 {
//        Domino(spin: $xpin, novelleViews: novelleViews, index: $column, flipper: $flipper)
////        .background(InsideView(rect: $rect))
//          .background(InsideView(novelleViews: novelleViews, index: $column))
//        .onAppear {
//          withAnimation(Animation.easeInOut(duration: 1.0).delay(0)) {
//            self.xpin = 0
//          }
//          DispatchQueue.main.asyncAfter(deadline: .now() + Double(2)) {
//            self.hideBack = true
//          }
//        }.rotation3DEffect(.degrees(xpin), axis: (x: 0, y: 1, z: 0))
//          .gesture(TapGesture(count: 2)
//            .onEnded({ (_) in
//              withAnimation {
//                if self.rotateAngle < 360 {
//                  self.rotateAngle += 90
//                  self.flipper -= 90
//                } else {
//                  self.rotateAngle = 0
//                  self.flipper = 0
//                }
//              }
//              }
//            )
//        ).onReceive(flipDominoPublisher, perform: { ( tupple ) in
//                let (domino,direction) = tupple
//                if domino == self.$column.wrappedValue {
//                withAnimation {
//                if self.rotateAngle < 360 {
//                  self.rotateAngle += direction
//                  self.flipper -= direction
//                } else {
//                  self.rotateAngle = 0
//                  self.flipper = 0
//                }
//              }
//              }
//        })
//        .onReceive(rotateDominoPublisher, perform: { ( domino ) in
//                if domino == self.$column.wrappedValue {
//                withAnimation {
//                if self.rotateAngle < 360 {
//                  self.rotateAngle += 180
//                  self.flipper -= 180
//                } else {
//                  self.rotateAngle = 0
//                  self.flipper = 0
//                }
//              }
//              }
//        })
//        .rotationEffect(.degrees(self.rotateAngle), anchor: .center)
//      }
//
//    }.offset(x: self.dragOffset.width, y: self.dragOffset.height)
//      .gesture(DragGesture(coordinateSpace: .global)
//        .updating($dragState, body: {dragValue, state, transaction in
////          print("details ",dragValue,state,transaction)
//        })
//        .onChanged({ ( value ) in
//          self.dragOffset = CGSize(width: value.translation.width + self.accumulated.width, height: value.translation.height + self.accumulated.height)
//        })
//        .onEnded { ( value ) in
//          self.dragOffset = CGSize(width: value.translation.width + self.accumulated.width, height: value.translation.height + self.accumulated.height)
//          self.accumulated = self.dragOffset
////          print("fooBar ",self.column,self.novelleViews.nouViews[self.column].id, self.novelleViews.nouViews[self.column].highImage,self.novelleViews.nouViews[self.column].lowImage)
//        }
//      ).onReceive(resetPublisher) { (_) in
//        self.dragOffset.width = CGFloat(0)
//        self.dragOffset.height = CGFloat(0)
//        self.accumulated = CGSize.zero
//        self.rotateAngle = 0
//      }
//      // .scaleEffect(magnificationEffect, anchor: .center)
//      //    .onLongPressGesture {
//      //        withAnimation(Animation.easeInOut(duration: 1.0).delay(0)) {
//      //          self.magnificationEffect = 2.0
//      //        }
//      //      }
//      //    .gesture(MagnificationGesture()
//      //    .onChanged { value in
//      //      self.magnificationEffect = value
//      //    })
//    }.onAppear {
////      self.novelleViews.nouViews[self.column].rect = self.rect.last
//    }
//  }
//}
//
//struct Domino: View {
//  @Binding var spin:Double
//  @ObservedObject var novelleViews:newViews
//  @Binding var index:Int
//  @State var rotateAngle: Double = 0
//  @Binding var flipper: Double
//
//
//  var body: some View {
//    return Rectangle()
//      .fill(Color.clear)
//      .frame(width: 48, height: 96, alignment: .center)
//      .background(
//        VStack{
//          Image(self.novelleViews.nouViews[index].highImage)
//            .resizable()
//            .frame(width: 32, height: 32, alignment: .top)
//            .padding(4)
//            .rotationEffect(.degrees(flipper), anchor: .center)
//            .onTapGesture(count: 2) {
//              flipDominoPublisher.send((self.index, 90))
//            }
//            .gesture(LongPressGesture()
//              .onEnded({ (_) in
//              rotateDominoPublisher.send(self.index)
//            }
//          )).onReceive(resetPublisher) { (_) in
//            self.flipper = 0
//          }
//
//
//          Divider()
//            .frame(width: 24, height: 2, alignment: .center)
//          Image(self.novelleViews.nouViews[index].lowImage)
//            .resizable()
//            .frame(width: 32, height: 32, alignment: .bottom)
//            .padding(4)
//            .rotationEffect(.degrees(flipper), anchor: .center)
//            .onTapGesture(count: 2) {
//              flipDominoPublisher.send((self.index, -90))
//            }
//            .gesture(LongPressGesture()
//              .onEnded({ (_) in
//                rotateDominoPublisher.send(self.index)
//                }
//              )
//          )
//        }.onReceive(resetPublisher) { (_) in
//            self.flipper = 0
//          }
//    ).overlay(RoundedRectangle(cornerRadius: 8)
//      .stroke(lineWidth: 2))
//  }
//}
//
//struct Back: View {
//
//  var body: some View {
//    Rectangle()
//      .fill(Color.clear)
//      .frame(width: 48, height: 96, alignment: .center)
//      .background(
//        VStack{
//          Image("image_part_000")
//            .resizable()
//            .frame(width: 32, height: 32, alignment: .top)
//            .padding(4)
//          Divider()
//            .frame(width: 24, height: 2, alignment: .center)
//          Image("image_part_000")
//            .resizable()
//            .frame(width: 32, height: 32, alignment: .bottom)
//            .padding(4)
//        }
//    )
//    .overlay(RoundedRectangle(cornerRadius: 8)
//      .stroke(lineWidth: 2))
//
//  }
//}
//
//var runOnce = true
//var index2D = 0
//
//struct InsideView: View {
////  @Binding var rect: [CGRect]
//  @ObservedObject var novelleViews:newViews
//  @Binding var index:Int
//
//  var body: some View {
//      return VStack {
//         GeometryReader { geometry in
//          Rectangle()
//            .fill(Color.clear)
//            .onAppear {
//              if runOnce {
//                self.novelleViews.nouViews[self.index].rect = geometry.frame(in: .global)
////                self.rect.append(geometry.frame(in: .global))
//
//              }
//          }
//        }
//    }
//  }
//}
//
//struct ContentView_Previews: PreviewProvider {
//  static var previews: some View {
//    ContentView(novelleViews: newViews.init())
//  }
//}
//
////      primaryImages.insert(String(format: "image_part_%03d",build))
////      secondaryImages.insert(String(format: "image_part_%03d",build))
//
//func allocateImagesV() -> [newView] {
//  var primaryImages:Set<String> = []
//  var secondaryImages:Set<String> = []
//  var tiles:Set<String> = []
//
//  for _ in 0..<2 {
//    for build in 2..<16 {
//            primaryImages.insert(String(format: "Image-%d",build))
//            secondaryImages.insert(String(format: "Image-%d",build))
//    }
//    repeat {
//      let elementA = primaryImages.removeFirst()
//      let elementB = secondaryImages.randomElement()
//      secondaryImages.remove(elementB!)
//      tiles.insert(elementA + ":" + elementB!)
//    } while !primaryImages.isEmpty
//  }
//
//  var count = 0
//  for tile in tiles {
//    print("tile ",tile,count)
//    count += 1
//  }
//
//  var answer:[newView] = []
//  for tile in tiles {
//    var highImage:String!
//    var lowImage:String!
//    let images = tile.split(separator: ":").map(String.init)
//    if images != [] {
//      highImage = images[0]
//      lowImage = images[1]
//    }
//    let tileView = newView(highImage: highImage, lowImage: lowImage)
//    answer.append(tileView)
//  }
//  return answer
//}
//
//func allocateImages() -> [newView] {
//  var primaryImages:Set<String> = []
//  var secondaryImages:Set<String> = []
//  var tiles:Set<String> = []
//
//  for build in 2..<37 {
//    primaryImages.insert(String(format: "image_part_%03d",build))
//    print(String(format: "image_part_%03d",build))
//  }
//
//  let elementA = primaryImages.randomElement()
//  primaryImages.remove(elementA!)
//  let elementB = primaryImages.randomElement()
//  primaryImages.remove(elementB!)
//
//  tiles.insert(elementA! + ":" + elementB!)
//  secondaryImages.insert(elementA!)
//  secondaryImages.insert(elementB!)
//  repeat {
//    let elementC = primaryImages.randomElement()
//    primaryImages.remove(elementC!)
//    let elementD = secondaryImages.randomElement()
//    secondaryImages.remove(elementD!)
//    secondaryImages.insert(elementC!)
//
//    tiles.insert(elementC! + ":" + elementD!)
//  } while !primaryImages.isEmpty
//  let elementE = secondaryImages.removeFirst()
//  let elementF = secondaryImages.randomElement()
//  tiles.insert(elementE + ":" + elementF!)
//  print("tiles ",tiles,secondaryImages.count)
//
//  var answer:[newView] = []
//  for tile in tiles {
//    var highImage:String!
//    var lowImage:String!
//    let images = tile.split(separator: ":").map(String.init)
//    if images != [] {
//      highImage = images[0]
//      lowImage = images[1]
//    }
//    let tileView = newView(id: nil, highImage: highImage, lowImage: lowImage)
//    answer.append(tileView)
//  }
//  return answer
//}
//
//extension UIWindow {
//  open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
//    if motion == .motionShake {
////      print("Device shaken")
//      resetPublisher.send()
//    }
//  }
//}
