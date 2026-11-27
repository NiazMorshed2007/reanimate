# Trang web reanimate

Trang web cho skill reanimate ở [`../skills/reanimate`](../skills/reanimate). Next.js 16, xuất ra file tĩnh và được phục vụ bởi một Cloudflare Worker (chỉ tài nguyên tĩnh, không có code phía server). Các lệnh dưới đây chạy từ thư mục `site/` này.

## Phát triển

```sh
bun install
bun run dev        # http://localhost:3000
```

`predev` và `prebuild` sao chép three.js và font Inter từ `node_modules` vào `public/examples/stripe-bento/vendor/` (đã git-ignore), vì các ví dụ trực tiếp là những trang HTML thuần được nạp trong iframe.

```sh
bun run preview    # next build, then wrangler dev on http://localhost:8787
bun run lint
```

## Thêm một ví dụ

1. Đặt bản clone, dưới dạng một trang độc lập, vào `public/examples/<name>/` (xem `stripe-bento/`).
2. Đặt media của nó vào `public/media/<slug>/`: `poster.webp` (bản clone lúc đứng yên, dùng cho ảnh thu nhỏ) và, với ví dụ dạng ghi hình, `compare.mp4` (bản gốc và bản clone, ghi theo cùng một cách và đặt cạnh nhau trong một file).
3. Thêm một mục vào `src/examples.ts`. Trang chủ hiển thị nó ở cuối, dưới mục Examples; phần mô tả nó làm gì và các con số của nó nằm sau một tooltip "details". `show.kind` quyết định cách hiển thị: `"video"` phát `compare.mp4` (`stacked` khi hai bản ghi nằm chồng lên nhau); `"live"` chạy chính bản clone trong trang, trong một iframe, cho những cái bạn có thể di chuột hoặc kéo (các thẻ clerk.com và hầu hết các ví dụ Vercel; `clerk-bento/?card=<slug>&embed` đóng khung một thẻ cho nó). Loại live chỉ cần `poster.webp`; `background` tô màu khung của nó và `try` nói người dùng nên làm gì với nó.

Để ghi media, thêm một dòng vào `CLIPS` trong `scripts/record-media.ts`: URL của bản gốc, đường dẫn của bản clone và các phần tử cần quay, cộng thêm `pin` khi animation chọn ngẫu nhiên, để cả hai phía chọn giống nhau, và `sync` khi mỗi trang chạy một vòng lặp bắt đầu theo đồng hồ riêng của nó thay vì theo lần cuộn hay di chuột, để hai bản ghi được căn theo khung hình. Một clip hover có thể có `path` đường di chuột và độ dài `ms` riêng; `still` giữ cho một điểm nhỏ liên tục vẽ lại trong khi quay một trang đang nghỉ giữa các chuyển động, để khung hình vẫn ra đều ở 60 fps; `trigger: "drop"` kéo một file qua phần tử (hero của vercel.com). Khi trang web đang chạy bằng `bun run preview`:

```sh
bun run media                       # every clip
bun run media --only <slug>         # one clip
bun run media --keep <dir>          # also keep the takes, lined up, for video/ (masters.json)
```

Nó quay bản gốc và bản clone trong cùng một trình duyệt với cùng thao tác cuộn, đường di chuột và thời gian, ở mức zoom 2x và 60 fps, rồi ghi `compare.mp4` và `poster.webp` vào `public/media/<slug>/`. Cả hai bản ghi nằm trong một file nên không bao giờ lệch nhau trên trang. Nó cũng ghi các animation của README vào `../.github/assets/`. Nó cần Chromium của Playwright (`bunx playwright install chromium`), và `ffmpeg`, `cwebp` cùng `webpmux` trong PATH của bạn (`brew install ffmpeg webp`). Mức zoom 2x và các cờ GPU nó dùng đã được kiểm thử trên macOS.

## Triển khai lên Cloudflare Workers

Đặt URL công khai trước, để các liên kết Open Graph và canonical là tuyệt đối:

```sh
# .env.production
SITE_URL=https://reanimate.<your-subdomain>.workers.dev
```

Sau đó chọn một trong hai cách:

- **Từ máy này:** `npx wrangler login` một lần (hoặc export `CLOUDFLARE_API_TOKEN` với mẫu "Edit Cloudflare Workers"), rồi `bun run deploy`.
- **Mỗi khi push:** trong bảng điều khiển Cloudflare, Workers & Pages → Create → Import a repository → `NiazMorshed2007/reanimate`. Thư mục gốc `site`, lệnh build `bun run build`, lệnh deploy `npx wrangler deploy`. Thêm `SITE_URL` làm biến build.

`wrangler.jsonc` đặt tên Worker là `reanimate` và phục vụ `./out`, với `404.html` cho các đường dẫn không tồn tại.

## Bố cục

| Đường dẫn | Là gì |
|---|---|
| `src/app/page.tsx` | Toàn bộ trang: nội dung chữ, các mục, các bảng. |
| `src/examples.ts` | Các ví dụ, theo thứ tự xuất hiện. |
| `src/components/` | `CompareVideo` (phát `compare.mp4` khi nó hiện trên màn hình), `LiveCard` (một bản clone trong iframe, thu nhỏ trên màn hình hẹp), `Nav`, `Sidenote`, `CopyCommand`. |
| `public/examples/` | Các bản clone dưới dạng trang độc lập. `stripe-bento/?card=agentic-commerce\|issuing\|crypto` hiển thị một thẻ; `workos-atlas/` là hình ảnh tích hợp của workos.com; `clerk-bento/` là lưới thẻ tính năng của clerk.com (`?card=<slug>` cho một thẻ); `liveblocks-comments/` là bản demo dưới hero của liveblocks.io/comments; `resend-cube/` là khối lập phương hero của resend.com; `reactbits-fading-stars/` là Fading Stars của React Bits Pro. `vercel-previews/` là thanh công cụ trên vercel.com/products/previews; `vercel-hero/` là tam giác hero của vercel.com; `vercel-fluid/` là đại dương ở vercel.com/fluid; `vercel-workflow/` là bảng điều khiển trên vercel.com/workflow; `turborepo-gauge/` là đồng hồ tốc độ của turborepo.com; `nextjs-features/` là ba thẻ minh họa của nextjs.org (`?card=optimizations\|streaming\|rsc`). Các ví dụ live nhận tham số `?embed`. |
| `public/media/` | Các bản so sánh và poster, mỗi ví dụ một thư mục. `stripe-bento/` là phần mở đầu ở đầu trang. |
| `scripts/record-media.ts` | Ghi media của các ví dụ và các animation của README. |
| `marketing/launch.md` | Các bản nháp bài đăng ra mắt. |
| `video/` | Video demo 47 giây, dưới dạng một trang được vẽ từng khung hình từ thời gian và kết xuất thành mp4 ([`video/README.md`](video/README.vi.md)). Trang web phục vụ nó tại `/demo.mp4` (`public/demo.mp4`). `vercel.html` là một video thứ hai, về các bản clone Vercel. |

## Về các ví dụ

Các ví dụ trực tiếp tái tạo một phần của vercel.com, nextjs.org, turborepo.com, stripe.com, workos.com, clerk.com, liveblocks.io, resend.com và pro.reactbits.dev như một nghiên cứu về kỹ thuật. Các thẻ Stripe dùng Inter thay cho Söhne có bản quyền của Stripe, nhưng port các shader của Stripe và dùng hình ảnh của Stripe; hình ảnh WorkOS dùng hình robot, biểu tượng ứng dụng và shader màn hình của WorkOS; các thẻ Clerk dùng Geist và Geist Mono thay cho font có bản quyền của Clerk, và port SVG nội tuyến, canvas vệt sáng và shader trường chấm của Clerk. Bản demo Liveblocks dùng Inter thay cho Suisse Int'l có bản quyền, và tái sử dụng avatar, hình vẽ và biểu tượng của liveblocks.io. Khối Resend vẽ cảnh Spline của chính resend.com (hình học, texture và shader) bằng three.js, trên nền hình hero của resend.com. Fading Stars port các shader và mô phỏng mà pro.reactbits.dev chạy cho bản xem trước trực tiếp của nó. Các bản sao Vercel, Next.js và Turborepo dùng các bản dựng Geist mà những trang đó phục vụ (OFL). Hero của vercel.com và đại dương Fluid port chính renderer của vercel.com, 13 shader GLSL và 10 mô-đun WGSL của nó mà không thay đổi; thanh công cụ, bảng điều khiển workflow và đồng hồ Turborepo tái sử dụng SVG nội tuyến của các trang đó và chạy code animation được port từ trang, thanh công cụ kèm hình avatar của vercel.com; các thẻ Next.js port code vẽ canvas và SVG của nextjs.org cùng dữ liệu chấm của nó. Không liên kết với, cũng không được chứng thực bởi Vercel, Stripe, WorkOS, Clerk, Liveblocks, Resend hay React Bits.
