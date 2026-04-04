import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/services/mood_provider.dart';

/// Call Booking screen per SRS 4.6.
/// User selects: date → time slot → call type (audio/video) → confirm.
class CallBookingScreen extends StatefulWidget {
  const CallBookingScreen({super.key});

  @override
  State<CallBookingScreen> createState() => _CallBookingScreenState();
}

class _CallBookingScreenState extends State<CallBookingScreen> {
  // Step tracking
  DateTime _selectedDate = DateTime.now();
  String? _selectedSlot;
  String _callType = 'audio'; // 'audio' or 'video'
  bool _useProfileNumber = true;
  final _phoneController = TextEditingController();

  // Generate next 7 days
  List<DateTime> get _availableDates {
    final today = DateTime.now();
    return List.generate(7, (i) => today.add(Duration(days: i)));
  }

  // Time slots (30 min intervals, 9 AM to 8 PM)
  static const _timeSlots = [
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '12:30 PM',
    '01:00 PM',
    '01:30 PM',
    '02:00 PM',
    '02:30 PM',
    '03:00 PM',
    '03:30 PM',
    '04:00 PM',
    '04:30 PM',
    '05:00 PM',
    '05:30 PM',
    '06:00 PM',
    '06:30 PM',
    '07:00 PM',
    '07:30 PM',
    '08:00 PM',
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool get _canBook => _selectedSlot != null;

  void _confirmBooking() {
    if (!_canBook) return;

    final dateStr = DateFormat('EEEE, MMM d').format(_selectedDate);
    final typeLabel = _callType == 'audio' ? 'Audio Call' : 'Video Call';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 28),
            const SizedBox(width: 10),
            Text('Booking Confirmed',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _confirmRow(Icons.calendar_today_rounded, dateStr),
            const SizedBox(height: 10),
            _confirmRow(Icons.access_time_rounded, _selectedSlot!),
            const SizedBox(height: 10),
            _confirmRow(
              _callType == 'audio'
                  ? Icons.phone_rounded
                  : Icons.videocam_rounded,
              typeLabel,
            ),
            const SizedBox(height: 16),
            Text(
              'You will receive a reminder 1 hour before your session.',
              style: GoogleFonts.nunito(
                  fontSize: 13, color: const Color(0xFF7A6055), height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to home
            },
            child: Text('Done',
                style: GoogleFonts.nunito(
                    color: const Color(0xFF5C3D2E),
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _confirmRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF5C3D2E)),
        const SizedBox(width: 10),
        Text(text,
            style: GoogleFonts.nunito(
                fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final moodProvider = context.watch<MoodProvider>();
    final config = moodProvider.currentConfig;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0ED),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF5C3D2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Book a Call',
            style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2C1810))),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── SECTION 1: Select Date ──
            _sectionTitle('Select Date'),
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _availableDates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final date = _availableDates[i];
                  final isSelected = _isSameDay(date, _selectedDate);
                  final isToday = _isSameDay(date, DateTime.now());

                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedDate = date;
                      _selectedSlot = null; // Reset slot on date change
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 68,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF5C3D2E)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF5C3D2E)
                              : const Color(0xFFE0D6CF),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF5C3D2E)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('EEE').format(date).toUpperCase(),
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white70
                                  : const Color(0xFF7A6055),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${date.day}',
                            style: GoogleFonts.nunito(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF2C1810),
                            ),
                          ),
                          if (isToday)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF5C3D2E),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 28),

            // ── SECTION 2: Select Time Slot ──
            _sectionTitle('Select Time Slot'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _timeSlots.map((slot) {
                final isSelected = _selectedSlot == slot;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSlot = slot),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF5C3D2E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF5C3D2E)
                            : const Color(0xFFE0D6CF),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF5C3D2E)
                                    .withValues(alpha: 0.2),
                                blurRadius: 8,
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      slot,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF5C3D2E),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            // ── SECTION 3: Call Type ──
            _sectionTitle('Call Type'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _callTypeCard(
                    icon: Icons.phone_rounded,
                    label: 'Audio Call',
                    subtitle: 'Voice only',
                    value: 'audio',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _callTypeCard(
                    icon: Icons.videocam_rounded,
                    label: 'Video Call',
                    subtitle: 'Face-to-face',
                    value: 'video',
                  ),
                ),
              ],
            ),

            // Phone number for audio calls
            if (_callType == 'audio') ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _useProfileNumber,
                    onChanged: (v) =>
                        setState(() => _useProfileNumber = v ?? true),
                    activeColor: const Color(0xFF5C3D2E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  Text('Use my profile number',
                      style: GoogleFonts.nunito(
                          fontSize: 14, color: const Color(0xFF5C3D2E))),
                ],
              ),
              if (!_useProfileNumber) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Enter phone number',
                    hintStyle:
                        GoogleFonts.nunito(color: const Color(0xFFB0A090)),
                    prefixIcon: const Icon(Icons.phone_outlined,
                        color: Color(0xFF7A6055)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                  ),
                  style: GoogleFonts.nunito(fontSize: 15),
                ),
              ],
            ],

            const SizedBox(height: 36),

            // ── CONFIRM BUTTON ──
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _canBook ? _confirmBooking : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C3D2E),
                  disabledBackgroundColor: const Color(0xFFD4C5BC),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: _canBook ? 4 : 0,
                ),
                child: Text(
                  'Confirm Booking',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _canBook ? Colors.white : const Color(0xFF9A8A7E),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Cancellation note
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE6D5C3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 18, color: Color(0xFF9B6B4E)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You can cancel or reschedule up to 1 hour before the call. 3 or more no-shows may result in time deduction.',
                      style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: const Color(0xFF7A6055),
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF2C1810),
      ),
    );
  }

  Widget _callTypeCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required String value,
  }) {
    final isSelected = _callType == value;
    return GestureDetector(
      onTap: () => setState(() => _callType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5C3D2E) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF5C3D2E)
                : const Color(0xFFE0D6CF),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color:
                        const Color(0xFF5C3D2E).withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 32,
                color: isSelected ? Colors.white : const Color(0xFF5C3D2E)),
            const SizedBox(height: 8),
            Text(label,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : const Color(0xFF2C1810),
                )),
            const SizedBox(height: 2),
            Text(subtitle,
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  color: isSelected ? Colors.white70 : const Color(0xFF7A6055),
                )),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
