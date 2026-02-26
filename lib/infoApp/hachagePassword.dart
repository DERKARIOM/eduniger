/*import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class PasswordUtil {
  public static String hashPassword(String password) {
    try {
      MessageDigest digest = MessageDigest.getInstance("SHA-256");
      byte[] hash = digest.digest(password.getBytes());
      StringBuilder hexString = new StringBuilder();

      for (byte b : hash) {
        String hex = Integer.toHexString(0xff & b);
        if (hex.length() == 1) hexString.append('0');
        hexString.append(hex);
      }
      return hexString.toString();
    } catch (NoSuchAlgorithmException e) {
    e.printStackTrace();
    return null;
    }
  }
*/
  import 'dart:convert'; // Pour utf8.encode
  import 'package:crypto/crypto.dart'; // Pour sha256

  class PasswordUtil {
  static String hashPassword(String password) {
  // 1. Convertir le String en bytes (équivalent de password.getBytes())
  var bytes = utf8.encode(password);

  // 2. Calculer le hash SHA-256 (équivalent de MessageDigest)
  var digest = sha256.convert(bytes);

  // 3. Retourner la représentation hexadécimale (équivalent de la boucle for + hexString)
  return digest.toString();
  }
  }
