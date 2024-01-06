//
//  TweakEditorHome.swift
//  Picasso
//
//  Created by sourcelocation on 05/08/2023.
//

import SwiftUI
import NavigationBackport

struct TweakEditorHomeWrapper: View {
    var body: some View {
        NavigationView { // say to Navigator, causes issues when selecting path (stuck indefinetely)
            TweakEditorHome()
        }
    }
}

struct TweakEditorHome: View {
    
    struct TemplatesSection: Identifiable {
        struct TemplateListEntry {
            var title: String
            var image: String
            var description: String
            var destination: AnyView
            var disabled: Bool = false
        }
        
        var image: String
        var title: String
        var id = UUID()
        
        var templates: [TemplateListEntry]
    }
    
    @State var sections: [TemplatesSection] = [
        .init(image: "paintbrush", title: "Colors", templates: [
            .init(title: "Springboard Colors", image: "apps.iphone", description: "Change various colors", destination: AnyView(ColorEditor(type: .dock))),
            .init(title: "Accent Color", image: "paintpalette", description: "Change system accent color", destination: AnyView(AccentEditor())),
        ]),
        .init(image: "ellipsis", title: "Other", templates: [
            .init(title: "Dynamic Island", image: "iphone.gen3", description: "Enable Dynamic Island on any device", destination: AnyView(DynamicIslandEditor())),
            .init(title: "System-wide font", image: "f.cursive", description: "(🚧 WIP 🚧) Changes the font used throughout the system", destination: AnyView(FontEditor()), disabled: true),
            .init(title: "Accent Color NX", image: "paintbrush", description: "(🚧 WIP 🚧) Change system colors", destination: AnyView(AccentNXView())),
            .init(title: "Change Passcode Keys", image: "paintbrush", description: "(🚧 WIP 🚧) Change Passcode Keys", destination: AnyView(ChangePasscodeKeysEditor())),
        ]),
        .init(image: "slider.horizontal.3", title: "Custom", templates: [
            .init(title: "Custom", image: "wrench.and.screwdriver.fill", description: "(🚧 WIP 🚧) Create a custom tweak from scratch (For advanced users)", destination: AnyView(CustomTweakEditor()), disabled: false),
        ]),
    ]
    
    @State var tweakProjects: [LocalPackage] = []
    
    var body: some View {
            List {
                if !tweakProjects.isEmpty {
                    Section(header: Label("Your projects", systemImage: "doc")) {
                        ForEach(tweakProjects, id: \.info.bundleID) { project in
                            NavigationLink(destination: CustomTweakEditor(package: project)) {
                                HStack {
                                    Image(systemName: "doc")
                                        .font(.system(size: 20))
                                        .frame(width: 30, height: 30)
                                        .padding(2)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(6)
                                        .foregroundColor(.accentColor)
                                    VStack(alignment: .leading) {
                                        Text(project.info.name)
                                            .font(.headline)
                                        Text(project.info.author)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.leading, 8)
                                }
                            }
                        }
                        .onDelete { index in
                            let project = tweakProjects[index.first!]
                            UIApplication.shared.confirmAlertDestructive(title: "Delete \(project.info.name)?", body: "Are you sure you want to delete this tweak? There is no going back after this!", onOK: {
                                print("hell nawhhh")
                                try? FileManager.default.removeItem(at: project.url!)
                                withAnimation {
                                    tweakProjects.remove(atOffsets: index)
                                }
                            }, destructActionText: "Yes, delete it!")
                        }
                    }
                }
                
                ForEach(sections) { section in
                    Section(header: Label(section.title, systemImage: section.image)) {
                        ForEach(section.templates, id: \.title) { template in
                            NavigationLink(destination: template.destination) {
                                Row(template: template)
                            }
                            .deleteDisabled(true)
                            .disabled(template.disabled)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Templates")
            .onAppear {
                let projects = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Projects")
                tweakProjects = TweakManager.shared.getPackages(at: projects)
                #if DEBUG
                
                #endif
            }
    }
    struct Row: View {
        public var template: TemplatesSection.TemplateListEntry
        
        var body: some View {
            HStack {
                Image(systemName: template.image)
                    .font(.system(size: 20))
                    .frame(width: 30, height: 30)
                    .padding(2)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(6)
                    .foregroundColor(.accentColor)
                VStack(alignment: .leading) {
                    Text(template.title)
                        .font(.headline)
                    Text(template.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.leading, 8)
            }
        }
    }
}



//struct TweakEditorHome_Previews: PreviewProvider {
//    static var previews: some View {
//        TweakEditorHome(, editingProject: <#Bool#>)
//    }
//}
