<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.BookingManager, model.Appointment, java.util.List" %>
<%
    String role = (String) session.getAttribute("userRole");
    if (!"admin".equals(role)) { response.sendRedirect("login.jsp"); return; }

    BookingManager manager = new BookingManager();
    List<Appointment> inGarage = manager.getInGarageAppointments();
    List<Appointment> queue = manager.getPendingAppointments();
    int totalQueued = queue.size();
    int carsInGarage = inGarage.size();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Garage Bay - SwiftDrive</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;700&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Plus Jakarta Sans', sans-serif; }
        .mono { font-family: 'JetBrains Mono', monospace; }
        .garage-card { transition: all 0.5s cubic-bezier(0.4, 0, 0.2, 1); }
        .garage-card:hover { transform: translateY(-8px); }
        @keyframes wrench-spin { 0%{transform:rotate(0)} 25%{transform:rotate(-15deg)} 75%{transform:rotate(15deg)} 100%{transform:rotate(0)} }
        .wrench-anim { animation: wrench-spin 3s ease-in-out infinite; }
        @keyframes slideUp { from{opacity:0;transform:translateY(30px)} to{opacity:1;transform:translateY(0)} }
        .animate-slide-up { animation: slideUp 0.7s cubic-bezier(0.4, 0, 0.2, 1) forwards; }
    </style>
</head>
<body class="antialiased text-slate-900 dark:text-slate-100 bg-slate-50 dark:bg-slate-950 transition-colors duration-300 min-h-screen pt-28 pb-20">
<%@ include file="navbar.jsp" %>

<div class="max-w-7xl mx-auto px-4">
    <!-- HEADER -->
    <div class="flex flex-col md:flex-row justify-between items-start mb-12 gap-8">
        <div>
            <h1 class="text-4xl font-black text-slate-900 dark:text-white tracking-tighter leading-none flex items-center gap-4">
                <i class="fa-solid fa-warehouse text-indigo-500"></i> Garage Management
            </h1>
            <p class="mt-4 text-base font-medium text-slate-500 dark:text-slate-400">Manage vehicles currently undergoing maintenance.</p>
        </div>
        <div class="flex items-center gap-6">
            <div class="bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 px-8 py-4 rounded-[2rem] shadow-2xl shadow-slate-200/40 dark:shadow-none flex items-center gap-5">
                <div class="w-12 h-12 rounded-2xl bg-orange-50 dark:bg-orange-950 flex items-center justify-center text-orange-500 shadow-inner">
                    <i class="fa-solid fa-gears text-xl"></i>
                </div>
                <div>
                    <p class="text-[9px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-[0.2em]">Active Repairs</p>
                    <p class="text-xl font-black text-slate-900 dark:text-white mono tracking-tighter"><%= inGarage.size() %> Vehicles</p>
                </div>
            </div>
        </div>
    </div>

    <!-- NAVIGATION -->
    <div class="flex flex-wrap gap-4 mb-12 animate-slide-up">
        <a href="manage_appointments.jsp" class="px-10 py-5 bg-white dark:bg-slate-900 text-slate-500 dark:text-slate-400 border border-slate-100 dark:border-slate-800 rounded-[2rem] shadow-2xl shadow-slate-200/40 dark:shadow-none hover:bg-slate-50 dark:hover:bg-slate-800 font-black text-[10px] uppercase tracking-[0.2em] flex items-center gap-3 transition-all">
            <i class="fa-solid fa-list-ol text-indigo-500"></i> Appointments (<%= totalQueued %>)
        </a>
        <a href="in_garage.jsp" class="px-10 py-5 bg-orange-500 text-white rounded-[2rem] shadow-2xl shadow-orange-100 dark:shadow-none font-black text-[10px] uppercase tracking-[0.2em] flex items-center gap-3 transition-all">
            <i class="fa-solid fa-gears text-lg"></i> In Garage (<%= carsInGarage %>)
        </a>
    </div>

    <!-- BAY GRID -->
    <% if (inGarage.isEmpty()) { %>
    <div class="bg-white dark:bg-slate-900 rounded-[4rem] border-2 border-dashed border-slate-100 dark:border-slate-800 p-32 text-center animate-slide-up shadow-inner">
        <div class="w-32 h-32 bg-slate-50 dark:bg-slate-950 rounded-full flex items-center justify-center mx-auto mb-10 shadow-inner">
            <i class="fa-solid fa-car-tunnel text-slate-300 dark:text-slate-800 text-8xl"></i>
        </div>
        <h3 class="text-3xl font-black text-slate-900 dark:text-white tracking-tighter mb-4">No Vehicles in Garage</h3>
        <p class="text-slate-500 dark:text-slate-400 font-medium text-lg max-w-sm mx-auto">All maintenance tasks have been completed.</p>
    </div>
    <% } else { %>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-10 animate-slide-up">
        <% for (Appointment app : inGarage) { %>
        <div class="garage-card bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 border-l-8 border-l-orange-500 rounded-[3.5rem] p-10 relative overflow-hidden shadow-2xl shadow-slate-200/40 dark:shadow-none group">
            <div class="flex flex-col h-full">
                <div class="flex items-start justify-between gap-6 mb-10">
                    <div class="w-20 h-20 rounded-[2rem] bg-orange-50 dark:bg-orange-950 flex items-center justify-center text-orange-500 text-4xl flex-shrink-0 shadow-inner border border-orange-100 dark:border-orange-900/30">
                        <i class="fa-solid fa-wrench wrench-anim"></i>
                    </div>
                    <div class="text-right">
                        <span class="inline-flex items-center gap-3 text-[9px] font-black text-orange-600 dark:text-orange-400 bg-orange-50 dark:bg-orange-950 px-5 py-2.5 rounded-2xl border border-orange-100 dark:border-orange-800/50 uppercase tracking-[0.2em] mb-4 shadow-inner">
                            <span class="w-2 h-2 rounded-full bg-orange-500 animate-pulse"></span> UNDER MAINTENANCE
                        </span>
                        <p class="text-[9px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-widest"><i class="fa-solid fa-hashtag mr-2 text-indigo-500"></i><%= app.getAppointmentId() %></p>
                    </div>
                </div>
                
                <div class="flex-1">
                    <div class="flex items-center gap-6 mb-6">
                        <span class="mono text-xl font-black text-slate-900 dark:text-white bg-slate-50 dark:bg-slate-950 border-2 border-orange-500/20 px-6 py-2 rounded-2xl tracking-[0.1em] shadow-inner"><%= app.getLicensePlate() %></span>
                    </div>
                    <h4 class="text-2xl font-black text-slate-900 dark:text-white tracking-tighter leading-none mb-4"><%= app.getIssueDescription() %></h4>
                    <p class="text-[10px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-widest flex items-center gap-3"><i class="fa-solid fa-user-shield text-indigo-500"></i> Customer: @<%= app.getCustomerUsername() %></p>
                </div>

                <div class="mt-10 pt-10 border-t border-slate-50 dark:border-slate-800">
                    <button type="button" 
                            onclick="openFinishServiceModal('<%= app.getAppointmentId() %>', '<%= app.getLicensePlate() %>', '<%= app.getCustomerUsername() %>', '<%= app.getIssueDescription() %>')"
                            class="w-full bg-slate-900 dark:bg-white text-white dark:text-slate-950 py-6 rounded-[2rem] font-black text-[10px] uppercase tracking-[0.3em] transition-all shadow-2xl active:scale-95 flex items-center justify-center gap-4 group-hover:bg-indigo-600 group-hover:text-white dark:group-hover:bg-indigo-600">
                        <i class="fa-solid fa-flag-checkered text-lg"></i> Finish Service
                    </button>
                </div>
            </div>
        </div>
        <% } %>
    </div>
    <% } %>
</div>
<%@ include file="finish_service_modal.jsp" %>
</body>
</html>
