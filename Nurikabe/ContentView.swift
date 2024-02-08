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
  var backgroundColor = Color(#colorLiteral(red: 0.5943129888, green: 0.8499712226, blue: 0.946557971, alpha: 1))
  @State var showingSolution: Bool = false

  init() {
    viewModel.buildPuzzle()
  }

  var body: some View {
    backgroundColor
      .overlay(content: {
        VStack(spacing: 0) {
          Text("NUMBER OF TRIES: \(viewModel.number_tries)")
            .font(.title3)
            .foregroundStyle(.black)

          Spacer()
            .frame(height: 10)

          GridView(grid: viewModel.playerGrid, viewModel: viewModel, interactable: true)
            .border(Color.black, width: 4)

          Spacer()
            .frame(height: 10)

          if showingSolution {
            GridView(grid: viewModel.m_grid, viewModel: viewModel, interactable: false)
              .border(Color.black, width: 4)
          } else {
            Button {
              showingSolution = true
            } label: {
              Text("Show Solution")
                .font(.title)
                .bold()
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
          }

          Spacer()
            .frame(height: 10)

          Text("\(viewModel.solvedResult.1)")
            .font(.title3)
            .bold()
            .foregroundStyle(viewModel.solvedResult.0 ? .green : .red)

          Spacer()
            .frame(height: 10)

          Button {
            showingSolution = false
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
