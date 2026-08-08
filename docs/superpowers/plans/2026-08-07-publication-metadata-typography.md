# Publication Metadata and Typography Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Simplify 2026 publication labels, allow venue-less preprints, and visually distinguish author names from titles.

**Architecture:** Keep publication content in `_data/publications.yml`, extend its validation so `venue` is optional, and make the shared Liquid include conditionally render venue metadata. Add one focused Sass partial for author typography and import it through the existing main stylesheet.

**Tech Stack:** Jekyll 3.10, Liquid, YAML, Sass, Ruby Minitest

## Global Constraints

- Display `SIGIR 2026`, `RecSys 2026`, `COLM 2026`, and `CIKM 2026` exactly.
- Do not render `Accepted`, `KDD submission`, `Preprint posted July 30, 2026`, or `arXiv (2022)`.
- Keep `title` and `authors` required; make `venue` optional.
- Do not render empty venue markup or extra blank lines.
- Render authors in the existing typeface at `0.92em` with modestly reduced opacity.
- Apply the same shared rendering to the home page and Publications page.

---

### Task 1: Publication metadata and optional venue schema

**Files:**
- Modify: `test/publications_data_test.rb`
- Modify: `_data/publications.yml`

**Interfaces:**
- Consumes: YAML records with `title`, `authors`, optional `venue`, optional `note`, and optional `links`.
- Produces: validated records whose two preprints may omit `venue` and whose 2026 labels match the approved copy.

- [ ] **Step 1: Write failing metadata tests**

Change required fields and add literal expected metadata:

```ruby
REQUIRED_FIELDS = %w[title authors].freeze
EXPECTED_REVISED_METADATA = {
  "Semantic IDs for Recommender Systems at Snapchat: Use Cases, Technical Challenges, and Design Choices" =>
    { "venue" => "SIGIR 2026", "note" => nil },
  "Exploiting ID-Text Complementarity via Ensembling for Sequential Recommendation" =>
    { "venue" => "RecSys 2026", "note" => nil },
  "CoSearch: Joint Training of Reasoning and Document Ranking via Reinforcement Learning for Agentic Search" =>
    { "venue" => "COLM 2026", "note" => nil },
  "Training-Free LLM-Based Recommendation with Post-LLM Item Refinement Using Collaborative Signals" =>
    { "venue" => "CIKM 2026", "note" => nil },
  "LLM-Based Generative Retrieval for Snapchat Content Recommendation" =>
    { "venue" => nil, "note" => nil },
  "Optimal spend rate estimation and pacing for ad campaigns with budgets" =>
    { "venue" => nil, "note" => nil }
}.freeze

def test_revised_publication_metadata
  records_by_title = records.to_h { |record| [record["title"], record] }

  EXPECTED_REVISED_METADATA.each do |title, expected|
    record = records_by_title.fetch(title)
    assert_equal expected["venue"], record["venue"], title
    assert_equal expected["note"], record["note"], title
  end
end

def test_present_venues_are_non_empty_text
  records.each do |record|
    next unless record.key?("venue")

    assert_kind_of String, record["venue"], record.inspect
    refute_empty record["venue"].strip, record.inspect
  end
end
```

- [ ] **Step 2: Run the data test and verify RED**

Run:

```bash
env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin" ruby test/publications_data_test.rb
```

Expected: FAIL because the old labels, notes, and preprint venues are still present.

- [ ] **Step 3: Apply the approved YAML changes**

Update the affected records to these values:

```yaml
venue: "SIGIR 2026"
```

```yaml
venue: "RecSys 2026"
```

```yaml
venue: "COLM 2026"
```

```yaml
venue: "CIKM 2026"
```

Delete the RecSys and COLM `note` fields. Delete both `venue` and `note` from the LLM-Based Generative Retrieval preprint. Delete `venue` from the Optimal Spend Rate preprint.

- [ ] **Step 4: Run the data test and verify GREEN**

Run:

```bash
env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin" ruby test/publications_data_test.rb
```

Expected: PASS with zero failures and zero errors.

- [ ] **Step 5: Commit the metadata task**

```bash
git add test/publications_data_test.rb _data/publications.yml
git commit -m "content: simplify publication metadata"
```

---

### Task 2: Conditional metadata renderer and author typography

**Files:**
- Modify: `test/rendered_site_test.rb`
- Modify: `_includes/publications-list.html`
- Create: `_sass/layout/_publications.scss`
- Modify: `assets/css/main.scss`

**Interfaces:**
- Consumes: publication records from Task 1, including records without `venue`.
- Produces: `.publication-authors` spans for every record and `.publication-venue` strong elements only for non-empty venues.

- [ ] **Step 1: Write failing rendered-site tests**

Add assertions that inspect the built home and Publications pages:

```ruby
def test_authors_have_dedicated_typography_hook
  expected_count = records.length

  PAGES.each do |relative_path|
    html = page(relative_path)
    assert_equal expected_count, html.scan(/class="publication-authors"/).length, relative_path
  end
end

def test_venue_less_preprints_do_not_render_empty_venue_markup
  venue_less_titles = records.select { |record| record["venue"].nil? }.map { |record| record["title"] }

  PAGES.each do |relative_path|
    html = page(relative_path)
    list_items = html.scan(/<li>.*?<\/li>/m)

    venue_less_titles.each do |title|
      item = list_items.find { |candidate| candidate.include?(title) }
      refute_nil item, title
      refute_includes item, "publication-venue", title
      refute_match(/<strong(?:\s+[^>]*)?>\s*<\/strong>/m, item, title)
    end
  end
end
```

- [ ] **Step 2: Build and run the rendered test to verify RED**

Run:

```bash
env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin" JEKYLL_ENV=production bundle exec jekyll build
env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin" SITE_DIR="_site" ruby test/rendered_site_test.rb
```

Expected: FAIL because the author class and conditional venue class do not exist.

- [ ] **Step 3: Add semantic renderer classes and conditional venue output**

In both publication loops, render:

```liquid
{{ publication.title }}<br>
<span class="publication-authors">{{ publication.authors }}</span>
{% if publication.venue %}
  <br>
  <strong class="publication-venue">{{ publication.venue }}</strong>
{% endif %}
```

Keep optional notes adjacent to venue metadata and render no note when absent. Preserve link rendering and the Training-Free no-link behavior.

- [ ] **Step 4: Add focused Sass styling**

Create `_sass/layout/_publications.scss`:

```scss
.publication-authors {
  font-size: 0.92em;
  opacity: 0.82;
}
```

Import it after `layout/page` in `assets/css/main.scss`:

```scss
"layout/page",
"layout/publications",
"layout/archive",
```

- [ ] **Step 5: Build and run rendered tests to verify GREEN**

Run:

```bash
env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin" JEKYLL_ENV=production bundle exec jekyll build
env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin" SITE_DIR="_site" ruby test/rendered_site_test.rb
```

Expected: PASS with zero failures and zero errors.

- [ ] **Step 6: Commit the renderer and typography task**

```bash
git add test/rendered_site_test.rb _includes/publications-list.html _sass/layout/_publications.scss assets/css/main.scss
git commit -m "style: refine publication metadata hierarchy"
```

---

### Task 3: Full verification and local preview

**Files:**
- Verify only; no source changes expected.

**Interfaces:**
- Consumes: completed Tasks 1 and 2.
- Produces: a clean feature branch and refreshed local previews ready for review.

- [ ] **Step 1: Run the complete automated verification**

```bash
env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin" ruby test/publications_data_test.rb
env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin" ruby test/repository_cleanup_test.rb
env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin" JEKYLL_ENV=production bundle exec jekyll build
env PATH="/opt/homebrew/opt/ruby/bin:/usr/bin:/bin" SITE_DIR="_site" ruby test/rendered_site_test.rb
git diff --check origin/master...HEAD
git status --short --branch
```

Expected: all tests and build exit zero, diff check emits no output, and status shows no uncommitted changes.

- [ ] **Step 2: Refresh and inspect both local routes**

Refresh `http://127.0.0.1:4000/` and `http://127.0.0.1:4000/publications/`. Verify the four revised venue labels, absence of removed metadata, venue-less preprints without blank lines, and the subtler author typography on desktop and narrow layouts.

- [ ] **Step 3: Keep the feature branch unpushed**

Do not push or merge until the user approves the refreshed preview.
