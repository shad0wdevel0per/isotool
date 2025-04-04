import Cocoa
import Foundation

class NSBlockTarget: NSObject {
    let block: () -> Void
    init(_ block: @escaping () -> Void) { self.block = block }
    @objc func call() { block() }
}

let app = NSApplication.shared
let window = NSWindow(
    contentRect: NSMakeRect(0, 0, 400, 300),
    styleMask: [.titled, .closable],
    backing: .buffered,
    defer: false
)
window.center()
window.title = "IsoTool"
window.makeKeyAndOrderFront(nil)
window.backgroundColor = NSColor.windowBackgroundColor

// ISO Label
let isoLabel = NSTextField(labelWithString: "📦 Selecione a ISO:")
isoLabel.frame = NSRect(x: 20, y: 240, width: 300, height: 24)
isoLabel.font = NSFont.boldSystemFont(ofSize: 13)
window.contentView?.addSubview(isoLabel)

// ISO Path Field
let isoPathField = NSTextField(frame: NSRect(x: 20, y: 210, width: 260, height: 24))
isoPathField.isEditable = false
isoPathField.placeholderString = "Clique para escolher a ISO"
isoPathField.backgroundColor = .controlBackgroundColor
isoPathField.font = NSFont.systemFont(ofSize: 12)
window.contentView?.addSubview(isoPathField)

// Disco Label
let diskLabel = NSTextField(labelWithString: "💽 Escolha o disco:")
diskLabel.frame = NSRect(x: 20, y: 170, width: 300, height: 24)
diskLabel.font = NSFont.boldSystemFont(ofSize: 13)
window.contentView?.addSubview(diskLabel)

// Seletor de Disco
let diskSelector = NSPopUpButton(frame: NSRect(x: 20, y: 140, width: 260, height: 26))
diskSelector.font = NSFont.systemFont(ofSize: 12)
window.contentView?.addSubview(diskSelector)

// Botão "Create"
let createButton = NSButton(title: "🚀 Criar Disco Bootável", target: nil, action: nil)
createButton.frame = NSRect(x: 100, y: 90, width: 200, height: 32)
createButton.font = NSFont.boldSystemFont(ofSize: 13)
createButton.bezelStyle = .rounded
window.contentView?.addSubview(createButton)

// Barra de Progresso
let progressBar = NSProgressIndicator(frame: NSRect(x: 20, y: 50, width: 260, height: 20))
progressBar.isIndeterminate = false
progressBar.minValue = 0
progressBar.maxValue = 100
progressBar.isHidden = true
progressBar.controlTint = .blueControlTint
window.contentView?.addSubview(progressBar)

// Label de Progresso
let progressLabel = NSTextField(labelWithString: "0.0%")
progressLabel.frame = NSRect(x: 290, y: 50, width: 60, height: 20)
progressLabel.alignment = .center
progressLabel.isHidden = true
progressLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
window.contentView?.addSubview(progressLabel)

// Atualiza lista de discos
func atualizarListaDiscos() {
    let task = Process()
    task.launchPath = "/usr/sbin/diskutil"
    task.arguments = ["list"]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    task.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""

    let lines = output.split(separator: "\n")
    diskSelector.removeAllItems()

    for line in lines {
        if line.contains("/dev/disk") {
            let components = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            if let disk = components.first {
                diskSelector.addItem(withTitle: disk.replacingOccurrences(of: "/dev/", with: ""))
            }
        }
    }
}

// Selecionar ISO
let selectISOTarget = NSBlockTarget {
    let dialog = NSOpenPanel()
    dialog.allowedFileTypes = ["iso"]
    dialog.allowsMultipleSelection = false
    dialog.canChooseDirectories = false

    if dialog.runModal() == .OK, let result = dialog.url {
        isoPathField.stringValue = result.path
    }
}
isoPathField.target = selectISOTarget
isoPathField.action = #selector(NSBlockTarget.call)

// Criar disco bootável
let createTarget = NSBlockTarget {
    guard !isoPathField.stringValue.isEmpty else { return }
    guard let disk = diskSelector.titleOfSelectedItem else { return }

    createButton.isEnabled = false
    progressBar.doubleValue = 0
    progressBar.isHidden = false
    progressLabel.stringValue = "0.0%"
    progressLabel.isHidden = false

    DispatchQueue.global().async {
        let task = Process()
        task.launchPath = "/bin/dd"
        task.arguments = ["if=\(isoPathField.stringValue)", "of=/dev/\(disk)", "bs=1m"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        try? task.run()

        let handle = pipe.fileHandleForReading
        let buffer = NSMutableData()

        while task.isRunning {
            let data = handle.availableData
            if data.isEmpty { break }
            buffer.append(data)

            DispatchQueue.main.async {
                let progresso = Double(buffer.length % 1000000) / 1000000.0 * 100.0
                progressBar.doubleValue = progresso
                progressLabel.stringValue = String(format: "%.1f%%", progresso)
            }
            Thread.sleep(forTimeInterval: 0.2)
        }

        task.waitUntilExit()

        DispatchQueue.main.async {
            progressBar.doubleValue = 100.0
            progressLabel.stringValue = "100.0%"
            sleep(1)
            NSApp.terminate(nil)
        }
    }
}
createButton.target = createTarget
createButton.action = #selector(NSBlockTarget.call)

atualizarListaDiscos()
app.run()