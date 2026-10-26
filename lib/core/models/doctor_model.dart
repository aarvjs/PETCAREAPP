class DoctorModel {
  final String id;
  final String fullName;
  final String specialization;
  final String qualification;
  final String experience;
  final String availability;
  final String? phone;
  final String? email;
  final String? photoUrl;
  final String status;

  const DoctorModel({
    required this.id,
    required this.fullName,
    this.specialization = 'Veterinary Physician & Surgeon',
    this.qualification = 'BVSc & AH',
    this.experience = '5+ Years Experience',
    this.availability = 'Mon - Sat (09:00 AM - 06:00 PM)',
    this.phone,
    this.email,
    this.photoUrl,
    this.status = 'active',
  });

  bool get isActive => status.toLowerCase() == 'active';
  String get name => fullName;

  factory DoctorModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return DoctorModel(
      id: docId,
      fullName: data['fullName'] ?? data['name'] ?? 'Dr. Veterinary Specialist',
      specialization: data['specialization'] ?? 'Veterinary Physician & Surgeon',
      qualification: data['qualification'] ?? 'BVSc & AH',
      experience: data['experience'] ?? '5+ Years Experience',
      availability: data['availability'] ?? 'Mon - Sat (09:00 AM - 06:00 PM)',
      phone: data['phone'],
      email: data['email'],
      photoUrl: data['photoURL'] ?? data['photoUrl'] ?? data['image'],
      status: data['status'] ?? 'active',
    );
  }
}
