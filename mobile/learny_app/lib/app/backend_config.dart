class BackendConfig {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://learny-19v5hrda.on-forge.com',
  );
  static const demoName = 'Parent Tester';
  static const demoEmail = 'parent@example.com';
  static const demoPassword = 'secret123';
  static const childName = 'Alex';
  static const childGrade = '6th';
  static const disableOnboarding = false;
}
