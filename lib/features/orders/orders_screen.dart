import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/business_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/shop_service.dart';
import '../clinic/appointment_detail_screen.dart';
import '../clinic/clinic_screen.dart';
import '../clinic/prescription_view_screen.dart';
import 'order_tracking_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _selectedTab = 0; // 0 = Appointments / Prescriptions, 1 = Orders

  @override
  void initState() {
    super.initState();
    final exp = ShopService.instance.experience;
    // Default to store orders only if ecommerceOnly mode
    if (exp == AppExperience.ecommerceOnly) {
      _selectedTab = 1;
    } else {
      _selectedTab = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final currentUid = user?.uid ?? '';
    final exp = ShopService.instance.experience;
    final isClinicOnly = exp == AppExperience.clinicOnly;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isClinicOnly ? 'My Appointments & Prescriptions' : 'My Bookings & Orders',
          style: const TextStyle(
            color: AppColors.mainText,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.mainText),
      ),
      body: SafeArea(
        child: currentUid.isEmpty
            ? const Center(
                child: Text(
                  'Please log in to view your consultations and orders.',
                  style: TextStyle(color: AppColors.secondaryText),
                ),
              )
            : Column(
                children: [
                  // Tab Switcher (Appointments vs Orders) if not strictly clinic-only
                  if (!isClinicOnly)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTab = 0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _selectedTab == 0 ? const Color(0xFF0284C7) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.calendar_month_rounded,
                                      size: 16,
                                      color: _selectedTab == 0 ? AppColors.white : AppColors.secondaryText,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Clinic Bookings',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: _selectedTab == 0 ? AppColors.white : AppColors.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTab = 1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _selectedTab == 1 ? AppColors.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 16,
                                      color: _selectedTab == 1 ? AppColors.white : AppColors.secondaryText,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Store Orders',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: _selectedTab == 1 ? AppColors.white : AppColors.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Expanded(
                    child: _selectedTab == 0
                        ? _buildAppointmentsStream(currentUid)
                        : _buildOrdersStream(currentUid),
                  ),
                ],
              ),
      ),
    );
  }

  /// Real-time stream of user's clinic appointments & prescriptions
  Widget _buildAppointmentsStream(String currentUid) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: currentUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF0284C7)));
        }

        final docs = List.of(snapshot.data?.docs ?? []);
        // Sort newest appointments first
        docs.sort((a, b) {
          final aData = a.data();
          final bData = b.data();
          final aDate = (aData['appointmentDate'] ?? aData['date'] ?? '').toString();
          final bDate = (bData['appointmentDate'] ?? bData['date'] ?? '').toString();
          if (aDate != bDate) return bDate.compareTo(aDate);
          return (bData['appointmentTime'] ?? '').toString().compareTo((aData['appointmentTime'] ?? '').toString());
        });

        if (docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppColors.parchment,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      size: 38,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No appointments scheduled',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.mainText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your veterinary consultations, doctor visits and official prescriptions for ${ShopService.instance.currentBusiness?.name ?? "Healthy Paws Clinic"} will appear here.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ClinicScreen()),
                      );
                    },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Book Consultation Now', style: TextStyle(fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            final aptId = (data['appointmentId'] ?? doc.id).toString();
            final petName = (data['petName'] ?? 'Pet Patient').toString();
            final petType = (data['petType'] ?? data['species'] ?? 'Pet').toString();
            final doctorName = (data['doctorName'] ?? 'Doctor Specialist').toString();
            final date = (data['appointmentDate'] ?? data['date'] ?? 'TBD').toString();
            final time = (data['appointmentTime'] ?? data['time'] ?? 'TBD').toString();
            final serviceName = (data['serviceName'] ?? 'Veterinary Care').toString();
            final status = (data['status'] ?? 'Pending').toString();
            final isCompleted = status.toLowerCase() == 'completed';
            final hasPrescription = isCompleted || data['treatment'] != null || data['treatmentId'] != null;
            final regNo = (data['petRegistrationNumber'] ?? (data['treatment'] is Map ? data['treatment']['petRegistrationNumber'] : null) ?? 'HPPC/P/01').toString();

            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AppointmentDetailScreen(
                      appointmentDocId: doc.id,
                      initialData: data,
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isCompleted ? const Color(0xFFBAE6FD) : AppColors.border,
                    width: isCompleted ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mainText.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar: Ref and Status
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                aptId,
                                style: const TextStyle(
                                  color: Color(0xFF0284C7),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'REG: $regNo',
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? const Color(0xFFDCFCE7)
                                : (status.toLowerCase().contains('cancel')
                                    ? AppColors.errorContainer
                                    : AppColors.primaryContainer),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: isCompleted
                                  ? const Color(0xFF166534)
                                  : (status.toLowerCase().contains('cancel')
                                      ? AppColors.errorRed
                                      : AppColors.onPrimaryContainer),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Pet and Service Details
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F9FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE0F2FE)),
                          ),
                          child: const Icon(
                            Icons.pets_rounded,
                            color: Color(0xFF0284C7),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$petName ($petType)',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.mainText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                serviceName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondaryText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    // Date & Doctor Info
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.secondaryText),
                              const SizedBox(width: 6),
                              Text(
                                '$date • $time',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.mainText),
                              ),
                            ],
                          ),
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.person_rounded, size: 14, color: AppColors.secondaryText),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    doctorName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Prescription Badge & Action
                    if (hasPrescription) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified_rounded, size: 16, color: Color(0xFF16A34A)),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Official Prescription & Medical Report Ready',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showPrescriptionBottomSheet(context, data),
                              icon: const Icon(Icons.description_rounded, size: 16),
                              label: const Text('View Prescription Slip', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0284C7),
                                foregroundColor: AppColors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AppointmentDetailScreen(
                                    appointmentDocId: doc.id,
                                    initialData: data,
                                  ),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.mainText,
                              side: const BorderSide(color: AppColors.border),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'View Case Details →',
                          style: TextStyle(
                            color: const Color(0xFF0284C7),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Official Prescription Bottom Sheet matching AppointmentDetailScreen
  void _showPrescriptionBottomSheet(BuildContext context, Map<String, dynamic> apt) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PrescriptionViewScreen(appointmentData: apt),
      ),
    );
  }

  /// Real-time stream of user's store orders
  Widget _buildOrdersStream(String currentUid) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: currentUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.sageGreen));
        }

        final docs = List.of(snapshot.data?.docs ?? []);
        docs.sort((a, b) {
          final aData = a.data();
          final bData = b.data();
          final aTime = (aData['createdAt'] as Timestamp?)?.toDate().millisecondsSinceEpoch ?? 0;
          final bTime = (bData['createdAt'] as Timestamp?)?.toDate().millisecondsSinceEpoch ?? 0;
          return bTime.compareTo(aTime);
        });

        if (docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppColors.parchment,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      size: 40,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No orders placed yet',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.mainText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your product purchases from ${ShopService.instance.currentBusiness?.name ?? "Healthy Paws"} will appear here.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final orderId = data['orderId'] ?? docs[index].id;
            final status = (data['status'] ?? data['orderStatus'] ?? 'Placed').toString();
            final totalAmount = data['totalAmount'] ?? 0;
            final businessName = data['businessName'] ?? 'Healthy Paws Store';
            final items = (data['items'] as List<dynamic>?) ?? [];
            final itemsSummary = items.isNotEmpty
                ? items.map((i) => '${i['name'] ?? 'Item'} (x${i['quantity'] ?? 1})').join(', ')
                : 'Order Items';

            final docId = docs[index].id;
            final isCancelled = status.toLowerCase().contains('cancel');
            final isDelivered = status.toLowerCase().contains('deliver');

            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OrderTrackingScreen(
                      orderDocId: docId,
                      initialData: data,
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mainText.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            orderId.toString(),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isCancelled
                                ? AppColors.errorContainer
                                : (isDelivered ? AppColors.successContainer : AppColors.primaryContainer),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            status.toString().toUpperCase(),
                            style: TextStyle(
                              color: isCancelled
                                  ? AppColors.errorRed
                                  : (isDelivered ? AppColors.successGreen : AppColors.onPrimaryContainer),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      itemsSummary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.mainText,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            businessName.toString(),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹${(totalAmount as num).toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppColors.mainText,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Track Order →',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
