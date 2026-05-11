---
description: TypeScript and JavaScript specific patterns, tooling, and idioms. Used alongside rules/common/.
globs: ["**/*.ts", "**/*.tsx", "**/*.js", "**/*.jsx", "**/*.mjs"]
alwaysApply: false
---

# TypeScript / JavaScript Patterns

## TypeScript Configuration

- `strict: true` in tsconfig — no exceptions
- Prefer `interface` over `type` for object shapes (better error messages, extends semantics)
- Use `type` for unions, intersections, and utility types
- Avoid `any` — use `unknown` when the type is not known. Cast only at usage sites with runtime validation.
- Avoid `as` casts — prefer type guards, discriminated unions, or Zod schemas

## Code Style

- Use `const` by default. Only use `let` when rebinding is necessary. Never use `var`.
- Use arrow functions for callbacks and anonymous functions
- Use named exports over default exports — better for refactoring, auto-import, and tree-shaking
- Use optional chaining (`?.`) and nullish coalescing (`??`) over `&&` chains
- Use template literals over string concatenation
- Use `for...of` over `.forEach()` — break/continue support, async-friendly

## Testing

- **Framework:** vitest (preferred) or jest
- **Test files:** co-located with source: `user.service.ts` → `user.service.test.ts`
- **Mocking:** use `vi.mock()` sparingly — prefer dependency injection
- **Coverage:** vitest --coverage with 80%+ thresholds

## Async Patterns

- Prefer `async/await` over `.then()` chains
- Handle promise rejections — no floating promises. Use `void` operator only when intentionally fire-and-forget
- Use `Promise.all()` for parallel independent operations, `Promise.allSettled()` when partial success is acceptable
- Use `AbortController` for cancellable operations — do not ignore cancellation signals

## Tooling

- **Format:** Prettier or Biome with consistent config
- **Lint:** ESLint with `@typescript-eslint` — prefer the `recommended` config
- **Type-check:** `tsc --noEmit` as a pre-commit or CI step
- **Bundle:** Use the project's existing bundler (Vite, webpack, tsup, esbuild) — don't add a new one
