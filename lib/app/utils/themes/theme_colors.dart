import 'package:flutter/material.dart';

/// PSOSYO COLOR THEMES AND STYLES MWAAHAHAHHAHA

@immutable
class PsosyoThemeColors extends ThemeExtension<PsosyoThemeColors> {
	const PsosyoThemeColors({
		required this.primaryPurple,
		required this.lightPurple,
		required this.surface,
		required this.titleGrey,
		required this.bodyGrey,
		required this.darkText,
		required this.accentBlue,
	});

	final Color primaryPurple;
	final Color lightPurple;
	final Color surface;
	final Color titleGrey;
	final Color bodyGrey;
	final Color darkText;
	final Color accentBlue;

	@override
	PsosyoThemeColors copyWith({
		Color? primaryPurple,
		Color? lightPurple,
		Color? surface,
		Color? titleGrey,
		Color? bodyGrey,
		Color? darkText,
		Color? accentBlue,
	}) {
		return PsosyoThemeColors(
			primaryPurple: primaryPurple ?? this.primaryPurple,
			lightPurple: lightPurple ?? this.lightPurple,
			surface: surface ?? this.surface,
			titleGrey: titleGrey ?? this.titleGrey,
			bodyGrey: bodyGrey ?? this.bodyGrey,
			darkText: darkText ?? this.darkText,
			accentBlue: accentBlue ?? this.accentBlue,
		);
	}

	@override
	PsosyoThemeColors lerp(ThemeExtension<PsosyoThemeColors>? other, double t) {
		if (other is! PsosyoThemeColors) return this;

		return PsosyoThemeColors(
			primaryPurple: Color.lerp(primaryPurple, other.primaryPurple, t) ?? primaryPurple,
			lightPurple: Color.lerp(lightPurple, other.lightPurple, t) ?? lightPurple,
			surface: Color.lerp(surface, other.surface, t) ?? surface,
			titleGrey: Color.lerp(titleGrey, other.titleGrey, t) ?? titleGrey,
			bodyGrey: Color.lerp(bodyGrey, other.bodyGrey, t) ?? bodyGrey,
			darkText: Color.lerp(darkText, other.darkText, t) ?? darkText,
			accentBlue: Color.lerp(accentBlue, other.accentBlue, t) ?? accentBlue,
		);
	}
}

class AppColors {
	// Primary color: #6533E7
	static const Color primary = Color(0xFF6533E7);

	static const PsosyoThemeColors psosyo = PsosyoThemeColors(
		primaryPurple: Color(0xFF6D3DF4),
		lightPurple: Color(0xFFF2EFFF),
		surface: Color(0xFFF6F6F8),
		titleGrey: Color(0xFFA6ABB5),
		bodyGrey: Color(0xFF5D6470),
		darkText: Color(0xFF2F333A),
		accentBlue: Color(0xFF3F66F4),
	);

	// Button background uses same primary color
	static const Color buttonBackground = primary;

	// Button text color
	static const Color buttonText = Colors.white;
}

class AppThemes {
	static final ThemeData lightTheme = ThemeData(
		fontFamily: 'Poppins',
		scaffoldBackgroundColor: AppColors.psosyo.surface,
		colorScheme: ColorScheme.fromSeed(
			seedColor: AppColors.primary,
			primary: AppColors.primary,
			secondary: AppColors.psosyo.accentBlue,
			surface: AppColors.psosyo.surface,
		).copyWith(
			onPrimary: Colors.white,
			onSecondary: Colors.white,
		),
		extensions: const <ThemeExtension<dynamic>>[
			AppColors.psosyo,
		],
	);

	static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
		backgroundColor: AppColors.buttonBackground,
		foregroundColor: AppColors.buttonText,
		textStyle: const TextStyle(
			fontWeight: FontWeight.w500,
			letterSpacing: 1,
			fontFamily: 'Poppins',
			fontSize: 25,
		),
		shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
		padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
		minimumSize: const Size(500, 65), // width, height
		maximumSize: const Size(500, 65),
	);
}

