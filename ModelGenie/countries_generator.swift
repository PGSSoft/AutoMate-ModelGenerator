import Foundation

func generateCountries() {
    let countryCodeRegex = "[A-Z]+"
    guard let countryCodeExpr = try? NSRegularExpression(pattern: countryCodeRegex, options: []) else {
        preconditionFailure("Couldn't initialize expression with given pattern")
    }

    let regex = "\\W+"
    guard let expr = try? NSRegularExpression(pattern: regex, options: []) else {
        preconditionFailure("Couldn't initialize expression with given pattern")
    }

    let simulatorCountriesPath = Configuration.developerDirectory + "/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks/AppSupport.framework/en_AU.lproj/Localizable_Countries.strings"

    let countriesDictionary = readStrings(fromPath: simulatorCountriesPath)

    write(toFile: "SystemCountry") { (writer) in
        writer.append(
"""
\(sharedSwiftLintOptions)

/// Enumeration describing available country codes in the system.
public enum SystemCountry: String {

"""
        )

        for (key, value) in countriesDictionary.sorted(by: { $0.value < $1.value }) {
            let countryCodeRange = NSRange(location: 0, length: key.count)
            guard countryCodeExpr.numberOfMatches(in: key, options: [], range: countryCodeRange) > 0 else { continue }

            let range = NSRange(location: 0, length: value.count)
            let caseName = expr.stringByReplacingMatches(in: value, options: [], range: range, withTemplate: "")

            writer.append(
"""

    /// Automatically generated value for country \(caseName).
    case \(caseName) = "\(key)"

"""
            )
        }

        writer.append(line: "}")
    }
}
