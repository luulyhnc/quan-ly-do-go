# Quản lý nguyên phụ liệu Đồ Gỗ

Ứng dụng React/Vite tông nâu gỗ–kem để quản lý danh mục NPL, giá theo ngày/lô, nhập kho, phiếu xuất gắn khách hàng–đơn hàng–sản phẩm và tra cứu tồn. Phiếu nháp không trừ tồn; ghi nhận/hủy dùng RPC transaction, khóa dòng lô và hoàn tồn đúng nguồn.

## Chạy local

```bash
npm install
npm run dev
```

Không có `.env.local`, chọn **Vào bản demo local**. Demo lưu trong localStorage. Muốn dùng Supabase, sao chép `.env.example` thành `.env.local` và chỉ điền **anon/publishable key**; tuyệt đối không đưa service-role key vào frontend.

## Supabase

1. Chạy `supabase/schema.sql` trong SQL Editor.
2. Tạo user trong Authentication, rồi thêm profile tương ứng với role `owner`, `admin` hoặc `viewer`.
3. Tùy chọn chạy `supabase/demo.sql`.
4. Production nên gọi `post_issue` và `void_issue`; hai hàm thực hiện nguyên tử, FIFO mặc định hoặc nhận map lô thủ công.

`viewer` chỉ đọc. `owner/admin` được ghi. RLS bật trên toàn bộ bảng nghiệp vụ. Frontend hiện có demo local đầy đủ; lớp kết nối Auth đã sẵn sàng, khi triển khai Supabase thật cần nối các form với bảng/RPC theo schema.

## GitHub Pages

Đặt repository là `quan-ly-do-go`, thêm Actions secrets `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`, bật **Settings → Pages → GitHub Actions**, rồi push nhánh `main`. Nếu tên repo khác, sửa `VITE_BASE_PATH` trong workflow.

## Kiểm tra

```bash
npm run lint
npm run build
```
