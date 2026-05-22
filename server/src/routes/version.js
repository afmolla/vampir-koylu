import { Router } from 'express';
import semver from 'semver';
import { config } from '../config.js';

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

  res.json({
    minRequiredVersion: config.minRequiredVersion,
    latestVersion: config.latestVersion,
    forceUpdate: config.forceUpdate,
    allowed,
    updateUrlAndroid: config.updateUrlAndroid,
    message: allowed
      ? null
      : 'Bu sürüm artık desteklenmiyor. Lütfen güncelleyin.',
    platform,
  });
});
