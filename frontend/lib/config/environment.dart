// ignore_for_file: do_not_use_environment
const bool _isRelease = bool.fromEnvironment('dart.vm.product');

class Environment {
  static String get baseUrl {
    // Use BACKEND_URL if injected at build time, otherwise fall back to defaults.
    const injected = String.fromEnvironment('BACKEND_URL', defaultValue: '');
    if (injected.isNotEmpty) return injected;
    // Release builds (e.g. the distributed APK) target the public backend.
    // Debug builds default to localhost; pass --dart-define=BACKEND_URL=...
    // to override (e.g. http://10.0.2.2:8001 for the Android emulator, or
    // http://192.168.x.x:8001 for a real device on the LAN).
    return _isRelease
        ? 'https://memo-api.nouhlab.com'
        : 'http://localhost:8001';
  }
}
