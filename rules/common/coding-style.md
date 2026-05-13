---
description: Universal coding style principles --- immutability, file organization, naming, error handling. Always apply regardless of programming language.
globs: []
alwaysApply: true
---

# Coding Style

## Immutability

Always create new objects, never mutate existing ones. Return new copies with changes applied.

```typescript
// GOOD
const updated = { ...state, count: state.count + 1 };

// BAD
state.count += 1;
```

**Rationale:** Immutability eliminates an entire class of bugs (aliasing, unexpected side effects, data races), makes code easier to reason about, and enables reliable change detection for testing and rendering.

## File Organization

- **Many small files over few large files.** 100-300 lines per file is typical; 500 max.
- **Organize by feature/domain, not by type.** Group related code together, not all utilities in one file.
- **Each file should have one clear responsibility.** If a file's purpose can't be summarized in one sentence, split it.
- **Name files after their primary export.** `user-service.ts` -> exports `UserService`.

## Naming

- **Functions and methods:** verb or verb phrase --- `getUser()`, `calculateTotal()`, `handleError()`
- **Classes and types:** noun or noun phrase --- `User`, `PaymentGateway`, `ValidationResult`
- **Booleans:** prefix with `is`, `has`, `can`, `should` --- `isActive`, `hasPermission`, `canEdit`
- **Constants:** `SCREAMING_SNAKE_CASE` for true constants (known at compile time)
- **Avoid abbreviations** unless universally understood (`id`, `url`, `html`)
- **Avoid single-letter names** except in loop indices and math

## Error Handling

- Handle errors at every level. Never silently swallow errors.
- **Server-side:** Log detailed context (what failed, with what inputs, at what state)
- **Client-side:** Provide user-friendly messages. Do not expose internal error details.
- **Fail fast:** Validate inputs at system boundaries. Catch problems early with clear messages.
- **Use typed errors** (custom error classes or tagged unions) rather than generic `Error` or string codes.

## Code Quality

- **Functions small:** under 50 lines. If longer, extract helper functions.
- **No deep nesting:** max 4 levels of indentation. Extract early returns or helper functions.
- **No hardcoded values** in business logic. Use constants, config, or environment variables.
- **Comments explain "why", not "what".** The code should make "what" obvious.
- **Dead code is removed, not commented out.** Version control preserves history.
