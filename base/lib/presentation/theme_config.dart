import 'package:flutter/material.dart';

// ── Shared / Neutral ──────────────────────────────────────────────────────────
const Color bayaInfraWhiteColor = Color(0xFFFFFFFF);
const Color bayaInfraBlackColor = Color(0xFF000000);
const Color bayaInfraRedColor   = Colors.red;
const Color bayaInfraGreyColor = Colors.grey;
const Color bayaInfraLightCardColorDark = Color(0xFF242222);
final bayaInfraGreen = Color(0xFF00C853);
final bayaInfraGraphBluePrimary = Color(0xFF1678CF);
Color? bayaInfraGrey = Colors.grey;
final bayaInfraPaleGreen = Color(0xFF66BB6A);
final bayaInfraBlue600 = Colors.blue[600];
const Color bayaInfraBlue100 = Color(0xFFBBDEFB);
final bayaInfraBlue50 = Colors.blue[50];
final bayaInfraPaleOrange = Color(0xFFEF5350);
final bayaInfraPaleOrangeRed = Color(0xFFF44336);
const Color bayaInfraPaleLightGreen  = Color(0xFF10b981);
final bayaInfraGraphBlueSecondary = Color(0xFF003870);
const Color bayaInfraLightGreenColor = Color(0xFFA8D5BA);
const Color new1 = Color(0xFF0298DB);
const Color new2 =  Color(0xFF4A8C55);
const Color new3 = Color(0xFF4A6580);
const Color new4 = Color(0xFFE6A956);
const Color new5 = Color(0xFF7B6C8D);
const Color new6 = Color(0xffFFE162);// Pending (Open)
const Color new7 = Color(0xffFF6464);// Delayed
const Color new8 = Color(0xff91C483); // Closed
const Color new9 = Colors.orange; // Closed


const Color bayaInfraDisabledColor     = Color(0xFFAFAFAF);
const Color bayaInfraDisabledColorDark = Color(0xFF5F6368);
 
const Color bayaInfraTextColorDark = Color(0xFF7A8478);

final Color kDefaultIconLightColor = const Color(0xFFFFFFFF);
final Color kDefaultIconDarkColor  = const Color(0xDD000000);

// Semantic status
final bayaInfraRed           = const Color(0xFFE57368);
final bayaInfraAmber         = Colors.amber;
final bayaInfraYellow        = const Color(0xFFFFA726);
final bayaInfraPaleYellow    = const Color(0xFFFFCC80);
final bayaInfraLightRedColor = const Color(0xFFF28B82);

final bayaInfraGrey300 = Colors.grey[300];
final bayaInfraGrey400 = Colors.grey[400];
Color? bayaInfraGrey600  = Colors.grey[600];
Color? bayaInfraGrey100  = Colors.grey[100];
Color? bayaInfraBlack12  = Colors.black12;
Color? bayaInfraBlack12OP9  = Colors.black87.withOpacity(0.9);
Color? bayaInfraBlack54OP7  = Colors.black54.withOpacity(0.6);
Color? bayaInfraBlack12OP5  = Colors.black12.withOpacity(0.5);

// ─────────────────────────────────────────────────────────────────────────────
// THEME PALETTES
// Each palette exposes the tokens consumed by _buildLight / _buildDark below.
// ─────────────────────────────────────────────────────────────────────────────

class _Palette {
    final Color primary;
    final Color primaryDark;
    final Color primaryLight;

    // Nav bar
    final Color navSelectedLight;
    final Color navUnselectedLight;
    final Color navSelectedDark;
    final Color navUnselectedDark;

    // Surfaces – light
    final Color scaffoldLight;
    final Color cardLight;
    final Color lightCardLight;
    final Color canvasLight;
    final Color lightHint;

    // Surfaces – dark
    final Color scaffoldDark;
    final Color cardDark;
    final Color lightCardDark;
    final Color darkHint;

    // Sub-container tints
    final Color subContainerLight;
    final Color subContainerDark;

    // Semantic
    final Color lightGreen;
    final Color paleGreen;
    final Color green;
    final Color paleOrangeRed;
    final Color paleOrange;

    // Blue-family (graph / info)
    final Color blueDark;
    final Color blue100;
    final Color blue50;

    // Opacity tints (derived from primary or neutral)
    final Color? lightBlue200op9;
    final Color? lightBlue100op7;
    final Color? lightBlue100op8;

    const _Palette({
        required this.primary,
        required this.primaryDark,
        required this.primaryLight,
        required this.navSelectedLight,
        required this.navUnselectedLight,
        required this.navSelectedDark,
        required this.navUnselectedDark,
        required this.scaffoldLight,
        required this.cardLight,
        required this.lightCardLight,
        required this.canvasLight,
        required this.lightHint,
        required this.scaffoldDark,
        required this.cardDark,
        required this.lightCardDark,
        required this.darkHint,
        required this.subContainerLight,
        required this.subContainerDark,
        required this.lightGreen,
        required this.paleGreen,
        required this.green,
        required this.paleOrangeRed,
        required this.paleOrange,
        required this.blueDark,
        required this.blue100,
        required this.blue50,
        required this.lightBlue200op9,
        required this.lightBlue100op7,
        required this.lightBlue100op8,
    });
}

// ── 1. Sky Blue  #0298DB ──────────────────────────────────────────────────────
final _Palette _skyBlue = _Palette(
    primary:            const Color(0xFF0298DB),
    primaryDark:        const Color(0xFF0172A3),
    primaryLight:       const Color(0xFF4DB8F0),
    navSelectedLight:   const Color(0xFF0298DB),
    navUnselectedLight: const Color(0xFF5A8A9F),
    navSelectedDark:    const Color(0xFFB3E4F8),
    navUnselectedDark:  const Color(0xFF7BBDD6),
    scaffoldLight:      const Color(0xFFFCFEFF),
    cardLight:          const Color(0xFFFFFFFF),
    lightCardLight:     const Color(0xFFEAF4FB),
    canvasLight:        const Color(0xFFF2F7FB),
    lightHint:          const Color(0xFFF6FAFD),
    scaffoldDark:       const Color(0xFF191E22),
    cardDark:           const Color(0xFF232B31),
    lightCardDark:      const Color(0xFF1C252C),
    darkHint:           const Color(0xFF191E22),
    subContainerLight:  const Color(0xFFB3DCF0),
    subContainerDark:   const Color(0xFF1E3A4A),
    lightGreen:         const Color(0xFFB3E5D0),
    paleGreen:          const Color(0xFF5AADA0),
    green:              const Color(0xFF2E9E8A),
    paleOrangeRed:      const Color(0xFFC4613E),
    paleOrange:         const Color(0xFFD4724A),
    blueDark:           const Color(0xFF0298DB),
    blue100:            const Color(0xFFCCEBF8),
    blue50:             const Color(0xFFE6F5FC),
    lightBlue200op9:    const Color(0xFFB3DCF0).withOpacity(0.9),
    lightBlue100op7:    const Color(0xFFD6EEF8).withOpacity(0.7),
    lightBlue100op8:    const Color(0xFFD6EEF8).withOpacity(0.8),
);

// ── 2. Forest Green  #355E3B ──────────────────────────────────────────────────
final _Palette _forestGreen = _Palette(
    primary:            const Color(0xFF4A8C55),
    primaryDark:        const Color(0xFF2E6638),
    primaryLight:       const Color(0xFF7BBF87),
    navSelectedLight:   const Color(0xFF4A8C55),
    navUnselectedLight: const Color(0xFF6A8470),
    navSelectedDark:    const Color(0xFFDCE7D6),
    navUnselectedDark:  const Color(0xFF9AB8A0),
    scaffoldLight:      const Color(0xFFFCFDFB),
    cardLight:          const Color(0xFFFFFFFF),
    lightCardLight:     const Color(0xFFF2F6EF),
    canvasLight:        const Color(0xFFF5F8F2),
    lightHint:          const Color(0xFFF8FAF6),
    scaffoldDark:       const Color(0xFF1A1C1A),
    cardDark:           const Color(0xFF252825),
    lightCardDark:      const Color(0xFF202320),
    darkHint:           const Color(0xFF1A1C1A),
    subContainerLight:  const Color(0xFFC4D9C6),
    subContainerDark:   const Color(0xFF344838),
    lightGreen:         const Color(0xFFC0DDB7),
    paleGreen:          const Color(0xFF5A9E68),
    green:              const Color(0xFF3D9142),
    paleOrangeRed:      const Color(0xFFC4613E),
    paleOrange:         const Color(0xFFD4724A),
    blueDark:           const Color(0xFF506A8A),
    blue100:            const Color(0xFFDCE8F4),
    blue50:             const Color(0xFFEEF4FA),
    lightBlue200op9:    const Color(0xFFC4D9C6).withOpacity(0.9),
    lightBlue100op7:    const Color(0xFFE2EDE0).withOpacity(0.7),
    lightBlue100op8:    const Color(0xFFE2EDE0).withOpacity(0.8),
);

// ── 3. Slate  – Vintage Blueprint Retro ──────────────────────────────────────
final _Palette _slate = _Palette(
    primary:            const Color(0xFF4A6580),   // vintage ink blue
    primaryDark:        const Color(0xFF304D65),   // deep prussian
    primaryLight:       const Color(0xFF7A9BB5),   // dusty sky
    navSelectedLight:   const Color(0xFF4A6580),
    navUnselectedLight: const Color(0xFF7A8E9E),
    navSelectedDark:    const Color(0xFFBDD0DF),
    navUnselectedDark:  const Color(0xFF90AABF),
    scaffoldLight:      const Color(0xFFFAF9F5),   // near-white warm parchment
    cardLight:          const Color(0xFFFDFCF8),   // almost white cream
    lightCardLight:     const Color(0xFFE4E8E8),   // unchanged
    canvasLight:        const Color(0xFFF6F4EE),   // lighter old paper
    lightHint:          const Color(0xFFFBFAF6),   // near-white hint
    scaffoldDark:       const Color(0xFF1A2130),
    cardDark:           const Color(0xFF242E3C),
    lightCardDark:      const Color(0xFF1E2838),
    darkHint:           const Color(0xFF1A2130),
    subContainerLight:  const Color(0xFFBDCCD8),   // dusty blue-grey
    subContainerDark:   const Color(0xFF283848),
    lightGreen:         const Color(0xFFB5CCBA),   // muted sage
    paleGreen:          const Color(0xFF6A9878),
    green:              const Color(0xFF4A8260),
    paleOrangeRed:      const Color(0xFFA86858),   // warm muted rust
    paleOrange:         const Color(0xFFBE7D65),
    blueDark:           const Color(0xFF4A6580),
    blue100:            const Color(0xFFCAD8E4),
    blue50:             const Color(0xFFE2EBF2),
    lightBlue200op9:    const Color(0xFFBDCCD8).withOpacity(0.9),
    lightBlue100op7:    const Color(0xFFD4DEE8).withOpacity(0.7),
    lightBlue100op8:    const Color(0xFFD4DEE8).withOpacity(0.8),
);

// ── 4. Terracotta  – Dusty Adobe Retro ───────────────────────────────────────
final _Palette _terracotta = _Palette(
    primary:            const Color(0xFFB8745A),   // faded adobe / dusty terracotta
    primaryDark:        const Color(0xFF8C5542),   // deeper burnt sienna
    primaryLight:       const Color(0xFFD4A088),   // pale peach
    navSelectedLight:   const Color(0xFFB8745A),
    navUnselectedLight: const Color(0xFFAA8E80),
    navSelectedDark:    const Color(0xFFF2D8CC),
    navUnselectedDark:  const Color(0xFFDDB8A8),
    scaffoldLight:      const Color(0xFFFFFCFB),   // near-white warm parchment
    cardLight:          const Color(0xFFFFFBF8),   // almost white linen
    lightCardLight:     const Color(0xFFF2E8E0),   // unchanged
    canvasLight:        const Color(0xFFFAF4EF),   // lighter sandstone
    lightHint:          const Color(0xFFFEFAF7),
    scaffoldDark:       const Color(0xFF1A1A1A),
    cardDark:           const Color(0xFF252525),
    lightCardDark:      const Color(0xFF202020),
    darkHint:           const Color(0xFF1A1A1A),
    subContainerLight:  const Color(0xFFE8CABB),   // dusty peach
    subContainerDark:   const Color(0xFF503028),
    lightGreen:         const Color(0xFFCCDDBC),   // muted sage
    paleGreen:          const Color(0xFF80AA78),
    green:              const Color(0xFF5C9450),
    paleOrangeRed:      const Color(0xFFB8745A),
    paleOrange:         const Color(0xFFD4A088),
    blueDark:           const Color(0xFF6E7E94),   // faded slate-blue accent
    blue100:            const Color(0xFFDDE4EE),
    blue50:             const Color(0xFFEEF2F8),
    lightBlue200op9:    const Color(0xFFE8CABB).withOpacity(0.9),
    lightBlue100op7:    const Color(0xFFF0DBD0).withOpacity(0.7),
    lightBlue100op8:    const Color(0xFFF0DBD0).withOpacity(0.8),
);

// ── 5. Violet  #7B6C8D ───────────────────────────────────────────────────────
final _Palette _violet = _Palette(
    primary:            const Color(0xFF7B6C8D),
    primaryDark:        const Color(0xFF564966),
    primaryLight:       const Color(0xFFA494B8),
    navSelectedLight:   const Color(0xFF7B6C8D),
    navUnselectedLight: const Color(0xFF8A7E96),
    navSelectedDark:    const Color(0xFFDDD6E8),
    navUnselectedDark:  const Color(0xFFB4A8C4),
    scaffoldLight:      const  Color(0xFFFEFDFF),
    cardLight:          const Color(0xFFFFFFFF),
    lightCardLight:     const Color(0xFFF2EFF7),
    canvasLight:        const Color(0xFFF5F3F9),
    lightHint:          const Color(0xFFFAF8FC),
    scaffoldDark:       const Color(0xFF1C1A22),
    cardDark:           const Color(0xFF272430),
    lightCardDark:      const Color(0xFF211E29),
    darkHint:           const Color(0xFF1C1A22),
    subContainerLight:  const Color(0xFFCEC4DC),
    subContainerDark:   const Color(0xFF3A3048),
    lightGreen:         const Color(0xFFC0DDB7),
    paleGreen:          const Color(0xFF6BA882),
    green:              const Color(0xFF3D9142),
    paleOrangeRed:      const Color(0xFFC4613E),
    paleOrange:         const Color(0xFFD4724A),
    blueDark:           const Color(0xFF7B6C8D),
    blue100:            const Color(0xFFDDD6E8),
    blue50:             const Color(0xFFEEEBF4),
    lightBlue200op9:    const Color(0xFFCEC4DC).withOpacity(0.9),
    lightBlue100op7:    const Color(0xFFE2DCEd).withOpacity(0.7),
    lightBlue100op8:    const Color(0xFFE2DCED).withOpacity(0.8),
);

// ─────────────────────────────────────────────────────────────────────────────
// Builder helpers
// ─────────────────────────────────────────────────────────────────────────────

ThemeData _buildLight(_Palette p) => ThemeData.light().copyWith(
    textSelectionTheme: TextSelectionThemeData(
        cursorColor: bayaInfraBlackColor,
        selectionColor: p.primary.withOpacity(0.3),
        selectionHandleColor: p.primary,
    ),
    colorScheme: ColorScheme.fromSeed(
        seedColor: p.primary,
        primary: bayaInfraBlackColor,
        secondary: bayaInfraWhiteColor,
        tertiary: p.subContainerLight,
        onTertiary: bayaInfraGrey100,
        inversePrimary: p.lightBlue200op9,
        onInverseSurface: p.lightBlue100op7,
        inverseSurface: p.lightBlue100op8,
    ),
    hintColor: p.lightHint,
    dialogTheme: DialogThemeData(backgroundColor: p.scaffoldLight),
    cardColor: p.cardLight,
    scaffoldBackgroundColor: p.scaffoldLight,
    highlightColor: p.lightCardLight,
    primaryColor: p.primary,
    primaryColorDark: bayaInfraBlackColor,
    secondaryHeaderColor: p.primary,
    primaryColorLight: p.navSelectedLight,
    tabBarTheme: const TabBarThemeData(indicatorColor: Colors.black54),
    canvasColor: p.canvasLight,
    checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) return p.primary;
            return bayaInfraWhiteColor;
        }),
        checkColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) return bayaInfraWhiteColor;
            return null;
        }),
        side: WidgetStateBorderSide.resolveWith(
                (states) => BorderSide(color: bayaInfraBlackColor, width: 2.0),
        ),
    ),
    iconTheme: IconThemeData(color: kDefaultIconDarkColor),
    disabledColor: bayaInfraDisabledColor,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bayaInfraWhiteColor,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: IconThemeData(color: p.navSelectedLight, size: 24),
        selectedLabelStyle: const TextStyle(fontSize: 16),
        unselectedIconTheme: const IconThemeData(color: bayaInfraBlackColor, size: 24),
        unselectedLabelStyle: const TextStyle(fontSize: 16),
        selectedItemColor: p.navSelectedLight,
        unselectedItemColor: p.navUnselectedLight,
    ),
    shadowColor: p.primary,
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: p.primary),
    ),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(backgroundColor: p.primary),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(backgroundColor: p.primary),
    ),
    textTheme: const TextTheme(
        displayLarge:   TextStyle(fontFamily: 'PlusJakartaSans', color: bayaInfraBlackColor, fontWeight: FontWeight.w700, fontSize: 28),
        displayMedium:  TextStyle(fontFamily: 'PlusJakartaSans', color: bayaInfraBlackColor, fontWeight: FontWeight.w700, fontSize: 26),
        displaySmall:   TextStyle(fontFamily: 'PlusJakartaSans', color: bayaInfraBlackColor, fontWeight: FontWeight.w600, fontSize: 24),
        headlineLarge:  TextStyle(fontFamily: 'PlusJakartaSans', color: bayaInfraBlackColor, fontWeight: FontWeight.w700, fontSize: 22),
        headlineMedium: TextStyle(fontFamily: 'PlusJakartaSans', color: bayaInfraBlackColor, fontWeight: FontWeight.w700, fontSize: 19),
        headlineSmall:  TextStyle(fontFamily: 'PlusJakartaSans', color: bayaInfraBlackColor, fontWeight: FontWeight.w600, fontSize: 19),
        titleLarge:     TextStyle(fontFamily: 'PlusJakartaSans', color: bayaInfraBlackColor, fontWeight: FontWeight.w700, fontSize: 15),
        titleMedium:    TextStyle(fontFamily: 'PlusJakartaSans', color: bayaInfraBlackColor, fontWeight: FontWeight.w600, fontSize: 14),
        titleSmall:     TextStyle(fontFamily: 'PlusJakartaSans', color: bayaInfraBlackColor, fontWeight: FontWeight.w600, fontSize: 13),
        labelLarge:     TextStyle(fontFamily: 'PlusJakartaSans', color: bayaInfraBlackColor, fontWeight: FontWeight.w700, fontSize: 12),
        labelMedium:    TextStyle(fontFamily: 'PlusJakartaSans', color: bayaInfraBlackColor, fontWeight: FontWeight.w500, fontSize: 11),
        labelSmall:     TextStyle(fontFamily: 'PlusJakartaSans', color: bayaInfraTextColorDark, fontWeight: FontWeight.w500, fontSize: 10),
        bodyLarge:      TextStyle(fontFamily: 'PlusJakartaSans', color: bayaInfraBlackColor, fontWeight: FontWeight.w500, fontSize: 10),
        bodyMedium:     TextStyle(fontFamily: 'PlusJakartaSans', color: bayaInfraTextColorDark, fontWeight: FontWeight.w500, fontSize: 10),
        bodySmall:      TextStyle(fontFamily: 'PlusJakartaSans', color: bayaInfraTextColorDark, fontWeight: FontWeight.w400, fontSize: 10),
    ),
    appBarTheme: const AppBarTheme(
        titleTextStyle: TextStyle(fontFamily: 'NunitoSans', color: bayaInfraBlackColor, fontWeight: FontWeight.w900),
    ),
    inputDecorationTheme: InputDecorationTheme(
        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade500)),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade500)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: p.primary, width: 2.0)),
        errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
        focusedErrorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2.0)),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: .5, color: bayaInfraWhiteColor),
                borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: .5, color: bayaInfraDisabledColor),
                borderRadius: BorderRadius.circular(10),
            ),
            errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: .5, color: bayaInfraRedColor),
                borderRadius: BorderRadius.circular(10),
            ),
            disabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: .5, color: bayaInfraDisabledColor),
                borderRadius: BorderRadius.circular(10),
            ),
        ),
    ),
);

ThemeData _buildDark(_Palette p) => ThemeData.dark().copyWith(
    textSelectionTheme: TextSelectionThemeData(
        cursorColor: bayaInfraWhiteColor,
        selectionColor: p.primary.withOpacity(0.4),
        selectionHandleColor: p.navSelectedDark,
    ),
    colorScheme: ColorScheme.fromSeed(
        seedColor: p.primary,
        brightness: Brightness.dark,
        primary: bayaInfraWhiteColor,
        secondary: bayaInfraBlackColor,
        tertiary: p.subContainerDark,
        onTertiary: bayaInfraGrey600,
        inversePrimary: bayaInfraBlack12OP9,
        onInverseSurface: bayaInfraBlack54OP7,
        inverseSurface: bayaInfraBlack12OP5,
    ),
    scaffoldBackgroundColor: p.scaffoldDark,
    shadowColor: bayaInfraBlackColor,
    dialogTheme: DialogThemeData(backgroundColor: p.scaffoldDark),
    cardColor: p.cardDark,
    primaryColor: p.primary,
    primaryColorLight: p.navSelectedDark,
    primaryColorDark: bayaInfraBlackColor,
    hintColor: p.darkHint,
    tabBarTheme: const TabBarThemeData(indicatorColor: Colors.white),
    highlightColor: p.lightCardDark,
    checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) return p.primary;
            return p.cardDark;
        }),
        checkColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) return bayaInfraWhiteColor;
            return null;
        }),
        side: WidgetStateBorderSide.resolveWith(
                (states) => const BorderSide(color: bayaInfraWhiteColor, width: 2.0),
        ),
    ),
    canvasColor: p.scaffoldDark,
    iconTheme: IconThemeData(color: kDefaultIconLightColor),
    disabledColor: bayaInfraDisabledColorDark,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: p.scaffoldDark,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: IconThemeData(color: p.navSelectedDark, size: 24),
        selectedLabelStyle: const TextStyle(fontSize: 16),
        unselectedIconTheme: const IconThemeData(color: bayaInfraWhiteColor, size: 24),
        unselectedLabelStyle: const TextStyle(fontSize: 16),
        selectedItemColor: p.navSelectedDark,
        unselectedItemColor: p.navUnselectedDark,
    ),
    secondaryHeaderColor: bayaInfraWhiteColor,
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: p.primary),
    ),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(backgroundColor: p.primary),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(backgroundColor: p.primary),
    ),
    textTheme: const TextTheme(
        displayLarge:   TextStyle(fontFamily: 'NunitoSans', color: bayaInfraWhiteColor, fontWeight: FontWeight.w700, fontSize: 28),
        displayMedium:  TextStyle(fontFamily: 'NunitoSans', color: bayaInfraWhiteColor, fontWeight: FontWeight.w700, fontSize: 26),
        displaySmall:   TextStyle(fontFamily: 'NunitoSans', color: bayaInfraWhiteColor, fontWeight: FontWeight.w600, fontSize: 24),
        headlineLarge:  TextStyle(fontFamily: 'NunitoSans', color: bayaInfraWhiteColor, fontWeight: FontWeight.w700, fontSize: 22),
        headlineMedium: TextStyle(fontFamily: 'NunitoSans', color: bayaInfraWhiteColor, fontWeight: FontWeight.w700, fontSize: 19),
        headlineSmall:  TextStyle(fontFamily: 'NunitoSans', color: bayaInfraWhiteColor, fontWeight: FontWeight.w600, fontSize: 19),
        titleLarge:     TextStyle(fontFamily: 'NunitoSans', color: bayaInfraWhiteColor, fontWeight: FontWeight.w700, fontSize: 15),
        titleMedium:    TextStyle(fontFamily: 'NunitoSans', color: bayaInfraWhiteColor, fontWeight: FontWeight.w600, fontSize: 14),
        titleSmall:     TextStyle(fontFamily: 'NunitoSans', color: bayaInfraWhiteColor, fontWeight: FontWeight.w600, fontSize: 13),
        labelLarge:     TextStyle(fontFamily: 'NunitoSans', color: bayaInfraWhiteColor, fontWeight: FontWeight.w700, fontSize: 12),
        labelMedium:    TextStyle(fontFamily: 'NunitoSans', color: bayaInfraWhiteColor, fontWeight: FontWeight.w500, fontSize: 11),
        labelSmall:     TextStyle(fontFamily: 'NunitoSans', color: bayaInfraTextColorDark, fontWeight: FontWeight.w500, fontSize: 10),
        bodyLarge:      TextStyle(fontFamily: 'NunitoSans', color: bayaInfraWhiteColor, fontWeight: FontWeight.w500, fontSize: 10),
        bodyMedium:     TextStyle(fontFamily: 'NunitoSans', color: bayaInfraTextColorDark, fontWeight: FontWeight.w500, fontSize: 10),
        bodySmall:      TextStyle(fontFamily: 'NunitoSans', color: bayaInfraTextColorDark, fontWeight: FontWeight.w400, fontSize: 10),
    ),
    inputDecorationTheme: InputDecorationTheme(
        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: p.primaryLight, width: 2.0)),
        errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
        focusedErrorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2.0)),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: .5, color: bayaInfraWhiteColor),
                borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: .5, color: bayaInfraDisabledColor),
                borderRadius: BorderRadius.circular(10),
            ),
            errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: .5, color: bayaInfraRedColor),
                borderRadius: BorderRadius.circular(10),
            ),
            disabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(width: .5, color: bayaInfraDisabledColor),
                borderRadius: BorderRadius.circular(10),
            ),
        ),
    ),
);

// ─────────────────────────────────────────────────────────────────────────────
// Public API
// ─────────────────────────────────────────────────────────────────────────────

enum AppThemeVariant {
    skyBlue,
    forestGreen,
    slate,
    terracotta,
    violet,
}

extension AppThemeVariantLabel on AppThemeVariant {
    String get label {
        switch (this) {
            case AppThemeVariant.skyBlue:     return 'Sky Blue';
            case AppThemeVariant.forestGreen: return 'Forest Green';
            case AppThemeVariant.slate:       return 'Slate';
            case AppThemeVariant.terracotta:  return 'Terracotta';
            case AppThemeVariant.violet:      return 'Violet';
        }
    }

    Color get swatch {
        switch (this) {
            case AppThemeVariant.skyBlue:     return const Color(0xFF0298DB);
            case AppThemeVariant.forestGreen: return const Color(0xFF355E3B);
            case AppThemeVariant.slate:       return const Color(0xFF3D4C63);
            case AppThemeVariant.terracotta:  return const Color(0xFFA24936);
            case AppThemeVariant.violet:      return const Color(0xFF7B6C8D);
        }
    }

    Color get swatchLight {
        switch (this) {
            case AppThemeVariant.skyBlue:     return const Color(0xFF4DB8F0);
            case AppThemeVariant.forestGreen: return const Color(0xFF7BBF87);
            case AppThemeVariant.slate:       return const Color(0xFF6A7E9B);
            case AppThemeVariant.terracotta:  return const Color(0xFFCA7060);
            case AppThemeVariant.violet:      return const Color(0xFFA494B8);
        }
    }
}

class AppThemes {
    AppThemes._();

    // ── Sky Blue ──────────────────────────────────────────────────────────────
    static final ThemeData skyBlueTheme     = _buildLight(_skyBlue);
    static final ThemeData skyBlueThemeDark = _buildDark(_skyBlue);

    // ── Forest Green ──────────────────────────────────────────────────────────
    static final ThemeData forestGreenTheme     = _buildLight(_forestGreen);
    static final ThemeData forestGreenThemeDark = _buildDark(_forestGreen);

    // ── Slate ─────────────────────────────────────────────────────────────────
    static final ThemeData slateTheme     = _buildLight(_slate);
    static final ThemeData slateThemeDark = _buildDark(_slate);

    // ── Terracotta ────────────────────────────────────────────────────────────
    static final ThemeData terracottaTheme     = _buildLight(_terracotta);
    static final ThemeData terracottaThemeDark = _buildDark(_terracotta);

    // ── Violet ────────────────────────────────────────────────────────────────
    static final ThemeData violetTheme     = _buildLight(_violet);
    static final ThemeData violetThemeDark = _buildDark(_violet);

    /// Convenience lookup — use in MaterialApp:
    ///   theme:      AppThemes.light(selectedVariant),
    ///   darkTheme:  AppThemes.dark(selectedVariant),
    static ThemeData light(AppThemeVariant v) {
        switch (v) {
            case AppThemeVariant.skyBlue:     return skyBlueTheme;
            case AppThemeVariant.forestGreen: return forestGreenTheme;
            case AppThemeVariant.slate:       return slateTheme;
            case AppThemeVariant.terracotta:  return terracottaTheme;
            case AppThemeVariant.violet:      return violetTheme;
        }
    }

    static ThemeData dark(AppThemeVariant v) {
        switch (v) {
            case AppThemeVariant.skyBlue:     return skyBlueThemeDark;
            case AppThemeVariant.forestGreen: return forestGreenThemeDark;
            case AppThemeVariant.slate:       return slateThemeDark;
            case AppThemeVariant.terracotta:  return terracottaThemeDark;
            case AppThemeVariant.violet:      return violetThemeDark;
        }
    }

}