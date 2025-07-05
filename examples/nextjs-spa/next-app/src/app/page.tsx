export default function HomePage() {
  return (
    <div className="max-w-4xl mx-auto">
      <h1 className="text-4xl font-bold mb-6">
        Next.js SPA Navigation Testing
      </h1>

      <div className="mb-8">
        <p className="text-lg text-gray-700 mb-4">
          This application demonstrates various routing scenarios for Next.js
          static export deployed on AWS CloudFront + S3. Test each navigation
          pattern to ensure proper SPA routing configuration.
        </p>
      </div>

      <div className="bg-blue-50 p-6 rounded-lg mb-8">
        <h2 className="text-2xl font-semibold mb-4">Test Scenarios</h2>
        <div className="space-y-4">
          <div>
            <h3 className="font-semibold text-lg">1. Trailing Slash</h3>
            <p className="text-gray-700">
              Tests basic routing with a trailing slash in the URL.
            </p>
          </div>

          <div>
            <h3 className="font-semibold text-lg">
              2. Trailing Slash with Query
            </h3>
            <p className="text-gray-700">
              Tests routing with both trailing slash and query parameters.
            </p>
          </div>

          <div>
            <h3 className="font-semibold text-lg">
              3. No Trailing Slash (Nested)
            </h3>
            <p className="text-gray-700">
              Tests nested routes without trailing slashes - a common failure
              point.
            </p>
          </div>

          <div>
            <h3 className="font-semibold text-lg">
              4. No Trailing Slash with Query (Nested)
            </h3>
            <p className="text-gray-700">
              The most complex scenario: nested route + no trailing slash +
              query params.
            </p>
          </div>
        </div>
      </div>

      <div className="bg-gray-50 p-6 rounded-lg">
        <h2 className="text-2xl font-semibold mb-4">Testing Instructions</h2>
        <ol className="list-decimal list-inside space-y-2 text-gray-700">
          <li>Click each link in the navigation header</li>
          <li>On each page, refresh the browser (Cmd/Ctrl + R)</li>
          <li>Check that the URL remains intact after refresh</li>
          <li>Verify query parameters are preserved where applicable</li>
          <li>Try accessing URLs directly by copying and pasting them</li>
        </ol>

        <div className="mt-4 p-4 bg-yellow-100 rounded">
          <p className="text-sm text-gray-800">
            <strong>Important:</strong> If any page returns a 404 or loses its
            URL structure after refresh, the CloudFront error pages are not
            configured correctly for SPA routing.
          </p>
        </div>
      </div>

      <div className="mt-8 text-sm text-gray-600">
        <p>
          This example uses Next.js{' '}
          {process.env.NODE_ENV === 'production' ? 'production' : 'development'}{' '}
          mode with static export configuration.
        </p>
      </div>
    </div>
  );
}
