/**
 * Shared utilities and types used across apps.
 *
 * Add your shared code here and import from other apps:
 *   import { ... } from 'common';
 */

export function formatDate(date: Date): string {
  return date.toISOString().split('T')[0]!;
}
