<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.ServiceTypeManager, model.ServiceType, model.InventoryManager, model.InventoryItem, java.util.List" %>
<%
    String role = (String) session.getAttribute("userRole");
    if (!"admin".equals(role)) { response.sendRedirect("login.jsp"); return; }

    String itemId = request.getParameter("id");
    if (itemId == null || itemId.isEmpty()) { response.sendRedirect("inventory.jsp"); return; }

    InventoryManager invManager = new InventoryManager();
    InventoryItem item = invManager.getItemById(itemId);
    if (item == null) { response.sendRedirect("inventory.jsp"); return; }

    ServiceTypeManager stm = new ServiceTypeManager();
    List<ServiceType> services = stm.getAllServices();
    
    int qty = item.getQuantity();
    String statusColor = qty == 0 ? "text-red-600 bg-red-50 border-red-200" : qty <= 5 ? "text-amber-600 bg-amber-50 border-amber-200" : "text-emerald-600 bg-emerald-50 border-emerald-200";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Item - SwiftDrive</title>
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

        /* Tabs styling */
        .tab-btn { transition: all 0.3s ease; }
        .tab-btn.active { background: #fff; color: #6366f1; box-shadow: 0 10px 20px -5px rgba(99, 102, 241, 0.1); }
        .dark .tab-btn.active { background: #1e293b; color: #818cf8; }
        .tab-content { display: none; animation: fadeIn 0.4s ease forwards; }
        .tab-content.active { display: block; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }

        .step-btn { transition: all 0.15s; }
        .step-btn:hover { transform: scale(1.08); }
        .step-btn:active { transform: scale(0.95); }
        .timeline-dot { width: 10px; height: 10px; border-radius: 50%; flex-shrink: 0; }
    </style>
</head>
<body class="antialiased text-slate-900 dark:text-slate-100 bg-slate-50 dark:bg-slate-950 transition-colors duration-300 min-h-screen pt-28 pb-16">
<%@ include file="navbar.jsp" %>

<div class="max-w-6xl mx-auto px-4">
    <!-- HEADER -->
    <div class="mb-8">
        <a href="inventory.jsp" class="inline-flex items-center gap-2 text-[10px] font-black text-slate-400 dark:text-slate-600 hover:text-indigo-500 uppercase tracking-[0.2em] transition-all mb-6 group">
            <i class="fa-solid fa-arrow-left group-hover:-translate-x-1 transition-transform"></i> Return to Inventory
        </a>
        <h1 class="text-4xl font-black text-slate-900 dark:text-white tracking-tight"><i class="fa-solid fa-pen-to-square text-indigo-500 mr-3"></i>Edit Inventory Item</h1>
        <p class="mt-2 text-base font-medium text-slate-500 dark:text-slate-400">Manage details and stock levels for <span class="mono text-indigo-500 font-bold"><%= item.getItemId() %></span>.</p>
    </div>

    <!-- TABS NAVIGATION -->
    <div class="flex items-center gap-2 p-2 bg-slate-100 dark:bg-slate-900 rounded-[2rem] w-fit mb-10 border border-slate-200 dark:border-slate-800 shadow-inner">
        <button type="button" onclick="switchTab('details')" id="tabBtn-details" class="tab-btn active px-8 py-4 rounded-[1.5rem] text-[11px] font-black uppercase tracking-widest text-slate-500 flex items-center gap-2">
            <i class="fa-solid fa-fingerprint"></i> Item Details
        </button>
        <button type="button" onclick="switchTab('stock')" id="tabBtn-stock" class="tab-btn px-8 py-4 rounded-[1.5rem] text-[11px] font-black uppercase tracking-widest text-slate-500 flex items-center gap-2">
            <i class="fa-solid fa-cubes-stacked"></i> Stock Control
        </button>
    </div>

    <div class="flex flex-col lg:flex-row gap-12">
        <!-- LEFT: FORM -->
        <div class="flex-1 min-w-0">
            <form action="UpdateInventoryServlet" method="POST" id="editForm" class="space-y-8" onsubmit="return validateForm()">
                <input type="hidden" name="itemId" id="fItemId" value="<%= item.getItemId() %>">

                <!-- TAB 1: DETAILS -->
                <div id="tab-details" class="tab-content active space-y-8">
                    <!-- Basic Info -->
                    <div class="bg-white dark:bg-slate-800/40 backdrop-blur-md rounded-[2.5rem] border border-slate-100 dark:border-slate-800 p-10 shadow-2xl shadow-slate-200/40 dark:shadow-none">
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                            <div>
                                <label class="block text-[10px] font-black text-slate-400 dark:text-slate-500 mb-3 uppercase tracking-widest">Item ID</label>
                                <input type="text" value="<%= item.getItemId() %>" disabled
                                       class="w-full px-6 py-4 bg-slate-100 dark:bg-slate-800 border-2 border-transparent dark:border-slate-700 rounded-2xl text-sm font-black mono uppercase outline-none transition-all dark:text-slate-400 cursor-not-allowed">
                            </div>
                            <div>
                                <label class="block text-[10px] font-black text-slate-400 dark:text-slate-500 mb-3 uppercase tracking-widest">Item Name</label>
                                <input type="text" name="itemName" id="fItemName" value="<%= item.getItemName() %>" placeholder="Ceramic Alloy Pads" required
                                       class="w-full px-6 py-4 bg-slate-50 dark:bg-slate-900 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white placeholder:text-slate-300 dark:placeholder:text-slate-700"
                                       oninput="updatePreview()" onblur="validateField(this,'Artifact Name Required')">
                                <p class="error-msg" id="err-fItemName"></p>
                            </div>
                        </div>
                    </div>

                    <!-- Category Grid -->
                    <div class="bg-white dark:bg-slate-800/40 backdrop-blur-md rounded-[2.5rem] border border-slate-100 dark:border-slate-800 p-10 shadow-2xl shadow-slate-200/40 dark:shadow-none">
                        <h3 class="text-[10px] font-black text-slate-400 dark:text-slate-500 mb-8 uppercase tracking-[0.2em] flex items-center gap-3">
                            <i class="fa-solid fa-layer-group text-indigo-500 text-lg"></i> Category
                        </h3>
                        <div class="grid grid-cols-2 sm:grid-cols-5 gap-3">
                            <div class="cat-btn border-2 border-slate-100 dark:border-slate-800 rounded-2xl p-4 text-center <%= "Engine".equals(item.getCategory()) ? "selected" : "" %>" onclick="selectCategory(this,'Engine')">
                                <i class="fa-solid fa-gear text-xl text-slate-400 block mb-2 transition-colors"></i>
                                <span class="text-[9px] font-black uppercase tracking-widest text-slate-500 transition-colors">Engine</span>
                            </div>
                            <div class="cat-btn border-2 border-slate-100 dark:border-slate-800 rounded-2xl p-4 text-center <%= "Brakes".equals(item.getCategory()) ? "selected" : "" %>" onclick="selectCategory(this,'Brakes')">
                                <i class="fa-solid fa-compact-disc text-xl text-slate-400 block mb-2 transition-colors"></i>
                                <span class="text-[9px] font-black uppercase tracking-widest text-slate-500 transition-colors">Brakes</span>
                            </div>
                            <div class="cat-btn border-2 border-slate-100 dark:border-slate-800 rounded-2xl p-4 text-center <%= "Suspension".equals(item.getCategory()) || "Chassis".equals(item.getCategory()) ? "selected" : "" %>" onclick="selectCategory(this,'Suspension')">
                                <i class="fa-solid fa-wrench text-xl text-slate-400 block mb-2 transition-colors"></i>
                                <span class="text-[9px] font-black uppercase tracking-widest text-slate-500 transition-colors">Chassis</span>
                            </div>
                            <div class="cat-btn border-2 border-slate-100 dark:border-slate-800 rounded-2xl p-4 text-center <%= "Electrical".equals(item.getCategory()) ? "selected" : "" %>" onclick="selectCategory(this,'Electrical')">
                                <i class="fa-solid fa-car-battery text-xl text-slate-400 block mb-2 transition-colors"></i>
                                <span class="text-[9px] font-black uppercase tracking-widest text-slate-500 transition-colors">Electrical</span>
                            </div>
                            <div class="cat-btn border-2 border-slate-100 dark:border-slate-800 rounded-2xl p-4 text-center <%= "Fluids".equals(item.getCategory()) ? "selected" : "" %>" onclick="selectCategory(this,'Fluids')">
                                <i class="fa-solid fa-oil-can text-xl text-slate-400 block mb-2 transition-colors"></i>
                                <span class="text-[9px] font-black uppercase tracking-widest text-slate-500 transition-colors">Fluids</span>
                            </div>
                        </div>
                        <input type="hidden" name="category" id="fCategory" value="<%= item.getCategory() %>">
                    </div>

                    <!-- Icon Selector -->
                    <div class="bg-white dark:bg-slate-800/40 backdrop-blur-md rounded-[2.5rem] border border-slate-100 dark:border-slate-800 p-10 shadow-2xl shadow-slate-200/40 dark:shadow-none">
                        <h3 class="text-[10px] font-black text-slate-400 dark:text-slate-500 mb-8 uppercase tracking-[0.2em] flex items-center gap-3">
                            <i class="fa-solid fa-icons text-indigo-500 text-lg"></i> Visual Identifier
                        </h3>
                        <div class="flex gap-4 flex-wrap">
                            <div class="icon-btn w-14 h-14 rounded-2xl border-2 border-slate-100 dark:border-slate-800 flex items-center justify-center <%= "fa-gear".equals(item.getIconName()) ? "selected" : "" %>" onclick="selectIcon(this,'fa-gear')"><i class="fa-solid fa-gear"></i></div>
                            <div class="icon-btn w-14 h-14 rounded-2xl border-2 border-slate-100 dark:border-slate-800 flex items-center justify-center <%= "fa-car-battery".equals(item.getIconName()) ? "selected" : "" %>" onclick="selectIcon(this,'fa-car-battery')"><i class="fa-solid fa-car-battery"></i></div>
                            <div class="icon-btn w-14 h-14 rounded-2xl border-2 border-slate-100 dark:border-slate-800 flex items-center justify-center <%= "fa-oil-can".equals(item.getIconName()) ? "selected" : "" %>" onclick="selectIcon(this,'fa-oil-can')"><i class="fa-solid fa-oil-can"></i></div>
                            <div class="icon-btn w-14 h-14 rounded-2xl border-2 border-slate-100 dark:border-slate-800 flex items-center justify-center <%= "fa-compact-disc".equals(item.getIconName()) ? "selected" : "" %>" onclick="selectIcon(this,'fa-compact-disc')"><i class="fa-solid fa-compact-disc"></i></div>
                            <div class="icon-btn w-14 h-14 rounded-2xl border-2 border-slate-100 dark:border-slate-800 flex items-center justify-center <%= "fa-wrench".equals(item.getIconName()) ? "selected" : "" %>" onclick="selectIcon(this,'fa-wrench')"><i class="fa-solid fa-wrench"></i></div>
                        </div>
                        <input type="hidden" name="iconName" id="fIconName" value="<%= item.getIconName() %>">
                    </div>

                    <!-- Applicable Service -->
                    <div class="bg-white dark:bg-slate-800/40 backdrop-blur-md rounded-[2.5rem] border border-slate-100 dark:border-slate-800 p-10 shadow-2xl shadow-slate-200/40 dark:shadow-none">
                        <label class="block text-[10px] font-black text-slate-400 dark:text-slate-500 mb-3 uppercase tracking-widest">Applicable Service</label>
                        <select name="applicableService" id="fService" class="w-full px-6 py-4 bg-slate-50 dark:bg-slate-900 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-4 focus:ring-indigo-500/10 outline-none transition-all dark:text-white cursor-pointer" onchange="updatePreview()">
                            <option value="none" <%= "none".equals(item.getApplicableService()) ? "selected" : "" %>>Universal Deployment (Global)</option>
                            <% for (ServiceType st : services) { %>
                            <option value="<%= st.getServiceName() %>" <%= st.getServiceName().equals(item.getApplicableService()) ? "selected" : "" %>><%= st.getServiceName() %></option>
                            <% } %>
                        </select>
                    </div>
                </div>

                <!-- TAB 2: STOCK CONTROL -->
                <div id="tab-stock" class="tab-content space-y-8">
                    <!-- Quantity & Price -->
                    <div class="bg-white dark:bg-slate-800/40 backdrop-blur-md rounded-[2.5rem] border border-slate-100 dark:border-slate-800 p-10 shadow-2xl shadow-slate-200/40 dark:shadow-none">
                        
                        <div class="mb-8">
                            <label class="block text-[10px] font-black text-slate-400 dark:text-slate-500 mb-3 uppercase tracking-widest">Unit Price (LKR)</label>
                            <input type="number" name="price" id="fPrice" value="<%= item.getPrice() %>" required step="0.01" min="0"
                                   class="w-full px-6 py-4 bg-slate-50 dark:bg-slate-900 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black mono focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white"
                                   oninput="updatePreview()" onblur="validateField(this,'Valuation Required')">
                            <p class="error-msg" id="err-fPrice"></p>
                        </div>

                        <hr class="border-slate-100 dark:border-slate-800 my-8">
                        
                        <h3 class="text-[10px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-widest mb-6 flex items-center gap-3"><i class="fa-solid fa-sliders text-indigo-500"></i> Quantity Adjustment</h3>
                        
                        <!-- Large Stepper -->
                        <div class="flex items-center justify-center gap-4 mb-6">
                            <button type="button" onclick="stepQty(-1)" class="step-btn w-14 h-14 rounded-2xl bg-red-100 hover:bg-red-200 text-red-600 flex items-center justify-center text-2xl font-bold shadow-sm">
                                <i class="fa-solid fa-minus"></i>
                            </button>
                            <input type="number" name="quantity" id="fQuantity" value="<%= qty %>" min="0" required
                                   class="w-32 h-20 text-center text-4xl font-black text-slate-900 dark:text-white bg-slate-50 dark:bg-slate-950 border-2 border-transparent dark:border-slate-800 rounded-3xl focus:ring-8 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all shadow-inner"
                                   oninput="updatePreview()" onblur="validateField(this,'Volume Required')">
                            <button type="button" onclick="stepQty(1)" class="step-btn w-14 h-14 rounded-2xl bg-emerald-100 hover:bg-emerald-200 text-emerald-600 flex items-center justify-center text-2xl font-bold shadow-sm">
                                <i class="fa-solid fa-plus"></i>
                            </button>
                        </div>
                        <p class="error-msg text-center" id="err-fQuantity"></p>

                        <!-- Contextual Buttons -->
                        <div class="grid grid-cols-2 gap-4 mt-8 mb-8">
                            <button type="button" onclick="markUsed()" class="py-4 rounded-2xl border-2 border-rose-100 dark:border-rose-900/30 text-rose-600 dark:text-rose-400 font-black text-[10px] uppercase tracking-widest hover:bg-rose-50 dark:hover:bg-rose-950/30 transition-all flex items-center justify-center gap-3 active:scale-95">
                                <i class="fa-solid fa-arrow-down text-lg"></i> Mark Used
                            </button>
                            <button type="button" onclick="restock()" class="py-4 rounded-2xl border-2 border-emerald-100 dark:border-emerald-900/30 text-emerald-600 dark:text-emerald-400 font-black text-[10px] uppercase tracking-widest hover:bg-emerald-50 dark:hover:bg-emerald-950/30 transition-all flex items-center justify-center gap-3 active:scale-95">
                                <i class="fa-solid fa-arrow-up text-lg"></i> Restock +10
                            </button>
                        </div>
                        
                        <!-- Reason Dropdown -->
                        <div>
                            <label class="block text-[9px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-widest mb-3">Adjustment Rationale</label>
                            <select id="reason" class="w-full px-6 py-4 bg-slate-50 dark:bg-slate-950 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black text-slate-900 dark:text-white focus:ring-8 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all cursor-pointer shadow-inner">
                                <option value="">— Select rationale (Optional) —</option>
                                <option>Used in Service</option>
                                <option>New Delivery</option>
                                <option>Damaged / Waste</option>
                                <option>Manual Correction</option>
                                <option>Inventory Audit</option>
                            </select>
                        </div>
                    </div>

                    <!-- AUDIT TRAIL -->
                    <div class="bg-white dark:bg-slate-800/40 backdrop-blur-md rounded-[2.5rem] border border-slate-100 dark:border-slate-800 p-10 shadow-2xl shadow-slate-200/40 dark:shadow-none">
                        <h3 class="text-[10px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-widest mb-8 flex items-center gap-3"><i class="fa-solid fa-clock-rotate-left text-indigo-500"></i> Audit History</h3>
                        <div class="space-y-4" id="auditTrail">
                            <!-- Dynamic entries will appear here -->
                            <div class="flex items-start gap-3">
                                <div class="timeline-dot bg-emerald-500 mt-1.5"></div>
                                <div class="flex-1 border-l-2 border-slate-100 dark:border-slate-800 pl-6 pb-6">
                                    <p class="text-sm font-black text-slate-800 dark:text-slate-200">Current System State</p>
                                    <p class="text-[11px] font-medium text-slate-400 dark:text-slate-600 mt-1">Quantity initialized to <span class="font-black text-indigo-600 dark:text-indigo-400"><%= qty %></span> units</p>
                                    <p class="text-[9px] font-black text-slate-400 dark:text-slate-800 uppercase tracking-widest mt-2">System Authority • On record creation</p>
                                </div>
                            </div>
                        </div>
                        <p class="text-[11px] text-slate-400 mt-3 text-center italic">Activity log is session-based and resets on reload.</p>
                    </div>
                </div>

                <!-- SUBMIT -->
                <div class="flex items-center gap-6 mt-8">
                    <button type="submit" class="flex-1 py-5 rounded-[2rem] bg-indigo-600 hover:bg-indigo-700 text-white font-black text-xs uppercase tracking-[0.2em] shadow-2xl shadow-indigo-100 dark:shadow-none transition-all active:scale-95 flex items-center justify-center gap-3">
                        <i class="fa-solid fa-cloud-arrow-up text-lg"></i> Save Changes
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
                        <span class="mono text-[10px] font-black text-indigo-600 dark:text-indigo-400 bg-indigo-50 dark:bg-indigo-900/30 px-3 py-1 rounded-xl border border-indigo-100 dark:border-indigo-800/50 uppercase tracking-widest" id="pvId"><%= item.getItemId() %></span>
                        <span class="text-[8px] font-black text-slate-400 dark:text-slate-600 bg-slate-50 dark:bg-slate-950 px-3 py-1 rounded-xl border border-slate-100 dark:border-slate-800 uppercase tracking-widest flex items-center gap-2" id="pvCat">
                            <i class="fa-solid <%= item.getIconName() %>"></i> <%= item.getCategory().toUpperCase() %>
                        </span>
                    </div>

                    <h4 class="text-xl font-black text-slate-800 dark:text-white truncate mb-1 group-hover:text-indigo-500 transition-colors" id="pvName"><%= item.getItemName() %></h4>
                    <p class="text-xs font-black text-slate-400 dark:text-slate-600 mono mb-8 uppercase tracking-widest" id="pvPrice">LKR <%= String.format("%,.2f", item.getPrice()) %></p>

                    <div class="bg-slate-50 dark:bg-slate-950/60 p-6 rounded-[1.5rem] border border-slate-100 dark:border-slate-800 shadow-inner mb-8">
                        <div class="flex items-center justify-between mb-3">
                            <span class="text-[9px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-widest">Stock Level</span>
                            <span class="text-xs font-black mono text-emerald-600 dark:text-emerald-400" id="pvQty"><%= item.getQuantity() %> <span class="text-[9px] opacity-60 uppercase">Units</span></span>
                        </div>
                        <div class="stock-bar"><div class="stock-fill" id="pvBar" style="width:<%= Math.min(item.getQuantity() * 2, 100) %>%;background:<%= item.getQuantity() > 20 ? "#10b981" : item.getQuantity() > 5 ? "#f59e0b" : "#ef4444" %>"></div></div>
                    </div>

                    <div class="flex items-center justify-between opacity-30 pointer-events-none">
                        <div class="flex items-center bg-white dark:bg-slate-950 border border-slate-100 dark:border-slate-800 rounded-xl p-1">
                            <div class="w-8 h-8 rounded-lg flex items-center justify-center"><i class="fa-solid fa-minus text-[10px]"></i></div>
                            <span class="text-xs font-black w-8 text-center mono">0</span>
                            <div class="w-8 h-8 rounded-lg flex items-center justify-center"><i class="fa-solid fa-plus text-[10px]"></i></div>
                        </div>
                        <div class="flex items-center gap-2">
                            <div class="w-10 h-10 rounded-xl bg-white dark:bg-slate-950 border border-slate-100 dark:border-slate-800 flex items-center justify-center"><i class="fa-solid fa-pen-to-square text-[11px]"></i></div>
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
let selectedCatIcon = '<%= item.getIconName() %>';

function switchTab(tabId) {
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
    
    document.getElementById('tabBtn-' + tabId).classList.add('active');
    document.getElementById('tab-' + tabId).classList.add('active');
}

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

function stepQty(delta) {
    const input = document.getElementById('fQuantity');
    let val = parseInt(input.value) || 0;
    val = Math.max(0, val + delta);
    input.value = val;
    updatePreview();
}

function markUsed() {
    const input = document.getElementById('fQuantity');
    let val = parseInt(input.value) || 0;
    if (val > 0) { 
        input.value = val - 1; 
        updatePreview(); 
        addAuditEntry('Used in Service', val, val - 1, 'red'); 
    }
}

function restock() {
    const input = document.getElementById('fQuantity');
    let val = parseInt(input.value) || 0;
    input.value = val + 10;
    updatePreview();
    addAuditEntry('Restocked +10', val, val + 10, 'emerald');
}

function addAuditEntry(action, oldVal, newVal, color) {
    const trail = document.getElementById('auditTrail');
    const now = new Date().toLocaleTimeString('en-US', {hour:'2-digit', minute:'2-digit'});
    const entry = document.createElement('div');
    entry.className = 'flex items-start gap-3';
    entry.style.animation = 'fadeIn 0.3s ease';
    entry.innerHTML =
        '<div class="timeline-dot bg-' + color + '-500 mt-1.5"></div>' +
        '<div class="flex-1 border-l-2 border-slate-100 dark:border-slate-800 pl-6 pb-6">' +
            '<p class="text-sm font-black text-slate-800 dark:text-slate-200">' + action + '</p>' +
            '<p class="text-[11px] text-slate-400 dark:text-slate-500">' + oldVal + ' → <span class="font-bold text-slate-900 dark:text-white">' + newVal + '</span> units</p>' +
            '<p class="text-[10px] text-slate-400 dark:text-slate-600 mt-1">Admin • ' + now + '</p>' +
        '</div>';
    trail.insertBefore(entry, trail.firstChild);
}

function updatePreview() {
    const id = document.getElementById('fItemId').value;
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
    if (!el.value.trim() && el.id !== 'fQuantity') { // Allow 0 for qty
        el.classList.add('field-error');
        if (errEl) { errEl.textContent = msg; errEl.classList.add('show'); }
    } else if (el.id === 'fQuantity' && el.value === '') {
        el.classList.add('field-error');
        if (errEl) { errEl.textContent = msg; errEl.classList.add('show'); }
    } else {
        el.classList.remove('field-error');
        if (errEl) errEl.classList.remove('show');
    }
}

function validateForm() {
    let valid = true;
    ['fItemName','fQuantity','fPrice'].forEach(id => {
        const el = document.getElementById(id);
        if (el.value === '') { el.classList.add('field-error'); valid = false; }
    });
    return valid;
}
</script>
</body>
</html>
