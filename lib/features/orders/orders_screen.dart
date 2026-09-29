import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      {
        'id': '#ORD-8921',
        'title': 'Chicken & Green Pea Recipe + Treats',
        'status': 'In Transit',
        'date': '29 Sept 2026',
        'price': '\$38.98',
        'isAppointment': false,
      },
      {
        'id': '#APT-4012',
        'title': 'Vaccination & Wellness Checkup',
        'status': 'Confirmed',
        'date': '02 Oct 2026, 10:30 AM',
        'price': '\$49.00',
        'isAppointment': true,
      },
      {
        'id': '#ORD-7810',
        'title': 'Organic Oat Grooming Shampoo',
        'status': 'Delivered',
        'date': '24 Sept 2026',
        'price': '\$18.25',
        'isAppointment': false,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Orders & Bookings',
                style: TextStyle(
                  color: AppColors.mainText,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final ord = orders[index];
                    final isAppt = ord['isAppointment'] as bool;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.3)),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                ord['id'] as String,
                                style: const TextStyle(
                                  color: AppColors.primaryPurple,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isAppt ? AppColors.softLavender : AppColors.lightSky,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  ord['status'] as String,
                                  style: const TextStyle(
                                    color: AppColors.primaryPurple,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            ord['title'] as String,
                            style: const TextStyle(
                              color: AppColors.mainText,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                ord['date'] as String,
                                style: const TextStyle(
                                  color: AppColors.secondaryText,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                ord['price'] as String,
                                style: const TextStyle(
                                  color: AppColors.mainText,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
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
            ],
          ),
        ),
      ),
    );
  }
}
