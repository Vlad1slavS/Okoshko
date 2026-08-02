import 'package:you_master_app/features/professional_details/domain/professional_details.dart';

abstract interface class ProfessionalDetailsRepository {
  Future<ProfessionalDetails> getById(String id);
}

class MockProfessionalDetailsRepository
    implements ProfessionalDetailsRepository {
  const MockProfessionalDetailsRepository();

  @override
  Future<ProfessionalDetails> getById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return ProfessionalDetails(
      id: id,
      name: 'Екатерина Смирнова',
      specializations: const ['Маникюр', 'Педикюр', 'Брови'],
      coverAsset: 'assets/images/professional_details/cover.webp',
      avatarAsset: 'assets/images/home/ekaterina.webp',
      rating: 4.9,
      reviewCount: 128,
      experienceYears: 6,
      completedAppointments: 312,
      repeatClientPercent: 85,
      address: 'Чистопрудный бульвар, 12с1',
      addressHint: '5 мин от м. Чистые пруды',
      workingHours: const {
        'Пн — Пт': '10:00 — 21:00',
        'Суббота': '10:00 — 19:00',
        'Воскресенье': 'Выходной',
      },
      about:
          'Более 6 лет занимаюсь маникюром и педикюром. Работаю на '
          'премиальных материалах, уделяю особое внимание стерильности '
          'инструментов и аккуратности результата.',
      serviceCategories: const ['Все', 'Маникюр', 'Педикюр', 'Брови'],
      services: const [
        ProfessionalService(
          id: 'manicure-coated',
          category: 'Маникюр',
          name: 'Маникюр с покрытием',
          description: 'Маникюр, выравнивание, покрытие гель-лаком',
          durationMinutes: 90,
          price: 2200,
          imageAsset: 'assets/images/professional_details/work_1.webp',
          isPopular: true,
        ),
        ProfessionalService(
          id: 'manicure-basic',
          category: 'Маникюр',
          name: 'Маникюр без покрытия',
          description: 'Классический маникюр без покрытия',
          durationMinutes: 45,
          price: 1200,
          imageAsset: 'assets/images/professional_details/work_3.webp',
        ),
        ProfessionalService(
          id: 'gel-strengthening',
          category: 'Маникюр',
          name: 'Укрепление гелем',
          description: 'Маникюр и укрепление ногтевой пластины гелем',
          durationMinutes: 90,
          price: 2300,
          imageAsset: 'assets/images/professional_details/work_2.webp',
        ),
        ProfessionalService(
          id: 'removal-manicure',
          category: 'Маникюр',
          name: 'Снятие + маникюр с покрытием',
          description: 'Снятие старого покрытия, маникюр, гель-лак',
          durationMinutes: 100,
          price: 2600,
          imageAsset: 'assets/images/professional_details/work_4.webp',
        ),
        ProfessionalService(
          id: 'nail-design',
          category: 'Маникюр',
          name: 'Дизайн',
          description: 'Любой дизайн ногтей любой сложности',
          durationMinutes: 15,
          price: 200,
          priceFrom: true,
          imageAsset: 'assets/images/professional_details/work_5.webp',
        ),
      ],
      portfolioAssets: const [
        'assets/images/professional_details/work_1.webp',
        'assets/images/professional_details/work_2.webp',
        'assets/images/professional_details/work_3.webp',
        'assets/images/professional_details/work_4.webp',
        'assets/images/professional_details/work_5.webp',
        'assets/images/professional_details/work_6.webp',
      ],
      reviews: const [
        ProfessionalReview(
          author: 'Анастасия',
          date: '22 мая',
          rating: 5,
          text:
              'Всё очень понравилось! Екатерина — профессионал своего дела, '
              'маникюр идеальный, как всегда ✨',
          isVerifiedAppointment: true,
        ),
        ProfessionalReview(
          author: 'Мария',
          date: '18 мая',
          rating: 5,
          text: 'Уютная студия, приятная атмосфера и потрясающий результат.',
          isVerifiedAppointment: true,
        ),
        ProfessionalReview(
          author: 'Ольга',
          date: '10 мая',
          rating: 5,
          text:
              'Делаю маникюр у Екатерины уже больше года. Всегда аккуратно '
              'и качественно!',
          isVerifiedAppointment: true,
        ),
      ],
      credentials: const [
        ProfessionalCredential(
          title: 'Сертификаты',
          value: '3 сертификата',
          icon: 'certificate',
        ),
        ProfessionalCredential(
          title: 'Образование',
          value: 'Высшее художественное',
          icon: 'education',
        ),
        ProfessionalCredential(
          title: 'Дипломы и курсы',
          value: '7 курсов повышения квалификации',
          icon: 'course',
        ),
        ProfessionalCredential(
          title: 'Способы оплаты',
          value: 'Наличные, карта, СБП',
          icon: 'payment',
        ),
        ProfessionalCredential(
          title: 'Отмена записи',
          value: 'Бесплатно за 12 часов',
          icon: 'cancellation',
        ),
      ],
      isVerified: true,
    );
  }
}
