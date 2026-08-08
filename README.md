# bhuveshkumar.com

Source for [bhuveshkumar.com](https://bhuveshkumar.com), built with Jekyll and published by GitHub Pages.

## Add or update a publication

Edit `_data/publications.yml`. Items under `publications` appear under **Publications**; items under `preprints` appear under **Preprint(s)**. Their order in the YAML file is their order on the website.

Linked example:

```yaml
- title: "Paper title"
  authors: "First Author, Bhuvesh Kumar"
  venue: "Conference 2026"
  note: "Accepted"
  links:
    - label: "paper"
      url: "https://example.com/paper"
```

Unlinked example:

```yaml
- title: "Paper awaiting a public URL"
  authors: "First Author, Bhuvesh Kumar"
  venue: "Conference 2026 Short Paper"
```

Omit `links` until a URL has been verified. Use `highlight: true` only for an award note that should retain the red emphasis used on the current site.

## Test and build

This Mac has the required Ruby and Bundler under Homebrew. Prefix commands so they do not use the older system Ruby:

```bash
env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin" ruby test/publications_data_test.rb
env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin" ruby test/repository_cleanup_test.rb
env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin" JEKYLL_ENV=production bundle exec jekyll build
env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin" SITE_DIR="_site" ruby test/rendered_site_test.rb
```

## Preview locally

```bash
env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin" bundle exec jekyll serve --host 127.0.0.1 --port 4000
```

Open [http://127.0.0.1:4000](http://127.0.0.1:4000). GitHub pull requests do not automatically receive a rendered GitHub Pages preview URL; use the local preview before merging.

## Publish through a pull request

1. Create a feature branch from `master`.
2. Make the change and run all verification commands.
3. Push the feature branch, not `master`.
4. Open a pull request targeting `master`.
5. Merge only after reviewing the local preview and PR diff.

Merging to `master` triggers the existing GitHub Pages publication flow for [bhuveshkumar.com](https://bhuveshkumar.com).
