import 'package:flutter/material.dart';
import 'package:auto_lube/core/services/address_service.dart';
import 'package:auto_lube/features/profile/data/models/address_model.dart';

class AddressProvider with ChangeNotifier {
  List<AddressModel> _addresses = [];
  bool _isLoading = false;
  AddressModel? _selectedAddress;

  List<AddressModel> get addresses => _addresses;
  bool get isLoading => _isLoading;
  AddressModel? get selectedAddress => _selectedAddress;

  AddressProvider() {
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await AddressService.getAddresses();
      _addresses = data.map((map) => AddressModel.fromMap(map)).toList();
      
      // Auto-select default address if none selected
      if (_addresses.isNotEmpty) {
        final defaultAddr = _addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => _addresses.first,
        );
        _selectedAddress = defaultAddr;
      } else {
        _selectedAddress = null;
      }
    } catch (e) {
      debugPrint('Error loading addresses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectAddress(AddressModel address) {
    _selectedAddress = address;
    notifyListeners();
  }

  Future<bool> addAddress(AddressModel address) async {
    final success = await AddressService.addAddress(address.toMap());
    if (success) {
      await loadAddresses();
    }
    return success;
  }

  Future<bool> updateAddress(AddressModel address) async {
    if (address.id == null) return false;
    final success = await AddressService.updateAddress(address.id!, address.toMap());
    if (success) {
      await loadAddresses();
    }
    return success;
  }

  Future<bool> deleteAddress(int id) async {
    final success = await AddressService.deleteAddress(id);
    if (success) {
      await loadAddresses();
    }
    return success;
  }

  Future<bool> setDefault(int id) async {
    final success = await AddressService.setDefault(id);
    if (success) {
      await loadAddresses();
    }
    return success;
  }
}
