//
//  LogView.swift
//  Picasso
//
//  Created by Hariz Shirazi on 2023-08-18.
//

import SwiftUIBackports
import SwiftUI

struct LogView: View {
    @State var LogItems: [String.SubSequence] = fullLog
    @State var logString: String = ""
    
    init() {
        logString = getLogs()
    }
    var body: some View {
            VStack {
                VStack {
                    ScrollView {
                        ScrollViewReader { scroll in
                            VStack(alignment: .leading) {
//                                ForEach(0..<LogItems.count, id: \.self) { LogItem in
//                                    VStack(alignment: .leading) {
//                                        Text("[*] \(String(LogItems[LogItem]))")
//                                            .textSelection(.enabled)
//                                            .font(.system(.subheadline, design: .monospaced))
//                                        Divider()
//                                    }
//                                }
                                Text(logString)
                            }
                            .onAppear {
                                scroll.scrollTo(LogItems.count - 1)
                            }
                            .onReceive(NotificationCenter.default.publisher(for: LogStream.shared.reloadNotification)) { obj in
                                DispatchQueue.global(qos: .utility).async {
                                    guard let AttributedText = LogStream.shared.outputString.copy() as? NSAttributedString else {
                                        LogItems = ["Error Getting Log!"]
                                        return
                                    }
                                    LogItems = AttributedText.string.split(separator: "\n")
                                    logString = getLogs()
                                    scroll.scrollTo(LogItems.count - 1)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Button(action: {
                        UIPasteboard.general.string = getLogs()
                        Haptic.shared.notify(.success)
                        UIApplication.shared.alert(title: "Notice", body: "Copied successfully!")
                    }, label: {
                        Label("Copy Logs", systemImage: "doc.on.doc")
                    })
                    .padding(.top, 2)
                    
                    Backport.ShareLink(item: getLogs(), label: {
                        Label("Share Logs", systemImage: "square.and.arrow.up")
                    })
                    .padding(.top, 2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
            }
            .clipShape(RoundedRectangle(cornerSize: CGSize(size: 16)))
            .padding(.vertical, 50)
            .padding(.horizontal, 30)
            
            .cornerRadius(20)
            .navigationTitle("Debug Logs")
    }
    
    func getLogs() -> String {
        var logString: String = ""
        
        for line in LogItems {
            logString += "\(line)\n"
        }
        
        return logString
    }
}

//#Preview {
//    LogView()
//}
