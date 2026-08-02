abstract final class AppRoutes {
  static const entry = '/';

  static const clientHome = '/client/home';
  static const clientSearch = '/client/search';
  static const clientAppointments = '/client/appointments';
  static const clientFavorites = '/client/favorites';
  static const clientProfile = '/client/profile';

  static const professionalDetailsPattern = '/professionals/:id';

  static String professionalDetails(String id) => '/professionals/$id';

  static const professionalHome = '/professional/home';
  static const professionalCalendar = '/professional/calendar';
  static const professionalCreate = '/professional/create';
  static const professionalMessages = '/professional/messages';
  static const professionalCabinet = '/professional/cabinet';
}
