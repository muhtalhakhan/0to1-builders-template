"use client";

import { HeroUIProvider } from "@heroui/react";
import { ReactNode } from "react";
import FloatingProgressOverlay from "@/components/FloatingProgressOverlay";

type ProvidersProps = {
  children: ReactNode;
};

export function Providers({ children }: ProvidersProps) {
  return (
    <HeroUIProvider>
      {children}
      <FloatingProgressOverlay />
    </HeroUIProvider>
  );
}
