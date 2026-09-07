export default function Home() {
  const metrics = [
    ["Solutions", "0", "Ready to configure"],
    ["Registered agents", "0", "Version-controlled"],
    ["Tool connections", "3", "Bedrock · Databricks · Snowflake"],
    ["Environment", "DEV", "us-west-2"],
  ];

  return (
    <div className="shell">
      <aside className="sidebar">
        <div className="brand">Agentic <span>Platform</span></div>
        <nav className="nav" aria-label="Platform navigation">
          <a href="#overview">Overview</a>
          <a href="#solutions">Solutions</a>
          <a href="#agents">Agent registry</a>
          <a href="#tools">Tools & MCP</a>
          <a href="#evaluations">Evaluations</a>
          <a href="#governance">Governance</a>
        </nav>
        <div className="environment">Active environment<strong>Development · us-west-2</strong></div>
      </aside>

      <main className="content" id="overview">
        <div className="eyebrow">Enterprise multi-agent control plane</div>
        <h1>Build agent teams that can reason, act, and remain governed.</h1>
        <p className="lede">Design reusable solutions on Amazon Bedrock, connect governed Databricks and Snowflake tools, and promote only the versions that pass evaluation, security, and cost gates.</p>
        <div className="actions">
          <button className="button primary" type="button">Create solution</button>
          <button className="button" type="button">Register agent</button>
        </div>

        <section className="metrics" aria-label="Platform metrics">
          {metrics.map(([label, value, note]) => (
            <article className="card" key={label}>
              <div className="metric-label">{label}</div>
              <div className="metric-value">{value}</div>
              <div className="metric-note">{note}</div>
            </article>
          ))}
        </section>

        <section className="section" id="tools">
          <div className="section-header"><h2>Platform connections</h2></div>
          <div className="stack">
            {[
              ["Amazon Bedrock", "Models, guardrails, reasoning and governed model invocation."],
              ["Databricks", "Data engineering, AI assets, vector search and evaluation datasets."],
              ["Snowflake", "Governed structured data, semantic products and operational analytics."],
            ].map(([name, copy]) => (
              <article className="card" key={name}>
                <div className="platform-name">{name}</div>
                <div className="platform-copy">{copy}</div>
                <div className="status"><span className="dot" />Configuration ready</div>
              </article>
            ))}
          </div>
        </section>

        <section className="section" id="governance">
          <div className="section-header"><h2>Solution promotion path</h2></div>
          <div className="pipeline">
            {[
              ["01", "Design", "Agents, workflow and tools"],
              ["02", "Secure", "Identity and least privilege"],
              ["03", "Evaluate", "Quality, safety and cost"],
              ["04", "Approve", "Human promotion gate"],
              ["05", "Operate", "Trace, audit and improve"],
            ].map(([number, name, copy]) => (
              <div className="stage" key={number}>
                <span className="stage-number">{number}</span><strong>{name}</strong><small>{copy}</small>
              </div>
            ))}
          </div>
        </section>
      </main>
    </div>
  );
}
