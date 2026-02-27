import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:heart_disease/shared/widgets/common_bar.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LanguageView();
  }
}

class LanguageView extends StatelessWidget {
  const LanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: ValueKey(context.locale.languageCode),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              commonBarWidget(
                context,
                tr("language"),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _sectionTitle("suggested"),
                    _langTile(context, "arabic", const Locale('ar')),
                    _langTile(context, "english", const Locale('en')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        tr(key),
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _langTile(
    BuildContext context,
    String title,
    Locale locale,
  ) {
    return RadioListTile<Locale>(
      value: locale,
      groupValue: context.locale,
      onChanged: (value) {
        if (value != null) {
          context.setLocale(value);
        }
      },
      title: Text(tr(title)),
      activeColor: Colors.green,
      contentPadding: EdgeInsets.zero,
    );
  }
}
