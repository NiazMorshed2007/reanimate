# Video demo

Một bản demo 47 giây của reanimate, không có tiếng, các đoạn cắt nằm trên lưới 90 bpm. Nó là một trang web: mỗi khung hình được vẽ chỉ từ thời gian, rồi chụp lại và mã hóa, nên bản kết xuất chính xác đến từng khung hình. Các lệnh chạy từ `site/`.

| Thời gian | Phách | Nội dung |
|---|---|---|
| 0–2 s | intro | `/reanimate` trượt vào với các khung hình onion-skin phía sau |
| 2–6.2 s | 0–1.5 | một vòng quay chọn những thứ có thể yêu cầu, mỗi nhịp một cái; cái cuối cùng được nhập vào |
| 6.2–15.5 s | 1.5–5 | các bản clone, cỡ lớn, cứ hai nhịp một cái: Fading Stars của React Bits, Stripe, Liveblocks, WorkOS, Clerk |
| 15.5–23.5 s | 5–8 | khối Resend ở cận cảnh; máy quay lùi lại để thấy cả 18 cái trong một bức khảm, rồi xoắn thành một vòng xoắn đang quay |
| 23.5–39.5 s | 8–14 | cách nó hoạt động, trên ba bản clone cùng lúc (thẻ Agentic commerce của stripe.com, khối lập phương của resend.com, thẻ Session management của clerk.com): ghi lại, đặc tả, dựng, kiểm chứng, lặp lại (độ khác biệt điểm ảnh của các bản sao thu hẹp sau mỗi vòng) |
| 39.5 s–end | 14–17 | lệnh cài đặt; `/reanimate`, màu xám suốt video, chuyển thành màu mực |

## Cách tạo

```sh
bun video/scripts/clips.ts     # records the 18 clones into video/clips/ (about 3 minutes)
bun video/scripts/render.ts    # video/out/reanimate-demo.mp4, 1920x1080, 60 fps
bun video/scripts/publish.ts   # public/demo.mp4 for the site, and the README's preview, ../.github/assets/demo.webp
```

`clips.ts` quay mỗi bản clone trên đồng hồ ảo của skill (`skills/reanimate/scripts/capture.ts --clock virtual`) ở 2x và 60 fps, nên clip cho ra giống hệt nhau ở mọi lần chạy. Cho phần "cách nó hoạt động", nó cũng quay thẻ Session management của clerk.com và bản sao của thẻ đó theo cùng cách (`how-clerk-*`), và cắt bản gốc cùng bản sao của hai cái còn lại từ các bản ghi của trang web (`public/media/stripe-bento/compare.mp4` và `resend-cube/compare.mp4`, thành `how-stripe-*` và `how-resend-*`; `--only compare` chỉ làm lại những cái đó). `--only <slug>,…` làm lại một số clip.

Các tùy chọn của `render.ts`: `--scale 2` vẽ ở 3840x2160 rồi thu nhỏ xuống (sắc nét hơn, chậm hơn khoảng 4 lần); `--size 3840x2160` giữ nguyên kích thước đó; `--from 12 --to 29` kết xuất một đoạn; `--stills 1.5,13.2` ghi ảnh PNG của từng khoảnh khắc vào `video/out/stills/`. Nó cần Chromium của Playwright và `ffmpeg` trong PATH. `publish.ts` tạo một bản sao nhỏ hơn mà trang web phục vụ tại `/demo.mp4` (README liên kết tới nó), và bản xem trước của README: vài khoảnh khắc của video, chuyển cảnh mờ dần thành một vòng lặp 20 giây. Nó cần `ffmpeg`, `cwebp` và `webpmux`.

## Video Vercel

`vercel.html` là một video thứ hai trên cùng sân khấu và cùng bộ kết xuất: 37.6 giây của sáu bản clone Vercel (vercel.com, nextjs.org, turborepo.com), mỗi cái đặt cạnh bản gốc của nó, rồi cả sáu cùng lúc và lệnh cài đặt. Các cảnh của nó nằm trong `src/vercel/`; `shots.js` liệt kê các cảnh quay, thời gian và các con số của chúng. Các cặp hình là bản ghi của chính trang web, được `record-media` giữ cho thẳng hàng:

```sh
bun run media --only vercel-previews,vercel-hero,vercel-fluid,vercel-workflow,turborepo-gauge,nextjs-rsc --keep <dir>
bun video/scripts/clips.ts --masters <dir>        # each as <slug>-reference and <slug>-copy
bun video/scripts/render.ts --page vercel.html     # video/out/vercel.mp4
```

Trình phát nằm tại `/video/vercel.html` trên `serve.ts`.

## Chỉnh sửa

```sh
bun video/scripts/serve.ts     # http://localhost:4700/video/
```

Một trình phát: phím cách phát và tạm dừng, ←/→ tiến/lùi một khung hình (giữ shift: một giây), `?t=12.5` bắt đầu từ đó. Mỗi cảnh là một mô-đun trong `src/` với `from`, `to`, `init(root)` và `render(t)`, và tùy chọn `shift` để giữ đồng hồ riêng (`how.js` được tính giờ như thể nó bắt đầu ở 12.86 giây và phát chậm hơn 4 phách); `src/lib.js` chứa lưới nhịp (`bar(n)`, `beat(n)`), easing và hàm hỗ trợ làm mờ–mờ dần mà các chuyển cảnh dùng chung.
