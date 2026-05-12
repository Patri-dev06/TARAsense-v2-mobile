import 'package:flutter_test/flutter_test.dart';
import 'package:tarasense_mobile/features/tester/domain/consumer_study.dart';

void main() {
  test('uses session slot date and time before plain schedule text', () {
    final ConsumerStudy study = ConsumerStudy.fromJson(<String, dynamic>{
      'id': 'study-1',
      'studyTitle': 'Mango texture test',
      'schedule': 'test, test, test',
      'sessionSlots': <Map<String, dynamic>>[
        <String, dynamic>{
          'label': 'Morning session',
          'startDateTime': '2026-05-11T09:30:00',
          'endDateTime': '2026-05-11T10:30:00',
        },
      ],
    });

    expect(study.session, contains('May 11, 2026'));
    expect(study.session, contains('Morning session'));
    expect(study.session, contains('9:30 AM - 10:30 AM'));
  });

  test(
    'parses mobile sessionSchedule slots from consumer studies response',
    () {
      final ConsumerStudy study = ConsumerStudy.fromJson(<String, dynamic>{
        'id': 'study-2',
        'title': 'Coffee Sensory Test',
        'location': 'FIC Lab A',
        'sampleSize': 30,
        'sessionSchedule': <String, dynamic>{
          'timezone': 'Asia/Manila',
          'slots': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'slot-1',
              'label': 'Morning Session',
              'startsAt': '2026-05-15T01:00:00.000Z',
              'endsAt': '2026-05-15T03:00:00.000Z',
              'capacity': 20,
              'reservedCount': 5,
              'remainingCount': 15,
            },
          ],
        },
      });

      expect(study.session, contains('May 15, 2026'));
      expect(study.session, contains('Morning Session'));
      expect(study.session, contains('9:00 AM - 11:00 AM'));
      expect(study.slotsLeft, 15);
    },
  );
}
