# reanimate site

The website for the reanimate skill in [`../skills/reanimate`](../skills/reanimate). Next.js 16, exported as static files and served by a Cloudflare Worker (static assets only, no server code). Commands below run from this `site/` folder.

## Develop

```sh
bun install
bun run dev        # http://localhost:3000
```

`predev` and `prebuild` copy three.js and the Inter font from `node_modules` into `public/examples/stripe-bento/vendor/` (git-ignored), because the live examples are plain HTML pages loaded in iframes.

```sh
bun run preview    # next build, then wrangler dev on http://localhost:8787
bun run lint
```

## Add an example

1. Put the clone, as a standalone page, in `public/examples/<name>/` (see `stripe-bento/`).
2. Put its media in `public/media/<slug>/`: `poster.webp` (the clone at rest, for the thumbnails) and, for a recorded example, `compare.mp4` (the original and the clone, recorded the same way and side by side in one file).
3. Add an entry to `src/examples.ts`. The home page shows it at the end, under Examples; what it does and its numbers sit behind a "details" tooltip. `show.kind` picks the picture: `"video"` plays `compare.mp4`; `"live"` runs the clone itself in the page, in an iframe (the clerk.com cards do this; `clerk-bento/?card=<slug>&embed` frames one card for it).

To record the media, add a row to `CLIPS` in `scripts/record-media.ts`: the original's URL, the clone's path and the elements to film, plus `pin` when the animation picks things at random, so both sides pick the same, and `sync` when each page runs a loop that starts on its own clock rather than on the scroll or hover, so the two takes are lined up by their frames. With the site running on `bun run preview`:

```sh
bun run media                       # every clip
bun run media --only <slug>         # one clip
```

It films the original and the clone in the same browser with the same scroll, pointer path and timing, at 2x and 60 fps, and writes `compare.mp4` and `poster.webp` into `public/media/<slug>/`. Both recordings go into one file so they can never drift apart on the page. It also writes the README animations in `../.github/assets/`. It needs Playwright's Chromium (`bunx playwright install chromium`), and `ffmpeg`, `cwebp` and `webpmux` on your PATH (`brew install ffmpeg webp`). The 2x zoom and GPU flags it uses are tested on macOS.

## Deploy to Cloudflare Workers

Set the public URL first, so the Open Graph and canonical links are absolute:

```sh
# .env.production
SITE_URL=https://reanimate.<your-subdomain>.workers.dev
```

Then either:

- **From this machine:** `npx wrangler login` once (or export `CLOUDFLARE_API_TOKEN` with the "Edit Cloudflare Workers" template), then `bun run deploy`.
- **On every push:** in the Cloudflare dashboard, Workers & Pages → Create → Import a repository → `NiazMorshed2007/reanimate`. Root directory `site`, build command `bun run build`, deploy command `npx wrangler deploy`. Add `SITE_URL` as a build variable.

`wrangler.jsonc` names the Worker `reanimate` and serves `./out`, with `404.html` for unknown paths.

## Layout

| Path | What it is |
|---|---|
| `src/app/page.tsx` | The whole page: copy, sections, tables. |
| `src/examples.ts` | The examples, in the order they appear. |
| `src/components/` | `CompareVideo` (plays a `compare.mp4` while it's on screen), `LiveCard` (a clone in an iframe, scaled down on narrow screens), `Nav`, `Sidenote`, `CopyCommand`. |
| `public/examples/` | The clones as standalone pages. `stripe-bento/?card=agentic-commerce\|issuing\|crypto` shows one card; `workos-atlas/` is the workos.com integrations visual; `clerk-bento/` is clerk.com's grid of feature cards (`?card=<slug>` for one); `liveblocks-comments/` is the demo under the liveblocks.io/comments hero; `resend-cube/` is the resend.com hero cube; `reactbits-fading-stars/` is React Bits Pro's Fading Stars. |
| `public/media/` | Comparisons and posters, one folder per example. `stripe-bento/` is the entrance at the top of the page. |
| `scripts/record-media.ts` | Records the examples' media and the README animations. |
| `marketing/launch.md` | Launch post drafts. |
| `video/` | The 47-second demo video, as a page drawn frame by frame from the time and rendered to mp4 ([`video/README.md`](video/README.md)). The site serves it at `/demo.mp4` (`public/demo.mp4`). |

## About the examples

The live examples recreate parts of stripe.com, workos.com and clerk.com as a study of the technique. The Stripe cards use Inter instead of Stripe's licensed Söhne, but port Stripe's shaders and use Stripe's images; the WorkOS visual uses WorkOS's robot images, app icons and screen shaders; the Clerk cards use Geist and Geist Mono instead of Clerk's licensed fonts, and port Clerk's inline SVG, light-streak canvas and dot-field shader. The Liveblocks demo uses Inter instead of the licensed Suisse Int'l, and reuses liveblocks.io's avatars, drawings and icons. The Resend cube draws resend.com's own Spline scene (geometry, textures and shaders) with three.js, over resend.com's hero images. Fading Stars ports the shaders and simulation that pro.reactbits.dev runs for its live preview. Not affiliated with or endorsed by Stripe, WorkOS, Clerk, Liveblocks, Resend or React Bits.
