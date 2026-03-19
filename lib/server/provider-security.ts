import { apiError } from '@/lib/server/api-response';
import { getDefaultProviderSecurityCapabilities } from '@/lib/provider-security';

function hasClientOverride(value: string | null | undefined): boolean {
  return typeof value === 'string' && value.trim().length > 0;
}

export function getServerProviderCapabilities() {
  return getDefaultProviderSecurityCapabilities();
}

export function hasBlockedClientSecretOverride(params: {
  apiKey?: string | null;
  baseUrl?: string | null;
}) {
  const capabilities = getServerProviderCapabilities();
  return (
    capabilities.secretsMode === 'server-only' &&
    (hasClientOverride(params.apiKey) || hasClientOverride(params.baseUrl))
  );
}

export function rejectClientSecretOverride(params: {
  apiKey?: string | null;
  baseUrl?: string | null;
}) {
  if (hasBlockedClientSecretOverride(params)) {
    return apiError(
      'INVALID_REQUEST',
      403,
      'Client API key and Base URL overrides are disabled in deployed environments',
    );
  }

  return null;
}
