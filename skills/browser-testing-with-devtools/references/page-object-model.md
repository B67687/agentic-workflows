# Page Object Model (POM) for Browser Testing

**Source:** [Playwright -- Page Object Models](https://playwright.dev/docs/pom)

A structural pattern for organizing browser test suites. Each page or
component of the web application is represented by a class that encapsulates
element selectors and interaction methods.

## Why POM

- **Simplifies authoring** -- tests use a higher-level API ("login page",
  "checkout page") instead of raw selectors
- **Simplifies maintenance** -- element selectors live in one place. When UI
  changes, only the page object changes, not every test
- **Eliminates repetition** -- common interactions (login, search, navigation)
  are defined once and reused
- **Works with any runner** -- compatible with Playwright Test, custom Node.js
  scripts, and MCP-based browsing

## Structure

```
tests/
  models/
    HomePage.ts        # Home page elements + actions
    SearchPage.ts      # Search results page
    CheckoutPage.ts    # Checkout flow
  specs/
    home.spec.ts       # Tests using HomePage
    search.spec.ts     # Tests using SearchPage
    checkout.spec.ts   # Tests using CheckoutPage
```

## Pattern

Each page object is a class that:

1. Takes the `Page` (or browser context) in its constructor
2. Exposes element **locators** as readonly properties
3. Exposes interaction **methods** (goto, search, submit, etc.)
4. Exposes **assertion helpers** for common verification

### Canonical Example (TypeScript)

```typescript
import { expect, type Locator, type Page } from '@playwright/test';

export class LoginPage {
  readonly page: Page;
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;
  readonly errorMessage: Locator;

  constructor(page: Page) {
    this.page = page;
    this.emailInput = page.locator('#email');
    this.passwordInput = page.locator('#password');
    this.submitButton = page.locator('button[type="submit"]');
    this.errorMessage = page.locator('.error-message');
  }

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }

  async expectError(expectedText: string) {
    await expect(this.errorMessage).toContainText(expectedText);
  }
}
```

### Used in a test

```typescript
import { test } from '@playwright/test';
import { LoginPage } from '../models/LoginPage';

test('successful login redirects to dashboard', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.goto();
  await loginPage.login('user@example.com', 'password123');
  await expect(page).toHaveURL(/\/dashboard/);
});

test('invalid credentials show error', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.goto();
  await loginPage.login('bad@user.com', 'wrong');
  await loginPage.expectError('Invalid email or password');
});
```

## Variants

### Component-Level POM

For complex UIs, model individual components rather than full pages:

```typescript
export class SearchBar {
  constructor(private page: Page) {}

  get input() { return this.page.locator('header input[type="search"]'); }
  get results() { return this.page.locator('.search-results'); }

  async search(query: string) {
    await this.input.fill(query);
    await this.input.press('Enter');
    await this.results.waitFor();
  }
}
```

### Plain JS (no Playwright Test)

For use with standalone browser scripts or MCP-based browsing:

```javascript
class LoginPage {
  constructor(page) {
    this.page = page;
    this.emailSelector = '#email';
    this.passwordSelector = '#password';
    this.submitSelector = 'button[type="submit"]';
  }

  async goto(url) {
    await this.page.goto(url);
  }

  async login(email, password) {
    await this.page.fill(this.emailSelector, email);
    await this.page.fill(this.passwordSelector, password);
    await this.page.click(this.submitSelector);
  }
}
```

## Integration with browser.sh

The `scripts/browser.sh` tool uses Playwright directly and can be wrapped
with page objects for structured browsing:

```bash
# Without POM: raw selector repetition
bash browser.sh navigate https://example.com/login
bash browser.sh section https://example.com/login "#email" # no fill in browser.sh
bash browser.sh click https://example.com/login "button[type=submit]"

# With POM: encapsulate in a script that uses Playwright API directly
# See models/LoginPage.js in your project
```

For full POM support (fill, select, assertions), use Playwright Test or the
Playwright MCP server (configured in `opencode.jsonc`) which provides
`browser_fill`, `browser_click`, `browser_select`, etc.

## When to Use

| Scenario | Use POM? |
|----------|----------|
| 3+ tests on the same page | YES -- maintenance savings are immediate |
| Shared UI components (nav, search, footer) | YES -- component-level POM |
| One-off debugging script | NO -- raw browser.sh is fine |
| Prototype / throwaway test | NO -- POM overhead not justified |
| MCP-based agent browsing | MAYBE -- POM is useful when agent repeats flows |

## Verification Checklist

- [ ] Each page object has a single responsibility (one page or component)
- [ ] Locators are readonly properties, not methods (avoids re-querying)
- [ ] Methods return `Promise<void>` or meaningful state objects
- [ ] Tests use page objects, not raw selectors
- [ ] Page objects don't contain test logic (assertions, conditions)
- [ ] Common flows (login, navigation) are extracted, not duplicated

## References

- [Playwright POM Guide](https://playwright.dev/docs/pom) -- official docs
- [Playwright Best Practices](https://playwright.dev/docs/best-practices)
- [Playwright Fixtures](https://playwright.dev/docs/test-fixtures) -- for
  dependency injection of page objects
