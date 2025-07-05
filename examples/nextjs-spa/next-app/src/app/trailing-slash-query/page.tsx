'use client';

import { usePathname, useSearchParams } from 'next/navigation';
import { useEffect, useState } from 'react';

export default function TrailingSlashQueryPage() {
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const [fullUrl, setFullUrl] = useState('N/A');

  useEffect(() => {
    setFullUrl(window.location.href);
  }, []);

  return (
    <div className="max-w-4xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">
        Trailing Slash with Query Test Page
      </h1>

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
            <dt className="font-semibold">Query Param &apos;test&apos;:</dt>
            <dd className="font-mono text-blue-600">
              {searchParams.get('test') || 'not found'}
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
          This page is accessed with both a trailing slash and query parameters
          (<code>/trailing-slash-query/?test=123</code>). The query parameters
          should be preserved and accessible through the application.
        </p>

        <h2 className="text-xl font-semibold mb-3">Testing Instructions</h2>
        <ol className="list-decimal list-inside space-y-2 text-gray-700">
          <li>Access this page via the navigation link</li>
          <li>
            Verify that the query parameter &apos;test=123&apos; is present
          </li>
          <li>Check that both the trailing slash and query are maintained</li>
          <li>Refresh the page to ensure query params persist</li>
          <li>Try modifying the query params in the URL bar</li>
        </ol>

        <div className="mt-6 p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
          <p className="text-sm text-gray-700">
            <strong>Note:</strong> Query parameters are handled client-side in
            static exports. The server/CDN should serve the base HTML file
            regardless of query parameters.
          </p>
        </div>
      </div>
    </div>
  );
}
