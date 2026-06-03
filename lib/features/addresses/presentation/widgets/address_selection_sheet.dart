import 'package:flutter/material.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/features/profile/data/models/address_model.dart';
import 'package:auto_lube/features/addresses/presentation/providers/address_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AddressSelectionSheet extends StatelessWidget {
  final AddressModel? preselectedAddress;

  const AddressSelectionSheet({super.key, this.preselectedAddress});

  static Future<AddressModel?> show(BuildContext context, {AddressModel? preselectedAddress}) async {
    return showModalBottomSheet<AddressModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddressSelectionSheet(preselectedAddress: preselectedAddress),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Consumer<AddressProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      'اختر عنوان التوصيل',
                      style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),

              Expanded(
                child: provider.isLoading && provider.addresses.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : provider.addresses.isEmpty
                        ? _buildEmptyState(context)
                        : _buildAddressesList(context, provider),
              ),

              _buildBottomBar(context, provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddressesList(BuildContext context, AddressProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: provider.addresses.length,
      itemBuilder: (context, index) {
        final address = provider.addresses[index];
        final isSelected = (provider.selectedAddress?.id == address.id);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.05) : AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: InkWell(
            onTap: () => provider.selectAddress(address),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.textTertiary,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              address.labelArabic,
                              style: GoogleFonts.cairo(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                            if (address.isDefault) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'افتراضي',
                                  style: GoogleFonts.cairo(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          address.displayAddress,
                          style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms).slideX(begin: 0.1);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_rounded, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            'لا توجد عناوين محفوظة',
            style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, AddressProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: provider.selectedAddress != null
                    ? () => Navigator.pop(context, provider.selectedAddress)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.border,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'تأكيد العنوان',
                  style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/addresses'),
              child: Text(
                'إدارة العناوين',
                style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
