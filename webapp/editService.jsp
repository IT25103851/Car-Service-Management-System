<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="navbar.jsp" %>
<%@ page import="model.ServiceTypeManager, model.ServiceType, java.util.List" %>
<%
    String oldDate = request.getParameter("date");
    String oldType = request.getParameter("type");
    String oldCost = request.getParameter("cost");
    String targetPlate = request.getParameter("plate");

    if (oldDate == null || oldType == null) { response.sendRedirect("manage_services.jsp"); return; }
    
    ServiceTypeManager stm = new ServiceTypeManager();
    List<ServiceType> sTypes = stm.getAllServices();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Service - SwiftDrive</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Plus Jakarta Sans', sans-serif; }
        .modified { border-left: 3px solid #4f46e5 !important; }
        .mod-badge { display: none; }
        .modified ~ .mod-badge, .modified + .mod-badge { display: inline-flex; }
        
        /* Flatpickr Customization */
        .flatpickr-calendar {
            background: #ffffff !important;
            border-radius: 1.5rem !important;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1) !important;
            border: 1px solid #f1f5f9 !important;
        }
        .dark .flatpickr-calendar {
            background: #1e293b !important;
            border: 1px solid #334155 !important;
            box-shadow: none !important;
        }
        .flatpickr-months .flatpickr-month {
            background: transparent !important;
            color: inherit !important;
            fill: inherit !important;
        }
        .flatpickr-current-month {
            font-weight: 800 !important;
            color: #4f46e5 !important;
        }
        .dark .flatpickr-current-month {
            color: #818cf8 !important;
        }
        .flatpickr-months .flatpickr-prev-month, .flatpickr-months .flatpickr-next-month {
            color: #6366f1 !important;
            fill: #6366f1 !important;
        }
        .flatpickr-day.selected {
            background: #4f46e5 !important;
            border-color: #4f46e5 !important;
            border-radius: 10px !important;
        }
    </style>
    <!-- Flatpickr -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/airbnb.css">
</head>
<body class="antialiased text-slate-900 dark:text-slate-100 bg-slate-50 dark:bg-slate-950 transition-colors duration-300 pt-28 pb-16">

<div class="max-w-2xl mx-auto px-4">
    <a href="dashboard.jsp" class="text-sm font-bold text-slate-500 dark:text-slate-400 hover:text-amber-600 dark:hover:text-amber-500 transition mb-4 inline-block"><i class="fa-solid fa-arrow-left mr-1"></i> Back to Dashboard</a>
    <h1 class="text-3xl font-black text-slate-900 dark:text-white tracking-tighter mb-8 flex items-center gap-4">
        <div class="w-10 h-10 rounded-xl bg-amber-500/10 flex items-center justify-center text-amber-600">
            <i class="fa-solid fa-pen-to-square"></i>
        </div>
        Edit Service Record
    </h1>

    <!-- BEFORE SNAPSHOT -->
    <div class="bg-slate-100 dark:bg-slate-900/50 rounded-2xl border border-slate-200 dark:border-slate-800 p-6 mb-8 shadow-sm">
        <div class="flex items-center gap-3 mb-5">
            <span class="text-[9px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest bg-slate-200 dark:bg-slate-800 px-3 py-1 rounded-lg">Original</span>
            <span class="text-[10px] font-medium text-slate-400 dark:text-slate-600 tracking-wide">Current record values</span>
        </div>
        <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
            <div>
                <p class="text-[9px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mb-1.5">Vehicle</p>
                <p class="text-xs font-black text-slate-600 dark:text-slate-300 mono"><%= targetPlate %></p>
            </div>
            <div>
                <p class="text-[9px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mb-1.5">Date</p>
                <p class="text-xs font-black text-slate-600 dark:text-slate-300"><%= oldDate %></p>
            </div>
            <div>
                <p class="text-[9px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mb-1.5">Service Type</p>
                <p class="text-xs font-black text-slate-600 dark:text-slate-300"><%= oldType %></p>
            </div>
            <div>
                <p class="text-[9px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mb-1.5">Cost</p>
                <p class="text-xs font-black text-slate-600 dark:text-slate-300 mono">LKR <%= oldCost %></p>
            </div>
        </div>
    </div>

    <!-- EDIT FORM -->
    <div class="bg-white dark:bg-slate-900 rounded-[2.5rem] border border-slate-200 dark:border-slate-800 p-10 shadow-2xl shadow-slate-200/40 dark:shadow-none">
        <div class="flex items-center gap-3 mb-8">
            <span class="text-[9px] font-black text-amber-600 uppercase tracking-widest bg-amber-50 dark:bg-amber-900/20 px-3 py-1 rounded-lg">Updated</span>
            <span class="text-[10px] font-medium text-slate-400 dark:text-slate-600 tracking-wide">Edit fields below — modified fields are highlighted</span>
        </div>

        <form action="UpdateServiceServlet" method="POST" class="space-y-4">
            <input type="hidden" name="oldDate" value="<%= oldDate %>">
            <input type="hidden" name="oldType" value="<%= oldType %>">
            <input type="hidden" name="targetPlate" value="<%= targetPlate %>">

            <!-- Vehicle (locked) -->
            <div>
                <label class="block text-[9px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mb-3">Vehicle (Immutable)</label>
                <div class="px-6 py-4 bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-800 rounded-2xl text-sm text-slate-400 dark:text-slate-600 font-black mono flex items-center gap-3 shadow-inner">
                    <i class="fa-solid fa-lock text-xs"></i> <%= targetPlate %>
                </div>
            </div>

            <div class="relative group">
                <label class="block text-[9px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mb-3">Date of Service</label>
                <div class="relative">
                    <i class="fa-solid fa-calendar absolute left-6 top-1/2 -translate-y-1/2 text-slate-400 dark:text-slate-700 pointer-events-none transition-colors group-focus-within:text-amber-500"></i>
                    <input id="fDate" name="newDate" type="text" value="<%= oldDate %>" required
                           class="w-full pl-14 pr-24 py-4 bg-white dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-8 focus:ring-amber-500/10 focus:border-amber-500 outline-none transition-all text-slate-900 dark:text-white cursor-pointer shadow-sm"
                           onchange="checkDiff(this, '<%= oldDate %>')">
                    <span class="mod-badge absolute right-6 top-1/2 -translate-y-1/2 text-[8px] font-black text-amber-600 bg-amber-50 dark:bg-amber-900/40 px-2 py-0.5 rounded uppercase tracking-widest border border-amber-100 dark:border-amber-800/50" id="badge-fDate">Modified</span>
                </div>
            </div>

            <!-- Service Type -->
            <div class="relative group">
                <label class="block text-[9px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mb-3">Service Type</label>
                <div class="relative space-y-3">
                    <select id="fType" name="newType" required
                           class="w-full px-6 py-4 bg-white dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-8 focus:ring-amber-500/10 focus:border-amber-500 outline-none transition-all text-slate-900 dark:text-white shadow-sm pr-24"
                           onchange="handleTypeChange(this); checkDiff(this, '<%= oldType %>')">
                        <% 
                            boolean isPredefined = false;
                            for (ServiceType st : sTypes) { 
                                if (st.getServiceName().equals(oldType)) isPredefined = true;
                        %>
                        <option value="<%= st.getServiceName() %>" <%= st.getServiceName().equals(oldType) ? "selected" : "" %>><%= st.getServiceName() %></option>
                        <% } %>
                        <option value="custom" <%= !isPredefined ? "selected" : "" %>>Other / Custom...</option>
                    </select>
                    
                    <input id="fCustomType" type="text" value="<%= !isPredefined ? oldType : "" %>" 
                           class="<%= isPredefined ? "hidden" : "" %> w-full px-6 py-4 bg-slate-100 dark:bg-slate-900/50 border-2 border-amber-500/30 rounded-2xl text-sm font-black text-slate-900 dark:text-white focus:border-amber-500 outline-none transition-all placeholder:text-slate-400" 
                           placeholder="Enter custom service name..."
                           oninput="syncCustomValue(this)">
                    
                    <span class="mod-badge absolute right-6 top-5 text-[8px] font-black text-amber-600 bg-amber-50 dark:bg-amber-900/40 px-2 py-0.5 rounded uppercase tracking-widest border border-amber-100 dark:border-amber-800/50" id="badge-fType">Modified</span>
                </div>
            </div>

            <!-- Cost -->
            <div class="relative group">
                <label class="block text-[9px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mb-3">Total Cost (LKR)</label>
                <div class="relative">
                    <input id="fCost" name="newCost" type="number" step="0.01" value="<%= oldCost %>" required
                           class="w-full px-6 py-4 bg-white dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-8 focus:ring-amber-500/10 focus:border-amber-500 outline-none transition-all text-slate-900 dark:text-white shadow-sm mono pr-24"
                           oninput="checkDiff(this, '<%= oldCost %>')">
                    <span class="mod-badge absolute right-6 top-1/2 -translate-y-1/2 text-[8px] font-black text-amber-600 bg-amber-50 dark:bg-amber-900/40 px-2 py-0.5 rounded uppercase tracking-widest border border-amber-100 dark:border-amber-800/50" id="badge-fCost">Modified</span>
                </div>
            </div>

            <!-- Change summary -->
            <div id="changeSummary" class="hidden bg-amber-50 dark:bg-amber-900/10 border border-amber-200 dark:border-amber-800/50 rounded-2xl p-4 mt-2">
                <p class="text-[10px] font-black text-amber-700 dark:text-amber-500 uppercase tracking-widest"><i class="fa-solid fa-pen-nib mr-2"></i> <span id="changeCount">0</span> field(s) modified from original snapshot</p>
            </div>

            <div class="flex gap-4 pt-6">
                <a href="dashboard.jsp" class="px-10 py-5 rounded-2xl border border-slate-200 dark:border-slate-800 text-slate-500 dark:text-slate-400 font-black text-[10px] uppercase tracking-widest hover:bg-slate-100 dark:hover:bg-slate-900 transition-all text-center flex items-center justify-center">Cancel</a>
                <button type="submit" class="flex-1 py-5 rounded-2xl bg-slate-900 dark:bg-white text-white dark:text-slate-950 font-black text-[10px] uppercase tracking-[0.2em] shadow-2xl transition-all flex items-center justify-center gap-3 hover:-translate-y-1 active:scale-95">
                    <i class="fa-solid fa-check-double text-lg"></i> Save Changes
                </button>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<script>
const originals = {
    fDate: '<%= oldDate %>',
    fType: '<%= oldType %>',
    fCost: '<%= oldCost %>'
};

document.addEventListener("DOMContentLoaded", () => {
    flatpickr("#fDate", {
        dateFormat: "Y-m-d",
        defaultDate: "<%= oldDate %>",
        monthSelectorType: "static",
        onChange: function(selectedDates, dateStr, instance) {
            checkDiff(document.getElementById('fDate'), originals.fDate);
        }
    });
});

function handleTypeChange(sel) {
    const customInp = document.getElementById('fCustomType');
    if (sel.value === 'custom') {
        customInp.classList.remove('hidden');
        customInp.required = true;
    } else {
        customInp.classList.add('hidden');
        customInp.required = false;
    }
}

function syncCustomValue(inp) {
    const sel = document.getElementById('fType');
    const customOpt = sel.options[sel.options.length - 1];
    customOpt.value = inp.value;
    checkDiff(sel, originals.fType);
}

function checkDiff(el, origVal) {
    const badge = document.getElementById('badge-' + el.id);
    if (!badge) return;
    if (el.value !== origVal) {
        el.classList.add('modified');
        badge.style.display = 'inline-flex';
    } else {
        el.classList.remove('modified');
        badge.style.display = 'none';
    }
    updateChangeSummary();
}

function updateChangeSummary() {
    let count = 0;
    Object.keys(originals).forEach(id => {
        const el = document.getElementById(id);
        if (el && el.value !== originals[id]) count++;
    });
    const summary = document.getElementById('changeSummary');
    document.getElementById('changeCount').textContent = count;
    summary.classList.toggle('hidden', count === 0);
}
</script>
</body>
</html>