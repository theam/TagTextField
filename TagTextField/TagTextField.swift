//
//  TagTextField.swift
//  Jus Law
//
//  Created by Li Jin on 7/30/21.
//

import SwiftUI
import UIKit

public struct TagTheme {
    public var font: Font
    public var foregroundColor: Color
    public var backgroundColor: Color
    public var borderColor: Color
    public var shadowColor: Color
    public var shadowRadius: CGFloat
    public var cornerRadius: CGFloat
    
    public var deletable: Bool
    public var deleteButtonSize: CGFloat
    public var deleteButtonColor: Color
    public var deleteButtonSystemImageName: String
    
    public var spacing: CGFloat
    public var alignment: HorizontalAlignment
    
    public var inputFieldFont: Font
    public var inputFieldTextColor: Color
    
    public var contentInsets: EdgeInsets

    
    public init(font: Font = Font.system(size: 14),
                foregroundColor: Color = Color(.sRGB, red: 45.0/255.0, green: 45.0/255.0, blue: 45.0/255.0, opacity: 1),
                backgroundColor: Color = Color.white, borderColor: Color = Color(.sRGB, red: 224.0/255.0, green: 224.0/255.0, blue: 225.0/255.0, opacity: 1),
                shadowColor: Color = Color(.sRGB, red: 151.0/255.0, green: 151.0/255.0, blue: 154.0/255.0, opacity: 1).opacity(0.4),
                shadowRadius: CGFloat = 5,
                cornerRadius: CGFloat = 13,
                deletable: Bool = true,
                deleteButtonSize: CGFloat = 12,
                deleteButtonColor: Color = Color(.sRGB, red: 151.0/255.0, green: 151.0/255.0, blue: 154.0/255.0, opacity: 1),
                deleteButtonSystemImageName: String = "xmark",
                spacing: CGFloat = 5.0,
                alignment: HorizontalAlignment = .leading,
                inputFieldFont: Font = Font.system(size: 14),
                inputFieldTextColor: Color = Color(.sRGB, red: 45.0/255.0, green: 45.0/255.0, blue: 45.0/255.0, opacity: 1),
                contentInsets: EdgeInsets = EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)) {
        
        self.font = font
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
        self.cornerRadius = cornerRadius
        self.deletable = deletable
        self.deleteButtonSize = deleteButtonSize
        self.deleteButtonColor = deleteButtonColor
        self.deleteButtonSystemImageName = deleteButtonSystemImageName
        self.spacing = spacing
        self.alignment = alignment
        self.inputFieldFont = inputFieldFont
        self.inputFieldTextColor = inputFieldTextColor
        self.contentInsets = contentInsets
    }
}

public struct TagTextField: View {
    @Binding public var tags: [String]
    @Binding public var keyword: String
    
    public var theme: TagTheme
    public var placeholder: String
    public var checkKeyword: ((String) -> String?)? //this is a closure is to get a candidate for the currently inputed text
        
    @State private var availableWidth: CGFloat = 0
    @State private var elementsSize: [String: CGSize] = [:]
    
    public init(tags: Binding<[String]>,
                keyword: Binding<String>,
                theme: TagTheme = TagTheme(),
                placeholder: String = "",
                checkKeyword: ((String) -> String?)? = { $0 }) {
        self._tags = tags
        self._keyword = keyword
        self.theme = theme
        self.placeholder = placeholder
        self.checkKeyword = checkKeyword
    }
    
    public var body: some View {
        ZStack(alignment: Alignment(horizontal: theme.alignment, vertical: .center)) {
            Color.clear
                .frame(height: 1)
                .readSize { size in
                    availableWidth = size.width
                }
            tagContainer
        }
    }
    
    var tagContainer: some View {
        let rows = computeRows()
        return VStack(alignment: theme.alignment, spacing: theme.spacing) {
            ForEach(0..<rows.count, id: \.self) { index in
                HStack(spacing: theme.spacing) {
                    ForEach(rows[index], id: \.self) { element in
                        TagView(tag: element, theme: theme, deleteAction: {
                            tags.removeAll(where: {$0 == element})
                        })
                        .fixedSize()
                        .readSize { size in
                            elementsSize[element] = size
                        }
                    }
                    if index == rows.count - 1 {
                        textInputView
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var textInputView: some View {
        TextField(placeholder, text: $keyword, onCommit: {
            if keyword.count > 0,
               let result = checkKeyword?(keyword), tags.contains(result) == false {
                tags.append(result)
            }
            keyword = ""
        })
        .textFieldStyle(PlainTextFieldStyle())
        .font(theme.inputFieldFont)
        .foregroundColor(theme.inputFieldTextColor)
        .disableAutocorrection(true)
        .autocapitalization(.none)
    }
    
    func computeRows() -> [[String]] {
        var rows: [[String]] = [[]]
        var currentRow = 0
        var remainingWidth = availableWidth
        
        for element in tags {
            let elementSize = elementsSize[element, default: CGSize(width: availableWidth, height: 1)]
            
            if remainingWidth - (elementSize.width + theme.spacing) >= 0 {
                rows[currentRow].append(element)
            } else {
                currentRow = currentRow + 1
                rows.append([element])
                remainingWidth = availableWidth
            }
            remainingWidth = remainingWidth - (elementSize.width + theme.spacing)
        }
        return rows
    }
}

public struct TagView: View {
    let tag: String
    let theme: TagTheme
    var deleteAction: (()->Void) = {}
        
    public var body: some View {
        HStack (spacing: 4) {
            Text(tag)
                .font(theme.font)
                .foregroundColor(theme.foregroundColor)
            if theme.deletable {
                Button(action: deleteAction, label: {
                    Image(systemName: theme.deleteButtonSystemImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(theme.deleteButtonColor)
                        .frame(width: theme.deleteButtonSize, height: theme.deleteButtonSize)
                })
            }
        }
        .padding(theme.contentInsets)
        .background(theme.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: theme.cornerRadius).stroke(theme.borderColor, lineWidth: 1.0)
                .shadow(color: theme.shadowColor, radius: theme.shadowRadius)
        )
    }
}

public struct TagTextField_Previews: PreviewProvider {
    public static var previews: some View {
        Group {
            TagTextField(tags: .constant(["SwiftUI", "Apple", "Java", "Javascript", "Objective-C", "Kotlin"]),
                         keyword: .constant(""),
                         placeholder: "Tags")
                .padding(6)
                .background(Color(.sRGB, red: 244.0/255.0, green: 245.0/255.0, blue: 249.0/255.0, opacity: 1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }.padding()
    }
}

internal struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

public extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

