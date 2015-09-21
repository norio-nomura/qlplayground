//
//  highlight.swift
//  qlplayground
//
//  Created by 野村 憲男 on 9/19/15.
//
//  Copyright (c) 2015 Norio Nomura
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

public class Highlight: NSObject {
    /// read bundle
    static let bundle = NSBundle(forClass: Highlight.self)
    static let script = bundle.URLForResource("highlight.pack", withExtension: "js", subdirectory: "highlight")
        .flatMap { try? String(contentsOfURL: $0)} ?? ""
    static var css: String {
        let style = NSUserDefaults(suiteName: bundle.bundleIdentifier)?.stringForKey("HighlightStyle") ?? "xcode"
        return bundle.URLForResource(style, withExtension: "css", subdirectory: "highlight/styles")
            .flatMap { try? String(contentsOfURL: $0)} ?? ""
    }

    /// create NSData from url pointing .swift or .playground
    public static func data(URL url: NSURL) -> NSData? {
        let fm = NSFileManager.defaultManager()
        
        var isDirectory: ObjCBool = false
        guard url.fileURL && url.path.map({ fm.fileExistsAtPath($0, isDirectory: &isDirectory) }) ?? false else {
            return nil
        }

        func escapeHTML(string: String) -> String {
            return NSXMLNode.textWithStringValue(string).XMLString
        }

        /// read contents.swift
        let codes: String
        if isDirectory {
            let keys = [NSURLTypeIdentifierKey]
            
            func isSwiftSourceURL(url: NSURL) -> Bool {
                if let typeIdentifier = try? url.resourceValuesForKeys(keys)[NSURLTypeIdentifierKey] as? String
                    where typeIdentifier == "public.swift-source" {
                        return true
                } else {
                    return false
                }
            }
            
            let enumerator = fm.enumeratorAtURL(url, includingPropertiesForKeys: keys, options: [], errorHandler: nil)
            let swiftSources = anyGenerator { enumerator?.nextObject() as? NSURL }
                .filter(isSwiftSourceURL)
            
            let length = url.path!.characters.count
            func subPath(url: NSURL) -> String {
                return String(url.path!.characters.dropFirst(length))
            }
            codes = swiftSources.flatMap {
                guard let content = try? String(contentsOfURL: $0) else { return nil }
                return "<code>\(subPath($0))</code><pre><code class='swift'>\(escapeHTML(content))</code></pre>"
                }
                .joinWithSeparator("<hr>")
        } else {
            codes = (try? String(contentsOfURL: url))
                .map {"<pre><code class='swift'>\(escapeHTML($0))</code></pre>"} ?? ""
            
        }
        
        let html = ["<!DOCTYPE html>",
            "<html><meta charset=\"utf-8\" /><head>",
            "<style>*{margin:0;padding:0}\(css)</style>",
            "<script>\(script)</script>",
            "<script>hljs.initHighlightingOnLoad();</script>",
            "</head><body class=\"hljs\">\(codes)</body></html>"]
            .joinWithSeparator("\n")
        return html.dataUsingEncoding(NSUTF8StringEncoding)
    }
}
