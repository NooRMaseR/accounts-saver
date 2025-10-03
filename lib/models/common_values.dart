/// an enum class for storing the stored keys in the `SharedPreferences`
enum SharedPrefsKeys {
  // normal enums for search bar options
  emailType("email type"),
  email("email"),
  password("password"),
  all("all"),

  /// a Key for current stored search bar selected option
  searchBy("search_by"),

  /// a Key for current stored theme
  theme("Theme"),

  /// a Key to check if the biomitric when app open is enabled or not
  biometric("bio"),

  /// a Key to check the saved locale 
  locale("locale"),

  /// a Key to check if the account details are hidden or not
  hideAccountDetails("hide_details");

  const SharedPrefsKeys(this.value);
  final String value;
}
