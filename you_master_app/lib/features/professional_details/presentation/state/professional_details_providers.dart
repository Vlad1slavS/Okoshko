import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_master_app/features/professional_details/data/professional_details_repository.dart';
import 'package:you_master_app/features/professional_details/domain/professional_details.dart';

final professionalDetailsRepositoryProvider =
    Provider<ProfessionalDetailsRepository>(
      (ref) => const MockProfessionalDetailsRepository(),
    );

final professionalDetailsProvider =
    FutureProvider.family<ProfessionalDetails, String>((ref, id) {
      return ref.watch(professionalDetailsRepositoryProvider).getById(id);
    });
