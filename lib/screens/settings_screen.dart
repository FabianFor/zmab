import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // ✅ DETECTAR TAMAÑO DE PANTALLA
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    final maxWidth = isLargeScreen ? 800.0 : double.infinity; // ✅ Limitar ancho en tablets

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings, style: TextStyle(fontSize: 18.sp)),
        backgroundColor: isDark ? null : const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: Center( // ✅ CENTRAR contenido en tablets
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth), // ✅ LIMITAR ancho
          child: ListView(
            padding: EdgeInsets.all(isLargeScreen ? 24.w : 16.w),
            children: [
              // ✅ DARK MODE SWITCH
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? 20.w : 16.w,
                    vertical: isLargeScreen ? 12.h : 8.h,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          settingsProvider.isDarkMode 
                              ? Icons.dark_mode 
                              : Icons.light_mode,
                          color: const Color(0xFF2196F3),
                          size: isLargeScreen ? 32.sp : 28.sp,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getDarkModeText(l10n),
                              style: TextStyle(
                                fontSize: isLargeScreen ? 18.sp : 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              _getDarkModeSubtitleText(l10n),
                              style: TextStyle(
                                fontSize: isLargeScreen ? 15.sp : 13.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: settingsProvider.isDarkMode,
                        onChanged: (value) {
                          settingsProvider.toggleDarkMode();
                        },
                        activeColor: const Color(0xFF2196F3),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16.h),

              // ✅ PERFIL DEL NEGOCIO
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? 20.w : 16.w,
                    vertical: isLargeScreen ? 12.h : 8.h,
                  ),
                  leading: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.store,
                      color: const Color(0xFF2196F3),
                      size: isLargeScreen ? 32.sp : 28.sp,
                    ),
                  ),
                  title: Text(
                    l10n.businessProfile,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 18.sp : 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    _getBusinessProfileSubtitleText(l10n),
                    style: TextStyle(
                      fontSize: isLargeScreen ? 15.sp : 13.sp,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    size: isLargeScreen ? 28.sp : 24.sp,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 16.h),

              // ✅ IDIOMA
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? 20.w : 16.w,
                    vertical: isLargeScreen ? 12.h : 8.h,
                  ),
                  leading: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.language,
                      color: const Color(0xFF4CAF50),
                      size: isLargeScreen ? 32.sp : 28.sp,
                    ),
                  ),
                  title: Text(
                    l10n.language,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 18.sp : 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${settingsProvider.currentLanguageFlag} ${settingsProvider.currentLanguageName}',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 16.sp : 14.sp,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    size: isLargeScreen ? 28.sp : 24.sp,
                  ),
                  onTap: () {
                    _showLanguageDialog(context);
                  },
                ),
              ),

              SizedBox(height: 16.h),

              // ✅ MONEDA
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? 20.w : 16.w,
                    vertical: isLargeScreen ? 12.h : 8.h,
                  ),
                  leading: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C27B0).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.attach_money,
                      color: const Color(0xFF9C27B0),
                      size: isLargeScreen ? 32.sp : 28.sp,
                    ),
                  ),
                  title: Text(
                    l10n.currency,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 18.sp : 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${settingsProvider.currentCurrencyFlag} ${settingsProvider.currentCurrencyName}',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 16.sp : 14.sp,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    size: isLargeScreen ? 28.sp : 24.sp,
                  ),
                  onTap: () {
                    _showCurrencyDialog(context);
                  },
                ),
              ),

              SizedBox(height: 32.h),

              // ✅ INFO DE LA APP
              Center(
                child: Column(
                  children: [
                    Text(
                      'MiNegocio',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 22.sp : 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Versión 1.0.0',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 16.sp : 14.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ DIÁLOGO DE IDIOMA (RESPONSIVO)
  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.read<SettingsProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLargeScreen = screenWidth > 600;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isLargeScreen ? 450 : screenWidth * 0.9,
            maxHeight: screenHeight * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ HEADER
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.r),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.language,
                      color: Colors.white,
                      size: isLargeScreen ? 28.sp : 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        l10n.selectLanguage,
                        style: TextStyle(
                          fontSize: isLargeScreen ? 22.sp : 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 24.sp),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // ✅ LISTA DE IDIOMAS
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  itemCount: SettingsProvider.supportedLanguages.length,
                  itemBuilder: (context, index) {
                    final entry = SettingsProvider.supportedLanguages.entries.elementAt(index);
                    final isSelected = settingsProvider.locale.languageCode == entry.key;
                    
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 8.h,
                      ),
                      leading: Text(
                        entry.value['flag']!,
                        style: TextStyle(fontSize: isLargeScreen ? 32.sp : 28.sp),
                      ),
                      title: Text(
                        entry.value['name']!,
                        style: TextStyle(
                          fontSize: isLargeScreen ? 18.sp : 16.sp,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected 
                          ? Icon(
                              Icons.check_circle,
                              color: const Color(0xFF2196F3),
                              size: isLargeScreen ? 28.sp : 24.sp,
                            )
                          : null,
                      selected: isSelected,
                      selectedTileColor: const Color(0xFF2196F3).withOpacity(0.1),
                      onTap: () {
                        settingsProvider.setLanguage(entry.key);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ DIÁLOGO DE MONEDA (RESPONSIVO)
  void _showCurrencyDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.read<SettingsProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isLargeScreen = screenWidth > 600;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isLargeScreen ? 550 : screenWidth * 0.9,
            maxHeight: screenHeight * 0.75, // ✅ Más altura para ver más monedas
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ HEADER
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.r),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      color: Colors.white,
                      size: isLargeScreen ? 28.sp : 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        l10n.selectCurrency,
                        style: TextStyle(
                          fontSize: isLargeScreen ? 22.sp : 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 24.sp),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // ✅ LISTA DE MONEDAS
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  itemCount: SettingsProvider.supportedCurrencies.length,
                  itemBuilder: (context, index) {
                    final entry = SettingsProvider.supportedCurrencies.entries.elementAt(index);
                    final isSelected = settingsProvider.currencyCode == entry.key;
                    
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 8.h,
                      ),
                      leading: Text(
                        entry.value['flag']!,
                        style: TextStyle(fontSize: isLargeScreen ? 32.sp : 28.sp),
                      ),
                      title: Text(
                        entry.value['name']!,
                        style: TextStyle(
                          fontSize: isLargeScreen ? 18.sp : 16.sp,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        entry.value['symbol']!,
                        style: TextStyle(
                          fontSize: isLargeScreen ? 16.sp : 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: isSelected 
                          ? Icon(
                              Icons.check_circle,
                              color: const Color(0xFF9C27B0),
                              size: isLargeScreen ? 28.sp : 24.sp,
                            )
                          : null,
                      selected: isSelected,
                      selectedTileColor: const Color(0xFF9C27B0).withOpacity(0.1),
                      onTap: () {
                        settingsProvider.setCurrency(entry.key);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDarkModeText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es': return 'Modo oscuro';
      case 'en': return 'Dark mode';
      case 'pt': return 'Modo escuro';
      case 'zh': return '深色模式';
      default: return 'Dark mode';
    }
  }

  String _getDarkModeSubtitleText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es': return 'Activa el tema oscuro';
      case 'en': return 'Activate dark theme';
      case 'pt': return 'Ativar tema escuro';
      case 'zh': return '激活深色主题';
      default: return 'Activate dark theme';
    }
  }

  String _getBusinessProfileSubtitleText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es': return 'Edita la información de tu negocio';
      case 'en': return 'Edit your business information';
      case 'pt': return 'Edite as informações do seu negócio';
      case 'zh': return '编辑您的企业信息';
      default: return 'Edit your business information';
    }
  }
}
