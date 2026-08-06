abstract final class AppRoutes {
  static const entry = '/';
  static const authPhone = '/auth/phone';
  static const authOtp = '/auth/otp';
  static const authProfile = '/auth/profile';

  static const clientHome = '/client/home';
  static const clientSearch = '/client/search';
  static const clientAppointments = '/client/appointments';
  static const clientFavorites = '/client/favorites';
  static const clientProfile = '/client/profile';

  static const professionalDetailsPattern = '/professionals/:id';

  static String professionalDetails(String id) => '/professionals/$id';

  static const professionalHome = '/professional/home';
  static const professionalCalendar = '/professional/calendar';
  static const professionalSchedule = '/professional/calendar/schedule';
  static const professionalCreate = '/professional/create';
  static const professionalClients = '/professional/clients';
  static const professionalCabinet = '/professional/cabinet';

  static String withReturnTo(String path, String? returnTo) {
    final safe = safeReturnTo(returnTo);
    if (safe == null) return path;
    return Uri(path: path, queryParameters: {'returnTo': safe}).toString();
  }

  static String? safeReturnTo(String? value) {
    if (value == null || value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !uri.hasAbsolutePath ||
        uri.hasScheme ||
        uri.hasAuthority ||
        value.startsWith('//') ||
        value.startsWith('/auth')) {
      return null;
    }
    return uri.toString();
  }
}
