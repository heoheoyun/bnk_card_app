abstract class TermsRepository {
  Future<List<Map<String, dynamic>>> getTermsPackage(String packageType);
  Future<void> agreeTerms(List<Map<String, dynamic>> agreements);
}
