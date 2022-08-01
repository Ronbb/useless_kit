import 'dart:ui';

import 'platform_stub.dart' if (dart.library.html) 'platform_web.dart'
    as platform;

final Locale defaultLocale = platform.defaultLocale;

const String? defaultFontFamily = platform.defaultFontFamily;
