<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.InventoryManager, model.InventoryItem, java.util.List" %>
<%
    String role = (String) session.getAttribute("userRole");
    if (!"admin".equals(role)) { response.sendRedirect("login.jsp"); return; }

    InventoryManager invManager = new InventoryManager();
    List<InventoryItem> items = invManager.getAllItems();

    double totalValue = 0; int outOfStockCount = 0; int lowStockCount = 0;
    for (InventoryItem item : items) {
        totalValue += (item.getPrice() * item.getQuantity());
        if (item.getQuantity() == 0) outOfStockCount++;
        else if (item.getQuantity() <= 5) lowStockCount++;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inventory Management - SwiftDrive</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;700&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Plus Jakarta Sans', sans-serif; }
        .mono { font-family: 'JetBrains Mono', monospace; }
        .stat-card { transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1); }
        .stat-card:hover { transform: translateY(-4px); }
        .inv-card { transition: all 0.5s cubic-bezier(0.4, 0, 0.2, 1); }
        .inv-card:hover { transform: translateY(-8px); }
        .stock-bar { height: 10px; border-radius: 100px; background: rgba(0,0,0,0.05); overflow: hidden; }
        .dark .stock-bar { background: rgba(255,255,255,0.05); }
        .stock-fill { height: 100%; border-radius: 100px; transition: width 0.8s cubic-bezier(0.34, 1.56, 0.64, 1); }
        .oos-ribbon {
            position: absolute; top: 20px; right: -45px; background: #DC2626; color: #fff;
            font-size: 10px; font-weight: 900; padding: 6px 50px; transform: rotate(45deg);
            letter-spacing: 0.2em; text-transform: uppercase; z-index: 10; shadow: 0 10px 20px rgba(220,38,38,0.3);
        }
        .status-pill { transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1); }
        .status-pill.active { background: #6366f1 !important; color: #fff !important; box-shadow: 0 10px 30px -5px rgba(99, 102, 241, 0.4); border-color: transparent !important; }
        .qty-btn { transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
        .qty-btn:hover { transform: scale(1.15); }
        .qty-btn:active { transform: scale(0.9); }
        @keyframes slideUp { from{opacity:0;transform:translateY(30px)} to{opacity:1;transform:translateY(0)} }
        .animate-slide-up { animation: slideUp 0.7s cubic-bezier(0.4, 0, 0.2, 1) forwards; }
    </style>
</head>
<body class="antialiased text-slate-900 dark:text-slate-100 bg-slate-50 dark:bg-slate-950 transition-colors duration-300 min-h-screen pt-28 pb-20">
<%@ include file="navbar.jsp" %>

<div class="max-w-7xl mx-auto px-4">
    <!-- HEADER -->
    <div class="flex flex-col md:flex-row justify-between items-stretch md:items-start mb-8 sm:mb-12 gap-6 sm:gap-8">
        <div>
            <h1 class="text-3xl sm:text-4xl font-black text-slate-900 dark:text-white tracking-tighter leading-none flex items-center gap-3 sm:gap-4">
                <i class="fa-solid fa-boxes-stacked text-indigo-500"></i> Inventory
            </h1>
            <p class="mt-3 sm:mt-4 text-sm sm:text-base font-medium text-slate-500 dark:text-slate-400">Manage your garage inventory, stock levels, and parts.</p>
        </div>
        <a href="add_inventory.jsp" class="bg-indigo-600 hover:bg-indigo-700 text-white px-8 sm:px-10 py-4 sm:py-5 rounded-2xl sm:rounded-[2rem] shadow-2xl shadow-indigo-100 dark:shadow-none font-black text-[10px] uppercase tracking-[0.2em] transition-all flex items-center justify-center gap-3 active:scale-95 w-full md:w-auto">
            <i class="fa-solid fa-plus-circle text-base sm:text-lg"></i> Add New Item
        </a>
    </div>

    <!-- INVENTORY OVERVIEW -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 mb-8 sm:mb-12 animate-slide-up">
        <div class="stat-card bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] border border-slate-100 dark:border-slate-800 p-6 sm:p-8 shadow-2xl shadow-slate-200/40 dark:shadow-none relative overflow-hidden group">
            <div class="absolute -right-8 -top-8 w-24 h-24 bg-indigo-500/5 rounded-full blur-2xl group-hover:scale-150 transition-transform"></div>
            <p class="text-[9px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-[0.3em] mb-3 sm:mb-4">Total Items</p>
            <p class="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white mono tracking-tighter"><%= items.size() %></p>
            <div class="mt-4 sm:mt-6 flex items-center gap-2 text-[9px] font-black text-indigo-500 uppercase tracking-widest bg-indigo-50 dark:bg-indigo-950 px-4 py-1.5 rounded-xl border border-indigo-100 dark:border-indigo-800/50 w-fit">
                <i class="fa-solid fa-cubes"></i> Inventory
            </div>
        </div>
        <div class="stat-card bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] border border-slate-100 dark:border-slate-800 p-6 sm:p-8 shadow-2xl shadow-slate-200/40 dark:shadow-none relative overflow-hidden group border-l-4 border-l-emerald-500">
            <div class="absolute -right-8 -top-8 w-24 h-24 bg-emerald-500/5 rounded-full blur-2xl group-hover:scale-150 transition-transform"></div>
            <p class="text-[9px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-[0.3em] mb-3 sm:mb-4">Total Valuation</p>
            <p class="text-2xl sm:text-3xl font-black text-emerald-600 dark:text-emerald-400 mono tracking-tighter"><span class="text-xs font-bold mr-1 opacity-30">LKR</span><%= String.format("%,.0f", totalValue) %></p>
            <div class="mt-4 sm:mt-6 flex items-center gap-2 text-[9px] font-black text-emerald-500 uppercase tracking-widest bg-emerald-50 dark:bg-emerald-950 px-4 py-1.5 rounded-xl border border-emerald-100 dark:border-emerald-800/50 w-fit">
                <i class="fa-solid fa-coins"></i> Fiscal
            </div>
        </div>
        <div class="stat-card bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] border border-slate-100 dark:border-slate-800 p-6 sm:p-8 shadow-2xl shadow-slate-200/40 dark:shadow-none relative overflow-hidden group border-l-4 border-l-amber-500">
            <div class="absolute -right-8 -top-8 w-24 h-24 bg-amber-500/5 rounded-full blur-2xl group-hover:scale-150 transition-transform"></div>
            <p class="text-[9px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-[0.3em] mb-3 sm:mb-4">Low Stock</p>
            <p class="text-2xl sm:text-3xl font-black text-amber-600 dark:text-amber-400 mono tracking-tighter"><%= lowStockCount %></p>
            <div class="mt-4 sm:mt-6 flex items-center gap-2 text-[9px] font-black text-amber-500 uppercase tracking-widest bg-amber-50 dark:bg-amber-950 px-4 py-1.5 rounded-xl border border-amber-100 dark:border-amber-800/50 w-fit">
                <i class="fa-solid fa-triangle-exclamation"></i> Critical
            </div>
        </div>
        <div class="stat-card bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] border border-slate-100 dark:border-slate-800 p-6 sm:p-8 shadow-2xl shadow-slate-200/40 dark:shadow-none relative overflow-hidden group border-l-4 border-l-rose-500">
            <div class="absolute -right-8 -top-8 w-24 h-24 bg-rose-500/5 rounded-full blur-2xl group-hover:scale-150 transition-transform"></div>
            <p class="text-[9px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-[0.3em] mb-3 sm:mb-4">Out of Stock</p>
            <p class="text-2xl sm:text-3xl font-black text-rose-600 dark:text-rose-400 mono tracking-tighter"><%= outOfStockCount %></p>
            <div class="mt-4 sm:mt-6 flex items-center gap-2 text-[9px] font-black text-rose-500 uppercase tracking-widest bg-rose-50 dark:bg-rose-950 px-4 py-1.5 rounded-xl border border-rose-100 dark:border-rose-800/50 w-fit">
                <i class="fa-solid fa-circle-xmark"></i> OOS
            </div>
        </div>
    </div>

    <!-- SEARCH & FILTERS -->
    <div class="bg-white dark:bg-slate-900 p-4 sm:p-6 rounded-[2rem] sm:rounded-[3rem] border border-slate-100 dark:border-slate-800 mb-8 sm:mb-12 flex flex-col lg:flex-row gap-4 sm:gap-6 items-center shadow-2xl shadow-slate-200/40 dark:shadow-none animate-slide-up">
        <div class="relative flex-grow group w-full">
            <i class="fa-solid fa-magnifying-glass absolute left-5 sm:left-6 top-1/2 -translate-y-1/2 text-slate-400 dark:text-slate-700 transition-colors group-focus-within:text-indigo-500 text-sm"></i>
            <input type="text" id="searchInput" onkeyup="filterGrid()" placeholder="Search by item name or ID..." class="w-full pl-12 sm:pl-14 pr-6 sm:pr-8 py-3.5 sm:py-4 bg-slate-50 dark:bg-slate-950 border-2 border-transparent dark:border-slate-800 rounded-2xl sm:rounded-[1.5rem] text-xs sm:text-sm font-black text-slate-900 dark:text-white focus:ring-8 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all placeholder:text-slate-200 dark:placeholder:text-slate-800 shadow-inner">
        </div>
        <select id="categoryFilter" onchange="filterGrid()" class="w-full lg:w-auto py-3.5 sm:py-4 px-6 sm:px-8 bg-slate-50 dark:bg-slate-950 border-2 border-transparent dark:border-slate-800 rounded-2xl sm:rounded-[1.5rem] text-[9px] font-black uppercase tracking-[0.2em] text-slate-500 dark:text-slate-400 focus:ring-8 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none shadow-inner">
            <option value="all">All Categories</option>
            <option value="engine">Engine Systems</option><option value="brakes">Braking Modules</option>
            <option value="suspension">Suspension Rig</option><option value="electrical">Electrical Grid</option>
            <option value="fluids">Technical Fluids</option>
        </select>
        <div class="grid grid-cols-2 sm:flex sm:flex-wrap gap-2 bg-slate-50 dark:bg-slate-950 p-2 rounded-2xl sm:rounded-[1.5rem] border border-slate-100 dark:border-slate-800 shadow-inner w-full lg:w-auto">
            <button class="status-pill active text-[9px] font-black uppercase tracking-[0.2em] px-4 sm:px-8 py-2.5 sm:py-3 rounded-xl transition-all text-center" onclick="setStatus(this,'all')">All</button>
            <button class="status-pill text-[9px] font-black uppercase tracking-[0.2em] px-4 sm:px-8 py-2.5 sm:py-3 rounded-xl text-slate-400 dark:text-slate-700 transition-all flex items-center justify-center gap-1.5 sm:gap-2" onclick="setStatus(this,'in stock')"><span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span> Stock</button>
            <button class="status-pill text-[9px] font-black uppercase tracking-[0.2em] px-4 sm:px-8 py-2.5 sm:py-3 rounded-xl text-slate-400 dark:text-slate-700 transition-all flex items-center justify-center gap-1.5 sm:gap-2" onclick="setStatus(this,'low stock')"><span class="w-1.5 h-1.5 rounded-full bg-amber-500"></span> Low</button>
            <button class="status-pill text-[9px] font-black uppercase tracking-[0.2em] px-4 sm:px-8 py-2.5 sm:py-3 rounded-xl text-slate-400 dark:text-slate-700 transition-all flex items-center justify-center gap-1.5 sm:gap-2" onclick="setStatus(this,'out of stock')"><span class="w-1.5 h-1.5 rounded-full bg-rose-500"></span> OOS</button>
        </div>
    </div>

    <!-- INVENTORY GRID -->
    <div id="inventoryGrid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 animate-slide-up">
        <% if (items.isEmpty()) { %>
            <div class="col-span-full bg-white dark:bg-slate-900 rounded-[2.5rem] sm:rounded-[4rem] border-2 border-dashed border-slate-100 dark:border-slate-800 p-16 sm:p-32 text-center shadow-inner">
                <i class="fa-solid fa-box-open text-slate-300 dark:text-slate-800 text-6xl sm:text-8xl mb-6 sm:mb-10"></i>
                <h3 class="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white tracking-tighter mb-4">Inventory Empty</h3>
                <p class="text-slate-500 dark:text-slate-400 font-medium text-sm sm:text-lg">No items currently registered in the database.</p>
            </div>
        <% } else {
            for (InventoryItem item : items) {
                String statusText = item.getStockStatus();
                int qty = item.getQuantity();
                String barColor = qty > 20 ? "#10B981" : qty > 5 ? "#F59E0B" : "#F43F5E";
                int barWidth = Math.min(qty * 4, 100);
                String borderCls = qty == 0 ? "border-l-8 border-l-rose-500" : qty <= 5 ? "border-l-8 border-l-amber-500" : "border-l-8 border-l-indigo-500";
                
                String catIcon = "fa-gear";
                String cat = item.getCategory().toLowerCase();
                if (cat.contains("brake")) catIcon = "fa-compact-disc";
                else if (cat.contains("electric")) catIcon = "fa-car-battery";
                else if (cat.contains("fluid")) catIcon = "fa-oil-can";
                else if (cat.contains("suspension")) catIcon = "fa-wrench";
        %>
        <div class="inv-card bg-white dark:bg-slate-900 rounded-[1.5rem] sm:rounded-[2rem] border border-slate-100 dark:border-slate-800 p-4 sm:p-5 md:p-6 <%= borderCls %> relative overflow-hidden shadow-2xl shadow-slate-200/40 dark:shadow-none"
             data-name="<%= item.getItemName().toLowerCase() %> <%= item.getItemId().toLowerCase() %>"
             data-category="<%= item.getCategory().toLowerCase() %>"
             data-status="<%= statusText.toLowerCase() %>"
             data-qty="<%= qty %>"
             data-value="<%= item.getPrice() * qty %>"
             id="card-<%= item.getItemId() %>">
            
            <% if (qty == 0) { %><div class="oos-ribbon">OUT OF STOCK</div><% } %>
            
            <div class="flex items-center justify-between mb-4 sm:mb-5">
                <span class="mono text-[9px] font-black text-indigo-600 dark:text-indigo-400 bg-indigo-50 dark:bg-indigo-950 border border-indigo-100 dark:border-indigo-800/50 px-2.5 py-1 rounded-lg uppercase tracking-widest shadow-inner"><%= item.getItemId() %></span>
                <span class="text-[9px] font-black text-slate-400 dark:text-slate-600 bg-slate-50 dark:bg-slate-950 px-2.5 py-1 rounded-lg flex items-center gap-1.5 uppercase tracking-widest border border-slate-100 dark:border-slate-800/50 shadow-inner">
                    <i class="fa-solid <%= catIcon %> text-indigo-500"></i> <%= item.getCategory() %>
                </span>
            </div>

            <h3 class="text-base sm:text-lg font-black text-slate-900 dark:text-white tracking-tighter truncate mb-1" title="<%= item.getItemName() %>"><%= item.getItemName() %></h3>
            <p class="text-[9px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-widest mb-4 sm:mb-5">Unit Price: <span class="text-slate-900 dark:text-white mono ml-1">LKR <%= String.format("%,.0f", item.getPrice()) %></span></p>

            <div class="space-y-3 mb-5 sm:mb-6">
                <div class="flex justify-between items-end">
                    <span class="text-[9px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-[0.3em]">Stock Level</span>
                    <span class="text-xl font-black <%= qty == 0 ? "text-rose-500" : qty <= 5 ? "text-amber-500" : "text-emerald-500" %> mono tracking-tighter" id="qtyLabel-<%= item.getItemId() %>"><%= qty %></span>
                </div>
                <div class="stock-bar shadow-inner"><div class="stock-fill" style="width:<%= barWidth %>%;background:<%= barColor %>;box-shadow: 0 0 15px <%= barColor %>40"></div></div>
            </div>

            <div class="flex items-center justify-between mt-auto">
                <div class="flex items-center gap-2">
                    <a href="editInventoryItem.jsp?id=<%= item.getItemId() %>" class="w-9 h-9 rounded-xl bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-800 text-slate-400 dark:text-slate-800 hover:text-indigo-600 dark:hover:text-indigo-400 flex items-center justify-center transition-all shadow-inner active:scale-90" title="Edit Item"><i class="fa-solid fa-pen-to-square text-xs"></i></a>
                    <button type="button" onclick="openDeleteDrawer('<%= item.getItemId() %>', '<%= item.getItemName().replace("\'","\\\\\'") %>')" class="w-9 h-9 rounded-xl bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-800 text-slate-400 dark:text-slate-800 hover:text-rose-600 dark:hover:text-rose-500 flex items-center justify-center transition-all shadow-inner active:scale-90" title="Delete Item"><i class="fa-solid fa-trash-can text-xs"></i></button>
                </div>
            </div>
        </div>
        <%  }
        } %>
    </div>
</div>

<!-- DELETE ITEM MODAL -->
<div id="deleteDrawer" class="hidden fixed inset-0 z-[200] flex items-center justify-center p-4 sm:p-6">
    <div class="absolute inset-0 bg-slate-950/80 backdrop-blur-xl opacity-0 transition-opacity duration-300" id="delBackdrop" onclick="closeDeleteDrawer()"></div>
    <div class="relative bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] shadow-2xl max-w-sm w-full border border-slate-100 dark:border-slate-800 overflow-y-auto max-h-[calc(100vh-2rem)] sm:max-h-[90vh] custom-scrollbar transform scale-90 opacity-0 transition-all duration-300" id="delPanel">
        <div class="p-6 sm:p-10 md:p-12 text-center">
            <div class="w-16 h-16 sm:w-24 sm:h-24 rounded-[1.5rem] sm:rounded-[2rem] bg-rose-50 dark:bg-rose-950 flex items-center justify-center mx-auto mb-6 sm:mb-10 text-rose-500 shadow-inner border border-rose-100 dark:border-rose-900/30">
                <i class="fa-solid fa-trash-can text-2xl sm:text-4xl"></i>
            </div>
            <h3 class="text-xl sm:text-2xl md:text-3xl font-black text-slate-900 dark:text-white tracking-tighter">Delete Item?</h3>
            <p class="text-xs sm:text-sm font-medium text-slate-500 dark:text-slate-400 mt-3 sm:mt-4 leading-relaxed">Permanently remove <strong id="delPartName" class="text-slate-900 dark:text-white"></strong> from the inventory database.</p>
            <div class="flex flex-col gap-3 sm:gap-4 mt-6 sm:mt-10">
                <button type="button" onclick="confirmDelete()" class="w-full py-3.5 sm:py-5 rounded-xl sm:rounded-2xl bg-rose-600 hover:bg-rose-700 text-white font-black text-[10px] uppercase tracking-[0.2em] shadow-2xl shadow-rose-100 dark:shadow-none transition-all active:scale-95 flex items-center justify-center gap-3 sm:gap-4">
                    <i class="fa-solid fa-trash-can text-base sm:text-lg"></i> Confirm Delete
                </button>
                <button type="button" onclick="closeDeleteDrawer()" class="w-full py-3.5 sm:py-5 rounded-xl sm:rounded-2xl bg-white dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 text-slate-400 dark:text-slate-700 font-black text-[10px] uppercase tracking-[0.2em] hover:bg-slate-50 dark:hover:bg-slate-800 transition-all">Cancel</button>
            </div>
        </div>
    </div>
</div>

<%@ include file="toast.jsp" %>
<script>
let currentStatusFilter = 'all';
let deleteTargetId = '';

function setStatus(el, status) {
    document.querySelectorAll('.status-pill').forEach(p => p.classList.remove('active'));
    el.classList.add('active');
    currentStatusFilter = status;
    filterGrid();
}

function filterGrid() {
    const search = document.getElementById('searchInput').value.toLowerCase();
    const category = document.getElementById('categoryFilter').value.toLowerCase();
    const cards = document.querySelectorAll('.inv-card');
    cards.forEach(card => {
        const name = card.getAttribute('data-name');
        const cat = card.getAttribute('data-category');
        const st = card.getAttribute('data-status');
        const ok = name.includes(search) && (category==='all' || cat.includes(category)) && (currentStatusFilter==='all' || st===currentStatusFilter);
        card.style.display = ok ? '' : 'none';
    });
}


function openDeleteDrawer(id, name) {
    deleteTargetId = id;
    document.getElementById('delPartName').textContent = name;
    const m = document.getElementById('deleteDrawer');
    const b = document.getElementById('delBackdrop');
    const p = document.getElementById('delPanel');
    m.classList.remove('hidden');
    setTimeout(() => { b.style.opacity='1'; p.style.opacity='1'; p.style.transform='scale(1)'; }, 20);
}
function closeDeleteDrawer() {
    const b = document.getElementById('delBackdrop');
    const p = document.getElementById('delPanel');
    b.style.opacity='0'; p.style.opacity='0'; p.style.transform='scale(0.9)';
    setTimeout(() => document.getElementById('deleteDrawer').classList.add('hidden'), 300);
}
function confirmDelete() {
    const params = new URLSearchParams();
    params.append('deleteId', deleteTargetId);
    fetch('DeleteInventoryServlet', { method: 'POST', body: params })
    .then(() => {
        const card = document.getElementById('card-' + deleteTargetId);
        if (card) { card.style.transform='scale(0.9) translateY(20px)'; card.style.opacity='0'; setTimeout(()=>card.remove(), 400); }
        closeDeleteDrawer();
        showToast('Item removed from inventory.', 'success');
    });
}

document.addEventListener('DOMContentLoaded', () => {
    if (window.location.search.includes('addSuccess=true')) showToast('New item added successfully.', 'success');
});
</script>
</body>
</html>