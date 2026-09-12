class UserSettings {
  final String userId;
  bool isDarkMode;
  bool isNotificationsEnabled;
  bool biometricLock;
  bool pinEnabled;
  bool hideValues;
  bool hideNotificationContent;
  bool closingMonthReminder;
  bool dueBillsReminder;
  bool weeklySummary;
  bool aboveAverageAlert;
  bool budgetGoalAlert;
  bool unusualMovementAlert;
  bool aiAssistantEnabled;
  String notificationFrequency;
  String notificationTime;

  UserSettings({
    required this.userId,
    this.isDarkMode = false,
    this.isNotificationsEnabled = true,
    this.biometricLock = false,
    this.pinEnabled = true,
    this.hideValues = false,
    this.hideNotificationContent = true,
    this.closingMonthReminder = true,
    this.dueBillsReminder = true,
    this.weeklySummary = true,
    this.aboveAverageAlert = false,
    this.budgetGoalAlert = false,
    this.unusualMovementAlert = false,
    this.aiAssistantEnabled = false,
    this.notificationFrequency = 'Semanal',
    this.notificationTime = '08:00',
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'isDarkMode': isDarkMode,
      'isNotificationsEnabled': isNotificationsEnabled,
      'biometricLock': biometricLock,
      'pinEnabled': pinEnabled,
      'hideValues': hideValues,
      'hideNotificationContent': hideNotificationContent,
      'closingMonthReminder': closingMonthReminder,
      'dueBillsReminder': dueBillsReminder,
      'weeklySummary': weeklySummary,
      'aboveAverageAlert': aboveAverageAlert,
      'budgetGoalAlert': budgetGoalAlert,
      'unusualMovementAlert': unusualMovementAlert,
      'aiAssistantEnabled': aiAssistantEnabled,
      'notificationFrequency': notificationFrequency,
      'notificationTime': notificationTime,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      userId: json['userId'] as String,
      isDarkMode: json['isDarkMode'] ?? false,
      isNotificationsEnabled: json['isNotificationsEnabled'] ?? true,
      biometricLock: json['biometricLock'] ?? false,
      pinEnabled: json['pinEnabled'] ?? true,
      hideValues: json['hideValues'] ?? false,
      hideNotificationContent: json['hideNotificationContent'] ?? true,
      closingMonthReminder: json['closingMonthReminder'] ?? true,
      dueBillsReminder: json['dueBillsReminder'] ?? true,
      weeklySummary: json['weeklySummary'] ?? true,
      aboveAverageAlert: json['aboveAverageAlert'] ?? false,
      budgetGoalAlert: json['budgetGoalAlert'] ?? false,
      unusualMovementAlert: json['unusualMovementAlert'] ?? false,
      aiAssistantEnabled: json['aiAssistantEnabled'] ?? false,
      notificationFrequency: json['notificationFrequency'] ?? 'Semanal',
      notificationTime: json['notificationTime'] ?? '08:00',
    );
  }

  void updateSettings(UserSettings newSettings) {
    isDarkMode = newSettings.isDarkMode;
    isNotificationsEnabled = newSettings.isNotificationsEnabled;
    biometricLock = newSettings.biometricLock;
    pinEnabled = newSettings.pinEnabled;
    hideValues = newSettings.hideValues;
    hideNotificationContent = newSettings.hideNotificationContent;
    closingMonthReminder = newSettings.closingMonthReminder;
    dueBillsReminder = newSettings.dueBillsReminder;
    weeklySummary = newSettings.weeklySummary;
    aboveAverageAlert = newSettings.aboveAverageAlert;
    budgetGoalAlert = newSettings.budgetGoalAlert;
    unusualMovementAlert = newSettings.unusualMovementAlert;
    aiAssistantEnabled = newSettings.aiAssistantEnabled;
    notificationFrequency = newSettings.notificationFrequency;
    notificationTime = newSettings.notificationTime;
  }
}