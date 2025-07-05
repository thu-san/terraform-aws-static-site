'use client';

import { usePathname, useSearchParams } from 'next/navigation';

export default function NoTrailingSlashPage() {
  const pathname = usePathname();
  const searchParams = useSearchParams();

  return (
    <div className="max-w-4xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">
        No Trailing Slash Test Page (Nested)
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
            <dt className="font-semibold">Full URL (client-side):</dt>
          </div>
        </dl>
      </div>

      <div className="prose max-w-none">
        <h2 className="text-xl font-semibold mb-3">Expected Behavior</h2>
        <p className="text-gray-700 mb-4">
          This page is in a nested route and accessed WITHOUT a trailing slash (
          <code>/nested/no-trailing-slash</code>). This tests how the static
          hosting handles nested routes without trailing slashes.
        </p>

        <h2 className="text-xl font-semibold mb-3">Testing Instructions</h2>
        <ol className="list-decimal list-inside space-y-2 text-gray-700">
          <li>Access this page via the navigation link</li>
          <li>Verify the URL does NOT have a trailing slash</li>
          <li>Refresh the page to ensure it loads correctly</li>
          <li>Try adding a trailing slash manually to see behavior</li>
          <li>Navigate away and back to test client-side routing</li>
        </ol>

        <div className="mt-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
          <p className="text-sm text-gray-700">
            <strong>Important:</strong> This is a critical test case. Many
            static hosting configurations struggle with nested routes without
            trailing slashes. The CloudFront configuration should handle this
            properly.
          </p>
        </div>
      </div>
    </div>
  );
}
