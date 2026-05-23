import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const serverRoot = path.join(__dirname, '..');

dotenv.config({ path: path.join(serverRoot, '.env') });
dotenv.config({ path: path.join(serverRoot, 'auth-secrets.env') });

/** GitHub Releases: afmolla/vampir-koylu (guncel APK'lar). */
const apkReleaseRepo = process.env.APK_RELEASE_REPO ?? 'afmolla/vampir-koylu';

export function apkLatestDownloadUrl() {
  return `https://github.com/${apkReleaseRepo}/releases/latest/download/app-release.apk`;
}

export function apkDownloadUrl(version) {
  const v = String(version).replace(/^v/i, '');
  return `https://github.com/${apkReleaseRepo}/releases/download/v${v}/app-release.apk`;
}

export const config = {
  port: Number(process.env.PORT ?? 3002),
  nodeEnv: process.env.NODE_ENV ?? 'development',
  minRequiredVersion: process.env.MIN_REQUIRED_VERSION ?? '0.2.6',
  latestVersion: process.env.LATEST_VERSION ?? '0.2.25',
  apkPublishVersion: process.env.APK_PUBLISH_VERSION ?? '0.2.25',
  forceUpdate: (process.env.FORCE_UPDATE ?? 'true') === 'true',
  updateUrlAndroid:
    process.env.UPDATE_URL_ANDROID ??
    apkDownloadUrl(process.env.APK_PUBLISH_VERSION ?? '0.2.25'),
  updateUrlLatest: apkLatestDownloadUrl(),
  apkReleaseRepo,
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
