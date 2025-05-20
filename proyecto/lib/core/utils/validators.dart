class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa un correo válido';
    }
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$');
    if (!regex.hasMatch(value)) {
      return 'Formato de correo inválido';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu teléfono';
    }
    final phoneRegex = RegExp(r'^[0-9]{9}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Ingresa un teléfono válido';
    }
    return null;
  }
}
