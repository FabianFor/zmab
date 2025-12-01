import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_typography.dart';
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
    
    // Responsive: más padding en tablets
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final horizontalPadding = isTablet ? 32.w : 20.w;
    final verticalSpacing = isTablet ? 20.h : 16.h;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header con gradiente
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: isTablet ? 28.h : 24.h,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      businessProvider.profile.businessName.isEmpty
                          ? 'MiNegocio'
                          : businessProvider.profile.businessName,
                      style: AppTypography.h2.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      l10n.businessManagement,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textLight.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido principal - SOLO ACCESOS RÁPIDOS
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: isTablet ? 32.h : 24.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título "Accesos Rápidos"
                    Text(
                      'Accesos Rápidos',
                      style: AppTypography.h4.copyWith(
                        fontSize: isTablet ? 20.sp : 18.sp,
                      ),
                    ),
                    SizedBox(height: isTablet ? 20.h : 16.h),

                    // Opciones en fila vertical con MÁS ESPACIO
                    _QuickAccessTile(
                      label: l10n.products,
                      icon: Icons.inventory_2,
                      color: AppColors.cardProductsColor,
                      isTablet: isTablet,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProductsScreen()),
                        );
                      },
                    ),
                    SizedBox(height: verticalSpacing),

                    _QuickAccessTile(
                      label: l10n.orders,
                      icon: Icons.shopping_cart,
                      color: AppColors.cardOrdersColor,
                      isTablet: isTablet,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const OrdersScreen()),
                        );
                      },
                    ),
                    SizedBox(height: verticalSpacing),

                    _QuickAccessTile(
                      label: l10n.invoices,
                      icon: Icons.receipt_long,
                      color: AppColors.cardInvoicesColor,
                      isTablet: isTablet,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const InvoicesScreen()),
                        );
                      },
                    ),
                    SizedBox(height: verticalSpacing),

                    _QuickAccessTile(
                      label: l10n.settings,
                      icon: Icons.settings,
                      color: AppColors.info,
                      isTablet: isTablet,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        );
                      },
                    ),

                    // Alerta de stock bajo (opcional, al final)
                    if (productProvider.lowStockProducts.isNotEmpty) ...[
                      SizedBox(height: isTablet ? 40.h : 32.h),
                      _buildLowStockAlert(
                        context,
                        productProvider,
                        l10n,
                        isTablet,
                      ),
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

  Widget _buildLowStockAlert(
    BuildContext context,
    ProductProvider productProvider,
    AppLocalizations l10n,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20.w : 16.w),
      decoration: BoxDecoration(
        color: AppColors.errorWithOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.errorWithOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: isTablet ? 26.sp : 24.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Productos con stock bajo',
                  style: AppTypography.h5.copyWith(
                    color: AppColors.errorDark,
                    fontSize: isTablet ? 17.sp : 16.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ...productProvider.lowStockProducts.take(5).map((product) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: isTablet ? 15.sp : 14.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    '${l10n.stock}: ${product.stock}',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                      fontSize: isTablet ? 15.sp : 14.sp,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

// Widget para cada opción de acceso rápido - CON MÁS ESPACIO
class _QuickAccessTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isTablet;
  final VoidCallback onTap;

  const _QuickAccessTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.isTablet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: isTablet ? 22.h : 18.h, // MÁS PADDING VERTICAL
            horizontal: isTablet ? 24.w : 18.w, // MÁS PADDING HORIZONTAL
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icono circular
              Container(
                width: isTablet ? 50.w : 44.w, // MÁS GRANDE EN TABLET
                height: isTablet ? 50.w : 44.w,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: isTablet ? 28.sp : 24.sp,
                ),
              ),
              SizedBox(width: isTablet ? 20.w : 16.w), // MÁS ESPACIO
              
              // Texto
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.h5.copyWith(
                    color: color,
                    fontSize: isTablet ? 18.sp : 16.sp, // MÁS GRANDE EN TABLET
                  ),
                ),
              ),
              
              // Flecha
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: isTablet ? 24.sp : 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
