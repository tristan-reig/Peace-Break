/// Configuration Supabase.
///
/// Pour compiler contre une autre instance :
///   flutter build apk --dart-define=SUPABASE_URL=... \
///                     --dart-define=SUPABASE_PUBLISHABLE_KEY=...
class Env {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://onndvxwytuqgctzasloa.supabase.co',
  );

  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_Sd79DOqTst3v28TU_j_NJA_BAwkrUDK',
  );
}
