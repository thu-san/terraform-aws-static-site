'use client';

import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';

export default function NotFound() {
  const pathname = usePathname();
  const router = useRouter();
  const [showNotFound, setShowNotFound] = useState(false);

  // Check if this is a trailing slash case that needs redirect
  const needsTrailingSlashRedirect =
    pathname && pathname.endsWith('/') && pathname !== '/';

  useEffect(() => {
    if (needsTrailingSlashRedirect) {
      // Get the full path including query and hash, remove trailing slash from pathname
      const fullPath = window.location.href.replace(window.location.origin, '');
      const newPath = fullPath.replace(/\/(\?|#|$)/, '$1');
      router.replace(newPath);
    } else {
      // Only show 404 if we're not redirecting
      setShowNotFound(true);
    }
  }, [needsTrailingSlashRedirect, router]);

  // Don't show anything until we know whether to redirect or show 404
  if (!showNotFound) {
    return null;
  }

  return (
    <div className="min-h-[60vh] flex items-center justify-center">
      <div className="text-center">
        <h1 className="text-6xl font-bold text-gray-900 mb-4">404</h1>
        <h2 className="text-3xl font-semibold text-gray-700 mb-6">
          Page Not Found
        </h2>
        <p className="text-lg text-gray-600 mb-8 max-w-md mx-auto">
          The page you&apos;re looking for doesn&apos;t exist. This error page
          is served by Next.js for routes that don&apos;t have a corresponding
          page component.
        </p>

        <div className="space-y-4">
          <Link
            href="/"
            className="inline-block bg-blue-600 text-white px-6 py-3 rounded-md hover:bg-blue-700 transition-colors"
          >
            Go Back Home
          </Link>

          <div className="mt-8 p-4 bg-gray-50 rounded-lg max-w-lg mx-auto">
            <p className="text-sm text-gray-600">
              <strong>Note:</strong> In production with static export, this 404
              page will be served by CloudFront&apos;s custom error pages
              configuration for missing files.
            </p>
          </div>

          <div className="mt-4 p-4 bg-blue-50 rounded-lg max-w-lg mx-auto">
            <p className="text-sm text-gray-600">
              <strong>Trailing Slash Handling:</strong> This page automatically
              redirects URLs with trailing slashes to their non-trailing slash
              equivalents before showing the 404 error.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
