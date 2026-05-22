<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.ServiceHistoryList, model.ServiceRecord, model.Node, java.net.URLEncoder" %>
<%
    // SECURITY CHECK: Admin only
    String role = (String) session.getAttribute("userRole");
    if (!"admin".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Load service history list
    ServiceHistoryList list = (ServiceHistoryList) session.getAttribute("serviceList");
    if (list == null) {
        list = new ServiceHistoryList();
        list.loadFromFile();
        session.setAttribute("serviceList", list);
    }
    list.sortHistoryByDate();

    // Calculate KPI stats
    int totalRecords = 0;
    double totalRevenue = 0;
    double highestCost = 0;
    String mostRecentDate = "—";
    Node statsNode = list.head;
    while (statsNode != null) {
        totalRecords++;
        double cost = statsNode.data.getCost();
        totalRevenue += cost;
        if (cost > highestCost) highestCost = cost;
        if (totalRecords == 1) mostRecentDate = statsNode.data.getDate();
        statsNode = statsNode.next;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - SwiftDrive</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;700&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Plus Jakarta Sans', sans-serif; }
        .mono { font-family: 'JetBrains Mono', monospace; }
        .stat-card { transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1); }
        .stat-card:hover { transform: translateY(-4px); }
        .svc-row { transition: all 0.3s ease; }
        .svc-row:hover { background: rgba(99, 102, 241, 0.03) !important; }
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
                <i class="fa-solid fa-chart-pie text-indigo-500"></i> Admin Dashboard
            </h1>
            <p class="mt-3 sm:mt-4 text-sm sm:text-base font-medium text-slate-600 dark:text-slate-400">Overview of service history and business analytics.</p>
        </div>
        <a href="addService.jsp" class="bg-indigo-600 hover:bg-indigo-700 text-white px-8 sm:px-10 py-4 sm:py-5 rounded-2xl sm:rounded-[2rem] shadow-2xl shadow-indigo-100 dark:shadow-none font-black text-[10px] uppercase tracking-[0.2em] transition-all flex items-center justify-center gap-3 active:scale-95 w-full md:w-auto">
            <i class="fa-solid fa-plus-circle text-base sm:text-lg"></i> Add Service Record
        </a>
    </div>

    <!-- KPI STRIP -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 mb-8 sm:mb-12 animate-slide-up">
        <div class="stat-card bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] border border-slate-100 dark:border-slate-800 p-6 sm:p-8 shadow-2xl shadow-slate-200/40 dark:shadow-none relative overflow-hidden group">
            <div class="absolute -right-8 -top-8 w-24 h-24 bg-indigo-500/5 rounded-full blur-2xl group-hover:scale-150 transition-transform"></div>
            <p class="text-[9px] font-black text-slate-500 dark:text-slate-600 uppercase tracking-[0.3em] mb-3 sm:mb-4">Total Records</p>
            <p class="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white mono tracking-tighter"><%= totalRecords %></p>
            <div class="mt-4 sm:mt-6 flex items-center gap-2 text-[9px] font-black text-indigo-500 uppercase tracking-widest bg-indigo-50 dark:bg-indigo-950 px-4 py-1.5 rounded-xl border border-indigo-100 dark:border-indigo-800/50 w-fit">
                <i class="fa-solid fa-clipboard-list"></i> Total Logs
            </div>
        </div>
        <div class="stat-card bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] border border-slate-100 dark:border-slate-800 p-6 sm:p-8 shadow-2xl shadow-slate-200/40 dark:shadow-none relative overflow-hidden group">
            <div class="absolute -right-8 -top-8 w-24 h-24 bg-amber-500/5 rounded-full blur-2xl group-hover:scale-150 transition-transform"></div>
            <p class="text-[9px] font-black text-slate-500 dark:text-slate-600 uppercase tracking-[0.3em] mb-3 sm:mb-4">Last Service</p>
            <p class="text-lg sm:text-xl font-black text-slate-900 dark:text-white mono tracking-tighter"><%= mostRecentDate %></p>
            <div class="mt-4 sm:mt-6 flex items-center gap-2 text-[9px] font-black text-amber-500 uppercase tracking-widest bg-amber-50 dark:bg-amber-950 px-4 py-1.5 rounded-xl border border-amber-100 dark:border-amber-800/50 w-fit">
                <i class="fa-solid fa-calendar-day"></i> Recent
            </div>
        </div>
        <div class="stat-card bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] border border-slate-100 dark:border-slate-800 p-6 sm:p-8 shadow-2xl shadow-slate-200/40 dark:shadow-none relative overflow-hidden group border-l-4 border-l-rose-500">
            <div class="absolute -right-8 -top-8 w-24 h-24 bg-rose-500/5 rounded-full blur-2xl group-hover:scale-150 transition-transform"></div>
            <p class="text-[9px] font-black text-slate-500 dark:text-slate-600 uppercase tracking-[0.3em] mb-3 sm:mb-4">Highest Price</p>
            <p class="text-xl sm:text-2xl font-black text-slate-900 dark:text-white mono tracking-tighter"><span class="text-xs font-bold mr-1 opacity-30">LKR</span><%= String.format("%,.0f", highestCost) %></p>
            <div class="mt-4 sm:mt-6 flex items-center gap-2 text-[9px] font-black text-rose-500 uppercase tracking-widest bg-rose-50 dark:bg-rose-950 px-4 py-1.5 rounded-xl border border-rose-100 dark:border-rose-800/50 w-fit">
                <i class="fa-solid fa-arrow-up-right-dots"></i> Max Cost
            </div>
        </div>
        <div class="stat-card bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] border border-slate-100 dark:border-slate-800 p-6 sm:p-8 shadow-2xl shadow-slate-200/40 dark:shadow-none relative overflow-hidden group border-l-4 border-l-emerald-500">
            <div class="absolute -right-8 -top-8 w-24 h-24 bg-emerald-500/5 rounded-full blur-2xl group-hover:scale-150 transition-transform"></div>
            <p class="text-[9px] font-black text-slate-500 dark:text-slate-600 uppercase tracking-[0.3em] mb-3 sm:mb-4">Total Revenue</p>
            <p class="text-xl sm:text-2xl font-black text-emerald-600 dark:text-emerald-400 mono tracking-tighter"><span class="text-xs font-bold mr-1 opacity-30">LKR</span><%= String.format("%,.0f", totalRevenue) %></p>
            <div class="mt-4 sm:mt-6 flex items-center gap-2 text-[9px] font-black text-emerald-500 uppercase tracking-widest bg-emerald-50 dark:bg-emerald-950 px-4 py-1.5 rounded-xl border border-emerald-100 dark:border-emerald-800/50 w-fit">
                <i class="fa-solid fa-coins"></i> Total
            </div>
        </div>
    </div>

    <!-- UTILITY BAR -->
    <div class="bg-white dark:bg-slate-900 p-4 sm:p-6 rounded-[2rem] sm:rounded-[3rem] border border-slate-100 dark:border-slate-800 mb-8 sm:mb-12 flex items-center shadow-2xl shadow-slate-200/40 dark:shadow-none animate-slide-up">
        <div class="relative flex-grow group">
            <i class="fa-solid fa-magnifying-glass absolute left-5 sm:left-6 top-1/2 -translate-y-1/2 text-slate-400 dark:text-slate-700 transition-colors group-focus-within:text-indigo-500 text-sm"></i>
            <input type="text" id="searchInput" onkeyup="filterTable()" placeholder="Search by license plate or service type..." class="w-full pl-12 sm:pl-14 pr-6 sm:pr-8 py-3.5 sm:py-4 bg-slate-50 dark:bg-slate-950 border-2 border-transparent dark:border-slate-800 rounded-2xl sm:rounded-[1.5rem] text-xs sm:text-sm font-black text-slate-900 dark:text-white focus:ring-8 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all placeholder:text-slate-200 dark:placeholder:text-slate-800 shadow-inner">
        </div>
    </div>

    <!-- SERVICE HISTORY -->
    <div class="bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 rounded-2xl overflow-hidden shadow-2xl shadow-slate-200/40 dark:shadow-none animate-slide-up">
        <% Node current = list.head; if (current == null) { %>
        <div class="p-16 sm:p-32 text-center">
            <div class="w-24 h-24 sm:w-32 sm:h-32 rounded-full bg-slate-50 dark:bg-slate-950 flex items-center justify-center mx-auto mb-6 sm:mb-10 shadow-inner">
                <i class="fa-solid fa-inbox text-slate-300 dark:text-slate-800 text-6xl sm:text-8xl"></i>
            </div>
            <h3 class="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white tracking-tighter mb-4">No records found</h3>
            <p class="text-slate-500 dark:text-slate-400 font-medium text-sm sm:text-lg">There are no service history entries in the database.</p>
        </div>
        <% } else { %>
        
        <!-- DESKTOP TABLE VIEW -->
        <div class="hidden md:block overflow-x-auto">
            <table class="w-full border-collapse" id="historyTable">
                <thead>
                    <tr class="bg-slate-950 text-white text-[9px] font-black uppercase border-b border-slate-800">
                        <th class="w-[15%] px-6 lg:px-8 py-5 text-left tracking-[0.3em]">Date</th>
                        <th class="w-[15%] px-6 lg:px-8 py-5 text-left tracking-[0.3em]">Vehicle Plate</th>
                        <th class="w-[45%] px-6 lg:px-8 py-5 text-left tracking-[0.3em]">Service Type</th>
                        <th class="w-[15%] px-6 lg:px-8 py-5 text-right tracking-[0.3em]">Cost</th>
                        <th class="w-[10%] px-6 lg:px-8 py-5 text-center tracking-[0.3em]">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-50 dark:divide-slate-800">
                    <% 
                        Node desktopCurrent = list.head;
                        while (desktopCurrent != null) {
                            String displayPlate = (desktopCurrent.data.getLicensePlate() != null) ? desktopCurrent.data.getLicensePlate() : "Unknown";
                            String encDate = URLEncoder.encode(desktopCurrent.data.getDate(), "UTF-8");
                            String encPlate = URLEncoder.encode(displayPlate, "UTF-8");
                            String encType = URLEncoder.encode(desktopCurrent.data.getServiceType(), "UTF-8");
                            String encCost = String.valueOf(desktopCurrent.data.getCost());
                    %>
                    <tr class="svc-row group transition-colors" data-plate="<%= displayPlate.toLowerCase() %>" data-type="<%= desktopCurrent.data.getServiceType().toLowerCase() %>">
                        <td class="w-[15%] px-6 lg:px-8 py-5 text-sm font-black text-slate-700 dark:text-slate-400 mono tracking-tighter">
                            <i class="fa-regular fa-calendar text-indigo-500 mr-2"></i><%= desktopCurrent.data.getDate() %>
                        </td>
                        <td class="w-[15%] px-6 lg:px-8 py-5">
                            <span class="mono text-[10px] font-black text-indigo-600 dark:text-indigo-400 bg-indigo-50 dark:bg-indigo-950 border border-indigo-100 dark:border-indigo-800/50 px-3 py-1 rounded-xl uppercase tracking-widest shadow-inner"><%= displayPlate %></span>
                        </td>
                        <td class="w-[45%] px-6 lg:px-8 py-5 text-base font-black text-slate-900 dark:text-white tracking-tight break-words">
                            <%= desktopCurrent.data.getServiceType() %>
                        </td>
                        <td class="w-[15%] px-6 lg:px-8 py-5 text-right whitespace-nowrap">
                            <span class="text-[10px] font-black text-slate-400 dark:text-slate-700 mr-1">LKR</span>
                            <span class="text-lg font-black text-slate-900 dark:text-white mono tracking-tighter"><%= String.format("%,.2f", desktopCurrent.data.getCost()) %></span>
                        </td>
                        <td class="w-[10%] px-6 lg:px-8 py-5 text-center">
                            <div class="flex items-center justify-center gap-3">
                                <a href="editService.jsp?date=<%= encDate %>&plate=<%= encPlate %>&type=<%= encType %>&cost=<%= encCost %>" 
                                   class="w-10 h-10 rounded-xl bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-800 text-slate-400 dark:text-slate-700 hover:text-indigo-600 dark:hover:text-indigo-400 flex items-center justify-center transition-all shadow-sm active:scale-90" title="Edit Record">
                                    <i class="fa-solid fa-pen-nib text-xs"></i>
                                </a>
                                <a href="DeleteServiceServlet?date=<%= encDate %>&type=<%= encType %>&plate=<%= encPlate %>" 
                                   class="w-10 h-10 rounded-xl bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-800 text-slate-400 dark:text-slate-700 hover:text-rose-600 dark:hover:text-rose-400 flex items-center justify-center transition-all shadow-sm active:scale-90" title="Delete Record">
                                    <i class="fa-solid fa-trash-can text-xs"></i>
                                </a>
                            </div>
                        </td>
                    </tr>
                    <% desktopCurrent = desktopCurrent.next; } %>
                </tbody>
            </table>
        </div>

        <!-- MOBILE CARD VIEW -->
        <div class="block md:hidden p-4 space-y-4">
            <% 
                Node mobileCurrent = list.head;
                while (mobileCurrent != null) {
                    String displayPlate = (mobileCurrent.data.getLicensePlate() != null) ? mobileCurrent.data.getLicensePlate() : "Unknown";
                    String encDate = URLEncoder.encode(mobileCurrent.data.getDate(), "UTF-8");
                    String encPlate = URLEncoder.encode(displayPlate, "UTF-8");
                    String encType = URLEncoder.encode(mobileCurrent.data.getServiceType(), "UTF-8");
                    String encCost = String.valueOf(mobileCurrent.data.getCost());
            %>
            <div class="svc-card p-5 bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-800 rounded-2xl space-y-4" data-plate="<%= displayPlate.toLowerCase() %>" data-type="<%= mobileCurrent.data.getServiceType().toLowerCase() %>">
                <div class="flex justify-between items-center">
                    <span class="mono text-[9px] font-black text-indigo-600 dark:text-indigo-400 bg-indigo-50 dark:bg-indigo-950 border border-indigo-100 dark:border-indigo-800/50 px-3 py-1 rounded-xl uppercase tracking-widest shadow-inner"><%= displayPlate %></span>
                    <span class="text-xs font-bold text-slate-500 dark:text-slate-400 mono">
                        <i class="fa-regular fa-calendar text-indigo-500 mr-1.5"></i><%= mobileCurrent.data.getDate() %>
                    </span>
                </div>
                <div>
                    <p class="text-[9px] font-black text-slate-500 dark:text-slate-600 uppercase tracking-[0.3em] mb-1">Service Type</p>
                    <h4 class="text-base font-black text-slate-900 dark:text-white tracking-tight"><%= mobileCurrent.data.getServiceType() %></h4>
                </div>
                <div class="flex justify-between items-end pt-2 border-t border-slate-100 dark:border-slate-800">
                    <div>
                        <p class="text-[9px] font-black text-slate-500 dark:text-slate-600 uppercase tracking-[0.3em] mb-1">Price</p>
                        <div class="flex items-baseline">
                            <span class="text-[10px] font-black text-slate-400 dark:text-slate-700 mr-1">LKR</span>
                            <span class="text-lg font-black text-slate-900 dark:text-white mono tracking-tighter"><%= String.format("%,.2f", mobileCurrent.data.getCost()) %></span>
                        </div>
                    </div>
                    <div class="flex items-center gap-2">
                        <a href="editService.jsp?date=<%= encDate %>&plate=<%= encPlate %>&type=<%= encType %>&cost=<%= encCost %>" 
                           class="w-10 h-10 rounded-xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 text-slate-400 dark:text-slate-700 hover:text-indigo-600 dark:hover:text-indigo-400 flex items-center justify-center transition-all shadow-sm active:scale-95" title="Edit Record">
                            <i class="fa-solid fa-pen-nib text-xs"></i>
                        </a>
                        <a href="DeleteServiceServlet?date=<%= encDate %>&type=<%= encType %>&plate=<%= encPlate %>" 
                           class="w-10 h-10 rounded-xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 text-slate-400 dark:text-slate-700 hover:text-rose-600 dark:hover:text-rose-400 flex items-center justify-center transition-all shadow-sm active:scale-95" title="Delete Record">
                            <i class="fa-solid fa-trash-can text-xs"></i>
                        </a>
                    </div>
                </div>
            </div>
            <% mobileCurrent = mobileCurrent.next; } %>
        </div>
        <% } %>
    </div>
</div>

<%@ include file="toast.jsp" %>
<script>
function filterTable() {
    const q = document.getElementById('searchInput').value.toLowerCase();
    
    // Filter desktop rows
    document.querySelectorAll('.svc-row').forEach(row => {
        const plate = row.getAttribute('data-plate') || '';
        const type = row.getAttribute('data-type') || '';
        row.style.display = (plate.includes(q) || type.includes(q)) ? '' : 'none';
    });

    // Filter mobile cards
    document.querySelectorAll('.svc-card').forEach(card => {
        const plate = card.getAttribute('data-plate') || '';
        const type = card.getAttribute('data-type') || '';
        card.style.display = (plate.includes(q) || type.includes(q)) ? '' : 'none';
    });
}
</script>
</body>
</html>