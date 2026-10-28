import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coody_food/app.dart';

import '../test/fixtures.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Capture every Coody screen on Android', (tester) async {
    SharedPreferences.setMockInitialValues({});
    var converted = false;
    for (final id in screenIds) {
      final state = await previewState(id);
      await tester.pumpWidget(
        CoodyApp(key: ValueKey(id), state: state, initialScreen: id),
      );
      await tester.pumpAndSettle();
      // Decoding local images does not itself keep pumpAndSettle waiting.
      // Preload the original assets before the first capture, then await a frame.
      if (id == screenIds.first) {
        final context = tester.element(find.byType(Navigator).first);
        await Future.wait(
          List.generate(
            46,
            (i) => precacheImage(
              AssetImage(
                'assets/images/asset_${i.toString().padLeft(2, '0')}.webp',
              ),
              context,
            ),
          ),
        );
        await tester.pumpAndSettle();
      }
      if (Platform.isAndroid && !converted) {
        await binding.convertFlutterSurfaceToImage();
        converted = true;
        await tester.pumpAndSettle();
      }
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      for (var attempt = 0; attempt < 30; attempt++) {
        final waiting = tester.widgetList<RawImage>(find.byType(RawImage)).any((image) => image.image == null);
        if (!waiting) break;
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(tester.widgetList<RawImage>(find.byType(RawImage)).where((image) => image.image == null), isEmpty, reason: 'All images loaded for $id');
      await tester.pump(const Duration(milliseconds: 150));
      expect(tester.takeException(), isNull, reason: 'Screen $id');
      await binding.takeScreenshot(id);
      if (['201', '213', '214', '215', '218', '501'].contains(id)) {
        final scroll = find
            .byWidgetPredicate(
              (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
            )
            .first;
        await tester.drag(scroll, const Offset(0, -1800));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 500));
        await binding.takeScreenshot('$id-bottom');
      }
    }
  }, timeout: const Timeout(Duration(minutes: 12)));
}
