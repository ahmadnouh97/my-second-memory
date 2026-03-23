// ignore_for_file: do_not_use_environment
const bool _isRelease = bool.fromEnvironment('dart.vm.product');

class Environment {
  static String get baseUrl {
    // Use BACKEND_URL if injected at build time, otherwise fall back to defaults.
    const injected = String.fromEnvironment('BACKEND_URL', defaultValue: '');
    if (injected.isNotEmpty) return injected;
    // On Android emulator the host machine is reachable via 10.0.2.2.
    // On web (flutter run -d chrome) localhost works fine.
    return _isRelease ? 'http://10.0.2.2:8000' : 'http://localhost:8000';
  }
}
