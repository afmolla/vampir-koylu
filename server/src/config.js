import dotenv from 'dotenv';

dotenv.config();

export const config = {
  port: Number(process.env.PORT ?? 3000),
  nodeEnv: process.env.NODE_ENV ?? 'development',
  minRequiredVersion: process.env.MIN_REQUIRED_VERSION ?? '0.2.6',
  latestVersion: process.env.LATEST_VERSION ?? '0.2.15',
  apkPublishVersion: process.env.APK_PUBLISH_VERSION ?? '0.2.15',
  forceUpdate: (process.env.FORCE_UPDATE ?? 'true') === 'true',
  updateUrlAndroid:
    process.env.UPDATE_URL_ANDROID ??
    `https://github.com/afmolla/vampir-koylu/releases/download/v${process.env.APK_PUBLISH_VERSION ?? '0.2.14'}/app-release.apk`,
  jwtSecret: process.env.JWT_SECRET ?? 'dev-only-change-in-production',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN ?? '7d',
  googleClientId: process.env.GOOGLE_CLIENT_ID ?? '',
  facebookAppId: process.env.FACEBOOK_APP_ID ?? '',
  facebookAppSecret: process.env.FACEBOOK_APP_SECRET ?? '',
  /** Admin bakiye yukleme: X-Admin-Key basligi */
  adminApiKey: process.env.ADMIN_API_KEY ?? '',
  publicAppUrl: process.env.PUBLIC_APP_URL ?? 'https://vampir-koylu.app',
  smtpHost: process.env.SMTP_HOST ?? '',
  smtpPort: Number(process.env.SMTP_PORT ?? 587),
  smtpSecure: (process.env.SMTP_SECURE ?? 'false') === 'true',
  smtpUser: process.env.SMTP_USER ?? '',
  smtpPass: process.env.SMTP_PASS ?? '',
  mailFrom: process.env.MAIL_FROM ?? 'noreply@vampir-koylu.app',
  fcmServerKey: process.env.FCM_SERVER_KEY ?? '',
  googlePlayPackageName: process.env.GOOGLE_PLAY_PACKAGE_NAME ?? 'com.vampirkoylu.vampir_koylu',
  googlePlayServiceAccount: process.env.GOOGLE_PLAY_SERVICE_ACCOUNT ?? '',
};
