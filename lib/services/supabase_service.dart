// lib/services/supabase_service.dart
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import '../models/puzzle.dart';
import '../core/constants.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get _client => Supabase.instance.client;

  // ─── Auth ─────────────────────────────────────────────────────────────────

  Stream<AuthState> get authStream => _client.auth.onAuthStateChange;
  User? get currentUser => _client.auth.currentUser;
  bool get isSignedIn => currentUser != null;

  Future<void> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    final googleUser   = await googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');
    final auth = await googleUser.authentication;
    if (auth.idToken == null) throw Exception('Google idToken null geldi');
    await _client.auth.signInWithIdToken(
      provider:    OAuthProvider.google,
      idToken:     auth.idToken!,
      accessToken: auth.accessToken,
    );
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email:    email,
      password: password,
    );
    // Supabase e-posta doğrulaması kapalıysa session hemen gelir
    // Açıksa kullanıcı mail onaylayana kadar session gelmez
    if (response.user == null) {
      throw Exception('Kayıt başarısız');
    }
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _client.auth.signOut();
  }

  // ─── Profile ──────────────────────────────────────────────────────────────

  Future<UserProfile?> getProfile() async {
    final userId = currentUser?.id;
    if (userId == null) return null;
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return UserProfile.fromMap(data);
  }

  Future<void> updateUsername(String username) async {
    await _client
        .from('profiles')
        .update({'username': username, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', currentUser!.id);
  }

  // ─── Daily Puzzle ─────────────────────────────────────────────────────────

  Future<DailyPuzzle?> getDailyPuzzle({DateTime? date}) async {
    final d = (date ?? DateTime.now());
    final dateStr = '${d.year.toString().padLeft(4,'0')}-'
        '${d.month.toString().padLeft(2,'0')}-'
        '${d.day.toString().padLeft(2,'0')}';
    final data = await _client
        .from('daily_puzzles')
        .select()
        .eq('date', dateStr)
        .maybeSingle();
    if (data == null) return null;
    return DailyPuzzle.fromMap(data);
  }

  Future<bool> hasDailyCompleted(String dailyPuzzleId) async {
    final userId = currentUser?.id;
    if (userId == null) return false;
    final data = await _client
        .from('completions')
        .select('id')
        .eq('user_id', userId)
        .eq('daily_puzzle_id', dailyPuzzleId)
        .maybeSingle();
    return data != null;
  }

  // ─── Completions & Diamonds ───────────────────────────────────────────────

  Future<void> recordCompletion({
    required Difficulty difficulty,
    required int timeTaken,
    String? dailyPuzzleId,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) return;

    final isDaily    = dailyPuzzleId != null;
    final puzzleType = isDaily ? 'daily' : difficulty.labelEn;
    final diamonds   = isDaily ? AppConstants.diamondsDaily : difficulty.diamonds;

    // Daily duplicate kontrolü
    if (isDaily) {
      final existing = await _client
          .from('completions')
          .select('id')
          .eq('user_id', userId)
          .eq('daily_puzzle_id', dailyPuzzleId)
          .maybeSingle();
      if (existing != null) return;
    }

    await _client.from('completions').insert({
      'user_id':         userId,
      'puzzle_type':     puzzleType,
      'daily_puzzle_id': dailyPuzzleId,
      'time_taken':      timeTaken,
      'diamonds_earned': diamonds,
    });

    await _client.rpc('award_diamonds', params: {
      'p_user_id':          userId,
      'p_amount':           diamonds,
      'p_transaction_type': 'puzzle_complete',
      'p_description':      'Completed $puzzleType puzzle',
    });

    if (isDaily) {
      final now      = DateTime.now();
      final hasBonus = await _client.rpc<bool>('check_monthly_bonus', params: {
        'p_user_id': userId,
        'p_year':    now.year,
        'p_month':   now.month,
      });
      if (hasBonus == true) {
        await _client.rpc('award_diamonds', params: {
          'p_user_id':          userId,
          'p_amount':           AppConstants.diamondsMonthly,
          'p_transaction_type': 'monthly_bonus',
          'p_description':      'Monthly completion bonus',
        });
      }
    }
  }

  Future<void> deductDiamond() async {
    final userId = currentUser?.id;
    if (userId == null) return;
    await _client.rpc('award_diamonds', params: {
      'p_user_id':          userId,
      'p_amount':           -1,
      'p_transaction_type': 'hint_used',
      'p_description':      'Hint used',
    });
  }

  // ─── Monthly calendar ─────────────────────────────────────────────────────

  Future<Set<String>> getMonthlyCompletions(int year, int month) async {
    final userId = currentUser?.id;
    if (userId == null) return {};
    final data = await _client
        .from('completions')
        .select('daily_puzzles(date)')
        .eq('user_id', userId)
        .eq('puzzle_type', 'daily');
    final Set<String> result = {};
    for (final row in data as List) {
      final dp = row['daily_puzzles'];
      if (dp == null) continue;
      final dateStr = dp['date'] as String;
      final d = DateTime.parse(dateStr);
      if (d.year == year && d.month == month) result.add(dateStr);
    }
    return result;
  }

  Future<Map<String, int>> getCompletionStats() async {
    final userId = currentUser?.id;
    if (userId == null) return {};
    final data = await _client
        .from('completions')
        .select('puzzle_type')
        .eq('user_id', userId);
    final Map<String, int> stats = {};
    for (final row in data as List) {
      final type = row['puzzle_type'] as String;
      stats[type] = (stats[type] ?? 0) + 1;
    }
    return stats;
  }

  Future<List<Map<String, dynamic>>> getDiamondHistory({int limit = 20}) async {
    final userId = currentUser?.id;
    if (userId == null) return [];
    return await _client
        .from('diamond_transactions')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);
  }

  Future<int> getMonthlyPuzzleCount(int year, int month) async {
    final data = await _client
        .from('daily_puzzles')
        .select('id')
        .gte('date', '$year-${month.toString().padLeft(2,'0')}-01')
        .lte('date', '$year-${month.toString().padLeft(2,'0')}-31');
    return (data as List).length;
  }
}