import 'package:get/get.dart';
import 'package:p_sosyo/app/modules/landing_page/pages/landing_page.dart';
import 'package:p_sosyo/app/modules/register_number/pages/register_page.dart';
import 'package:p_sosyo/app/modules/verify_otp/pages/otp_page.dart';
import 'package:p_sosyo/app/modules/verify_otp/bindings/otp_binding.dart';
import '../modules/register_number/bindings/register_binding.dart';
import 'app_routes.dart';

class AppPages {
	static final pages = [
		GetPage(
			name: AppRoutes.landing,
			page: () => const LandingPage(),
		),
		GetPage(
			name: AppRoutes.register,
			page: () => const RegisterPage(),
			binding: RegisterBinding(),
		),
		GetPage(
			name: AppRoutes.verifyOtp,
			page: () => const OtpVerificationPage(),
			binding: OtpBinding(),
		),
	];
}
