import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';

final authProvider = StreamProvider<GoogleSignInAccount?>((ref) {
  return googleSignIn.onCurrentUserChanged;
});

Future<void> signIn() async {
  await googleSignIn.signInSilently();
  if (googleSignIn.currentUser == null) {
    await googleSignIn.signIn();
  }
}

Future<void> signOut() async {
  await googleSignIn.signOut();
}
