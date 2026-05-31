type FeatureCardProps = {
  title: string;
  description: string;
};

export function FeatureCard({ title, description }: FeatureCardProps) {
  return (
    <article
      style={{
        background: "var(--card)",
        borderRadius: 16,
        border: "1px solid #dbe2ee",
        padding: 18
      }}
    >
      <h3 style={{ margin: "0 0 8px", fontSize: 18 }}>{title}</h3>
      <p style={{ margin: 0, color: "var(--muted)", lineHeight: 1.5 }}>{description}</p>
    </article>
  );
}
