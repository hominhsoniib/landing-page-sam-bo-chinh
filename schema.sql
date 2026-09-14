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
('company-phone', 'text', '0919 257 757 - 0886554242', 'Số điện thoại hotline liên hệ', 'lien-he'),
('company-address', 'text', 'Số 02 - Đường Lộ 12A - Khu phố Tân Trung, Phường Bình Minh, Tỉnh Tây Ninh', 'Địa chỉ trụ sở công ty', 'lien-he'),
('company-email', 'text', 'contact@badenfarm.com', 'Email liên hệ công ty', 'lien-he')

ON CONFLICT (id) DO UPDATE SET 
    content = EXCLUDED.content,
    alt_text = EXCLUDED.alt_text,
    updated_at = NOW();

-- ============================================================
-- 5. BẢNG PHÂN QUYỀN THÀNH VIÊN & ĐỐI TÁC (profiles)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    phone TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'nong_ho', -- 'nong_ho', 'dai_ly', 'can_bo', 'admin'
    status TEXT NOT NULL DEFAULT 'active', -- 'pending', 'active', 'suspended'
    region TEXT DEFAULT 'Tây Ninh',
    points INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read profiles" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- ============================================================
-- 6. BẢNG HỌC VIỆN NÔNG NGHIỆP SÂM BỐ CHÍNH (courses & user_progress)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.courses (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    thumbnail TEXT,
    category TEXT DEFAULT 'vietgap',
    level TEXT DEFAULT 'Cơ bản',
    duration TEXT DEFAULT '2 giờ',
    lessons_count INT DEFAULT 5,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read courses" ON public.courses FOR SELECT USING (true);

CREATE TABLE IF NOT EXISTS public.user_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    course_id TEXT REFERENCES public.courses(id) ON DELETE CASCADE,
    progress INT DEFAULT 0,
    completed BOOLEAN DEFAULT FALSE,
    certificate_issued BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.user_progress ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users read own progress" ON public.user_progress FOR SELECT USING (auth.uid() = user_id);

-- DỮ LIỆU MẪU HỌC VIỆN
INSERT INTO public.courses (id, title, description, thumbnail, category, level, duration, lessons_count) VALUES
('course-vietgap-01', 'Kỹ thuật Canh tác Sâm Bố Chính chuẩn VietGAP', 'Hướng dẫn làm đất, bón phân hữu cơ, quản lý nguồn nước và phòng trừ sâu bệnh sinh học.', 'images/ghep-vuon-sam.png', 'vietgap', 'Cơ bản', '3 giờ', 6),
('course-thuhoach-02', 'Quy trình Thu hoạch & Sơ chế Củ Sâm Tươi', 'Phương pháp đào sâm tránh gãy rễ, phân loại sâm củ và kỹ thuật rửa siêu âm giữ dưỡng chất.', 'images/cu sam.jpg', 'thu_hoach', 'Nâng cao', '2.5 giờ', 4),
('course-banhang-03', 'Đào tạo Marketing & Phân phối Sâm Bố Chính', 'Kỹ năng tư vấn khách hàng, xây dựng thương hiệu cá nhân và quản lý điểm bán OCOP.', 'images/sp tieu bieu.png', 'ban_hang', 'Đại lý', '4 giờ', 8)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 7. BẢNG ĐƠN HÀNG ĐẠI LÝ & ĐIỂM THƯỞNG (agent_orders)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.agent_orders (
    id TEXT PRIMARY KEY,
    agent_name TEXT NOT NULL,
    phone TEXT NOT NULL,
    items JSONB NOT NULL,
    total_amount NUMERIC NOT NULL,
    discount_rate INT DEFAULT 15,
    status TEXT DEFAULT 'pending', -- 'pending', 'confirmed', 'shipping', 'completed', 'cancelled'
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.agent_orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read orders" ON public.agent_orders FOR SELECT USING (true);
CREATE POLICY "Public insert orders" ON public.agent_orders FOR INSERT WITH CHECK (true);

-- DỮ LIỆU MẪU ĐƠN HÀNG
INSERT INTO public.agent_orders (id, agent_name, phone, items, total_amount, discount_rate, status) VALUES
('ORD-2026-001', 'Đại Lý Tây Ninh Sâm Việt', '0988123456', '[{"name":"Trà Túi Lọc Sâm","qty":50,"price":150000},{"name":"Rượu Sâm Tiến Vua","qty":20,"price":450000}]', 16500000, 20, 'completed'),
('ORD-2026-002', 'Điểm Bán OCOP TP.HCM', '0912987654', '[{"name":"Cao Sâm Bố Chính","qty":30,"price":650000}]', 19500000, 15, 'confirmed')
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 8. BẢNG NHẬT KÝ VÙNG TRỒNG VIETGAP (farm_logs)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.farm_logs (
    id TEXT PRIMARY KEY,
    farmer_name TEXT NOT NULL,
    batch_code TEXT NOT NULL,
    location TEXT DEFAULT 'Vùng trồng Núi Bà Đen - Lô A1',
    stage TEXT NOT NULL,
    activity TEXT NOT NULL,
    log_date DATE DEFAULT CURRENT_DATE
);

ALTER TABLE public.farm_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read farm logs" ON public.farm_logs FOR SELECT USING (true);

-- DỮ LIỆU MẪU NHẬT KÝ VÙNG TRỒNG
INSERT INTO public.farm_logs (id, farmer_name, batch_code, location, stage, activity, log_date) VALUES
('LOG-2026-101', 'Hộ Nông Dân Nguyễn Văn A', 'LOT-BDF-2026-08', 'Vùng 1 - Chân Núi Bà Đen', 'Xuống Giống', 'Bón lót phân hữu cơ sinh học, làm luống cao 30cm, phủ bạt diệt cỏ.', '2026-08-15'),
('LOG-2026-102', 'Hộ Nông Dân Trần Thị B', 'LOT-BDF-2026-08', 'Vùng 2 - Tân Trung', 'Chăm Sóc', 'Phun chế phẩm sinh học Trichoderma phòng nấm rễ, kiểm tra độ ẩm đất.', '2026-09-02'),
('LOG-2026-103', 'Kỹ Thuật Viên Lê Văn C', 'LOT-BDF-2026-06', 'Vùng 1 - Chân Núi Bà Đen', 'Thu Hoạch', 'Kiểm tra hàm lượng Saponin đạt 4.8%, tiến hành thu hoạch đợt 1.', '2026-09-10')
ON CONFLICT (id) DO NOTHING;

