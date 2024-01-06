//
//  CustomTweakEditor.swift
//  Picasso
//
//  Created by sourcelocation on 05/08/2023.
//

import SwiftUI
import URLBackport
import NavigationBackport

struct CustomTweakEditor: View {

    @StateObject var package: LocalPackage = .init(tweak: .init(operations: []),
                                                   info: .init(bundleID: "\(UserDefaults.standard.string(forKey: "bundleID") ?? "com.\(UserDefaults.standard.string(forKey: "username")?.lowercased() ?? "example")").newpackage",
                                                               name: "",
                                                               author: UserDefaults.standard.string(forKey: "authorName") ?? UserDefaults.standard.string(forKey: "username") ?? "You!",
                                                               version: "1.0",
                                                               iconURL: nil), prefs: .init(preferences: []),
                                                   url: nil)
    
    @State var showNameAlert = false
    @State var nameAlertNameText = ""
    
    @ViewBuilder
    var noOperations: some View {
        VStack {
            Text("No operations. Would you like to create a first one?")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding()
            
            Button("Create operation") {
                addOperation()
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        addOperation()
                    } label: { Image(systemName: "plus") }
                }
            }
        }
    }
    
    var body: some View {
        Group {
            if package.tweak.operations.isEmpty {
                noOperations
            } else {
                let alertBinding = Binding<Bool>(
                    get: { showNameAlert || package.info.name == "" },
                    set: { showNameAlert = $0 })
                
                List {
                    ForEach($package.tweak.operations) { operation in
                        let operationI = package.tweak.operations.firstIndex(where:{ $0.id == operation.id })!
                        
                        Section(header:
                                    HStack {
                            Text("Operation \(operationI + 1)")
                            Spacer()
                            Button {
                                package.tweak.operations.remove(at: operationI)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        ) {
                            Picker("Type", selection: operation.type) {
                                Text("Replace").tag(OperationType.replacing)
                                Text("Remove").tag(OperationType.removing)
                                Text("Plist editing").tag(OperationType.plistEditing)
                            }
                            //                            .pickerStyle(.)
                            .onChange(of: operation.type.wrappedValue) { _ in
                                switch operation.type.wrappedValue {
                                case .replacing:
                                    package.tweak.operations[operationI] = ReplaceOperation(path: "", replacementFileName: "", replacementFileBundled: false)
                                case .removing:
                                    package.tweak.operations[operationI] = RemoveOperation(path: "")
                                case .plistEditing:
                                    package.tweak.operations[operationI] = PlistOperation(path: "", keyPath: "", value: .init(""), matchAllKeys: true)
                                default:
                                    break
                                }
                            }
                            
                            if let replaceOp = operation.wrappedValue as? ReplaceOperation {
                                ReplaceOperationOptions(operation: replaceOp)
                                    .environmentObject(package)
                            } else if let removeOp = operation.wrappedValue as? RemoveOperation {
                                RemoveOperationOptions(operation: removeOp)
                            } else if let plistOp = operation.wrappedValue as? PlistOperation {
                                PlistOperationOptions(operation: plistOp)
                            }
                            
                        }
                        .headerProminence(.increased)
                    }
                    .onDelete { indexSet in
                        package.tweak.operations.remove(atOffsets: indexSet)
                    }
                    
                    NavigationLink(destination: TweakCompileReviewView(package: package)) {
                        Text("Compile tweak")
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.accentColor.opacity(0.2))
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            if let url = package.url {
                                package.save(to: url)
                            } else {
                                showNameAlert = true
                            }
                        } label: { Image(systemName:"square.and.arrow.down") }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: CustomTweakAssetsViewer(tweak: package)) {
                            Image(systemName: "shippingbox")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            addOperation()
                        } label: { Image(systemName: "plus") }
                    }
                }
                .alert("Enter tweak name", isPresented: alertBinding) {
                    TextField("Tweak name", text: $nameAlertNameText)
                    Button("OK") {
                        package.info = .init(createDefaultWithName: nameAlertNameText)
                        
                        let projects = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Projects")
                        try? FileManager.default.createDirectory(at: projects, withIntermediateDirectories: true, attributes: nil)
                        let tweakURL = projects.appendingPathComponent("\(package.info.name)")
                        
                        package.url = tweakURL
                        
                        package.save(to: package.url!)
                    }
                } message: {
                    Text("For the tweak to be saved a name must be given")
                }
            }
        }
        .navigationTitle("Create")
    }
    
    func addOperation() {
        package.tweak.operations.append(ReplaceOperation(path: "", replacementFileName: "", replacementFileBundled: false))
    }

    func save() {
        
    }
}


struct ReplaceOperationOptions: View {
    
    @ObservedObject var operation: ReplaceOperation
    
    @State var showingPicker = false
    
    var body: some View {
        
        NavigationLink(destination: CustomTweakDirectoryView(selectedURL: $operation.path, currentURL: .backport(filePath: "/"))) {
            Text("Path")
            Spacer()
            Text(operation.path)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
        
        Toggle("Replacement File Bundled", isOn: $operation.replacementFileBundled)
            .tint(.accentColor)
        
        if operation.replacementFileBundled {
            HStack {
                Button(operation.replacementFileName.isEmpty ? "Select file" : operation.replacementFileName) {
                    showingPicker = true
                }
                .sheet(isPresented: $showingPicker) {
                    CustomTweakAssetsPicker(selectedPath: $operation.replacementFileName)
                }
            }
        } else {
            NavigationLink(destination: CustomTweakDirectoryView(selectedURL: $operation.replacementFileName, currentURL: .backport(filePath: "/"))) {
                Text("Replacement file")
                Spacer()
                Text(operation.replacementFileName)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
}

struct PlistOperationOptions: View {
    
    @ObservedObject var operation: PlistOperation
    
    @State var plistValueType = "String"
    
    var body: some View {
        
        NavigationLink(destination: CustomTweakDirectoryView(selectedURL: $operation.path, currentURL: .backport(filePath: "/"))) {
            Text("Path")
            Spacer()
            Text(operation.path)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
        
        TextField("Key path", text: $operation.keyPath)
                .autocapitalization(.none)
        
        
        Toggle("Match all keys", isOn: $operation.matchAllKeys)
            .tint(.accentColor)
        
        Picker("Value type", selection: $plistValueType) {
            Text("String").tag("String")
            Text("Bool").tag("Bool")
            Text("Int").tag("Int")
            Text("Float").tag("Float")
        }

        switch plistValueType {
        case "String":
            let binding = Binding<String>(
                get: { operation.value.value as? String ?? "" },
                set: { operation.value = .init($0) }
            )

            TextField("Value", text: binding)
                .autocapitalization(.none)
        case "Bool":
            let binding = Binding<Bool>(
                get: { operation.value.value as? Bool ?? false },
                set: { operation.value = .init($0) }
            )

            Toggle("Value", isOn: binding)
                .tint(.accentColor)
        case "Int":
            let binding = Binding<Int>(
                get: { operation.value.value as? Int ?? 0 },
                set: { operation.value = .init($0) }
            )

            TextField("Value", value: binding, formatter: NumberFormatter())
                .keyboardType(.numberPad)
        case "Float":
            let binding = Binding<Float>(
                get: { operation.value.value as? Float ?? 0 },
                set: { operation.value = .init($0) }
            )

            TextField("Value", value: binding, formatter: NumberFormatter())
                .keyboardType(.decimalPad)
        default:
            Text("Unknown value type")
        }
    }
}

struct RemoveOperationOptions: View {
    
    @ObservedObject var operation: RemoveOperation
    
    var body: some View {
        NavigationLink(destination: CustomTweakDirectoryView(selectedURL: $operation.path, currentURL: .backport(filePath: "/"))) {
            Text("Path")
            Spacer()
            Text(operation.path)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}

//struct CustomTweakEditor_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomTweakEditor()
//    }
//}
