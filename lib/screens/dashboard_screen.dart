import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/business_provider.dart';
import '../providers/product_provider.dart';
import 'products_screen.dart';
import 'orders_screen.dart';
import 'invoices_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final businessProvider = context.watch<BusinessProvider>();
    final productProvider = context.watch<ProductProvider>();

    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ✅ HEADER
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: isLargeScreen ? 32.h : 24.h,
                  horizontal: isLargeScreen ? 32.w : 20.w,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            businessProvider.profile.businessName.isEmpty
                                ? 'MiNegocio'
                                : businessProvider.profile.businessName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isLargeScreen ? 28.sp : 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            l10n.businessManagement,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (productProvider.lowStockProducts.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '${productProvider.lowStockProducts.length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.all(isLargeScreen ? 32.w : 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ TÍTULO
                    Text(
                      _getHomeTitleText(l10n),
                      style: TextStyle(
                        fontSize: isLargeScreen ? 32.sp : 28.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _getHomeSubtitleText(l10n),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // ✅ ACCESOS RÁPIDOS TÍTULO
                    Text(
                      _getQuickAccessText(l10n),
                      style: TextStyle(
                        fontSize: isLargeScreen ? 24.sp : 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // ✅ BOTONES EN LÍNEA (uno debajo del otro)
                    _buildQuickAccessButton(
                      context: context,
                      icon: Icons.inventory_2,
                      label: l10n.products,
                      color: const Color(0xFF4CAF50),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProductsScreen()),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    
                    _buildQuickAccessButton(
                      context: context,
                      icon: Icons.shopping_cart,
                      label: l10n.orders,
                      color: const Color(0xFF2196F3),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const OrdersScreen()),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    
                    _buildQuickAccessButton(
                      context: context,
                      icon: Icons.receipt_long,
                      label: l10n.invoices,
                      color: const Color(0xFFFF9800),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const InvoicesScreen()),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    
                    _buildQuickAccessButton(
                      context: context,
                      icon: Icons.settings,
                      label: l10n.settings,
                      color: const Color(0xFF607D8B),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen()),
                        );
                      },
                    ),

                    SizedBox(height: 32.h),

                    // ✅ ALERTA DE STOCK BAJO (si existe)
                    if (productProvider.lowStockProducts.isNotEmpty) ...[
                      Text(
                        _getLowStockTitleText(l10n),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning_amber_rounded,
                                    color: Colors.red, size: 24.sp),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    _getLowStockText(l10n),
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[900],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            ...productProvider.lowStockProducts
                                .take(5)
                                .map((product) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 8.h),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        product.name,
                                        style: TextStyle(fontSize: 14.sp),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '${l10n.stock}: ${product.stock}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ BOTÓN HORIZONTAL (como antes)
  Widget _buildQuickAccessButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getHomeTitleText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Inicio';
      case 'en':
        return 'Home';
      case 'pt':
        return 'Início';
      case 'zh':
        return '首页';
      default:
        return 'Home';
    }
  }

  String _getHomeSubtitleText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Gestiona rápidamente tu negocio desde aquí.';
      case 'en':
        return 'Manage your business quickly from here.';
      case 'pt':
        return 'Gerencie seu negócio rapidamente daqui.';
      case 'zh':
        return '从这里快速管理您的业务。';
      default:
        return 'Manage your business quickly from here.';
    }
  }

  String _getQuickAccessText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Accesos rápidos';
      case 'en':
        return 'Quick access';
      case 'pt':
        return 'Acesso rápido';
      case 'zh':
        return '快速访问';
      default:
        return 'Quick access';
    }
  }

  String _getLowStockTitleText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Productos con poco stock';
      case 'en':
        return 'Low stock products';
      case 'pt':
        return 'Produtos com pouco estoque';
      case 'zh':
        return '库存不足的产品';
      default:
        return 'Low stock products';
    }
  }

  String _getLowStockText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Productos con stock bajo';
      case 'en':
        return 'Low stock products';
      case 'pt':
        return 'Produtos com estoque baixo';
      case 'zh':
        return '库存不足的产品';
      default:
        return 'Low stock products';
    }
  }
}
