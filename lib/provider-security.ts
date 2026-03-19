import type { ProviderSecurityCapabilities } from '@/lib/types/settings';

export const SERVER_ONLY_PROVIDER_CAPABILITIES: ProviderSecurityCapabilities = {
  secretsMode: 'server-only',
  allowClientBaseUrl: false,
  allowCustomProviders: false,
  allowProviderEditing: false,
};

export const CLIENT_OVERRIDE_PROVIDER_CAPABILITIES: ProviderSecurityCapabilities = {
  secretsMode: 'client-override',
  allowClientBaseUrl: true,
  allowCustomProviders: true,
  allowProviderEditing: true,
};

export function getDefaultProviderSecurityCapabilities(): ProviderSecurityCapabilities {
  return process.env.NODE_ENV === 'development'
    ? CLIENT_OVERRIDE_PROVIDER_CAPABILITIES
    : SERVER_ONLY_PROVIDER_CAPABILITIES;
}

export function allowClientSecrets(capabilities: ProviderSecurityCapabilities): boolean {
  return capabilities.secretsMode === 'client-override';
}

export function sanitizeClientSecretValue(
  value: string | undefined,
  capabilities: ProviderSecurityCapabilities,
): string {
  return allowClientSecrets(capabilities) ? value || '' : '';
}
