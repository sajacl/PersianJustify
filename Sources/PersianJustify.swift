//
//  MainLogics.swift
//  PersianJustify
//
//  Created by Ahmadreza on 3/14/24.
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - Usage using toPJString function
extension String {
    /// Method that will layout words in a `Farsi` calligraphy friendly way.
    /// - Parameter view: Ancestor view that string will be displayed in.
    /// - Warning: This is a computed heavy operation.
    public func toPJString(in view: View) -> NSAttributedString {
        guard !isEmpty else {
            return NSAttributedString()
        }

        let lines = splitStringToLines()

        let viewWidth = view.frame.width

        let font: Font = {
            lazy var defaultFont = Font()
            return view.getFont() ?? defaultFont
        }()

        return justify(lines, in: viewWidth, with: font)
    }

    private func splitStringToLines() -> [Line] {
        replaceDoubleEmptyLines()
            .splitWithLineSeparator()
            .map { Line($0) }
    }

    private func replaceDoubleEmptyLines() -> String {
        let doubleNextLine = LineBreakCharacter() + LineBreakCharacter()

        // Replacing double empty lines with one empty line
        return replacingOccurrences(
            of: doubleNextLine,
            with: LineBreakCharacter()
        )
    }

    private func linesProcessing(lines: [Line]) -> (index: Int, line: [Word]) {
        var line = [Word]()
        var index = 0
        lines.enumerated().lazy.forEach {
            line = $1.getWords()
            index = $0
        }
        return (index, line)
    }
    
    private func justify(
        _ lines: [Line],
        in proposedWidth: CGFloat,
        with font: Font
    ) -> NSAttributedString {
        let final = NSMutableAttributedString(string: "")
        let (index, words) = linesProcessing(lines: lines)

//        lines.enumerated().forEach { index, line in
//            let words = line.getWords()

            var currentLineWords: [Word] = []

            words.forEach { word in
                let canAddNewWord: Bool = {
                    let lineHasRoomForNextWord = currentLineWords.hasRoomForNextWord(
                        nextWord: word,
                        proposedWidth: proposedWidth,
                        font: font
                    )

                    lazy var isLineEmpty = currentLineWords.isEmpty

                    return lineHasRoomForNextWord || isLineEmpty
                }()

                if canAddNewWord {
                    currentLineWords.append(word)
                } 
                // Line is filled and is ready to justify
                else {
                    let justifiedLine = justifyLine(
                        from: currentLineWords,
                        in: proposedWidth,
                        with: font,
                        isLastLineInParagraph: false
                    )

                    // Appending space at the end
                    justifiedLine.appendSpaceCharacter()

                    final.append(justifiedLine)

                    currentLineWords = [word]
                }
            }

            if !currentLineWords.isEmpty {
                let extracted = justifyLine(
                    from: currentLineWords,
                    in: proposedWidth,
                    with: font,
                    isLastLineInParagraph: true
                )

                final.append(extracted)
            }

            // To avoid add extra next line at the end of text
            if index < lines.count-1 {
                final.append(LineBreakCharacter.attributedStringRepresentation)
            }
//        }

        return final
    }

    private func justifyLine(
        from words: [Word],
        in proposedWidth: CGFloat,
        with font: Font,
        isLastLineInParagraph: Bool
    ) -> NSMutableAttributedString {
        words
            .createLineFromWords()
            .justify(
                in: proposedWidth,
                isLastLineInParagraph: isLastLineInParagraph,
                font: font
            )
    }
}
