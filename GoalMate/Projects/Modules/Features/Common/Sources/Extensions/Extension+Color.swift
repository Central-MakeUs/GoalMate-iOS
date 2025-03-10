//
//  Extension+Color.swift
//  Common
//
//  Created by 이재훈 on 1/7/25.
//

import SwiftUI
import UIKit

public extension Colors {
    static let primary = Asset.Assets.Primary.primary.swiftUIColor
    static let primary50 = Asset.Assets.Primary.primary50.swiftUIColor
    static let primary100 = Asset.Assets.Primary.primary100.swiftUIColor
    static let primary200 = Asset.Assets.Primary.primary200.swiftUIColor
    static let primary600 = Asset.Assets.Primary.primary600.swiftUIColor
    static let primary700 = Asset.Assets.Primary.primary700.swiftUIColor
    static let primary800 = Asset.Assets.Primary.primary800.swiftUIColor
    static let primary900 = Asset.Assets.Primary.primary900.swiftUIColor

    static let secondaryP = Asset.Assets.SecondaryP.secondaryP.swiftUIColor
    static let secondaryP50 = Asset.Assets.SecondaryP.secondaryP50.swiftUIColor
    static let secondaryP400 = Asset.Assets.SecondaryP.secondaryP400.swiftUIColor

    static let secondaryY = Asset.Assets.SecondaryY.secondaryY.swiftUIColor
    static let secondaryY50 = Asset.Assets.SecondaryY.secondaryY50.swiftUIColor
    static let secondaryY700 = Asset.Assets.SecondaryY.secondaryY700.swiftUIColor
    static let secondaryY800 = Asset.Assets.SecondaryY.secondaryY800.swiftUIColor

    static let grey50 = Asset.Assets.Grey.grey50.swiftUIColor
    static let grey100 = Asset.Assets.Grey.grey100.swiftUIColor
    static let grey200 = Asset.Assets.Grey.grey200.swiftUIColor
    static let grey300 = Asset.Assets.Grey.grey300.swiftUIColor
    static let grey400 = Asset.Assets.Grey.grey400.swiftUIColor
    static let grey500 = Asset.Assets.Grey.grey500.swiftUIColor
    static let grey600 = Asset.Assets.Grey.grey600.swiftUIColor
    static let grey700 = Asset.Assets.Grey.grey700.swiftUIColor
    static let grey800 = Asset.Assets.Grey.grey800.swiftUIColor
    static let grey900 = Asset.Assets.Grey.grey900.swiftUIColor

    static let warn = Asset.Assets.System.warn.swiftUIColor
    static let error = Asset.Assets.System.error.swiftUIColor
    static let success = Asset.Assets.System.success.swiftUIColor
    static let focused = Asset.Assets.System.focused.swiftUIColor

    static let kakaoBg = Asset.Assets.kakaoBg.swiftUIColor
    static let kakaoText = Asset.Assets.kakaoText.swiftUIColor
}

public extension Color {
    init(appAsset: Colors) {
        self.init(asset: appAsset)
    }
    /**
     HEX 코드를 사용하여 SwiftUI의 `Color` 객체를 생성하는 초기화 메서드입니다.
     
     - Parameters:
     - hex: 색상을 나타내는 16진수 문자열 (예: `"#FFFFFF"`, `"FFFFFF"`)
     - opacity: 색상의 투명도를 지정하는 값. 기본값은 `1.0`이며, `0.0`에서 `1.0` 사이의 값을 사용합니다.
     
     - Important:
     - `hex` 문자열은 6자리 16진수 형식이어야 하며, 선택적으로 `#` 접두사를 포함할 수 있습니다.
     - `hex` 문자열이 유효하지 않을 경우 프로그램이 종료됩니다. (Assertion 및 Fatal Error)
     
     - Usage:
     ```swift
     let whiteColor = Color(hex: "#FFFFFF") // 불투명한 흰색
     let semiTransparentBlack = Color(hex: "000000", opacity: 0.5) // 반투명한 검정색
     ```
     
     - Precondition:
     - `hex`는 공백 없이 6자리여야 합니다. (`"#RRGGBB"` 또는 `"RRGGBB"`)
     - `opacity`는 `0.0` 이상 `1.0` 이하의 값이어야 합니다.
     
     - Note:
     - 유효하지 않은 HEX 코드가 제공되면 에러 메시지를 출력하며 실행이 중단됩니다.
     
     - Throws:
     - `fatalError`: HEX 코드가 유효하지 않거나 변환이 실패할 경우 발생합니다.
     */
    init(hex: String, opacity: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines
        ).uppercased()

        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }

        assert(hexFormatted.count == 6, "Invalid hex code used.")

        var rgbValue: UInt64 = 0
        guard Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        else { fatalError("InvaildColor > hex: \(hex), opacity: \(opacity)") }
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            opacity: min(1, max(opacity, 0))
        )
    }
}

extension UIColor {
    // Hex 문자열로부터 UIColor를 생성하는 이니셜라이저
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        var alpha: CGFloat = alpha
        // 유효한 hex 코드인지 확인
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb)
        else {
            self.init(white: 0, alpha: alpha)
            return
        }
        // 알파 채널이 포함된 8자리 hex 코드 (RRGGBBAA)인 경우
        if hexSanitized.count == 8 {
            alpha = CGFloat((rgb & 0xFF)) / 255.0
            rgb = rgb >> 8
        }
        // 6자리 hex 코드 (RRGGBB)인 경우
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    // 특정 Hex 문자열로부터 UIColor를 생성하는 정적 메서드
    static func fromHex(_ hex: String, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(hex: hex, alpha: alpha)
    }
}
