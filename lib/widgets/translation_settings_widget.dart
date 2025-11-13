import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/services/enhanced_translation.service.dart';

class TranslationSettingsWidget extends StatefulWidget {
  final VoidCallback? onSettingsChanged;

  const TranslationSettingsWidget({Key? key, this.onSettingsChanged})
    : super(key: key);

  @override
  State<TranslationSettingsWidget> createState() =>
      _TranslationSettingsWidgetState();
}

class _TranslationSettingsWidgetState extends State<TranslationSettingsWidget> {
  bool _autoTranslateEnabled = false;
  String _selectedLanguage = 'en';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final autoTranslate =
          await EnhancedTranslationService.isAutoTranslateEnabled();
      final language = await EnhancedTranslationService.getSelectedLanguage();

      setState(() {
        _autoTranslateEnabled = autoTranslate;
        _selectedLanguage = language;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading translation settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAutoTranslate(bool value) async {
    try {
      await EnhancedTranslationService.setAutoTranslateEnabled(value);
      setState(() {
        _autoTranslateEnabled = value;
      });
      widget.onSettingsChanged?.call();
    } catch (e) {
      print('Error toggling auto-translate: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update auto-translate setting'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _changeLanguage(String languageCode) async {
    try {
      await EnhancedTranslationService.setSelectedLanguage(languageCode);
      setState(() {
        _selectedLanguage = languageCode;
      });
      widget.onSettingsChanged?.call();
    } catch (e) {
      print('Error changing language: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to change language'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Title
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Select Language',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),

                // Language list
                Expanded(
                  child: ListView.builder(
                    itemCount:
                        EnhancedTranslationService.supportedLanguages.length,
                    itemBuilder: (context, index) {
                      final entry = EnhancedTranslationService
                          .supportedLanguages
                          .entries
                          .elementAt(index);
                      final languageCode = entry.key;
                      final languageInfo = entry.value;
                      final isSelected = languageCode == _selectedLanguage;

                      return ListTile(
                        leading: Text(
                          languageInfo['flag'] ?? '🌐',
                          style: TextStyle(fontSize: 24),
                        ),
                        title: Text(
                          languageInfo['name'] ?? languageCode.toUpperCase(),
                          style: TextStyle(
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color: isSelected ? AppColor.primaryColor : null,
                          ),
                        ),
                        trailing:
                            isSelected
                                ? Icon(
                                  FlutterIcons.check_fea,
                                  color: AppColor.primaryColor,
                                )
                                : null,
                        onTap: () {
                          _changeLanguage(languageCode);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        children: [
          // Auto-translate toggle
          Row(
            children: [
              Icon(
                FlutterIcons.globe_fea,
                color: AppColor.primaryColor,
                size: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Auto-translate messages',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              Switch(
                value: _autoTranslateEnabled,
                onChanged: _toggleAutoTranslate,
                activeColor: AppColor.primaryColor,
              ),
            ],
          ),

          // Language selector
          if (_autoTranslateEnabled) ...[
            SizedBox(height: 8),
            GestureDetector(
              onTap: _showLanguageSelector,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Text(
                      EnhancedTranslationService
                              .supportedLanguages[_selectedLanguage]?['flag'] ??
                          '🌐',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Translate to ${EnhancedTranslationService.supportedLanguages[_selectedLanguage]?['name'] ?? _selectedLanguage.toUpperCase()}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ),
                    Icon(
                      FlutterIcons.chevron_down_fea,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
