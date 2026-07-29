import 'package:flutter/material.dart';

class AuthColors {
  static const Color primaryBlue = Color(0xFF2C2C9E);
  static const Color darkBlue = Color(0xFF101038);
  static const Color background = Color(0xFFF8F8F8);
  static const Color textDark = Color(0xFF101038);
  static const Color textGrey = Color(0xFF8D8C8C);
  static const Color inputBorder = Color(0xFFD9D9D9);
  static const Color white = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFDC2626);
}

// Imagem de fundo do topo
class AuthHeaderGradient extends StatelessWidget {
  const AuthHeaderGradient({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      color: AuthColors.darkBlue,
      child: Image.asset(
        'assets/backgrounds/fundo_jbs.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: 300,
      ),
    );
  }
}

// Card com borda arredondada no topo
class AuthBottomCard extends StatelessWidget {
  final Widget child;

  const AuthBottomCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
      decoration: const BoxDecoration(
        color: AuthColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: child,
    );
  }
}

// Logo
class AuthBrandTitle extends StatelessWidget {
  const AuthBrandTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/icons/logo_seara_jbs.png',
          height: 64,
        ),
      ],
    );
  }
}
// Input padrão com label acima
class AppInput extends StatefulWidget {
  final String label;
  final String? hintText;
  final bool isPassword;
  final bool enabled;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const AppInput({
    super.key,
    required this.label,
    this.hintText,
    this.isPassword = false,
    this.enabled = true,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.onChanged,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscure,
      keyboardType: widget.keyboardType,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        errorText: widget.errorText,

        floatingLabelBehavior: FloatingLabelBehavior.auto,

        labelStyle: const TextStyle(
          color: AuthColors.textGrey,
          fontSize: 12,
        ),

        floatingLabelStyle: const TextStyle(
          color: AuthColors.textGrey,
          fontSize: 12,
        ),

        filled: true,
        fillColor:
            widget.enabled ? AuthColors.white : AuthColors.background,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AuthColors.inputBorder,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AuthColors.inputBorder,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AuthColors.primaryBlue,
            width: 2,
          ),
        ),

        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AuthColors.inputBorder,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AuthColors.error,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AuthColors.error,
            width: 2,
          ),
        ),

        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AuthColors.textGrey,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscure = !_obscure;
                  });
                },
              )
            : null,

        isDense: true,
      ),
    );
  }
}

// Botão primário arredondado
class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AuthColors.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: AuthColors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}