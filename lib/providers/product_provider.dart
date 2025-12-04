import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../core/utils/app_logger.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;
  
  // ✅ CORREGIDO: Usar Completer en lugar de busy-wait
  Completer<bool>? _saveCompleter;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalProducts => _products.length;

  List<Product> get lowStockProducts => 
      _products.where((p) => p.stock <= 5).toList();

  Future<void> loadProducts() async {
    if (_isInitialized) {
      AppLogger.info('Productos ya en caché');
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? productsJson = prefs.getString('products');

      if (productsJson != null && productsJson.isNotEmpty) {
        final List<dynamic> decodedList = json.decode(productsJson);
        _products = decodedList
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
        AppLogger.success('${_products.length} productos cargados');
      } else {
        _products = [];
        AppLogger.info('No hay productos guardados');
      }

      _isInitialized = true;
    } catch (e, stackTrace) {
      _error = 'Error al cargar productos';
      AppLogger.error(_error!, e, stackTrace);
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _saveProducts() async {
    // ✅ CORREGIDO: Usar Completer para evitar race conditions
    if (_saveCompleter != null && !_saveCompleter!.isCompleted) {
      AppLogger.info('Esperando guardado anterior');
      return await _saveCompleter!.future;
    }

    _saveCompleter = Completer<bool>();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = json.encode(
        _products.map((product) => product.toJson()).toList(),
      );
      
      final bool saved = await prefs.setString('products', encodedData);
      
      if (saved) {
        AppLogger.success('Productos guardados');
        _saveCompleter!.complete(true);
        return true;
      } else {
        AppLogger.error('Error al guardar productos');
        _saveCompleter!.complete(false);
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error crítico al guardar', e, stackTrace);
      _error = 'Error al guardar productos';
      _saveCompleter!.complete(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> addProduct(Product product) async {
    // ✅ VALIDACIONES con sanitización
    final sanitizedName = _sanitizeInput(product.name.trim());
    if (sanitizedName.isEmpty) {
      _error = 'El nombre del producto no puede estar vacío';
      notifyListeners();
      return false;
    }

    if (sanitizedName.length > 100) {
      _error = 'El nombre es demasiado largo (máx. 100 caracteres)';
      notifyListeners();
      return false;
    }

    if (product.price <= 0 || product.price > 999999999) {
      _error = 'Precio inválido';
      notifyListeners();
      return false;
    }

    if (product.stock < 0 || product.stock > 999999) {
      _error = 'Stock inválido';
      notifyListeners();
      return false;
    }

    try {
      AppLogger.info('Agregando producto');
      
      final sanitizedProduct = Product(
        id: product.id,
        name: sanitizedName,
        description: _sanitizeInput(product.description.trim()),
        price: product.price,
        stock: product.stock,
        imagePath: product.imagePath,
      );
      
      _products.add(sanitizedProduct);
      notifyListeners();
      
      final bool saved = await _saveProducts();
      
      if (saved) {
        _error = null;
        AppLogger.success('Producto agregado');
        return true;
      } else {
        _products.removeLast();
        _error = 'No se pudo guardar el producto';
        notifyListeners();
        AppLogger.error('Rollback: producto no guardado');
        return false;
      }
    } catch (e, stackTrace) {
      _products.removeLast();
      _error = 'Error al agregar producto';
      AppLogger.error(_error!, e, stackTrace);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(Product updatedProduct) async {
    // ✅ VALIDACIONES con sanitización
    final sanitizedName = _sanitizeInput(updatedProduct.name.trim());
    if (sanitizedName.isEmpty) {
      _error = 'El nombre del producto no puede estar vacío';
      notifyListeners();
      return false;
    }

    if (sanitizedName.length > 100) {
      _error = 'El nombre es demasiado largo';
      notifyListeners();
      return false;
    }

    if (updatedProduct.price <= 0 || updatedProduct.price > 999999999) {
      _error = 'Precio inválido';
      notifyListeners();
      return false;
    }

    if (updatedProduct.stock < 0 || updatedProduct.stock > 999999) {
      _error = 'Stock inválido';
      notifyListeners();
      return false;
    }

    try {
      final index = _products.indexWhere((p) => p.id == updatedProduct.id);
      if (index == -1) {
        _error = 'Producto no encontrado';
        notifyListeners();
        return false;
      }

      final oldProduct = _products[index];
      
      final sanitizedProduct = Product(
        id: updatedProduct.id,
        name: sanitizedName,
        description: _sanitizeInput(updatedProduct.description.trim()),
        price: updatedProduct.price,
        stock: updatedProduct.stock,
        imagePath: updatedProduct.imagePath,
      );
      
      _products[index] = sanitizedProduct;
      notifyListeners();
      
      final bool saved = await _saveProducts();
      
      if (saved) {
        _error = null;
        AppLogger.success('Producto actualizado');
        return true;
      } else {
        _products[index] = oldProduct;
        _error = 'No se pudo guardar la actualización';
        notifyListeners();
        AppLogger.error('Rollback: actualización no guardada');
        return false;
      }
    } catch (e, stackTrace) {
      _error = 'Error al actualizar producto';
      AppLogger.error(_error!, e, stackTrace);
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      final index = _products.indexWhere((p) => p.id == productId);
      if (index == -1) {
        _error = 'Producto no encontrado';
        notifyListeners();
        return;
      }

      final removed = _products.removeAt(index);
      notifyListeners();
      
      final bool saved = await _saveProducts();
      
      if (saved) {
        _error = null;
        AppLogger.success('Producto eliminado');
      } else {
        _products.insert(index, removed);
        _error = 'No se pudo eliminar el producto';
        notifyListeners();
        AppLogger.error('Rollback: producto no eliminado');
      }
    } catch (e, stackTrace) {
      _error = 'Error al eliminar producto';
      AppLogger.error(_error!, e, stackTrace);
      notifyListeners();
    }
  }

  Future<bool> updateStock(String productId, int newStock) async {
    if (newStock < 0 || newStock > 999999) {
      _error = 'Stock inválido';
      notifyListeners();
      return false;
    }

    try {
      final index = _products.indexWhere((p) => p.id == productId);
      if (index == -1) {
        _error = 'Producto no encontrado';
        notifyListeners();
        return false;
      }

      final oldStock = _products[index].stock;
      
      _products[index] = _products[index].copyWith(stock: newStock);
      notifyListeners();
      
      final bool saved = await _saveProducts();
      
      if (saved) {
        _error = null;
        AppLogger.success('Stock actualizado');
        return true;
      } else {
        _products[index] = _products[index].copyWith(stock: oldStock);
        notifyListeners();
        AppLogger.error('Rollback: stock no actualizado');
        return false;
      }
    } catch (e, stackTrace) {
      _error = 'Error al actualizar stock';
      AppLogger.error(_error!, e, stackTrace);
      notifyListeners();
      return false;
    }
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    
    final lowerQuery = _sanitizeInput(query.toLowerCase());
    return _products.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
             product.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      AppLogger.warning('Producto no encontrado');
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> reload() async {
    _isInitialized = false;
    await loadProducts();
  }

  // ✅ SANITIZACIÓN DE INPUTS
  String _sanitizeInput(String input) {
    // Remover caracteres de control
    input = input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    // Limitar longitud
    if (input.length > 500) {
      input = input.substring(0, 500);
    }
    return input;
  }
}