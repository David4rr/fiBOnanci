package com.fibonanci.app.fibonanci_app

import android.app.Activity
import android.app.KeyguardManager
import android.content.Context
import android.hardware.biometrics.BiometricManager
import android.hardware.biometrics.BiometricPrompt
import android.os.Build
import android.os.CancellationSignal
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import android.view.WindowManager
import java.security.KeyStore
import java.security.SecureRandom
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

object SecurityVaultHelper {
    private const val ANDROID_KEYSTORE = "AndroidKeyStore"
    private const val MASTER_KEY_ALIAS = "fibonanci_master_key_v1"
    private const val TRANSFORMATION = "AES/GCM/NoPadding"
    private const val GCM_TAG_BITS = 128
    private const val CIPHER_PREFIX = "ENC_V1:"

    private const val VAULT_PREFS = "fibonanci_security_vault"
    private const val KEY_DB_SECRET = "encrypted_db_key_v1"
    private const val KEY_BIOMETRIC_ENABLED = "biometric_lock_enabled"
    private const val KEY_PRIVACY_SCREEN = "privacy_screen_enabled"

    const val REQUEST_CONFIRM_CREDENTIAL = 9412

    @Synchronized
    private fun getOrCreateMasterKey(): SecretKey {
        val keyStore = KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) }
        val existing = keyStore.getEntry(MASTER_KEY_ALIAS, null) as? KeyStore.SecretKeyEntry
        if (existing != null) return existing.secretKey

        val keyGenerator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, ANDROID_KEYSTORE)
        val spec = KeyGenParameterSpec.Builder(
            MASTER_KEY_ALIAS,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
        )
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setKeySize(256)
            .setRandomizedEncryptionRequired(true)
            .build()
        keyGenerator.init(spec)
        return keyGenerator.generateKey()
    }

    fun encryptString(plainText: String): String {
        return try {
            val cipher = Cipher.getInstance(TRANSFORMATION)
            cipher.init(Cipher.ENCRYPT_MODE, getOrCreateMasterKey())
            val iv = Base64.encodeToString(cipher.iv, Base64.NO_WRAP)
            val encrypted = Base64.encodeToString(
                cipher.doFinal(plainText.toByteArray(Charsets.UTF_8)),
                Base64.NO_WRAP
            )
            "$CIPHER_PREFIX$iv:$encrypted"
        } catch (_: Exception) {
            plainText
        }
    }

    fun decryptString(raw: String): String {
        if (!raw.startsWith(CIPHER_PREFIX)) return raw
        return try {
            val payload = raw.removePrefix(CIPHER_PREFIX)
            val sepIdx = payload.indexOf(':')
            if (sepIdx <= 0) return raw
            val iv = Base64.decode(payload.substring(0, sepIdx), Base64.NO_WRAP)
            val cipherBytes = Base64.decode(payload.substring(sepIdx + 1), Base64.NO_WRAP)
            val cipher = Cipher.getInstance(TRANSFORMATION)
            cipher.init(Cipher.DECRYPT_MODE, getOrCreateMasterKey(), GCMParameterSpec(GCM_TAG_BITS, iv))
            String(cipher.doFinal(cipherBytes), Charsets.UTF_8)
        } catch (_: Exception) {
            "[]"
        }
    }

    @Synchronized
    fun getOrCreateDatabaseKey(context: Context): String {
        val prefs = context.getSharedPreferences(VAULT_PREFS, Context.MODE_PRIVATE)
        val stored = prefs.getString(KEY_DB_SECRET, null)
        if (!stored.isNullOrBlank()) {
            val decrypted = decryptString(stored)
            if (decrypted.length == 64 && decrypted != "[]") {
                return decrypted
            }
        }
        val randomBytes = ByteArray(32)
        SecureRandom().nextBytes(randomBytes)
        val hexKey = randomBytes.joinToString("") { "%02x".format(it) }
        val encryptedKey = encryptString(hexKey)
        prefs.edit().putString(KEY_DB_SECRET, encryptedKey).commit()
        return hexKey
    }

    fun isDeviceSecure(context: Context): Boolean {
        val km = context.getSystemService(Context.KEYGUARD_SERVICE) as? KeyguardManager
        return km?.isDeviceSecure == true
    }

    fun isBiometricLockEnabled(context: Context): Boolean {
        val prefs = context.getSharedPreferences(VAULT_PREFS, Context.MODE_PRIVATE)
        return prefs.getBoolean(KEY_BIOMETRIC_ENABLED, false)
    }

    fun setBiometricLockEnabled(context: Context, enabled: Boolean) {
        val prefs = context.getSharedPreferences(VAULT_PREFS, Context.MODE_PRIVATE)
        prefs.edit().putBoolean(KEY_BIOMETRIC_ENABLED, enabled).apply()
    }

    fun isPrivacyScreenEnabled(context: Context): Boolean {
        val prefs = context.getSharedPreferences(VAULT_PREFS, Context.MODE_PRIVATE)
        return prefs.getBoolean(KEY_PRIVACY_SCREEN, false)
    }

    fun applyPrivacyScreen(activity: Activity, enabled: Boolean) {
        val prefs = activity.applicationContext.getSharedPreferences(VAULT_PREFS, Context.MODE_PRIVATE)
        prefs.edit().putBoolean(KEY_PRIVACY_SCREEN, enabled).apply()
        activity.runOnUiThread {
            if (enabled) {
                activity.window?.setFlags(
                    WindowManager.LayoutParams.FLAG_SECURE,
                    WindowManager.LayoutParams.FLAG_SECURE
                )
            } else {
                activity.window?.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
            }
        }
    }

    @Suppress("DEPRECATION")
    fun authenticateUser(
        activity: Activity,
        reason: String,
        onResult: (Boolean) -> Unit,
        registerPendingResult: ((Boolean) -> Unit) -> Unit
    ) {
        val km = activity.getSystemService(Context.KEYGUARD_SERVICE) as? KeyguardManager
        if (km == null || !km.isDeviceSecure) {
            onResult(false)
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            try {
                val builder = BiometricPrompt.Builder(activity)
                    .setTitle("Verifikasi Keamanan fiBOnanci")
                    .setSubtitle(reason)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    builder.setAllowedAuthenticators(
                        BiometricManager.Authenticators.BIOMETRIC_STRONG or
                            BiometricManager.Authenticators.BIOMETRIC_WEAK or
                            BiometricManager.Authenticators.DEVICE_CREDENTIAL
                    )
                } else {
                    builder.setDeviceCredentialAllowed(true)
                }
                val prompt = builder.build()
                prompt.authenticate(
                    CancellationSignal(),
                    activity.mainExecutor,
                    object : BiometricPrompt.AuthenticationCallback() {
                        override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult?) {
                            onResult(true)
                        }
                        override fun onAuthenticationError(errorCode: Int, errString: CharSequence?) {
                            onResult(false)
                        }
                        override fun onAuthenticationFailed() {}
                    }
                )
                return
            } catch (_: Exception) {}
        }

        val intent = km.createConfirmDeviceCredentialIntent("Verifikasi Keamanan fiBOnanci", reason)
        if (intent != null) {
            registerPendingResult(onResult)
            activity.startActivityForResult(intent, REQUEST_CONFIRM_CREDENTIAL)
        } else {
            onResult(false)
        }
    }
}
