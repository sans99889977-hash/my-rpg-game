RPG Adventure — ระบบบัญชีและแชทโลก

ไฟล์ที่ให้
- index_online_login_chat.html : เกมพร้อมหน้าเข้าสู่ระบบด้วยอีเมล + รหัสผ่าน และแชทโลก
- supabase_login_worldchat.sql : ตาราง/นโยบาย RLS สำหรับแชทโลกและฟังก์ชันรายชื่อผู้เล่นของแอดมิน

ขั้นตอนติดตั้ง
1) เปิด Supabase Dashboard > SQL Editor
2) รัน supabase_setup.sql เดิมก่อน (ถ้ายังไม่เคยรัน)
3) รัน supabase_login_worldchat.sql
4) เปิดไฟล์ index_online_login_chat.html แล้วค้นหา SUPABASE_URL และ SUPABASE_ANON_KEY
5) ใส่ Project URL และ anon/publishable key จาก Supabase > Project Settings > API
   ห้ามใส่ service_role key ในไฟล์ HTML เด็ดขาด
6) ใน Supabase > Authentication > Providers > Email ให้เปิด Email/Password
   หากต้องการให้สมัครแล้วเข้าเกมได้ทันที ให้ปิด Confirm email (สำหรับช่วงทดสอบ)
7) อัปโหลดไฟล์นี้เป็น index.html ใน GitHub repository แล้วรอ Cloudflare Pages deploy

การใช้งาน
- บัญชีเดิม: กรอกอีเมลและรหัสผ่านเดิมเพื่อโหลดเซฟจาก Supabase
- บัญชีใหม่: เลือกสมัคร กรอกอีเมล ชื่อในเกม และรหัสผ่านอย่างน้อย 8 ตัว
- ชื่อในเกมซ้ำจะสมัครไม่ได้ เพื่อป้องกันการแอบอ้างชื่อ
- ปุ่ม 🌐 บนแถบด้านบนเปิดแชทโลก
- ปุ่มบัญชีของฉันในหน้าต่างแชทใช้ดูข้อมูลบัญชี/ออกจากระบบ

แอดมิน Mask
- สร้างบัญชี Mask ก่อน จากนั้นรัน SQL บรรทัดตัวอย่างท้ายไฟล์ โดยเอา comment ออก
  update public.profiles set is_admin = true where username_key = 'mask';
- ฟังก์ชัน admin_player_directory() ให้รายชื่อบัญชีแก่แอดมินเท่านั้น
- ไม่มีระบบใดควรแสดงรหัสผ่านจริงของผู้เล่น แม้แต่แอดมิน ให้ใช้การรีเซ็ตรหัสผ่านแทน

หมายเหตุสำคัญ
- ไฟล์นี้เป็นรุ่นเชื่อมระบบบัญชี/แชทสำหรับทดสอบ ต้องใส่ Supabase URL และ anon key ของโปรเจกต์จริงก่อน
- ต้องรัน SQL ทั้งสองไฟล์ตามลำดับ
- ระบบเซฟใช้ตาราง game_saves จาก supabase_setup.sql
- ระบบออนไลน์/แชทต้องเปิดผ่าน HTTPS และอนุญาต Realtime ใน Supabase
- ระบบป้องกันโกง/สิทธิ์แอดมินขั้น production ยังต้องเพิ่ม Edge Functions และการตรวจสอบฝั่งเซิร์ฟเวอร์
