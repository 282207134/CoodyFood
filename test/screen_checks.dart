import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coody_food/app.dart';

import 'fixtures.dart';
import 'layout_assets.dart';

void checkScreens(double width) {
  testWidgets('All 54 screens render without errors at width $width', (
    tester,
  ) async {
    await loadLayoutFonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, width == 375 ? 812 : 640);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    for (final id in screenIds) {
      final s = await previewState(id);
      await tester.pumpWidget(
        DefaultAssetBundle(
          bundle: LayoutAssets(),
          child: CoodyApp(key: ValueKey(id), state: s, initialScreen: id),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Screen $id at $width');
    }
  });
}
