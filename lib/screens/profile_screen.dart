import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/business_provider.dart';
import '../models/business_profile.dart';
import '../services/permission_handler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _businessNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  String? _logoPath;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<BusinessProvider>(context, listen: false).profile;
    _businessNameController = TextEditingController(text: profile.businessName);
    _phoneController = TextEditingController(text: profile.phone);
    _emailController = TextEditingController(text: profile.email);
    _addressController = TextEditingController(text: profile.address);
    _logoPath = profile.logoPath.isNotEmpty ? profile.logoPath : null;
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar logo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF2196F3)),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                _pickLogo(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF4CAF50)),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.pop(context);
                _pickLogo(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickLogo(ImageSource source) async {
    bool hasPermission = false;

    // Solicitar permisos según la fuente
    if (source == ImageSource.gallery) {
      hasPermission = await AppPermissionHandler.requestGalleryPermission(context);
      
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Se necesitan permisos para acceder a la galería'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
    } else if (source == ImageSource.camera) {
      hasPermission = await AppPermissionHandler.requestCameraPermission(context);
      
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Se necesitan permisos para usar la cámara'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
    }

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _logoPath = pickedFile.path;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Logo seleccionado'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error al seleccionar logo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al seleccionar logo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil del Negocio'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Stack(
                    children: [
                      Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[300]!, width: 2),
                        ),
                        child: _logoPath != null
                            ? ClipOval(
                                child: Image.file(
                                  File(_logoPath!),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo,
                                      size: 40.sp, color: Colors.grey),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Agregar Logo',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      if (_logoPath != null)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: _showImageSourceDialog,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Center(
                child: Text(
                  'Toca para cambiar el logo',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12.sp,
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              Text(
                'Información del Negocio',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _businessNameController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Negocio',
                  hintText: 'Ej: MiNegocio',
                  prefixIcon: const Icon(Icons.store),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Campo requerido' : null,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  hintText: '+51 999 999 999',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'ejemplo@email.com',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Dirección',
                  hintText: 'Calle, Ciudad',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Guardar Cambios',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final profile = BusinessProfile(
        businessName: _businessNameController.text,
        logoPath: _logoPath ?? '',
        phone: _phoneController.text,
        email: _emailController.text,
        address: _addressController.text,
      );

      Provider.of<BusinessProvider>(context, listen: false)
          .updateProfile(profile);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado exitosamente')),
      );

      Navigator.pop(context);
    }
  }
}