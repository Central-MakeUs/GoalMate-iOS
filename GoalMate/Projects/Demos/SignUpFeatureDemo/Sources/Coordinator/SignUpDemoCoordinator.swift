//
//  SignUpCoordinator.swift
//  DemoSignUpFeature
//
//  Created by 이재훈 on 3/4/25.
//

import ComposableArchitecture
import FeatureCommon
import FeatureSignUp
import Data
import SwiftUI
import TCACoordinators

public struct SignUpDemoCoordinatorView: View {
    let store: StoreOf<SignUpDemoCoordinator>

    public init(store: StoreOf<SignUpDemoCoordinator>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            Color.white
            TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
                switch screen.case {
                case let .signUp(store):
                    SignUpView(store: store)
                case let .termsAgreement(store):
                    TermsAgreementSheetView(store: store)
                        .customSheet(heights: [414], radius: 30, corners: [.topLeft, .topRight])
                }
            }
        }
        .toolbar(.hidden)
    }
}

@Reducer
public struct SignUpDemoCoordinator {
    public init() {}
    @Reducer(state: .equatable)
    public enum Screen {
        case signUp(SignUpFeature)
        case termsAgreement(TermsAgreementFeature)
    }
    @ObservableState
    public struct State: Equatable {
        public var id: UUID
        var routes: IdentifiedArrayOf<Route<Screen.State>>

        public init(
            routes: IdentifiedArrayOf<Route<Screen.State>> = [
                .root(.signUp(.init()), embedInNavigationView: true)
            ]
        ) {
            self.id = UUID()
            self.routes = routes
        }
    }

    public enum Action {
        case router(IdentifiedRouterActionOf<Screen>)
        case coordinatorFinished
    }

    public var body: some Reducer<State, Action> {
        self.core
            .dependency(\.authClient, .previewValue)
            .dependency(\.menteeClient, .previewValue)
            .dependency(\.goalClient, .previewValue)
    }

    @ReducerBuilder<State, Action>
    var core: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .router(.routeAction(
                _,
                action: .signUp(.delegate(.authenticationCompleted)))):
                state.routes.presentSheet(.termsAgreement(.init()))
                return .none
            case .router(.routeAction(
                _,
                action: .termsAgreement(.delegate(.termsAgreementFinished)))):
                state.routes.dismiss()
                guard case let .signUp(signUp) = state.routes.first?.screen else { return .none }
                return .send(.router(.routeAction(
                    id: signUp.id,
                    action: .signUp(.delegate(.termsAgreementCompleted)))))
            case .router(.routeAction(
                _,
                action: .signUp(.delegate(.loginFinished)))):
                return .send(.coordinatorFinished)
            default: break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}

extension SignUpDemoCoordinator.Screen.State: Identifiable {
    public var id: UUID {
    switch self {
    case let .signUp(state):
      state.id
    case let .termsAgreement(state):
      state.id
    }
  }
}
