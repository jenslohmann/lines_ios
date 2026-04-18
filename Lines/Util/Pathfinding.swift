/// BFS pathfinding on the 9×9 grid.
/// Finds a shortest path from `from` to `to`, moving only horizontally/vertically,
/// avoiding positions in `occupied`.
/// - Returns: An array of positions from `from` to `to` (inclusive), or `nil` if no path exists.
func findPath(from: Position, to: Position, occupied: Set<Position>) -> [Position]? {
    if from == to { return [from] }
    if occupied.contains(to) { return nil }

    var visited: Set<Position> = [from]
    var queue: [(position: Position, path: [Position])] = [(from, [from])]
    var head = 0

    while head < queue.count {
        let (current, path) = queue[head]
        head += 1

        for neighbor in current.neighbors {
            if neighbor == to {
                return path + [neighbor]
            }
            if !occupied.contains(neighbor) && !visited.contains(neighbor) {
                visited.insert(neighbor)
                queue.append((neighbor, path + [neighbor]))
            }
        }
    }

    return nil
}

