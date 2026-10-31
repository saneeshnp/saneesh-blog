# Photo gallery maintenance

Edit index.md to reorder photos or change alt, note, location, and year.
Photos are currently ordered by capture date, newest first. Only the year is
published; full dates are used locally to establish the list order. Place new
entries at their chronological position when adding photos.
The note and location are optional. Notes appear beneath the full-size photo.
The grid displays only the capture year and optional location.
Use descriptive alt text for accessibility; keep personal commentary in note.

To prepare new images on macOS:

1. Put JPG/JPEG originals in the ignored `Photos Original` folder.
2. Run `swift scripts/prepare-photos.swift`. The watermarked output goes to
   the ignored `Photos Prepared` staging folder, outside Hugo's content tree.
3. Review the results and copy only selected JPEGs into `content/photos/`.
4. Add their filenames, years, descriptive alt text, and optional locations and
   notes to `content/photos/index.md`, in the desired order. The script never
   edits this file or infers personal locations from source filenames.

Example entry:

```yaml
  - src: "photo-2026-<identifier>.jpg"
    year: 2026
    alt: "A description of what is visible in the photograph"
    location: "Optional place name"
    note: "Optional personal note"
```

The bundle uses `build.publishResources: false` so unreferenced files are not
automatically copied to the site. Its explicit sharing image also avoids the
theme's automatic featured-image discovery. Keep unselected photos in staging:
files committed to a public GitHub repository are public even if Hugo does not
publish them. To remove a photo, remove its list entry and its JPEG from the
bundle. Preparing the folder again only writes staging copies, so it cannot
restore a removed gallery photo.

The script makes sRGB JPEG copies at up to 2400px and quality 0.9, applies
orientation, adds saneesh.net at bottom right, and discards source metadata.
Published names contain only year and an opaque identifier, never full dates.
Originals stay local, unchanged and excluded from Git and Hugo publication.

Hugo builds cropped 400px/800px-wide WebP previews. Full JPEGs load on click only.
Previews crop to fill their portrait frames; the viewer shows the whole photo.
The native dialog supports Escape, Tab, arrow keys, previous/next and close.
Without JavaScript, thumbnail links open the processed JPEG directly.
No image preparation software is required on the deployment host.
