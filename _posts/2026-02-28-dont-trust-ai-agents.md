---
layout: post
title: "Don't Trust AI Agents — A New Security Model"
date: 2026-02-28
categories: [security, research]
tags: [agents, security, prompt-injection, trust]
excerpt: "A new post argues that AI agents should be treated as untrusted by default, and proposes a layered security model for agentic systems."
---

A post titled *"Don't trust AI agents"* from nanoclaw.dev is generating heated discussion on Hacker News (155 points, 90 comments), laying out why the current default posture of trusting AI agent outputs is dangerously naive.

### The Core Argument

The author argues that AI agents — systems that autonomously browse the web, execute code, send emails, and manage files — should be treated with the **same zero-trust principles** applied to external APIs or untrusted user input.

Key threat vectors highlighted:

- **Prompt injection via web content**: malicious websites embedding hidden instructions for agents that browse them
- **Tool abuse**: agents being manipulated into calling destructive tools
- **Data exfiltration**: tricked into leaking private context to external systems

### Proposed Security Model

The post outlines a layered defense:

1. **Sandboxed execution environments** — isolate agent tool use
2. **Human-in-the-loop checkpoints** for irreversible actions (emails, deletes, payments)
3. **Content sanitization** before passing external data into agent context
4. **Capability restriction** — agents should only have the permissions they absolutely need

### The Bigger Picture

As AI agents become mainstream in products like GitHub Copilot Workspace, Devin, and OpenAI's Operator, the industry is still catching up on security fundamentals. This post is a useful primer on what "agentic security" should look like.

**Source:** [nanoclaw.dev](https://nanoclaw.dev/blog/nanoclaw-security-model)
