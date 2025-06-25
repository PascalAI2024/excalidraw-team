import React from 'react';
import { ClerkProvider as ClerkProviderBase } from '@clerk/clerk-react';

const CLERK_PUBLISHABLE_KEY = import.meta.env.VITE_CLERK_PUBLISHABLE_KEY;

if (!CLERK_PUBLISHABLE_KEY) {
  throw new Error('Missing Clerk Publishable Key');
}

export function ClerkProvider({ children }: { children: React.ReactNode }) {
  return (
    <ClerkProviderBase publishableKey={CLERK_PUBLISHABLE_KEY}>
      {children}
    </ClerkProviderBase>
  );
}