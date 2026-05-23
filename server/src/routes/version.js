import { Router } from 'express';
import semver from 'semver';
import { apkDownloadUrl, apkLatestDownloadUrl, config } from '../config.js';
import { SERVER_BUILD } from './health.js';

export const versionRouter = Router();

versionRouter.get('/', (req, res) => {
  const clientVersion = String(req.query.clientVersion ?? '0.0.0');
  const platform = String(req.query.platform ?? 'android');

  const validClient = semver.valid(clientVersion);
  const meetsMin =
    validClient && semver.gte(clientVersion, config.minRequiredVersion);
  const meetsLatest =
    validClient &&
    semver.valid(config.latestVersion) &&
    semver.gte(clientVersion, config.latestVersion);
  const allowed = meetsMin && meetsLatest;
  const needsUpdate =
    config.forceUpdate &&
    validClient &&
    semver.valid(config.latestVersion) &&
    semver.lt(clientVersion, config.latestVersion);

  const apkVer = config.apkPublishVersion || config.latestVersion;
  let updateUrlAndroid = apkDownloadUrl(apkVer);
  const envUrl = (config.updateUrlAndroid ?? '').trim();
  if (envUrl.endsWith('.apk')) {
    const m = envUrl.match(/\/releases\/download\/v([^/]+)\//);
    const envVer = m?.[1];
    if (!envVer || semver.gte(envVer, apkVer)) {
      updateUrlAndroid = envUrl;
    }
  }

  res.json({
    serverBuild: SERVER_BUILD,
    minRequiredVersion: config.minRequiredVersion,
    latestVersion: config.latestVersion,
    apkPublishVersion: apkVer,
    apkReleaseRepo: config.apkReleaseRepo,
    forceUpdate: config.forceUpdate,
    allowed,
    needsUpdate,
    updateUrlAndroid,
    updateUrlLatest: apkLatestDownloadUrl(),
    message: needsUpdate
      ? `Yeni surum v$apkVer mevcut. Lutfen guncelleyin.`
      : allowed
        ? null
        : 'Bu surum artik desteklenmiyor. Lutfen guncelleyin.',
    platform,
  });
});
