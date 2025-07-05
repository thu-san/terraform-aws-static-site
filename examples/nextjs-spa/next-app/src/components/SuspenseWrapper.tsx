import { Suspense } from 'react';

export default function SuspenseWrapper({
  children,
}: {
  children: React.ReactNode;
}) {
  return <Suspense>{children}</Suspense>;
}
