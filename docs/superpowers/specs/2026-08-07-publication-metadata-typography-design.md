# Publication Metadata and Typography Design

## Goal

Simplify the metadata displayed for the newly added 2026 papers and give author names a subtle visual distinction from paper titles without changing the site's overall typeface.

## Content changes

- Display `SIGIR 2026` instead of `SIGIR 2026 Industry Papers Track`.
- Keep `RecSys 2026` and `COLM 2026`, but remove their `Accepted` notes.
- Display `CIKM 2026` instead of `CIKM'26 Short Paper`.
- For *LLM-Based Generative Retrieval for Snapchat Content Recommendation*, remove both `KDD submission` and `Preprint posted July 30, 2026`.
- For *Optimal spend rate estimation and pacing for ad campaigns with budgets*, remove `arXiv (2022)`.

The two preprints without venue text will omit the `venue` field rather than store an empty string.

## Data and rendering behavior

Publication `title` and `authors` remain required non-empty text. `venue` becomes optional. The shared renderer emits venue markup only when a non-empty venue is present, so an omitted venue creates neither an empty bold element nor an extra blank line. Notes remain optional and are rendered only when present.

## Author typography

The renderer will wrap author text in a dedicated `publication-authors` class. The class will retain the site's existing typeface and use:

- `font-size: 0.92em`
- the existing text color with modestly reduced opacity

Titles and links retain their current styling, while venues remain bold. The same author treatment applies to publications and preprints on both the home page and the Publications page.

## Testing and verification

- Data tests will assert the revised labels, removed notes, and optional preprint venues.
- Rendered-site tests will assert that venue markup is absent for the two venue-less preprints and that author text uses the dedicated class.
- The full Jekyll production build and existing repository tests must pass.
- The local home and Publications previews will be refreshed and visually checked before pushing the branch.
