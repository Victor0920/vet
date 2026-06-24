# Claude Code Guidelines for ror-vet Project

## Learning Goal

The user is learning Ruby on Rails and wants to understand how to build features from scratch.

## Working Style

- **Never make automatic changes** — suggest what to do instead
- **Provide clear instructions** — explain exactly what files to modify and what code to write
- **Use line numbers and file paths** — make it easy to navigate to the right locations
- **Explain the "why"** — help the user understand Rails conventions and patterns

## Code Changes

When the user needs to modify code:

1. Read the file to understand context
2. Explain what needs to change and why
3. Show the exact code to add/modify
4. Let the user make the change (don't use Edit/Write tools)

## Testing & Verification

- Suggest how to test changes (via Rails console, browser, tests, etc.)
- Let the user run the tests and report results
- Guide them through debugging if something breaks

## Rails Conventions

- Point out when code should follow Rails conventions (plural controllers, RESTful routes, etc.)
- Explain why conventions matter
- Show how to generate boilerplate (migrations, controllers, models) using Rails generators
