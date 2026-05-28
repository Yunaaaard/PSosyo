const String _principalLogoBaseUrl =
    'https://raw.githubusercontent.com/Yunaaaard/PSosyo/main/assets/images';

String? principalLogoUrlForTitle(String? principalTitle) {
  if (principalTitle == null) {
    return null;
  }

  final normalizedTitle = _normalizePrincipalTitle(principalTitle);
  if (normalizedTitle.isEmpty) {
    return null;
  }

  if (normalizedTitle.contains('monde') || normalizedTitle.contains('nissin')) {
    return '$_principalLogoBaseUrl/monde-sample-logo.png';
  }
  if (normalizedTitle.contains('nestle')) {
    return '$_principalLogoBaseUrl/nestle-sample-logo.png';
  }
  if (normalizedTitle.contains('shell')) {
    return '$_principalLogoBaseUrl/shell-sample-logo.png';
  }
  if (normalizedTitle.contains('nutri') || normalizedTitle.contains('asia')) {
    return '$_principalLogoBaseUrl/nutriasia-sample-logo.png';
  }
  if (normalizedTitle.contains('cdo')) {
    return '$_principalLogoBaseUrl/cdo-sample-logo.png';
  }

  return null;
}

String _normalizePrincipalTitle(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
}