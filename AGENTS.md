# Repository guidance

## Stack and workflow

- This is the Hugo site for saneesh.net, using PaperMod as a Git submodule.
- Keep the site static and lightweight. No npm build or JavaScript framework is
  required. The Swift photo preparation tool runs locally on macOS, not on hosting.
- Cloudflare Pages builds with `hugo --minify` after a push. Do not push or deploy
  unless requested.
- Use `hugo server -D` for local previews and `hugo --minify` for production checks.
  For publication checks, build into a fresh temporary destination so stale files
  from previous builds cannot hide removed-resource problems.
- `public/` and `resources/_gen/` are generated output; do not commit them.
- For hosting build failures, check the configured `HUGO_VERSION` and that Git
  submodules were initialized. Keep hosting settings aligned with the working
  Hugo version; do not change them as part of unrelated content edits.

## Public documentation and privacy

- Keep agent guidance technical and suitable for a public repository. Do not
  record credentials, private account details, personal conversation history,
  home/work addresses, or private photo context in instruction files.
- Use repository-relative paths in checked-in documentation. Do not copy local
  usernames, absolute home-directory paths, or session identifiers into it.
- Use generic examples instead of actual source photo filenames, capture
  timestamps, or personal filename aliases. Public branding and intentionally
  published content are not secrets, but do not duplicate personal details into
  agent instructions when they serve no implementation purpose.
- Ignoring a file does not remove it from existing Git history. Check what is
  tracked before committing private inputs; do not rewrite history without an
  explicit request.

## Project structure

- `hugo.yaml`: menus, global presentation settings, and search configuration.
- `content/posts/`: blog posts; `archetypes/default.md`: new-content defaults.
- `content/projects.md` and `layouts/_default/projects.html`: Projects page.
- `content/archives/archives.md` and `content/search.md`: archive and search pages.
- `layouts/partials/header.html`: custom masthead and navbar.
- `layouts/partials/home_info.html`: homepage introduction and social links.
- `layouts/partials/comments.html` and `author-bio.html`: author bio integration;
  do not assume the comments partial contains a third-party comment service.
- `layouts/partials/extend_head.html`: font loading and page-specific head assets.
- `layouts/partials/extend_footer.html`: shared footer enhancement scripts.
- `static/images/`: shared site images; process gallery images as page resources.

## Theme and UI conventions

- Never edit `themes/PaperMod/`. Add project-level layout or partial overrides.
- Prefer the smallest override: CSS or config first, then extension partials and
  small custom partials, with full template overrides only when necessary.
- Keep custom CSS in `assets/css/extended/custom.css`. Comment the reason for
  non-obvious styles and scope page-specific selectors to avoid affecting posts.
- Use PaperMod color variables and `data-theme` selectors. Light-only changes
  must not change dark mode; follow the existing light-selector pair.
- Navbar entries belong in `hugo.yaml`; the custom header reads this menu.
- Preserve `params.mainSections: [posts]` and the homepage JSON output for search.
- Preserve keyboard access, visible focus, responsive layouts, and light/dark
  compatibility. Do not add gallery dependencies or third-party image requests.
- Inspect existing CSS before adding rules. Homepage layout rules are scoped by
  `.main:has(.home-info)` so they do not affect posts, archives, or the gallery.
  Preserve the desktop sidebar and the stacked layout on smaller screens.
- Preserve the existing separation between visible content and presentation:
  post descriptions remain available for SEO even though hidden on the page,
  and decorative card labels must not create duplicate interactive elements.
- The current typography uses Newsreader for reading text, Inter for UI labels,
  and a monospace stack for code. Verify source before carrying forward styling
  assumptions: the older `CLAUDE.md` describes Lora, which is no longer loaded.

## Blog content conventions

- Use kebab-case filenames under `content/posts/` and start new posts as drafts.
  Do not publish drafts unless requested. Drafts in a public Git repository are
  still publicly readable even when omitted from Hugo output.
- Keep ordinary post front matter minimal: `title`, `date`, `draft`, `tags`, and
  `description`. Blog publication dates are separate from private photo capture
  dates. Avoid duplicating presentation flags already controlled globally.
- Reuse existing tags with Title Case and avoid introducing categories or
  unnecessary taxonomy variants.
- For authored blog prose, follow the existing first-person, reflective voice:
  short paragraphs, direct openings, `##`/`###` headings where helpful, restrained
  bold text, and acronyms spelled out on first use. Avoid em dashes and canned
  conclusions. Preserve the author's voice when editing existing posts.
- Local rendering examples use `content/posts/_test-*.md`, which is ignored.
  Keep private material out of such examples even when Git-ignored.

## Photo gallery

Read `docs/photos.md` before changing the gallery or preparing photos.

Key files:

- `content/photos/index.md`: selected photos, their display order, and metadata.
- `layouts/_default/photos.html`: gallery and native dialog viewer.
- `assets/js/photos.js`: click-to-load enhancement, loaded only on the Photos page
  through `layouts/partials/extend_head.html`, with minification and fingerprinting.
- `scripts/prepare-photos.swift`: local resizing, watermarking, and metadata removal.

### Privacy and publication

- Never modify originals. `Photos Original/` and `Photos Prepared/` are ignored,
  local-only folders. Never force-add their contents to Git.
- Preparation writes only to `Photos Prepared/`. Review copies before moving
  selected JPEGs into `content/photos/`; the script must not edit gallery metadata
  or automatically restore removed photos.
- Publish only capture years. Do not put full capture dates, times, GPS data, or
  original filenames into public filenames, image metadata, or front matter.
  Dates in local source filenames may be used to establish chronological order.
- Keep `build.publishResources: false` and an explicit sharing image in the
  gallery front matter. Hugo otherwise publishes unlisted bundle resources, and
  theme featured-image discovery can also publish an unintended image.
- Files committed to this public repository are public even if Hugo does not
  publish them. Keep unselected images outside the content tree.
- Locations and notes are optional, deliberately public fields in `index.md`.
  Do not reintroduce personal filename-to-location mappings into the Swift tool.
- Removing a photo means removing its list entry and its processed JPEG from the
  bundle. Preserve the local original unless explicitly asked to delete it.

### Images and viewer behavior

- Web copies use a maximum 2400px long edge, no upscaling, sRGB, JPEG quality 0.9,
  corrected orientation, and a subtle `saneesh.net` watermark at bottom right.
- Generate actual 400px/800px-wide cropped WebP previews with Hugo. Narrow sources
  must not yield undersized previews that are enlarged to fill thumbnail frames.
- Thumbnails fill portrait frames; the viewer shows the entire photograph.
- Keep the gallery newest-first by capture date through the explicit list order.
  Sorting by displayed year or hashed filename cannot establish exact chronology.
- Keep descriptive alt text separate from optional personal notes. Missing alt
  text or a missing referenced image should fail the build.
- Full-size images must have no initial image `src`; assign it only when opening
  or navigating the viewer. Lazy-load below-the-fold thumbnails.
- Preserve ordinary image links as a fallback without JavaScript, Escape/arrow-key
  controls, focus restoration, loading/error feedback, and 44px viewer tap targets.
- Render notes and locations with contextual template escaping and `textContent`,
  never `innerHTML`. Release previous image handlers and sources when navigating
  or closing, and guard against stale image-load events.

### Verification

- Run the Hugo production build and `git diff --check` after source changes.
  Run `node --check assets/js/photos.js` when changing the viewer script.
- For image-processing changes, check dimensions, orientation, watermark placement,
  removal of capture dates/GPS, and that originals remain unchanged.
- For publication changes, verify a clean build includes selected JPEGs and
  thumbnails while excluding unlisted resources and local staging folders.
- For viewer changes, check opening, rapid navigation, closing, focus restoration,
  and both themes. Confirm initial image sources reference only thumbnails and
  the viewer script is absent from other pages.
