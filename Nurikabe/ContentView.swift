//
//  ContentView.swift
//  Nurikabe
//
//  Created by Pedro Saldanha on 08/02/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var items: [Item]
  @ObservedObject var viewModel = NurikabeViewModel(7, 7)
  var backgroundColor = Color(#colorLiteral(red: 0.1530615734, green: 0.587199738, blue: 0.8573596014, alpha: 1))
  
  var body: some View {
    backgroundColor
      .overlay(content: {
        VStack(spacing: 0) {
          Text("NUMBER OF TRIES: \(viewModel.number_tries)")
            .font(.title)
            .foregroundStyle(.black)

          Spacer()
            .frame(height: 10)

          GridView(grid: viewModel.playerGrid, viewModel: viewModel, interactable: true)

          Spacer()
            .frame(height: 10)

          GridView(grid: viewModel.m_grid, viewModel: viewModel, interactable: false)

          Spacer()
            .frame(height: 10)

          Button {
            viewModel.buildPuzzle()
          } label: {
            Text("Generate")
              .font(.title)
              .bold()
          }
          .buttonStyle(.borderedProminent)
          .tint(.black)
        }
      })
      .ignoresSafeArea(.all)
  }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
