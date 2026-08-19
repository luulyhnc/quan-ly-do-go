insert into public.materials(name,supplier,unit,specification) values
('Gỗ sồi trắng','Gỗ Minh Long','m³','Sấy 8–12%, dày 26 mm'),('Ván MDF chống ẩm','An Cường','tấm','1220×2440×17 mm'),('Keo sữa D3','Hóa chất Việt','kg','Can 20 kg'),('Sơn PU mờ','Sơn Đại Phát','kg','Độ bóng 30%'),('Bản lề giảm chấn','Häfele','cái','Bật 110°') on conflict do nothing;
