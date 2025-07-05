'use client';

import { usePathname, useSearchParams } from 'next/navigation';
import { useEffect, useState } from 'react';

export default function NoTrailingSlashQueryPage() {
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const [fullUrl, setFullUrl] = useState('N/A');

  useEffect(() => {
    setFullUrl(window.location.href);
  }, []);

  return (
    <div className="max-w-4xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">
        No Trailing Slash with Query Test Page (Nested)
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
          This page combines the challenges of nested routes, no trailing slash,
          AND query parameters (
          <code>/nested/no-trailing-slash-query?test=456</code>). This is the
          most complex routing scenario to handle in static hosting.
        </p>

        <h2 className="text-xl font-semibold mb-3">Testing Instructions</h2>
        <ol className="list-decimal list-inside space-y-2 text-gray-700">
          <li>Access this page via the navigation link</li>
          <li>
            Verify the URL has NO trailing slash but includes query params
          </li>
          <li>
            Check that the query parameter &apos;test=456&apos; is accessible
          </li>
          <li>Refresh the page to ensure both path and query work</li>
          <li>Test direct URL access by copying and pasting the URL</li>
        </ol>

        <div className="mt-6 p-4 bg-red-50 border border-red-200 rounded-lg">
          <p className="text-sm text-gray-700">
            <strong>Critical Test:</strong> This scenario often fails in
            misconfigured static hosting setups. The combination of nested route
            + no trailing slash + query params tests the robustness of the
            CloudFront error page configuration.
          </p>
        </div>

        <div className="mt-4 p-4 bg-green-50 border border-green-200 rounded-lg">
          <p className="text-sm text-gray-700">
            <strong>Success Criteria:</strong> If this page loads correctly with
            all URL components intact after a page refresh, the static hosting
            is properly configured for SPA routing.
          </p>
        </div>
      </div>
    </div>
  );
}
