import 'package:flutter_test/flutter_test.dart';
import 'package:second_memory/theme/app_theme.dart';

void main() {
  test('Muted text has readable contrast on the dark surface tokens', () {
    for (final background in [
      AppColors.background,
      AppColors.surface,
      AppColors.surfaceElevated,
      AppColors.gradientStart,
      AppColors.gradientEnd,
    ]) {
      final contrast = (AppColors.textMuted.computeLuminance() + 0.05) /
          (background.computeLuminance() + 0.05);
      expect(contrast, greaterThanOrEqualTo(4.5));
    }
  });
}
