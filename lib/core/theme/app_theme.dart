import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
// APP COLORS
// ─────────────────────────────────────────────
class AppColors {
  AppColors._();

  // Primary — Red Cross Red
  static const Color primary        = Color(0xFFC8102E);
  static const Color primaryDark    = Color(0xFF9B0E23);
  static const Color primaryLight   = Color(0xFFFFEBEE);
  static const Color primarySurface = Color(0xFFFFF0F2);

  // Neutral
  static const Color black          = Color(0xFF0F1923);
  static const Color grey900        = Color(0xFF1C2531);
  static const Color grey800        = Color(0xFF2D3748);
  static const Color grey700        = Color(0xFF4A5568);
  static const Color grey600        = Color(0xFF718096);
  static const Color grey500        = Color(0xFF9AA5B4);
  static const Color grey400        = Color(0xFFCBD5E0);
  static const Color grey300        = Color(0xFFE2E8F0);
  static const Color grey200        = Color(0xFFEDF2F7);
  static const Color grey50         = Color(0xFFFAFAFA);
  static const Color grey100        = Color(0xFFF7FAFC);
  static const Color white          = Color(0xFFFFFFFF);

  // Semantic
  static const Color success        = Color(0xFF276749);
  static const Color successLight   = Color(0xFFE6F4EE);
  static const Color warning        = Color(0xFFB7791F);
  static const Color warningLight   = Color(0xFFFEF3C7);
  static const Color error          = Color(0xFFC53030);
  static const Color errorLight     = Color(0xFFFFF5F5);
  static const Color info           = Color(0xFF2B6CB0);
  static const Color infoLight      = Color(0xFFEBF8FF);

  // Status Colors
  static const Color statusActive      = Color(0xFF276749);
  static const Color statusInactive    = Color(0xFF718096);
  static const Color statusPending     = Color(0xFFB7791F);
  static const Color statusCompleted   = Color(0xFF2B6CB0);
  static const Color statusRejected    = Color(0xFFC53030);
  static const Color statusRestricted  = Color(0xFF6B46C1);

  // Surface
  static const Color surface          = Color(0xFFFFFFFF);
  static const Color surfaceElevated  = Color(0xFFF7FAFC);
  static const Color surfaceOverlay   = Color(0xFFF0F4F8);
  static const Color background       = Color(0xFFF4F6F9);

  // Sidebar
  static const Color sidebarBg       = Color(0xFF0F1923);
  static const Color sidebarActive   = Color(0xFFC8102E);
  static const Color sidebarText     = Color(0xFFCBD5E0);
  static const Color sidebarSubtext  = Color(0xFF718096);
  static const Color sidebarDivider  = Color(0xFF1C2531);

  // Chart colors
  static const List<Color> chartColors = [
    Color(0xFFC8102E),
    Color(0xFF2B6CB0),
    Color(0xFF276749),
    Color(0xFFB7791F),
    Color(0xFF6B46C1),
    Color(0xFF2C7A7B),
  ];
}

// ─────────────────────────────────────────────
// APP TEXT STYLES
// ─────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  // Display — for headings, bold titles
  static TextStyle displayLarge = GoogleFonts.playfairDisplay(
    fontSize: 32, fontWeight: FontWeight.w800,
    color: AppColors.black, letterSpacing: -0.5,
  );

  static TextStyle displayMedium = GoogleFonts.playfairDisplay(
    fontSize: 26, fontWeight: FontWeight.w700,
    color: AppColors.black, letterSpacing: -0.3,
  );

  static TextStyle displaySmall = GoogleFonts.playfairDisplay(
    fontSize: 22, fontWeight: FontWeight.w700,
    color: AppColors.black,
  );

  // Headings — section titles
  static TextStyle headingLarge = GoogleFonts.dmSans(
    fontSize: 18, fontWeight: FontWeight.w700,
    color: AppColors.black, letterSpacing: -0.2,
  );

  static TextStyle headingMedium = GoogleFonts.dmSans(
    fontSize: 16, fontWeight: FontWeight.w700,
    color: AppColors.black,
  );

  static TextStyle headingSmall = GoogleFonts.dmSans(
    fontSize: 14, fontWeight: FontWeight.w700,
    color: AppColors.black,
  );

  // Body
  static TextStyle bodyLarge = GoogleFonts.dmSans(
    fontSize: 15, fontWeight: FontWeight.w400,
    color: AppColors.grey800, height: 1.6,
  );

  static TextStyle bodyMedium = GoogleFonts.dmSans(
    fontSize: 13, fontWeight: FontWeight.w400,
    color: AppColors.grey700, height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.dmSans(
    fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.grey600, height: 1.5,
  );

  // Labels
  static TextStyle labelLarge = GoogleFonts.dmSans(
    fontSize: 13, fontWeight: FontWeight.w600,
    color: AppColors.grey800, letterSpacing: 0.1,
  );

  static TextStyle labelMedium = GoogleFonts.dmSans(
    fontSize: 12, fontWeight: FontWeight.w600,
    color: AppColors.grey700, letterSpacing: 0.1,
  );

  static TextStyle labelSmall = GoogleFonts.dmSans(
    fontSize: 11, fontWeight: FontWeight.w600,
    color: AppColors.grey600,
    letterSpacing: 0.5, textBaseline: TextBaseline.alphabetic,
  );

  // Caption
  static TextStyle caption = GoogleFonts.dmSans(
    fontSize: 11, fontWeight: FontWeight.w400,
    color: AppColors.grey500,
  );

  // Overline — section labels, tags
  static TextStyle overline = GoogleFonts.dmSans(
    fontSize: 10, fontWeight: FontWeight.w700,
    color: AppColors.grey600,
    letterSpacing: 1.2,
  );

  // Burmese text support
  static TextStyle burmese({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.grey700,
  }) {
    return TextStyle(
      // Padauk font used when available (add to assets/fonts/ to enable)
      // Falls back to system font which supports Burmese on iOS/Android/macOS
      fontFamily: 'Padauk',
      fontFamilyFallback: const ['Myanmar Text', 'Pyidaungsu', 'sans-serif'],
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.8, // Burmese needs more line height
    );
  }

  // Numeric — for stats, counts
  static TextStyle numeric = GoogleFonts.playfairDisplay(
    fontSize: 28, fontWeight: FontWeight.w800,
    color: AppColors.black,
  );

  static TextStyle numericSmall = GoogleFonts.playfairDisplay(
    fontSize: 20, fontWeight: FontWeight.w700,
    color: AppColors.black,
  );

  // Badge text
  static TextStyle badge = GoogleFonts.dmSans(
    fontSize: 10, fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
  );

  // Button
  static TextStyle button = GoogleFonts.dmSans(
    fontSize: 13, fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  static TextStyle buttonSmall = GoogleFonts.dmSans(
    fontSize: 12, fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );
}

// ─────────────────────────────────────────────
// APP DIMENSIONS
// ─────────────────────────────────────────────
class AppDimensions {
  AppDimensions._();

  // Spacing
  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 20.0;
  static const double xxl  = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;

  // Border radius
  static const double radiusXs  = 4.0;
  static const double radiusSm  = 6.0;
  static const double radiusMd  = 8.0;
  static const double radiusLg  = 12.0;
  static const double radiusXl  = 16.0;
  static const double radiusXxl = 24.0;
  static const double radiusFull = 999.0;

  // Layout
  static const double sidebarWidth          = 248.0;
  static const double sidebarCollapsedWidth = 68.0;
  static const double topBarHeight          = 60.0;
  static const double cardElevation         = 2.0;

  // Avatar sizes
  static const double avatarSm  = 28.0;
  static const double avatarMd  = 36.0;
  static const double avatarLg  = 48.0;
  static const double avatarXl  = 64.0;
  static const double avatarXxl = 80.0;

  // Icon sizes
  static const double iconSm  = 16.0;
  static const double iconMd  = 20.0;
  static const double iconLg  = 24.0;
  static const double iconXl  = 32.0;

  // Content max width (desktop)
  static const double contentMaxWidth = 1200.0;
}

// ─────────────────────────────────────────────
// APP SHADOWS
// ─────────────────────────────────────────────
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4, offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8, offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x06000000),
      blurRadius: 2, offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16, offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 4, offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 32, offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8, offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> primary = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.25),
      blurRadius: 12, offset: const Offset(0, 4),
    ),
  ];
}

// ─────────────────────────────────────────────
// APP THEME
// ─────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        secondary: AppColors.info,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: GoogleFonts.dmSans().fontFamily,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.grey300,
        titleTextStyle: AppTextStyles.headingMedium,
        iconTheme: const IconThemeData(color: AppColors.grey700),
        surfaceTintColor: Colors.transparent,
      ),

      // Card
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: const BorderSide(color: AppColors.grey300, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // InputDecoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.grey300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500),
        labelStyle: AppTextStyles.labelMedium,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.grey100,
        selectedColor: AppColors.primaryLight,
        labelStyle: AppTextStyles.labelSmall,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        side: BorderSide.none,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.grey200,
        thickness: 1,
        space: 0,
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        titleTextStyle: AppTextStyles.bodyLarge,
        subtitleTextStyle: AppTextStyles.bodySmall,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        ),
        titleTextStyle: AppTextStyles.headingLarge,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.grey900,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // TabBar
      tabBarTheme: TabBarThemeData(
        labelStyle: AppTextStyles.labelLarge,
        unselectedLabelStyle: AppTextStyles.labelMedium,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.grey600,
        indicatorColor: AppColors.primary,
        dividerColor: AppColors.grey300,
      ),

      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.grey900,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        textStyle: AppTextStyles.caption.copyWith(color: AppColors.white),
      ),
    );
  }
}
