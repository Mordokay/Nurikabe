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
    var stack = [Point]()

    init(_ row: Int, _ col: Int) {
        self.row = row
        self.col = col
    }

    func generateMap() {
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
                let children = getValidChildren(p, 0)
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

    func getValidChildren(_ p: Point, _ val: Int) -> [Point] {
        var children = [Point]()
        let i = p.r
        let j = p.c
        if i+1 < row && m_grid[i+1][j] == val {
            children.append(Point(i+1, j))
        }
        if i-1 >= 0 && m_grid[i-1][j] == val {
            children.append(Point(i-1, j))
        }
        if j+1 < col && m_grid[i][j+1] == val {
            children.append(Point(i, j+1))
        }
        if j-1 >= 0 && m_grid[i][j-1] == val {
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
//    printPuzzle()
  }

  func didTap(x: Int, y: Int) {
    if playerGrid[x][y] == -2 {
      playerGrid[x][y] = -1
    } else if playerGrid[x][y] == -1 {
      playerGrid[x][y] = 0
    } else if playerGrid[x][y] == 0 {
      playerGrid[x][y] = -2
    }
    printPlayerGrid()
  }
}
