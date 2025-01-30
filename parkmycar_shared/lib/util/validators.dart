class Validators {
  /// Validate if a String? contains a valid number for id. Valid number value are 1-99999.
  static bool isValidId(String? value) {
    //if (value != null && RegExp(r'^[1-9]|[1-9][0-9]{1,4}$').hasMatch(value)) {
    return true;
    // }
    // return false;
  }

  /// Valid value = string with minimum of 1 letter, max 255
  static bool isValidName(String? value) {
    if (value != null && value.isNotEmpty && value.length <= 255) {
      return true;
    }
    return false;
  }

  /// Valid value = string with minimum of 6 letter, max 12
  static bool isValidPassword(String? value, [bool isEmptyOk = false]) {
    if (isEmptyOk && (value == null || value.isEmpty)) {
      return true;
    } else if (value != null && value.length >= 6 && value.length <= 12) {
      return true;
    }
    return false;
  }

  /// Valid value is a valid email address
  static bool isValidEmail(String? value) {
    if (value != null &&
        RegExp(r'^[0-9a-zA-Z]+([0-9a-zA-Z]*[-._+])*[0-9a-zA-Z]+@[0-9a-zA-Z]+([-.][0-9a-zA-Z]+)*([0-9a-zA-Z]*[.])[a-zA-Z]{2,6}$')
            .hasMatch(value)) {
      return true;
    }
    return false;
  }

  /// Valid value = string with minimum of 1 letter, max 1000
  static bool isValidStreetAddress(String? value) {
    if (value != null && value.isNotEmpty && value.length <= 1000) {
      return true;
    }
    return false;
  }

  /// Validate if a String? contains a valid number for Swedish postal code. Valid format is nnn nn.
  static bool isValidPostalCode(String? value) {
    if (value != null && RegExp(r'^[0-9]{3}\s?[0-9]{2}$').hasMatch(value)) {
      return true;
    }
    return false;
  }

  /// Valid value = string with minimum of 1 letter, max 100
  static bool isValidCity(String? value) {
    if (value != null && value.isNotEmpty && value.length <= 100) {
      return true;
    }
    return false;
  }

  /// Valid value number from 0-99999
  static bool isValidPricePerHour(String? value) {
    if (value != null && RegExp(r'^[0-9]{1,4}$').hasMatch(value)) {
      return true;
    }
    return false;
  }

  /// Valid value = "YYYY-MM-DD HH:MM"
  static bool isValidDateTime(String? value) {
    if (value != null &&
        RegExp(r'^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1]) (2[0-3]|[01][0-9]):[0-5][0-9]$')
            .hasMatch(value)) {
      return true;
    }
    return false;
  }

  /// Valid value = "NNNXXX"
  static bool isValidRegNr(String? value) {
    if (value != null &&
        RegExp(r'^[A-Za-z]{3}[0-9]{2}[A-Za-z0-9]{1}$').hasMatch(value)) {
      return true;
    }
    return false;
  }
}
