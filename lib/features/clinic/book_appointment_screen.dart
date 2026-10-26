import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/doctor_model.dart';
import '../../core/models/pet_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/pet_service.dart';
import '../../core/services/shop_service.dart';
import 'appointment_detail_screen.dart';
import 'pet_registration_screen.dart';

class BookAppointmentScreen extends StatefulWidget {
  final PetModel? pet;
  final String? preSelectedService;
  final double? servicePrice;

  const BookAppointmentScreen({
    super.key,
    this.pet,
    this.preSelectedService,
    this.servicePrice,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  // Calendar & Slot selection
  DateTime _selectedDate = DateTime.now();
  late DateTime _displayedMonth;
  String? _selectedTimeSlot;
  List<String> _availableSlots = [];
  bool _isLoadingSlots = false;

  DoctorModel? _selectedDoctor;
  List<DoctorModel> _clinicDoctors = [];

  // Patient Pet Selection
  PetModel? _selectedPet;
  List<PetModel> _myPets = [];
  bool _isLoadingPets = false;

  // Primary Concern & Symptoms
  String _selectedCategory = 'General Health Checkup';
  late final TextEditingController _reasonController;
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Owner details (auto-loaded from profile)
  String _ownerName = '';
  String _ownerPhone = '';
  String _ownerAddress = '';

  bool _isSubmitting = false;
  String? _errorMessage;

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  static const List<String> _weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final List<Map<String, dynamic>> _concernCategories = [
    {'label': 'General Health Checkup', 'icon': Icons.medical_services_outlined},
    {'label': 'Vaccination & Deworming', 'icon': Icons.shield_outlined},
    {'label': 'Digestive / Vomiting / Diarrhea', 'icon': Icons.healing_outlined},
    {'label': 'Skin / Itching / Allergies', 'icon': Icons.pets_outlined},
    {'label': 'Eye, Ear or Dental Issue', 'icon': Icons.visibility_outlined},
    {'label': 'Limping / Injury / Bone Issue', 'icon': Icons.accessibility_new_outlined},
    {'label': 'Urgent / Emergency Consultation', 'icon': Icons.emergency_outlined},
    {'label': 'Other / Custom Reason', 'icon': Icons.edit_note_rounded},
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month, 1);
    
    _selectedPet = widget.pet;
    if (widget.preSelectedService != null && widget.preSelectedService!.trim().isNotEmpty) {
      _selectedCategory = widget.preSelectedService!.trim();
      _reasonController = TextEditingController(text: _selectedCategory);
    } else {
      _reasonController = TextEditingController(text: _selectedCategory);
    }

    _loadInitialData();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _symptomsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final user = AuthService.instance.currentUser;
    final profile = AuthService.instance.currentUserProfile;

    if (widget.pet != null) {
      _selectedPet = widget.pet;
      _ownerName = (profile?.name ?? user?.displayName ?? widget.pet!.ownerName).toString();
      _ownerPhone = (profile?.phoneNumber ?? user?.phoneNumber ?? widget.pet!.contactNumber).toString();
      _ownerAddress = (profile?.address ?? widget.pet!.ownerAddress).toString();
    } else {
      _ownerName = (profile?.name ?? user?.displayName ?? '').toString();
      _ownerPhone = (profile?.phoneNumber ?? user?.phoneNumber ?? '').toString();
      _ownerAddress = (profile?.address ?? '').toString();
      _fetchUserPets();
    }

    // Load Doctors for this clinic
    final shopService = ShopService.instance;
    _clinicDoctors = shopService.doctors;
    if (_clinicDoctors.isNotEmpty) {
      _selectedDoctor = _clinicDoctors.first;
    } else {
      _selectedDoctor = const DoctorModel(
        id: 'WcWmpKLJImU9QtBZA5C7MGWe8hA2',
        fullName: 'Dr. Ashwani Kumar Singh',
        specialization: 'Veterinary Physician & Surgeon',
        qualification: 'B.V.Sc & A.H (UPVC 6394)',
        availability: 'Mon - Sat (10:00 AM - 08:00 PM)',
      );
    }

    // Default to today if not Sunday, else tomorrow
    final now = DateTime.now();
    if (now.weekday == DateTime.sunday) {
      _selectedDate = now.add(const Duration(days: 1));
      _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    } else {
      _selectedDate = now;
    }

    _fetchSlotsForDate(_selectedDate);
  }

  Future<void> _fetchUserPets() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    setState(() => _isLoadingPets = true);
    try {
      final pets = await PetService.instance.getCustomerPets(user.uid);
      if (mounted) {
        setState(() {
          _myPets = pets;
          _isLoadingPets = false;
          if (_selectedPet == null && pets.isNotEmpty) {
            _selectedPet = pets.first;
            if (_ownerName.isEmpty) _ownerName = pets.first.ownerName;
            if (_ownerPhone.isEmpty) _ownerPhone = pets.first.contactNumber;
            if (_ownerAddress.isEmpty) _ownerAddress = pets.first.ownerAddress;
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingPets = false);
    }
  }

  Future<void> _fetchSlotsForDate(DateTime date) async {
    setState(() {
      _selectedDate = date;
      _selectedTimeSlot = null;
      _isLoadingSlots = true;
      _errorMessage = null;
    });

    final slots = await PetService.instance.getAvailableSlots(
      date: date,
      doctorId: _selectedDoctor?.id,
      shopId: ShopService.instance.configuredShopId,
    );

    if (mounted) {
      setState(() {
        _availableSlots = slots;
        _isLoadingSlots = false;
      });
    }
  }

  Future<void> _handleBookAppointment() async {
    if (_selectedPet == null) {
      setState(() {
        _errorMessage = 'Please select or register a pet before submitting an appointment.';
      });
      return;
    }

    final finalConcern = _reasonController.text.trim().isNotEmpty
        ? _reasonController.text.trim()
        : _selectedCategory;

    if (finalConcern.isEmpty) {
      setState(() {
        _errorMessage = 'Please provide a primary reason for the consultation.';
      });
      return;
    }

    if (_selectedTimeSlot == null) {
      setState(() {
        _errorMessage = 'Please select a suitable consultation time slot.';
      });
      return;
    }

    final user = AuthService.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'Please sign in to confirm your appointment.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final biz = ShopService.instance.currentBusiness;
    final dateStr =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    try {
      final docId = await PetService.instance.bookPetAppointment(
        petId: _selectedPet!.id,
        petName: _selectedPet!.name,
        petRegistrationNumber: _selectedPet!.registrationNumber,
        breed: _selectedPet!.breed,
        petType: _selectedPet!.species,
        age: _selectedPet!.dob.isNotEmpty ? _selectedPet!.ageDisplay : 'Adult',
        gender: _selectedPet!.gender,
        userId: user.uid,
        customerName: _ownerName.isNotEmpty ? _ownerName : 'Pet Parent',
        customerPhone: _ownerPhone.isNotEmpty ? _ownerPhone : 'N/A',
        customerAddress: _ownerAddress.isNotEmpty ? _ownerAddress : 'Kanpur',
        appointmentDate: dateStr,
        appointmentTime: _selectedTimeSlot!,
        concernCategory: finalConcern,
        symptoms: _symptomsController.text.trim(),
        notes: _notesController.text.trim(),
        doctorId: _selectedDoctor?.id ?? '',
        doctorName: _selectedDoctor?.name ?? 'Dr. Ashwani Kumar Singh',
        shopId: biz?.shopId ?? ShopService.instance.configuredShopId,
        businessId: biz?.id ?? '',
        businessName: biz?.name ?? 'Healthy Paws Pet Clinic',
      );

      if (!mounted) return;

      // Show Confirmation Dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 28),
              SizedBox(width: 10),
              Text(
                'Booking Submitted',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your consultation request for ${_selectedPet!.name} on $dateStr at $_selectedTimeSlot has been scheduled with the clinic.',
                style: const TextStyle(fontSize: 13, color: AppColors.mainText, height: 1.4),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Reason: $finalConcern\nStatus: Pending Clinic Confirmation.',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onPrimaryContainer,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Back to Pet', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AppointmentDetailScreen(appointmentDocId: docId),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('View Booking Status', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isSubmitting = false;
        });
      }
    }
  }

  // --- CALENDAR HELPERS ---
  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  void _goToPreviousMonth() {
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final prevMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);

    if (!prevMonth.isBefore(currentMonthStart)) {
      setState(() {
        _displayedMonth = prevMonth;
      });
    }
  }

  void _goToNextMonth() {
    final now = DateTime.now();
    final maxMonth = DateTime(now.year, now.month + 6, 1);
    final nextMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);

    if (!nextMonth.isAfter(maxMonth)) {
      setState(() {
        _displayedMonth = nextMonth;
      });
    }
  }

  void _selectDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target.isBefore(today)) return;

    if (date.weekday == DateTime.sunday) {
      setState(() {
        _selectedDate = date;
        _selectedTimeSlot = null;
        _availableSlots = [];
        _errorMessage = 'The clinic is closed on Sundays for routine consultations.';
      });
      return;
    }

    _fetchSlotsForDate(date);
  }

  @override
  Widget build(BuildContext context) {
    final biz = ShopService.instance.currentBusiness;
    final clinicName = biz?.name ?? 'Healthy Paws Pet Clinic';
    final doctorName = _selectedDoctor?.name ?? 'Dr. Ashwani Kumar Singh';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Book Clinic Appointment',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.mainText,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.mainText),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Patient Pet Selection
            widget.pet != null
                ? _buildPetProfileCard(clinicName, widget.pet!)
                : _buildPetSelectionSection(clinicName),
            const SizedBox(height: 16),

            // Error Banner
            if (_errorMessage != null) ...[
              _buildErrorBanner(),
              const SizedBox(height: 16),
            ],

            // 2. Real Interactive Calendar
            _buildSectionHeader(
              title: '1. Select Appointment Date',
              subtitle: 'Pick any available clinic consultation day',
              badge: _selectedDate.weekday == DateTime.sunday ? 'Closed Sunday' : 'Open Mon-Sat',
              badgeColor: _selectedDate.weekday == DateTime.sunday ? AppColors.errorRed : AppColors.successGreen,
            ),
            const SizedBox(height: 10),
            _buildRealCalendarCard(),
            const SizedBox(height: 22),

            // 3. Time Slots
            _buildSectionHeader(
              title: '2. Available Time Slots',
              subtitle: _availableSlots.isNotEmpty
                  ? '${_availableSlots.length} consultation slots open with $doctorName'
                  : 'Consultation slots for selected date',
              badge: _selectedTimeSlot,
              badgeColor: AppColors.primary,
            ),
            const SizedBox(height: 10),
            _buildTimeSlotsSection(),
            const SizedBox(height: 22),

            // 4. Primary Reason & Custom Input
            _buildSectionHeader(
              title: '3. Reason / Primary Concern',
              subtitle: 'Select from common reasons or write in your own words',
            ),
            const SizedBox(height: 10),
            _buildReasonAndConcernCard(),
            const SizedBox(height: 20),

            // 5. Additional Clinical Symptoms (Optional)
            _buildSectionHeader(
              title: '4. Describe Symptoms (Optional)',
              subtitle: 'Provide extra details for the examining doctor',
            ),
            const SizedBox(height: 8),
            _buildSymptomsInput(),
            const SizedBox(height: 22),

            // 6. Booking Summary Card
            _buildBookingSummaryCard(clinicName, doctorName),
            const SizedBox(height: 24),

            // 7. Action Button
            _buildSubmitButton(),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENT BUILDERS ---

  Widget _buildSectionHeader({
    required String title,
    String? subtitle,
    String? badge,
    Color? badgeColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.mainText,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (badgeColor ?? AppColors.primary).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (badgeColor ?? AppColors.primary).withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: badgeColor ?? AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPetSelectionSection(String clinicName) {
    if (_isLoadingPets) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
              SizedBox(width: 12),
              Text(
                'Loading your registered pets...',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
      );
    }

    if (_myPets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF7F7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF5D6D6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFECEC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.pets_rounded, color: AppColors.errorRed, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No Registered Pets Found',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.mainText),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'A registered patient profile is required for clinic consultations.',
                        style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PetRegistrationScreen()),
                  ).then((_) => _fetchUserPets());
                },
                icon: const Icon(Icons.app_registration_rounded, size: 16),
                label: const Text('Register Your Pet Now', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Select Patient Pet',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.mainText),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PetRegistrationScreen()),
                ).then((_) => _fetchUserPets());
              },
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_circle_outline_rounded, size: 14, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text(
                      'Add New Pet',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _myPets.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (ctx, index) {
              final p = _myPets[index];
              final isSelected = _selectedPet?.id == p.id;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedPet = p;
                    _ownerName = p.ownerName;
                    _ownerPhone = p.contactNumber;
                    _ownerAddress = p.ownerAddress;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 190,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF3EFFF) : AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 1.6 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: p.photoUrl != null && p.photoUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(p.photoUrl!, fit: BoxFit.cover),
                              )
                            : const Icon(Icons.pets_rounded, size: 20, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                color: isSelected ? AppColors.primary : AppColors.mainText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${p.species} • ${p.breed}',
                              style: const TextStyle(fontSize: 10, color: AppColors.secondaryText),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              p.registrationNumber,
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPetProfileCard(String clinicName, [PetModel? customPet]) {
    final pet = customPet ?? _selectedPet ?? widget.pet;
    if (pet == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: pet.photoUrl != null && pet.photoUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(pet.photoUrl!, fit: BoxFit.cover),
                  )
                : const Icon(Icons.pets_rounded, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.mainText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.successContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Patient',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.successGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${pet.species} • ${pet.breed} • ${pet.gender}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.local_hospital_outlined, size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '$clinicName (${pet.registrationNumber})',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.errorRed, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.errorRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Authentic, full-featured Monthly Calendar Card
  Widget _buildRealCalendarCard() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final monthName = _monthNames[_displayedMonth.month - 1];
    final year = _displayedMonth.year;

    final daysInMonth = _getDaysInMonth(_displayedMonth);
    final firstWeekday = DateTime(_displayedMonth.year, _displayedMonth.month, 1).weekday; // 1 = Mon, 7 = Sun
    final leadingBlanks = firstWeekday - 1;
    final totalCells = ((leadingBlanks + daysInMonth + 6) ~/ 7) * 7;

    final isCurrentMonth = _displayedMonth.year == now.year && _displayedMonth.month == now.month;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month Header Bar with Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '$monthName $year',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.mainText,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Jump to Today button
                  if (!isCurrentMonth || _selectedDate.day != now.day)
                    InkWell(
                      onTap: () {
                        setState(() {
                          _displayedMonth = DateTime(now.year, now.month, 1);
                        });
                        _selectDay(now.weekday == DateTime.sunday ? now.add(const Duration(days: 1)) : now);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Today',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                  // Left / Right navigation
                  InkWell(
                    onTap: isCurrentMonth ? null : _goToPreviousMonth,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCurrentMonth ? AppColors.surfaceMuted : AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        size: 20,
                        color: isCurrentMonth ? AppColors.mutedText : AppColors.mainText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: _goToNextMonth,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: AppColors.mainText,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Weekday Labels (Mon - Sun)
          Row(
            children: _weekdayNames.map((day) {
              final isSunday = day == 'Sun';
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isSunday ? const Color(0xFFE53935) : AppColors.secondaryText,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.borderLight, height: 1),
          const SizedBox(height: 8),

          // Monthly Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              if (index < leadingBlanks || index >= leadingBlanks + daysInMonth) {
                return const SizedBox.shrink();
              }

              final dayNumber = index - leadingBlanks + 1;
              final cellDate = DateTime(_displayedMonth.year, _displayedMonth.month, dayNumber);
              final cellDateOnly = DateTime(cellDate.year, cellDate.month, cellDate.day);

              final isPast = cellDateOnly.isBefore(today);
              final isToday = cellDateOnly.isAtSameMomentAs(today);
              final isSunday = cellDate.weekday == DateTime.sunday;
              final isSelected = cellDate.year == _selectedDate.year &&
                  cellDate.month == _selectedDate.month &&
                  cellDate.day == _selectedDate.day;

              return InkWell(
                onTap: isPast ? null : () => _selectDay(cellDate),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : (isToday
                            ? AppColors.primaryContainer.withValues(alpha: 0.4)
                            : (isSunday ? const Color(0xFFFFF5F5) : Colors.transparent)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (isToday ? AppColors.primary : (isSunday ? const Color(0xFFFFE0E0) : AppColors.borderLight)),
                      width: isSelected || isToday ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w900 : (isToday ? FontWeight.w800 : FontWeight.w700),
                          color: isSelected
                              ? AppColors.white
                              : (isPast
                                  ? AppColors.mutedText.withValues(alpha: 0.4)
                                  : (isSunday ? const Color(0xFFE53935) : AppColors.mainText)),
                        ),
                      ),
                      if (isSunday && !isPast && !isSelected) ...[
                        const SizedBox(height: 1),
                        const Text(
                          'Off',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE53935),
                          ),
                        ),
                      ] else if (isToday && !isSelected) ...[
                        const SizedBox(height: 1),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.borderLight, height: 1),
          const SizedBox(height: 12),

          // Active Selection & Clinic Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _selectedDate.weekday == DateTime.sunday
                  ? const Color(0xFFFFF1F0)
                  : AppColors.primarySurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _selectedDate.weekday == DateTime.sunday
                    ? const Color(0xFFFFCCC7)
                    : AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _selectedDate.weekday == DateTime.sunday
                      ? Icons.event_busy_rounded
                      : Icons.event_available_rounded,
                  size: 18,
                  color: _selectedDate.weekday == DateTime.sunday
                      ? const Color(0xFFE53935)
                      : AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_weekdayNames[_selectedDate.weekday - 1]}, ${_selectedDate.day} ${_monthNames[_selectedDate.month - 1]} ${_selectedDate.year}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: _selectedDate.weekday == DateTime.sunday
                              ? const Color(0xFFE53935)
                              : AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _selectedDate.weekday == DateTime.sunday
                            ? 'Clinic is closed for regular visits. Emergency consultations on-call.'
                            : 'OPD Consultation Hours: 10:00 AM - 08:00 PM',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _selectedDate.weekday == DateTime.sunday
                              ? const Color(0xFFE53935).withValues(alpha: 0.8)
                              : AppColors.secondaryText,
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

  /// Interactive Time Slots Grid
  Widget _buildTimeSlotsSection() {
    if (_isLoadingSlots) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Column(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.2),
              ),
              SizedBox(height: 10),
              Text(
                'Checking doctor availability...',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
      );
    }

    if (_selectedDate.weekday == DateTime.sunday) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5F5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFD1D1)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Color(0xFFE53935), size: 22),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Routine consultations are not scheduled on Sundays. Please select Monday to Saturday for clinic visits.',
                style: TextStyle(fontSize: 12, color: Color(0xFFB71C1C), fontWeight: FontWeight.w600, height: 1.4),
              ),
            ),
          ],
        ),
      );
    }

    if (_availableSlots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.schedule_rounded, size: 32, color: AppColors.secondaryText),
              SizedBox(height: 8),
              Text(
                'No available slots for this date',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.mainText),
              ),
              SizedBox(height: 4),
              Text(
                'All consultation slots on this date might be booked or elapsed. Please choose an alternate date from the calendar above.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.secondaryText, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableSlots.map((slot) {
              final isSelected = _selectedTimeSlot == slot;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedTimeSlot = slot;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.28),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: isSelected ? AppColors.white : AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        slot,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                          color: isSelected ? AppColors.white : AppColors.mainText,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.check_rounded, size: 14, color: AppColors.white),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Primary Reason with Preset Category Chips AND Free-form Custom Input
  Widget _buildReasonAndConcernCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Preset Reasons',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 10),

          // Preset Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _concernCategories.map((item) {
              final label = item['label'] as String;
              final icon = item['icon'] as IconData;
              final isSelected = _selectedCategory == label;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedCategory = label;
                    if (label == 'Other / Custom Reason') {
                      _reasonController.text = '';
                    } else {
                      _reasonController.text = label;
                    }
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 1.4 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 14,
                        color: isSelected ? AppColors.white : AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? AppColors.white : AppColors.mainText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.borderLight, height: 1),
          const SizedBox(height: 14),

          // Custom Writeable Reason Input
          const Row(
            children: [
              Icon(Icons.edit_note_rounded, size: 18, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                'Primary Reason (Editable / Custom)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.mainText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _reasonController,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.mainText),
            decoration: InputDecoration(
              hintText: 'Type your pet\'s specific reason (e.g. skin itching, fever, routine checkup)...',
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.secondaryText, fontWeight: FontWeight.w400),
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
              ),
              suffixIcon: _reasonController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.secondaryText),
                      onPressed: () {
                        _reasonController.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (val) {
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsInput() {
    return TextField(
      controller: _symptomsController,
      maxLines: 3,
      style: const TextStyle(fontSize: 13, color: AppColors.mainText, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: 'e.g. Vomiting since yesterday, lethargic, reduced food intake, scratching left ear...',
        hintStyle: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
      ),
    );
  }

  Widget _buildBookingSummaryCard(String clinicName, String doctorName) {
    final activeReason = _reasonController.text.trim().isNotEmpty
        ? _reasonController.text.trim()
        : _selectedCategory;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Appointment Summary',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.mainText),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'In-Clinic OPD',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.onPrimaryContainer),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildSummaryRow(Icons.local_hospital_outlined, 'Clinic', clinicName),
          const Divider(color: AppColors.borderLight, height: 16),
          _buildSummaryRow(Icons.person_pin_outlined, 'Doctor', doctorName),
          const Divider(color: AppColors.borderLight, height: 16),
          _buildSummaryRow(
            Icons.calendar_today_outlined,
            'Date',
            '${_weekdayNames[_selectedDate.weekday - 1]}, ${_selectedDate.day} ${_monthNames[_selectedDate.month - 1]} ${_selectedDate.year}',
          ),
          const Divider(color: AppColors.borderLight, height: 16),
          _buildSummaryRow(
            Icons.schedule_rounded,
            'Time Slot',
            _selectedTimeSlot ?? 'Select from slots above',
            isHighlighted: _selectedTimeSlot != null,
          ),
          const Divider(color: AppColors.borderLight, height: 16),
          _buildSummaryRow(Icons.help_outline_rounded, 'Reason', activeReason),
          if (_selectedPet != null) ...[
            const Divider(color: AppColors.borderLight, height: 16),
            _buildSummaryRow(
              Icons.pets_rounded,
              'Patient Pet',
              '${_selectedPet!.name} (${_selectedPet!.species} • ${_selectedPet!.registrationNumber})',
            ),
          ],
          if (widget.servicePrice != null && widget.servicePrice! > 0) ...[
            const Divider(color: AppColors.borderLight, height: 16),
            _buildSummaryRow(
              Icons.payments_outlined,
              'Service Fee',
              '₹${widget.servicePrice!.toStringAsFixed(0)}',
              isHighlighted: true,
            ),
          ],
          const Divider(color: AppColors.borderLight, height: 16),
          _buildSummaryRow(Icons.account_circle_outlined, 'Pet Parent', '$_ownerName ($_ownerPhone)'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value, {bool isHighlighted = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: isHighlighted ? AppColors.primary : AppColors.secondaryText),
        const SizedBox(width: 10),
        SizedBox(
          width: 82,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isHighlighted ? FontWeight.w900 : FontWeight.w700,
              color: isHighlighted ? AppColors.primary : AppColors.mainText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleBookAppointment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
        ),
        child: _isSubmitting
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Submitting Appointment Request...',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Confirm Appointment Request',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.3),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
      ),
    );
  }
}
