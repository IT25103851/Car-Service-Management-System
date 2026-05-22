<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.UserManager, model.AbstractUser, java.util.List" %>
<%
    String role = (String) session.getAttribute("userRole");
    String currentUser = (String) session.getAttribute("username");
    if (currentUser == null) currentUser = (String) session.getAttribute("loggedInUser");
    if (!"admin".equals(role)) { response.sendRedirect("login.jsp"); return; }

    UserManager uManager = new UserManager();
    List<AbstractUser> allUsers = uManager.getAllUsers();
    int adminCount = 0, custCount = 0;
    for (AbstractUser u : allUsers) { if ("admin".equals(u.getRole())) adminCount++; else custCount++; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Users - SwiftDrive</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;700&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Plus Jakarta Sans', sans-serif; }
        .mono { font-family: 'JetBrains Mono', monospace; }
        .stat-card { transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1); }
        .stat-card:hover { transform: translateY(-4px); }
        .user-row { transition: all 0.3s ease; }
        .user-row:hover { background: rgba(99, 102, 241, 0.03) !important; }
        .modal-backdrop { transition: opacity 0.4s ease; }
        .modal-panel { 
            transition: all 0.5s cubic-bezier(0.34, 1.56, 0.64, 1); 
            transform: scale(0.9) translateY(40px);
            opacity: 0;
            max-height: 90vh;
            display: flex;
            flex-direction: column;
        }
        .modal-panel.open { transform: scale(1) translateY(0); opacity: 1; }
        
        @keyframes slideUp { from{opacity:0;transform:translateY(20px)} to{opacity:1;transform:translateY(0)} }
        .animate-slide-up { animation: slideUp 0.6s cubic-bezier(0.4, 0, 0.2, 1) forwards; }
        
        /* Body scroll lock */
        .modal-open { overflow: hidden !important; height: 100vh !important; }
    </style>
</head>
<body class="antialiased text-slate-900 dark:text-slate-100 bg-slate-50 dark:bg-slate-950 transition-colors duration-300 min-h-screen pt-28 pb-20">
<%@ include file="navbar.jsp" %>

<div class="max-w-7xl mx-auto px-4">
    <!-- HEADER -->
    <div class="flex flex-col md:flex-row justify-between items-stretch md:items-start mb-8 sm:mb-12 gap-6 sm:gap-8">
        <div>
            <h1 class="text-3xl sm:text-4xl font-black text-slate-900 dark:text-white tracking-tighter leading-none flex items-center gap-3 sm:gap-4">
                <i class="fa-solid fa-users text-indigo-500"></i> User Management
            </h1>
            <p class="mt-3 sm:mt-4 text-sm sm:text-base font-medium text-slate-500 dark:text-slate-400">Manage all registered accounts and their system roles.</p>
        </div>
        <button onclick="openAddModal()" class="bg-indigo-600 hover:bg-indigo-700 text-white px-8 sm:px-10 py-4 sm:py-5 rounded-2xl sm:rounded-[2rem] shadow-2xl shadow-indigo-100 dark:shadow-none font-black text-[10px] uppercase tracking-[0.2em] transition-all flex items-center justify-center gap-3 active:scale-95 w-full md:w-auto">
            <i class="fa-solid fa-user-plus text-base sm:text-lg"></i> Add New User
        </button>
    </div>

    <!-- USER STATISTICS -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 mb-8 sm:mb-12 animate-slide-up">
        <div class="stat-card bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] border border-slate-100 dark:border-slate-800 p-6 sm:p-8 shadow-2xl shadow-slate-200/40 dark:shadow-none relative overflow-hidden group">
            <div class="absolute -right-8 -top-8 w-24 h-24 bg-indigo-500/5 rounded-full blur-2xl group-hover:scale-150 transition-transform"></div>
            <p class="text-[9px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-[0.3em] mb-3 sm:mb-4">Total Users</p>
            <p class="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white mono tracking-tighter"><%= allUsers.size() %></p>
        </div>
        <div class="stat-card bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] border border-slate-100 dark:border-slate-800 p-6 sm:p-8 shadow-2xl shadow-slate-200/40 dark:shadow-none relative overflow-hidden group border-l-4 border-l-rose-500">
            <div class="absolute -right-8 -top-8 w-24 h-24 bg-rose-500/5 rounded-full blur-2xl group-hover:scale-150 transition-transform"></div>
            <p class="text-[9px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-[0.3em] mb-3 sm:mb-4">Administrators</p>
            <p class="text-2xl sm:text-3xl font-black text-rose-600 mono tracking-tighter"><%= adminCount %></p>
        </div>
        <div class="stat-card bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] border border-slate-100 dark:border-slate-800 p-6 sm:p-8 shadow-2xl shadow-slate-200/40 dark:shadow-none relative overflow-hidden group border-l-4 border-l-blue-500">
            <div class="absolute -right-8 -top-8 w-24 h-24 bg-blue-500/5 rounded-full blur-2xl group-hover:scale-150 transition-transform"></div>
            <p class="text-[9px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-[0.3em] mb-3 sm:mb-4">Customers</p>
            <p class="text-2xl sm:text-3xl font-black text-blue-600 mono tracking-tighter"><%= custCount %></p>
        </div>
        <div class="stat-card bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] border border-slate-100 dark:border-slate-800 p-6 sm:p-8 shadow-2xl shadow-slate-200/40 dark:shadow-none relative overflow-hidden group border-l-4 border-l-emerald-500">
            <div class="absolute -right-8 -top-8 w-24 h-24 bg-emerald-500/5 rounded-full blur-2xl group-hover:scale-150 transition-transform"></div>
            <p class="text-[9px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-[0.3em] mb-3 sm:mb-4">Current User</p>
            <p class="text-sm font-black text-emerald-600 dark:text-emerald-400 truncate tracking-tight"><%= currentUser %></p>
        </div>
    </div>

    <!-- SEARCH & FILTER -->
    <div class="bg-white dark:bg-slate-900 p-4 sm:p-6 rounded-[2rem] sm:rounded-[3rem] border border-slate-100 dark:border-slate-800 mb-8 sm:mb-12 flex flex-col sm:flex-row gap-4 sm:gap-6 items-stretch shadow-2xl shadow-slate-200/40 dark:shadow-none animate-slide-up">
        <div class="relative flex-grow group">
            <i class="fa-solid fa-magnifying-glass absolute left-5 sm:left-6 top-1/2 -translate-y-1/2 text-slate-400 dark:text-slate-700 text-sm group-focus-within:text-indigo-500 transition-colors"></i>
            <input type="text" id="searchInput" onkeyup="filterUsers()" placeholder="Search by username..." class="w-full pl-12 sm:pl-14 pr-6 sm:pr-8 py-3.5 sm:py-4 bg-slate-50 dark:bg-slate-950 border-2 border-transparent dark:border-slate-800 rounded-2xl sm:rounded-[1.5rem] text-xs sm:text-sm font-black text-slate-900 dark:text-white focus:ring-8 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all placeholder:text-slate-200 dark:placeholder:text-slate-800 shadow-inner">
        </div>
        <select id="roleFilter" onchange="filterUsers()" class="py-3.5 sm:py-4 px-6 sm:px-8 bg-slate-50 dark:bg-slate-950 border-2 border-transparent dark:border-slate-800 rounded-2xl sm:rounded-[1.5rem] text-[10px] font-black text-slate-700 dark:text-slate-300 uppercase tracking-widest focus:ring-8 focus:ring-indigo-500/10 outline-none cursor-pointer transition-all hover:bg-slate-100 dark:hover:bg-slate-900">
            <option value="all">All Roles</option>
            <option value="admin">Administrators</option>
            <option value="customer">Customers</option>
        </select>
    </div>

    <!-- USER LIST -->
    <div class="bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 rounded-2xl overflow-hidden shadow-2xl shadow-slate-200/40 dark:shadow-none animate-slide-up">
        <!-- DESKTOP TABLE VIEW -->
        <div class="hidden md:block overflow-x-auto">
            <table class="w-full border-collapse" id="userTable">
                <thead>
                    <tr class="bg-slate-950 text-white text-[9px] font-black uppercase border-b border-slate-800">
                        <th class="w-[25%] px-6 lg:px-8 py-5 text-left tracking-[0.3em]">Full Name</th>
                        <th class="w-[25%] px-6 lg:px-8 py-5 text-left tracking-[0.3em]">Username</th>
                        <th class="w-[20%] px-6 lg:px-8 py-5 text-left tracking-[0.3em]">User Role</th>
                        <th class="w-[15%] px-6 lg:px-8 py-5 text-left tracking-[0.3em]">Status</th>
                        <th class="w-[15%] px-6 lg:px-8 py-5 text-center tracking-[0.3em]">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-50 dark:divide-slate-800">
                    <% for (AbstractUser u : allUsers) {
                           boolean isSelf = u.getUsername().equals(currentUser);
                    %>
                    <tr class="user-row tbl-row group transition-colors" data-username="<%= u.getUsername().toLowerCase() %>" data-role="<%= u.getRole() %>">
                        <td class="w-[25%] px-6 lg:px-8 py-5 text-sm font-bold text-slate-900 dark:text-white break-words"><%= u.getName() %></td>
                        <td class="w-[25%] px-6 lg:px-8 py-5 text-sm font-bold text-slate-900 dark:text-white break-words"><%= u.getUsername() %></td>
                        <td class="w-[20%] px-6 lg:px-8 py-5">
                            <% if ("admin".equals(u.getRole())) { %>
                            <span class="text-[9px] font-black text-white bg-indigo-600 px-4 py-1.5 rounded-xl uppercase tracking-wider w-fit flex items-center gap-2 shadow-sm"><i class="fa-solid fa-shield-halved"></i> Admin</span>
                            <% } else { %>
                            <span class="text-[9px] font-black text-slate-600 dark:text-slate-400 bg-slate-100 dark:bg-slate-950 px-4 py-1.5 rounded-xl uppercase tracking-wider border border-slate-200 dark:border-slate-800 w-fit flex items-center gap-2 shadow-inner"><i class="fa-solid fa-user"></i> Customer</span>
                            <% } %>
                        </td>
                        <td class="w-[15%] px-6 lg:px-8 py-5">
                            <% if (u.isActive()) { %>
                            <span class="text-[9px] font-black text-emerald-600 bg-emerald-50 dark:bg-emerald-950/30 px-4 py-1.5 rounded-xl uppercase tracking-wider border border-emerald-100 dark:border-emerald-900/50 w-fit flex items-center gap-2"><i class="fa-solid fa-circle-check"></i> Active</span>
                            <% } else { %>
                            <span class="text-[9px] font-black text-rose-600 bg-rose-50 dark:bg-rose-950/30 px-4 py-1.5 rounded-xl uppercase tracking-wider border border-rose-100 dark:border-rose-900/50 w-fit flex items-center gap-2"><i class="fa-solid fa-circle-xmark"></i> Inactive</span>
                            <% } %>
                        </td>
                        <td class="w-[15%] px-6 lg:px-8 py-5 text-center">
                            <div class="flex items-center justify-center gap-3">
                                <button onclick="openEditModal('<%= u.getName() %>', '<%= u.getUsername() %>', '<%= u.getPassword() %>', '<%= u.getRole() %>')" 
                                   class="w-10 h-10 rounded-xl bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-800 text-slate-400 dark:text-slate-700 hover:text-indigo-600 dark:hover:text-indigo-400 flex items-center justify-center transition-all shadow-sm active:scale-90" title="Edit User">
                                    <i class="fa-solid fa-pen-nib text-xs"></i>
                                </button>
                                 <% if (isSelf) { %>
                                 <div class="w-10 h-10 rounded-xl bg-slate-100/50 dark:bg-slate-900/50 border border-slate-200/50 dark:border-slate-800/50 text-slate-200 dark:text-slate-800 flex items-center justify-center cursor-not-allowed">
                                     <i class="fa-solid fa-ban text-xs"></i>
                                 </div>
                                 <% } else { 
                                     if (u.isActive()) { %>
                                     <button onclick="openDeactivateModal('<%= u.getUsername() %>')" 
                                        class="w-10 h-10 rounded-xl bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-800 text-slate-400 dark:text-slate-700 hover:text-amber-600 dark:hover:text-amber-400 flex items-center justify-center transition-all shadow-sm active:scale-90" title="Deactivate Account">
                                         <i class="fa-solid fa-user-slash text-xs"></i>
                                     </button>
                                     <% } else { %>
                                     <button onclick="openReactivateModal('<%= u.getUsername() %>')" 
                                        class="w-10 h-10 rounded-xl bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-800 text-slate-400 dark:text-slate-700 hover:text-emerald-600 dark:hover:text-emerald-400 flex items-center justify-center transition-all shadow-sm active:scale-90" title="Reactivate Account">
                                         <i class="fa-solid fa-user-check text-xs"></i>
                                     </button>
                                     <% } %>
                                 <% } %>
                                 
                                 <% if (isSelf) { %>
                                 <div class="w-10 h-10 rounded-xl bg-slate-100/50 dark:bg-slate-900/50 border border-slate-200/50 dark:border-slate-800/50 text-slate-200 dark:text-slate-800 flex items-center justify-center cursor-not-allowed">
                                     <i class="fa-solid fa-lock text-xs"></i>
                                 </div>
                                 <% } else { %>
                                 <button onclick="openDeleteUserModal('<%= u.getUsername() %>')" 
                                    class="w-10 h-10 rounded-xl bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-800 text-slate-400 dark:text-slate-700 hover:text-rose-600 dark:hover:text-rose-400 flex items-center justify-center transition-all shadow-sm active:scale-90" title="Permanently Delete">
                                     <i class="fa-solid fa-trash-can text-xs"></i>
                                 </button>
                                 <% } %>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>

        <!-- MOBILE CARD VIEW -->
        <div class="block md:hidden p-4 space-y-4">
            <% for (AbstractUser u : allUsers) {
                   boolean isSelf = u.getUsername().equals(currentUser);
            %>
            <div class="user-card p-5 bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-800 rounded-2xl space-y-4" data-username="<%= u.getUsername().toLowerCase() %>" data-role="<%= u.getRole() %>">
                <div class="flex justify-between items-center">
                    <div>
                        <p class="text-[9px] font-black text-slate-500 dark:text-slate-600 uppercase tracking-[0.3em] mb-1">Full Name</p>
                        <h4 class="text-base font-black text-slate-900 dark:text-white tracking-tight"><%= u.getName() %></h4>
                    </div>
                    <div>
                        <% if ("admin".equals(u.getRole())) { %>
                        <span class="text-[9px] font-black text-white bg-indigo-600 px-4 py-1.5 rounded-xl uppercase tracking-wider w-fit flex items-center gap-2 shadow-sm"><i class="fa-solid fa-shield-halved"></i> Admin</span>
                        <% } else { %>
                        <span class="text-[9px] font-black text-slate-600 dark:text-slate-400 bg-slate-100 dark:bg-slate-950 px-4 py-1.5 rounded-xl uppercase tracking-wider border border-slate-200 dark:border-slate-800 w-fit flex items-center gap-2 shadow-inner"><i class="fa-solid fa-user"></i> Customer</span>
                        <% } %>
                    </div>
                </div>
                
                <div class="flex justify-between items-start gap-4">
                    <div>
                        <p class="text-[9px] font-black text-slate-500 dark:text-slate-600 uppercase tracking-[0.3em] mb-1">Username</p>
                        <p class="text-sm font-bold text-slate-850 dark:text-slate-200 mono"><%= u.getUsername() %></p>
                    </div>
                    <div class="text-right">
                        <p class="text-[9px] font-black text-slate-500 dark:text-slate-600 uppercase tracking-[0.3em] mb-1">Status</p>
                        <% if (u.isActive()) { %>
                        <span class="inline-flex text-[9px] font-black text-emerald-600 bg-emerald-50 dark:bg-emerald-950/30 px-4 py-1.5 rounded-xl uppercase tracking-wider border border-emerald-100 dark:border-emerald-900/50 w-fit items-center gap-2"><i class="fa-solid fa-circle-check"></i> Active</span>
                        <% } else { %>
                        <span class="inline-flex text-[9px] font-black text-rose-600 bg-rose-50 dark:bg-rose-950/30 px-4 py-1.5 rounded-xl uppercase tracking-wider border border-rose-100 dark:border-rose-900/50 w-fit items-center gap-2"><i class="fa-solid fa-circle-xmark"></i> Inactive</span>
                        <% } %>
                    </div>
                </div>
                
                <div class="flex justify-end items-center pt-2 border-t border-slate-100 dark:border-slate-800">
                    <div class="flex items-center gap-2">
                        <button onclick="openEditModal('<%= u.getName() %>', '<%= u.getUsername() %>', '<%= u.getPassword() %>', '<%= u.getRole() %>')" 
                           class="w-10 h-10 rounded-xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 text-slate-400 dark:text-slate-700 hover:text-indigo-600 dark:hover:text-indigo-400 flex items-center justify-center transition-all shadow-sm active:scale-95" title="Edit User">
                            <i class="fa-solid fa-pen-nib text-xs"></i>
                        </button>
                         <% if (isSelf) { %>
                         <div class="w-10 h-10 rounded-xl bg-slate-100 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-200 dark:text-slate-700 flex items-center justify-center cursor-not-allowed">
                             <i class="fa-solid fa-ban text-xs"></i>
                         </div>
                         <% } else { 
                             if (u.isActive()) { %>
                             <button onclick="openDeactivateModal('<%= u.getUsername() %>')" 
                                class="w-10 h-10 rounded-xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 text-slate-400 dark:text-slate-700 hover:text-amber-600 dark:hover:text-amber-400 flex items-center justify-center transition-all shadow-sm active:scale-95" title="Deactivate Account">
                                 <i class="fa-solid fa-user-slash text-xs"></i>
                             </button>
                             <% } else { %>
                             <button onclick="openReactivateModal('<%= u.getUsername() %>')" 
                                class="w-10 h-10 rounded-xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 text-slate-400 dark:text-slate-700 hover:text-emerald-600 dark:hover:text-emerald-400 flex items-center justify-center transition-all shadow-sm active:scale-95" title="Reactivate Account">
                                 <i class="fa-solid fa-user-check text-xs"></i>
                             </button>
                             <% } %>
                         <% } %>
                         
                         <% if (isSelf) { %>
                         <div class="w-10 h-10 rounded-xl bg-slate-100 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-200 dark:text-slate-700 flex items-center justify-center cursor-not-allowed">
                             <i class="fa-solid fa-lock text-xs"></i>
                         </div>
                         <% } else { %>
                         <button onclick="openDeleteUserModal('<%= u.getUsername() %>')" 
                            class="w-10 h-10 rounded-xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 text-slate-400 dark:text-slate-700 hover:text-rose-600 dark:hover:text-rose-400 flex items-center justify-center transition-all shadow-sm active:scale-95" title="Permanently Delete">
                             <i class="fa-solid fa-trash-can text-xs"></i>
                         </button>
                         <% } %>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
    </div>
</div>

<!-- PREMIUM CENTERED MODAL -->
<div id="modal" class="hidden fixed inset-0 z-[200] flex items-center justify-center p-4 sm:p-6 overflow-hidden">
    <div class="modal-backdrop absolute inset-0 bg-slate-955/40 backdrop-blur-2xl opacity-0" id="backdrop" onclick="closeModal()"></div>
    <div class="modal-panel relative bg-white dark:bg-slate-900 rounded-[3rem] shadow-[0_32px_64px_-12px_rgba(0,0,0,0.2)] dark:shadow-none border border-slate-100 dark:border-slate-800 w-full max-w-xl overflow-hidden max-h-[calc(100vh-2rem)] sm:max-h-[90vh] flex flex-col" id="modalContent">
        <!-- Modal Header -->
        <div class="p-6 sm:p-10 border-b border-slate-50 dark:border-slate-800/50 flex justify-between items-start">
            <div>
                <h3 class="text-3xl font-black text-slate-900 dark:text-white tracking-tighter" id="modalTitle">Add User</h3>
                <p class="text-sm font-medium text-slate-400 dark:text-slate-500 mt-2">Configure system access credentials.</p>
            </div>
            <button onclick="closeModal()" class="w-12 h-12 rounded-2xl bg-slate-50 dark:bg-slate-800 text-slate-400 hover:text-rose-500 transition-all flex items-center justify-center active:scale-90">
                <i class="fa-solid fa-xmark text-lg"></i>
            </button>
        </div>

        <div class="flex-1 overflow-y-auto p-6 sm:p-10 custom-scrollbar">
            <form action="RegisterServlet" method="POST" id="userForm" class="space-y-8" onsubmit="return validateUserForm()">
                <input type="hidden" name="action" id="formAction" value="add">
                <div>
                    <label class="block text-[9px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-widest mb-3">Full Name</label>
                    <input type="text" name="name" id="userName" required class="w-full px-6 py-4 bg-slate-50 dark:bg-slate-950 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-8 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white shadow-inner">
                </div>
                <div>
                    <label class="block text-[9px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-widest mb-3">Username</label>
                    <input type="text" name="username" id="userUsername" required class="w-full px-6 py-4 bg-slate-50 dark:bg-slate-955 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-8 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white shadow-inner">
                    <!-- Suggestions container -->
                    <div id="usernameSuggestions" class="mt-3 hidden">
                        <span class="text-[9px] font-black text-slate-400 dark:text-slate-650 uppercase tracking-widest block mb-2">Suggested Usernames (Click to use)</span>
                        <div class="flex flex-wrap gap-2" id="suggestionsContainer"></div>
                    </div>
                </div>
                <div>
                    <label class="block text-[9px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-widest mb-3">Password</label>
                    <div class="relative">
                        <input type="password" name="password" id="userPassword" required class="w-full px-6 py-4 bg-slate-50 dark:bg-slate-955 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-8 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white shadow-inner pr-14">
                        <button type="button" onclick="toggleUserPassword()" class="absolute right-4 top-1/2 -translate-y-1/2 w-10 h-10 flex items-center justify-center text-slate-400 hover:text-indigo-500 transition-colors">
                            <i id="userPasswordToggleIcon" class="fa-solid fa-eye text-sm"></i>
                        </button>
                    </div>
                    <p class="text-[9px] font-medium text-slate-450 dark:text-slate-550 mt-2">Password must contain letters, numbers, and symbols.</p>
                </div>
                <div id="securityFields" class="space-y-8">
                    <div>
                        <label class="block text-[9px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-widest mb-3">Security Question</label>
                        <select name="securityQuestion" id="userSQ" class="w-full px-6 py-4 bg-slate-50 dark:bg-slate-955 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-8 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white shadow-inner">
                            <option value="What was your first car?">What was your first car?</option>
                            <option value="What was your childhood nickname?">What was your childhood nickname?</option>
                            <option value="In what city were you born?">In what city were you born?</option>
                            <option value="What is your favorite food?">What is your favorite food?</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-[9px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-widest mb-3">Security Answer</label>
                        <input type="text" name="securityAnswer" id="userSA" required placeholder="Required for password reset" class="w-full px-6 py-4 bg-slate-50 dark:bg-slate-950 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-8 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white shadow-inner">
                    </div>
                </div>
                <div>
                    <label class="block text-[9px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-widest mb-3">User Role</label>
                    <select name="role" id="userRole" class="w-full px-6 py-4 bg-slate-50 dark:bg-slate-950 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-8 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white shadow-inner">
                        <option value="customer">Customer</option>
                        <option value="admin">Administrator</option>
                    </select>
                </div>
                <div class="pt-6">
                    <button type="submit" class="w-full py-5 rounded-2xl bg-indigo-600 hover:bg-indigo-700 text-white font-black text-[10px] uppercase tracking-[0.2em] shadow-xl shadow-indigo-100 dark:shadow-none transition-all active:scale-95 flex items-center justify-center gap-4">
                        <i class="fa-solid fa-shield-halved text-lg"></i> Save User
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- DEACTIVATION MODAL -->
<div id="deactivateModal" class="hidden fixed inset-0 z-[200] flex items-center justify-center p-4 sm:p-6 overflow-hidden">
    <div class="modal-backdrop absolute inset-0 bg-slate-955/40 backdrop-blur-2xl opacity-0" id="deactivateBackdrop" onclick="closeDeactivateModal()"></div>
    <div class="modal-panel relative bg-white dark:bg-slate-900 rounded-[3rem] shadow-[0_32px_64px_-12px_rgba(0,0,0,0.2)] dark:shadow-none border border-slate-100 dark:border-slate-800 w-full max-w-md overflow-y-auto max-h-[calc(100vh-2rem)] sm:max-h-[90vh] custom-scrollbar" id="deactivateModalContent">
        <div class="p-6 sm:p-10 text-center">
            <div class="w-20 h-20 bg-amber-500/10 rounded-full flex items-center justify-center mx-auto mb-8">
                <i class="fa-solid fa-user-slash text-3xl text-amber-500"></i>
            </div>
            <h3 class="text-3xl font-black text-slate-900 dark:text-white tracking-tighter">Deactivate Account?</h3>
            <p class="text-sm font-medium text-slate-400 dark:text-slate-505 mt-4 leading-relaxed">
                Deactivating <span id="deactivateTarget" class="text-amber-500 font-bold"></span> will immediately revoke all system access. This can be reversed at any time.
            </p>
            
            <div class="flex flex-col gap-4 mt-10">
                <a id="deactivateConfirmBtn" href="#" class="w-full py-5 rounded-2xl bg-amber-600 hover:bg-amber-700 text-white font-black text-[10px] uppercase tracking-[0.2em] shadow-xl shadow-amber-100 dark:shadow-none transition-all active:scale-95 flex items-center justify-center gap-4">
                    Confirm Deactivation
                </a>
                <button onclick="closeDeactivateModal()" class="w-full py-5 rounded-2xl bg-slate-50 dark:bg-slate-800 text-slate-600 dark:text-slate-300 font-black text-[10px] uppercase tracking-[0.2em] transition-all hover:bg-slate-100 dark:hover:bg-slate-700">
                    Cancel
                </button>
            </div>
        </div>
    </div>
</div>

<!-- REACTIVATION MODAL -->
<div id="reactivateModal" class="hidden fixed inset-0 z-[200] flex items-center justify-center p-4 sm:p-6 overflow-hidden">
    <div class="modal-backdrop absolute inset-0 bg-slate-955/40 backdrop-blur-2xl opacity-0" id="reactivateBackdrop" onclick="closeReactivateModal()"></div>
    <div class="modal-panel relative bg-white dark:bg-slate-900 rounded-[3rem] shadow-[0_32px_64px_-12px_rgba(0,0,0,0.2)] dark:shadow-none border border-slate-100 dark:border-slate-800 w-full max-w-md overflow-y-auto max-h-[calc(100vh-2rem)] sm:max-h-[90vh] custom-scrollbar" id="reactivateModalContent">
        <div class="p-6 sm:p-10 text-center">
            <div class="w-20 h-20 bg-emerald-500/10 rounded-full flex items-center justify-center mx-auto mb-8">
                <i class="fa-solid fa-user-check text-3xl text-emerald-500"></i>
            </div>
            <h3 class="text-3xl font-black text-slate-900 dark:text-white tracking-tighter">Restore Access?</h3>
            <p class="text-sm font-medium text-slate-400 dark:text-slate-505 mt-4 leading-relaxed">
                Reactivating <span id="reactivateTarget" class="text-emerald-500 font-bold"></span> will restore their ability to log in and use the system immediately.
            </p>
            
            <div class="flex flex-col gap-4 mt-10">
                <a id="reactivateConfirmBtn" href="#" class="w-full py-5 rounded-2xl bg-emerald-600 hover:bg-emerald-700 text-white font-black text-[10px] uppercase tracking-[0.2em] shadow-xl shadow-emerald-100 dark:shadow-none transition-all active:scale-95 flex items-center justify-center gap-4">
                    Confirm Reactivation
                </a>
                <button onclick="closeReactivateModal()" class="w-full py-5 rounded-2xl bg-slate-50 dark:bg-slate-800 text-slate-600 dark:text-slate-300 font-black text-[10px] uppercase tracking-[0.2em] transition-all hover:bg-slate-100 dark:hover:bg-slate-700">
                    Cancel
                </button>
            </div>
        </div>
    </div>
</div>

<!-- DELETE USER MODAL -->
<div id="deleteUserModal" class="hidden fixed inset-0 z-[200] flex items-center justify-center p-4 sm:p-6 overflow-hidden">
    <div class="modal-backdrop absolute inset-0 bg-slate-955/40 backdrop-blur-2xl opacity-0" id="deleteUserBackdrop" onclick="closeDeleteUserModal()"></div>
    <div class="modal-panel relative bg-white dark:bg-slate-900 rounded-[3rem] shadow-[0_32px_64px_-12px_rgba(0,0,0,0.2)] dark:shadow-none border border-slate-100 dark:border-slate-800 w-full max-w-md overflow-y-auto max-h-[calc(100vh-2rem)] sm:max-h-[90vh] custom-scrollbar" id="deleteUserModalContent">
        <div class="p-6 sm:p-10 text-center">
            <div class="w-20 h-20 bg-rose-500/10 rounded-full flex items-center justify-center mx-auto mb-8">
                <i class="fa-solid fa-trash-can text-3xl text-rose-500"></i>
            </div>
            <h3 class="text-3xl font-black text-slate-900 dark:text-white tracking-tighter">Remove User?</h3>
            <p class="text-sm font-medium text-slate-400 dark:text-slate-500 mt-4 leading-relaxed">
                Are you sure you want to permanently delete <span id="deleteUserTarget" class="text-rose-500 font-bold"></span>? This action cannot be undone.
            </p>
            
            <div class="flex flex-col gap-4 mt-10">
                <a id="deleteUserConfirmBtn" href="#" class="w-full py-5 rounded-2xl bg-rose-600 hover:bg-rose-700 text-white font-black text-[10px] uppercase tracking-[0.2em] shadow-xl shadow-rose-100 dark:shadow-none transition-all active:scale-95 flex items-center justify-center gap-4">
                    Confirm & Delete
                </a>
                <button onclick="closeDeleteUserModal()" class="w-full py-5 rounded-2xl bg-slate-50 dark:bg-slate-800 text-slate-600 dark:text-slate-300 font-black text-[10px] uppercase tracking-[0.2em] transition-all hover:bg-slate-100 dark:hover:bg-slate-700">
                    Cancel
                </button>
            </div>
        </div>
    </div>
</div>

<%@ include file="toast.jsp" %>
<script>
let userUsernameEdited = false;

function toggleUserPassword() {
    const passwordInput = document.getElementById("userPassword");
    const toggleIcon = document.getElementById("userPasswordToggleIcon");
    if (passwordInput.type === "password") {
        passwordInput.type = "text";
        toggleIcon.classList.remove("fa-eye");
        toggleIcon.classList.add("fa-eye-slash");
    } else {
        passwordInput.type = "password";
        toggleIcon.classList.remove("fa-eye-slash");
        toggleIcon.classList.add("fa-eye");
    }
}

function generateUsernames(fullName) {
    if (!fullName || fullName.trim().length === 0) return [];
    const clean = fullName.toLowerCase().replace(/[^a-z0-9\s]/g, '').trim();
    const parts = clean.split(/\s+/).filter(p => p.length > 0);
    if (parts.length === 0) return [];
    
    const suggestions = [];
    const first = parts[0];
    const last = parts.length > 1 ? parts[parts.length - 1] : "";
    const rand1 = Math.floor(100 + Math.random() * 900);
    const rand2 = Math.floor(10 + Math.random() * 90);
    
    if (last) {
        suggestions.push(`${first}${last}`);
        suggestions.push(`${first}.${last}`);
        suggestions.push(`${first.charAt(0)}${last}${rand2}`);
    } else {
        suggestions.push(`${first}${rand1}`);
        suggestions.push(`${first}_${rand2}`);
        suggestions.push(`iam${first}`);
    }
    
    while (suggestions.length < 3) {
        suggestions.push(`${first}${Math.floor(1000 + Math.random() * 9000)}`);
    }
    return [...new Set(suggestions)].slice(0, 3);
}

function validateUserForm() {
    const action = document.getElementById('formAction').value;
    const pwd = document.getElementById('userPassword').value;
    
    if (action === 'edit' && pwd.trim().length === 0) {
        return true;
    }
    
    if (pwd.length < 8) {
        showToast("Password must be at least 8 characters long.", "error");
        return false;
    }
    
    const hasLetter = /[a-zA-Z]/.test(pwd);
    const hasNumber = /[0-9]/.test(pwd);
    const hasSymbol = /[^a-zA-Z0-9]/.test(pwd);
    
    if (!hasLetter || !hasNumber || !hasSymbol) {
        showToast("Password must contain letters, numbers, and symbols.", "error");
        return false;
    }
    return true;
}

document.addEventListener("DOMContentLoaded", () => {
    const params = new URLSearchParams(window.location.search);
    if (params.get("success") === "created") showToast("New user added.", "success");
    if (params.get("success") === "updated") showToast("User updated.", "success");
    if (params.get("success") === "deleted") showToast("User removed.", "info");
    if (params.get("success") === "deactivated") showToast("User deactivated.", "warning");
    if (params.get("success") === "reactivated") showToast("User reactivated.", "success");
    if (params.get("error") === "protected") showToast("Master Admin is protected.", "error");
    if (params.get("error") === "weakpassword") showToast("Password must contain letters, numbers, and symbols.", "error");
    if (params.get("error") === "exists") showToast("Username already exists.", "error");

    const userUsernameEl = document.getElementById('userUsername');
    if (userUsernameEl) {
        userUsernameEl.addEventListener('input', () => {
            userUsernameEdited = true;
        });
    }

    const userNameEl = document.getElementById('userName');
    if (userNameEl) {
        userNameEl.addEventListener('input', function() {
            const isAdd = document.getElementById('formAction').value === 'add';
            if (!isAdd) return;
            
            const nameVal = this.value;
            const suggestions = generateUsernames(nameVal);
            const container = document.getElementById('suggestionsContainer');
            const wrapper = document.getElementById('usernameSuggestions');
            
            if (suggestions.length > 0) {
                wrapper.classList.remove('hidden');
                container.innerHTML = '';
                suggestions.forEach(s => {
                    const btn = document.createElement('button');
                    btn.type = 'button';
                    btn.className = 'px-3 py-1.5 bg-indigo-50 dark:bg-indigo-950/40 text-indigo-600 dark:text-indigo-400 hover:bg-indigo-100 hover:text-indigo-700 rounded-lg text-xs font-black transition-all';
                    btn.textContent = s;
                    btn.onclick = () => {
                        document.getElementById('userUsername').value = s;
                    };
                    container.appendChild(btn);
                });
                
                if (!userUsernameEdited) {
                    document.getElementById('userUsername').value = suggestions[0];
                }
            } else {
                wrapper.classList.add('hidden');
            }
        });
    }
});

function openAddModal() {
    document.getElementById('modalTitle').textContent = 'Add New User';
    document.getElementById('formAction').value = 'add';
    document.getElementById('userForm').action = 'RegisterServlet';
    document.getElementById('userForm').reset();
    document.getElementById('userUsername').readOnly = false;
    document.getElementById('userUsername').classList.remove('opacity-50');
    
    // Set Password Required
    document.getElementById('userPassword').required = true;
    document.getElementById('userPassword').placeholder = '••••••••••••';
    
    // Show Security Fields
    document.getElementById('securityFields').classList.remove('hidden');
    document.getElementById('userSQ').required = true;
    document.getElementById('userSA').required = true;
    
    userUsernameEdited = false;
    document.getElementById('usernameSuggestions').classList.add('hidden');
    
    document.body.classList.add('overflow-hidden');
    const m = document.getElementById('modal'); m.classList.remove('hidden');
    setTimeout(() => { 
        document.getElementById('backdrop').style.opacity = '1'; 
        document.getElementById('modalContent').classList.add('open'); 
    }, 20);
}

function openEditModal(name, username, password, role) {
    document.getElementById('modalTitle').textContent = 'Edit User';
    document.getElementById('formAction').value = 'edit';
    document.getElementById('userForm').action = 'UpdateUserServlet';
    
    document.getElementById('userName').value = name;
    document.getElementById('userUsername').value = username;
    document.getElementById('userUsername').readOnly = true;
    document.getElementById('userUsername').classList.add('opacity-50');
    
    // Set Password Optional
    document.getElementById('userPassword').required = false;
    document.getElementById('userPassword').value = '';
    document.getElementById('userPassword').placeholder = 'Enter new password or leave blank';
    
    // Hide Security Fields
    document.getElementById('securityFields').classList.add('hidden');
    document.getElementById('userSQ').required = false;
    document.getElementById('userSA').required = false;
    
    document.getElementById('usernameSuggestions').classList.add('hidden');
    
    document.getElementById('userRole').value = role;
    
    document.body.classList.add('overflow-hidden');
    const m = document.getElementById('modal'); m.classList.remove('hidden');
    setTimeout(() => { 
        document.getElementById('backdrop').style.opacity = '1'; 
        document.getElementById('modalContent').classList.add('open'); 
    }, 20);
}

function closeModal() {
    document.getElementById('backdrop').style.opacity = '0';
    document.getElementById('modalContent').classList.remove('open');
    document.body.classList.remove('overflow-hidden');
    setTimeout(() => document.getElementById('modal').classList.add('hidden'), 300);
}

function openDeactivateModal(username) {
    document.getElementById('deactivateTarget').textContent = username;
    document.getElementById('deactivateConfirmBtn').href = 'DeactivateUserServlet?username=' + username;
    
    document.body.classList.add('overflow-hidden');
    const m = document.getElementById('deactivateModal'); m.classList.remove('hidden');
    setTimeout(() => { 
        document.getElementById('deactivateBackdrop').style.opacity = '1'; 
        document.getElementById('deactivateModalContent').classList.add('open'); 
    }, 20);
}

function closeDeactivateModal() {
    document.getElementById('deactivateBackdrop').style.opacity = '0';
    document.getElementById('deactivateModalContent').classList.remove('open');
    document.body.classList.remove('overflow-hidden');
    setTimeout(() => document.getElementById('deactivateModal').classList.add('hidden'), 300);
}

function openReactivateModal(username) {
    document.getElementById('reactivateTarget').textContent = username;
    document.getElementById('reactivateConfirmBtn').href = 'ReactivateUserServlet?username=' + username;
    
    document.body.classList.add('overflow-hidden');
    const m = document.getElementById('reactivateModal'); m.classList.remove('hidden');
    setTimeout(() => { 
        document.getElementById('reactivateBackdrop').style.opacity = '1'; 
        document.getElementById('reactivateModalContent').classList.add('open'); 
    }, 20);
}

function closeReactivateModal() {
    document.getElementById('reactivateBackdrop').style.opacity = '0';
    document.getElementById('reactivateModalContent').classList.remove('open');
    document.body.classList.remove('overflow-hidden');
    setTimeout(() => document.getElementById('reactivateModal').classList.add('hidden'), 300);
}

function openDeleteUserModal(username) {
    document.getElementById('deleteUserTarget').textContent = username;
    document.getElementById('deleteUserConfirmBtn').href = 'DeleteUserServlet?username=' + username;
    
    document.body.classList.add('overflow-hidden');
    const m = document.getElementById('deleteUserModal'); m.classList.remove('hidden');
    setTimeout(() => { 
        document.getElementById('deleteUserBackdrop').style.opacity = '1'; 
        document.getElementById('deleteUserModalContent').classList.add('open'); 
    }, 20);
}

function closeDeleteUserModal() {
    document.getElementById('deleteUserBackdrop').style.opacity = '0';
    document.getElementById('deleteUserModalContent').classList.remove('open');
    document.body.classList.remove('overflow-hidden');
    setTimeout(() => document.getElementById('deleteUserModal').classList.add('hidden'), 300);
}

function filterUsers() {
    const q = document.getElementById('searchInput').value.toLowerCase();
    const r = document.getElementById('roleFilter').value;
    
    // Filter desktop rows
    document.querySelectorAll('.user-row').forEach(row => {
        const name = row.getAttribute('data-username') || '';
        const role = row.getAttribute('data-role') || '';
        row.style.display = (name.includes(q) && (r === 'all' || role === r)) ? '' : 'none';
    });

    // Filter mobile cards
    document.querySelectorAll('.user-card').forEach(card => {
        const name = card.getAttribute('data-username') || '';
        const role = card.getAttribute('data-role') || '';
        card.style.display = (name.includes(q) && (r === 'all' || role === r)) ? '' : 'none';
    });
}
</script>
</body>
</html>