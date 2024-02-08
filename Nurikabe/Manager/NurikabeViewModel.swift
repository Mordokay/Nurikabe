//
//  NurikabeViewModel.swift
//  Nurikabe
//
//  Created by Pedro Saldanha on 08/02/2024.
//

import Foundation

// Point struct representing coordinates
struct Point: Equatable {
  var r: Int
  var c: Int

  init() {
    self.r = 0
    self.c = 0
  }

  init(_ row: Int, _ col: Int) {
    self.r = row
    self.c = col
  }
}

class NurikabeViewModel: ObservableObject {
  var row: Int
  var col: Int
  @Published var m_grid = [[Int]]()
  @Published var playerGrid = [[Int]]()
  @Published var number_tries: Int = 0
  @Published var isFilled: Bool = false
  @Published var solvedResult: (Bool, String) = (false, "")

  var stack = [Point]()

  init(_ row: Int, _ col: Int) {
    self.row = row
    self.col = col
    m_grid = Array(repeating: Array(repeating: 0, count: col), count: row)
    playerGrid = Array(repeating: Array(repeating: -2, count: col), count: row)
  }

  func generateMap() {
    isFilled = false
    m_grid = Array(repeating: Array(repeating: 0, count: col), count: row)
    playerGrid = Array(repeating: Array(repeating: -2, count: col), count: row)

    self.stack = [Point]()

    var curr = Point(Int.random(in: 0..<row), Int.random(in: 0..<col))
    m_grid[curr.r][curr.c] = -1
    stack.append(curr)

    while !stack.isEmpty {
      curr = stack.removeLast()
      let child = getRandomChild(curr.r, curr.c)
      //            if child.r == -1 || Double.random(in: 0..<1) < 0.05 {
      if child.r == -1 || Double.random(in: 0..<1) < 0.03 {
        continue
      }
      m_grid[child.r][child.c] = -1
      stack.append(child)
    }
  }

  func partOfSquare(_ i: Int, _ j: Int) -> Bool {
    if i+1 < row && j+1 < col {
      if m_grid[i+1][j] == -1 && m_grid[i+1][j+1] == -1 && m_grid[i][j+1] == -1 {
        return true
      }
    }
    if i+1 < row && j-1 >= 0 {
      if m_grid[i+1][j] == -1 && m_grid[i+1][j-1] == -1 && m_grid[i][j-1] == -1 {
        return true
      }
    }
    if i-1 >= 0 && j+1 < col {
      if m_grid[i-1][j] == -1 && m_grid[i-1][j+1] == -1 && m_grid[i][j+1] == -1 {
        return true
      }
    }
    if i-1 >= 0 && j-1 >= 0 {
      if m_grid[i-1][j] == -1 && m_grid[i-1][j-1] == -1 && m_grid[i][j-1] == -1 {
        return true
      }
    }
    return false
  }

  func getRandomChild(_ i: Int, _ j: Int) -> Point {
    var children = [Point]()
    if i+1 < row && !partOfSquare(i+1, j) && m_grid[i+1][j] == 0 {
      children.append(Point(i+1, j))
    }
    if i-1 >= 0 && !partOfSquare(i-1, j) && m_grid[i-1][j] == 0 {
      children.append(Point(i-1, j))
    }
    if j+1 < col && !partOfSquare(i, j+1) && m_grid[i][j+1] == 0 {
      children.append(Point(i, j+1))
    }
    if j-1 >= 0 && !partOfSquare(i, j-1) && m_grid[i][j-1] == 0 {
      children.append(Point(i, j-1))
    }
    if children.isEmpty {
      return Point(-1, -1)
    }
    let r = Int.random(in: 0..<children.count)
    return children[r]
  }

  func fillInNumbers() {
    var whites = [Point]()
    for i in 0..<row {
      for j in 0..<col {
        if m_grid[i][j] == 0 {
          whites.append(Point(i, j))
        }
      }
    }

    while !whites.isEmpty {
      var q = [Point]()
      q.append(whites.removeLast())
      var visited = [q[0]]
      while !q.isEmpty {
        let p = q.removeFirst()
        let children = getValidChildren(m_grid, p, 0)
        for child in children {
          if !visited.contains(child) {
            q.append(child)
            visited.append(child)
          }
        }
      }
      let randIndex = Int.random(in: 0..<visited.count)
      m_grid[visited[randIndex].r][visited[randIndex].c] = visited.count
      whites = whites.filter { !visited.contains($0) }
    }
  }

  func generatePlayerMap() {
    for i in (0..<m_grid.count) {
      for j in (0..<m_grid[i].count) where m_grid[i][j] > 0 {
        playerGrid[i][j] = m_grid[i][j]
      }
    }
  }

  func removeValue(_ val: Int) {
    for i in 0..<row {
      for j in 0..<col {
        if m_grid[i][j] == val {
          m_grid[i][j] = 0
        }
      }
    }
  }

  func getValidChildren(_ grid: [[Int]], _ p: Point, _ val: Int) -> [Point] {
      var children = [Point]()
      let i = p.r
      let j = p.c
      if i+1 < grid.count && grid[i+1][j] == val {
          children.append(Point(i+1, j))
      }
      if i-1 >= 0 && grid[i-1][j] == val {
          children.append(Point(i-1, j))
      }
      if j+1 < grid[0].count && grid[i][j+1] == val {
          children.append(Point(i, j+1))
      }
      if j-1 >= 0 && grid[i][j-1] == val {
          children.append(Point(i, j-1))
      }
      return children
  }

  func printPuzzle() {
    for line in m_grid {
      print(line)
    }
    print("")
  }

  func printPlayerGrid() {
    for line in playerGrid {
      print(line)
    }
    print("")
  }

  func hasBigIsland() -> Bool {
    return m_grid.contains { $0.contains { $0 > 7 } }
  }

  func checkFiled() {
    isFilled = !playerGrid.contains { $0.contains { $0 == -2 } }
    if isFilled {
      checkPuzzle()
    } else {
      solvedResult = (false, "")
    }
  }

  func buildPuzzle() {
    generateMap()
    fillInNumbers()
    generatePlayerMap()
    number_tries = 1
    while hasBigIsland() {
      generateMap()
      fillInNumbers()
      generatePlayerMap()
      number_tries += 1
    }
  }

  func didTap(x: Int, y: Int) {
    if playerGrid[x][y] == -2 {
      playerGrid[x][y] = -1
    } else if playerGrid[x][y] == -1 {
      playerGrid[x][y] = 0
    } else if playerGrid[x][y] == 0 {
      playerGrid[x][y] = -2
    }
    checkFiled()
  }

  func checkPuzzle() {
    // create temporary grid for checking
    var temp_grid = [[Int]]()

    // populate search spaces
    var white_search = [Point]()
    var black_search = [Point]()
    for i in 0..<row {
      temp_grid.append([Int]())
      for j in 0..<col {
        if playerGrid[i][j] <= -3 {
          temp_grid[i].append(0)
        } else {
          temp_grid[i].append(playerGrid[i][j])
        }
        if playerGrid[i][j] > 0 {
          white_search.append(Point(i, j))
        }
        if playerGrid[i][j] == -1 {
          black_search.append(Point(i, j))
        }
      }
    }

    // BFS call for checking if whites are satisfied
    while !white_search.isEmpty {
      var q = [Point]()
      q.append(white_search.removeLast())
      let val = playerGrid[q.first!.r][q.first!.c]

      var visited = [q.first!]

      BFS(&temp_grid, &q, &visited, 0)

      if val != visited.count {
        solvedResult = (false, "Island sizes are not satisfied!")
        print("ERROR: Island sizes are not satisfied!")
        return
      }

      for point in visited {
        if temp_grid[point.r][point.c] != 0 { continue }
        temp_grid[point.r][point.c] = -2
      }
    }

    // checks to make sure there are un-filled chunks
    for i in 0..<row {
      for j in 0..<col {
        if temp_grid[i][j] == 0 {
          solvedResult = (false, "Some parts of the map are unfilled!")
          print("ERROR: Some parts of the map are unfilled")
          return
        }
      }
    }

    // check if all blacks are connected
    var visited = [Point]()
    var q = [Point]()
    q.append(black_search[0])
    visited.append(q.first!)
    BFS(&temp_grid, &q, &visited, -1)
    if visited.count != black_search.count {
      solvedResult = (false, "Some walls aren't connected!")
      print("ERROR: Walls aren't connected")
      return
    }

    // check for 2x2 blacks
    for i in 0..<(row - 1) {
      for j in 0..<(col - 1) {
        if temp_grid[i][j] == -1 && temp_grid[i+1][j] == -1 &&
            temp_grid[i+1][j+1] == -1 && temp_grid[i][j+1] == -1 {
          solvedResult = (false, "Can't have 2x2 walls!")
          print("ERROR: Can't have 2x2 walls")
          return
        }
      }
    }
    solvedResult = (true, "Congratulations! You've solved the puzzle!")
    print("Congratulations! You've solved the puzzle.")
  }

  func BFS(_ grid: inout [[Int]], _ q: inout [Point], _ visited: inout [Point], _ val: Int) {
    while !q.isEmpty {
      let p = q.removeFirst()

      // gets valid children
      let children = getValidChildren(grid, p, val)

      // adds every valid child to q if it isn't in visited
      for child in children {
        if !visited.contains(child) {
          q.append(child)
          // push child back to visited if it wasn't in there
          visited.append(child)
        }
      }
    }
  }
}
