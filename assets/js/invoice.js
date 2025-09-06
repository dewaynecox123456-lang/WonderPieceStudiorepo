
const KEY_ITEMS='wb_items', KEY_PAYPAL='wb_paypal_url', KEY_CASH='wb_cashapp_url', KEY_QR_PP='wb_qr_paypal', KEY_QR_CA='wb_qr_cash', KEY_SELLER='wb_seller_name';
function loadItems(){ try{return JSON.parse(localStorage.getItem(KEY_ITEMS))||[];}catch(e){return [];} }
function q(id){ return document.getElementById(id); }
function round2(n){ return Math.round(n*100)/100; }
function todayId(){ const d=new Date(); return `${d.getFullYear()}${String(d.getMonth()+1).padStart(2,'0')}${String(d.getDate()).padStart(2,'0')}-${String(d.getHours()).padStart(2,'0')}${String(d.getMinutes()).padStart(2,'0')}`; }
function buildInvoice(){
  const catalog=loadItems();
  const selected=JSON.parse(localStorage.getItem('wb_invoice_selection')||'{}');
  const buyer=JSON.parse(localStorage.getItem('wb_invoice_buyer')||'{}');
  const ship=JSON.parse(localStorage.getItem('wb_invoice_ship')||'{"shipping":0,"tax":0}');
  const seller=localStorage.getItem(KEY_SELLER)||'Wonder Piece Studio';
  q('seller').textContent=seller; q('invno').textContent=todayId(); q('invdate').textContent=new Date().toLocaleDateString();
  q('b_name').textContent=buyer.name||''; q('b_email').textContent=buyer.email||''; q('b_phone').textContent=buyer.phone||''; q('b_addr').textContent=buyer.addr||'';
  const tbody=q('tbody'); tbody.innerHTML=''; let subtotal=0;
  Object.entries(selected).forEach(([id,qty])=>{ const it=catalog.find(x=>x.id===id); if(!it)return; const unit=round2(it.price||0); const amount=round2(unit*(qty||1)); subtotal+=amount; const tr=document.createElement('tr'); tr.innerHTML=`<td>${it.title}</td><td>${qty||1}</td><td>$${unit.toFixed(2)}</td><td>$${amount.toFixed(2)}</td>`; tbody.appendChild(tr); });
  const shipping=parseFloat(ship.shipping||0)||0, tax=parseFloat(ship.tax||0)||0, total=round2(subtotal+shipping+tax);
  q('subtotal').textContent=`$${subtotal.toFixed(2)}`; q('shipping').textContent=`$${shipping.toFixed(2)}`; q('tax').textContent=`$${tax.toFixed(2)}`; q('total').textContent=`$${total.toFixed(2)}`;
  q('pp_link').href=(localStorage.getItem(KEY_PAYPAL)||'#'); q('pp_qr').src=(localStorage.getItem(KEY_QR_PP)||''); q('ca_link').href=(localStorage.getItem(KEY_CASH)||'#'); q('ca_qr').src=(localStorage.getItem(KEY_QR_CA)||'');
}
function doPrint(){ window.print(); }
