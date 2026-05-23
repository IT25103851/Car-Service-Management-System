<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.VehicleManager, model.Vehicle, java.util.List, java.util.ArrayList, java.util.Map, java.util.HashMap" %>
<%@ page import="model.ServiceTypeManager, model.ServiceType" %>
<%@ page import="model.UserManager, model.AbstractUser, model.CustomerUser" %>
<%@ include file="navbar.jsp" %>
<%
    String role = (String) session.getAttribute("userRole");
    if (!"admin".equals(role)) { response.sendRedirect("login.jsp"); return; }
    
    VehicleManager vManager = new VehicleManager();
    List<Vehicle> allCars = vManager.getAllVehicles();
    
    ServiceTypeManager stm = new ServiceTypeManager();
    List<ServiceType> sTypes = stm.getAllServices();
    
    UserManager uManager = new UserManager();
    List<AbstractUser> allUsers = uManager.getAllUsers();
    List<CustomerUser> customers = new ArrayList<>();
    for(AbstractUser u : allUsers) {
        if(u instanceof CustomerUser && u.isActive()) {
            customers.add((CustomerUser)u);
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Service Record - SwiftDrive</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Flatpickr -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/airbnb.css">
    <style>
        * { font-family: 'Plus Jakarta Sans', sans-serif; }
        .field-error { border-color: #DC2626 !important; box-shadow: 0 0 0 2px rgba(220,38,38,0.15) !important; }
        .error-msg { color: #DC2626; font-size: 11px; font-weight: 600; margin-top: 4px; display: none; }
        .error-msg.show { display: block; }
        .cost-card { box-shadow: 0 4px 24px rgba(0,0,0,0.07); }
        
        /* Custom Radio Styles for toggle */
        .type-radio:checked + div {
            border-color: #4f46e5;
            background-color: #e0e7ff;
        }
        .dark .type-radio:checked + div {
            border-color: #6366f1;
            background-color: rgba(99, 102, 241, 0.1);
        }

        /* Flatpickr Customization */
        .flatpickr-calendar {
            background: #ffffff !important;
            border-radius: 2rem !important;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.08) !important;
            border: 1px solid #f1f5f9 !important;
            font-family: inherit !important;
            padding: 0.5rem !important;
        }
        .flatpickr-wrapper {
            display: block !important;
            width: 100% !important;
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
            color: #d97706 !important; /* amber-600 */
        }
        .dark .flatpickr-current-month {
            color: #fbbf24 !important; /* amber-400 */
        }
        .flatpickr-months .flatpickr-prev-month, .flatpickr-months .flatpickr-next-month {
            color: #d97706 !important;
            fill: #d97706 !important;
        }
        .dark .flatpickr-months .flatpickr-prev-month, .dark .flatpickr-months .flatpickr-next-month {
            color: #fbbf24 !important;
            fill: #fbbf24 !important;
        }
        .flatpickr-day {
            color: #475569 !important;
        }
        .dark .flatpickr-day {
            color: #94a3b8 !important;
        }
        .flatpickr-day.selected {
            background: #d97706 !important;
            border-color: #d97706 !important;
            border-radius: 12px !important;
            color: #fff !important;
        }
        .flatpickr-day.flatpickr-disabled, .flatpickr-day.flatpickr-disabled:hover {
            color: #e2e8f0 !important;
        }
        .dark .flatpickr-day.flatpickr-disabled {
            color: #334155 !important;
        }
    </style>
</head>
<body class="antialiased text-slate-900 dark:text-slate-100 bg-slate-50 dark:bg-slate-950 transition-colors duration-300 pt-28 pb-16">

<div class="max-w-5xl mx-auto px-4">
    <a href="dashboard.jsp" class="text-sm font-bold text-slate-400 hover:text-amber-600 dark:hover:text-amber-500 transition mb-4 inline-block"><i class="fa-solid fa-arrow-left mr-1"></i> Back to Dashboard</a>
    <h1 class="text-3xl font-black text-slate-900 dark:text-white tracking-tighter mb-8 flex items-center gap-4">
        <div class="w-10 h-10 rounded-xl bg-amber-500/10 flex items-center justify-center text-amber-600">
            <i class="fa-solid fa-plus"></i>
        </div>
        New Service Record
    </h1>

    <div class="flex flex-col lg:flex-row gap-8">
        <!-- LEFT: FORM -->
        <div class="flex-1 min-w-0">
            <form action="AddServiceServlet" method="POST" id="addForm" class="space-y-5" onsubmit="return validateForm()">
                <input type="hidden" name="customerMode" id="customerMode" value="registered">
                
                <!-- CUSTOMER TYPE TOGGLE -->
                <div class="grid grid-cols-2 gap-4 mb-6">
                    <label class="cursor-pointer relative">
                        <input type="radio" name="cType" class="peer sr-only type-radio" value="registered" checked onchange="toggleMode('registered')">
                        <div class="p-4 rounded-2xl border-2 border-slate-200 dark:border-slate-800 transition-all flex items-center gap-3">
                            <div class="w-4 h-4 rounded-full border-2 border-slate-300 dark:border-slate-600 peer-checked:border-indigo-600 peer-checked:border-[5px] transition-all"></div>
                            <span class="font-bold text-sm text-slate-700 dark:text-slate-300">Registered Customer</span>
                        </div>
                    </label>
                    <label class="cursor-pointer relative">
                        <input type="radio" name="cType" class="peer sr-only type-radio" value="walkin" onchange="toggleMode('walkin')">
                        <div class="p-4 rounded-2xl border-2 border-slate-200 dark:border-slate-800 transition-all flex items-center gap-3">
                            <div class="w-4 h-4 rounded-full border-2 border-slate-300 dark:border-slate-600 peer-checked:border-indigo-600 peer-checked:border-[5px] transition-all"></div>
                            <span class="font-bold text-sm text-slate-700 dark:text-slate-300">Walk-in Customer</span>
                        </div>
                    </label>
                </div>

                <!-- REGISTERED CUSTOMER SECTION -->
                <div id="section-registered" class="bg-white dark:bg-slate-900 rounded-[2rem] border border-slate-200 dark:border-slate-800 p-8 shadow-2xl shadow-slate-200/40 dark:shadow-none transition-all duration-300">
                    <h3 class="text-[10px] font-black text-slate-500 dark:text-slate-400 mb-6 uppercase tracking-[0.3em] flex items-center gap-3">
                        <i class="fa-solid fa-user text-amber-500"></i> Registered Customer
                    </h3>
                    <div class="space-y-6">
                        <div>
                            <label class="block text-[10px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mb-3">Customer <span class="text-red-500">*</span></label>
                            <select name="selectedUsername" id="rUser" class="w-full px-6 py-4 bg-white dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-8 focus:ring-amber-500/10 focus:border-amber-500 outline-none transition-all text-slate-900 dark:text-white shadow-sm" onchange="onUserChange()" onblur="validateField(this)">
                                <option value="" disabled selected>— Choose a customer —</option>
                                <% for (CustomerUser c : customers) { %>
                                <option value="<%= c.getUsername() %>"><%= c.getUsername() %> — <%= c.getName() %></option>
                                <% } %>
                            </select>
                            <p class="error-msg" id="err-rUser">Customer is required</p>
                        </div>
                        <div>
                            <label class="block text-[10px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mb-3">Vehicle <span class="text-red-500">*</span></label>
                            <select name="licensePlate" id="rPlate" disabled class="w-full px-6 py-4 bg-slate-50 dark:bg-slate-900/50 border-2 border-slate-100 dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-8 focus:ring-amber-500/10 focus:border-amber-500 outline-none transition-all text-slate-500 dark:text-slate-400 shadow-sm" onchange="updatePreview()" onblur="validateField(this)">
                                <option value="" disabled selected>— Select customer first —</option>
                            </select>
                            <p class="error-msg" id="err-rPlate">Vehicle is required</p>
                            <p id="rNoVehicleMsg" class="hidden text-xs text-amber-600 mt-2 font-medium"><i class="fa-solid fa-triangle-exclamation mr-1"></i> This customer has no registered vehicles. Switch to Walk-in mode to add one.</p>
                        </div>
                    </div>
                </div>

                <!-- WALK-IN CUSTOMER SECTION -->
                <div id="section-walkin" class="hidden bg-white dark:bg-slate-900 rounded-[2rem] border border-slate-200 dark:border-slate-800 p-8 shadow-2xl shadow-slate-200/40 dark:shadow-none transition-all duration-300">
                    <h3 class="text-[10px] font-black text-slate-500 dark:text-slate-400 mb-6 uppercase tracking-[0.3em] flex items-center gap-3">
                        <i class="fa-solid fa-person-walking text-amber-500"></i> Walk-in Customer & Vehicle
                    </h3>
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-6 mb-6">
                        <div>
                            <label class="block text-[10px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mb-3">Customer Name</label>
                            <input type="text" name="walkInName" id="wName" placeholder="e.g. John Doe" class="w-full px-6 py-4 bg-white dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-8 focus:ring-amber-500/10 focus:border-amber-500 outline-none transition-all text-slate-900 dark:text-white shadow-sm" oninput="updatePreview()">
                        </div>
                        <div>
                            <label class="block text-[10px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mb-3">Phone Number</label>
                            <input type="text" name="walkInPhone" id="wPhone" placeholder="07XXXXXXXX" class="w-full px-6 py-4 bg-white dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-8 focus:ring-amber-500/10 focus:border-amber-500 outline-none transition-all text-slate-900 dark:text-white shadow-sm">
                        </div>
                    </div>
                    <div class="border-t border-slate-100 dark:border-slate-800 pt-6">
                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-6 mb-6">
                            <div>
                                <label class="block text-[10px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mb-3">License Plate <span class="text-red-500">*</span></label>
                                <input type="text" name="walkInPlate" id="wPlate" placeholder="ABC-1234" class="w-full px-6 py-4 bg-white dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-8 focus:ring-amber-500/10 focus:border-amber-500 outline-none transition-all text-slate-900 dark:text-white shadow-sm uppercase" oninput="updatePreview()" onblur="validateField(this)">
                                <p class="error-msg" id="err-wPlate">Plate is required</p>
                            </div>
                            <div>
                                <label class="block text-[10px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mb-3">Make <span class="text-red-500">*</span></label>
                                <input type="text" name="walkInMake" id="wMake" placeholder="Toyota" class="w-full px-6 py-4 bg-white dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-8 focus:ring-amber-500/10 focus:border-amber-500 outline-none transition-all text-slate-900 dark:text-white shadow-sm" onblur="validateField(this)">
                                <p class="error-msg" id="err-wMake">Make is required</p>
                            </div>
                        </div>
                        <div class="grid grid-cols-1 sm:grid-cols-3 gap-6">
                            <div class="sm:col-span-1">
                                <label class="block text-[10px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mb-3">Model <span class="text-red-500">*</span></label>
                                <input type="text" name="walkInModel" id="wModel" placeholder="Corolla" class="w-full px-6 py-4 bg-white dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-8 focus:ring-amber-500/10 focus:border-amber-500 outline-none transition-all text-slate-900 dark:text-white shadow-sm" onblur="validateField(this)">
                                <p class="error-msg" id="err-wModel">Model is required</p>
                            </div>
                            <div class="sm:col-span-1">
                                <label class="block text-[10px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mb-3">Year <span class="text-red-500">*</span></label>
                                <input type="number" name="walkInYear" id="wYear" placeholder="2018" min="1900" max="2100" class="w-full px-6 py-4 bg-white dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-8 focus:ring-amber-500/10 focus:border-amber-500 outline-none transition-all text-slate-900 dark:text-white shadow-sm" onblur="validateField(this)">
                                <p class="error-msg" id="err-wYear">Year is required</p>
                            </div>
                            <div class="sm:col-span-1">
                                <label class="block text-[10px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mb-3">Mileage</label>
                                <input type="number" name="walkInMileage" id="wMileage" placeholder="50000" min="0" class="w-full px-6 py-4 bg-white dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-8 focus:ring-amber-500/10 focus:border-amber-500 outline-none transition-all text-slate-900 dark:text-white shadow-sm">
                            </div>
                        </div>
                    </div>
                </div>

                <!-- SERVICE DETAILS (SHARED) -->
                <div class="bg-white dark:bg-slate-900 rounded-[2rem] border border-slate-200 dark:border-slate-800 p-8 shadow-2xl shadow-slate-200/40 dark:shadow-none">
                    <h3 class="text-[10px] font-black text-slate-400 dark:text-slate-600 mb-6 uppercase tracking-[0.3em] flex items-center gap-3">
                        <i class="fa-solid fa-wrench text-amber-500"></i> Service Details
                    </h3>
                    <div class="mb-8">
                        <label class="block text-[10px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mb-3">Service Date <span class="text-red-500">*</span></label>
                        <div class="relative group md:w-1/2">
                            <i class="fa-solid fa-calendar-day absolute left-6 top-1/2 -translate-y-1/2 text-slate-400 dark:text-slate-600 transition-colors pointer-events-none z-10"></i>
                            <input type="text" name="date" id="fDate" required placeholder="Select Date" class="w-full pl-14 pr-6 py-4 bg-white dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-8 focus:ring-amber-500/10 focus:border-amber-500 outline-none transition-all text-slate-900 dark:text-white shadow-sm cursor-pointer" onblur="validateField(this)">
                        </div>
                        <p class="error-msg" id="err-fDate">Date is required</p>
                    </div>
                    
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-8 mb-8">
                        <div>
                            <label class="block text-[10px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mb-3">Service Type <span class="text-red-500">*</span></label>
                            <div class="space-y-3">
                                <select name="serviceType" id="fType" required class="w-full px-6 py-4 bg-white dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-8 focus:ring-amber-500/10 focus:border-amber-500 outline-none transition-all text-slate-900 dark:text-white shadow-sm" onchange="autofillCost()">
                                    <option value="">— Select service —</option>
                                    <% for (ServiceType st : sTypes) { %>
                                    <option value="<%= st.getServiceName() %>" data-cost="<%= st.getDefaultBasePrice() %>"><%= st.getServiceName() %></option>
                                    <% } %>
                                    <option value="custom">Other / Custom...</option>
                                </select>
                                
                                <input id="fCustomType" type="text" 
                                       class="hidden w-full px-6 py-4 bg-slate-100 dark:bg-slate-900/50 border-2 border-amber-500/30 rounded-2xl text-sm font-black text-slate-900 dark:text-white focus:border-amber-500 outline-none transition-all placeholder:text-slate-400" 
                                       placeholder="Enter custom service name..."
                                       oninput="syncCustomValue(this)">
                            </div>
                            <p class="error-msg" id="err-fType">Service type is required</p>
                        </div>
                        <div>
                            <label class="block text-[10px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mb-3">Parts Cost (LKR)</label>
                            <div class="relative group">
                                <span class="absolute left-6 top-1/2 -translate-y-1/2 text-slate-400 dark:text-slate-600 text-sm font-black group-focus-within:text-amber-500 transition-colors">LKR</span>
                                <input type="number" step="0.01" name="cost" id="fCost" placeholder="0.00" value="0" min="0"
                                       class="w-full pl-16 pr-6 py-4 bg-white dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-8 focus:ring-amber-500/10 focus:border-amber-500 outline-none transition-all text-slate-900 dark:text-white shadow-sm"
                                       oninput="updatePreview()">
                            </div>
                        </div>
                        <div>
                            <label class="block text-[10px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mb-3">Labor Fee (LKR) <span class="text-red-500">*</span></label>
                            <div class="relative group">
                                <span class="absolute left-6 top-1/2 -translate-y-1/2 text-slate-400 dark:text-slate-600 text-sm font-black group-focus-within:text-amber-500 transition-colors">LKR</span>
                                <input type="number" step="0.01" name="laborCost" id="fLabor" placeholder="0.00" required min="0"
                                       class="w-full pl-16 pr-6 py-4 bg-white dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-8 focus:ring-amber-500/10 focus:border-amber-500 outline-none transition-all text-slate-900 dark:text-white shadow-sm"
                                       oninput="updatePreview()" onblur="validateField(this)">
                            </div>
                            <p class="error-msg" id="err-fLabor">Labor fee is required</p>
                        </div>
                    </div>
                    <div>
                        <label class="block text-[10px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mb-3">Service Notes <span class="text-slate-400 dark:text-slate-700 font-normal ml-2 tracking-normal">(Optional)</span></label>
                        <textarea rows="4" id="fNotes" placeholder="Additional notes about the service..." class="w-full px-6 py-4 bg-white dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 rounded-2xl text-sm font-medium focus:ring-8 focus:ring-amber-500/10 focus:border-amber-500 outline-none transition-all text-slate-900 dark:text-white resize-none shadow-sm"></textarea>
                    </div>
                </div>

                <div class="flex gap-4 pt-4">
                    <a href="dashboard.jsp" class="px-10 py-5 rounded-2xl border border-slate-200 dark:border-slate-800 text-slate-500 dark:text-slate-400 font-black text-[10px] uppercase tracking-widest hover:bg-slate-100 dark:hover:bg-slate-900 transition-all text-center flex items-center justify-center">Cancel</a>
                    <button type="submit" class="flex-1 py-5 rounded-2xl bg-slate-900 dark:bg-white text-white dark:text-slate-950 font-black text-[10px] uppercase tracking-[0.2em] shadow-2xl transition-all flex items-center justify-center gap-3 hover:-translate-y-1 active:scale-95">
                        <i class="fa-solid fa-cloud-arrow-up text-lg"></i> Save Record
                    </button>
                </div>
            </form>
        </div>

        <!-- RIGHT: LIVE COST BREAKDOWN -->
        <div class="w-full lg:w-96 flex-shrink-0">
            <div class="sticky top-28">
                <h3 class="text-[10px] font-black text-slate-500 dark:text-slate-400 mb-6 uppercase tracking-[0.3em] flex items-center gap-3">
                    <i class="fa-solid fa-receipt text-amber-500"></i> Live Cost Breakdown
                </h3>
                <div class="bg-white dark:bg-slate-900 rounded-[2.5rem] border border-slate-200 dark:border-slate-800 overflow-hidden shadow-2xl shadow-slate-200/40 dark:shadow-none">
                    <div class="bg-gradient-to-br from-amber-600 to-amber-700 p-8">
                        <h4 class="text-white/60 text-[10px] font-black uppercase tracking-[0.2em]">Estimated Total</h4>
                        <p class="text-white text-4xl font-black mt-2 tracking-tighter" id="pvTotal">LKR 0.00</p>
                    </div>
                    <div class="p-8 space-y-6">
                        <div class="flex justify-between items-center">
                            <span class="text-[10px] font-black text-slate-400 dark:text-slate-500 uppercase tracking-widest">Customer</span>
                            <span class="text-xs font-black text-slate-800 dark:text-white truncate max-w-[150px]" id="pvCustomer">—</span>
                        </div>
                        <div class="flex justify-between items-center">
                            <span class="text-[10px] font-black text-slate-400 dark:text-slate-500 uppercase tracking-widest">Vehicle</span>
                            <span class="text-xs font-black text-slate-800 dark:text-white truncate max-w-[150px]" id="pvPlate">—</span>
                        </div>
                        <div class="flex justify-between items-center">
                            <span class="text-[10px] font-black text-slate-400 dark:text-slate-500 uppercase tracking-widest">Service</span>
                            <span class="text-xs font-black text-slate-800 dark:text-white truncate max-w-[150px]" id="pvType">—</span>
                        </div>
                        <div class="flex justify-between items-center">
                            <span class="text-[10px] font-black text-slate-400 dark:text-slate-500 uppercase tracking-widest">Date</span>
                            <span class="text-xs font-black text-slate-800 dark:text-white" id="pvDate">—</span>
                        </div>
                        <div class="border-t border-slate-100 dark:border-slate-800 pt-6 mt-6">
                            <div class="flex justify-between items-center mb-3">
                                <span class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Base Labor</span>
                                <span class="text-xs font-black text-slate-600 dark:text-slate-400" id="pvBase">LKR 0.00</span>
                            </div>
                            <div class="flex justify-between items-center">
                                <span class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Parts & Materials</span>
                                <span class="text-xs font-black text-slate-300 dark:text-slate-700">Incl.</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="toast.jsp" %>
<script>
// JSON mapping of username -> array of vehicles
const userVehicles = {
    <% 
    for(int i=0; i<customers.size(); i++) {
        CustomerUser u = customers.get(i);
        List<Vehicle> userCars = vManager.getVehiclesByOwner(u.getUsername());
        out.print("\"" + u.getUsername() + "\": [");
        for(int j=0; j<userCars.size(); j++) {
            Vehicle v = userCars.get(j);
            out.print("{\"plate\":\"" + v.getLicensePlate() + "\", \"make\":\"" + v.getMake() + "\", \"model\":\"" + v.getModel() + "\"}");
            if(j < userCars.size()-1) out.print(",");
        }
        out.print("]");
        if(i < customers.size()-1) out.print(",");
    }
    %>
};

let currentMode = 'registered';

function toggleMode(mode) {
    currentMode = mode;
    document.getElementById('customerMode').value = mode;
    
    if (mode === 'registered') {
        document.getElementById('section-registered').classList.remove('hidden');
        document.getElementById('section-walkin').classList.add('hidden');
    } else {
        document.getElementById('section-registered').classList.add('hidden');
        document.getElementById('section-walkin').classList.remove('hidden');
    }
    
    // Clear errors when switching
    document.querySelectorAll('.error-msg').forEach(el => el.classList.remove('show'));
    document.querySelectorAll('.field-error').forEach(el => el.classList.remove('field-error'));
    
    updatePreview();
}

function onUserChange() {
    const userSel = document.getElementById('rUser');
    const plateSel = document.getElementById('rPlate');
    const noMsg = document.getElementById('rNoVehicleMsg');
    const username = userSel.value;
    
    // Reset vehicle dropdown
    plateSel.innerHTML = '<option value="" disabled selected>— Choose a vehicle —</option>';
    plateSel.disabled = true;
    plateSel.classList.replace('text-slate-900', 'text-slate-500');
    plateSel.classList.replace('bg-white', 'bg-slate-50');
    if(document.body.classList.contains('dark')) {
        plateSel.classList.replace('dark:text-white', 'dark:text-slate-400');
        plateSel.classList.replace('dark:bg-slate-950', 'dark:bg-slate-900/50');
    }
    noMsg.classList.add('hidden');
    
    if (username && userVehicles[username]) {
        const cars = userVehicles[username];
        if (cars.length > 0) {
            plateSel.disabled = false;
            plateSel.classList.replace('text-slate-500', 'text-slate-900');
            plateSel.classList.replace('bg-slate-50', 'bg-white');
            if(document.body.classList.contains('dark')) {
                plateSel.classList.replace('dark:text-slate-400', 'dark:text-white');
                plateSel.classList.replace('dark:bg-slate-900/50', 'dark:bg-slate-950');
            }
            
            cars.forEach(car => {
                const opt = document.createElement('option');
                opt.value = car.plate;
                opt.textContent = car.plate + ' — ' + car.make + ' ' + car.model;
                plateSel.appendChild(opt);
            });
        } else {
            noMsg.classList.remove('hidden');
        }
    }
    updatePreview();
}

function autofillCost() {
    const sel = document.getElementById('fType');
    const customInp = document.getElementById('fCustomType');
    
    if (sel.value === 'custom') {
        customInp.classList.remove('hidden');
        customInp.required = true;
    } else {
        customInp.classList.add('hidden');
        customInp.required = false;
        customInp.value = "";
        
        const opt = sel.options[sel.selectedIndex];
        const cost = opt.getAttribute('data-cost');
        if (cost) { document.getElementById('fCost').value = parseFloat(cost).toFixed(2); }
    }
    updatePreview();
}

function syncCustomValue(inp) {
    const sel = document.getElementById('fType');
    const customOpt = sel.options[sel.options.length - 1];
    customOpt.value = inp.value;
    updatePreview();
}

function updatePreview() {
    let customerText = '—';
    let plateText = '—';
    
    if (currentMode === 'registered') {
        const uSel = document.getElementById('rUser');
        if(uSel.selectedIndex > 0) {
            // "username — Full Name" => extract just Full Name or Username
            const parts = uSel.options[uSel.selectedIndex].text.split(' — ');
            customerText = parts.length > 1 ? parts[1] : parts[0];
        }
        
        const pSel = document.getElementById('rPlate');
        if(pSel && pSel.selectedIndex > 0) {
            plateText = pSel.options[pSel.selectedIndex].text.split(' — ')[0];
        }
    } else {
        const wName = document.getElementById('wName').value;
        customerText = wName.trim() ? wName : 'Walk-in';
        
        const wPlate = document.getElementById('wPlate').value;
        plateText = wPlate.trim() ? wPlate.toUpperCase() : '—';
    }

    const type = document.getElementById('fType');
    const typeText = type.selectedIndex > 0 ? type.value : '—';
    
    const date = document.getElementById('fDate').value || '—';
    
    const costInput = document.getElementById('fCost').value;
    const cost = costInput ? parseFloat(costInput) : 0;

    document.getElementById('pvCustomer').textContent = customerText;
    document.getElementById('pvPlate').textContent = plateText;
    document.getElementById('pvType').textContent = typeText;
    document.getElementById('pvDate').textContent = date;
    
    const formattedCost = 'LKR ' + cost.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,');
    document.getElementById('pvBase').textContent = formattedCost;
    document.getElementById('pvTotal').textContent = formattedCost;
}

function validateField(el) {
    const errEl = document.getElementById('err-' + el.id);
    if (!el.value || !el.value.trim()) { 
        el.classList.add('field-error'); 
        if(errEl) errEl.classList.add('show'); 
    } else { 
        el.classList.remove('field-error'); 
        if(errEl) errEl.classList.remove('show'); 
    }
}

function validateForm() {
    let ok = true;
    let requiredFields = [];
    
    if (currentMode === 'registered') {
        requiredFields = ['rUser', 'rPlate', 'fDate', 'fType', 'fCost'];
    } else {
        requiredFields = ['wPlate', 'wMake', 'wModel', 'wYear', 'fDate', 'fType', 'fCost'];
    }
    
    requiredFields.forEach(id => {
        const el = document.getElementById(id);
        if (!el || !el.value || !el.value.trim()) { 
            if(el) el.classList.add('field-error'); 
            ok = false; 
            const errEl = document.getElementById('err-' + id);
            if(errEl) errEl.classList.add('show');
        }
    });
    
    if (!ok) showToast("Please fill in all required fields.", "error");
    return ok;
}

document.addEventListener("DOMContentLoaded", () => {
    flatpickr("#fDate", {
        dateFormat: "Y-m-d",
        defaultDate: "today",
        disableMobile: "true",
        animate: true,
        monthSelectorType: "static",
        static: true,
        onChange: function(selectedDates, dateStr) {
            updatePreview();
            validateField(document.getElementById('fDate'));
        }
    });
});
</script>
<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
</body>
</html>