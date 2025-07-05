'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';

export default function Header() {
  const pathname = usePathname();

  const navLinks = [
    { href: '/', label: 'Home', color: 'bg-gray-100 hover:bg-gray-200' },
    {
      href: '/trailing-slash/',
      label: 'Trailing Slash /',
      color: 'bg-green-100 hover:bg-green-200',
      useATag: true,
    },
    {
      href: '/trailing-slash-query/?test=123',
      label: 'Trailing Slash Query /?test=123',
      color: 'bg-blue-100 hover:bg-blue-200',
      useATag: true,
    },
    {
      href: '/nested/no-trailing-slash',
      label: 'No Trailing Slash',
      color: 'bg-orange-100 hover:bg-orange-200',
    },
    {
      href: '/nested/no-trailing-slash-query?test=456',
      label: 'No Trailing Slash Query ?test=456',
      color: 'bg-purple-100 hover:bg-purple-200',
    },
    {
      href: '/non-existent-page',
      label: '404 Error Test',
      color: 'bg-red-100 hover:bg-red-200',
    },
  ];

  return (
    <header className="bg-white shadow-sm border-b">
      <nav className="container mx-auto px-4 py-6">
        <h1 className="text-2xl font-bold mb-6">Navigation Testing</h1>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {navLinks.map(({ href, label, color, useATag }) => {
            const isActive = pathname === href.split('?')[0];
            const linkClassName = `
              block p-4 rounded-lg border-2 transition-all duration-200
              ${color}
              ${
                isActive
                  ? 'border-blue-500 shadow-md transform scale-105'
                  : 'border-transparent hover:border-gray-300'
              }
            `;
            const content = (
              <div className="space-y-2">
                <div
                  className={`text-sm font-semibold ${
                    isActive ? 'text-blue-600' : 'text-gray-900'
                  }`}
                >
                  {label.split(' ')[0]} {label.split(' ')[1]}
                </div>
                <div className="text-xs text-gray-600 font-mono">{href}</div>
                {isActive && (
                  <div className="text-xs text-blue-600 font-semibold">
                    ← Current Page
                  </div>
                )}
              </div>
            );

            if (useATag) {
              return (
                <a key={href} href={href} className={linkClassName}>
                  {content}
                </a>
              );
            }

            return (
              <Link key={href} href={href} className={linkClassName}>
                {content}
              </Link>
            );
          })}
        </div>
      </nav>
    </header>
  );
}
