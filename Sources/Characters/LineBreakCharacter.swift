import Foundation

/// Wrapper around a character which is used to break a line.
struct LineBreakCharacter {
//    fileprivate static let _character: Character = "\n"
    fileprivate static let _character: CharacterSet = CharacterSet.newlines

    static var stringRepresentation: String {
        return String(describing: _character)
        //        String(LineBreakCharacter._character)
    }

    static var attributedStringRepresentation: NSAttributedString {
        NSAttributedString(string: stringRepresentation)
    }

    static func + (lhs: LineBreakCharacter, rhs: LineBreakCharacter) -> String {
        stringRepresentation + stringRepresentation
    }

    static func + (lhs: String, rhs: LineBreakCharacter) -> String {
        lhs + stringRepresentation
    }
}

extension String {
    func replacingOccurrences(of target: String, with replacement: LineBreakCharacter) -> String {
        replacingOccurrences(of: target, with: LineBreakCharacter.stringRepresentation)
    }

    func splitWithLineSeparator() -> [String] {
//        split(separator: LineBreakCharacter._character)
        return components(separatedBy: LineBreakCharacter._character)
    }
}
