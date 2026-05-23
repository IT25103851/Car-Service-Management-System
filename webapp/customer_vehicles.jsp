<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.VehicleManager, model.Vehicle, java.util.List" %>
<%@ page import="model.ServiceHistoryList, model.ServiceRecord, model.Node" %>
<%@ page import="model.BookingManager, model.Appointment" %>
<%
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("userRole");
    if (username == null || !"customer".equals(role)) { response.sendRedirect("login.jsp"); return; }

    VehicleManager vManager = new VehicleManager();
    List<Vehicle> customerCars = vManager.getVehiclesByOwner(username);

    ServiceHistoryList shl = new ServiceHistoryList(); shl.loadFromFile();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Garage - SwiftDrive</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;700&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Plus Jakarta Sans', sans-serif; }
        .mono { font-family: 'JetBrains Mono', monospace; }
        .hero-card { transition: all 0.5s cubic-bezier(0.4, 0, 0.2, 1); }
        .hero-card:hover { transform: translateY(-8px); }
        .odo { font-family: 'JetBrains Mono', monospace; tracking: -0.05em; }
        .mileage-input { transition: all 0.5s cubic-bezier(0.4, 0, 0.2, 1); max-height: 0; opacity: 0; overflow: hidden; }
        .mileage-input.show { max-height: 120px; opacity: 1; margin-top: 24px; }
        
        .plate-tag { 
            background: #FEF9C3; 
            border: 2px solid #1a1a1a; 
            font-family: 'Courier New', monospace; 
            font-weight: 800; 
            text-transform: uppercase; 
            letter-spacing: .1em; 
            padding: 3px 10px; 
            border-radius: 4px; 
            font-size: 11px; 
            color: #1a1a1a; 
            white-space: nowrap; 
            display: inline-block; 
            line-height: 1; 
        }
        .dark .plate-tag {
            background: #1e293b;
            color: #f8fafc;
            border-color: #f8fafc;
        }

        @keyframes slideUp { from{opacity:0;transform:translateY(30px)} to{opacity:1;transform:translateY(0)} }
        .animate-slide-up { animation: slideUp 0.7s cubic-bezier(0.4, 0, 0.2, 1) forwards; }
    </style>
</head>
<body class="antialiased text-slate-900 dark:text-slate-100 bg-slate-50 dark:bg-slate-950 transition-colors duration-300 min-h-screen pt-28 pb-20">
<%@ include file="customer_navbar.jsp" %>

<div class="max-w-6xl mx-auto px-4">
    <!-- HEADER -->
    <div class="flex flex-col sm:flex-row justify-between items-stretch sm:items-start mb-8 sm:mb-16 gap-6 sm:gap-8">
        <div>
            <h1 class="text-3xl sm:text-4xl font-black text-slate-900 dark:text-white tracking-tighter leading-none flex items-center gap-3 sm:gap-4">
                <i class="fa-solid fa-car text-indigo-500"></i> My Garage
            </h1>
            <p class="mt-3 sm:mt-4 text-sm sm:text-base font-medium text-slate-500 dark:text-slate-400">Manage your vehicles, track mileage, and view service history.</p>
        </div>
    </div>

    <!-- REGISTRATION CORE -->
    <div class="bg-white dark:bg-slate-900 rounded-2xl border border-slate-100 dark:border-slate-800 p-5 sm:p-6 mb-6 sm:mb-8 shadow-sm animate-slide-up relative overflow-hidden">
        <div class="absolute -right-24 -top-24 w-64 h-64 bg-indigo-500/5 rounded-full blur-[80px]"></div>
        <h3 class="text-[9px] font-black text-slate-400 dark:text-slate-600 mb-4 sm:mb-6 uppercase tracking-[0.3em] flex items-center gap-2 relative z-10">
            <i class="fa-solid fa-plus-circle text-indigo-500 text-sm"></i> Add New Vehicle
        </h3>
        <form action="AddVehicleServlet" method="POST" class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4 items-end relative z-10">
            <input type="hidden" name="ownerUsername" value="<%= username %>">
            <input type="hidden" name="redirect" value="customer_vehicles.jsp?success=added">
            <div>
                <label class="block text-[8px] font-black text-slate-400 dark:text-slate-700 mb-2 uppercase tracking-widest text-center">Plate ID</label>
                <input type="text" name="licensePlate" placeholder="CAA-1234" required 
                       pattern="[A-Z]{3}-[0-9]{4}" 
                       title="Format: 3 uppercase letters, a hyphen, and 4 digits (e.g., CAA-1234)"
                       maxlength="8"
                       class="w-full px-4 py-2.5 bg-slate-50 dark:bg-slate-950 border border-slate-200 dark:border-slate-800 rounded-xl text-xs sm:text-sm mono font-black uppercase text-center focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white placeholder:text-slate-300 dark:placeholder:text-slate-700 shadow-sm">
            </div>
            <div>
                <label class="block text-[8px] font-black text-slate-400 dark:text-slate-700 mb-2 uppercase tracking-widest">Make</label>
                <input type="text" name="make" list="makeList" placeholder="Toyota" required class="w-full px-4 py-2.5 bg-slate-50 dark:bg-slate-950 border border-slate-200 dark:border-slate-800 rounded-xl text-xs font-black focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white placeholder:text-slate-300 dark:placeholder:text-slate-750 shadow-sm">
                <datalist id="makeList"><option value="Toyota"><option value="Honda"><option value="Suzuki"><option value="Nissan"><option value="Bajaj"><option value="Mitsubishi"><option value="BMW"><option value="Benz"><option value="Hyundai"><option value="KIA"></datalist>
            </div>
            <div>
                <label class="block text-[8px] font-black text-slate-400 dark:text-slate-700 mb-2 uppercase tracking-widest">Model</label>
                <input type="text" name="model" placeholder="Prius" required class="w-full px-4 py-2.5 bg-slate-50 dark:bg-slate-950 border border-slate-200 dark:border-slate-800 rounded-xl text-xs font-black focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white placeholder:text-slate-300 dark:placeholder:text-slate-750 shadow-sm">
            </div>
            <div>
                <label class="block text-[8px] font-black text-slate-400 dark:text-slate-700 mb-2 uppercase tracking-widest">Year</label>
                <input type="number" name="year" placeholder="2024" min="1990" max="2026" required class="w-full px-4 py-2.5 bg-slate-50 dark:bg-slate-950 border border-slate-200 dark:border-slate-800 rounded-xl text-xs font-black focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white placeholder:text-slate-300 dark:placeholder:text-slate-750 shadow-sm">
            </div>
            <div>
                <label class="block text-[8px] font-black text-slate-400 dark:text-slate-700 mb-2 uppercase tracking-widest">Odometer</label>
                <input type="number" name="mileage" placeholder="0" required class="w-full px-4 py-2.5 bg-slate-50 dark:bg-slate-950 border border-slate-200 dark:border-slate-800 rounded-xl text-xs font-black focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white placeholder:text-slate-300 dark:placeholder:text-slate-750 shadow-sm">
            </div>
            <div class="sm:col-span-2 md:col-span-3 lg:col-span-5 mt-2">
                <button type="submit" class="w-full sm:w-auto px-6 py-3 bg-indigo-600 hover:bg-indigo-700 text-white font-black text-[9px] uppercase tracking-widest rounded-xl shadow-md transition-all active:scale-95 flex items-center justify-center gap-2">
                    <i class="fa-solid fa-plus-circle text-xs"></i> Add Vehicle
                </button>
            </div>
        </form>
    </div>

    <!-- ASSET STREAM -->
    <% if (customerCars.isEmpty()) { %>
    <div class="bg-white dark:bg-slate-900 rounded-[2rem] border-2 border-dashed border-slate-100 dark:border-slate-800 p-16 sm:p-24 text-center animate-slide-up shadow-sm">
        <div class="w-20 h-20 bg-slate-50 dark:bg-slate-950 rounded-full flex items-center justify-center mx-auto mb-6 shadow-inner">
            <i class="fa-solid fa-car-tunnel text-slate-355 dark:text-slate-750 text-4xl"></i>
        </div>
        <h3 class="text-xl sm:text-2xl font-black text-slate-900 dark:text-white tracking-tight mb-2">Garage is Empty</h3>
        <p class="text-slate-500 dark:text-slate-400 font-medium text-sm max-w-xs mx-auto mb-6">You haven't added any vehicles to your garage yet.</p>
        <button onclick="document.querySelector('input[name=licensePlate]').focus()" class="bg-indigo-600 hover:bg-indigo-700 text-white px-8 py-3.5 rounded-xl shadow-md font-black text-[9px] uppercase tracking-widest transition-all active:scale-95 flex items-center gap-2 mx-auto">
            <i class="fa-solid fa-plus-circle text-xs"></i> Add Your First Vehicle
        </button>
    </div>
    <% } else { %>
    <div class="space-y-6 sm:space-y-8 animate-slide-up">
        <% for (Vehicle car : customerCars) {
               int svcCount = 0; double totalSpent = 0; String lastDate = "—";
               Node n = shl.head;
               while (n != null) {
                   if (car.getLicensePlate().equals(n.data.getLicensePlate())) {
                       svcCount++; totalSpent += n.data.getCost();
                       if (lastDate.equals("—") || n.data.getDate().compareTo(lastDate) > 0) lastDate = n.data.getDate();
                   }
                   n = n.next;
               }
        %>
        <div class="hero-card bg-white dark:bg-slate-900 rounded-2xl border border-slate-100 dark:border-slate-800 overflow-hidden shadow-sm group mb-6">
            <div class="flex flex-col lg:flex-row">
                <!-- VEHICLE DETAILS -->
                <div class="bg-slate-50 dark:bg-slate-950/50 p-5 sm:p-6 lg:w-72 flex-shrink-0 flex flex-col items-center justify-center border-b lg:border-b-0 lg:border-r border-slate-100 dark:border-slate-800 transition-colors">
                    <div class="w-16 h-16 rounded-xl bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 shadow-sm flex items-center justify-center text-slate-350 dark:text-slate-700 mb-3 relative">
                        <i class="fa-solid fa-car-side text-2xl relative z-10"></i>
                    </div>
                    <h3 class="text-lg font-black text-slate-900 dark:text-white text-center leading-none tracking-tight"><%= car.getMake() %><br/><span class="text-indigo-500 text-xs mt-1.5 inline-block"><%= car.getModel() %></span></h3>
                    <span class="bg-slate-100 dark:bg-slate-800 text-slate-500 dark:text-slate-450 text-[8px] font-black px-2.5 py-1 rounded-lg mt-3 uppercase tracking-widest">YEAR: <%= car.getYear() %></span>
                    <div class="mt-4">
                        <span class="mono text-xs font-black text-slate-900 dark:text-white bg-white dark:bg-slate-900 border border-slate-900 dark:border-indigo-500/50 px-4 py-1.5 rounded-lg tracking-wider shadow-sm"><%= car.getLicensePlate() %></span>
                    </div>
                </div>
                <!-- VEHICLE STATUS -->
                <div class="flex-1 p-5 sm:p-6 md:p-8 flex flex-col justify-center">
                    <div class="mb-6">
                        <p class="text-[8px] font-black text-slate-400 dark:text-slate-650 uppercase tracking-widest mb-1.5 flex items-center gap-1.5">
                            <i class="fa-solid fa-gauge-high"></i> CURRENT MILEAGE
                        </p>
                        <div class="flex items-baseline gap-2">
                            <p class="odo text-2xl sm:text-3xl font-black text-slate-900 dark:text-white tracking-tight leading-none" id="odo-<%= car.getLicensePlate() %>"><%= String.format("%,d", car.getMileage()) %></p>
                            <span class="text-xs font-bold text-slate-400 dark:text-slate-650">KM</span>
                        </div>
                        <button type="button" onclick="toggleMileage('<%= car.getLicensePlate() %>')" class="text-[8px] font-black text-indigo-600 dark:text-indigo-400 hover:text-indigo-500 mt-2 transition-all flex items-center gap-1.5 uppercase tracking-widest active:scale-95">
                            <i class="fa-solid fa-pen-nib"></i> Update Mileage
                        </button>
                        <div class="mileage-input" id="mileageForm-<%= car.getLicensePlate() %>">
                            <div class="flex gap-3 mt-3 bg-slate-50 dark:bg-slate-950 p-3 rounded-xl border border-slate-100 dark:border-slate-800 shadow-inner">
                                <input type="number" id="mileageInput-<%= car.getLicensePlate() %>" value="<%= car.getMileage() %>" class="flex-1 bg-white dark:bg-slate-900 px-4 py-2 rounded-lg text-xs font-black border border-slate-200 dark:border-slate-800 focus:border-indigo-500 outline-none transition-all dark:text-white mono shadow-sm">
                                <button type="button" onclick="saveMileage('<%= car.getLicensePlate() %>')" class="px-4 py-2 bg-indigo-600 text-white font-black text-[9px] uppercase tracking-widest rounded-lg shadow-md active:scale-95 transition-all">Update</button>
                            </div>
                        </div>
                    </div>
                    
                    <div class="grid grid-cols-3 gap-3 mb-6">
                        <div class="bg-slate-50 dark:bg-slate-950/60 rounded-xl p-3 border border-slate-100 dark:border-slate-800 shadow-inner">
                            <p class="text-[8px] font-black text-slate-400 dark:text-slate-650 uppercase tracking-widest mb-1">Service Logs</p>
                            <p class="text-sm sm:text-base font-black text-slate-900 dark:text-white mono"><%= svcCount %></p>
                        </div>
                        <div class="bg-slate-50 dark:bg-slate-950/60 rounded-xl p-3 border border-slate-100 dark:border-slate-800 shadow-inner">
                            <p class="text-[8px] font-black text-slate-400 dark:text-slate-650 uppercase tracking-widest mb-1">Last Service</p>
                            <p class="text-[10px] font-black text-slate-900 dark:text-slate-300 truncate mono uppercase"><%= lastDate %></p>
                        </div>
                        <div class="bg-slate-50 dark:bg-slate-950/60 rounded-xl p-3 border border-slate-100 dark:border-slate-800 shadow-inner">
                            <p class="text-[8px] font-black text-slate-400 dark:text-slate-650 uppercase tracking-widest mb-1">Total Cost</p>
                            <p class="text-xs font-black text-emerald-600 dark:text-emerald-400 mono">LKR <%= String.format("%,.0f", totalSpent) %></p>
                        </div>
                    </div>

                    <div class="flex flex-col sm:flex-row gap-3">
                        <a href="book_appointment.jsp" class="flex-1 py-2.5 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white font-black text-[9px] uppercase tracking-widest shadow-md transition-all active:scale-95 text-center flex items-center justify-center gap-2">
                            <i class="fa-solid fa-calendar-plus text-xs"></i> Book Service
                        </a>
                        <button type="button" onclick="openServiceHistoryModal('<%= car.getLicensePlate() %>')" class="flex-1 py-2.5 rounded-xl bg-white dark:bg-slate-955 border border-slate-200 dark:border-slate-800 text-slate-550 dark:text-slate-455 font-black text-[9px] uppercase tracking-widest transition-all hover:bg-slate-50 dark:hover:bg-slate-800 text-center flex items-center justify-center gap-2 shadow-sm">
                            <i class="fa-solid fa-clock-rotate-left text-xs text-indigo-500"></i> Service History
                        </button>
                        <button type="button" onclick="openEditModal('<%= car.getLicensePlate() %>', '<%= car.getMake() %>', '<%= car.getModel() %>', <%= car.getYear() %>, <%= car.getMileage() %>)" class="w-full sm:w-10 h-10 rounded-xl bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-800 text-slate-400 hover:text-indigo-600 flex items-center justify-center transition-all active:scale-90" title="Edit Vehicle">
                            <i class="fa-solid fa-pen text-sm"></i>
                        </button>
                        <button type="button" onclick="openDeleteModal('<%= car.getLicensePlate() %>')" class="w-full sm:w-10 h-10 rounded-xl bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-800 text-slate-400 hover:text-rose-600 flex items-center justify-center transition-all active:scale-90" title="Remove Vehicle">
                            <i class="fa-solid fa-trash-can text-sm"></i>
                        </button>
                    </div>
                </div>
            </div>
            
            <!-- Hidden Service History Logs for JavaScript to Load -->
            <div id="logs-<%= car.getLicensePlate() %>" class="hidden">
                <% 
                   boolean hasLogs = false;
                   Node logNode = shl.head;
                   while (logNode != null) {
                       if (car.getLicensePlate().equals(logNode.data.getLicensePlate())) {
                           hasLogs = true;
                %>
                    <div class="p-3.5 bg-slate-50 dark:bg-slate-950/40 rounded-xl border border-slate-100 dark:border-slate-800/60 flex flex-col gap-2 transition-all">
                        <div class="flex justify-between items-center">
                            <span class="text-[9px] font-black uppercase tracking-widest text-slate-400"><%= logNode.data.getDate() %></span>
                            <span class="text-xs font-black text-emerald-600 dark:text-emerald-400 mono">LKR <%= String.format("%,.0f", logNode.data.getCost()) %></span>
                        </div>
                        <div>
                            <h4 class="text-xs font-black text-slate-800 dark:text-white"><%= logNode.data.getServiceType() %></h4>
                            <p class="text-[10px] text-slate-550 dark:text-slate-400 mt-1 leading-relaxed"><i class="fa-solid fa-gears mr-1 text-indigo-500"></i> <%= logNode.data.getPartsUsed() != null ? logNode.data.getPartsUsed() : "No physical parts recorded." %></p>
                        </div>
                    </div>
                <% 
                       }
                       logNode = logNode.next;
                   }
                   if (!hasLogs) {
                %>
                    <div class="py-8 text-center">
                        <div class="w-12 h-12 bg-slate-50 dark:bg-slate-950/50 rounded-full flex items-center justify-center mx-auto mb-3">
                            <i class="fa-solid fa-clipboard-list text-slate-350 dark:text-slate-700 text-lg"></i>
                        </div>
                        <p class="text-xs font-bold text-slate-500 dark:text-slate-400">No service logs recorded for this vehicle.</p>
                    </div>
                <% } %>
            </div>
        </div>
        <% } %>
    </div>
    <% } %>
</div>

<!-- DELETE CONFIRMATION MODAL -->
<div id="deleteModal" class="hidden fixed inset-0 z-[200] flex items-center justify-center p-4 sm:p-6">
    <div class="absolute inset-0 bg-slate-950/80 backdrop-blur-xl opacity-0 transition-opacity duration-300" id="deleteBackdrop" onclick="closeDeleteModal()"></div>
    <div class="relative bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] shadow-2xl max-w-sm w-full border border-slate-100 dark:border-slate-800 overflow-y-auto max-h-[calc(100vh-2rem)] sm:max-h-[90vh] custom-scrollbar transform scale-95 opacity-0 transition-all duration-300" id="deletePanel">
        <div class="p-6 sm:p-10 md:p-12 text-center">
            <div class="w-16 h-16 sm:w-24 sm:h-24 rounded-[1.5rem] sm:rounded-[2rem] bg-rose-50 dark:bg-rose-955 flex items-center justify-center mx-auto mb-6 sm:mb-10 text-rose-500 shadow-inner border border-rose-100 dark:border-rose-900/30">
                <i class="fa-solid fa-trash-can text-2xl sm:text-4xl"></i>
            </div>
            <h3 class="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white tracking-tighter">Remove Vehicle?</h3>
            <p class="text-xs sm:text-sm font-medium text-slate-500 dark:text-slate-400 mt-3 sm:mt-4 leading-relaxed">
                Are you sure you want to remove <span id="deleteItemDisplay" class="font-bold text-slate-900 dark:text-white"></span> from your garage? This action cannot be undone.
            </p>
            
            <div class="flex flex-col gap-3 sm:gap-4 mt-8 sm:mt-10">
                <a id="confirmDeleteBtn" href="#" class="w-full py-4 sm:py-5 rounded-xl sm:rounded-2xl bg-rose-600 hover:bg-rose-700 text-white font-black text-[10px] uppercase tracking-[0.2em] shadow-2xl shadow-rose-100 dark:shadow-none transition-all active:scale-95 flex items-center justify-center gap-3 sm:gap-4">
                    <i class="fa-solid fa-trash-can text-base sm:text-lg"></i> Confirm & Remove
                </a>
                <button type="button" onclick="closeDeleteModal()" class="w-full py-4 sm:py-5 rounded-xl sm:rounded-2xl bg-white dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 text-slate-400 dark:text-slate-700 font-black text-[10px] uppercase tracking-[0.2em] hover:bg-slate-50 dark:hover:bg-slate-800 transition-all">
                    Cancel
                </button>
            </div>
        </div>
    </div>
</div>

<!-- EDIT VEHICLE MODAL -->
<div id="editModal" class="hidden fixed inset-0 z-[200] flex items-center justify-center p-4 sm:p-6">
    <div class="absolute inset-0 bg-slate-955/80 backdrop-blur-xl opacity-0 transition-opacity duration-300" id="editBackdrop" onclick="closeEditModal()"></div>
    <div class="relative bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[2.5rem] shadow-2xl max-w-md w-full border border-slate-100 dark:border-slate-800 overflow-y-auto max-h-[calc(100vh-2rem)] sm:max-h-[90vh] custom-scrollbar transform scale-95 opacity-0 transition-all duration-300" id="editPanel">
        <div class="p-6 sm:p-10">
            <div class="flex justify-between items-center mb-6 pb-4 border-b border-slate-100 dark:border-slate-800">
                <div class="flex items-center gap-2.5">
                    <div class="w-9 h-9 rounded-xl bg-indigo-50 dark:bg-indigo-900/40 flex items-center justify-center text-indigo-600 dark:text-indigo-400">
                        <i class="fa-solid fa-pen text-sm"></i>
                    </div>
                    <div>
                        <h3 class="text-sm font-black text-slate-900 dark:text-white uppercase tracking-wider">Edit Vehicle</h3>
                        <p class="text-[9px] font-black text-slate-400 dark:text-slate-500 tracking-widest uppercase mt-0.5">Update Details</p>
                    </div>
                </div>
                <button onclick="closeEditModal()" class="w-7 h-7 rounded-lg bg-slate-50 dark:bg-slate-955 hover:bg-slate-100 dark:hover:bg-slate-800 text-slate-400 hover:text-slate-600 transition-all flex items-center justify-center">
                    <i class="fa-solid fa-xmark text-sm"></i>
                </button>
            </div>

            <form action="AddVehicleServlet" method="POST" class="space-y-4">
                <input type="hidden" name="editMode" value="true">
                <input type="hidden" name="redirect" value="customer_vehicles.jsp?success=updated">
                <input type="hidden" name="originalPlate" id="editOrigPlate">
                <input type="hidden" name="licensePlate" id="editPlate">
                <input type="hidden" name="ownerUsername" value="<%= username %>">
                
                <div class="flex justify-center mb-4">
                    <span class="mono bg-slate-950 dark:bg-slate-100 text-white dark:text-slate-955 px-4 py-1.5 rounded-xl font-black tracking-wider text-sm shadow-md border border-indigo-500/20" id="editPlateDisplay"></span>
                </div>

                <div>
                    <label class="block text-[8px] font-black text-slate-400 dark:text-slate-700 mb-2 uppercase tracking-widest">Make</label>
                    <input type="text" name="make" id="editMake" list="editMakeList" required class="w-full px-4 py-2.5 bg-slate-50 dark:bg-slate-950 border border-slate-200 dark:border-slate-800 rounded-xl text-xs font-black focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white shadow-sm">
                    <datalist id="editMakeList"><option value="Toyota"><option value="Honda"><option value="Suzuki"><option value="Nissan"><option value="Bajaj"><option value="Mitsubishi"><option value="BMW"><option value="Benz"><option value="Hyundai"><option value="KIA"></datalist>
                </div>
                <div>
                    <label class="block text-[8px] font-black text-slate-400 dark:text-slate-700 mb-2 uppercase tracking-widest">Model</label>
                    <input type="text" name="model" id="editModel" required class="w-full px-4 py-2.5 bg-slate-50 dark:bg-slate-950 border border-slate-200 dark:border-slate-800 rounded-xl text-xs font-black focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white shadow-sm">
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-[8px] font-black text-slate-400 dark:text-slate-700 mb-2 uppercase tracking-widest">Year</label>
                        <input type="number" name="year" id="editYear" min="1990" max="2026" required class="w-full px-4 py-2.5 bg-slate-50 dark:bg-slate-950 border border-slate-200 dark:border-slate-800 rounded-xl text-xs font-black focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white shadow-sm">
                    </div>
                    <div>
                        <label class="block text-[8px] font-black text-slate-400 dark:text-slate-700 mb-2 uppercase tracking-widest">Odometer (KM)</label>
                        <input type="number" name="mileage" id="editMileage" required class="w-full px-4 py-2.5 bg-slate-50 dark:bg-slate-950 border border-slate-200 dark:border-slate-800 rounded-xl text-xs font-black focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white shadow-sm">
                    </div>
                </div>

                <div class="flex gap-3 pt-4">
                    <button type="submit" class="flex-1 py-3 bg-indigo-600 hover:bg-indigo-700 text-white font-black text-[9px] uppercase tracking-widest rounded-xl shadow-md transition-all active:scale-95 flex items-center justify-center gap-2">
                        Update Vehicle
                    </button>
                    <button type="button" onclick="closeEditModal()" class="px-5 py-3 bg-slate-50 dark:bg-slate-955 border border-slate-200 dark:border-slate-800 text-slate-655 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-850 font-black text-[9px] uppercase tracking-widest transition-all rounded-xl">
                        Cancel
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- SERVICE HISTORY MODAL -->
<div id="serviceHistoryModal" class="hidden fixed inset-0 z-[200] flex items-center justify-center p-4">
    <div class="absolute inset-0 bg-slate-950/60 backdrop-blur-sm opacity-0 transition-opacity duration-300" id="historyBackdrop" onclick="closeServiceHistoryModal()"></div>
    <div class="relative bg-white dark:bg-slate-900 rounded-2xl shadow-2xl max-w-md w-full border border-slate-150 dark:border-slate-800 overflow-y-auto max-h-[calc(100vh-2rem)] sm:max-h-[90vh] custom-scrollbar transform scale-95 opacity-0 transition-all duration-300" id="historyPanel">
        <div class="p-6">
            <div class="flex justify-between items-center mb-6 pb-4 border-b border-slate-100 dark:border-slate-800">
                <div class="flex items-center gap-2.5">
                    <div class="w-9 h-9 rounded-xl bg-indigo-50 dark:bg-indigo-900/40 flex items-center justify-center text-indigo-600 dark:text-indigo-400">
                        <i class="fa-solid fa-clock-rotate-left text-sm"></i>
                    </div>
                    <div>
                        <h3 class="text-sm font-black text-slate-900 dark:text-white uppercase tracking-wider" id="historyModalTitle">Service History</h3>
                        <p class="text-[9px] font-black text-slate-400 dark:text-slate-500 tracking-widest uppercase mt-0.5">Maintenance Logs</p>
                    </div>
                </div>
                <button onclick="closeServiceHistoryModal()" class="w-7 h-7 rounded-lg bg-slate-50 dark:bg-slate-955 hover:bg-slate-100 dark:hover:bg-slate-800 text-slate-400 hover:text-slate-600 transition-all flex items-center justify-center">
                    <i class="fa-solid fa-xmark text-sm"></i>
                </button>
            </div>
            
            <div class="max-h-[350px] overflow-y-auto space-y-3 pr-1 no-scrollbar" id="historyModalContent">
                <!-- Appended dynamically by JavaScript -->
            </div>
            
            <div class="mt-6 pt-4 border-t border-slate-100 dark:border-slate-800 flex justify-end">
                <button type="button" onclick="closeServiceHistoryModal()" class="px-5 py-2.5 rounded-lg bg-slate-50 dark:bg-slate-950 border border-slate-200 dark:border-slate-800 text-slate-650 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-850 font-black text-[9px] uppercase tracking-widest transition-all">
                    Close History
                </button>
            </div>
        </div>
    </div>
</div>

<%@ include file="toast.jsp" %>
<script>
document.addEventListener("DOMContentLoaded", () => {
    <% if ("added".equals(request.getParameter("success"))) { %>showToast("Vehicle added successfully.", "success");<% } %>
    <% if ("updated".equals(request.getParameter("success"))) { %>showToast("Vehicle details updated.", "success");<% } %>
    <% if ("deleted".equals(request.getParameter("success"))) { %>showToast("Vehicle removed from garage.", "info");<% } %>
});

function toggleMileage(plate) {
    document.getElementById('mileageForm-' + plate).classList.toggle('show');
}

function saveMileage(plate) {
    const input = document.getElementById('mileageInput-' + plate);
    const newMileage = parseInt(input.value);
    if (isNaN(newMileage) || newMileage < 0) return;
    const params = new URLSearchParams();
    params.append('plate', plate);
    params.append('mileage', newMileage);
    fetch('UpdateMileageServlet', { method: 'POST', body: params })
    .then(() => {
        document.getElementById('odo-' + plate).textContent = newMileage.toLocaleString();
        document.getElementById('mileageForm-' + plate).classList.remove('show');
        showToast('Mileage updated: ' + newMileage.toLocaleString() + ' KM', 'success');
    });
}

function openEditModal(plate, make, model, year, mileage) {
    const m = document.getElementById('editModal');
    const b = document.getElementById('editBackdrop');
    const p = document.getElementById('editPanel');
    
    document.getElementById('editPlate').value = plate;
    document.getElementById('editOrigPlate').value = plate;
    document.getElementById('editPlateDisplay').textContent = plate;
    document.getElementById('editMake').value = make;
    document.getElementById('editModel').value = model;
    document.getElementById('editYear').value = year;
    document.getElementById('editMileage').value = mileage;
    
    m.classList.remove('hidden');
    document.body.style.overflow = 'hidden';
    setTimeout(() => { b.style.opacity='1'; p.classList.remove('scale-95', 'opacity-0'); p.classList.add('scale-100', 'opacity-100'); }, 20);
}

function closeEditModal() {
    const b = document.getElementById('editBackdrop');
    const p = document.getElementById('editPanel');
    b.style.opacity='0'; p.classList.remove('scale-100', 'opacity-100'); p.classList.add('scale-95', 'opacity-0');
    document.body.style.overflow = 'auto';
    setTimeout(() => document.getElementById('editModal').classList.add('hidden'), 300);
}

function openDeleteModal(plate) {
    const m = document.getElementById('deleteModal');
    const b = document.getElementById('deleteBackdrop');
    const p = document.getElementById('deletePanel');
    const btn = document.getElementById('confirmDeleteBtn');
    const display = document.getElementById('deleteItemDisplay');
    
    display.textContent = plate;
    btn.href = 'DeleteVehicleServlet?plate=' + encodeURIComponent(plate) + '&from=customer';
    
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

function openServiceHistoryModal(plate) {
    const modal = document.getElementById('serviceHistoryModal');
    const backdrop = document.getElementById('historyBackdrop');
    const panel = document.getElementById('historyPanel');
    const title = document.getElementById('historyModalTitle');
    const content = document.getElementById('historyModalContent');
    
    title.textContent = "Service History — " + plate;
    
    const logs = document.getElementById('logs-' + plate);
    if (logs) {
        content.innerHTML = logs.innerHTML;
    } else {
        content.innerHTML = '<div class="py-8 text-center text-slate-400">No logs found.</div>';
    }
    
    modal.classList.remove('hidden');
    document.body.style.overflow = 'hidden';
    setTimeout(() => {
        backdrop.style.opacity = '1';
        panel.classList.remove('scale-95', 'opacity-0');
        panel.classList.add('scale-100', 'opacity-100');
    }, 20);
}

function closeServiceHistoryModal() {
    const backdrop = document.getElementById('historyBackdrop');
    const panel = document.getElementById('historyPanel');
    backdrop.style.opacity = '0';
    panel.classList.remove('scale-100', 'opacity-100');
    panel.classList.add('scale-95', 'opacity-0');
    document.body.style.overflow = 'auto';
    setTimeout(() => {
        document.getElementById('serviceHistoryModal').classList.add('hidden');
    }, 300);
}
</script>
<%@ include file="logout_script.jsp" %>
</body>
</html>
