import dotenv from 'dotenv';

dotenv.config();

export const config = {
  port: Number(process.env.PORT ?? 3000),
  nodeEnv: process.env.NODE_ENV ?? 'development',
  minRequiredVersion: process.env.MIN_REQUIRED_VERSION ?? '0.2.6',
  latestVersion: process.env.LATEST_VERSION ?? '0.2.10',
  /** GitHub'da yayinli APK — kilitle release.keystore ile ayni imza */
  /** GitHub'da APK olan surum (0.2.10 Actions bitene kadar 0.2.8) */
  apkPublishVersion: process.env.APK_PUBLISH_VERSION ?? '0.2.8',
  forceUpdate: (process.env.FORCE_UPDATE ?? 'true') === 'true',
  updateUrlAndroid:
    process.env.UPDATE_URL_ANDROID ??
    `https://github.com/afmolla/flutter/releases/download/v${process.env.APK_PUBLISH_VERSION ?? '0.2.8'}/app-release.apk`,
  jwtSecret: process.env.JWT_SECRET ?? 'dev-only-change-in-production',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN ?? '7d',
  googleClientId: process.env.GOOGLE_CLIENT_ID ?? '',
  facebookAppId: process.env.FACEBOOK_APP_ID ?? '',
  facebookAppSecret: process.env.FACEBOOK_APP_SECRET ?? '',
};
