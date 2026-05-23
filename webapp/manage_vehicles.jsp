<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.VehicleManager, model.Vehicle, java.util.List" %>
<%@ page import="model.ServiceHistoryList, model.ServiceRecord, model.Node" %>
<%@ page import="model.UserManager, model.AbstractUser" %>
<%
    String role = (String) session.getAttribute("userRole");
    if (!"admin".equals(role)) { response.sendRedirect("login.jsp"); return; }

    VehicleManager vManager = new VehicleManager();
    List<Vehicle> allCars = vManager.getAllVehicles();
    ServiceHistoryList shl = new ServiceHistoryList(); shl.loadFromFile();
    
    UserManager uManager = new UserManager();
    List<AbstractUser> allUsers = uManager.getAllUsers();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vehicle Registry - SwiftDrive</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;700&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Plus Jakarta Sans', sans-serif; }
        .mono { font-family: 'JetBrains Mono', monospace; }
        .sl-plate { font-family: 'JetBrains Mono', monospace; letter-spacing: 0.15em; }
        .v-card { transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1); }
        .v-card:hover { transform: translateY(-6px); }
        .drawer-backdrop { transition: opacity 0.3s; }
        .drawer-panel { transition: transform 0.4s cubic-bezier(.4,0,.2,1); transform: translateX(100%); }
        .drawer-panel.open { transform: translateX(0); }
        .del-drawer-panel { transition: transform 0.4s cubic-bezier(.4,0,.2,1); transform: translateY(100%); }
        .del-drawer-panel.open { transform: translateY(0); }
        .modified-field { border-color: #6366f1 !important; background: rgba(99, 102, 241, 0.05) !important; }
        @keyframes fadeIn { from{opacity:0;transform:translateY(20px)} to{opacity:1;transform:translateY(0)} }
        .fade-in { animation: fadeIn 0.6s cubic-bezier(0.4, 0, 0.2, 1) forwards; }
    </style>
</head>
<body class="antialiased text-slate-900 dark:text-slate-100 bg-slate-50 dark:bg-slate-950 transition-colors duration-300 min-h-screen pt-28 pb-20">
<%@ include file="navbar.jsp" %>

<div class="max-w-7xl mx-auto px-4">
    <!-- HEADER -->
    <div class="flex flex-col sm:flex-row justify-between items-stretch sm:items-start mb-6 sm:mb-8 gap-4 sm:gap-6">
        <div>
            <h1 class="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white tracking-tighter leading-none flex items-center gap-2 sm:gap-3">
                <i class="fa-solid fa-car text-indigo-500 text-xl sm:text-2xl"></i> Vehicle Management
            </h1>
            <p class="mt-2 text-xs sm:text-sm font-medium text-slate-500 dark:text-slate-400">List of registered customer vehicles and their technical data.</p>
        </div>
        <div class="flex items-center">
            <div class="w-full sm:w-auto bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 px-4 py-2.5 rounded-xl shadow-sm flex items-center gap-3">
                <div class="w-8 h-8 rounded-lg bg-indigo-50 dark:bg-indigo-900/30 flex items-center justify-center text-indigo-500 shadow-inner">
                    <i class="fa-solid fa-database text-sm"></i>
                </div>
                <div>
                    <p class="text-[8px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-widest leading-none">Active Vehicles</p>
                    <p class="text-sm font-black text-slate-900 dark:text-white mt-1"><%= allCars.size() %> Records</p>
                </div>
            </div>
        </div>
    </div>

    <!-- ADD VEHICLE -->
    <div id="addVehicle" class="bg-white dark:bg-slate-900 rounded-2xl sm:rounded-3xl border border-slate-100 dark:border-slate-800 p-4 sm:p-6 md:p-8 shadow-2xl animate-slide-up relative overflow-hidden mb-6 sm:mb-8">
        <div class="absolute -right-24 -top-24 w-96 h-96 bg-indigo-500/5 rounded-full blur-[100px]"></div>
        <h3 class="text-[9px] font-black text-slate-400 dark:text-slate-600 mb-4 sm:mb-6 uppercase tracking-[0.4em] flex items-center gap-2 sm:gap-3 relative z-10">
            <i class="fa-solid fa-plus-circle text-indigo-500 text-sm sm:text-base"></i> Add New Vehicle
        </h3>
        <form action="AddVehicleServlet" method="POST" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-5 md:gap-6 relative z-10">
            <input type="hidden" name="redirect" value="manage_vehicles.jsp?success=added">
            <div>
                <label class="block text-[8px] font-black text-slate-400 dark:text-slate-700 mb-2 uppercase tracking-widest">Plate ID</label>
                <input type="text" name="licensePlate" placeholder="ABC-1234" required pattern="[A-Z]{3}-[0-9]{4}" title="3 letters - 4 digits" class="w-full px-4 py-2.5 bg-slate-50 dark:bg-slate-950 border border-slate-200 dark:border-slate-800 rounded-xl text-xs sm:text-sm mono font-bold text-slate-900 dark:text-white focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all placeholder:text-slate-200 dark:placeholder:text-slate-805 shadow-inner">
            </div>
            <div>
                <label class="block text-[8px] font-black text-slate-400 dark:text-slate-700 mb-2 uppercase tracking-widest">Make</label>
                <input type="text" name="make" placeholder="Toyota" required class="w-full px-4 py-2.5 bg-slate-50 dark:bg-slate-950 border border-slate-200 dark:border-slate-800 rounded-xl text-xs sm:text-sm font-bold text-slate-900 dark:text-white focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all placeholder:text-slate-200 dark:placeholder:text-slate-805 shadow-inner">
            </div>
            <div>
                <label class="block text-[8px] font-black text-slate-400 dark:text-slate-700 mb-2 uppercase tracking-widest">Model</label>
                <input type="text" name="model" placeholder="Prius" required class="w-full px-4 py-2.5 bg-slate-50 dark:bg-slate-950 border border-slate-200 dark:border-slate-800 rounded-xl text-xs sm:text-sm font-bold text-slate-900 dark:text-white focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all placeholder:text-slate-200 dark:placeholder:text-slate-805 shadow-inner">
            </div>
            <div>
                <label class="block text-[8px] font-black text-slate-400 dark:text-slate-700 mb-2 uppercase tracking-widest">Year</label>
                <input type="number" name="year" placeholder="2020" required class="w-full px-4 py-2.5 bg-slate-50 dark:bg-slate-950 border border-slate-200 dark:border-slate-800 rounded-xl text-xs sm:text-sm font-bold text-slate-900 dark:text-white focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all placeholder:text-slate-200 dark:placeholder:text-slate-805 shadow-inner">
            </div>
            <div class="sm:col-span-2">
                <label class="block text-[8px] font-black text-slate-400 dark:text-slate-700 mb-2 uppercase tracking-widest">Owner Username</label>
                <select name="ownerUsername" required class="w-full px-4 py-2.5 bg-slate-50 dark:bg-slate-950 border border-slate-200 dark:border-slate-800 rounded-xl text-xs sm:text-sm font-bold text-slate-900 dark:text-white focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all shadow-inner appearance-none cursor-pointer">
                    <option value="" disabled selected>Select an owner</option>
                    <% for (AbstractUser u : allUsers) { 
                           if ("customer".equals(u.getRole())) { %>
                        <option value="<%= u.getUsername() %>">@<%= u.getUsername() %> - <%= u.getName() %></option>
                    <%     } 
                       } %>
                </select>
            </div>
            <div class="sm:col-span-2">
                <label class="block text-[8px] font-black text-slate-400 dark:text-slate-700 mb-2 uppercase tracking-widest">Mileage (KM)</label>
                <input type="number" name="mileage" placeholder="0" required class="w-full px-4 py-2.5 bg-slate-50 dark:bg-slate-950 border border-slate-200 dark:border-slate-800 rounded-xl text-xs sm:text-sm font-bold text-slate-900 dark:text-white focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all placeholder:text-slate-200 dark:placeholder:text-slate-805 shadow-inner">
            </div>
            <div class="sm:col-span-2 lg:col-span-4 mt-1">
                <button type="submit" class="w-full sm:w-auto bg-indigo-600 hover:bg-indigo-700 text-white px-8 py-3 rounded-xl shadow-2xl transition-all active:scale-95 font-black text-[9px] uppercase tracking-widest flex items-center justify-center gap-2">
                    <i class="fa-solid fa-plus-circle text-sm"></i> Add Vehicle
                </button>
            </div>
        </form>
    </div>

    <!-- VEHICLE LIST -->
    <% if (allCars.isEmpty()) { %>
    <div class="bg-white dark:bg-slate-800/40 backdrop-blur-md rounded-2xl border-2 border-dashed border-slate-200 dark:border-slate-800 p-20 text-center">
        <div class="w-20 h-20 rounded-full bg-slate-50 dark:bg-slate-950 flex items-center justify-center mx-auto mb-6 shadow-inner">
            <i class="fa-solid fa-car-side text-slate-300 dark:text-slate-800 text-4xl"></i>
        </div>
        <h3 class="text-xl font-black text-slate-900 dark:text-white tracking-tighter mb-2">No Vehicles Registered</h3>
        <p class="text-slate-500 dark:text-slate-400 font-medium text-xs">The vehicle database is currently empty.</p>
    </div>
    <% } else { %>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 fade-in">
        <% for (Vehicle car : allCars) {
               int svcCount = 0;
               Node n = shl.head;
               while (n != null) { if (car.getLicensePlate().equals(n.data.getLicensePlate())) svcCount++; n = n.next; }
        %>
        <div class="v-card bg-white dark:bg-slate-800/40 backdrop-blur-md rounded-2xl border border-slate-100 dark:border-slate-800 overflow-hidden shadow-xl shadow-slate-200/20 dark:shadow-none group" id="vcard-<%= car.getLicensePlate() %>">
            <div class="bg-slate-50 dark:bg-slate-950/60 p-4 flex items-center gap-4 border-b border-slate-100 dark:border-slate-800">
                <div class="w-10 h-10 rounded-xl bg-white dark:bg-slate-900 shadow-inner flex items-center justify-center text-slate-400 dark:text-slate-700 group-hover:text-indigo-500 transition-colors">
                    <i class="fa-solid fa-car-side text-lg"></i>
                </div>
                <div class="min-w-0 flex-1">
                    <p class="text-lg font-black text-slate-900 dark:text-white truncate leading-none"><%= car.getMake() %></p>
                    <p class="text-[8px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-widest mt-1.5"><%= car.getModel() %> • <%= car.getYear() %></p>
                </div>
            </div>
            
            <div class="p-4">
                <div class="flex justify-center mb-4">
                    <span class="mono bg-slate-950 dark:bg-slate-100 text-white dark:text-slate-950 px-4 py-1 rounded-xl font-black tracking-wider text-sm shadow-md border border-indigo-500/20"><%= car.getLicensePlate() %></span>
                </div>
                
                <div class="grid grid-cols-2 gap-3 mb-4">
                    <div class="bg-slate-50 dark:bg-slate-950/40 p-2.5 rounded-xl border border-slate-100 dark:border-slate-800">
                        <p class="text-[7px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-widest mb-0.5">Odometer</p>
                        <p class="text-xs font-bold text-slate-900 dark:text-white mono"><%= String.format("%,d", car.getMileage()) %> <span class="text-[8px] opacity-40">km</span></p>
                    </div>
                    <div class="bg-slate-50 dark:bg-slate-950/40 p-2.5 rounded-xl border border-slate-100 dark:border-slate-800">
                        <p class="text-[7px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-widest mb-0.5">Owner</p>
                        <p class="text-xs font-bold text-slate-900 dark:text-white truncate">@<%= car.getOwnerUsername() %></p>
                    </div>
                </div>

                <div class="flex items-center justify-between pt-4 border-t border-slate-50 dark:border-slate-800">
                    <span class="text-[8px] font-black text-indigo-600 dark:text-indigo-400 bg-indigo-50 dark:bg-indigo-900/30 px-2.5 py-1.5 rounded-lg border border-indigo-100 dark:border-indigo-800/50 uppercase tracking-widest flex items-center gap-1.5"><i class="fa-solid fa-wrench"></i> <%= svcCount %> Logs</span>
                    <div class="flex items-center gap-2">
                        <button onclick="openEditDrawer('<%= car.getLicensePlate() %>','<%= car.getMake() %>','<%= car.getModel() %>',<%= car.getYear() %>,<%= car.getMileage() %>,'<%= car.getOwnerUsername() %>')" class="w-8 h-8 rounded-xl bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 text-slate-400 dark:text-slate-700 hover:text-indigo-600 dark:hover:text-indigo-400 flex items-center justify-center transition-all shadow-sm active:scale-90" title="Edit"><i class="fa-solid fa-pen-nib text-[10px]"></i></button>
                        <button onclick="openDeleteDrawer('<%= car.getLicensePlate() %>','<%= car.getMake() %> <%= car.getModel() %>')" class="w-8 h-8 rounded-xl bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 text-slate-400 dark:text-slate-700 hover:text-rose-600 dark:hover:text-rose-400 flex items-center justify-center transition-all shadow-sm active:scale-90" title="Delete"><i class="fa-solid fa-trash-can text-[10px]"></i></button>
                    </div>
                </div>
            </div>
        </div>
        <% } %>
    </div>
    <% } %>
</div>

<!-- EDIT DRAWER -->
<div id="editDrawer" class="hidden fixed inset-0 z-[60]">
    <div class="drawer-backdrop absolute inset-0 bg-slate-950/40 backdrop-blur-md opacity-0" id="editBackdrop" onclick="closeEditDrawer()"></div>
    <div class="drawer-panel absolute top-0 right-0 bottom-0 w-full max-w-xl bg-white dark:bg-slate-900 shadow-2xl border-l border-slate-100 dark:border-slate-800 flex flex-col" id="editPanel">
        <div class="p-6 sm:p-10 border-b border-slate-50 dark:border-slate-800 flex justify-between items-center bg-slate-950">
            <div>
                <h3 class="text-2xl sm:text-3xl font-black text-white leading-tight">Edit Vehicle</h3>
                <p class="text-[10px] font-black text-indigo-500 uppercase tracking-[0.3em] mt-2">Update vehicle details</p>
            </div>
            <button onclick="closeEditDrawer()" class="w-12 h-12 rounded-2xl bg-slate-900 border border-slate-800 text-slate-400 hover:text-white transition-all flex items-center justify-center shadow-xl active:scale-90"><i class="fa-solid fa-xmark"></i></button>
        </div>
        <div class="p-6 sm:p-10 overflow-y-auto flex-1">
            <form action="AddVehicleServlet" method="POST" id="editForm" class="space-y-6 sm:space-y-8">
                <input type="hidden" name="editMode" value="true">
                <input type="hidden" name="redirect" value="manage_vehicles.jsp">
                <input type="hidden" name="originalPlate" id="editOrigPlate">
                <div>
                    <label class="block text-[10px] font-black text-slate-400 dark:text-slate-500 mb-4 uppercase tracking-widest text-center">License Plate</label>
                    <div class="flex justify-center">
                        <span class="mono text-xl sm:text-2xl font-black text-slate-900 dark:text-white bg-slate-50 dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 px-8 sm:px-10 py-3 sm:py-4 rounded-2xl shadow-inner" id="editPlateDisplay"></span>
                    </div>
                    <input type="hidden" name="licensePlate" id="editPlate">
                </div>
                <div class="grid grid-cols-2 gap-4 sm:gap-6">
                    <div>
                        <label class="block text-[10px] font-black text-slate-400 dark:text-slate-500 mb-3 uppercase tracking-widest">Make</label>
                        <input type="text" name="make" id="editMake" required class="edit-input w-full px-5 sm:px-6 py-3.5 sm:py-4 bg-slate-50 dark:bg-slate-950 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white" oninput="markEdited(this)">
                    </div>
                    <div>
                        <label class="block text-[10px] font-black text-slate-400 dark:text-slate-500 mb-3 uppercase tracking-widest">Model</label>
                        <input type="text" name="model" id="editModel" required class="edit-input w-full px-5 sm:px-6 py-3.5 sm:py-4 bg-slate-50 dark:bg-slate-950 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white" oninput="markEdited(this)">
                    </div>
                </div>
                <div class="grid grid-cols-2 gap-4 sm:gap-6">
                    <div>
                        <label class="block text-[10px] font-black text-slate-400 dark:text-slate-500 mb-3 uppercase tracking-widest">Year</label>
                        <input type="number" name="year" id="editYear" required class="edit-input w-full px-5 sm:px-6 py-3.5 sm:py-4 bg-slate-50 dark:bg-slate-950 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white" oninput="markEdited(this)">
                    </div>
                    <div>
                        <label class="block text-[10px] font-black text-slate-400 dark:text-slate-500 mb-3 uppercase tracking-widest">Mileage (KM)</label>
                        <input type="number" name="mileage" id="editMileage" required class="edit-input w-full px-5 sm:px-6 py-3.5 sm:py-4 bg-slate-50 dark:bg-slate-950 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white" oninput="markEdited(this)">
                    </div>
                </div>
                <div>
                    <label class="block text-[10px] font-black text-slate-400 dark:text-slate-500 mb-3 uppercase tracking-widest">Owner Username</label>
                    <select name="ownerUsername" id="editOwner" required class="edit-input w-full px-5 sm:px-6 py-3.5 sm:py-4 bg-slate-50 dark:bg-slate-950 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white appearance-none cursor-pointer" onchange="markEdited(this)">
                        <option value="" disabled>Select an owner</option>
                        <% for (AbstractUser u : allUsers) { %>
                            <option value="<%= u.getUsername() %>">@<%= u.getUsername() %> - <%= u.getName() %> (<%= u.getRole() %>)</option>
                        <% } %>
                    </select>
                </div>
                <div class="flex gap-4 pt-6 sm:pt-8">
                    <button type="submit" class="flex-1 py-4 sm:py-5 rounded-2xl sm:rounded-[2rem] bg-indigo-600 hover:bg-indigo-700 text-white font-black text-xs uppercase tracking-widest shadow-2xl transition-all active:scale-95 flex items-center justify-center gap-3">Update Vehicle</button>
                    <button type="button" onclick="closeEditDrawer()" class="px-6 sm:px-10 py-4 sm:py-5 rounded-2xl sm:rounded-[2rem] border-2 border-slate-100 dark:border-slate-800 text-slate-500 dark:text-slate-400 font-black text-xs uppercase tracking-widest hover:bg-slate-50 dark:hover:bg-slate-800 transition-all">Cancel</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- DELETE CONFIRMATION MODAL -->
<div id="deleteModal" class="hidden fixed inset-0 z-[200] flex items-center justify-center p-4 sm:p-6">
    <div class="absolute inset-0 bg-slate-950/80 backdrop-blur-xl opacity-0 transition-opacity duration-300" id="deleteBackdrop" onclick="closeDeleteDrawer()"></div>
    <div class="relative bg-white dark:bg-slate-900 rounded-2xl sm:rounded-3xl shadow-2xl max-w-sm w-full border border-slate-100 dark:border-slate-800 overflow-y-auto max-h-[calc(100vh-2rem)] sm:max-h-[90vh] custom-scrollbar transform scale-95 opacity-0 transition-all duration-300" id="deletePanel">
        <div class="p-6 sm:p-8 text-center">
            <div class="w-16 h-16 rounded-[1.5rem] bg-rose-50 dark:bg-rose-950 flex items-center justify-center mx-auto mb-6 text-rose-500 shadow-inner border border-rose-100 dark:border-rose-900/30">
                <i class="fa-solid fa-trash-can text-2xl"></i>
            </div>
            <h3 class="text-xl sm:text-2xl font-black text-slate-900 dark:text-white tracking-tighter">Remove Vehicle?</h3>
            <p class="text-xs sm:text-sm font-medium text-slate-500 dark:text-slate-400 mt-3 leading-relaxed">
                Are you sure you want to remove <span id="delCarName" class="font-bold text-slate-900 dark:text-white"></span> (<span id="delPlateDisplay" class="font-bold text-slate-900 dark:text-white"></span>) from registry? This action cannot be undone.
            </p>
            
            <div class="flex flex-col gap-3 mt-8">
                <a id="delLink" href="#" class="w-full py-4 rounded-xl bg-rose-600 hover:bg-rose-700 text-white font-black text-[10px] uppercase tracking-[0.2em] shadow-2xl transition-all active:scale-95 flex items-center justify-center gap-3">
                    <i class="fa-solid fa-trash-can text-base"></i> Confirm & Remove
                </a>
                <button type="button" onclick="closeDeleteDrawer()" class="w-full py-4 rounded-xl bg-white dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 text-slate-400 dark:text-slate-700 font-black text-[10px] uppercase tracking-[0.2em] hover:bg-slate-50 dark:hover:bg-slate-800 transition-all">
                    Cancel
                </button>
            </div>
        </div>
    </div>
</div>

<%@ include file="toast.jsp" %>
<script>
document.addEventListener("DOMContentLoaded", () => {
    const params = new URLSearchParams(window.location.search);
    if (params.get("success") === "added") showToast("Vehicle registered successfully.", "success");
    if (params.get("success") === "deleted") showToast("Vehicle removed from registry.", "info");
});

const editOriginals = {};

function openEditDrawer(plate, make, model, year, mileage, owner) {
    document.getElementById('editPlate').value = plate;
    document.getElementById('editOrigPlate').value = plate;
    document.getElementById('editPlateDisplay').textContent = plate;
    document.getElementById('editMake').value = make; editOriginals['editMake'] = make;
    document.getElementById('editModel').value = model; editOriginals['editModel'] = model;
    document.getElementById('editYear').value = year; editOriginals['editYear'] = String(year);
    document.getElementById('editMileage').value = mileage; editOriginals['editMileage'] = String(mileage);
    document.getElementById('editOwner').value = owner; editOriginals['editOwner'] = owner;
    document.querySelectorAll('.edit-input').forEach(el => el.classList.remove('modified-field'));
    const d = document.getElementById('editDrawer'); d.classList.remove('hidden');
    setTimeout(() => { document.getElementById('editBackdrop').style.opacity='1'; document.getElementById('editPanel').classList.add('open'); }, 20);
}
function closeEditDrawer() {
    document.getElementById('editBackdrop').style.opacity='0'; document.getElementById('editPanel').classList.remove('open');
    setTimeout(() => document.getElementById('editDrawer').classList.add('hidden'), 350);
}

function markEdited(el) {
    if (el.value !== editOriginals[el.id]) el.classList.add('modified-field');
    else el.classList.remove('modified-field');
}

function openDeleteDrawer(plate, name) {
    document.getElementById('delCarName').textContent = name;
    document.getElementById('delPlateDisplay').textContent = plate;
    document.getElementById('delLink').href = 'DeleteVehicleServlet?plate=' + encodeURIComponent(plate) + '&from=admin';
    const m = document.getElementById('deleteModal');
    const b = document.getElementById('deleteBackdrop');
    const p = document.getElementById('deletePanel');
    m.classList.remove('hidden');
    document.body.style.overflow = 'hidden';
    setTimeout(() => { b.style.opacity='1'; p.classList.remove('scale-95', 'opacity-0'); p.classList.add('scale-100', 'opacity-100'); }, 20);
}
function closeDeleteDrawer() {
    const b = document.getElementById('deleteBackdrop');
    const p = document.getElementById('deletePanel');
    b.style.opacity='0'; p.classList.remove('scale-100', 'opacity-100'); p.classList.add('scale-95', 'opacity-0');
    document.body.style.overflow = 'auto';
    setTimeout(() => document.getElementById('deleteModal').classList.add('hidden'), 300);
}
</script>
</body>
</html>