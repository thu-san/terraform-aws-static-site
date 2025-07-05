'use client';

import { usePathname, useSearchParams } from 'next/navigation';
import { useEffect, useState } from 'react';

export default function TrailingSlashPage() {
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const [fullUrl, setFullUrl] = useState('N/A');

  useEffect(() => {
    setFullUrl(window.location.href);
  }, []);

  return (
    <div className="max-w-4xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Trailing Slash Test Page</h1>

      <div className="bg-gray-50 p-6 rounded-lg mb-6">
        <h2 className="text-xl font-semibold mb-4">Current URL Information</h2>
        <dl className="space-y-2">
          <div>
            <dt className="font-semibold">Pathname:</dt>
            <dd className="font-mono text-blue-600">{pathname}</dd>
          </div>
          <div>
            <dt className="font-semibold">Search Params:</dt>
            <dd className="font-mono text-blue-600">
              {searchParams.toString() || 'none'}
            </dd>
          </div>
          <div>
            <dt className="font-semibold">Full URL (client-side):</dt>
            <dd className="font-mono text-blue-600">{fullUrl}</dd>
          </div>
        </dl>
      </div>

      <div className="prose max-w-none">
        <h2 className="text-xl font-semibold mb-3">Expected Behavior</h2>
        <p className="text-gray-700 mb-4">
          This page is accessed with a trailing slash (
          <code>/trailing-slash/</code>). In a properly configured static
          hosting environment, this should work without issues.
        </p>

        <h2 className="text-xl font-semibold mb-3">Testing Instructions</h2>
        <ol className="list-decimal list-inside space-y-2 text-gray-700">
          <li>Access this page via the navigation link</li>
          <li>Check that the URL maintains the trailing slash</li>
          <li>Refresh the page to ensure it loads correctly</li>
          <li>Try accessing without trailing slash to see redirect behavior</li>
        </ol>
      </div>
    </div>
  );
}
