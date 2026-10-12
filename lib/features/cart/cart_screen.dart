import 'package:flutter/material.dart';
import '../../core/cart/cart_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/shop_service.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_network_image.dart';
import '../../core/routes/app_routes.dart';
import '../orders/order_tracking_screen.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback? onContinueShopping;

  const CartScreen({
    super.key,
    this.onContinueShopping,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isSubmittingOrder = false;

  void _showCheckoutBottomSheet(BuildContext context) async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in with your phone number to complete checkout'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pushNamed(AppRoutes.login);
      return;
    }

    final profile = AuthService.instance.currentUserProfile;

    final nameController = TextEditingController(
      text: (profile?.name != null && profile!.name!.trim().isNotEmpty) ? profile.name! : '',
    );
    final phoneController = TextEditingController(
      text: (profile?.phoneNumber != null && profile!.phoneNumber.trim().isNotEmpty)
          ? profile.phoneNumber
          : (user.phoneNumber ?? ''),
    );
    final houseController = TextEditingController(
      text: (profile?.address != null && profile!.address!.trim().isNotEmpty) ? profile.address! : '',
    );
    final streetController = TextEditingController();
    final landmarkController = TextEditingController();
    final cityController = TextEditingController(
      text: (profile?.city != null && profile!.city!.trim().isNotEmpty) ? profile.city! : 'Kanpur',
    );
    final stateController = TextEditingController(text: 'Uttar Pradesh');
    final pincodeController = TextEditingController();
    final instructionsController = TextEditingController();

    String paymentMethod = 'Cash on Delivery';

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.88,
              ),
              padding: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Delivery & Checkout',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.mainText,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          icon: const Icon(Icons.close_rounded, color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Section: Recipient Information
                    const Text(
                      'Contact Information',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 8),

                    // Recipient Name
                    const Text(
                      'Recipient Full Name *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.mainText),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Rahul Sharma',
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.secondaryText, size: 20),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Phone Number
                    const Text(
                      'Contact Mobile Number *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.mainText),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: '10-digit mobile number',
                        prefixIcon: Icon(Icons.phone_outlined, color: AppColors.secondaryText, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section: Complete Address Details
                    const Text(
                      'Complete Delivery Address',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 8),

                    // House / Flat No.
                    const Text(
                      'House / Flat No., Building Name *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.mainText),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: houseController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Flat 304, Green Heights',
                        prefixIcon: Icon(Icons.home_outlined, color: AppColors.secondaryText, size: 20),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Street / Area / Locality
                    const Text(
                      'Street, Area, Locality *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.mainText),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: streetController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Main Market, Civil Lines',
                        prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.secondaryText, size: 20),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Landmark (Optional)
                    const Text(
                      'Nearby Landmark (Optional)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.mainText),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: landmarkController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Near City Hospital',
                        prefixIcon: Icon(Icons.flag_outlined, color: AppColors.secondaryText, size: 20),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // City & State Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'City / Town *',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.mainText),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: cityController,
                                decoration: const InputDecoration(
                                  hintText: 'e.g. Kanpur',
                                  prefixIcon: Icon(Icons.location_city_outlined, color: AppColors.secondaryText, size: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'State *',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.mainText),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: stateController,
                                decoration: const InputDecoration(
                                  hintText: 'Uttar Pradesh',
                                  prefixIcon: Icon(Icons.map_outlined, color: AppColors.secondaryText, size: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Postal / PIN Code
                    const Text(
                      'PIN / Postal Code *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.mainText),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: pincodeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'e.g. 208001',
                        prefixIcon: Icon(Icons.pin_drop_outlined, color: AppColors.secondaryText, size: 20),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Delivery Instructions (Optional)
                    const Text(
                      'Delivery Instructions (Optional)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.mainText),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: instructionsController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Please call before arrival',
                        prefixIcon: Icon(Icons.note_alt_outlined, color: AppColors.secondaryText, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Payment Method Options
                    const Text(
                      'Payment Method',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.mainText),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => paymentMethod = 'Cash on Delivery'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                              decoration: BoxDecoration(
                                color: paymentMethod == 'Cash on Delivery'
                                    ? AppColors.sageGreen.withValues(alpha: 0.1)
                                    : AppColors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: paymentMethod == 'Cash on Delivery'
                                      ? AppColors.sageGreen
                                      : AppColors.outlineVariant.withValues(alpha: 0.4),
                                  width: paymentMethod == 'Cash on Delivery' ? 1.8 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.payments_outlined,
                                    size: 18,
                                    color: paymentMethod == 'Cash on Delivery'
                                        ? AppColors.sageGreen
                                        : AppColors.secondaryText,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Cash on Delivery',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: paymentMethod == 'Cash on Delivery'
                                          ? AppColors.sageGreen
                                          : AppColors.mainText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => paymentMethod = 'UPI on Delivery'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                              decoration: BoxDecoration(
                                color: paymentMethod == 'UPI on Delivery'
                                    ? AppColors.sageGreen.withValues(alpha: 0.1)
                                    : AppColors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: paymentMethod == 'UPI on Delivery'
                                      ? AppColors.sageGreen
                                      : AppColors.outlineVariant.withValues(alpha: 0.4),
                                  width: paymentMethod == 'UPI on Delivery' ? 1.8 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.qr_code_2_rounded,
                                    size: 18,
                                    color: paymentMethod == 'UPI on Delivery'
                                        ? AppColors.sageGreen
                                        : AppColors.secondaryText,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'UPI / QR Code',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: paymentMethod == 'UPI on Delivery'
                                          ? AppColors.sageGreen
                                          : AppColors.mainText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter recipient name'),
                                backgroundColor: AppColors.warmCoral,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          if (phoneController.text.trim().length < 10) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a valid 10-digit mobile number'),
                                backgroundColor: AppColors.warmCoral,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          if (houseController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter house/flat and building name'),
                                backgroundColor: AppColors.warmCoral,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          if (streetController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter street or locality name'),
                                backgroundColor: AppColors.warmCoral,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          if (cityController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter city name'),
                                backgroundColor: AppColors.warmCoral,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          if (pincodeController.text.trim().length < 4) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a valid postal PIN code'),
                                backgroundColor: AppColors.warmCoral,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          Navigator.pop(ctx, true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.sageGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          'Place Order • ₹${CartService.instance.total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == true) {
      _processPlaceOrder(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        houseOrFlat: houseController.text.trim(),
        streetOrLocality: streetController.text.trim(),
        landmark: landmarkController.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim().isNotEmpty ? stateController.text.trim() : 'Uttar Pradesh',
        pincode: pincodeController.text.trim(),
        deliveryInstructions: instructionsController.text.trim(),
        paymentMethod: paymentMethod,
      );
    }
  }

  Future<void> _processPlaceOrder({
    required String name,
    required String phone,
    required String houseOrFlat,
    required String streetOrLocality,
    required String landmark,
    required String city,
    required String state,
    required String pincode,
    required String deliveryInstructions,
    required String paymentMethod,
  }) async {
    if (_isSubmittingOrder) return;

    final user = AuthService.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to complete your order'),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.of(context).pushNamed(AppRoutes.login);
      return;
    }

    setState(() {
      _isSubmittingOrder = true;
    });

    final orderTotal = CartService.instance.total;

    // Build the complete formatted address string for safe display
    final formattedAddress = [
      houseOrFlat,
      streetOrLocality,
      if (landmark.isNotEmpty) 'Near $landmark',
      city,
      if (state.isNotEmpty) '$state - $pincode' else pincode,
    ].where((s) => s.trim().isNotEmpty).join(', ');

    final shippingAddressMap = {
      'recipientName': name,
      'phoneNumber': phone,
      'houseOrFlat': houseOrFlat,
      'streetOrLocality': streetOrLocality,
      'landmark': landmark,
      'city': city,
      'state': state,
      'pincode': pincode,
      'deliveryInstructions': deliveryInstructions,
      'formattedAddress': formattedAddress,
    };

    try {
      final orderDocId = await ShopService.instance.submitOrder(
        userId: user.uid,
        customerName: name.isNotEmpty ? name : 'Valued Customer',
        customerPhone: phone.isNotEmpty ? phone : (user.phoneNumber ?? ''),
        deliveryAddress: formattedAddress,
        city: city.isNotEmpty ? city : 'Local Delivery',
        houseOrFlat: houseOrFlat,
        streetOrLocality: streetOrLocality,
        landmark: landmark,
        state: state,
        pincode: pincode,
        deliveryInstructions: deliveryInstructions,
        shippingAddress: shippingAddressMap,
        items: CartService.instance.items,
        subtotal: CartService.instance.subtotal,
        deliveryFee: CartService.instance.deliveryFee,
        totalAmount: orderTotal,
        paymentMethod: paymentMethod,
      );

      // Clear Cart after successful placement
      CartService.instance.clearCart();

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogCtx) => AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Order Confirmed!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.mainText,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Thank you! Your order of ₹${orderTotal.toStringAsFixed(0)} has been placed with ${ShopService.instance.currentBusiness?.name ?? "the shop"}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'Order ID: $orderDocId',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  widget.onContinueShopping?.call();
                },
                child: const Text(
                  'Continue Shopping',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OrderTrackingScreen(
                        orderDocId: orderDocId,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Track Order',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingOrder = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: CartService.instance,
          builder: (context, child) {
            final cartItems = CartService.instance.items;
            final isEmpty = cartItems.isEmpty;

            if (isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Pet Illustration Container
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.parchment,
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 60,
                          color: AppColors.sageGreen,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Your cart is empty',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.mainText,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Discover healthy nutrition and favorite pet supplies.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14,
                      ),
                    ),

                    const Spacer(),

                    AppButton(
                      text: 'Explore Shop',
                      onPressed: widget.onContinueShopping,
                      icon: Icons.arrow_forward_rounded,
                      backgroundColor: AppColors.sageGreen,
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Cart Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Cart',
                            style: TextStyle(
                              color: AppColors.mainText,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${CartService.instance.totalItemCount} items from ${ShopService.instance.currentBusiness?.name ?? "Healthy Paws"}',
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => CartService.instance.clearCart(),
                        child: const Text(
                          'Clear All',
                          style: TextStyle(
                            color: AppColors.warmCoral,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Cart Items List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.mainText.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: SizedBox(
                                width: 72,
                                height: 72,
                                child: AppNetworkImage(
                                  imageUrl: item.product.image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Product Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.mainText,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (item.selectedVariant != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        'Variant: ${item.selectedVariant}',
                                        style: const TextStyle(
                                          color: AppColors.secondaryText,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.effectivePriceString,
                                    style: const TextStyle(
                                      color: AppColors.sageGreen,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Quantity Stepper
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => CartService.instance.decrementQuantity(
                                    item.product.id,
                                    variant: item.selectedVariant,
                                  ),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: AppColors.parchment,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.remove,
                                      size: 16,
                                      color: AppColors.mainText,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    '${item.quantity}',
                                    style: const TextStyle(
                                      color: AppColors.mainText,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => CartService.instance.addToCart(
                                    item.product,
                                    variant: item.selectedVariant,
                                  ),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: AppColors.sageGreen,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      size: 16,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Cart Summary Footer
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.mainText.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subtotal',
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '₹${CartService.instance.subtotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColors.mainText,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Delivery',
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            CartService.instance.deliveryFee == 0
                                ? 'FREE'
                                : '₹${CartService.instance.deliveryFee.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: CartService.instance.deliveryFee == 0
                                  ? AppColors.sageGreen
                                  : AppColors.mainText,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24, thickness: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              color: AppColors.mainText,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '₹${CartService.instance.total.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColors.sageGreen,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        text: 'Proceed to Checkout',
                        isLoading: _isSubmittingOrder,
                        onPressed: () => _showCheckoutBottomSheet(context),
                        backgroundColor: AppColors.sageGreen,
                      ),
                      const SizedBox(height: 70), // Spacing for floating bottom bar
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
