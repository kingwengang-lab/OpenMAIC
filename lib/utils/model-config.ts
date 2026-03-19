import { useSettingsStore } from '@/lib/store/settings';
import { sanitizeClientSecretValue } from '@/lib/provider-security';

type ClientOverrideConfig = {
  apiKey?: string;
  baseUrl?: string;
};

/**
 * Get current model configuration from settings store
 */
export function getCurrentModelConfig() {
  const { providerId, modelId, providersConfig, providerCapabilities } = useSettingsStore.getState();
  const modelString = `${providerId}:${modelId}`;

  // Get current provider's config
  const providerConfig = providersConfig[providerId];

  return {
    providerId,
    modelId,
    modelString,
    apiKey: sanitizeClientSecretValue(providerConfig?.apiKey, providerCapabilities),
    baseUrl: providerCapabilities.allowClientBaseUrl ? providerConfig?.baseUrl || '' : '',
    providerType: providerConfig?.type,
    requiresApiKey: providerConfig?.requiresApiKey,
    isServerConfigured: providerConfig?.isServerConfigured,
  };
}

export function getSanitizedClientOverride(config?: ClientOverrideConfig) {
  const { providerCapabilities } = useSettingsStore.getState();

  return {
    apiKey: sanitizeClientSecretValue(config?.apiKey, providerCapabilities),
    baseUrl: providerCapabilities.allowClientBaseUrl ? config?.baseUrl || '' : '',
  };
}
