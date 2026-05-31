"use client";

import { Button, Chip } from "@heroui/react";
import { FeatureCard } from "@/components/feature-card";

export default function HomePage() {
  return (
    <main
      style={{
        maxWidth: 980,
        margin: "0 auto",
        padding: "56px 20px 80px"
      }}
    >
      <section style={{ marginBottom: 34 }}>
        <Chip variant="flat" color="primary">
          codex starter
        </Chip>
        <h1 style={{ fontSize: 48, margin: "16px 0 12px", lineHeight: 1.05 }}>
          It&apos;s for People, By the People
        </h1>
        <p style={{ margin: 0, fontSize: 18, color: "var(--muted)", maxWidth: 680 }}>
          Start from this screen and build your app with Codex, using a scaffold that already includes
          skills, milestones, and reusable UI structure.
        </p>
      </section>

      <section
        style={{
          display: "grid",
          gap: 14,
          gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))",
          marginBottom: 24
        }}
      >
        <FeatureCard title="App Router Ready" description="The app directory is set up and can scale route by route." />
        <FeatureCard title="Reusable Components" description="Use the components folder for shared UI building blocks." />
        <FeatureCard title="Skills Included" description="Local skills are already wired through AGENTS.md for Codex." />
      </section>

      <Button color="primary" size="lg">
        build your first feature
      </Button>
    </main>
  );
}
