import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/shop_service.dart';
import 'order_tracking_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final currentUid = user?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Orders & Bookings',
          style: TextStyle(
            color: AppColors.mainText,
            fontSize: 20,
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
                  'Please log in to view orders.',
                  style: TextStyle(color: AppColors.secondaryText),
                ),
              )
            : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .where('userId', isEqualTo: currentUid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.sageGreen),
                    );
                  }

                  final docs = List.of(snapshot.data?.docs ?? []);
                  // Sort newest orders first
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
                              'Your purchases and clinic bookings for ${ShopService.instance.currentBusiness?.name ?? "Healthy Paws"} will appear here.',
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
                            border: Border.all(
                              color: AppColors.border,
                              width: 1,
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
              ),
      ),
    );
  }
}
