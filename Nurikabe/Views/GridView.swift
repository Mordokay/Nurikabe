//
//  GridView.swift
//  Nurikabe
//
//  Created by Pedro Saldanha on 08/02/2024.
//

import SwiftUI

struct GridView: View {
  var grid: [[Int]]
  @ObservedObject var viewModel: NurikabeViewModel
  var interactable: Bool

    var body: some View {
      ForEach((0..<grid.count), id: \.self) { i in
        HStack(spacing: 0) {
          ForEach((0..<grid[i].count), id: \.self) { j in
            if grid[i][j] == -1 {
              Rectangle()
                .fill(.black)
                .frame(width: 50, height: 50)
                .border(Color.black, width: 2)
                .onTapGesture {
                  if interactable{
                    viewModel.didTap(x: i, y: j)
                  }
                }
            } else if grid[i][j] == 0 {
              Rectangle()
                .fill(.white)
                .frame(width: 50, height: 50)
                .border(Color.black, width: 2)
                .overlay(content: {
                  Rectangle()
                    .fill(.black)
                    .frame(width: 12, height: 12)
                    .cornerRadius(6)
//                  Image("i-letter")
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 20, height: 20)
                })
                .onTapGesture {
                  if interactable{
                    viewModel.didTap(x: i, y: j)
                  }
                }
            } else if grid[i][j] == -2 {
              Rectangle()
                .fill(.gray)
                .frame(width: 50, height: 50)
                .border(Color.black, width: 2)
                .onTapGesture {
                  if interactable{
                    viewModel.didTap(x: i, y: j)
                  }
                }
            } else {
              ZStack {
                Rectangle()
                  .fill(.white)
                  .frame(width: 50, height: 50)
                  .border(Color.black, width: 2)
                Text("\(grid[i][j])")
                  .foregroundStyle(.black)
              }
            }
          }
        }
      }
    }
}

#Preview {
  let viewModel = NurikabeViewModel(7, 7)
  viewModel.buildPuzzle()
  return GridView(grid: viewModel.playerGrid, viewModel: viewModel, interactable: true)
}
