import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/theme/dimensions.dart';
import 'package:auto_lube/core/services/notification_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:auto_lube/core/widgets/app_network_image.dart';
import 'package:auto_lube/core/utils/image_url_helper.dart';

class MyVehiclesScreen extends StatefulWidget {
  const MyVehiclesScreen({super.key});

  @override
  State<MyVehiclesScreen> createState() => _MyVehiclesScreenState();
}

class _MyVehiclesScreenState extends State<MyVehiclesScreen> {
  List<Map<String, dynamic>> vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final vehiclesJson = prefs.getString('vehicles');
      if (vehiclesJson != null) {
        final List<dynamic> loadedVehicles = json.decode(vehiclesJson);
        vehicles = loadedVehicles
            .map((v) => Map<String, dynamic>.from(v))
            .toList();
      } else {
        vehicles = [];
      }
    } catch (e) {
      print('Error loading vehicles: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vehicles', json.encode(vehicles));
  }

  void _addVehicle(Map<String, dynamic> newVehicle) {
    setState(() {
      newVehicle['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      if (vehicles.isEmpty) {
        newVehicle['isDefault'] = true;
      }
      vehicles.add(newVehicle);
    });
    _saveVehicles();
  }

  void _updateVehicle(String id, Map<String, dynamic> updatedVehicle) {
    setState(() {
      final index = vehicles.indexWhere((v) => v['id'] == id);
      if (index != -1) {
        vehicles[index] = updatedVehicle;
      }
    });
    _saveVehicles();
  }

  void _setDefaultVehicle(String id) {
    setState(() {
      for (var vehicle in vehicles) {
        vehicle['isDefault'] = vehicle['id'] == id;
      }
    });
    _saveVehicles();
  }

  void _deleteVehicle(String id) {
    setState(() {
      vehicles.removeWhere((v) => v['id'] == id);
    });
    _saveVehicles();
  }

  void _showAddVehicleSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AddVehicleSheet(onSave: _addVehicle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: Text(
          'سيارتي',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showAddVehicleSheet,
            icon: const Icon(Icons.add, color: AppColors.primary),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : vehicles.isEmpty
          ? _buildEmptyVehicles()
          : RefreshIndicator(
              onRefresh: _loadVehicles,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: vehicles.length,
                itemBuilder: (context, index) => _VehicleCard(
                  vehicle: vehicles[index],
                  onSetDefault: _setDefaultVehicle,
                  onDelete: _deleteVehicle,
                  onUpdate: _updateVehicle,
                ),
              ),
            ),
      floatingActionButton: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: IconButton(
          onPressed: _showAddVehicleSheet,
          icon: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildEmptyVehicles() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.directions_car,
              size: 60,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لم تقم بإضافة سيارة',
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أضف سيارتك للحصول على توصيات أفضل',
            style: GoogleFonts.cairo(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 180,
            height: 48,
            child: ElevatedButton(
              onPressed: _showAddVehicleSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'إضافة سيارة',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  final Function(String) onSetDefault;
  final Function(String) onDelete;
  final Function(String, Map<String, dynamic>) onUpdate;

  const _VehicleCard({
    required this.vehicle,
    required this.onSetDefault,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final isDefault = vehicle['isDefault'] == true;
    final nextOilChange = vehicle['nextOilChange'] != null
        ? DateTime.parse(vehicle['nextOilChange'])
        : null;
    final daysUntilChange = nextOilChange?.difference(DateTime.now()).inDays;
    final needsOilChange = daysUntilChange != null && daysUntilChange <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDefault ? AppColors.primary : AppColors.border,
          width: isDefault ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          // Vehicle Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AppNetworkImage(
                      imageUrl: ImageUrlHelper.service(vehicle['image'] as String? ?? ''),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'افتراضي',
                                      style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'default') {
                                  onSetDefault(vehicle['id']);
                                } else if (value == 'delete') {
                                  onDelete(vehicle['id']);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'default',
                                  child: Text(
                                    'تعيين كافتراضي',
                                    style: GoogleFonts.cairo(),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text(
                                    'حذف',
                                    style: GoogleFonts.cairo(color: AppColors.error),
                                  ),
                                ),
                              ],
                              icon: const Icon(Icons.more_vert, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Vehicle Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${vehicle['brand']} ${vehicle['model']}',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '${vehicle['year']}',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Vehicle details chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      Icons.directions_car,
                      vehicle['color']?.toString() ?? '',
                    ),
                    _buildInfoChip(
                      Icons.confirmation_number,
                      vehicle['plate']?.toString() ?? '',
                    ),
                    _buildInfoChip(
                      Icons.speed,
                      vehicle['engineSize']?.toString() ?? '',
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                // Oil Change Status Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: needsOilChange
                        ? AppColors.error.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: needsOilChange
                          ? AppColors.error.withOpacity(0.3)
                          : AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: needsOilChange
                              ? AppColors.error.withOpacity(0.2)
                              : AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.oil_barrel,
                          color: needsOilChange
                              ? AppColors.error
                              : AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              needsOilChange
                                  ? 'حان وقت تغيير الزيت!'
                                  : 'تغيير الزيت التالي',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: needsOilChange
                                    ? AppColors.error
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              nextOilChange != null
                                  ? 'تاريخ التغيير: ${DateFormat('yyyy-MM-dd').format(nextOilChange)}'
                                  : 'لم يتم تحديد موعد',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (daysUntilChange != null && daysUntilChange > 0)
                              Text(
                                'متبقي $daysUntilChange يوم',
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (vehicle['reminderEnabled'] == true)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.notifications_active,
                            color: AppColors.success,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddVehicleSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const _AddVehicleSheet({required this.onSave});

  @override
  State<_AddVehicleSheet> createState() => _AddVehicleSheetState();
}

class _AddVehicleSheetState extends State<_AddVehicleSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _engineSizeController = TextEditingController();

  int _oilChangeInterval = 6;
  bool _reminderEnabled = true;
  final DateTime _lastOilChange = DateTime.now();

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    _engineSizeController.dispose();
    super.dispose();
  }

  void _saveVehicle() async {
    if (_formKey.currentState!.validate()) {
      final nextOilChange = DateTime.now().add(
        Duration(days: _oilChangeInterval * 30),
      );

      final vehicleId = DateTime.now().millisecondsSinceEpoch.toString();
      final vehicleName =
          '${_brandController.text.trim()} ${_modelController.text.trim()}';

      final newVehicle = {
        'id': vehicleId,
        'brand': _brandController.text.trim(),
        'model': _modelController.text.trim(),
        'year': int.tryParse(_yearController.text) ?? 2024,
        'plate': _plateController.text.trim(),
        'color': _colorController.text.trim(),
        'engineSize': _engineSizeController.text.trim(),
        'lastOilChange': _lastOilChange.toIso8601String(),
        'oilChangeInterval': _oilChangeInterval,
        'nextOilChange': nextOilChange.toIso8601String(),
        'reminderEnabled': _reminderEnabled,
        'isDefault': false,
        'image':
            'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=400&h=300&fit=crop',
      };

      // Schedule notification if reminder is enabled
      if (_reminderEnabled) {
        final daysUntilChange = nextOilChange.difference(DateTime.now()).inDays;
        await NotificationService().scheduleOilChangeReminder(
          vehicleId: vehicleId,
          vehicleName: vehicleName,
          daysUntilChange: daysUntilChange,
        );
      }

      widget.onSave(newVehicle);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'إضافة سيارة',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Basic Info Section
              Text(
                'معلومات السيارة',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              _buildTextField(
                _brandController,
                'الشركة المصنعة',
                Icons.directions_car,
                required: true,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                _modelController,
                'الموديل',
                Icons.time_to_leave,
                required: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _yearController,
                      'السنة',
                      Icons.calendar_today,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      _plateController,
                      'رقم اللوحة',
                      Icons.confirmation_number,
                      required: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _colorController,
                      'اللون',
                      Icons.palette,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      _engineSizeController,
                      'حجم المحرك',
                      Icons.speed,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Oil Change Section
              Text(
                'معلومات تغيير الزيت',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Oil Change Interval
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'فترة تغيير الزيت: $_oilChangeInterval شهر',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Slider(
                      value: _oilChangeInterval.toDouble(),
                      min: 3,
                      max: 12,
                      divisions: 9,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() => _oilChangeInterval = value.toInt());
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Reminder Switch
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.notifications,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'تفعيل التذكير',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _reminderEnabled,
                      activeThumbColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() => _reminderEnabled = value);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Add Button
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: _saveVehicle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.buttonBorderRadius,
                      ),
                    ),
                  ),
                  child: Text(
                    'إضافة السيارة',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.cairo(
            color: AppColors.textTertiary,
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: GoogleFonts.cairo(fontSize: 15, color: AppColors.textPrimary),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'هذا الحقل مطلوب';
                }
                return null;
              }
            : null,
      ),
    );
  }
}
