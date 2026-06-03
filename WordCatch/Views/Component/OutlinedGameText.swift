import SwiftUI

struct OutlinedGameText: UIViewRepresentable {
    let text: String

    var fontSize: CGFloat = 80
    var textColor: UIColor = .white
    var strokeColor: UIColor = UIColor(red: 1.0, green: 0.39, blue: 0.07, alpha: 1.0)
    var strokeWidth: CGFloat = 7

    func makeUIView(context: Context) -> OutlinedLabel {
        let label = OutlinedLabel()
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }

    func updateUIView(_ label: OutlinedLabel, context: Context) {
        label.text = text
        label.font = roundedFont(size: fontSize)
        label.fillColor = textColor
        label.outlineColor = strokeColor
        label.outlineWidth = strokeWidth
    }

    private func roundedFont(size: CGFloat) -> UIFont {
        let baseFont = UIFont.systemFont(ofSize: size, weight: .black)
        guard let descriptor = baseFont.fontDescriptor.withDesign(.rounded) else {
            return baseFont
        }
        return UIFont(descriptor: descriptor, size: size)
    }
}

final class OutlinedLabel: UILabel {
    var fillColor: UIColor = .white {
        didSet { setNeedsDisplay() }
    }

    var outlineColor: UIColor = UIColor(red: 1.0, green: 0.39, blue: 0.07, alpha: 1.0) {
        didSet { setNeedsDisplay() }
    }

    var outlineWidth: CGFloat = 7 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }

    private var drawingInsets: UIEdgeInsets {
        let inset = ceil(outlineWidth) + 2
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        let insets = drawingInsets
        return CGSize(
            width: size.width + insets.left + insets.right,
            height: size.height + insets.top + insets.bottom
        )
    }

    override func drawText(in rect: CGRect) {
        guard let text, !text.isEmpty else { return }

        let insetRect = rect.inset(by: drawingInsets)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        paragraphStyle.lineBreakMode = lineBreakMode

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font as Any,
            .paragraphStyle: paragraphStyle
        ]

        let textRect = text.boundingRect(
            with: insetRect.size,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )

        let y = insetRect.midY - ceil(textRect.height) / 2
        let drawRect = CGRect(x: insetRect.minX, y: y, width: insetRect.width, height: ceil(textRect.height))

        draw(text, in: drawRect, strokeWidth: outlineWidth, foregroundColor: outlineColor)
        draw(text, in: drawRect, strokeWidth: 0, foregroundColor: fillColor)
    }

    private func draw(_ text: String, in rect: CGRect, strokeWidth: CGFloat, foregroundColor: UIColor) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        paragraphStyle.lineBreakMode = lineBreakMode

        var attributes: [NSAttributedString.Key: Any] = [
            .font: font as Any,
            .foregroundColor: foregroundColor,
            .paragraphStyle: paragraphStyle
        ]

        if strokeWidth > 0 {
            attributes[.strokeColor] = foregroundColor
            attributes[.strokeWidth] = strokeWidth
        }

        NSAttributedString(string: text, attributes: attributes).draw(in: rect)
    }
}

#Preview {
    ZStack {
        Color.black
        OutlinedGameText(text: "Ready?", fontSize: 86)
    }
}
