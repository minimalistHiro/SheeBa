//
//  UIViewExtension.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/01/07.
//

import SwiftUI

extension UIView {
    func getImage(rect: CGRect) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
