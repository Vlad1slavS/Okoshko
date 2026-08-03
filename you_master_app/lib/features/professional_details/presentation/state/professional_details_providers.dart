import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:you_master_app/core/config/app_environment.dart';
import 'package:you_master_app/core/network/api_retry_policy.dart';
import 'package:you_master_app/core/network/network_providers.dart';
import 'package:you_master_app/features/professional_details/data/backend_professional_details_repository.dart';
import 'package:you_master_app/features/professional_details/data/professional_details_repository.dart';
import 'package:you_master_app/features/professional_details/domain/professional_details.dart';

final professionalDetailsRepositoryProvider =
    Provider<ProfessionalDetailsRepository>((ref) {
      const mockRepository = MockProfessionalDetailsRepository();
      if (!AppEnvironment.useRemoteApi) return mockRepository;

      return BackendProfessionalDetailsRepository(
        ref.watch(apiClientProvider),
        mockRepository,
      );
    });

final professionalDetailsProvider =
    FutureProvider.family<ProfessionalDetails, String>((ref, id) {
      return ref.watch(professionalDetailsRepositoryProvider).getById(id);
    }, retry: ApiRetryPolicy.transientErrors);
