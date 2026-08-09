import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../styles/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;

  /// Gợi ý autofill (AutofillHints.email, .password, .oneTimeCode...) để bàn
  /// phím hệ thống và trình quản lý mật khẩu điền tự động được.
  final Iterable<String>? autofillHints;

  /// Giới hạn số ký tự (ví dụ 6 cho mã OTP). Ẩn bộ đếm mặc định.
  final int? maxLength;

  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.textInputAction,
    this.readOnly = false,
    this.maxLines,
    this.minLines,
    this.autofillHints,
    this.maxLength,
    this.inputFormatters,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nhãn hiển thị đã được gộp vào semantics của chính TextFormField bên
        // dưới, nên loại khỏi cây semantics để screen reader không đọc hai lần.
        ExcludeSemantics(
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.isLight ? AppColors.textPrimary : AppColors.textCyan,
              fontFamily: 'Inter',
            ),
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          textField: true,
          label: widget.label,
          child: TextFormField(
          controller: widget.controller,
          readOnly: widget.readOnly,
          obscureText: widget.isPassword && _obscure,
          keyboardType: widget.keyboardType,
          maxLines: widget.isPassword ? 1 : (widget.maxLines ?? 1),
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          autofillHints: widget.autofillHints,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          textInputAction: widget.textInputAction,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontFamily: 'Inter',
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            counterText: '',
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon,
                    color: AppColors.primary, size: 20)
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
            filled: true,
            fillColor: AppColors.cardSurfaceMuted,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          ),
        ),
      ],
    );
  }
}
