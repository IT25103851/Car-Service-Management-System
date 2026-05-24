<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.ServiceTypeManager, model.ServiceType, java.util.List" %>
<%
    String role = (String) session.getAttribute("userRole");
    if (!"admin".equals(role)) { response.sendRedirect("login.jsp"); return; }
    ServiceTypeManager stm = new ServiceTypeManager();
    List<ServiceType> services = stm.getAllServices();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add New Item - SwiftDrive</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;700&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Plus Jakarta Sans', sans-serif; }
        .mono { font-family: 'JetBrains Mono', monospace; }
        .cat-btn { transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); cursor: pointer; }
        .cat-btn:hover { background: rgba(99, 102, 241, 0.05); border-color: #6366f1; }
        .cat-btn.selected { border-color: #6366f1 !important; background: #6366f1 !important; color: #fff !important; box-shadow: 0 10px 20px -5px rgba(99, 102, 241, 0.4); }
        .cat-btn.selected i, .cat-btn.selected span { color: #fff !important; }
        
        .icon-btn { transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); cursor: pointer; }
        .icon-btn:hover { transform: scale(1.1); border-color: #6366f1; color: #6366f1; }
        .icon-btn.selected { border-color: #6366f1 !important; background: #6366f1 !important; color: #fff !important; box-shadow: 0 10px 20px -5px rgba(99, 102, 241, 0.4); }
        
        .preview-card { transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1); }
        .stock-bar { height: 6px; border-radius: 100px; background: rgba(226, 232, 240, 0.1); overflow: hidden; }
        .stock-fill { height: 100%; border-radius: 100px; transition: width 0.6s cubic-bezier(0.4, 0, 0.2, 1); }
        
        .field-error { border-color: #ef4444 !important; box-shadow: 0 0 0 4px rgba(239, 68, 68, 0.1) !important; }
        .error-msg { color: #ef4444; font-size: 10px; font-weight: 800; text-transform: uppercase; letter-spacing: 0.1em; margin-top: 8px; display: none; }
        .error-msg.show { display: block; animation: shake 0.4s cubic-bezier(.36,.07,.19,.97) both; }
        @keyframes shake { 10%, 90% { transform: translate3d(-1px, 0, 0); } 20%, 80% { transform: translate3d(2px, 0, 0); } 30%, 50%, 70% { transform: translate3d(-4px, 0, 0); } 40%, 60% { transform: translate3d(4px, 0, 0); } }
    </style>
</head>
<body class="antialiased text-slate-900 dark:text-slate-100 bg-slate-50 dark:bg-slate-950 transition-colors duration-300 min-h-screen pt-28 pb-16">
<%@ include file="navbar.jsp" %>

<div class="max-w-6xl mx-auto px-4">
    <!-- HEADER -->
    <div class="mb-12">
        <a href="inventory.jsp" class="inline-flex items-center gap-2 text-[10px] font-black text-slate-400 dark:text-slate-600 hover:text-indigo-500 uppercase tracking-[0.2em] transition-all mb-6 group">
            <i class="fa-solid fa-arrow-left group-hover:-translate-x-1 transition-transform"></i> Return to Inventory
        </a>
        <h1 class="text-4xl font-black text-slate-900 dark:text-white tracking-tight"><i class="fa-solid fa-plus-circle text-indigo-500 mr-3"></i>Add Inventory Item</h1>
        <p class="mt-2 text-base font-medium text-slate-500 dark:text-slate-400">Add new parts or items to the garage inventory.</p>
    </div>

    <div class="flex flex-col lg:flex-row gap-12">
        <!-- LEFT: FORM -->
        <div class="flex-1 min-w-0">
            <form action="AddInventoryServlet" method="POST" id="addForm" class="space-y-8" onsubmit="return validateForm()">
                
                <div class="bg-white dark:bg-slate-800/40 backdrop-blur-md rounded-[2.5rem] border border-slate-100 dark:border-slate-800 p-10 shadow-2xl shadow-slate-200/40 dark:shadow-none">
                    <h3 class="text-[10px] font-black text-slate-400 dark:text-slate-500 mb-8 uppercase tracking-[0.2em] flex items-center gap-3">
                        <i class="fa-solid fa-fingerprint text-indigo-500 text-lg"></i> Item Details
                    </h3>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                        <div>
                            <label class="block text-[10px] font-black text-slate-400 dark:text-slate-500 mb-3 uppercase tracking-widest">Item ID</label>
                            <input type="text" name="itemId" id="fItemId" placeholder="BRK-001" required
                                   class="w-full px-6 py-4 bg-slate-50 dark:bg-slate-900 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black mono uppercase focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white placeholder:text-slate-300 dark:placeholder:text-slate-700"
                                   oninput="updatePreview()" onblur="validateField(this,'Identification Required')">
                            <p class="error-msg" id="err-fItemId"></p>
                        </div>
                        <div>
                            <label class="block text-[10px] font-black text-slate-400 dark:text-slate-500 mb-3 uppercase tracking-widest">Item Name</label>
                            <input type="text" name="itemName" id="fItemName" placeholder="Ceramic Alloy Pads" required
                                   class="w-full px-6 py-4 bg-slate-50 dark:bg-slate-900 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white placeholder:text-slate-300 dark:placeholder:text-slate-700"
                                   oninput="updatePreview()" onblur="validateField(this,'Artifact Name Required')">
                            <p class="error-msg" id="err-fItemName"></p>
                        </div>
                    </div>
                </div>

                <!-- CATEGORY GRID -->
                <div class="bg-white dark:bg-slate-800/40 backdrop-blur-md rounded-[2.5rem] border border-slate-100 dark:border-slate-800 p-10 shadow-2xl shadow-slate-200/40 dark:shadow-none">
                    <h3 class="text-[10px] font-black text-slate-400 dark:text-slate-500 mb-8 uppercase tracking-[0.2em] flex items-center gap-3">
                        <i class="fa-solid fa-layer-group text-indigo-500 text-lg"></i> Category
                    </h3>
                    <div class="grid grid-cols-2 sm:grid-cols-5 gap-3">
                        <div class="cat-btn border-2 border-slate-100 dark:border-slate-800 rounded-2xl p-4 text-center selected" onclick="selectCategory(this,'Engine')">
                            <i class="fa-solid fa-gear text-xl text-slate-400 block mb-2 transition-colors"></i>
                            <span class="text-[9px] font-black uppercase tracking-widest text-slate-500 transition-colors">Engine</span>
                        </div>
                        <div class="cat-btn border-2 border-slate-100 dark:border-slate-800 rounded-2xl p-4 text-center" onclick="selectCategory(this,'Brakes')">
                            <i class="fa-solid fa-compact-disc text-xl text-slate-400 block mb-2 transition-colors"></i>
                            <span class="text-[9px] font-black uppercase tracking-widest text-slate-500 transition-colors">Brakes</span>
                        </div>
                        <div class="cat-btn border-2 border-slate-100 dark:border-slate-800 rounded-2xl p-4 text-center" onclick="selectCategory(this,'Suspension')">
                            <i class="fa-solid fa-wrench text-xl text-slate-400 block mb-2 transition-colors"></i>
                            <span class="text-[9px] font-black uppercase tracking-widest text-slate-500 transition-colors">Chassis</span>
                        </div>
                        <div class="cat-btn border-2 border-slate-100 dark:border-slate-800 rounded-2xl p-4 text-center" onclick="selectCategory(this,'Electrical')">
                            <i class="fa-solid fa-car-battery text-xl text-slate-400 block mb-2 transition-colors"></i>
                            <span class="text-[9px] font-black uppercase tracking-widest text-slate-500 transition-colors">Electrical</span>
                        </div>
                        <div class="cat-btn border-2 border-slate-100 dark:border-slate-800 rounded-2xl p-4 text-center" onclick="selectCategory(this,'Fluids')">
                            <i class="fa-solid fa-oil-can text-xl text-slate-400 block mb-2 transition-colors"></i>
                            <span class="text-[9px] font-black uppercase tracking-widest text-slate-500 transition-colors">Fluids</span>
                        </div>
                    </div>
                    <input type="hidden" name="category" id="fCategory" value="Engine">
                </div>

                <!-- ICON SELECTOR -->
                <div class="bg-white dark:bg-slate-800/40 backdrop-blur-md rounded-[2.5rem] border border-slate-100 dark:border-slate-800 p-10 shadow-2xl shadow-slate-200/40 dark:shadow-none">
                    <h3 class="text-[10px] font-black text-slate-400 dark:text-slate-500 mb-8 uppercase tracking-[0.2em] flex items-center gap-3">
                        <i class="fa-solid fa-icons text-indigo-500 text-lg"></i> Visual Identifier
                    </h3>
                    <div class="flex gap-4 flex-wrap">
                        <div class="icon-btn w-14 h-14 rounded-2xl border-2 border-slate-100 dark:border-slate-800 flex items-center justify-center selected" onclick="selectIcon(this,'fa-gear')"><i class="fa-solid fa-gear"></i></div>
                        <div class="icon-btn w-14 h-14 rounded-2xl border-2 border-slate-100 dark:border-slate-800 flex items-center justify-center" onclick="selectIcon(this,'fa-car-battery')"><i class="fa-solid fa-car-battery"></i></div>
                        <div class="icon-btn w-14 h-14 rounded-2xl border-2 border-slate-100 dark:border-slate-800 flex items-center justify-center" onclick="selectIcon(this,'fa-oil-can')"><i class="fa-solid fa-oil-can"></i></div>
                        <div class="icon-btn w-14 h-14 rounded-2xl border-2 border-slate-100 dark:border-slate-800 flex items-center justify-center" onclick="selectIcon(this,'fa-compact-disc')"><i class="fa-solid fa-compact-disc"></i></div>
                        <div class="icon-btn w-14 h-14 rounded-2xl border-2 border-slate-100 dark:border-slate-800 flex items-center justify-center" onclick="selectIcon(this,'fa-wrench')"><i class="fa-solid fa-wrench"></i></div>
                    </div>
                    <input type="hidden" name="iconName" id="fIconName" value="fa-gear">
                </div>

                <!-- STOCK + PRICING -->
                <div class="bg-white dark:bg-slate-800/40 backdrop-blur-md rounded-[2.5rem] border border-slate-100 dark:border-slate-800 p-10 shadow-2xl shadow-slate-200/40 dark:shadow-none">
                    <h3 class="text-[10px] font-black text-slate-400 dark:text-slate-500 mb-8 uppercase tracking-[0.2em] flex items-center gap-3">
                        <i class="fa-solid fa-coins text-indigo-500 text-lg"></i> Stock & Pricing
                    </h3>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-8 mb-8">
                        <div>
                            <label class="block text-[10px] font-black text-slate-400 dark:text-slate-500 mb-3 uppercase tracking-widest">Initial Stock</label>
                            <input type="number" name="quantity" id="fQuantity" placeholder="0" required min="0" value="0"
                                   class="w-full px-6 py-4 bg-slate-50 dark:bg-slate-900 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white"
                                   oninput="updatePreview()" onblur="validateField(this,'Volume Metric Required')">
                            <p class="error-msg" id="err-fQuantity"></p>
                        </div>
                        <div>
                            <label class="block text-[10px] font-black text-slate-400 dark:text-slate-500 mb-3 uppercase tracking-widest">Unit Price (LKR)</label>
                            <input type="number" name="price" id="fPrice" placeholder="0.00" required step="0.01" min="0" value="0"
                                   class="w-full px-6 py-4 bg-slate-50 dark:bg-slate-900 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black mono focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white"
                                   oninput="updatePreview()" onblur="validateField(this,'Valuation Required')">
                            <p class="error-msg" id="err-fPrice"></p>
                        </div>
                    </div>
                    <div>
                        <label class="block text-[10px] font-black text-slate-400 dark:text-slate-500 mb-3 uppercase tracking-widest">Applicable Service</label>
                        <select name="applicableService" id="fService" class="w-full px-6 py-4 bg-slate-50 dark:bg-slate-900 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-4 focus:ring-indigo-500/10 outline-none transition-all dark:text-white cursor-pointer" onchange="updatePreview()">
                            <option value="none">Universal Deployment (Global)</option>
                            <% for (ServiceType st : services) { %>
                            <option value="<%= st.getServiceName() %>"><%= st.getServiceName() %></option>
                            <% } %>
                        </select>
                    </div>
                </div>

                <!-- SUBMIT -->
                <div class="flex items-center gap-6">
                    <button type="submit" class="flex-1 py-5 rounded-[2rem] bg-indigo-600 hover:bg-indigo-700 text-white font-black text-xs uppercase tracking-[0.2em] shadow-2xl shadow-indigo-100 dark:shadow-none transition-all active:scale-95 flex items-center justify-center gap-3">
                        <i class="fa-solid fa-cloud-arrow-up text-lg"></i> Add to Inventory
                    </button>
                    <a href="inventory.jsp" class="px-12 py-5 rounded-[2rem] border-2 border-slate-100 dark:border-slate-800 text-slate-500 dark:text-slate-400 font-black text-xs uppercase tracking-widest hover:bg-slate-50 dark:hover:bg-slate-800 transition-all">Cancel</a>
                </div>
            </form>
        </div>

        <!-- RIGHT: LIVE PREVIEW -->
        <div class="w-full lg:w-96 flex-shrink-0">
            <div class="sticky top-32">
                <h3 class="text-[10px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-[0.3em] mb-6 flex items-center gap-3">
                    <i class="fa-solid fa-eye text-indigo-500"></i> Item Preview
                </h3>
                <div class="preview-card bg-white dark:bg-slate-900 rounded-[2.5rem] border border-slate-100 dark:border-slate-800 p-8 relative overflow-hidden shadow-2xl shadow-slate-200/40 dark:shadow-none group" id="previewCard">
                    <div class="absolute -top-12 -right-12 w-32 h-32 bg-indigo-500/5 rounded-full blur-2xl group-hover:bg-indigo-500/10 transition-all"></div>
                    
                    <div class="flex items-center justify-between mb-8">
                        <span class="mono text-[10px] font-black text-indigo-600 dark:text-indigo-400 bg-indigo-50 dark:bg-indigo-900/30 px-3 py-1 rounded-xl border border-indigo-100 dark:border-indigo-800/50 uppercase tracking-widest" id="pvId">PRO-001</span>
                        <span class="text-[8px] font-black text-slate-400 dark:text-slate-600 bg-slate-50 dark:bg-slate-950 px-3 py-1 rounded-xl border border-slate-100 dark:border-slate-800 uppercase tracking-widest flex items-center gap-2" id="pvCat">
                            <i class="fa-solid fa-gear"></i> ENGINE
                        </span>
                    </div>

                    <h4 class="text-xl font-black text-slate-800 dark:text-white truncate mb-1 group-hover:text-indigo-500 transition-colors" id="pvName">Item Name</h4>
                    <p class="text-xs font-black text-slate-400 dark:text-slate-600 mono mb-8 uppercase tracking-widest" id="pvPrice">LKR 0.00</p>

                    <div class="bg-slate-50 dark:bg-slate-950/60 p-6 rounded-[1.5rem] border border-slate-100 dark:border-slate-800 shadow-inner mb-8">
                        <div class="flex items-center justify-between mb-3">
                            <span class="text-[9px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-widest">Stock Level</span>
                            <span class="text-xs font-black mono text-emerald-600 dark:text-emerald-400" id="pvQty">0 <span class="text-[9px] opacity-60 uppercase">Units</span></span>
                        </div>
                        <div class="stock-bar"><div class="stock-fill" id="pvBar" style="width:0%;background:#10b981"></div></div>
                    </div>

                    <div class="flex items-center justify-between opacity-30 pointer-events-none">
                        <div class="flex items-center bg-white dark:bg-slate-950 border border-slate-100 dark:border-slate-800 rounded-xl p-1">
                            <div class="w-8 h-8 rounded-lg flex items-center justify-center"><i class="fa-solid fa-minus text-[10px]"></i></div>
                            <span class="text-xs font-black w-8 text-center mono">0</span>
                            <div class="w-8 h-8 rounded-lg flex items-center justify-center"><i class="fa-solid fa-plus text-[10px]"></i></div>
                        </div>
                        <div class="flex items-center gap-2">
                            <div class="w-10 h-10 rounded-xl bg-white dark:bg-slate-950 border border-slate-100 dark:border-slate-800 flex items-center justify-center"><i class="fa-solid fa-sliders text-[11px]"></i></div>
                            <div class="w-10 h-10 rounded-xl bg-white dark:bg-slate-950 border border-slate-100 dark:border-slate-800 flex items-center justify-center"><i class="fa-solid fa-trash text-[11px]"></i></div>
                        </div>
                    </div>
                </div>
                <p class="text-[10px] font-black text-slate-400 dark:text-slate-600 mt-6 text-center uppercase tracking-widest">Real-time Render of Inventory Entry</p>
            </div>
        </div>
    </div>
</div>

<script>
let selectedCatIcon = 'fa-gear';

function selectCategory(el, cat) {
    document.querySelectorAll('.cat-btn').forEach(b => b.classList.remove('selected'));
    el.classList.add('selected');
    document.getElementById('fCategory').value = cat;
    updatePreview();
}

function selectIcon(el, icon) {
    document.querySelectorAll('.icon-btn').forEach(b => b.classList.remove('selected'));
    el.classList.add('selected');
    document.getElementById('fIconName').value = icon;
    selectedCatIcon = icon;
    updatePreview();
}

function updatePreview() {
    const id = document.getElementById('fItemId').value || 'PRO-001';
    const name = document.getElementById('fItemName').value || 'Item Name';
    const price = parseFloat(document.getElementById('fPrice').value) || 0;
    const qty = parseInt(document.getElementById('fQuantity').value) || 0;
    const cat = document.getElementById('fCategory').value || 'Engine';
    const icon = document.getElementById('fIconName').value || 'fa-gear';

    document.getElementById('pvId').textContent = id.toUpperCase();
    document.getElementById('pvName').textContent = name;
    document.getElementById('pvPrice').textContent = 'LKR ' + price.toLocaleString('en-LK', {minimumFractionDigits:2, maximumFractionDigits:2});
    document.getElementById('pvQty').innerHTML = qty + ' <span class="text-[9px] opacity-60 uppercase">Units</span>';
    document.getElementById('pvCat').innerHTML = '<i class="fa-solid ' + icon + '"></i> ' + cat.toUpperCase();

    const barWidth = Math.min(qty * 2, 100);
    const barColor = qty > 20 ? '#10b981' : qty > 5 ? '#f59e0b' : '#ef4444';
    document.getElementById('pvBar').style.width = barWidth + '%';
    document.getElementById('pvBar').style.background = barColor;
}

function validateField(el, msg) {
    const errEl = document.getElementById('err-' + el.id);
    if (!el.value.trim()) {
        el.classList.add('field-error');
        if (errEl) { errEl.textContent = msg; errEl.classList.add('show'); }
    } else {
        el.classList.remove('field-error');
        if (errEl) errEl.classList.remove('show');
    }
}

function validateForm() {
    let valid = true;
    ['fItemId','fItemName','fQuantity','fPrice'].forEach(id => {
        const el = document.getElementById(id);
        if (!el.value.trim()) { el.classList.add('field-error'); valid = false; }
    });
    return valid;
}

document.addEventListener('DOMContentLoaded', () => {
    const params = new URLSearchParams(window.location.search);
    if (params.has('error')) {
        const err = params.get('error');
        if (err === 'duplicateId') {
            const id = params.get('id') || '';
            showToast(`Item ID "${id}" already exists in the inventory!`, 'error');
        } else if (err === 'invalidNumeric') {
            showToast('Invalid numeric format for quantity or price.', 'error');
        } else if (err === 'emptyFields') {
            showToast('Please fill out all required fields.', 'error');
        }
    }
});
</script>
<%@ include file="toast.jsp" %>
</body>
</html>