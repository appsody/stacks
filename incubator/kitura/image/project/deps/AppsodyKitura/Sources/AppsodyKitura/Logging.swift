import LoggerAPI
import HeliumLogger

/// Initialize logging using HeliumLogger, using the `LOG_LEVEL` environment
/// variable. This must match the name of a `LoggerMessageType`, or `none` to
/// disable logging entirely.
///
/// If no `LOG_LEVEL` is specified, the default level of `info` will be used.
///
func initializeLogging(value: String?) {
    let logLevel: LoggerMessageType
    switch value?.lowercased() {
    case "error":
        logLevel = .error
    case "warning":
        logLevel = .warning
    case "info":
        logLevel = .info
    case "verbose":
        logLevel = .verbose
    case "debug":
        logLevel = .debug
    case "exit":
        logLevel = .exit
    case "entry":
        logLevel = .entry
    case "none", "false", "off", "disabled":
        return
    default:
        logLevel = .info
    }
    HeliumLogger.use(logLevel)
}
