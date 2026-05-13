---
description: Testing standards --- coverage targets, TDD enforcement, test structure, and quality expectations.
globs: []
alwaysApply: true
---

# Testing

## Minimum Coverage

- **Lines:** 80%
- **Branches:** 80%
- **Functions:** 80%

Test at the lowest level that captures the behavior:

```
Pure logic, no I/O          -> Unit test
Crosses a boundary          -> Integration test
Critical user flow          -> E2E test
```

Do not write E2E tests for things unit tests can cover.

## TDD Discipline

For new features and bug fixes, follow RED -> GREEN -> IMPROVE:

1. **RED** --- Write a test that fails. This proves the test is meaningful.
2. **GREEN** --- Write the minimum code to make it pass.
3. **IMPROVE** --- Refactor while keeping all tests green.

Bug fixes use the Prove-It pattern: write a failing test that reproduces the bug first, then fix.

## Test Structure

Each test should verify one concept. Use Arrange -> Act -> Assert:

```typescript
describe('[Module / Function]', () => {
  it('[expected behavior in plain English]', () => {
    // Arrange
    const input = { ... };

    // Act
    const result = fn(input);

    // Assert
    expect(result).toEqual(expected);
  });
});
```

## What to Test

| Scenario | Must cover? | Example |
|----------|-------------|---------|
| Happy path | Yes | Valid input -> expected output |
| Empty/null/undefined | Yes | Empty array, null object, undefined field |
| Boundary values | Yes | Max/min, zero, negative |
| Error paths | Yes | Network failure, invalid input, auth failure |
| Concurrency | If applicable | Race conditions, out-of-order responses |

## What NOT to Test

- Implementation details --- test behavior, not how it's implemented
- Third-party library behavior --- assume libraries work correctly
- Trivial getters/setters --- unless they have logic
- Generated code --- test the generator, not its output
- Configuration values --- test that config is read correctly, not every value

## Rules

1. Tests must be independent --- no shared mutable state between tests
2. A test that never fails is as useful as a test that always fails
3. Mock only at system boundaries (database, network, filesystem), not between internal functions
4. Test names should read like specifications --- "returns user when valid ID provided"
5. Avoid snapshot tests unless you review every change to the snapshot
