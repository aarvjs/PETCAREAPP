import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'prescription_view_screen.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final String appointmentDocId;
  final Map<String, dynamic>? initialData;

  const AppointmentDetailScreen({
    super.key,
    required this.appointmentDocId,
    this.initialData,
  });

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    if (timestamp is Timestamp) {
      final dt = timestamp.toDate();
      return '${dt.day}/${dt.month}/${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    if (timestamp is String) {
      try {
        final dt = DateTime.parse(timestamp);
        return '${dt.day}/${dt.month}/${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {
        return timestamp;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.mainText, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Appointment Details',
          style: TextStyle(
            color: AppColors.mainText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .doc(appointmentDocId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error loading appointment: ${snapshot.error}',
                  style: const TextStyle(color: AppColors.errorRed),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting && initialData == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final data = snapshot.data?.data() ?? initialData ?? {};
          if (data.isEmpty) {
            return const Center(
              child: Text(
                'Appointment record not found.',
                style: TextStyle(color: AppColors.secondaryText),
              ),
            );
          }

          final appointmentId = data['appointmentId'] ?? appointmentDocId;
          final status = (data['status'] ?? 'Pending').toString();
          final isPending = status.toLowerCase() == 'pending';
          final isConfirmed = status.toLowerCase() == 'confirmed';
          final isCompleted = status.toLowerCase() == 'completed';
          final isCancelled = status.toLowerCase() == 'cancelled' || status.toLowerCase() == 'canceled';

          final businessName = data['businessName'] ?? 'Healthy Paws Clinic';
          final serviceName = data['serviceName'] ?? 'Veterinary Consultation';
          final doctorName = data['doctorName'] ?? 'Assigned Specialist';
          final petName = data['petName'] ?? 'Pet';
          final petType = data['petType'] ?? 'Dog';
          final customerName = data['customerName'] ?? '';
          final customerPhone = data['customerPhone'] ?? '';
          final appointmentDate = data['appointmentDate'] ?? '';
          final appointmentTime = data['appointmentTime'] ?? '';
          final notes = data['notes'] ?? '';
          final createdAt = data['createdAt'];

          Color statusBg = AppColors.primaryContainer;
          Color statusText = AppColors.onPrimaryContainer;
          IconData statusIcon = Icons.hourglass_top_rounded;

          if (isConfirmed) {
            statusBg = AppColors.successContainer;
            statusText = AppColors.successGreen;
            statusIcon = Icons.check_circle_rounded;
          } else if (isCompleted) {
            statusBg = AppColors.surfaceContainer;
            statusText = AppColors.primary;
            statusIcon = Icons.task_alt_rounded;
          } else if (isCancelled) {
            statusBg = AppColors.errorContainer;
            statusText = AppColors.errorRed;
            statusIcon = Icons.cancel_rounded;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Status Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appointmentId.toString(),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  businessName.toString(),
                                  style: const TextStyle(
                                    color: AppColors.secondaryText,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon, size: 14, color: statusText),
                                const SizedBox(width: 5),
                                Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    color: statusText,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(color: AppColors.borderLight, height: 1),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(Icons.event_available_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$appointmentDate at $appointmentTime',
                                  style: const TextStyle(
                                    color: AppColors.mainText,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Scheduled Consultation Slot',
                                  style: TextStyle(
                                    color: AppColors.secondaryText,
                                    fontSize: 11,
                                  ),
                                ),
                                if (createdAt != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    'Booked on: ${_formatDate(createdAt)}',
                                    style: const TextStyle(
                                      color: AppColors.secondaryText,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Patient & Doctor Information
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Appointment Details',
                        style: TextStyle(
                          color: AppColors.mainText,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),

                      _buildDetailRow(
                        icon: Icons.medical_services_outlined,
                        label: 'Clinical Service',
                        value: serviceName,
                      ),
                      const Divider(color: AppColors.borderLight, height: 20),

                      _buildDetailRow(
                        icon: Icons.person_outline,
                        label: 'Assigned Specialist',
                        value: doctorName,
                      ),
                      const Divider(color: AppColors.borderLight, height: 20),

                      _buildDetailRow(
                        icon: Icons.pets_rounded,
                        label: 'Pet Patient',
                        value: '$petName ($petType)',
                      ),
                      const Divider(color: AppColors.borderLight, height: 20),

                      _buildDetailRow(
                        icon: Icons.phone_outlined,
                        label: 'Pet Parent Contact',
                        value: '$customerName ${customerPhone.isNotEmpty ? "• $customerPhone" : ""}',
                      ),

                      if (notes.toString().isNotEmpty) ...[
                        const Divider(color: AppColors.borderLight, height: 20),
                        _buildDetailRow(
                          icon: Icons.notes_rounded,
                          label: 'Symptoms / Notes',
                          value: notes.toString(),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Live Update Notice Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sync_rounded, color: AppColors.primary, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isPending
                              ? 'Your booking is awaiting clinic confirmation. Changes made by the doctor will appear here live.'
                              : (isConfirmed
                                  ? 'Your appointment has been confirmed by the clinic. Please arrive 10 minutes before your slot.'
                                  : (isCompleted
                                      ? 'Consultation completed. The doctor has recorded the clinical treatment and issued the prescription.'
                                      : 'This appointment consultation has been ${status.toLowerCase()}.')),
                          style: const TextStyle(
                            color: AppColors.mainText,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Rejection / Cancellation Reason Card
                if (isCancelled && (data['rejectionReason'] != null || data['cancelReason'] != null)) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.cancel_outlined, color: AppColors.errorRed, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Clinic Notice / Reason',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.errorRed),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          (data['rejectionReason'] ?? data['cancelReason']).toString(),
                          style: const TextStyle(fontSize: 12, color: AppColors.mainText, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],

                // Completed Consultation: View Prescription Button
                if (isCompleted) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => _showPrescriptionBottomSheet(context, data),
                      icon: const Icon(Icons.description_rounded, size: 20),
                      label: const Text(
                        'View Prescription & Treatment Report',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 1,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPrescriptionBottomSheet(BuildContext context, Map<String, dynamic> apt) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PrescriptionViewScreen(appointmentData: apt),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.mainText,
            ),
          ),
        ),
      ],
    );
  }
}
