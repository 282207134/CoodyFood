import 'dart:convert';

import 'package:flutter/services.dart';

Future<void> loadLayoutFonts() async {
  final loader = FontLoader('DM Sans');
  for (final weight in ['Regular', 'Medium', 'Bold']) {
    loader.addFont(rootBundle.load('assets/fonts/DMSans-$weight.ttf'));
  }
  await loader.load();
}

/// Layout tests use a tiny bitmap; device screenshots verify the real artwork.
/// Keeps 108 repeated page mounts independent of bitmap decoding cost.
class LayoutAssets extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key.endsWith('.webp')) {
      return ByteData.sublistView(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4////fwAJ+wP9KobjigAAAABJRU5ErkJggg==',
        ),
      );
    }
    return rootBundle.load(key);
  }
}
