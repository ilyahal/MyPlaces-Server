import Vapor

/// Called after your application has initialized.
public func boot(_ app: Application) throws {
    let settingsService = try app.make(SettingsService.self)
    
    do {
        try FileManager.`default`.createDirectory(at: settingsService.filesDirectory, withIntermediateDirectories: true, attributes: nil)
    } catch {
        preconditionFailure()
    }
}
