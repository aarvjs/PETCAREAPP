import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Authentic Doctor's Prescription View Screen
/// Modeled after the official clinical letterhead format (Prescription Format.docx / Sample PDF)
/// Designed without any fixed unconstrained horizontal rows to eliminate any RenderFlex overflow.
class PrescriptionViewScreen extends StatelessWidget {
  final Map<String, dynamic> appointmentData;

  const PrescriptionViewScreen({
    super.key,
    required this.appointmentData,
  });

  @override
  Widget build(BuildContext context) {
    final treatment = (appointmentData['treatment'] is Map)
        ? Map<String, dynamic>.from(appointmentData['treatment'] as Map)
        : <String, dynamic>{};

    final aptId = (appointmentData['appointmentId'] ?? appointmentData['id'] ?? 'APT-0000').toString();
    final petName = (treatment['petName'] ?? appointmentData['petName'] ?? 'Patient').toString();
    final breed = (treatment['breed'] ?? appointmentData['breed'] ?? appointmentData['petType'] ?? 'Canine').toString();
    final species = (treatment['species'] ?? appointmentData['petType'] ?? 'Dog').toString();
    final age = (treatment['age'] ?? appointmentData['age'] ?? 'N/A').toString();
    final gender = (treatment['gender'] ?? appointmentData['gender'] ?? 'N/A').toString();
    final regNo = (treatment['petRegistrationNumber'] ?? appointmentData['petRegistrationNumber'] ?? 'HPPC/P/01').toString();
    final date = (treatment['consultationDate'] ?? appointmentData['appointmentDate'] ?? 'Today').toString();

    final ownerName = (treatment['ownerName'] ?? appointmentData['customerName'] ?? appointmentData['ownerName'] ?? 'Pet Parent').toString();
    final ownerPhone = (treatment['ownerPhone'] ?? appointmentData['customerPhone'] ?? appointmentData['ownerPhone'] ?? '').toString();
    final ownerAddress = (treatment['ownerAddress'] ?? appointmentData['customerAddress'] ?? 'Kanpur').toString();

    final doctorName = (treatment['doctorName'] ?? appointmentData['doctorName'] ?? 'Dr. Ashwani Kumar Singh').toString();
    final doctorReg = (treatment['doctorRegdNo'] ?? 'UPVC 6394').toString();
    final doctorQual = (treatment['doctorQualifications'] ?? 'B.V.Sc & A.H (RAJUVAS, Bikaner)').toString();

    final history = (treatment['history'] ?? appointmentData['symptoms'] ?? appointmentData['notes'] ?? '').toString();
    final temp = (treatment['temperature'] ?? '').toString();
    final signs = (treatment['clinicalSigns'] ?? '').toString();
    final diagnosis = (treatment['diagnosis'] ?? appointmentData['diagnosis'] ?? 'Clinical Evaluation').toString();
    final weight = (treatment['weight'] ?? '').toString();
    final prognosis = (treatment['prognosis'] ?? 'Guarded').toString();
    final nextVisit = (treatment['nextVisitDate'] ?? appointmentData['nextVisitDate'] ?? '').toString();
    final advice = (treatment['advice'] ?? 'Keep warm, bland soft diet. Maintain clean fresh drinking water.').toString();

    final administered = (treatment['administeredItems'] is List) ? (treatment['administeredItems'] as List) : [];
    final prescribed = (treatment['prescribedItems'] is List) ? (treatment['prescribedItems'] as List) : [];

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Light paper desk background
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Official Medical Prescription',
              style: TextStyle(
                color: AppColors.mainText,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '$aptId • $petName',
              style: const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.mainText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Clinic & Doctor Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor & Clinic Credentials
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: const Text(
                              'An ISO 9001:2015 Certified Clinic',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF047857),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            doctorName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            doctorQual,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF334155),
                            ),
                          ),
                          Text(
                            'Regd. No. $doctorReg',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                          const SizedBox(height: 1),
                          const Text(
                            '(LMIVA, LMAPPA-UP, LMVAI, LMPLRC-NVC, MCACT-AWBI)',
                            style: TextStyle(
                              fontSize: 9.5,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Clinic Emblem / Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.local_hospital_rounded,
                          color: Color(0xFF16A34A),
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(color: Color(0xFF0F172A), thickness: 1.5, height: 1.5),
                const SizedBox(height: 2),
                const Divider(color: Color(0xFF94A3B8), thickness: 0.8, height: 0.8),
                const SizedBox(height: 10),

                // 2. Patient & Owner Demographics Strip (Italicized Serif look)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pet Demographics
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildDemographicPill('Pet Name', '$petName ($breed)'),
                          _buildDemographicPill('Species', species),
                          _buildDemographicPill('Age', age),
                          _buildDemographicPill('Gender', gender),
                          _buildDemographicPill('Date', '$date (V-1)'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Owner Demographics
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildDemographicPill('Owner', ownerName),
                          if (ownerAddress.isNotEmpty) _buildDemographicPill('Address', ownerAddress),
                          if (ownerPhone.isNotEmpty) _buildDemographicPill('Mobile', ownerPhone),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0284C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'REG: $regNo',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ref: $aptId',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                const Divider(color: Color(0xFF94A3B8), thickness: 0.8, height: 0.8),
                const SizedBox(height: 12),

                // 3. Official Two-Column Medical Examination & Prescription Layout
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT COLUMN: Clinical Examination & Vitals (38% width)
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'EXAMINATION',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                              color: Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 8),

                          if (history.isNotEmpty) ...[
                            _buildClinicalLine('H/O:', history),
                            const SizedBox(height: 6),
                          ],
                          if (temp.isNotEmpty) ...[
                            _buildClinicalLine('Temp:', temp.endsWith('F') ? temp : '$temp F'),
                            const SizedBox(height: 6),
                          ],
                          if (signs.isNotEmpty) ...[
                            _buildClinicalLine('Signs:', signs),
                            const SizedBox(height: 6),
                          ],
                          _buildClinicalLine('Diagnosis:', diagnosis, isBold: true),
                          const SizedBox(height: 6),
                          if (weight.isNotEmpty) ...[
                            _buildClinicalLine('Weight:', weight.toLowerCase().contains('kg') ? weight : '$weight Kgs'),
                            const SizedBox(height: 6),
                          ],
                          // Prognosis Guarded in PURE RED as in template
                          _buildClinicalLine('Prognosis:', prognosis, isRed: true),
                          const SizedBox(height: 6),
                          if (nextVisit.isNotEmpty) ...[
                            _buildClinicalLine('Next Visit:', nextVisit),
                          ],
                        ],
                      ),
                    ),

                    // Vertical Divider Rule
                    Container(
                      width: 1.2,
                      height: 240,
                      color: const Color(0xFFCBD5E1),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                    ),

                    // RIGHT COLUMN: Rx Symbol & Prescriptions (62% width)
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Classic Rx Symbol
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              const Text(
                                '℞',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'serif',
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'PRESCRIPTION',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                  color: const Color(0xFF475569).withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // In-Clinic Injections / Treatments
                          if (administered.isNotEmpty) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFBBF7D0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Administered in Clinic:',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF15803D),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  ...administered.map((item) {
                                    final m = (item is Map) ? item : {};
                                    final name = (m['name'] ?? m['medicineName'] ?? 'Injection').toString();
                                    final dose = (m['dosage'] ?? '').toString();
                                    final route = (m['route'] ?? 'IM').toString();
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Text(
                                        '• Inj. $name $dose $route'.trim(),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          // Take-Home Prescriptions
                          if (prescribed.isNotEmpty) ...[
                            ...prescribed.asMap().entries.map((entry) {
                              final idx = entry.key + 1;
                              final m = (entry.value is Map) ? entry.value : {};
                              final name = (m['name'] ?? m['medicineName'] ?? 'Medicine').toString();
                              final dosage = (m['dosage'] ?? '').toString();
                              final inst = (m['instructions'] ?? '').toString();
                              final qty = (m['quantity'] ?? '').toString();

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$idx. $name $dosage'.trim(),
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    if (inst.isNotEmpty)
                                      Text(
                                        '    Directions: $inst',
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          color: Color(0xFF475569),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    if (qty.isNotEmpty)
                                      Text(
                                        '    Quantity: $qty',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }),
                          ] else if (administered.isEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'General supportive care & clinical observation as advised.',
                                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF64748B)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(color: Color(0xFFCBD5E1), thickness: 1),
                const SizedBox(height: 8),

                // 4. Clinical Advice Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEFCE8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFEF08A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ADVICE & INSTRUCTIONS:',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: Color(0xFF854D0E),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        advice.isNotEmpty ? advice : 'Blood Profile: Basic + BP + RBS. Keep warm, clean drinking water.',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF713F12),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 5. Signature & Stamp Box
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Official Stamp
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF0284C7), width: 1.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HEALTHY PAWS PET CLINIC',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                          Text(
                            'Authorized Consultation • $date',
                            style: const TextStyle(
                              fontSize: 8,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Doctor Sign Line
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 140,
                          height: 1,
                          color: const Color(0xFF0F172A),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctorName,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Reg. No. $doctorReg',
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE2E8F0), thickness: 1),
                const SizedBox(height: 6),

                // 6. Clinic Footer & Legal Disclaimer
                const Center(
                  child: Text(
                    'Healthy Paws Pet Clinic',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                const Center(
                  child: Text(
                    '620/112, W Block, Keshav Nagar (Near Shri Guest House), Kanpur, UP - 208014',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 9.5, color: Color(0xFF475569)),
                  ),
                ),
                const Center(
                  child: Text(
                    'Emergency Helpline: 7568308808, 9460674066 • Timings: 10:30AM - 01:00PM, 05:00PM - 09:00PM',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Disclaimer: This prescription is issued based on clinical judgment and available investigations. Treatment outcome may vary depending on the patient’s condition and response to therapy. Follow-up evaluation is advised as recommended.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8.5,
                    color: Color(0xFF94A3B8),
                    fontStyle: FontStyle.italic,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemographicPill(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 11, color: Color(0xFF334155)),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalLine(String label, String value, {bool isBold = false, bool isRed = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isBold || isRed ? FontWeight.w900 : FontWeight.w700,
            color: isRed
                ? const Color(0xFFDC2626) // Pure red for Prognosis Guarded
                : (isBold ? const Color(0xFF0F172A) : const Color(0xFF334155)),
          ),
        ),
      ],
    );
  }
}
