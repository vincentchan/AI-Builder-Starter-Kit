---
glob: src/app/**/*.tsx
---

<!--
  WHAT THIS FILE IS
  -----------------
  This is a glob-scoped rules file. Claude Code automatically loads it whenever
  it touches any file matching `src/app/**/*.tsx` — no skill invocation needed.
  Use it to enforce conventions specific to your UI components and pages.

  HOW TO USE IT
  -------------
  Replace the examples below with rules that match your framework and design
  system. Rules here are injected into Claude's context only when relevant,
  keeping your main CLAUDE.md focused on project-wide concerns.

  EXAMPLES TO ADAPT
  -----------------
  Component constraints:
  - Props-only — no data fetching, no DB calls, no async inside components
  - Under 50 lines per component — split if growing larger
  - Server components by default; only use "use client" for event handlers/hooks

  Page conventions (Next.js App Router):
  - Always export generateMetadata() from page files
  - Parallel data fetching via Promise.all() in server components

  Design system:
  - Follow your card pattern: e.g. `bg-white rounded-xl p-6 shadow-sm`
  - Primary colour tokens: replace with your own (e.g. `text-brand-500`)
  - Typography scale: replace with your heading/body conventions

  CHANGE THE GLOB
  ---------------
  If your components live elsewhere (e.g. `src/components/` or `app/`), update
  the glob pattern in the frontmatter above to match your project structure.
  You can also split this into multiple rules files with different globs —
  e.g. one for pages, one for shared components.
-->