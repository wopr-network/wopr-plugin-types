# wopr-plugin-types

`@wopr-network/plugin-types` — canonical type definitions for WOPR plugins. All plugins import from here.

## Commands

```bash
npm run build  # tsc
npm run check  # biome check + tsc --noEmit
```

No tests — this is a types-only package.

## What This Package Exports

```typescript
// The plugin contract
WOPRPlugin           // Default export interface every plugin must satisfy
WOPRPluginContext    // Runtime API plugins receive at init()

// Channel types
ChannelAdapter, ChannelProvider, ChannelMessageContext, ChannelCommandContext

// Config / setup
ConfigSchema, ConfigField, SetupFlowType

// Capabilities
CapabilityRef        // How plugins declare capability requirements

// A2A (agent-to-agent)
A2AServerConfig, A2AToolDefinition, A2AToolResult
```

## Critical Rule

**Plugins ONLY import from this package** — never from `@wopr-network/wopr` core internals. This boundary is what keeps plugins decoupled from the runtime.

If a type is missing here that a plugin needs, add it here first, then bump the version.

## Versioning

Semantic versioning strictly. Breaking changes to exported types = major bump. New exports = minor. Fixes = patch.

Plugins pin `@wopr-network/plugin-types` in their `package.json`. After bumping, update all affected plugins.

## Issue Tracking

All issues in **Linear** (team: WOPR). No GitHub issues. Issue descriptions start with `**Repo:** wopr-network/wopr-plugin-types`.

## Session Memory

At the start of every WOPR session, **read `~/.wopr-memory.md` if it exists.** It contains recent session context: which repos were active, what branches are in flight, and how many uncommitted changes exist. Use it to orient quickly without re-investigating.

The `Stop` hook writes to this file automatically at session end. Only non-main branches are recorded — if everything is on `main`, nothing is written for that repo.