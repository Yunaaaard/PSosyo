import 'package:get/get.dart';
import 'package:p_sosyo/app/modules/landing_page/pages/landing_page.dart';
import 'package:p_sosyo/app/modules/register_number/pages/register_page.dart';
import 'package:p_sosyo/app/modules/verify_otp/pages/otp_page.dart';
import 'package:p_sosyo/app/modules/verify_otp/bindings/otp_binding.dart';
import 'package:p_sosyo/app/modules/dashboard_page/pages/initial_dashboard.dart';
import 'package:p_sosyo/app/modules/dashboard_page/bindings/dashboard_binding.dart';
import 'package:p_sosyo/app/modules/check_eligiblity/pages/about_yourself.dart';
import 'package:p_sosyo/app/modules/check_eligiblity/pages/employment_income.dart';
import 'package:p_sosyo/app/modules/check_eligiblity/pages/upload_id.dart';
import 'package:p_sosyo/app/modules/check_eligiblity/pages/selfie_verification.dart';
import 'package:p_sosyo/app/modules/check_eligiblity/bindings/employment_income_binding.dart';
import 'package:p_sosyo/app/modules/check_eligiblity/bindings/about_yourself_binding.dart';
import 'package:p_sosyo/app/modules/check_eligiblity/bindings/selfie_verification_binding.dart';
import 'package:p_sosyo/app/modules/check_eligiblity/bindings/upload_id_binding.dart';
import 'package:p_sosyo/app/modules/loan_offer/pages/loan_offer.dart';
import 'package:p_sosyo/app/widgets/verifying_process.dart';
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
			name: AppRoutes.employmentIncome,
			page: () => const EmploymentIncomePage(),
			binding: EmploymentIncomeBinding(),
		),
		GetPage(
			name: AppRoutes.uploadId,
			page: () => const UploadIdPage(),
			binding: UploadIdBinding(),
		),
		GetPage(
			name: AppRoutes.selfieVerification,
			page: () => const SelfieVerificationPage(),
			binding: SelfieVerificationBinding(),
		),
		GetPage(
			name: AppRoutes.aboutYourself,
			page: () => const AboutYourselfPage(),
			binding: AboutYourselfBinding(),
		),
		GetPage(
			name: AppRoutes.verificationProcess,
			page: () => const VerifyingProcessPage(),
		),
		GetPage(
			name: AppRoutes.loanOffer,
			page: () => const LoanOfferPage(),
		),
	];
}
