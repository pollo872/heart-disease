import 'package:flutter_test/flutter_test.dart';
import 'package:heart_disease/features/main_pages/presentation/screens/result_screen.dart';

void main() {
  group('vital value visibility', () {
    test('shows BP row when both blood pressure values are greater than zero', () {
      expect(shouldShowBpValues(120, 80), isTrue);
      expect(shouldShowBpValues(120, 0), isFalse);
      expect(shouldShowBpValues(0, 80), isFalse);
    });

    test('shows lab values when they are greater than zero', () {
      expect(shouldShowVitalValue(110), isTrue);
      expect(shouldShowVitalValue(0), isFalse);
      expect(shouldShowVitalValue(null), isFalse);
    });
  });
}
