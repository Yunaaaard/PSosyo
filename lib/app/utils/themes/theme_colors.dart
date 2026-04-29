import 'package:flutter/material.dart';

/// PSOSYO COLOR THEMES AND STYLES MWAAHAHAHHAHA

class AppColors {
	// Primary color: #6533E7
	static const Color primary = Color(0xFF6533E7);

	// Button background uses same primary color
	static const Color buttonBackground = primary;

	// Button text color
	static const Color buttonText = Colors.white;
}

class AppThemes {
	static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
		backgroundColor: AppColors.buttonBackground,
		foregroundColor: AppColors.buttonText,
		textStyle: const TextStyle(fontWeight: FontWeight.w600),
		shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
		padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
	);
}

