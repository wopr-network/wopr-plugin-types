# @wopr-network/plugin-types

Canonical type definitions for all WOPR plugins. This is the single source of truth for plugin-facing types including plugin interfaces, context APIs, event buses, hooks, channels, and more.

## Install

This package is installed directly from GitHub (not published to npm):

```bash
npm install wopr-network/wopr-plugin-types
```

Or in `package.json`:

```json
{
  "@wopr-network/plugin-types": "github:wopr-network/wopr-plugin-types"
}
```

## Usage

```typescript
import type {
  WOPRPlugin,
  WOPRPluginContext,
  ConfigSchema,
  PluginManifest,
  WOPREventMap,
} from "@wopr-network/plugin-types";
```

## What's included

- **Plugin interface** (`WOPRPlugin`) -- the core interface every plugin implements
- **Plugin context** (`WOPRPluginContext`) -- the runtime API plugins receive during `init()`
- **Config types** (`ConfigSchema`, `ConfigField`) -- configuration schema for plugin settings
- **Manifest types** (`PluginManifest`) -- full plugin metadata for WaaS marketplace
- **Event types** (`WOPREventMap`, `WOPREventBus`) -- reactive event bus types
- **Hook types** (`WOPRHookManager`) -- lifecycle hook interception points
- **Channel types** (`ChannelAdapter`, `ChannelProvider`) -- communication channel abstractions
- **Context provider types** (`ContextProvider`) -- composable context injection
- **A2A types** (`A2AServerConfig`, `A2AToolDefinition`) -- agent-to-agent tool types
