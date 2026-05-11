import 'package:get/get.dart';
import 'package:p_sosyo/app/modules/landing_page/pages/landing_page.dart';
import 'package:p_sosyo/app/modules/register_number/pages/register_page.dart';
import 'package:p_sosyo/app/modules/verify_otp/pages/otp_page.dart';
import 'package:p_sosyo/app/modules/verify_otp/bindings/otp_binding.dart';
import 'package:p_sosyo/app/modules/dashboard_page/pages/initial_dashboard.dart';
import 'package:p_sosyo/app/modules/dashboard_page/bindings/dashboard_binding.dart';
import 'package:p_sosyo/app/modules/check_eligiblity/pages/upload_id.dart';
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
		GetPage(
			name: AppRoutes.dashboard,
			page: () => const InitialDashboard(),
			binding: DashboardBinding(),
		),
		GetPage(
			name: AppRoutes.uploadId,
			page: () => const UploadIdPage(),
		),
	];
}
