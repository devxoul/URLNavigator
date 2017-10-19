enum URLPathComponent {
  case plain(String)
  case placeholder(type: String?, key: String)
}

extension URLPathComponent {
  init(_ value: String) {
    if value.hasPrefix("<") && value.hasSuffix(">") {
      let start = value.index(after: value.startIndex)
      let end = value.index(before: value.endIndex)
      let placeholder = value[start..<end] // e.g. "<int:id>" -> "int:id"
      let typeAndKey = placeholder.components(separatedBy: ":")
      if typeAndKey.count == 1 { // any-type placeholder
        self = .placeholder(type: nil, key: typeAndKey[0])
      } else if typeAndKey.count == 2 {
        self = .placeholder(type: typeAndKey[0], key: typeAndKey[1])
      } else {
        self = .plain(value)
      }
    } else {
      self = .plain(value)
    }
  }
}

extension URLPathComponent: Equatable {
  static func == (lhs: URLPathComponent, rhs: URLPathComponent) -> Bool {
    switch (lhs, rhs) {
    case let (.plain(leftValue), .plain(rightValue)):
      return leftValue == rightValue

    case let (.placeholder(leftType, leftKey), .placeholder(rightType, key: rightKey)):
      return (leftType == rightType) && (leftKey == rightKey)

    default:
      return false
    }
  }
}
