import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

final googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    drive.DriveApi.driveFileScope,
  ],
);
