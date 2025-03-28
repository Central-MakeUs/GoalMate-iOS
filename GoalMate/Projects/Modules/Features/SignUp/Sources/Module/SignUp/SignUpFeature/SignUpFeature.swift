//
//  SignUpFeature.swift
//  SignUp
//
//  Created by Importants on 1/6/25.
//

import ComposableArchitecture
import Data
import Dependencies
import FeatureCommon
import UIKit
import Utils

@Reducer
public struct SignUpFeature {
    public init() {}
    @ObservableState
    public struct State: Equatable {
        public var id: UUID
        // 페이지 상태
        var pageType: SignUpProcessType
        var isLoading: Bool
        var toastState: ToastState
        // 닉네임 입력 관련 상태
        var nicknameFormState: NicknameFormState
        // 키보드 상태
        var keyboardHeight: Double
        // textFieldInput
        var nickname: String // 닉네임
        public struct NicknameFormState: Equatable {
            var inputText: String
            var defaultNickname: String
            var validationState: TextFieldState
            var isSubmitEnabled: Bool
            var isDuplicateCheckEnabled: Bool
            public init(
                validationState: TextFieldState = .idle,
                isSubmitEnabled: Bool = false,
                isDuplicateCheckEnabled: Bool = false
            ) {
                self.inputText = ""
                self.defaultNickname = ""
                self.validationState = validationState
                self.isSubmitEnabled = isSubmitEnabled
                self.isDuplicateCheckEnabled = isDuplicateCheckEnabled
            }
        }
        public init(
            id: UUID = UUID(),
            pageType: SignUpProcessType = .signUp,
            isLoading: Bool = false,
            nicknameInput: NicknameFormState = .init(),
            keyboardHeight: Double = 0
        ) {
            self.id = id
            self.pageType = pageType
            self.isLoading = isLoading
            self.toastState = .hide
            self.nicknameFormState = nicknameInput
            self.keyboardHeight = keyboardHeight
            self.nickname = ""
        }
    }
    public enum Action: BindableAction {
        case viewCycling(ViewCyclingAction)
        case auth(AuthAction)
        case nickname(NicknameAction)
        case signUpSuccess(SignUpSuccessAction)
        case feature(FeatureAction)
        case delegate(DelegateAction)
        case binding(BindingAction<State>)
        case nicknameTextInputted(String)
    }
    public enum ViewCyclingAction {
        case onAppear
    }
    public enum AuthAction {
        case signUpButtonTapped(SignUpProvider)
        case backButtonTapped
    }
    public enum NicknameAction {
        case duplicateCheckButtonTapped
        case submitButtonTapped
    }
    public enum SignUpSuccessAction {
        case finishButtonTapped
    }
    public enum FeatureAction {
        case getNickname
        case checkGetNicknameResponse(GetNicknameResult)
        case checkAuthenticationResponse(AuthenticationResult)
        case checkDuplicateResponse(NicknameCheckResult)
        case nicknameSubmitted(NicknameSubmitResult)
        case updateKeyboardHeight(CGFloat)
    }
    public enum DelegateAction {
        case authenticationCompleted
        case termsAgreementCompleted
        case loginFinished
    }
    @Dependency(\.authClient) var authClient
    @Dependency(\.environmentClient) var environmentClient
    @Dependency(\.menteeClient) var menteeClient
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .viewCycling(action):
                return reduce(into: &state, action: action)
            case let .auth(action):
                return reduce(into: &state, action: action)
            case let .nickname(action):
                return reduce(into: &state, action: action)
            case let .signUpSuccess(action):
                return reduce(into: &state, action: action)
            case let .feature(action):
                return reduce(into: &state, action: action)
            case let .delegate(action):
                return reduce(into: &state, action: action)
            case .binding:
                return .none
            case let .nicknameTextInputted(input):
                guard state.isLoading == false &&
                      state.nicknameFormState.inputText != input
                else { return .none }
                state.nicknameFormState.inputText = input
                // 인풋이 존재하면서 랜덤 닉네임과 인풋이 같을 경우 || 인풋이 없으면서 랜덤 닉네임이 있는 경우
                if (input.isEmpty == false && state.nicknameFormState.defaultNickname == input) ||
                   (input.isEmpty && state.nicknameFormState.defaultNickname.isEmpty == false) {
                    state.nicknameFormState.isDuplicateCheckEnabled = false
                    state.nicknameFormState.validationState = input.isEmpty ? .idle : .editing
                    state.nicknameFormState.isSubmitEnabled = true
                } else if 2...5 ~= input.count {
                    // 값이 입력된 경우
                    state.nicknameFormState.isDuplicateCheckEnabled = true
                    state.nicknameFormState.validationState = .editing
                    state.nicknameFormState.isSubmitEnabled = false
                } else {
                    // 그 외의 경우
                    let isEmptyDefaultNickname = state.nicknameFormState.defaultNickname.isEmpty
                    let isEmptyInput = input.isEmpty
                    state.nicknameFormState.isDuplicateCheckEnabled = false
                    state.nicknameFormState.validationState =
                        isEmptyInput && isEmptyDefaultNickname ? .idle : .invalid
                    state.nicknameFormState.isSubmitEnabled = false
                }
                return .none
            }
        }
    }
}
