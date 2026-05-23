<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.ServiceTypeManager, model.ServiceType, java.util.List" %>
<%@ page import="model.ServiceHistoryList, model.ServiceRecord, model.Node, java.net.URLEncoder" %>
<%@ page import="model.FeedbackManager, model.Feedback" %>
<%
    String role = (String) session.getAttribute("userRole");
    if (!"admin".equals(role)) { response.sendRedirect("login.jsp"); return; }

    ServiceHistoryList histList = new ServiceHistoryList();
    histList.loadFromFile();
    histList.sortHistoryByDate();

    FeedbackManager fbMgr = new FeedbackManager();
    List<Feedback> allFb = fbMgr.getAllFeedback();

    int totalRecords = 0; double totalRevenue = 0;
    Node counter = histList.head;
    while (counter != null) { totalRecords++; totalRevenue += counter.data.getCost(); counter = counter.next; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Service Catalog - SwiftDrive</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;700&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Plus Jakarta Sans', sans-serif; }
        .mono { font-family: 'JetBrains Mono', monospace; }
        .stat-card { transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1); }
        .stat-card:hover { transform: translateY(-4px); }
        .view-toggle { transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1); }
        .view-toggle.active { background: #6366f1 !important; color: #fff !important; box-shadow: 0 10px 30px -5px rgba(99, 102, 241, 0.4); border-color: transparent !important; }
        .tbl-row { transition: all 0.3s ease; }
        .tbl-row:hover { background: rgba(99, 102, 241, 0.03) !important; }
        .month-header { background: linear-gradient(90deg, rgba(99, 102, 241, 0.05) 0%, transparent 100%); }
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
                <i class="fa-solid fa-screwdriver-wrench text-indigo-500"></i> Service Catalog
            </h1>
            <p class="mt-3 sm:mt-4 text-sm sm:text-base font-medium text-slate-500 dark:text-slate-400">Configure and manage available service types and pricing.</p>
        </div>
        <button onclick="openAddModal()" class="bg-indigo-600 hover:bg-indigo-700 text-white px-8 sm:px-10 py-4 sm:py-5 rounded-2xl sm:rounded-[2rem] shadow-2xl shadow-indigo-100 dark:shadow-none font-black text-[10px] uppercase tracking-[0.2em] transition-all flex items-center justify-center gap-3 active:scale-95 w-full md:w-auto">
            <i class="fa-solid fa-plus-circle text-base sm:text-lg"></i> Add New Service
        </button>
    </div>

    <!-- ANALYTICS GRID -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 mb-8 sm:mb-12 animate-slide-up">
        <div class="stat-card bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] border border-slate-100 dark:border-slate-800 p-6 sm:p-8 shadow-2xl shadow-slate-200/40 dark:shadow-none relative overflow-hidden group">
            <div class="absolute -right-8 -top-8 w-24 h-24 bg-indigo-500/5 rounded-full blur-2xl group-hover:scale-150 transition-transform"></div>
            <p class="text-[9px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-[0.3em] mb-3 sm:mb-4">Total Logs</p>
            <p class="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white mono tracking-tighter"><%= totalRecords %></p>
            <div class="mt-4 sm:mt-6 flex items-center gap-2 text-[9px] font-black text-indigo-500 uppercase tracking-widest bg-indigo-50 dark:bg-indigo-950 px-4 py-1.5 rounded-xl border border-indigo-100 dark:border-indigo-800/50 w-fit">
                <i class="fa-solid fa-file-invoice"></i> Registry
            </div>
        </div>
        <div class="stat-card bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] border border-slate-100 dark:border-slate-800 p-6 sm:p-8 shadow-2xl shadow-slate-200/40 dark:shadow-none relative overflow-hidden group border-l-4 border-l-emerald-500">
            <div class="absolute -right-8 -top-8 w-24 h-24 bg-emerald-500/5 rounded-full blur-2xl group-hover:scale-150 transition-transform"></div>
            <p class="text-[9px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-[0.3em] mb-3 sm:mb-4">Fiscal</p>
            <p class="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white mono tracking-tighter"><span class="text-xs font-bold mr-1 opacity-30">LKR</span><%= String.format("%,.0f", totalRevenue) %></p>
            <div class="mt-4 sm:mt-6 flex items-center gap-2 text-[9px] font-black text-emerald-500 uppercase tracking-widest bg-emerald-50 dark:bg-emerald-950 px-4 py-1.5 rounded-xl border border-emerald-100 dark:border-emerald-800/50 w-fit">
                <i class="fa-solid fa-coins"></i> Fiscal
            </div>
        </div>
        <div class="stat-card bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] border border-slate-100 dark:border-slate-800 p-6 sm:p-8 shadow-2xl shadow-slate-200/40 dark:shadow-none relative overflow-hidden group border-l-4 border-l-amber-500">
            <div class="absolute -right-8 -top-8 w-24 h-24 bg-amber-500/5 rounded-full blur-2xl group-hover:scale-150 transition-transform"></div>
            <p class="text-[9px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-[0.3em] mb-3 sm:mb-4">User Feedback</p>
            <p class="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white mono tracking-tighter"><%= allFb.size() %></p>
            <div class="mt-4 sm:mt-6 flex items-center gap-2 text-[9px] font-black text-amber-500 uppercase tracking-widest bg-amber-50 dark:bg-amber-950 px-4 py-1.5 rounded-xl border border-amber-100 dark:border-amber-800/50 w-fit">
                <i class="fa-solid fa-star"></i> Feedback
            </div>
        </div>
        <div class="stat-card bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] border border-slate-100 dark:border-slate-800 p-6 sm:p-8 shadow-2xl shadow-slate-200/40 dark:shadow-none relative overflow-hidden group border-l-4 border-l-indigo-500">
            <div class="absolute -right-8 -top-8 w-24 h-24 bg-indigo-500/5 rounded-full blur-2xl group-hover:scale-150 transition-transform"></div>
            <p class="text-[9px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-[0.3em] mb-3 sm:mb-4">Average Cost</p>
            <p class="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white mono tracking-tighter"><span class="text-xs font-bold mr-1 opacity-30">LKR</span><%= totalRecords > 0 ? String.format("%,.0f", totalRevenue / totalRecords) : "0" %></p>
            <div class="mt-4 sm:mt-6 flex items-center gap-2 text-[9px] font-black text-indigo-500 uppercase tracking-widest bg-indigo-50 dark:bg-indigo-950 px-4 py-1.5 rounded-xl border border-indigo-100 dark:border-indigo-800/50 w-fit">
                <i class="fa-solid fa-chart-line"></i> Average
            </div>
        </div>
    </div>

    <!-- CONTROLS -->
    <div class="bg-white dark:bg-slate-900 p-4 sm:p-6 rounded-[2rem] sm:rounded-[3rem] border border-slate-100 dark:border-slate-800 mb-8 sm:mb-12 flex items-center shadow-2xl shadow-slate-200/40 dark:shadow-none animate-slide-up">
        <div class="relative flex-grow group">
            <i class="fa-solid fa-magnifying-glass absolute left-5 sm:left-6 top-1/2 -translate-y-1/2 text-slate-400 dark:text-slate-700 transition-colors group-focus-within:text-indigo-500 text-sm"></i>
            <input type="text" id="searchInput" onkeyup="filterServices()" placeholder="Search services or categories..." class="w-full pl-12 sm:pl-14 pr-6 sm:pr-8 py-3.5 sm:py-4 bg-slate-50 dark:bg-slate-950 border-2 border-transparent dark:border-slate-800 rounded-2xl sm:rounded-[1.5rem] text-xs sm:text-sm font-black text-slate-900 dark:text-white focus:ring-8 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all placeholder:text-slate-200 dark:placeholder:text-slate-800 shadow-inner">
        </div>
    </div>

    <!-- CATALOG -->
    <div id="tableView" class="bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 rounded-2xl overflow-hidden shadow-2xl shadow-slate-200/40 dark:shadow-none animate-slide-up">
        <% if (totalRecords == 0) { %>
        <div class="p-16 sm:p-32 text-center">
            <div class="w-24 h-24 sm:w-32 sm:h-32 rounded-full bg-slate-50 dark:bg-slate-950 flex items-center justify-center mx-auto mb-6 sm:mb-10 shadow-inner">
                <i class="fa-solid fa-layer-group text-slate-300 dark:text-slate-800 text-6xl sm:text-8xl"></i>
            </div>
            <h3 class="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white tracking-tighter mb-4">No Services Configured</h3>
            <p class="text-slate-500 dark:text-slate-400 font-medium text-sm sm:text-lg">Define your first service record to start taking bookings.</p>
        </div>
        <% } else { %>

        <!-- DESKTOP TABLE VIEW -->
        <div class="hidden md:block overflow-x-auto">
            <table class="w-full border-collapse" id="serviceTable">
                <thead>
                    <tr class="bg-slate-950 text-white text-[9px] font-black uppercase border-b border-slate-800">
                        <th class="w-[45%] px-6 lg:px-8 py-5 text-left tracking-[0.3em]">Service Name</th>
                        <th class="w-[20%] px-6 lg:px-8 py-5 text-left tracking-[0.3em]">Category</th>
                        <th class="w-[20%] px-6 lg:px-8 py-5 text-right tracking-[0.3em]">Base Price</th>
                        <th class="w-[15%] px-6 lg:px-8 py-5 text-center tracking-[0.3em]">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-50 dark:divide-slate-800">
                    <% ServiceTypeManager stm = new ServiceTypeManager();
                       List<ServiceType> services = stm.getAllServices();
                       for (ServiceType s : services) { %>
                    <tr class="tbl-row service-row group transition-colors" data-name="<%= s.getServiceName().toLowerCase() %>" data-cat="<%= s.getCategory().toLowerCase() %>">
                        <td class="w-[45%] px-6 lg:px-8 py-5 text-base font-black text-slate-900 dark:text-white tracking-tight break-words"><%= s.getServiceName() %></td>
                        <td class="w-[20%] px-6 lg:px-8 py-5">
                            <span class="mono text-[10px] font-black text-indigo-600 dark:text-indigo-400 bg-indigo-50 dark:bg-indigo-950 border border-indigo-100 dark:border-indigo-800/50 px-3 py-1 rounded-xl uppercase tracking-widest shadow-inner"><%= s.getCategory() %></span>
                        </td>
                        <td class="w-[20%] px-6 lg:px-8 py-5 text-right whitespace-nowrap">
                            <span class="text-[10px] font-black text-slate-400 dark:text-slate-700 mr-1">LKR</span>
                            <span class="text-lg font-black text-slate-900 dark:text-white mono tracking-tighter"><%= String.format("%,.0f", s.getDefaultBasePrice()) %></span>
                        </td>
                        <td class="w-[15%] px-6 lg:px-8 py-5 text-center">
                            <div class="flex items-center justify-center gap-3">
                                <button onclick="openEditModal('<%= s.getServiceName().replace("'","\\\\\'") %>', '<%= s.getCategory() %>', <%= s.getDefaultBasePrice() %>)" 
                                   class="w-10 h-10 rounded-xl bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-800 text-slate-400 dark:text-slate-700 hover:text-indigo-600 dark:hover:text-indigo-400 flex items-center justify-center transition-all shadow-sm active:scale-90" title="Edit Service">
                                    <i class="fa-solid fa-pen-nib text-xs"></i>
                                </button>
                                <a href="#" 
                                   onclick="event.preventDefault(); openDeleteModal('<%= URLEncoder.encode(s.getServiceName(), "UTF-8") %>', '<%= s.getServiceName().replace("'", "\\\\'") %>')"
                                   class="w-10 h-10 rounded-xl bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-800 text-slate-400 dark:text-slate-700 hover:text-rose-600 dark:hover:text-rose-400 flex items-center justify-center transition-all shadow-sm active:scale-90" title="Delete Service">
                                    <i class="fa-solid fa-trash-can text-xs"></i>
                                </a>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>

        <!-- MOBILE CARD VIEW -->
        <div class="block md:hidden p-4 space-y-4">
            <% for (ServiceType s : services) { %>
            <div class="service-card p-5 bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-800 rounded-2xl space-y-4" data-name="<%= s.getServiceName().toLowerCase() %>" data-cat="<%= s.getCategory().toLowerCase() %>">
                <div class="flex justify-between items-center">
                    <span class="mono text-[9px] font-black text-indigo-600 dark:text-indigo-400 bg-indigo-50 dark:bg-indigo-950 border border-indigo-100 dark:border-indigo-800/50 px-3 py-1 rounded-xl uppercase tracking-widest shadow-inner"><%= s.getCategory() %></span>
                </div>
                <div>
                    <p class="text-[9px] font-black text-slate-500 dark:text-slate-600 uppercase tracking-[0.3em] mb-1">Service Name</p>
                    <h4 class="text-base font-black text-slate-900 dark:text-white tracking-tight"><%= s.getServiceName() %></h4>
                </div>
                <div class="flex justify-between items-end pt-2 border-t border-slate-100 dark:border-slate-800">
                    <div>
                        <p class="text-[9px] font-black text-slate-500 dark:text-slate-600 uppercase tracking-[0.3em] mb-1">Base Price</p>
                        <div class="flex items-baseline">
                            <span class="text-[10px] font-black text-slate-400 dark:text-slate-700 mr-1">LKR</span>
                            <span class="text-lg font-black text-slate-900 dark:text-white mono tracking-tighter"><%= String.format("%,.0f", s.getDefaultBasePrice()) %></span>
                        </div>
                    </div>
                    <div class="flex items-center gap-2">
                        <button onclick="openEditModal('<%= s.getServiceName().replace("'","\\\\\'") %>', '<%= s.getCategory() %>', <%= s.getDefaultBasePrice() %>)" 
                           class="w-10 h-10 rounded-xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 text-slate-400 dark:text-slate-700 hover:text-indigo-600 dark:hover:text-indigo-400 flex items-center justify-center transition-all shadow-sm active:scale-95" title="Edit Service">
                            <i class="fa-solid fa-pen-nib text-xs"></i>
                        </button>
                        <a href="#" 
                           onclick="event.preventDefault(); openDeleteModal('<%= URLEncoder.encode(s.getServiceName(), "UTF-8") %>', '<%= s.getServiceName().replace("'", "\\\\'") %>')"
                           class="w-10 h-10 rounded-xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 text-slate-400 dark:text-slate-700 hover:text-rose-600 dark:hover:text-rose-400 flex items-center justify-center transition-all shadow-sm active:scale-95" title="Delete Service">
                            <i class="fa-solid fa-trash-can text-xs"></i>
                        </a>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
        <% } %>
    </div>
</div>

<!-- ADD/EDIT MODAL -->
<div id="modal" class="fixed inset-0 z-50 hidden flex items-center justify-center p-4 sm:p-6">
    <div id="backdrop" class="absolute inset-0 bg-slate-900/50 backdrop-blur-sm opacity-0 transition-opacity" onclick="closeModal()"></div>
    <div id="modalContent" class="bg-white dark:bg-slate-900 w-full max-w-lg p-6 sm:p-10 rounded-[2rem] sm:rounded-[3rem] shadow-2xl relative opacity-0 scale-95 transition-all max-h-[calc(100vh-2rem)] sm:max-h-[90vh] flex flex-col">
        <h3 class="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white tracking-tighter" id="modalTitle">Add Service</h3>
        <p class="text-xs sm:text-sm font-medium text-slate-500 dark:text-slate-400 mt-2 leading-relaxed">Configure the service details below.</p>
        <form action="AddServiceTypeServlet" method="POST" id="serviceForm" class="mt-6 sm:mt-8 text-left space-y-4 sm:space-y-6 flex-1 overflow-y-auto pr-1 custom-scrollbar">
            <input type="hidden" name="action" id="formAction" value="add">
            <div>
                <label class="block text-[9px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-widest mb-2 sm:mb-3">Service Name</label>
                <input type="text" name="name" id="serviceName" required class="w-full px-4 sm:px-6 py-3 sm:py-4 bg-slate-50 dark:bg-slate-950 border-2 border-transparent dark:border-slate-800 rounded-2xl text-xs sm:text-sm font-black focus:ring-8 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white shadow-inner">
            </div>
            <div>
                <label class="block text-[9px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-widest mb-2 sm:mb-3">Category</label>
                <select name="category" id="serviceCategory" class="w-full px-4 sm:px-6 py-3 sm:py-4 bg-slate-50 dark:bg-slate-955 border-2 border-transparent dark:border-slate-800 rounded-2xl text-xs sm:text-sm font-black focus:ring-8 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white shadow-inner">
                    <option value="Maintenance">Maintenance</option>
                    <option value="Repair">Repair</option>
                    <option value="Diagnostic">Diagnostic</option>
                    <option value="Cleaning">Cleaning</option>
                </select>
            </div>
            <div>
                <label class="block text-[9px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-widest mb-2 sm:mb-3">Price (LKR)</label>
                <input type="number" name="price" id="servicePrice" required class="w-full px-4 sm:px-6 py-3 sm:py-4 bg-slate-50 dark:bg-slate-950 border-2 border-transparent dark:border-slate-800 rounded-2xl text-xs sm:text-sm font-black focus:ring-8 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white shadow-inner">
            </div>
            <button type="submit" class="w-full py-3.5 sm:py-5 rounded-2xl bg-indigo-600 hover:bg-indigo-700 text-white font-black text-[10px] uppercase tracking-[0.2em] shadow-2xl shadow-indigo-100 dark:shadow-none transition-all active:scale-95 flex items-center justify-center gap-3 sm:gap-4">
                <i class="fa-solid fa-plus-circle text-base sm:text-lg"></i> Save Service
            </button>
        </form>
    </div>
</div>

<!-- DELETE CONFIRMATION MODAL -->
<div id="deleteModal" class="hidden fixed inset-0 z-[200] flex items-center justify-center p-4 sm:p-6">
    <div class="absolute inset-0 bg-slate-950/80 backdrop-blur-xl opacity-0 transition-opacity duration-300" id="deleteBackdrop" onclick="closeDeleteModal()"></div>
    <div class="relative bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] shadow-2xl max-w-sm w-full border border-slate-100 dark:border-slate-800 overflow-y-auto max-h-[calc(100vh-2rem)] sm:max-h-[90vh] custom-scrollbar transform scale-95 opacity-0 transition-all duration-300" id="deletePanel">
        <div class="p-6 sm:p-10 md:p-12 text-center">
            <div class="w-16 h-16 sm:w-24 sm:h-24 rounded-[1.5rem] sm:rounded-[2rem] bg-rose-50 dark:bg-rose-950 flex items-center justify-center mx-auto mb-6 sm:mb-10 text-rose-500 shadow-inner border border-rose-100 dark:border-rose-900/30">
                <i class="fa-solid fa-trash-can text-2xl sm:text-4xl"></i>
            </div>
            <h3 class="text-xl sm:text-2xl md:text-3xl font-black text-slate-900 dark:text-white tracking-tighter">Remove Service?</h3>
            <p class="text-xs sm:text-sm font-medium text-slate-500 dark:text-slate-400 mt-3 sm:mt-4 leading-relaxed">
                Are you sure you want to remove <span id="deleteItemDisplay" class="font-bold text-slate-900 dark:text-white"></span> from the catalog?
            </p>
            
            <div class="flex flex-col gap-3 sm:gap-4 mt-6 sm:mt-10">
                <a id="confirmDeleteBtn" href="#" class="w-full py-3.5 sm:py-5 rounded-xl sm:rounded-2xl bg-rose-600 hover:bg-rose-700 text-white font-black text-[10px] uppercase tracking-[0.2em] shadow-2xl shadow-rose-100 dark:shadow-none transition-all active:scale-95 flex items-center justify-center gap-3 sm:gap-4">
                    <i class="fa-solid fa-trash-can text-base sm:text-lg"></i> Confirm & Remove
                </a>
                <button type="button" onclick="closeDeleteModal()" class="w-full py-3.5 sm:py-5 rounded-xl sm:rounded-2xl bg-white dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 text-slate-400 dark:text-slate-700 font-black text-[10px] uppercase tracking-[0.2em] hover:bg-slate-50 dark:hover:bg-slate-800 transition-all">
                    Cancel
                </button>
            </div>
        </div>
    </div>
</div>
<script>
document.addEventListener("DOMContentLoaded", () => {
    const params = new URLSearchParams(window.location.search);
    if (params.get("success") === "added") showToast("Service type added successfully.", "success");
    if (params.get("success") === "updated") showToast("Service details updated.", "success");
    if (params.get("success") === "deleted") showToast("Service removed from catalog.", "success");
});

function openAddModal() {
    document.getElementById('modalTitle').textContent = 'Add Service';
    document.getElementById('formAction').value = 'add';
    document.getElementById('serviceForm').reset();
    const m = document.getElementById('modal');
    const b = document.getElementById('backdrop');
    const c = document.getElementById('modalContent');
    m.classList.remove('hidden');
    setTimeout(() => { b.classList.add('opacity-100'); c.classList.add('opacity-100', 'scale-100'); }, 20);
}

function openEditModal(name, category, price) {
    document.getElementById('modalTitle').textContent = 'Edit Service';
    document.getElementById('formAction').value = 'edit';
    document.getElementById('serviceName').value = name;
    document.getElementById('serviceCategory').value = category;
    document.getElementById('servicePrice').value = price;
    const m = document.getElementById('modal');
    const b = document.getElementById('backdrop');
    const c = document.getElementById('modalContent');
    m.classList.remove('hidden');
    setTimeout(() => { b.classList.add('opacity-100'); c.classList.add('opacity-100', 'scale-100'); }, 20);
}

function closeModal() {
    const b = document.getElementById('backdrop');
    const c = document.getElementById('modalContent');
    b.classList.remove('opacity-100'); c.classList.remove('opacity-100', 'scale-100');
    setTimeout(() => document.getElementById('modal').classList.add('hidden'), 300);
}

function filterServices() {
    const q = document.getElementById('searchInput').value.toLowerCase();
    
    // Filter desktop rows
    document.querySelectorAll('.service-row').forEach(row => {
        const name = row.getAttribute('data-name') || '';
        const cat = row.getAttribute('data-cat') || '';
        row.style.display = (name.includes(q) || cat.includes(q)) ? '' : 'none';
    });

    // Filter mobile cards
    document.querySelectorAll('.service-card').forEach(card => {
        const name = card.getAttribute('data-name') || '';
        const cat = card.getAttribute('data-cat') || '';
        card.style.display = (name.includes(q) || cat.includes(q)) ? '' : 'none';
    });
}

function openDeleteModal(encodedName, displayName) {
    const m = document.getElementById('deleteModal');
    const b = document.getElementById('deleteBackdrop');
    const p = document.getElementById('deletePanel');
    const btn = document.getElementById('confirmDeleteBtn');
    const display = document.getElementById('deleteItemDisplay');
    
    display.textContent = displayName;
    btn.href = 'DeleteServiceTypeServlet?name=' + encodedName;
    
    m.classList.remove('hidden');
    document.body.style.overflow = 'hidden';
    setTimeout(() => { b.style.opacity='1'; p.classList.remove('scale-95', 'opacity-0'); p.classList.add('scale-100', 'opacity-100'); }, 20);
}

function closeDeleteModal() {
    const b = document.getElementById('deleteBackdrop');
    const p = document.getElementById('deletePanel');
    b.style.opacity='0'; p.classList.remove('scale-100', 'opacity-100'); p.classList.add('scale-95', 'opacity-0');
    document.body.style.overflow = 'auto';
    setTimeout(() => document.getElementById('deleteModal').classList.add('hidden'), 300);
}
</script>
</body>
</html>
