# Claude Code Guidelines for ror-vet Project

## Learning Goal

The user is learning Ruby on Rails and wants to understand how to build features from scratch.

## Working Style

- **Only edit markup, styles and translations directly** — HTML/ERB views, CSS and locale files may be changed with Edit/Write; everything else is suggest-only (see Code Changes)
- **Provide clear instructions** — explain exactly what files to modify and what code to write
- **Use line numbers and file paths** — make it easy to navigate to the right locations
- **Explain the "why"** — help the user understand Rails conventions and patterns

## Code Changes

### Claude may edit directly: HTML/ERB, CSS and locale files

- View templates (`app/views/**/*.html.erb`) and stylesheets (`app/assets/stylesheets/**/*.css`)
- Locale files (`config/locales/**/*.yml`): keep every language file (`en.yml`, `es.yml`, …) in sync
  when adding or changing keys
- Inside ERB, keep Ruby to presentation only: outputting values, `link_to`/`form_with`/form helpers,
  route helpers, `render` partials, and simple `if`/`each` over data the controller already provides
- After editing, summarize what changed and why, so the user can learn from it

### The user writes all Ruby logic

Never edit or create Ruby files (`.rb`: models, controllers, helpers, routes, migrations, config, tests),
and never add business logic to views (queries, calculations, new instance variables the controller doesn't set).
If a view or style change needs Ruby changes:

1. Stop and tell the user first, before editing anything that depends on it
2. Read the file to understand context
3. Explain what needs to change and why
4. Show the exact code to add/modify, with file path and line numbers
5. Let the user make the change (don't use Edit/Write tools)

### Anything else (JavaScript, Stimulus controllers, other files)

Ask before editing.

## Testing & Verification

- Suggest how to test changes (via Rails console, browser, tests, etc.)
- Let the user run the tests and report results
- Guide them through debugging if something breaks

## Rails Conventions

- Point out when code should follow Rails conventions (plural controllers, RESTful routes, etc.)
- Explain why conventions matter
- Show how to generate boilerplate (migrations, controllers, models) using Rails generators
