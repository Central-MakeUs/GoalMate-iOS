//
//  TabCoordinator+Action.swift
//  FeatureHome
//
//  Created by Importants on 2/14/25.
//

import ComposableArchitecture
import Data
import FeatureComment
import FeatureGoal
import FeatureMyGoal
import FeatureProfile

extension TabCoordinator {
    func reduce(into state: inout State, action: ViewCyclingAction) -> Effect<Action> {
        switch action {
        case .onAppear:
            return .send(.feature(.checkAllCounts))
        }
    }
    func reduce(into state: inout State, action: CoordinatorAction) -> Effect<Action> {
        switch action {
        case .showLogin:
            return .none
        }
    }
    func reduce(into state: inout State, action: FeatureAction) -> Effect<Action> {
        switch action {
        case .checkAllCounts:
            return .merge(
                .send(.feature(.getRemainingTodoCount)),
                .send(.feature(.getNewCommentsCount))
            )
        case .getRemainingTodoCount:
            return .run { send in
                do {
                    let hasRemainingTodos = try await menteeClient.hasRemainingTodos()
                    await send(.feature(
                        .checkRemainingTodoResponse(hasRemainingTodos)))
                } catch {
                    await send(.feature(
                        .checkRemainingTodoResponse(false)))
                }
            }
        case let .checkRemainingTodoResponse(result):
            state.hasRemainingTodos = result
            return .none
        case .getNewCommentsCount:
            return .run { send in
                do {
                    let count = try await menteeClient.getNewCommentsCount()
                    await send(.feature(
                        .chekcNewCommentsCountResponse(count)))
                } catch {
                    await send(.feature(
                        .chekcNewCommentsCountResponse(0)))
                }
            }
        case let .chekcNewCommentsCountResponse(count):
            state.newCommentsCount = count
            return .none
        }
    }
    func reduce(into state: inout State, action: GoalCoordinator.Action) -> Effect<Action> {
        switch action {
        case .delegate(.showMyGoal):
            state.selectedTab = .myGoal
            state.isTabVisible = true
            return .none
        case .delegate(.showLogin):
            return .send(.coordinator(.showLogin))
        case let .delegate(.setTabbarVisibility(isShow)):
            state.isTabVisible = isShow
            return .none
        default:
            return .none
        }
    }
    func reduce(into state: inout State, action: MyGoalCoordinator.Action) -> Effect<Action> {
        switch action {
        case .delegate(.showGoalList):
            state.isTabVisible = true
            state.selectedTab = .goal
            return .none
        case let .delegate(.showGoalDetail(contentId)):
            state.isTabVisible = true
            state.selectedTab = .goal
            return .send(.goal(.delegate(.showGoalDetail(contentId))))
        case let .delegate(.setTabbarVisibility(isShow)):
            state.isTabVisible = isShow
            return .none
        default: return .none
        }
    }
    func reduce(into state: inout State, action: CommentCoordinator.Action) -> Effect<Action> {
        switch action {
        case let .delegate(.setTabbarVisibility(isShow)):
            state.isTabVisible = isShow
            return .none
        case .delegate(.showGoalList):
            state.isTabVisible = true
            state.selectedTab = .goal
            return .none
        default: return .none
        }
    }
    func reduce(into state: inout State, action: ProfileCoordinator.Action) -> Effect<Action> {
        switch action {
        case .delegate(.showLogin):
            return .send(.coordinator(.showLogin))
        case .delegate(.showMyGoalList):
            state.selectedTab = .myGoal
            return .none
        case .delegate(.showGoalList):
            state.selectedTab = .goal
            return .none
        case let .delegate(.setTabbarVisibility(isShow)):
            state.isTabVisible = isShow
            return .none
        default: return .none
        }
    }
}
