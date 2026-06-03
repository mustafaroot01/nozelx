import 'package:flutter/material.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/features/profile/data/models/address_model.dart';
import 'package:auto_lube/features/addresses/presentation/providers/address_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<AddressProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              // Main Content
              RefreshIndicator(
                onRefresh: provider.loadAddresses,
                color: AppColors.primary,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    const SliverToBoxAdapter(child: SizedBox(height: 110)),

                    if (provider.isLoading && provider.addresses.isEmpty)
                      _buildLoadingList()
                    else if (provider.addresses.isEmpty)
                      _buildEmptyState(context)
                    else
                      _buildAddressesList(context, provider),

                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),

              // Glassmorphic Header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildHeader(context),
              ),

              // Add Button
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: _buildAddButton(context, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background.withOpacity(0.9),
            AppColors.background.withOpacity(0.0),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.glassBorder, width: 1),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.background.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'عناويني',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2);
  }

  Widget _buildAddressesList(BuildContext context, AddressProvider provider) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final address = provider.addresses[index];
            return _buildAddressCard(context, provider, address, index);
          },
          childCount: provider.addresses.length,
        ),
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, AddressProvider provider, AddressModel address, int index) {
    final bool isDefault = address.isDefault;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDefault ? AppColors.primary.withOpacity(0.5) : AppColors.border,
          width: isDefault ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDefault ? AppColors.primary : AppColors.shadowColor).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => provider.selectAddress(address),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isDefault ? AppColors.primary : AppColors.textTertiary).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _getIconForLabel(address.label),
                      color: isDefault ? AppColors.primary : AppColors.textTertiary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address.labelArabic,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (isDefault)
                          Text(
                            'العنوان الافتراضي',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildActionMenu(context, provider, address),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              _buildInfoRow(Icons.person_outline_rounded, address.fullName),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.phone_outlined, address.phoneNumber),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.location_on_outlined, address.displayAddress),
              if (address.notes != null && address.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow(Icons.note_outlined, address.notes!, isItalic: true),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: (index * 100).ms).slideX(begin: 0.1);
  }

  Widget _buildInfoRow(IconData icon, String text, {bool isItalic = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.4,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionMenu(BuildContext context, AddressProvider provider, AddressModel address) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: AppColors.textTertiary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (value) {
        if (value == 'edit') {
          _showAddressForm(context, provider, address: address);
        } else if (value == 'delete') {
          _showDeleteConfirm(context, provider, address);
        } else if (value == 'default') {
          if (address.id != null) provider.setDefault(address.id!);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              const Icon(Icons.edit_outlined, size: 18),
              const SizedBox(width: 10),
              Text('تعديل', style: GoogleFonts.cairo()),
            ],
          ),
        ),
        if (!address.isDefault)
          PopupMenuItem(
            value: 'default',
            child: Row(
              children: [
                const Icon(Icons.star_outline_rounded, size: 18, color: AppColors.warning),
                const SizedBox(width: 10),
                Text('تعيين كافتراضي', style: GoogleFonts.cairo()),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
              const SizedBox(width: 10),
              Text('حذف', style: GoogleFonts.cairo(color: AppColors.error)),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'home':
      case 'المنزل':
        return Icons.home_rounded;
      case 'work':
      case 'العمل':
        return Icons.work_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  Widget _buildAddButton(BuildContext context, AddressProvider provider) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _showAddressForm(context, provider),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_location_alt_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'إضافة عنوان جديد',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_off_rounded, size: 80, color: AppColors.textTertiary),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 32),
            Text(
              'لا توجد عناوين بعد',
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'أضف عنوان توصيل ليسهل عليك إتمام طلباتك بسرعة في المرات القادمة',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingList() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Container(
            height: 150,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(24),
            ),
          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms),
          childCount: 3,
        ),
      ),
    );
  }

  void _showAddressForm(BuildContext context, AddressProvider provider, {AddressModel? address}) {
    final bool isEdit = address != null;
    final nameController = TextEditingController(text: isEdit ? address.fullName : '');
    final phoneController = TextEditingController(text: isEdit ? address.phoneNumber : '');
    final cityController = TextEditingController(text: isEdit ? address.city : '');
    final addressController = TextEditingController(text: isEdit ? address.address : '');
    final districtController = TextEditingController(text: isEdit ? address.district : '');
    final notesController = TextEditingController(text: isEdit ? address.notes ?? '' : '');
    
    String selectedLabel = isEdit ? address.label : 'Home';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isEdit ? 'تعديل العنوان' : 'إضافة عنوان جديد',
                  style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 24),
                
                // Label Chips
                Row(
                  children: [
                    _buildLabelChip('Home', 'المنزل', Icons.home_rounded, selectedLabel, (v) => setModalState(() => selectedLabel = v)),
                    const SizedBox(width: 8),
                    _buildLabelChip('Work', 'العمل', Icons.work_rounded, selectedLabel, (v) => setModalState(() => selectedLabel = v)),
                    const SizedBox(width: 8),
                    _buildLabelChip('Other', 'أخرى', Icons.location_on_rounded, selectedLabel, (v) => setModalState(() => selectedLabel = v)),
                  ],
                ),
                const SizedBox(height: 24),

                _buildTextField('الاسم الكامل', Icons.person_outline_rounded, nameController),
                const SizedBox(height: 16),
                _buildTextField('رقم الهاتف', Icons.phone_outlined, phoneController, keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                _buildTextField('المدينة', Icons.location_city_outlined, cityController),
                const SizedBox(height: 16),
                _buildTextField('العنوان (شارع، بناية)', Icons.map_outlined, addressController),
                const SizedBox(height: 16),
                _buildTextField('الحي / المنطقة', Icons.apartment_outlined, districtController),
                const SizedBox(height: 16),
                _buildTextField('ملاحظات إضافية', Icons.note_outlined, notesController),
                
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isEmpty || phoneController.text.isEmpty || cityController.text.isEmpty || addressController.text.isEmpty) {
                        return;
                      }

                      final newAddress = AddressModel(
                        id: address?.id,
                        userId: address?.userId ?? 0, // Provider will fill this if 0
                        label: selectedLabel,
                        fullName: nameController.text,
                        phoneNumber: phoneController.text,
                        city: cityController.text,
                        address: addressController.text,
                        district: districtController.text,
                        notes: notesController.text,
                        isDefault: address?.isDefault ?? false,
                      );

                      bool success;
                      if (isEdit) {
                        success = await provider.updateAddress(newAddress);
                      } else {
                        success = await provider.addAddress(newAddress);
                      }

                      if (success && context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      isEdit ? 'حفظ التعديلات' : 'إضافة العنوان',
                      style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabelChip(String value, String label, IconData icon, String selectedValue, Function(String) onSelected) {
    final bool isSelected = value == selectedValue;
    return GestureDetector(
      onTap: () => onSelected(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.cairo(fontSize: 14),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: GoogleFonts.cairo(fontSize: 14, color: AppColors.textTertiary),
          prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, AddressProvider provider, AddressModel address) {
    if (address.id == null) return;
    
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text('حذف العنوان؟', style: GoogleFonts.cairo(fontWeight: FontWeight.w900)),
          content: Text('هل أنت متأكد من رغبتك في حذف هذا العنوان؟ لا يمكن التراجع عن هذا الإجراء.', style: GoogleFonts.cairo()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء', style: GoogleFonts.cairo(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                provider.deleteAddress(address.id!);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('حذف', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
