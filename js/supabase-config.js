/**
 * ============================================================
 *  KẾT NỐI SUPABASE HEADLESS CMS — Bà Đen Farm Landing Page
 * ============================================================
 */

(function () {
  // Config mặc định dự án Supabase chính thức của Bà Đen Farm
  var DEFAULT_URL = window.SUPABASE_URL || localStorage.getItem('BDF_SUPABASE_URL') || 'https://ajugxtxxlllwalgzrfef.supabase.co';
  var DEFAULT_KEY = window.SUPABASE_ANON_KEY || localStorage.getItem('BDF_SUPABASE_ANON_KEY') || 'sb_publishable_p-RaEm9cpLCznKXSkD7Qhw_AEpvXIYM';

  window.BDF_CMS = {
    url: DEFAULT_URL,
    key: DEFAULT_KEY,
    client: null,

    // Khởi tạo Supabase Client
    init: function (url, key) {
      if (url) this.url = url;
      if (key) this.key = key;

      if (!this.url || !this.key) {
        console.warn('[Supabase CMS] Chưa có SUPABASE_URL hoặc SUPABASE_ANON_KEY. Đang dùng dữ liệu tĩnh mặc định.');
        return false;
      }

      if (window.supabase && typeof window.supabase.createClient === 'function') {
        try {
          this.client = window.supabase.createClient(this.url, this.key);
          console.log('[Supabase CMS] Đã kết nối Supabase thành công!');
          return true;
        } catch (err) {
          console.error('[Supabase CMS] Lỗi khởi tạo client:', err);
          return false;
        }
      } else {
        console.error('[Supabase CMS] Thư viện Supabase JS chưa được nạp!');
        return false;
      }
    },

    // Tải toàn bộ nội dung từ Supabase và chèn vào Web
    loadContent: async function () {
      if (!this.client && !this.init()) return;

      try {
        var res = await this.client.from('site_content').select('*');
        if (res.error) {
          console.error('[Supabase CMS] Lỗi tải dữ liệu:', res.error);
          return;
        }

        var data = res.data || [];
        console.log('[Supabase CMS] Đã nạp ' + data.length + ' mục dữ liệu động từ CMS.');

        data.forEach(function (item) {
          if (item.type === 'image') {
            // Cập nhật các thẻ img có data-img-key hoặc data-cms-key hoặc data-site-image
            var selector = '[data-img-key="' + item.id + '"], [data-cms-key="' + item.id + '"], [data-site-image="' + item.id + '"]';
            var imgs = document.querySelectorAll(selector);
            imgs.forEach(function (img) {
              if (item.content) img.src = item.content;
              if (item.alt_text) img.alt = item.alt_text;
            });

            // Cập nhật vào window.SITE_IMAGES để duy trì tương thích cũ
            if (window.SITE_IMAGES && window.SITE_IMAGES[item.id]) {
              window.SITE_IMAGES[item.id].src = item.content;
              if (item.alt_text) window.SITE_IMAGES[item.id].alt = item.alt_text;
            }
          } else if (item.type === 'text') {
            var textElems = document.querySelectorAll('[data-text-key="' + item.id + '"]');
            textElems.forEach(function (elem) {
              if (item.id === 'company-phone') {
                if (elem.getAttribute('data-phone-prefix')) {
                  elem.textContent = elem.getAttribute('data-phone-prefix') + item.content;
                } else if (elem.textContent.trim().startsWith('📞')) {
                  elem.textContent = '📞 Hotline: ' + item.content;
                } else if (elem.textContent.trim().startsWith('Hotline:')) {
                  elem.textContent = 'Hotline: ' + item.content;
                } else {
                  elem.textContent = item.content;
                }

                if (elem.tagName === 'A' && elem.href) {
                  var cleanNum = item.content.split(/[-–]/)[0].replace(/[^0-9+]/g, '');
                  if (elem.href.includes('zalo.me')) {
                    elem.href = 'https://zalo.me/' + cleanNum;
                  } else {
                    elem.href = 'tel:' + cleanNum;
                  }
                }
              } else if (item.id === 'company-email') {
                elem.textContent = item.content;
                if (elem.tagName === 'A' && elem.href) {
                  elem.href = 'mailto:' + item.content;
                }
              } else {
                elem.textContent = item.content;
              }
            });

            // Cập nhật các thẻ chỉ đổi link href (như icon Zalo, 📞, @) mà giữ nguyên icon/text gốc
            var hrefElems = document.querySelectorAll('[data-href-key="' + item.id + '"]');
            hrefElems.forEach(function (elem) {
              if (elem.tagName === 'A' && elem.href) {
                if (item.id === 'company-phone') {
                  var cleanNum = item.content.split(/[-–]/)[0].replace(/[^0-9+]/g, '');
                  if (elem.href.includes('zalo.me') || elem.getAttribute('aria-label') === 'Zalo' || elem.getAttribute('aria-label') === 'Chat Zalo') {
                    elem.href = 'https://zalo.me/' + cleanNum;
                  } else {
                    elem.href = 'tel:' + cleanNum;
                  }
                } else if (item.id === 'company-email') {
                  elem.href = 'mailto:' + item.content;
                }
              }
            });
          }
        });
      } catch (e) {
        console.error('[Supabase CMS] Ngoại lệ khi tải nội dung:', e);
      }
    }
  };

  // Tự động khởi chạy khi trang nạp xong
  document.addEventListener('DOMContentLoaded', function () {
    if (window.BDF_CMS.init()) {
      window.BDF_CMS.loadContent();
    }
  });
})();
