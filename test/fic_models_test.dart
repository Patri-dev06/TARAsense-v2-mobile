import 'package:flutter_test/flutter_test.dart';
import 'package:tarasense_mobile/features/fic/domain/fic_models.dart';

void main() {
  test('parses FIC studies with nested session schedule slots', () {
    final List<FicStudy> studies = parseFicStudies(<String, dynamic>{
      'studies': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'study-1',
          'title': 'Coffee Sensory Test',
          'status': 'IN_PROGRESS',
          'participantCount': 5,
          'sampleSize': 20,
          'sessionSchedule': <String, dynamic>{
            'slots': <Map<String, dynamic>>[
              <String, dynamic>{
                'label': 'Morning Session',
                'startsAt': '2026-05-15T01:00:00.000Z',
                'endsAt': '2026-05-15T03:00:00.000Z',
              },
            ],
          },
        },
      ],
    });

    expect(studies, hasLength(1));
    expect(studies.first.title, 'Coffee Sensory Test');
    expect(studies.first.progressLabel, '5/20 participants');
    expect(studies.first.scheduleLabel, contains('May 15'));
    expect(studies.first.scheduleLabel, contains('9:00 AM - 11:00 AM'));
  });

  test('parses FIC availability response', () {
    final List<FicAvailabilityDay> availability = parseFicAvailability(
      <String, dynamic>{
        'availability': <Map<String, dynamic>>[
          <String, dynamic>{'date': '2026-05-11', 'status': 'AVAILABLE'},
          <String, dynamic>{'date': '2026-05-12', 'status': 'BOOKED'},
        ],
      },
    );

    expect(availability, hasLength(2));
    expect(availability.first.available, isTrue);
    expect(availability.last.booked, isTrue);
  });
}
