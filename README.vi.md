<h1 align="center">reanimate</h1>

<p align="center"><b>Học ngược những animation bạn thích. Rồi tự xây cái của mình trên nền đó.</b><br>Một skill của Claude Code hoạt động từ một trang web trực tiếp, một bản ghi màn hình, một file mp4, gif hay Lottie.</p>

<p align="center">
  <a href="https://code.claude.com/docs/en/skills"><img src="https://img.shields.io/badge/Claude_Code-skill-171717?style=flat-square&logo=claude&logoColor=white" alt="Claude Code skill"></a>
  <a href="https://agentskills.io"><img src="https://img.shields.io/badge/Agent_Skills-compatible-171717?style=flat-square" alt="Agent Skills compatible"></a>
  <a href="#cài-đặt"><img src="https://img.shields.io/badge/runs_on-Bun-171717?style=flat-square&logo=bun&logoColor=white" alt="Runs on Bun"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-171717?style=flat-square" alt="MIT license"></a>
</p>

<p align="center"><a href="README.md">Read in English</a></p>

<p align="center">
  <a href="https://reanimate.niazmorshed.dev/demo.mp4"><img src=".github/assets/demo.webp" width="760" alt="Những khoảnh khắc trong video demo: /reanimate trượt vào; ba trình duyệt ghi lại các widget trên stripe.com, resend.com và clerk.com; các bản sao được đo với bản gốc cho đến khi khác biệt biến mất; 18 ví dụ xoay trên một vòng xoắn; lệnh cài đặt tự gõ ra."></a>
</p>
<p align="center"><sub>Một đoạn demo ngắn. <a href="https://reanimate.niazmorshed.dev/demo.mp4">Xem video đầy đủ</a>.</sub></p>

Nhiều ý tưởng hay bắt đầu từ trang web của người khác. Bảo một agent dựng lại từ một đường link hay một ảnh chụp màn hình, nó chỉ làm một lượt, tuyên bố xong, và bỏ sót. Nó không nhìn thấy chuyển động, cũng không biết mình lệch bao nhiêu.

reanimate ghi lại bản gốc, dựng lại nó trong code của bạn, rồi ghi lại bản sao theo đúng cách đó và so sánh hai bản. Mỗi vòng cho thấy chỗ nào còn lệch, nên agent cứ tiếp tục cho đến khi các con số khớp nhau. Cuối cùng bạn có một điểm khởi đầu sát bản gốc để biến thành của mình.

<p align="center">
  <img src=".github/assets/entrance.webp" width="760" alt="Hai bản ghi của cùng ba thẻ đang hiện dần: stripe.com ở trên, bản sao reanimate dựng ở dưới. Các bong bóng chat, vòng hạt, thẻ Visa và quả địa cầu chấm điểm xuất hiện ở cùng thời điểm trong cả hai.">
</p>
<p align="center"><sub>Ba thẻ từ stripe.com. Trên: bản gốc. Dưới: bản sao, được quay theo cùng một cách.</sub></p>

## Cài đặt

```sh
npx skills add NiazMorshed2007/reanimate -g
```

[skills CLI](https://skills.sh) sẽ hỏi bạn muốn cài cho agent nào; thêm `-a claude-code` để bỏ qua câu hỏi. Sau đó, trong Claude Code, hãy nói bạn muốn gì, nó ở đâu và nên đặt ở đâu:

```text
/reanimate the hero entrance on https://example.com, into components/Hero.tsx
/reanimate this loader, 0:03 to 0:05 of ~/Downloads/loader.mov
/reanimate the card hover in this gif, match it exactly
/reanimate the logo marquee from https://example.com, with our logos and pause on hover
```

Cần [Bun](https://bun.sh) 1.1 trở lên, trên macOS hoặc Linux (Windows chưa được kiểm thử). Lần chạy đầu tiên sẽ cài một bản ffmpeg tĩnh vào thư mục của skill và Chromium của Playwright vào bộ nhớ đệm quen thuộc của Playwright, tổng cộng khoảng 250 MB. Không cần API key. Các agent khác có đọc `SKILL.md` cũng cài được, nhưng skill mới chỉ được kiểm thử với Claude Code.

## Cách hoạt động

1. **Ghi lại.** Nó quay bản tham chiếu trong một trình duyệt headless ở khung hình và tốc độ khung hình cố định: một video, các khung hình được đánh số, mọi animation CSS và Web Animations API tìm thấy, cùng vị trí của các phần tử được chọn trên từng khung hình. Với canvas và WebGL, nó còn truy vết các lệnh gọi GPU (shader, uniform, draw call, cảnh three.js) trên một đồng hồ ảo khiến mọi lần ghi đều giống hệt nhau.
2. **Đặc tả.** Mỗi phần tử, mỗi thuộc tính một dòng: điểm bắt đầu, thời lượng, từ → đến, easing, stagger. Dòng nào có dấu "?" nghĩa là các khung hình chưa được đọc.
3. **Dựng.** Nó viết animation bằng chính những gì dự án của bạn đang dùng: CSS, Framer Motion, GSAP, three.js.
4. **Kiểm chứng.** Nó quay bản sao theo cùng cách, so sánh thời gian, easing và điểm ảnh, rồi tạo các bảng so sánh đặt cạnh nhau.
5. **Lặp lại.** Nó sửa điểm khác biệt lớn nhất rồi quay lại, thường từ 2 đến 5 vòng. Sau 5 vòng mà vẫn còn gì chưa khớp, nó sẽ liệt kê trong báo cáo kèm lý do.

<p align="center">
  <img src=".github/assets/hover.webp" width="520" alt="Thẻ issuing được di chuột tới trên stripe.com và trong bản sao, đặt cạnh nhau: cùng một đường di chuột khiến thẻ Visa nghiêng cùng một kiểu ở cả hai.">
</p>
<p align="center"><sub>Cùng một đường di chuột trên stripe.com và trên bản sao. Độ nghiêng ổn định trong vòng 0.4 px.</sub></p>

Mặc định, nó khớp phần chuyển động và để phần hình thức cho bạn. Bạn có thể yêu cầu nhiều hơn hoặc ít hơn:

| Bạn nói | Mức độ | Phải khớp |
|---|---|---|
| "clone this animation" | Chuyển động giống hệt (mặc định) | trigger, thứ tự, stagger, thời gian trong vòng 80 ms, họ easing, khoảng cách |
| "match it exactly", "pixel-perfect" | Hình thức giống hệt | tất cả những điều trên, cộng thêm font chữ, kích thước, màu sắc, khoảng cách và tài nguyên; độ lệch điểm ảnh trung bình ≤ 2 % |
| "clone X and add Y" | Thêm phần của bạn lên trên | phần clone ở một trong các mức trên; phần bạn thêm vào được giữ riêng |

## Ví dụ

Sáu animation từ vercel.com, nextjs.org và turborepo.com, ba thẻ từ trang chủ stripe.com, hình ảnh tích hợp từ workos.com/atlas, các thẻ tính năng từ clerk.com, bản demo dưới phần hero của liveblocks.io/comments, khối lập phương trong phần hero của resend.com và Fading Stars của React Bits Pro — mỗi cái được clone bởi một agent riêng chạy skill này, phần lớn trong 30 đến 90 phút. [Trang web](site/) cho chạy trực tiếp trong trang những cái bạn có thể di chuột hoặc kéo, và hiển thị những cái còn lại bên cạnh bản ghi của bản gốc.

| Bản clone | Dựng bằng | Đo so với bản gốc |
|---|---|---|
| **Vercel Toolbar** (vercel.com/products/previews): một thanh công cụ giữa bảy thẻ tag; di chuột lên một nút và thẻ tag của nó đổi màu trong khi các thẻ còn lại mờ đi | HTML, SVG, CSS | 417 trên 417 khung hình giống hệt; mọi thay đổi đều ở cùng một khung hình |
| **Drop to deploy** (vercel.com): tam giác hero, được chiếu sáng bởi con trỏ; kéo một file qua trang và nó biến thành một lăng kính | WebGL2, Web Workers | 785 trên 803 khung hình giống hệt từng byte, phần còn lại lệch trong vòng 1 mức |
| **Fluid ocean** (vercel.com/fluid): 262,144 chấm cuộn như sóng biển phía sau phần hero | WebGPU, Web Workers | 0 px khác biệt trong 12 giây, cả sáng và tối |
| **Inspect every run** (vercel.com/workflow): một bảng điều khiển phát lại một lần chạy của workflow | HTML, SVG | cả sáu thanh lệch 0 px; mọi bước đều đúng giờ (0 ms) |
| **Speedometer** (turborepo.com): một cây kim vọt vào vùng đỏ theo con trỏ, và một bộ đếm cuộn lên | SVG, springs | 0 px khác biệt khi di chuột, cả sáng và tối |
| **Feature cards** (nextjs.org): các khung hình được con trỏ chiếu sáng, những vệt sáng chảy vào một trang, một cây component | canvas, SVG | mọi giá trị chuyển động đều giống hệt trên từng khung hình |
| **Agentic commerce**: một khung chat trên vòng hạt 10,000 điểm | three.js, CSS | thời gian chat trong vòng 43 ms, bố cục trong vòng 0.05 px |
| **Card issuing**: một thẻ Visa nghiêng theo con trỏ | three.js, Web Workers | 0.03 % điểm ảnh khác biệt khi đứng yên; độ nghiêng trong vòng 0.4 px |
| **Stablecoins and crypto**: một quả địa cầu chấm điểm với các khoản thanh toán bay qua | three.js, Web Workers | tư thế địa cầu chính xác; các cung và nhãn nằm trong độ phân tán của chính stripe.com |
| **Connected to all your tools** (workos.com): một robot vươn tới vòm biểu tượng ứng dụng | HTML, SVG, WebGPU | 0.05 % điểm ảnh khác biệt; mỗi liên kết trong vòng 10 ms |
| **Feature cards** (clerk.com): mã xác thực, magic link, một radar, một chiếc laptop đang mở ra và hơn nữa, mỗi thẻ phát khi di chuột tới | HTML, SVG, canvas, WebGL2 | chuyển động của mỗi thẻ trong vòng 40 ms; dưới 0.6 % điểm ảnh khác biệt |
| **Comments in any app** (liveblocks.io): một cửa sổ ứng dụng chuyển qua lại giữa năm ứng dụng, panel bình luận của nó trượt tới từng ứng dụng | HTML, SVG, springs | mọi thay đổi đúng giờ (0 ms); panel trong vòng 0.7 px; 0.55 % điểm ảnh khác biệt |
| **Hero cube** (resend.com): một khối Rubik tối màu đang xoay, các lớp của nó xoay nửa vòng | three.js | mọi vòng xoay đều chính xác trong 25 giây; 0.11 % điểm ảnh khác biệt |
| **Fading stars** (pro.reactbits.dev): những ngôi sao tím bay lên thành hình quạt, dâng trào theo con trỏ | WebGL2 | 0 px khác biệt khi đứng yên; 0.014 % trong một đợt click dồn dập |

## Canvas, WebGL và 3D

Một canvas chỉ hiển thị điểm ảnh, nên reanimate ghi lại các lệnh gọi đã vẽ ra chúng. Với `--gl`, nó truy vết WebGL, WebGPU và canvas 2D. Nó móc vào đồ thị cảnh (scene graph) của three.js, Pixi, PlayCanvas, Babylon và OGL qua chính các điểm vào devtools của chúng, và chạm tới cả các worker. Kết quả thu được là mã nguồn shader, mọi uniform hằng số, các lượt render, texture và mô hình, cùng mỗi uniform hay thuộc tính đối tượng có chuyển động dưới dạng một đường cong có thể khớp và so sánh. `--clock virtual` chạy trang trên một đồng hồ được tiến từng khung hình, với `Math.random` được gieo hạt giống (seed) trong trang và các worker của nó. Nhờ vậy mọi khung hình đều chính xác bất kể GPU chậm đến đâu, và hai lần ghi của một quả địa cầu WebGL với các cung ngẫu nhiên và các chấm do worker tạo ra sẽ giống hệt nhau từng byte.

Trên stripe.com trực tiếp, cách này khôi phục được bản composite bốn lượt của thẻ issuing, các shader và hằng số của nó như `u_twistFrequencyX = 0.059`. Nó cũng ghi lại độ nghiêng của thẻ dưới dạng đường cong: −0.174 → 0.262 rad trong khoảng 33 đến 1800 ms trên đường di chuột. Sau đó `gl.ts compare` kiểm tra bản clone với bản gốc theo từng kênh; độ nghiêng khớp trong vòng 33 ms và 0.5 % phạm vi của nó. Xem [`references/webgl.md`](skills/reanimate/references/webgl.md).

## Giới hạn

- Các trang nằm sau đăng nhập, YouTube và Loom không ghi trực tiếp được; hãy đưa cho nó một bản ghi màn hình.
- Các lò xo vật lý (spring) được khớp từ độ vọt lố và thời gian ổn định của chúng, chứ không đọc từ mã nguồn.
- Các worker được gieo hạt giống và truy vết, nhưng đồng hồ riêng của chúng chạy theo thời gian thực. Canvas nằm trong iframe cần URL của chính iframe đó.
- Khi bản clone không tái tạo được bộ sinh ngẫu nhiên của bản tham chiếu, các hạt được so sánh bằng độ lệch làm mờ (mật độ, màu sắc, chuyển động) thay vì từng chấm một.
- `--gpu hardware` dùng GPU thật (macOS: Metal; Linux: Vulkan, chưa kiểm thử). Mặc định là SwiftShader, chậm hơn nhưng cho cùng một điểm ảnh trên mọi máy.
- Nó clone đúng cái bạn chỉ vào. Font chữ, hình ảnh và code từ trang khác vẫn thuộc về chủ sở hữu của chúng; hãy chắc chắn bạn được phép dùng những gì mình sao chép.

## Kho mã nguồn

skills CLI chỉ cài `skills/reanimate/`; `site/` là trang web với các ví dụ chạy trực tiếp ([`site/README.md`](site/README.vi.md)).

<details>
<summary>Trong skill có gì</summary>

| Đường dẫn | Là gì |
|---|---|
| `SKILL.md` | Quy trình Claude làm theo: xác định phạm vi, ghi lại, đặc tả, dựng, kiểm chứng, báo cáo. |
| `references/` | Công thức ghi lại theo từng loại nguồn, đọc khung hình thành bản đặc tả, các mẫu triển khai theo từng stack, WebGL, tiêu chí đạt và cách sửa. |
| `scripts/capture.ts` | Ghi lại một trang: video, khung hình, các animation đã khai báo, style đã tính, font chữ, thư viện, đường đi của phần tử theo từng khung hình. Các trigger: load, scroll, hover, leave, đường di chuột, drag, click, none. `--clock virtual` tiến một đồng hồ ảo từng khung hình (khung hình chính xác, các lần ghi giống hệt, `Math.random` được gieo hạt giống); `--gl` truy vết GPU; `--assets` lưu mô hình, texture và script. |
| `scripts/gl.ts` | Đọc một bản truy vết GPU: các canvas, đồ thị cảnh của three.js / Pixi / PlayCanvas / Babylon / OGL, shader, các lượt render, texture, các uniform có chuyển động dưới dạng kênh, và bản so sánh tham chiếu–bản sao. |
| `scripts/inpage/` | Phần chạy bên trong trang: đồng hồ ảo và bộ truy vết WebGL / WebGPU / canvas 2D. |
| `scripts/frames.ts` | Trích xuất và cắt khung hình từ video hoặc gif. |
| `scripts/compare.ts` | So sánh theo từng khung hình: căn chỉnh, sai số thời gian, độ lệch, đường cong hoạt động, ảnh diff, và độ lệch làm mờ cho hạt và nhiễu. |
| `scripts/easing.ts` | Khớp một thuộc tính được theo dõi hoặc một kênh GPU với các easing có tên, phát hiện độ vọt lố và lò xo, so sánh hai đường theo dõi. |
| `scripts/sheet.ts` | Các bảng contact sheet có nhãn và bảng so sánh tham chiếu / bản sao / diff. |

</details>

## Giấy phép

[MIT](LICENSE). Các ví dụ tái tạo một phần của vercel.com, nextjs.org, turborepo.com, stripe.com, workos.com, clerk.com, liveblocks.io, resend.com và pro.reactbits.dev như một nghiên cứu về kỹ thuật; dự án không liên kết với, cũng không được chứng thực bởi Vercel, Stripe, WorkOS, Clerk, Liveblocks, Resend hay React Bits. Mọi thương hiệu thuộc về chủ sở hữu của chúng.
