export const seed = {
  materials: [
    {id:'m1',code:'G00001',name:'Gỗ sồi trắng',supplier:'Gỗ Minh Long',unit:'m³',spec:'Sấy 8–12%, dày 26 mm'},
    {id:'m2',code:'V00001',name:'Ván MDF chống ẩm',supplier:'An Cường',unit:'tấm',spec:'1220×2440×17 mm'},
    {id:'m3',code:'K00001',name:'Keo sữa D3',supplier:'Hóa chất Việt',unit:'kg',spec:'Can 20 kg'},
    {id:'m4',code:'S00001',name:'Sơn PU mờ',supplier:'Sơn Đại Phát',unit:'kg',spec:'Độ bóng 30%'},
    {id:'m5',code:'B00001',name:'Bản lề giảm chấn',supplier:'Häfele',unit:'cái',spec:'Bật 110°'}],
  lots: [
    {id:'l1',materialId:'m1',lot:'SOI-260701',received:'2026-07-01',expiry:'',qty:4.8,remaining:3.45,price:28500000},
    {id:'l2',materialId:'m2',lot:'MDF-260715',received:'2026-07-15',expiry:'',qty:80,remaining:52,price:525000},
    {id:'l3',materialId:'m3',lot:'KSD3-260610',received:'2026-06-10',expiry:'2027-06-10',qty:100,remaining:36,price:68500},
    {id:'l4',materialId:'m4',lot:'PU-260701',received:'2026-07-01',expiry:'2027-01-01',qty:60,remaining:22,price:142000},
    {id:'l5',materialId:'m5',lot:'BL-260720',received:'2026-07-20',expiry:'',qty:300,remaining:184,price:47500}],
  issues:[{id:'PX-202608-001',date:'2026-08-14',customer:'Nội thất An Gia',order:'DH-2608-12',product:'Tủ bếp sồi chữ L',status:'posted',total:5231500,lines:[{materialId:'m1',qty:0.12,price:28500000,lotId:'l1'},{materialId:'m5',qty:18,price:47500,lotId:'l5'}]},{id:'PX-202608-002',date:'2026-08-18',customer:'Chị Mai',order:'DH-2608-19',product:'Bàn ăn 6 ghế',status:'draft',total:0,lines:[]}]
}
