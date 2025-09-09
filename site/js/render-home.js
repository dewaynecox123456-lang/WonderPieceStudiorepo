(async function () {
  const GRID_ID = "featured-grid";

  // Resolve JSON relative to site root
  const jsonUrl = "/assets/puzzles/puzzles.json";

  // Ensure there's a grid container; create if missing
  function ensureGrid() {
    let grid = document.getElementById(GRID_ID);
    if (!grid) {
      grid = document.createElement("section");
      grid.id = GRID_ID;
      grid.style.display = "grid";
      grid.style.gridTemplateColumns = "repeat(auto-fit, minmax(260px, 1fr))";
      grid.style.gap = "16px";
      const host = document.querySelector("main") || document.body;
      host.appendChild(grid);
    }
    return grid;
  }

  function cardTemplate(item) {
    const el = document.createElement("article");
    el.style.background = "rgba(255,255,255,0.06)";
    el.style.border = "1px solid rgba(255,255,255,0.12)";
    el.style.borderRadius = "14px";
    el.style.padding = "12px";
    el.style.boxShadow = "0 6px 24px rgba(0,0,0,0.25)";

    // image
    const img = document.createElement("img");
    img.src = item.img;
    img.alt = item.title || "Puzzle image";
    img.style.width = "100%";
    img.style.height = "200px";
    img.style.objectFit = "cover";
    img.style.borderRadius = "10px";
    el.appendChild(img);

    // title
    const h3 = document.createElement("h3");
    h3.textContent = item.title || "Untitled";
    h3.style.margin = "10px 0 4px";
    h3.style.fontWeight = "600";
    el.appendChild(h3);

    // meta
    const meta = document.createElement("div");
    meta.style.opacity = "0.85";
    meta.style.fontSize = "0.9rem";
    meta.textContent = item.details || (item.size ? `${item.size}` : "");
    el.appendChild(meta);

    // buy button (goes to payments flow with price + optional tip param)
    const btn = document.createElement("a");
    btn.textContent = "Buy";
    btn.href = "/payments/checkout.html?item=" + encodeURIComponent(item.title || "Puzzle")
              + (item.price ? `&price=${encodeURIComponent(item.price)}` : "");
    btn.style.display = "inline-block";
    btn.style.marginTop = "10px";
    btn.style.padding = "8px 14px";
    btn.style.borderRadius = "10px";
    btn.style.textDecoration = "none";
    btn.style.background = "#21a1f1";
    btn.style.color = "white";
    btn.style.fontWeight = "600";
    el.appendChild(btn);

    return el;
  }

  try {
    const grid = ensureGrid();
    const res = await fetch(jsonUrl, { cache: "no-store" });
    if (!res.ok) throw new Error("Failed to load puzzles.json");
    const data = await res.json();

    const items = Array.isArray(data?.items) ? data.items : [];
    if (items.length === 0) {
      const msg = document.createElement("div");
      msg.textContent = "No puzzles yet. Add items in assets/puzzles/puzzles.json.";
      grid.appendChild(msg);
      return;
    }

    items.forEach(item => grid.appendChild(cardTemplate(item)));
  } catch (e) {
    console.error(e);
  }
})();