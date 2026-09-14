-- ============================================================
-- SUPABASE DATABASE SETUP SCRIPT FOR BÀ ĐEN FARM LANDING PAGE
-- ============================================================
-- Hướng dẫn: Copy toàn bộ đoạn script này, mở Supabase Dashboard -> SQL Editor
-- dán vào và nhấn button "RUN" để tự động tạo Bảng, Phân quyền & Dữ liệu mẫu.

-- 1. TẠO BẢNG CHỨA NỘI DUNG (site_content)
CREATE TABLE IF NOT EXISTS public.site_content (
    id TEXT PRIMARY KEY,               -- Mã định danh key (ví dụ: 'hero-visual', 'slogan-hero')
    type TEXT NOT NULL DEFAULT 'image',-- Loại nội dung: 'image', 'text', 'video', 'link'
    content TEXT NOT NULL,             -- Đường dẫn ảnh (src) hoặc nội dung chữ
    alt_text TEXT DEFAULT '',           -- Mô tả alt cho hình ảnh (tối ưu SEO)
    category TEXT DEFAULT 'chung',     -- Phân loại: 'trang-chu', 'gioi-thieu', 'san-pham', 'chung-nhan'
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    updated_by TEXT DEFAULT 'system'
);

-- Bật tính năng Row Level Security (RLS) bảo mật dữ liệu
ALTER TABLE public.site_content ENABLE ROW LEVEL SECURITY;

-- 2. THIẾT LẬP PHÂN QUYỀN (RLS POLICIES)
-- A. Khách truy cập web được phép đọc dữ liệu (Public Read)
DROP POLICY IF EXISTS "Cho phap public xem noi dung" ON public.site_content;
CREATE POLICY "Cho phap public xem noi dung"
ON public.site_content FOR SELECT
USING (true);

-- B. Chỉ người dùng đã đăng nhập (Admin/Nhân viên) mới được Thêm/Sửa/Xóa (Authenticated Write)
DROP POLICY IF EXISTS "Cho phap Admin chinh sua noi dung" ON public.site_content;
CREATE POLICY "Cho phap Admin chinh sua noi dung"
ON public.site_content FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- 3. TẠO STORAGE BUCKET CHO HÌNH ẢNH (site-assets)
INSERT INTO storage.buckets (id, name, public)
VALUES ('site-assets', 'site-assets', true)
ON CONFLICT (id) DO NOTHING;

-- Phân quyền Storage: Public có thể xem ảnh, Admin đã đăng nhập có thể upload ảnh
DROP POLICY IF EXISTS "Public view assets" ON storage.objects;
CREATE POLICY "Public view assets" ON storage.objects
FOR SELECT USING (bucket_id = 'site-assets');

DROP POLICY IF EXISTS "Admin upload assets" ON storage.objects;
CREATE POLICY "Admin upload assets" ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'site-assets');

DROP POLICY IF EXISTS "Admin update assets" ON storage.objects;
CREATE POLICY "Admin update assets" ON storage.objects
FOR UPDATE TO authenticated
USING (bucket_id = 'site-assets');

-- 4. KHỞI TẠO DỮ LIỆU MẪU (SEED DATA)
INSERT INTO public.site_content (id, type, content, alt_text, category) VALUES
-- HÌNH ẢNH TRANG CHỦ & GIỚI THIỆU
('hero-visual', 'image', 'images/ghep-vuon-sam.png', 'Vùng trồng Sâm Bố Chính công nghệ cao Bà Đen Farm Tây Ninh', 'trang-chu'),
('gioi-thieu-visual', 'image', 'images/VUON SAM BC.jpg', 'Vườn Sâm Bố Chính phủ xanh ngát tại Bà Đen Farm', 'gioi-thieu'),
('gioi-thieu-infographic', 'image', 'images/gioi-thieu-infographic.jpg', 'Infographic Giới thiệu Công ty CP Bà Đen Farm', 'gioi-thieu'),

-- GIẤY CHỨNG NHẬN
('giay-chung-nhan-haccp', 'image', 'images/giay-chung-nhan-haccp.jpg', 'Giấy chứng nhận An toàn Thực phẩm HACCP', 'chung-nhan'),
('giay-cn-atvstp', 'image', 'images/giay-cn-atvstp.png', 'Giấy chứng nhận Cơ sở đủ điều kiện ATVTSP', 'chung-nhan'),
('giay-chung-nhan-sp-tieu-bieu', 'image', 'images/giay-chung-nhan-sp-tieu-bieu.jpg', 'Giấy chứng nhận Sản phẩm CN Nông thôn Tiêu biểu cấp Khu vực', 'chung-nhan'),
('giay-cn-sp-tieu-bieu-1', 'image', 'images/giay-cn-sp-tieu-bieu-1.jpg', 'Giấy chứng nhận Sản phẩm Nông thôn Tiêu biểu', 'chung-nhan'),
('giay-cn-ocop-1', 'image', 'images/giay-cn-ocop-1.png', 'OCOP 3 Sao — Trà túi lọc Sâm Bố Chính', 'chung-nhan'),
('giay-cn-ocop-2', 'image', 'images/giay-cn-ocop-2.png', 'OCOP 3 Sao — Rượu & Dược Tửu Sâm Bố Chính', 'chung-nhan'),
('giay-cn-ocop-3', 'image', 'images/giay-cn-ocop-3.png', 'OCOP 3 Sao — Củ Sâm Bố Chính Tươi', 'chung-nhan'),
('giay-cn-ocop-4', 'image', 'images/giay-cn-ocop-4.png', 'OCOP 3 Sao — Bột Sâm Nguyên Chất BDF', 'chung-nhan'),
('giay-cn-ocop-5', 'image', 'images/giay-cn-ocop-5.png', 'OCOP 3 Sao — Cao Sâm Bố Chính', 'chung-nhan'),
('giay-cn-ocop-6', 'image', 'images/giay-cn-ocop-6.png', 'OCOP 3 Sao — Trà Hoa Sâm Tứ Vị', 'chung-nhan'),
('giay-cn-ocop-7', 'image', 'images/giay-cn-ocop-7.png', 'OCOP 3 Sao — Set Lẩu Sâm Khô Thanh Ngọt', 'chung-nhan'),

-- SẢN PHẨM TIÊU BIỂU
('sp-tra-tui-loc', 'image', 'images/TRÀ SÂM.jpg', 'Trà túi lọc Sâm Bố Chính - Sản phẩm OCOP 3 sao', 'san-pham'),
('sp-ruou-sam-tien-vua', 'image', 'images/RS TV.jpg', 'Rượu Sâm Tiến Vua Bà Đen Farm', 'san-pham'),
('sp-duoc-tuu-ba-den', 'image', 'images/ĐVT.jpg', 'Dược Tửu Bà Đen Farm ngâm ủ truyền thống', 'san-pham'),
('sp-bot-sam', 'image', 'images/BỘT SÂM.jpg', 'Bột Sâm Bố Chính nguyên chất 100%', 'san-pham'),
('sp-cao-sam', 'image', 'images/CAO SÂM.jpg', 'Cao Sâm Bố Chính đậm đặc dinh dưỡng', 'san-pham'),
('sp-tra-hoa-sam', 'image', 'images/tra-hoa-sam.jpg', 'Trà Hoa Sâm Bố Chính', 'san-pham'),
('sp-sam-say-lat', 'image', 'images/sam-say-lat.png', 'Sâm Bố Chính Sấy Lát 100% Củ Sâm Tươi', 'san-pham'),
('sp-set-lau-sam', 'image', 'images/set-lau-sam.png', 'Set Lẩu Sâm Khô Thanh Ngọt Tự Nhiên', 'san-pham'),

-- NỘI DUNG VĂN BẢN (TEXT & SLOGAN)
('sp-duoc-tuu-title', 'text', 'Đế Vương Tửu Bà Đen Farm', 'Tên sản phẩm Rượu/Dược Tửu', 'san-pham'),
('site-slogan', 'text', 'Sâm thật · Trồng thật · Chất lượng thật', 'Slogan chính đầu trang', 'trang-chu'),
('company-phone', 'text', '0919 257 757', 'Số điện thoại hotline liên hệ', 'lien-he'),
('company-address', 'text', 'Số 02 - Đường Lộ 12A - Khu phố Tân Trung, Phường Bình Minh, Tỉnh Tây Ninh', 'Địa chỉ trụ sở công ty', 'lien-he'),
('company-email', 'text', 'contact@badenfarm.com', 'Email liên hệ công ty', 'lien-he')

ON CONFLICT (id) DO UPDATE SET 
    content = EXCLUDED.content,
    alt_text = EXCLUDED.alt_text,
    updated_at = NOW();
