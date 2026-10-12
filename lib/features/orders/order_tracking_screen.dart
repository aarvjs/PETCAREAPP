import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_network_image.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderDocId;
  final Map<String, dynamic>? initialData;

  const OrderTrackingScreen({
    super.key,
    required this.orderDocId,
    this.initialData,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  // Ordered fulfillment steps
  static const List<String> _stages = [
    'Placed',
    'Confirmed',
    'Processing',
    'Out for Delivery',
    'Delivered',
  ];

  int _getStageIndex(String status) {
    final s = status.trim().toLowerCase();
    if (s == 'placed') return 0;
    if (s == 'confirmed') return 1;
    if (s == 'processing' || s == 'preparing') return 2;
    if (s == 'out for delivery' || s == 'shipped' || s == 'dispatched') return 3;
    if (s == 'delivered' || s == 'completed') return 4;
    return 0;
  }

  bool _isCancelled(String status) {
    final s = status.trim().toLowerCase();
    return s == 'cancelled' || s == 'canceled' || s == 'rejected';
  }

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
          'Live Order Tracking',
          style: TextStyle(
            color: AppColors.mainText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
        stream: widget.orderDocId.startsWith('ORD-')
            ? FirebaseFirestore.instance
                .collection('orders')
                .where('orderId', isEqualTo: widget.orderDocId)
                .limit(1)
                .snapshots()
                .map((snap) => snap.docs.isNotEmpty ? snap.docs.first : null)
            : FirebaseFirestore.instance
                .collection('orders')
                .doc(widget.orderDocId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error loading order status: ${snapshot.error}',
                  style: const TextStyle(color: AppColors.errorRed),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting && widget.initialData == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final data = snapshot.data?.data() ?? widget.initialData ?? {};
          if (data.isEmpty) {
            return const Center(
              child: Text(
                'Order details not found.',
                style: TextStyle(color: AppColors.secondaryText),
              ),
            );
          }

          final orderId = data['orderId'] ?? widget.orderDocId;
          final status = (data['status'] ?? data['orderStatus'] ?? 'Placed').toString();
          final cancelled = _isCancelled(status);
          final currentStageIndex = _getStageIndex(status);
          final items = (data['items'] as List<dynamic>?) ?? [];
          final totalAmount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
          final subtotal = (data['subtotal'] as num?)?.toDouble() ?? totalAmount;
          final deliveryFee = (data['deliveryFee'] as num?)?.toDouble() ?? 0.0;
          final businessName = data['businessName'] ?? 'Healthy Paws Store';

          // Comprehensive Delivery Address Snapshot
          final shippingAddress = (data['shippingAddress'] is Map)
              ? Map<String, dynamic>.from(data['shippingAddress'] as Map)
              : null;
          final customerName = shippingAddress?['recipientName'] ?? data['customerName'] ?? '';
          final customerPhone = shippingAddress?['phoneNumber'] ?? data['customerPhone'] ?? '';
          final houseOrFlat = shippingAddress?['houseOrFlat'] ?? data['houseOrFlat'] ?? '';
          final streetOrLocality = shippingAddress?['streetOrLocality'] ?? data['streetOrLocality'] ?? '';
          final landmark = shippingAddress?['landmark'] ?? data['landmark'] ?? '';
          final city = shippingAddress?['city'] ?? data['city'] ?? '';
          final state = shippingAddress?['state'] ?? data['state'] ?? '';
          final pincode = shippingAddress?['pincode'] ?? data['pincode'] ?? '';
          final deliveryInstructions = shippingAddress?['deliveryInstructions'] ?? data['deliveryInstructions'] ?? '';
          final deliveryAddress = shippingAddress?['formattedAddress'] ?? data['deliveryAddress'] ?? '';

          final paymentMethod = data['paymentMethod'] ?? 'Cash on Delivery';
          final paymentStatus = data['paymentStatus'] ?? 'Pending';
          final createdAt = data['createdAt'];
          final updatedAt = data['updatedAt'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  orderId.toString(),
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
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: cancelled
                                  ? AppColors.errorContainer
                                  : AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: cancelled ? AppColors.errorRed : AppColors.onPrimaryContainer,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: AppColors.borderLight, height: 1),
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        runSpacing: 4,
                        spacing: 8,
                        children: [
                          Text(
                            'Placed on: ${_formatDate(createdAt)}',
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 11,
                            ),
                          ),
                          if (updatedAt != null)
                            Text(
                              'Updated: ${_formatDate(updatedAt)}',
                              style: const TextStyle(
                                color: AppColors.secondaryText,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Vertical Status Timeline Card
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
                      const Row(
                        children: [
                          Icon(Icons.timeline_rounded, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Order Status Timeline',
                            style: TextStyle(
                              color: AppColors.mainText,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      if (cancelled)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.errorContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.cancel_rounded, color: AppColors.errorRed, size: 24),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order Cancelled',
                                      style: TextStyle(
                                        color: AppColors.errorRed,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'This order has been cancelled. If any payment was deducted, refund will be initiated.',
                                      style: TextStyle(
                                        color: AppColors.mainText,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _stages.length,
                          itemBuilder: (context, idx) {
                            final stageName = _stages[idx];
                            final isDone = idx <= currentStageIndex;
                            final isCurrent = idx == currentStageIndex;
                            final isLast = idx == _stages.length - 1;

                            return IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Icon / Dot Column
                                  Column(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isDone
                                              ? AppColors.primary
                                              : AppColors.borderLight,
                                          border: Border.all(
                                            color: isDone ? AppColors.primary : AppColors.border,
                                            width: 2,
                                          ),
                                        ),
                                        child: isDone
                                            ? const Icon(
                                                Icons.check,
                                                size: 14,
                                                color: AppColors.white,
                                              )
                                            : null,
                                      ),
                                      if (!isLast)
                                        Expanded(
                                          child: Container(
                                            width: 2,
                                            color: isDone && idx < currentStageIndex
                                                ? AppColors.primary
                                                : AppColors.borderLight,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 14),

                                  // Stage Text Description
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            stageName,
                                            style: TextStyle(
                                              color: isDone
                                                  ? AppColors.mainText
                                                  : AppColors.mutedText,
                                              fontSize: 14,
                                              fontWeight: isCurrent
                                                  ? FontWeight.w900
                                                  : (isDone ? FontWeight.w700 : FontWeight.w500),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _getStageSubtitle(stageName),
                                            style: TextStyle(
                                              color: isDone
                                                  ? AppColors.secondaryText
                                                  : AppColors.mutedText,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Order Items Summary Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Items in this Order',
                        style: TextStyle(
                          color: AppColors.mainText,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...items.map((item) {
                        final name = item['name'] ?? 'Pet Product';
                        final qty = item['quantity'] ?? 1;
                        final priceStr = item['price'] ?? '₹0';
                        final variant = item['variant'];
                        final img = item['image'] ?? '';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.borderLight),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: AppNetworkImage(
                                    imageUrl: img,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        color: AppColors.mainText,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (variant != null && variant.toString().isNotEmpty)
                                      Text(
                                        'Size: $variant',
                                        style: const TextStyle(
                                          color: AppColors.secondaryText,
                                          fontSize: 11,
                                        ),
                                      ),
                                    Text(
                                      'Qty: $qty',
                                      style: const TextStyle(
                                        color: AppColors.secondaryText,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                priceStr,
                                style: const TextStyle(
                                  color: AppColors.mainText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      const Divider(color: AppColors.borderLight, height: 1),
                      const SizedBox(height: 12),

                      // Price Breakdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal', style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
                          Text('₹${subtotal.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.mainText, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Delivery Charge', style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
                          Text(
                            deliveryFee == 0 ? 'FREE' : '₹${deliveryFee.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: deliveryFee == 0 ? AppColors.successGreen : AppColors.mainText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: AppColors.borderLight, height: 1),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount', style: TextStyle(color: AppColors.mainText, fontSize: 15, fontWeight: FontWeight.w800)),
                          Text('₹${totalAmount.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.primary, fontSize: 17, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Delivery & Payment Details Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Delivery Address & Payment',
                        style: TextStyle(
                          color: AppColors.mainText,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (customerName.isNotEmpty)
                                  Text(
                                    customerName,
                                    style: const TextStyle(color: AppColors.mainText, fontSize: 14, fontWeight: FontWeight.w800),
                                  ),
                                if (customerPhone.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2, bottom: 4),
                                    child: Text(
                                      'Phone: $customerPhone',
                                      style: const TextStyle(color: AppColors.secondaryText, fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                const SizedBox(height: 2),
                                if (houseOrFlat.isNotEmpty || streetOrLocality.isNotEmpty) ...[
                                  Text(
                                    [houseOrFlat, streetOrLocality].where((s) => s.isNotEmpty).join(', '),
                                    style: const TextStyle(color: AppColors.mainText, fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  if (landmark.isNotEmpty)
                                    Text(
                                      'Landmark: Near $landmark',
                                      style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
                                    ),
                                  Text(
                                    [city, if (state.isNotEmpty) '$state - $pincode' else pincode].where((s) => s.isNotEmpty).join(', '),
                                    style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
                                  ),
                                ] else ...[
                                  Text(
                                    deliveryAddress.isNotEmpty ? deliveryAddress : city,
                                    style: const TextStyle(color: AppColors.mainText, fontSize: 13),
                                  ),
                                ],
                                if (deliveryInstructions.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.borderLight),
                                    ),
                                    child: Text(
                                      'Note: $deliveryInstructions',
                                      style: const TextStyle(color: AppColors.secondaryText, fontSize: 11, fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: AppColors.borderLight, height: 1),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.payment_outlined, color: AppColors.primary, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Payment: $paymentMethod ($paymentStatus)',
                              style: const TextStyle(color: AppColors.mainText, fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getStageSubtitle(String stage) {
    switch (stage) {
      case 'Placed':
        return 'We have received your order request.';
      case 'Confirmed':
        return 'The seller has confirmed your order.';
      case 'Processing':
        return 'Your package is being prepared for dispatch.';
      case 'Out for Delivery':
        return 'Your courier is on the way to your delivery address.';
      case 'Delivered':
        return 'Package was handed over at your doorstep.';
      default:
        return '';
    }
  }
}
