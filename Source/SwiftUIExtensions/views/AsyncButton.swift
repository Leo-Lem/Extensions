//	Created by Leopold Lemmermann on 07.12.22.

import SwiftUI

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
public struct AsyncButton<Label: View, Indicator: View>: View {
  public enum IndicatorStyle: Equatable {
    case replace, edge(Edge), none
  }

  let role: ButtonRole?
  let indicatorStyle: IndicatorStyle
  let taskPriority: TaskPriority?
  let action: () async -> Void
  let label: () -> Label
  let indicator: () -> Indicator

  public var body: some View {
    Button(role: role) { Task(priority: taskPriority, operation: asyncAction) } label: {
      if case let .edge(edge) = indicatorStyle {
        VStack {
          if isExecuting, edge == .top {
            indicator()
            Spacer()
          }
          
          HStack {
            if isExecuting, edge == .leading {
              indicator()
              Spacer()
            }
            
            label()
            
            if isExecuting, edge == .trailing {
              Spacer()
              indicator()
            }
          }
          
          if isExecuting, edge == .bottom {
            Spacer()
            indicator()
          }
        }
      } else {
        label()
      }
    }
    .if(isExecuting && indicatorStyle == .replace) { $0
      .hidden()
      .overlay(content: indicator)
    }
  }

  @State private var isExecuting = false

  public init(
    role: ButtonRole? = nil,
    indicatorStyle: IndicatorStyle = .none,
    taskPriority: TaskPriority? = nil,
    action: @escaping () async -> Void,
    @ViewBuilder label: @escaping () -> Label,
    @ViewBuilder indicator: @escaping () -> Indicator = ProgressView.init
  ) {
    self.role = role
    self.indicatorStyle = indicatorStyle
    self.taskPriority = taskPriority
    self.action = action
    self.label = label
    self.indicator = indicator
  }

  @Sendable func asyncAction() async {
    isExecuting = true
    await action()
    isExecuting = false
  }
}

public extension AsyncButton where Label == SwiftUI.Label<Text, Image> {
  init(
    _ titleKey: LocalizedStringKey,
    systemImage: String,
    role: ButtonRole? = nil,
    indicatorStyle: IndicatorStyle = .none,
    taskPriority: TaskPriority? = nil,
    action: @escaping () async -> Void,
    @ViewBuilder indicator: @escaping () -> Indicator = ProgressView.init
  ) {
    self.init(
      role: role,
      indicatorStyle: indicatorStyle,
      taskPriority: taskPriority,
      action: action,
      label: { SwiftUI.Label(titleKey, systemImage: systemImage) },
      indicator: indicator
    )
  }

  @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
  init(
    _ titleResource: LocalizedStringResource,
    systemImage: String,
    role: ButtonRole? = nil,
    indicatorStyle: IndicatorStyle = .none,
    taskPriority: TaskPriority? = nil,
    action: @escaping () async -> Void,
    @ViewBuilder indicator: @escaping () -> Indicator = ProgressView.init
  ) {
    self.init(
      role: role,
      indicatorStyle: indicatorStyle,
      taskPriority: taskPriority,
      action: action,
      label: { SwiftUI.Label(titleResource, systemImage: systemImage) },
      indicator: indicator
    )
  }

  init<S>(
    _ title: S,
    systemImage: String,
    role: ButtonRole? = nil,
    indicatorStyle: IndicatorStyle = .none,
    taskPriority: TaskPriority? = nil,
    action: @escaping () async -> Void,
    @ViewBuilder indicator: @escaping () -> Indicator = ProgressView.init
  ) where S: StringProtocol {
    self.init(
      role: role,
      indicatorStyle: indicatorStyle,
      taskPriority: taskPriority,
      action: action,
      label: { SwiftUI.Label(String(title), systemImage: systemImage) },
      indicator: indicator
    )
  }
}
