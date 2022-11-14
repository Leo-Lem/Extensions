//	Created by Leopold Lemmermann on 14.11.22.

public extension Array {
  /// Asynchronously maps the array, while dropping nil results, and returns the result.
  /// - Parameter transform: The transformation to apply to the array's elements.
  /// - Returns: An array of the transformed values.
  @_disfavoredOverload
  func compactMap<T>(_ transform: (Element) async throws -> T?) async rethrows -> [T] {
    var values = [T]()
    for element in self {
      if let newElement = try await transform(element) { values.append(newElement) }
    }
    return values
  }
  
  /// Asynchronously maps the array, while dropping nil results, and streams the result (available when transform is non-throwing).
  /// - Parameter transform: The transformation to apply to the array's elements.
  /// - Returns: An AsyncStream of the transformed values.
  @_disfavoredOverload
  func compactMap<T>(_ transform: @escaping (Element) async -> T?) -> AsyncStream<T> {
    AsyncStream { continuation in
      for element in self {
        if let newElement = await transform(element) { continuation.yield(newElement) }
      }

      continuation.finish()
    }
  }

  /// Asynchronously maps the array, while dropping nil results, and streams the result (available when transform is throwing).
  /// - Parameter transform: The transformation to apply to the array's elements.
  /// - Returns: An AsyncThrowingStream of the transformed values and errors.
  @_disfavoredOverload
  func compactMap<T>(_ transform: @escaping (Element) async throws -> T?) -> AsyncThrowingStream<T, Error> {
    AsyncThrowingStream { continuation in
      do {
        for element in self {
          if let newElement = try await transform(element) { continuation.yield(newElement) }
        }

        continuation.finish()
      } catch {
        continuation.finish(throwing: error)
      }
    }
  }
}
