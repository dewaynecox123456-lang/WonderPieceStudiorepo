
const KEY_ITEMS='wb_items', KEY_COUNTS='wb_counts', KEY_PAYPAL='wb_paypal_url', KEY_CASHAPP='wb_cashapp_url';
const KEY_BANNER_ENABLED='wb_banner_enabled', KEY_BANNER_MSG='wb_banner_msg';
const DEFAULT_ITEMS=[
 {id:'pz-laundry',kind:'puzzle',title:'Laundry Night 500pc',price:39.00,img:'/assets/img/puzzles/Laundry_Night.webp',active:true},
 {id:'pz-truck',kind:'puzzle',title:'Teal Truck Fair 500pc',price:39.00,img:'/assets/img/puzzles/Teal_Truck_Fair.webp',active:true},
 {id:'pz-porch',kind:'puzzle',title:'Porch Swing Moon 500pc',price:39.00,img:'/assets/img/puzzles/Porch_Swing_Moon.webp',active:true},
 {id:'art-laundry',kind:'art',title:'Laundry Night (16×20 in)',price:120.00,img:'/assets/img/puzzles/Laundry_Night.webp',active:true},
 {id:'art-truck',kind:'art',title:'Teal Truck Fair (16×20 in)',price:120.00,img:'/assets/img/puzzles/Teal_Truck_Fair.webp',active:true},
 {id:'art-porch',kind:'art',title:'Porch Swing Moon (16×20 in)',price:140.00,img:'/assets/img/puzzles/Porch_Swing_Moon.webp',active:true}
];
function loadItems(){ try{return JSON.parse(localStorage.getItem(KEY_ITEMS))||DEFAULT_ITEMS;}catch(e){return DEFAULT_ITEMS;} }
function bumpCount(id){ const c=JSON.parse(localStorage.getItem(KEY_COUNTS)||'{}'); c[id]=(c[id]||0)+1; localStorage.setItem(KEY_COUNTS',JSON.stringify(c)); }
function renderBanner(){ const bar=document.querySelector('.banner'); if(!bar)return; const on=(localStorage.getItem(KEY_BANNER_ENABLED)==='true'); const msg=localStorage.getItem(KEY_BANNER_MSG)||''; if(!on||!msg.trim()){bar.style.display='none';return;} bar.innerHTML=`<span>${msg}</span>`; bar.style.display='block';}
function buyItem(id,method){ const url=(method==='paypal')?(localStorage.getItem(KEY_PAYPAL)||'https://paypal.me/Dewaynecox123456'):(localStorage.getItem(KEY_CASHAPP)||'https://cash.app/$kittyslayer227'); window.open(url,'_blank','noopener'); }
document.addEventListener('DOMContentLoaded',()=>{ const f=document.querySelector('footer'); if(f){ f.innerHTML='© '+new Date().getFullYear()+' Wonder Piece Studio. All Rights Reserved.'; } renderBanner(); });
