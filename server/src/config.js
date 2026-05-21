import dotenv from 'dotenv';

dotenv.config();

export const config = {
  port: Number(process.env.PORT ?? 3000),
  nodeEnv: process.env.NODE_ENV ?? 'development',
  minRequiredVersion: process.env.MIN_REQUIRED_VERSION ?? '0.1.0',
  latestVersion: process.env.LATEST_VERSION ?? '0.1.0',
  forceUpdate: (process.env.FORCE_UPDATE ?? 'true') === 'true',
  updateUrlAndroid: process.env.UPDATE_URL_ANDROID ?? '',
  jwtSecret: process.env.JWT_SECRET ?? 'dev-only-change-in-production',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN ?? '7d',
  googleClientId: process.env.GOOGLE_CLIENT_ID ?? '',
  facebookAppId: process.env.FACEBOOK_APP_ID ?? '',
  facebookAppSecret: process.env.FACEBOOK_APP_SECRET ?? '',
};
