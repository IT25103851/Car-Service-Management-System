<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.BookingManager, model.Appointment, java.util.List" %>
<%
    String role = (String) session.getAttribute("userRole");
    if (!"admin".equals(role)) { response.sendRedirect("login.jsp"); return; }

    BookingManager manager = new BookingManager();
    ChatManager chatManager = new ChatManager();
    List<Appointment> pending = manager.getPendingAppointments();
    List<Appointment> garageList = manager.getInGarageAppointments();
    List<Appointment> completed = manager.getCompletedAppointments();
    int totalQueued = pending.size();
    int carsInGarage = garageList.size();
    int totalCompleted = completed.size();
    int estWaitMins = totalQueued * 45;
%>
<%@ page import="model.ChatManager, model.ChatMessage" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Service Queue - SwiftDrive</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;700&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Plus Jakarta Sans', sans-serif; }
        .mono { font-family: 'JetBrains Mono', monospace; }
        .stat-card { transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1); }
        .stat-card:hover { transform: translateY(-4px); }
        .queue-card { transition: all 0.5s cubic-bezier(0.4, 0, 0.2, 1); }
        .queue-card:hover { transform: translateY(-8px); }
        @keyframes shimmer { 0%{background-position:-200% 0} 100%{background-position:200% 0} }
        .shimmer-active {
            background: linear-gradient(90deg, transparent 0%, rgba(99, 102, 241, 0.05) 50%, transparent 100%);
            background-size: 200% 100%; animation: shimmer 3s infinite;
        }
        .modal-backdrop { transition: opacity 0.3s; }
        .modal-panel { transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1), opacity 0.3s; transform: scale(0.9) translateY(20px); opacity: 0; }
        .modal-panel.open { transform: scale(1) translateY(0); opacity: 1; }
        @keyframes slideUp { from{opacity:0;transform:translateY(30px)} to{opacity:1;transform:translateY(0)} }
        .animate-slide-up { animation: slideUp 0.7s cubic-bezier(0.4, 0, 0.2, 1) forwards; }
        
        /* Body scroll lock */
        .modal-open { overflow: hidden !important; height: 100vh !important; }

        .status-tab { transition: all 0.3s ease; border-bottom: 3px solid transparent; }
        .status-tab.active { border-bottom-color: #4f46e5; color: #4f46e5; }
    </style>
</head>
<body class="antialiased text-slate-900 dark:text-slate-100 bg-slate-50 dark:bg-slate-950 transition-colors duration-300 min-h-screen pt-28 pb-20">
<%@ include file="navbar.jsp" %>

<div class="max-w-7xl mx-auto px-4">
    <!-- HEADER -->
    <div class="flex flex-col md:flex-row justify-between items-stretch md:items-start mb-8 sm:mb-12 gap-6 sm:gap-8">
        <div>
            <h1 class="text-3xl sm:text-4xl font-black text-slate-900 dark:text-white tracking-tighter leading-none flex items-center gap-3 sm:gap-4">
                <i class="fa-solid fa-calendar-check text-indigo-500"></i> Appointments Management
            </h1>
            <p class="mt-3 sm:mt-4 text-sm sm:text-base font-medium text-slate-500 dark:text-slate-400">List of scheduled and pending service appointments.</p>
        </div>
        <button onclick="openServiceModal()" class="bg-indigo-600 hover:bg-indigo-700 text-white px-8 sm:px-10 py-4 sm:py-5 rounded-2xl sm:rounded-[2rem] shadow-2xl shadow-indigo-100 dark:shadow-none font-black text-[10px] uppercase tracking-[0.2em] transition-all flex items-center justify-center gap-3 active:scale-95 w-full md:w-auto">
            <i class="fa-solid fa-bolt text-base sm:text-lg"></i> Start Next Service
        </button>
    </div>

    <!-- STATS MATRIX -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 mb-8 sm:mb-12 animate-slide-up">
        <div class="stat-card bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] border border-slate-100 dark:border-slate-800 p-6 sm:p-8 shadow-2xl shadow-slate-200/40 dark:shadow-none relative overflow-hidden group">
            <div class="absolute -right-8 -top-8 w-24 h-24 bg-indigo-500/5 rounded-full blur-2xl group-hover:scale-150 transition-transform"></div>
            <p class="text-[9px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-[0.3em] mb-3 sm:mb-4">Pending</p>
            <p class="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white mono tracking-tighter"><%= totalQueued %></p>
            <div class="mt-4 sm:mt-6 flex items-center gap-2 text-[9px] font-black text-indigo-500 uppercase tracking-widest bg-indigo-50 dark:bg-indigo-950 px-4 py-1.5 rounded-xl border border-indigo-100 dark:border-indigo-800/50 w-fit">
                <i class="fa-solid fa-list-ol"></i> Count
            </div>
        </div>
        <div class="stat-card bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] border border-slate-100 dark:border-slate-800 p-6 sm:p-8 shadow-2xl shadow-slate-200/40 dark:shadow-none relative overflow-hidden group">
            <div class="absolute -right-8 -top-8 w-24 h-24 bg-amber-500/5 rounded-full blur-2xl group-hover:scale-150 transition-transform"></div>
            <p class="text-[9px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-[0.3em] mb-3 sm:mb-4">Wait Time</p>
            <p class="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white mono tracking-tighter"><%= estWaitMins >= 60 ? (estWaitMins/60) + "h " + (estWaitMins%60) + "m" : estWaitMins + "m" %></p>
            <div class="mt-4 sm:mt-6 flex items-center gap-2 text-[9px] font-black text-amber-500 uppercase tracking-widest bg-amber-50 dark:bg-amber-950 px-4 py-1.5 rounded-xl border border-amber-100 dark:border-amber-800/50 w-fit">
                <i class="fa-solid fa-hourglass-half"></i> Estimate
            </div>
        </div>
        <div class="stat-card bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] border border-slate-100 dark:border-slate-800 p-6 sm:p-8 shadow-2xl shadow-slate-200/40 dark:shadow-none relative overflow-hidden group">
            <div class="absolute -right-8 -top-8 w-24 h-24 bg-emerald-500/5 rounded-full blur-2xl group-hover:scale-150 transition-transform"></div>
            <p class="text-[9px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-[0.3em] mb-3 sm:mb-4">Garage Load</p>
            <p class="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white mono tracking-tighter"><%= carsInGarage %></p>
            <div class="mt-4 sm:mt-6 flex items-center gap-2 text-[9px] font-black text-emerald-500 uppercase tracking-widest bg-emerald-50 dark:bg-emerald-950 px-4 py-1.5 rounded-xl border border-emerald-100 dark:border-emerald-800/50 w-fit">
                <i class="fa-solid fa-warehouse"></i> In Service
            </div>
        </div>
        <div class="stat-card bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] border border-slate-100 dark:border-slate-800 p-6 sm:p-8 shadow-2xl shadow-slate-200/40 dark:shadow-none relative overflow-hidden group">
            <div class="absolute -right-8 -top-8 w-24 h-24 bg-blue-500/5 rounded-full blur-2xl group-hover:scale-150 transition-transform"></div>
            <p class="text-[9px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-[0.3em] mb-3 sm:mb-4">Completed</p>
            <p class="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white mono tracking-tighter"><%= totalCompleted %></p>
            <div class="mt-4 sm:mt-6 flex items-center gap-2 text-[9px] font-black text-blue-500 uppercase tracking-widest bg-blue-50 dark:bg-blue-950 px-4 py-1.5 rounded-xl border border-blue-100 dark:border-blue-800/50 w-fit">
                <i class="fa-solid fa-circle-check"></i> Finished
            </div>
        </div>
    </div>

    <!-- TABS -->
    <div class="flex items-center gap-4 sm:gap-8 mb-8 sm:mb-12 border-b border-slate-100 dark:border-slate-800 overflow-x-auto no-scrollbar">
        <button onclick="switchTab('pending')" id="tab-pending" class="status-tab active px-2 sm:px-4 py-4 sm:py-5 text-[9px] sm:text-[10px] font-black uppercase tracking-[0.2em] whitespace-nowrap">
            Pending Appointments (<%= totalQueued %>)
        </button>
        <button onclick="switchTab('garage')" id="tab-garage" class="status-tab px-2 sm:px-4 py-4 sm:py-5 text-[9px] sm:text-[10px] font-black uppercase tracking-[0.2em] whitespace-nowrap">
            In Garage (<%= carsInGarage %>)
        </button>
        <button onclick="switchTab('completed')" id="tab-completed" class="status-tab px-2 sm:px-4 py-4 sm:py-5 text-[9px] sm:text-[10px] font-black uppercase tracking-[0.2em] whitespace-nowrap">
            Completed (<%= totalCompleted %>)
        </button>
    </div>

    <!-- PENDING SECTION -->
    <div id="section-pending" class="animate-slide-up">
        <% if (pending.isEmpty()) { %>
        <div class="bg-white dark:bg-slate-900 rounded-[2.5rem] sm:rounded-[4rem] border-2 border-dashed border-slate-100 dark:border-slate-800 p-16 sm:p-32 text-center shadow-inner">
            <div class="w-24 h-24 sm:w-32 sm:h-32 bg-slate-50 dark:bg-slate-950 rounded-full flex items-center justify-center mx-auto mb-6 sm:mb-10 shadow-inner">
                <i class="fa-solid fa-check-double text-slate-300 dark:text-slate-800 text-6xl sm:text-8xl"></i>
            </div>
            <h3 class="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white tracking-tighter mb-4">Queue Clear</h3>
            <p class="text-slate-500 dark:text-slate-400 font-medium text-sm sm:text-lg max-w-sm mx-auto">No pending appointments in the list.</p>
        </div>
        <% } else { %>
        <div class="space-y-6 sm:space-y-8">
            <% for (Appointment app : pending) { %>
            <div class="queue-card bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 rounded-[2rem] sm:rounded-[3.5rem] p-6 sm:p-8 md:p-10 relative overflow-hidden shadow-2xl shadow-slate-200/40 dark:shadow-none">
                <div class="flex flex-col md:flex-row md:items-center justify-between gap-6 sm:gap-8 md:gap-10">
                    <div class="flex-1 min-w-0">
                        <div class="flex flex-wrap items-center gap-4 sm:gap-6 mb-4 sm:mb-6">
                            <span class="mono text-[10px] font-black text-indigo-600 dark:text-indigo-400 bg-indigo-50 dark:bg-indigo-950 border border-indigo-100 dark:border-indigo-800/50 px-3.5 py-1.5 rounded-xl uppercase tracking-widest shadow-inner"><%= app.getLicensePlate() %></span>
                            <span class="text-[10px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-[0.3em] flex items-center gap-2.5"><i class="fa-regular fa-clock text-indigo-500 text-xs"></i> Scheduled for <%= app.getPreferredTime() %></span>
                        </div>
                        <h4 class="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white tracking-tighter group-hover:text-indigo-500 transition-colors leading-none truncate" title="<%= app.getIssueDescription() %>"><%= app.getIssueDescription() %></h4>
                        <p class="mt-4 sm:mt-6 text-[10px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-widest">Customer: <span class="text-slate-900 dark:text-white ml-2">@<%= app.getCustomerUsername() %></span></p>
                    </div>
                    <div class="flex flex-col items-stretch sm:items-end gap-4 sm:gap-6 w-full md:w-auto">
                        <div class="flex flex-wrap items-center gap-3 sm:gap-4 w-full justify-start sm:justify-end">
                            <% 
                                int unread = chatManager.getUnreadCountForUser(app.getAppointmentId(), "admin"); 
                            %>
                            <a href="appointment_chat.jsp?appId=<%= app.getAppointmentId() %>" class="relative bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300 px-5 sm:px-6 py-3 sm:py-3.5 rounded-xl sm:rounded-2xl text-[9px] font-black uppercase tracking-[0.3em] hover:bg-slate-200 dark:hover:bg-slate-700 transition-all flex items-center justify-center gap-2.5 sm:gap-3 active:scale-95 flex-grow sm:flex-grow-0">
                                <i class="fa-solid fa-comments text-xs text-indigo-500"></i> Message
                                <% if (unread > 0) { %>
                                    <span class="absolute -top-2 -right-2 w-6 h-6 bg-rose-500 text-white rounded-full flex items-center justify-center text-[8px] animate-bounce shadow-lg"><%= unread %></span>
                                <% } %>
                            </a>
                            <a href="move_to_garage_action.jsp?id=<%= app.getAppointmentId() %>" class="bg-indigo-600 text-white px-6 sm:px-8 py-3 sm:py-3.5 rounded-xl sm:rounded-2xl text-[9px] font-black uppercase tracking-[0.3em] hover:bg-indigo-700 transition-all shadow-xl shadow-indigo-100 dark:shadow-none active:scale-95 flex items-center justify-center gap-2.5 sm:gap-3 flex-grow sm:flex-grow-0">
                                <i class="fa-solid fa-play text-xs"></i> Start Service
                            </a>
                            <button onclick="openDeleteModal('<%= app.getAppointmentId() %>', '<%= app.getLicensePlate() %>')" class="w-10 sm:w-12 h-10 sm:h-12 bg-white dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 rounded-xl sm:rounded-2xl text-slate-400 dark:text-slate-800 hover:text-rose-600 dark:hover:text-rose-500 flex items-center justify-center transition-all shadow-sm active:scale-90 flex-shrink-0">
                                <i class="fa-solid fa-trash-can text-sm"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
        <% } %>
    </div>

    <!-- GARAGE SECTION -->
    <div id="section-garage" class="hidden animate-slide-up">
        <% if (garageList.isEmpty()) { %>
        <div class="bg-white dark:bg-slate-900 rounded-[2.5rem] sm:rounded-[4rem] border-2 border-dashed border-slate-100 dark:border-slate-800 p-16 sm:p-32 text-center shadow-inner">
            <div class="w-24 h-24 sm:w-32 sm:h-32 bg-slate-50 dark:bg-slate-950 rounded-full flex items-center justify-center mx-auto mb-6 sm:mb-10 shadow-inner">
                <i class="fa-solid fa-warehouse text-slate-300 dark:text-slate-800 text-6xl sm:text-8xl"></i>
            </div>
            <h3 class="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white tracking-tighter mb-4">Garage Empty</h3>
            <p class="text-slate-500 dark:text-slate-400 font-medium text-sm sm:text-lg max-w-sm mx-auto">No vehicles are currently undergoing maintenance.</p>
        </div>
        <% } else { %>
        <div class="space-y-6 sm:space-y-8">
            <% for (Appointment app : garageList) { %>
            <div class="queue-card bg-white dark:bg-slate-900 border-l-8 border-l-orange-500 border border-slate-100 dark:border-slate-800 rounded-[2rem] sm:rounded-[3.5rem] p-6 sm:p-8 md:p-10 relative overflow-hidden shadow-2xl shadow-slate-200/40 dark:shadow-none">
                <div class="flex flex-col md:flex-row md:items-center justify-between gap-6 sm:gap-8 md:gap-10">
                    <div class="flex-1 min-w-0">
                        <div class="flex flex-wrap items-center gap-4 sm:gap-6 mb-4 sm:mb-6">
                            <span class="mono text-[10px] font-black text-orange-600 dark:text-orange-400 bg-orange-50 dark:bg-orange-950 border border-orange-100 dark:border-orange-800/50 px-3.5 py-1.5 rounded-xl uppercase tracking-widest shadow-inner"><%= app.getLicensePlate() %></span>
                            <span class="text-[10px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-[0.3em] flex items-center gap-2.5"><i class="fa-solid fa-gears text-orange-500 animate-spin-slow"></i> Under Maintenance</span>
                        </div>
                        <h4 class="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white tracking-tighter leading-none truncate" title="<%= app.getIssueDescription() %>"><%= app.getIssueDescription() %></h4>
                        <p class="mt-4 sm:mt-6 text-[10px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-widest">Customer: <span class="text-slate-900 dark:text-white ml-2">@<%= app.getCustomerUsername() %></span></p>
                    </div>
                    <div class="flex flex-col items-stretch sm:items-end gap-4 sm:gap-6 w-full md:w-auto">
                        <button type="button" 
                                onclick="openFinishServiceModal('<%= app.getAppointmentId() %>', '<%= app.getLicensePlate() %>', '<%= app.getCustomerUsername() %>', '<%= app.getIssueDescription() %>')"
                                class="bg-slate-900 dark:bg-white text-white dark:text-slate-950 px-6 sm:px-8 py-3 sm:py-3.5 rounded-xl sm:rounded-2xl text-[9px] font-black uppercase tracking-[0.3em] hover:bg-indigo-600 hover:text-white transition-all shadow-xl active:scale-95 flex items-center justify-center gap-2.5 sm:gap-3 w-full sm:w-auto">
                            <i class="fa-solid fa-flag-checkered text-xs"></i> Finish Service
                        </button>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
        <% } %>
    </div>

    <!-- COMPLETED SECTION -->
    <div id="section-completed" class="hidden animate-slide-up">
        <% if (completed.isEmpty()) { %>
        <div class="bg-white dark:bg-slate-900 rounded-[2.5rem] sm:rounded-[4rem] border-2 border-dashed border-slate-100 dark:border-slate-800 p-16 sm:p-32 text-center shadow-inner">
            <div class="w-24 h-24 sm:w-32 sm:h-32 bg-slate-50 dark:bg-slate-950 rounded-full flex items-center justify-center mx-auto mb-6 sm:mb-10 shadow-inner">
                <i class="fa-solid fa-circle-check text-slate-300 dark:text-slate-800 text-6xl sm:text-8xl"></i>
            </div>
            <h3 class="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white tracking-tighter mb-4">No Recent Completion</h3>
            <p class="text-slate-500 dark:text-slate-400 font-medium text-sm sm:text-lg max-w-sm mx-auto">No appointments have been marked as completed recently.</p>
        </div>
        <% } else { %>
        <div class="space-y-6 sm:space-y-8">
            <% for (Appointment app : completed) { %>
            <div class="queue-card bg-white dark:bg-slate-900 border-l-8 border-l-emerald-500 border border-slate-100 dark:border-slate-800 rounded-[2rem] sm:rounded-[3.5rem] p-6 sm:p-8 md:p-10 relative overflow-hidden shadow-2xl shadow-slate-200/40 dark:shadow-none">
                <div class="flex flex-col md:flex-row md:items-center justify-between gap-6 sm:gap-8 md:gap-10">
                    <div class="flex-1 min-w-0">
                        <div class="flex flex-wrap items-center gap-4 sm:gap-6 mb-4 sm:mb-6">
                            <span class="mono text-[10px] font-black text-emerald-600 dark:text-emerald-400 bg-emerald-50 dark:bg-emerald-950 border border-emerald-100 dark:border-emerald-800/50 px-3.5 py-1.5 rounded-xl uppercase tracking-widest shadow-inner"><%= app.getLicensePlate() %></span>
                            <span class="text-[10px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-[0.3em] flex items-center gap-2.5"><i class="fa-solid fa-circle-check text-emerald-500"></i> Completed</span>
                        </div>
                        <h4 class="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white tracking-tighter leading-none truncate" title="<%= app.getIssueDescription() %>"><%= app.getIssueDescription() %></h4>
                        <p class="mt-4 sm:mt-6 text-[10px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-widest">Customer: <span class="text-slate-900 dark:text-white ml-2">@<%= app.getCustomerUsername() %></span></p>
                    </div>
                    <div class="flex flex-col items-stretch sm:items-end gap-4 sm:gap-6 w-full md:w-auto">
                        <%
                            boolean isChatOpen = ChatManager.isChatWindowOpen(app.getCompletedDate(), 7);
                            if (isChatOpen) {
                                int unread = chatManager.getUnreadCountForUser(app.getAppointmentId(), "admin");
                                long daysLeft = ChatManager.getRemainingDays(app.getCompletedDate(), 7);
                        %>
                        <div class="flex flex-wrap items-center gap-3 sm:gap-4 w-full justify-start sm:justify-end">
                            <a href="appointment_chat.jsp?appId=<%= app.getAppointmentId() %>" class="relative bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300 px-5 sm:px-6 py-3 sm:py-3.5 rounded-xl sm:rounded-2xl text-[9px] font-black uppercase tracking-[0.3em] hover:bg-slate-200 dark:hover:bg-slate-700 transition-all flex items-center justify-center gap-2.5 sm:gap-3 active:scale-95 flex-grow sm:flex-grow-0">
                                <i class="fa-solid fa-comments text-xs text-indigo-500"></i> Message
                                <span class="text-[8px] font-black text-slate-400 normal-case tracking-normal ml-1">(<%= daysLeft %>d left)</span>
                                <% if (unread > 0) { %>
                                    <span class="absolute -top-2 -right-2 w-6 h-6 bg-rose-500 text-white rounded-full flex items-center justify-center text-[8px] animate-bounce shadow-lg"><%= unread %></span>
                                <% } %>
                            </a>
                        </div>
                        <% } %>
                        <a href="billing_dashboard.jsp" class="bg-emerald-600 text-white px-6 sm:px-8 py-3 sm:py-3.5 rounded-xl sm:rounded-2xl text-[9px] font-black uppercase tracking-[0.3em] hover:bg-emerald-700 transition-all shadow-xl active:scale-95 flex items-center justify-center gap-2.5 sm:gap-3 w-full sm:w-auto">
                            <i class="fa-solid fa-receipt text-xs"></i> View Invoices
                        </a>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
        <% } %>
    </div>
</div>

<!-- DELETE CONFIRMATION MODAL -->
<div id="deleteModal" class="hidden fixed inset-0 z-[200] flex items-center justify-center p-4 sm:p-6">
    <div class="modal-backdrop absolute inset-0 bg-slate-950/80 backdrop-blur-xl opacity-0" id="deleteBackdrop" onclick="closeDeleteModal()"></div>
    <div class="modal-panel relative bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] shadow-2xl max-w-sm w-full border border-slate-100 dark:border-slate-800 overflow-y-auto max-h-[calc(100vh-2rem)] sm:max-h-[90vh] custom-scrollbar" id="deletePanel">
        <div class="p-6 sm:p-10 md:p-12 text-center">
            <div class="w-16 h-16 sm:w-24 sm:h-24 rounded-[1.5rem] sm:rounded-[2rem] bg-rose-50 dark:bg-rose-950 flex items-center justify-center mx-auto mb-6 sm:mb-10 text-rose-500 shadow-inner border border-rose-100 dark:border-rose-900/30">
                <i class="fa-solid fa-trash-can text-2xl sm:text-4xl"></i>
            </div>
            <h3 class="text-xl sm:text-2xl md:text-3xl font-black text-slate-900 dark:text-white tracking-tighter">Cancel Appointment?</h3>
            <p class="text-xs sm:text-sm font-medium text-slate-500 dark:text-slate-400 mt-3 sm:mt-4 leading-relaxed">
                Are you sure you want to cancel the appointment for <span id="deletePlateDisplay" class="font-bold text-slate-900 dark:text-white"></span>? This action cannot be undone.
            </p>
            
            <div class="flex flex-col gap-3 sm:gap-4 mt-6 sm:mt-10">
                <a id="confirmDeleteBtn" href="#" class="w-full py-3.5 sm:py-5 rounded-xl sm:rounded-2xl bg-rose-600 hover:bg-rose-700 text-white font-black text-[10px] uppercase tracking-[0.2em] shadow-2xl shadow-rose-100 dark:shadow-none transition-all active:scale-95 flex items-center justify-center gap-3 sm:gap-4">
                    <i class="fa-solid fa-trash-can text-base sm:text-lg"></i> Confirm & Delete
                </a>
                <button type="button" onclick="closeDeleteModal()" class="w-full py-3.5 sm:py-5 rounded-xl sm:rounded-2xl bg-white dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 text-slate-400 dark:text-slate-700 font-black text-[10px] uppercase tracking-[0.2em] hover:bg-slate-50 dark:hover:bg-slate-800 transition-all">
                    Keep Appointment
                </button>
            </div>
        </div>
    </div>
</div>

<!-- SERVICE MODAL -->
<div id="serviceModal" class="hidden fixed inset-0 z-[200] flex items-center justify-center p-4 sm:p-6">
    <div class="modal-backdrop absolute inset-0 bg-slate-950/80 backdrop-blur-xl opacity-0" id="modalBackdrop" onclick="closeServiceModal()"></div>
    <div class="modal-panel relative bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] shadow-2xl max-w-sm w-full border border-slate-100 dark:border-slate-800 overflow-y-auto max-h-[calc(100vh-2rem)] sm:max-h-[90vh] custom-scrollbar" id="modalPanel">
        <div class="p-6 sm:p-10 md:p-12 text-center">
            <div class="w-16 h-16 sm:w-24 sm:h-24 rounded-[1.5rem] sm:rounded-[2rem] bg-indigo-50 dark:bg-indigo-950 flex items-center justify-center mx-auto mb-6 sm:mb-10 text-indigo-500 shadow-inner border border-indigo-100 dark:border-indigo-900/30">
                <i class="fa-solid fa-bolt text-2xl sm:text-4xl"></i>
            </div>
            <h3 class="text-xl sm:text-2xl md:text-3xl font-black text-slate-900 dark:text-white tracking-tighter">Start Service?</h3>
            <p class="text-xs sm:text-sm font-medium text-slate-500 dark:text-slate-400 mt-3 sm:mt-4 leading-relaxed">Start the service for the next appointment in the queue.</p>
            
            <div class="flex flex-col gap-3 sm:gap-4 mt-6 sm:mt-10">
                <% if (!pending.isEmpty()) { 
                    Appointment next = pending.get(0); %>
                <a href="move_to_garage_action.jsp?id=<%= next.getAppointmentId() %>" class="w-full py-3.5 sm:py-5 rounded-xl sm:rounded-2xl bg-indigo-600 hover:bg-indigo-700 text-white font-black text-[10px] uppercase tracking-[0.2em] shadow-2xl shadow-indigo-100 dark:shadow-none transition-all active:scale-95 flex items-center justify-center gap-3 sm:gap-4">
                    <i class="fa-solid fa-play text-base sm:text-lg"></i> Confirm & Start
                </a>
                <% } %>
                <button type="button" onclick="closeServiceModal()" class="w-full py-3.5 sm:py-5 rounded-xl sm:rounded-2xl bg-white dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 text-slate-400 dark:text-slate-700 font-black text-[10px] uppercase tracking-[0.2em] hover:bg-slate-50 dark:hover:bg-slate-800 transition-all">Cancel</button>
            </div>
        </div>
    </div>
</div>

<script>
function openServiceModal() {
    const m = document.getElementById('serviceModal');
    const b = document.getElementById('modalBackdrop');
    const p = document.getElementById('modalPanel');
    m.classList.remove('hidden');
    document.body.classList.add('modal-open');
    setTimeout(() => { b.style.opacity='1'; p.classList.add('open'); }, 20);
}
function closeServiceModal() {
    const b = document.getElementById('modalBackdrop');
    const p = document.getElementById('modalPanel');
    b.style.opacity='0'; p.classList.remove('open');
    document.body.classList.remove('modal-open');
    setTimeout(() => document.getElementById('serviceModal').classList.add('hidden'), 300);
}

function openDeleteModal(id, plate) {
    const m = document.getElementById('deleteModal');
    const b = document.getElementById('deleteBackdrop');
    const p = document.getElementById('deletePanel');
    const btn = document.getElementById('confirmDeleteBtn');
    const display = document.getElementById('deletePlateDisplay');
    
    display.textContent = plate;
    btn.href = 'delete_appointment_action.jsp?id=' + id;
    
    m.classList.remove('hidden');
    document.body.classList.add('modal-open');
    setTimeout(() => { b.style.opacity='1'; p.classList.add('open'); }, 20);
}

function closeDeleteModal() {
    const b = document.getElementById('deleteBackdrop');
    const p = document.getElementById('deletePanel');
    b.style.opacity='0'; p.classList.remove('open');
    document.body.classList.remove('modal-open');
    setTimeout(() => document.getElementById('deleteModal').classList.add('hidden'), 300);
}

function switchTab(tab) {
    // Update tabs
    document.querySelectorAll('.status-tab').forEach(t => t.classList.remove('active'));
    document.getElementById('tab-' + tab).classList.add('active');

    // Update sections
    document.getElementById('section-pending').classList.add('hidden');
    document.getElementById('section-garage').classList.add('hidden');
    document.getElementById('section-completed').classList.add('hidden');
    document.getElementById('section-' + tab).classList.remove('hidden');
}

document.addEventListener('DOMContentLoaded', () => {
    const params = new URLSearchParams(window.location.search);
    if (params.get('serviceStarted') === 'true') {
        showToast('Service started successfully. Vehicle moved to garage.', 'success');
        switchTab('garage');
    }
    if (params.get('deleteSuccess') === 'true') {
        showToast('Appointment canceled and removed from queue.', 'info');
    }
    if (params.get('error') === 'moveFailed') {
        showToast('Failed to start service. Please try again.', 'error');
    }
    if (params.get('error') === 'deleteFailed') {
        showToast('Failed to cancel appointment.', 'error');
    }
});

function updateCountdowns() {
    document.querySelectorAll('.countdown-chip').forEach(chip => {
        const d = chip.dataset.date, t = chip.dataset.time;
        if (!d || !t) return;
        const target = new Date(d + 'T' + (t.length === 5 ? t : '0' + t) + ':00');
        const now = new Date();
        const diff = target - now;
        const txt = chip.querySelector('.cd-text');
        if (diff <= 0) { 
            txt.textContent = 'WINDOW ACTIVE'; 
            chip.classList.remove('bg-indigo-600', 'shadow-indigo-100');
            chip.classList.add('bg-emerald-600', 'shadow-emerald-100');
            return; 
        }
        const hrs = Math.floor(diff / 3600000), mins = Math.floor((diff % 3600000) / 60000);
        if (hrs > 24) { txt.textContent = 'IN ' + Math.floor(hrs/24) + 'D ' + (hrs%24) + 'H'; }
        else if (hrs > 0) { txt.textContent = 'IN ' + hrs + 'H ' + mins + 'M'; }
        else { txt.textContent = 'IN ' + mins + 'M'; }
    });
}
updateCountdowns();
setInterval(updateCountdowns, 60000);
</script>
<%@ include file="finish_service_modal.jsp" %>
<%@ include file="toast.jsp" %>
</body>
</html>