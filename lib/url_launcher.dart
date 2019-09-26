// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const MethodChannel _channel = MethodChannel('plugins.flutter.io/url_launcher');


Future<bool> launch(
    String urlString, {
      bool forceSafariVC,
      bool forceWebView,
      bool enableJavaScript,
      bool enableDomStorage,
      bool universalLinksOnly,
      Map<String, String> headers,
      Brightness statusBarBrightness,
    }) async {
  assert(urlString != null);
  final Uri url = Uri.parse(urlString.trimLeft());
  final bool isWebURL = url.scheme == 'http' || url.scheme == 'https';
  if ((forceSafariVC == true || forceWebView == true) && !isWebURL) {
    throw PlatformException(
        code: 'NOT_A_WEB_SCHEME',
        message: 'To use webview or safariVC, you need to pass'
            'in a web URL. This $urlString is not a web URL.');
  }
  bool previousAutomaticSystemUiAdjustment;
  if (statusBarBrightness != null &&
      defaultTargetPlatform == TargetPlatform.iOS) {
    previousAutomaticSystemUiAdjustment =
        WidgetsBinding.instance.renderView.automaticSystemUiAdjustment;
    WidgetsBinding.instance.renderView.automaticSystemUiAdjustment = false;
    SystemChrome.setSystemUIOverlayStyle(statusBarBrightness == Brightness.light
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light);
  }
  final bool result = await _channel.invokeMethod<bool>(
    'launch',
    <String, Object>{
      'url': urlString,
      'useSafariVC': forceSafariVC ?? isWebURL,
      'useWebView': forceWebView ?? false,
      'enableJavaScript': enableJavaScript ?? false,
      'enableDomStorage': enableDomStorage ?? false,
      'universalLinksOnly': universalLinksOnly ?? false,
      'headers': headers ?? <String, String>{},
    },
  );
  if (statusBarBrightness != null) {
    WidgetsBinding.instance.renderView.automaticSystemUiAdjustment =
        previousAutomaticSystemUiAdjustment;
  }
  return result;
}

Future<bool> canLaunch(String urlString) async {
  if (urlString == null) {
    return false;
  }
  return await _channel.invokeMethod<bool>(
    'canLaunch',
    <String, Object>{'url': urlString},
  );
}

Future<void> closeWebView() async {
  return await _channel.invokeMethod<void>('closeWebView');
}