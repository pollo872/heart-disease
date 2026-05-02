import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

// للـ Web
import 'dart:html' as html;

 findDoctor() {
  
  const url = 'https://www.google.com/maps/search/دكتور+قلب';
  
  if (kIsWeb) {
    // Web
    html.window.open(url, '_blank');
  } else {
    // Mobile - استخدم url_launcher
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

}