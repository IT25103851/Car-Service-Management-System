<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.VehicleManager, model.Vehicle, java.util.List" %>
<%@ page import="model.ServiceTypeManager, model.ServiceType" %>
<%@ page import="model.InventoryManager, model.InventoryItem" %>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) { response.sendRedirect("login.jsp"); return; }

    VehicleManager vManager = new VehicleManager();
    List<Vehicle> allCars = vManager.getAllVehicles();
    ServiceTypeManager stm = new ServiceTypeManager();
    InventoryManager im = new InventoryManager();
    List<ServiceType> sList = stm.getAllServices();
    List<InventoryItem> invList = im.getAllItems();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book Appointment - SwiftDrive</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Plus Jakarta Sans', sans-serif; }
        .step-active { background: #4f46e5; color: #fff; box-shadow: 0 0 0 4px rgba(79,70,229,0.18); }
        .step-done { background: #10b981; color: #fff; }
        .step-pending { background: #e2e8f0; color: #94a3b8; }
        .dark .step-pending { background: #1e293b; color: #475569; }

        .vehicle-card, .service-card { transition: all 0.25s cubic-bezier(.4,0,.2,1); cursor: pointer; }
        .vehicle-card:hover, .service-card:hover { transform: translateY(-3px); box-shadow: 0 8px 32px rgba(79,70,229,0.13); }
        .vehicle-card.selected, .service-card.selected { border-color: #4f46e5 !important; box-shadow: 0 0 0 3px rgba(79,70,229,0.18), 0 8px 32px rgba(79,70,229,0.10); }
        .dark .vehicle-card.selected, .dark .service-card.selected { border-color: #818cf8 !important; box-shadow: 0 0 0 3px rgba(129,140,248,0.2); }

        .time-chip { transition: all 0.2s; cursor: pointer; }
        .time-chip:hover:not(.disabled) { background: #4f46e5; color: #fff; transform: scale(1.06); }
        .time-chip.selected { background: #4f46e5 !important; color: #fff !important; box-shadow: 0 0 0 3px rgba(79,70,229,0.22); }
        .time-chip.disabled { opacity: 0.4; cursor: not-allowed; pointer-events: none; }
        
        .cal-day { transition: all 0.15s; cursor: pointer; border-radius: 12px; }
        .cal-day:hover:not(.past):not(.empty):not(.sunday) { background: #eef2ff; color: #4f46e5; }
        .dark .cal-day:hover:not(.past):not(.empty):not(.sunday) { background: rgba(79,70,229,0.1); color: #818cf8; }
        .cal-day.selected { background: #4f46e5 !important; color: #fff !important; font-weight: 800; box-shadow: 0 2px 8px rgba(79,70,229,0.22); }
        .cal-day.past, .cal-day.sunday { color: #cbd5e1; cursor: not-allowed; pointer-events: none; }
        .dark .cal-day.past, .dark .cal-day.sunday { color: #334155; }
        .cal-day.sunday { background: #fef2f2; color: #fca5a5; }
        .dark .cal-day.sunday { background: rgba(252,165,165,0.05); color: #7f1d1d; }
        .cal-day.today { border: 2px solid #4f46e5; font-weight: 700; }
        
        .sidebar-card { box-shadow: 0 4px 24px rgba(0,0,0,0.07); }
        .dark .sidebar-card { box-shadow: none; }

        @keyframes pulse-cta { 0%,100%{box-shadow:0 0 0 0 rgba(79,70,229,0.4)} 50%{box-shadow:0 0 0 12px rgba(79,70,229,0)} }
        .cta-pulse:hover { animation: pulse-cta 1.5s infinite; }
        @keyframes fadeUp { from{opacity:0;transform:translateY(16px)} to{opacity:1;transform:translateY(0)} }
        .fade-up { animation: fadeUp 0.4s ease-out forwards; }
        
        /* Flatpickr Customization */
        .flatpickr-calendar {
            background: #ffffff !important;
            border-radius: 2rem !important;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.08) !important;
            border: 1px solid #f1f5f9 !important;
            width: 100% !important;
            font-family: inherit !important;
        }
        .dark .flatpickr-calendar {
            background: #0f172a !important;
            border: 1px solid #1e293b !important;
            box-shadow: none !important;
        }
        .flatpickr-months .flatpickr-month {
            background: transparent !important;
            color: inherit !important;
            fill: inherit !important;
            height: 60px !important;
        }
        .flatpickr-current-month {
            font-size: 1.1rem !important;
            font-weight: 800 !important;
            color: #4f46e5 !important;
        }
        .dark .flatpickr-current-month {
            color: #818cf8 !important;
        }
        .flatpickr-months .flatpickr-prev-month, .flatpickr-months .flatpickr-next-month {
            color: #6366f1 !important;
            fill: #6366f1 !important;
            top: 15px !important;
        }
        .flatpickr-day {
            color: #475569 !important;
        }
        .dark .flatpickr-day {
            color: #94a3b8 !important;
        }
        .flatpickr-day.selected {
            background: #4f46e5 !important;
            border-color: #4f46e5 !important;
            border-radius: 12px !important;
            color: #fff !important;
        }
        .flatpickr-day.flatpickr-disabled, .flatpickr-day.flatpickr-disabled:hover {
            color: #e2e8f0 !important;
        }
        .dark .flatpickr-day.flatpickr-disabled {
            color: #1e293b !important;
        }
        .flatpickr-time {
            height: 80px !important;
            border-top: 1px solid #f1f5f9 !important;
        }
        .dark .flatpickr-time {
            border-top: 1px solid #1e293b !important;
        }
        .flatpickr-time input:hover, .flatpickr-time .flatpickr-am-pm:hover {
            background: #f1f5f9 !important;
        }
        .dark .flatpickr-time input:hover {
            background: #1e293b !important;
        }
    </style>
    <!-- Flatpickr -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/airbnb.css">
</head>
<body class="antialiased text-slate-900 dark:text-slate-100 bg-slate-50 dark:bg-slate-950 transition-colors duration-300 min-h-screen">
<%@ include file="customer_navbar.jsp" %>

<form action="BookAppointmentServlet" method="POST" id="bookingForm" class="pt-28 pb-16">
<div class="max-w-7xl mx-auto px-4 lg:flex lg:gap-10">

    <!-- MAIN WIZARD AREA -->
    <div class="flex-1 min-w-0">
        <!-- HEADER -->
        <div class="mb-10">
            <h1 class="text-4xl font-black text-slate-900 dark:text-white tracking-tight"><i class="fa-solid fa-calendar-plus text-indigo-600 mr-2"></i>Book a Service</h1>
            <p class="mt-2 text-base font-medium text-slate-500 dark:text-slate-400">Complete the steps below to join the service schedule.</p>
        </div>

        <!-- STEP INDICATORS -->
        <div class="flex items-center gap-4 mb-10 overflow-x-auto pb-2 no-scrollbar">
            <div class="flex items-center gap-3 shrink-0">
                <div id="stepBadge1" class="step-active w-10 h-10 rounded-2xl flex items-center justify-center text-sm font-black transition-all duration-300">1</div>
                <span id="stepLabel1" class="text-xs font-black uppercase tracking-widest text-indigo-600 dark:text-indigo-400">Vehicle</span>
            </div>
            <div class="w-12 h-0.5 bg-slate-200 dark:bg-slate-800 rounded shrink-0"><div id="prog1" class="h-full bg-indigo-500 rounded transition-all duration-500" style="width:0%"></div></div>
            <div class="flex items-center gap-3 shrink-0">
                <div id="stepBadge2" class="step-pending w-10 h-10 rounded-2xl flex items-center justify-center text-sm font-black transition-all duration-300 bg-slate-200 dark:bg-slate-800 text-slate-400 dark:text-slate-600">2</div>
                <span id="stepLabel2" class="text-xs font-black uppercase tracking-widest text-slate-400 dark:text-slate-600">Service</span>
            </div>
            <div class="w-12 h-0.5 bg-slate-200 dark:bg-slate-800 rounded shrink-0"><div id="prog2" class="h-full bg-indigo-500 rounded transition-all duration-500" style="width:0%"></div></div>
            <div class="flex items-center gap-3 shrink-0">
                <div id="stepBadge3" class="step-pending w-10 h-10 rounded-2xl flex items-center justify-center text-sm font-black transition-all duration-300 bg-slate-200 dark:bg-slate-800 text-slate-400 dark:text-slate-600">3</div>
                <span id="stepLabel3" class="text-xs font-black uppercase tracking-widest text-slate-400 dark:text-slate-600">Schedule</span>
            </div>
        </div>

        <!-- STEP 1: VEHICLE -->
        <div id="step1" class="fade-up">
            <h2 class="text-xl font-black text-slate-900 dark:text-white mb-6 flex items-center gap-2">
                <i class="fa-solid fa-car-side text-indigo-500"></i> Select Your Vehicle
            </h2>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-5">
                <% boolean hasCars = false;
                   for (Vehicle car : allCars) {
                       if (car.getOwnerUsername().equals(username)) { hasCars = true; %>
                <div class="vehicle-card bg-white dark:bg-slate-800/40 backdrop-blur-md border-2 border-slate-100 dark:border-slate-800 rounded-3xl p-6 relative overflow-hidden shadow-xl shadow-slate-200/40 dark:shadow-none"
                     onclick="selectVehicle(this, '<%= car.getLicensePlate() %>', '<%= car.getMake() %> <%= car.getModel() %>', '<%= car.getYear() %>')">
                    <div class="flex items-start gap-5">
                        <div class="w-14 h-14 rounded-2xl bg-indigo-50 dark:bg-indigo-900/40 flex items-center justify-center text-indigo-600 dark:text-indigo-400 text-2xl flex-shrink-0 transition-colors group-hover:bg-indigo-600 group-hover:text-white">
                            <i class="fa-solid fa-car-side"></i>
                        </div>
                        <div class="min-w-0 flex-1">
                            <p class="font-black text-slate-800 dark:text-white text-lg"><%= car.getMake() %> <%= car.getModel() %></p>
                            <p class="text-[10px] font-black text-slate-400 dark:text-slate-500 uppercase tracking-widest mt-1"><%= car.getYear() %> Model Year</p>
                            <span class="inline-block mt-3 font-mono text-xs font-black text-indigo-600 dark:text-indigo-400 bg-indigo-50 dark:bg-indigo-900/30 border border-indigo-100 dark:border-indigo-800/50 px-3 py-1.5 rounded-xl"><%= car.getLicensePlate() %></span>
                        </div>
                    </div>
                    <div class="absolute top-4 right-4 w-7 h-7 rounded-xl border-2 border-slate-200 dark:border-slate-700 flex items-center justify-center check-circle transition-all">
                        <i class="fa-solid fa-check text-xs text-white opacity-0 transition-opacity"></i>
                    </div>
                </div>
                <%     }
                   }
                   if (!hasCars) { %>
                <div class="col-span-full bg-white dark:bg-slate-800/40 border-2 border-dashed border-slate-200 dark:border-slate-700 rounded-3xl p-16 text-center shadow-xl shadow-slate-200/40 dark:shadow-none">
                    <div class="w-20 h-20 bg-slate-50 dark:bg-slate-900/60 rounded-full flex items-center justify-center mx-auto mb-6">
                        <i class="fa-solid fa-car-tunnel text-slate-200 dark:text-slate-700 text-4xl"></i>
                    </div>
                    <p class="text-slate-900 dark:text-white font-black text-xl mb-2">No vehicles found!</p>
                    <p class="text-slate-500 dark:text-slate-400 font-medium mb-6">You need to register a vehicle before booking a service.</p>
                    <a href="customer_vehicles.jsp" class="inline-flex items-center gap-2 bg-indigo-600 hover:bg-indigo-700 text-white font-black text-sm px-8 py-3.5 rounded-2xl shadow-xl shadow-indigo-100 dark:shadow-none transition-all">
                        Register a car first &rarr;
                    </a>
                </div>
                <% } %>
            </div>
            <input type="hidden" name="licensePlate" id="hiddenPlate" required>
        </div>

        <!-- STEP 2: SERVICE -->
        <div id="step2" class="hidden fade-up">
            <h2 class="text-xl font-black text-slate-900 dark:text-white mb-6 flex items-center gap-2">
                <i class="fa-solid fa-wrench text-indigo-500"></i> Select Service Type
            </h2>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-5">
                <% for (ServiceType st : sList) {
                       int minQty = Integer.MAX_VALUE; boolean hasLinked = false;
                       for (InventoryItem item : invList) {
                           if (st.getServiceName().equals(item.getApplicableService())) {
                               hasLinked = true;
                               if (item.getQuantity() < minQty) minQty = item.getQuantity();
                           }
                       }
                       String stockBadge, stockColor, stockIcon;
                       boolean isDisabled = false;
                       if (!hasLinked) { stockBadge="Ready"; stockColor="bg-emerald-50 dark:bg-emerald-900/20 text-emerald-700 dark:text-emerald-400 border-emerald-100 dark:border-emerald-800/50"; stockIcon="fa-circle-check"; }
                       else if (minQty <= 0) { stockBadge="Out of Stock"; stockColor="bg-rose-50 dark:bg-rose-900/20 text-rose-600 dark:text-rose-400 border-rose-100 dark:border-rose-800/50"; stockIcon="fa-clock"; isDisabled=true; }
                       else if (minQty <= 5) { stockBadge="Limited"; stockColor="bg-amber-50 dark:bg-amber-900/20 text-amber-700 dark:text-amber-400 border-amber-100 dark:border-amber-800/50"; stockIcon="fa-triangle-exclamation"; }
                       else { stockBadge="In Stock"; stockColor="bg-emerald-50 dark:bg-emerald-900/20 text-emerald-700 dark:text-emerald-400 border-emerald-100 dark:border-emerald-800/50"; stockIcon="fa-circle-check"; }
                %>
                <div class="service-card bg-white dark:bg-slate-800/40 backdrop-blur-md border-2 border-slate-100 dark:border-slate-800 rounded-3xl p-6 relative overflow-hidden shadow-xl shadow-slate-200/40 dark:shadow-none <%= isDisabled ? "opacity-40 grayscale pointer-events-none" : "" %>"
                     onclick="selectService(this, '<%= st.getServiceName() %>', <%= st.getDefaultBasePrice() %>)">
                    <div class="flex items-start justify-between mb-5">
                        <div class="w-12 h-12 rounded-2xl bg-violet-50 dark:bg-violet-900/40 flex items-center justify-center text-violet-600 dark:text-violet-400 text-xl"><i class="fa-solid fa-gears"></i></div>
                        <span class="text-[9px] font-black px-2.5 py-1.5 rounded-xl border uppercase tracking-widest <%= stockColor %>"><i class="fa-solid <%= stockIcon %> mr-1.5"></i><%= stockBadge %></span>
                    </div>
                    <p class="font-black text-slate-800 dark:text-white text-base"><%= st.getServiceName() %></p>
                    <div class="flex items-center justify-between mt-5 pt-5 border-t border-slate-50 dark:border-slate-700/50">
                        <span class="text-[10px] font-black text-slate-400 dark:text-slate-500 uppercase tracking-widest"><i class="fa-regular fa-clock mr-1.5 text-indigo-500"></i>Est. 3-5 Hours</span>
                        <span class="text-lg font-black text-indigo-600 dark:text-indigo-400">LKR <%= String.format("%,.0f", st.getDefaultBasePrice()) %></span>
                    </div>
                    <div class="absolute top-4 right-16 w-7 h-7 rounded-xl border-2 border-slate-200 dark:border-slate-700 flex items-center justify-center check-circle transition-all">
                        <i class="fa-solid fa-check text-xs text-white opacity-0 transition-opacity"></i>
                    </div>
                </div>
                <% } %>
            </div>
            <input type="hidden" name="issueDescription" id="hiddenService" required>
        </div>

        <!-- STEP 3: SCHEDULE -->
        <div id="step3" class="hidden fade-up">
            <h2 class="text-xl font-black text-slate-900 dark:text-white mb-6 flex items-center gap-2">
                <i class="fa-solid fa-calendar-days text-indigo-500"></i> Pick Date & Time
            </h2>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                <!-- Date Picker Column -->
                <div class="bg-white dark:bg-slate-800/40 backdrop-blur-md border border-slate-100 dark:border-slate-800 rounded-[2.5rem] p-8 shadow-xl shadow-slate-200/40 dark:shadow-none">
                    <h3 class="text-sm font-black text-slate-900 dark:text-white uppercase tracking-[0.2em] mb-6 flex items-center gap-2">
                        <i class="fa-solid fa-calendar text-indigo-500"></i> Select Date
                    </h3>
                    <div id="inlineCalendar"></div>
                </div>
                <!-- Time Picker Column -->
                <div class="bg-white dark:bg-slate-800/40 backdrop-blur-md border border-slate-100 dark:border-slate-800 rounded-[2.5rem] p-8 shadow-xl shadow-slate-200/40 dark:shadow-none">
                    <h3 class="text-sm font-black text-slate-900 dark:text-white uppercase tracking-[0.2em] mb-6 flex items-center gap-2">
                        <i class="fa-regular fa-clock text-indigo-500"></i> Preferred Time
                    </h3>
                    <div id="inlineTime"></div>
                    <div class="mt-8 p-6 bg-slate-50 dark:bg-slate-900/60 rounded-2xl border border-slate-100 dark:border-slate-800">
                        <p class="text-[10px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-widest mb-2">Notice</p>
                        <p class="text-xs text-slate-500 dark:text-slate-400 leading-relaxed font-medium">Please select a time between 08:00 AM and 06:00 PM. Same-day bookings require at least 2 hours notice.</p>
                    </div>
                </div>
            </div>
            <input type="hidden" name="preferredDate" id="hiddenDate" required>
            <input type="hidden" name="preferredTime" id="hiddenTime" required>
        </div>

        <!-- NAV BUTTONS -->
        <div class="flex items-center justify-between mt-12">
            <button type="button" id="btnBack" onclick="prevStep()" class="hidden px-8 py-4 rounded-2xl border-2 border-slate-200 dark:border-slate-800 text-slate-600 dark:text-slate-400 font-black text-sm hover:bg-slate-50 dark:hover:bg-slate-800 transition-all active:scale-95"><i class="fa-solid fa-arrow-left mr-3"></i>Previous</button>
            <div class="flex-1"></div>
            <button type="button" id="btnNext" onclick="nextStep()" class="px-10 py-4 rounded-2xl bg-indigo-600 text-white font-black text-sm hover:bg-indigo-700 shadow-2xl shadow-indigo-200 dark:shadow-none transition-all disabled:opacity-40 disabled:cursor-not-allowed active:scale-95" disabled>Continue<i class="fa-solid fa-arrow-right ml-3"></i></button>
            <button type="submit" id="btnSubmit" class="hidden px-10 py-4 rounded-2xl bg-indigo-600 text-white font-black text-sm cta-pulse shadow-2xl shadow-indigo-200 dark:shadow-none transition-all disabled:opacity-40 disabled:cursor-not-allowed active:scale-95" disabled><i class="fa-solid fa-ticket-simple mr-3"></i>Confirm Booking</button>
        </div>
    </div>

    <!-- STICKY SIDEBAR -->
    <div class="hidden lg:block w-96 flex-shrink-0">
        <div class="sticky top-28 sidebar-card bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 rounded-[2.5rem] overflow-hidden shadow-2xl shadow-slate-200/50 dark:shadow-none">
            <div class="bg-gradient-to-br from-indigo-950 to-slate-900 p-8 border-b border-indigo-900/30">
                <h3 class="!text-indigo-50 font-black text-xs uppercase tracking-[0.2em] flex items-center gap-2"><i class="fa-solid fa-receipt text-indigo-400"></i> Booking Summary</h3>
            </div>
            <div class="p-8 space-y-8">
                <div class="group">
                    <span class="text-[10px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest block mb-2">Selected Vehicle</span>
                    <p id="sumVehicle" class="text-base font-black text-slate-900 dark:text-white transition-all group-hover:text-indigo-500">—</p>
                </div>
                <div class="group">
                    <span class="text-[10px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest block mb-2">Service Package</span>
                    <p id="sumService" class="text-base font-black text-slate-900 dark:text-white transition-all group-hover:text-indigo-500">—</p>
                </div>
                <div class="group">
                    <span class="text-[10px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest block mb-2">Appointment Date & Time</span>
                    <p id="sumDateTime" class="text-base font-black text-slate-900 dark:text-white transition-all group-hover:text-indigo-500">—</p>
                </div>
                <div class="pt-8 border-t border-slate-100 dark:border-slate-800 mt-8">
                    <span class="text-[10px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest block mb-2">Estimated Cost</span>
                    <p id="sumCost" class="text-3xl font-black text-indigo-600 dark:text-indigo-400 tracking-tighter">LKR 0</p>
                    <p class="text-[9px] font-black text-slate-400 dark:text-slate-600 mt-2 italic">* Final price may vary based on actual parts consumed.</p>
                </div>
            </div>
        </div>
    </div>
</div>
</form>

<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<script>
let currentStep = 1;
let selectedPlate = '', selectedVehicleName = '', selectedService = '', selectedCost = 0;
let selectedDate = '', selectedTime = '';
let calYear, calMonth;

// Init Flatpickr
document.addEventListener("DOMContentLoaded", () => {
    flatpickr("#inlineCalendar", {
        inline: true,
        minDate: "today",
        dateFormat: "Y-m-d",
        disable: [
            function(date) { return (date.getDay() === 0); }
        ],
        monthSelectorType: "static",
        showMonths: 1,
        onChange: function(selectedDates, dateStr) {
            selectedDate = dateStr;
            document.getElementById('hiddenDate').value = dateStr;
            updateSummaryDateTime();
            checkStep3Ready();
        }
    });

    flatpickr("#inlineTime", {
        inline: true,
        noCalendar: true,
        enableTime: true,
        dateFormat: "H:i",
        time_24hr: true,
        minTime: "08:00",
        maxTime: "18:00",
        onChange: function(selectedDates, timeStr) {
            selectedTime = timeStr;
            document.getElementById('hiddenTime').value = timeStr;
            updateSummaryDateTime();
            checkStep3Ready();
        }
    });
});

function selectVehicle(el, plate, name, year) {
    document.querySelectorAll('.vehicle-card').forEach(c => { c.classList.remove('selected'); c.querySelector('.check-circle').style.background=''; c.querySelector('.fa-check').style.opacity='0'; });
    el.classList.add('selected');
    el.querySelector('.check-circle').style.background='#4f46e5'; el.querySelector('.check-circle').style.borderColor='#4f46e5';
    el.querySelector('.fa-check').style.opacity='1';
    selectedPlate = plate; selectedVehicleName = name + ' (' + year + ')';
    document.getElementById('hiddenPlate').value = plate;
    document.getElementById('sumVehicle').textContent = name + ' · ' + plate;
    document.getElementById('btnNext').disabled = false;
}

function selectService(el, name, cost) {
    document.querySelectorAll('.service-card').forEach(c => { c.classList.remove('selected'); c.querySelector('.check-circle').style.background=''; c.querySelector('.fa-check').style.opacity='0'; });
    el.classList.add('selected');
    el.querySelector('.check-circle').style.background='#4f46e5'; el.querySelector('.check-circle').style.borderColor='#4f46e5';
    el.querySelector('.fa-check').style.opacity='1';
    selectedService = name; selectedCost = cost;
    document.getElementById('hiddenService').value = name;
    document.getElementById('sumService').textContent = name;
    document.getElementById('sumCost').textContent = 'LKR ' + cost.toLocaleString('en-LK', {minimumFractionDigits:2});
    document.getElementById('btnNext').disabled = false;
}

function selectDay(el, dateStr) {
    document.querySelectorAll('.cal-day').forEach(d => d.classList.remove('selected'));
    el.classList.add('selected');
    selectedDate = dateStr;
    document.getElementById('hiddenDate').value = dateStr;
    updateSummaryDateTime();
    checkStep3Ready();
}

function selectTime(el, time) {
    document.querySelectorAll('.time-chip').forEach(c => c.classList.remove('selected'));
    el.classList.add('selected');
    selectedTime = time;
    document.getElementById('hiddenTime').value = time;
    updateSummaryDateTime();
    checkStep3Ready();
}

function updateSummaryDateTime() {
    let txt = '';
    if (selectedDate) { const d = new Date(selectedDate + 'T00:00:00'); txt = d.toLocaleDateString('en-US',{weekday:'short',month:'short',day:'numeric',year:'numeric'}); }
    if (selectedTime) txt += ' at ' + selectedTime;
    document.getElementById('sumDateTime').textContent = txt || '—';
}

function checkStep3Ready() {
    document.getElementById('btnSubmit').disabled = !(selectedDate && selectedTime);
}

function nextStep() {
    if (currentStep >= 3) return;
    document.getElementById('step'+currentStep).classList.add('hidden');
    document.getElementById('stepBadge'+currentStep).className = 'step-done w-9 h-9 rounded-full flex items-center justify-center text-sm font-bold transition-all duration-300';
    document.getElementById('prog'+currentStep).style.width = '100%';
    currentStep++;
    document.getElementById('step'+currentStep).classList.remove('hidden');
    document.getElementById('stepBadge'+currentStep).className = 'step-active w-9 h-9 rounded-full flex items-center justify-center text-sm font-bold transition-all duration-300';
    document.getElementById('stepLabel'+currentStep).className = 'text-sm font-semibold text-indigo-700 transition-colors';
    document.getElementById('btnBack').classList.remove('hidden');
    document.getElementById('btnNext').disabled = true;
    if (currentStep === 2 && selectedService) document.getElementById('btnNext').disabled = false;
    if (currentStep === 3) { document.getElementById('btnNext').classList.add('hidden'); document.getElementById('btnSubmit').classList.remove('hidden'); checkStep3Ready(); }
}

function prevStep() {
    if (currentStep <= 1) return;
    document.getElementById('step'+currentStep).classList.add('hidden');
    document.getElementById('stepBadge'+currentStep).className = 'step-pending w-9 h-9 rounded-full flex items-center justify-center text-sm font-bold transition-all duration-300';
    document.getElementById('stepLabel'+currentStep).className = 'text-sm font-semibold text-slate-400 transition-colors';
    if (currentStep === 3) { document.getElementById('btnSubmit').classList.add('hidden'); document.getElementById('btnNext').classList.remove('hidden'); }
    currentStep--;
    document.getElementById('prog'+currentStep).style.width = '0%';
    document.getElementById('step'+currentStep).classList.remove('hidden');
    document.getElementById('stepBadge'+currentStep).className = 'step-active w-9 h-9 rounded-full flex items-center justify-center text-sm font-bold transition-all duration-300';
    if (currentStep === 1) document.getElementById('btnBack').classList.add('hidden');
    document.getElementById('btnNext').disabled = false;
}

function renderCalendar() {
    const grid = document.getElementById('calGrid');
    const today = new Date(); today.setHours(0,0,0,0);
    const first = new Date(calYear, calMonth, 1);
    const last = new Date(calYear, calMonth + 1, 0);
    document.getElementById('calMonthLabel').textContent = first.toLocaleDateString('en-US',{month:'long',year:'numeric'});
    let html = '';
    for (let i = 0; i < first.getDay(); i++) html += '<div class="cal-day empty p-2"></div>';
    for (let d = 1; d <= last.getDate(); d++) {
        const dt = new Date(calYear, calMonth, d);
        const iso = dt.getFullYear()+'-'+String(dt.getMonth()+1).padStart(2,'0')+'-'+String(d).padStart(2,'0');
        const isPast = dt < today;
        const isSunday = dt.getDay() === 0;
        const isToday = dt.getTime() === today.getTime();
        const isSel = iso === selectedDate;
        const isBlocked = isPast || isSunday;
        let cls = 'cal-day p-2 text-sm font-medium';
        if (isPast) cls += ' past'; else if (isSunday) cls += ' sunday'; else if (isSel) cls += ' selected'; else if (isToday) cls += ' today';
        const click = isBlocked ? '' : " onclick=\"selectDay(this,'"+iso+"')\"";
        html += '<div class="'+cls+'"'+click+'>'+d+'</div>';
    }
    grid.innerHTML = html;
}

function changeMonth(dir) {
    calMonth += dir;
    if (calMonth > 11) { calMonth = 0; calYear++; }
    if (calMonth < 0) { calMonth = 11; calYear--; }
    renderCalendar();
}

function renderTimeSlots() {
    const slots = ['08:00','09:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00'];
    const container = document.getElementById('timeSlots');
    let html = '';
    slots.forEach(t => {
        const sel = t === selectedTime ? ' selected' : '';
        html += '<div class="time-chip px-4 py-2.5 rounded-xl border-2 border-slate-200 bg-white text-sm font-semibold text-slate-700'+sel+'" onclick="selectTime(this,\''+t+'\')">'+t+'</div>';
    });
    container.innerHTML = html;
}
</script>
<%@ include file="logout_script.jsp" %>
</body>
</html>