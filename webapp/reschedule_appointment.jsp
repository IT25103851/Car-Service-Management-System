<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.BookingManager, model.Appointment" %>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) { response.sendRedirect("login.jsp"); return; }

    String appId = request.getParameter("id");
    if (appId == null || appId.isEmpty()) { response.sendRedirect("customer_dashboard.jsp"); return; }

    BookingManager bm = new BookingManager();
    Appointment apt = bm.getAppointmentById(appId);

    if (apt == null || !apt.getCustomerUsername().equals(username) || !"Pending".equals(apt.getStatus())) {
        response.sendRedirect("customer_dashboard.jsp"); return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reschedule Appointment - SwiftDrive</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Plus Jakarta Sans', sans-serif; }
        .cal-day { transition: all 0.15s; cursor: pointer; border-radius: 12px; }
        .cal-day:hover:not(.past):not(.empty):not(.sunday) { background: #eef2ff; color: #4f46e5; }
        .dark .cal-day:hover:not(.past):not(.empty):not(.sunday) { background: rgba(79,70,229,0.1); color: #818cf8; }
        .cal-day.selected { background: #4f46e5 !important; color: #fff !important; font-weight: 800; box-shadow: 0 2px 8px rgba(79,70,229,0.22); }
        .cal-day.past, .cal-day.sunday { color: #cbd5e1; cursor: not-allowed; pointer-events: none; }
        .dark .cal-day.past, .dark .cal-day.sunday { color: #334155; }
        .cal-day.sunday { background: #fef2f2; color: #fca5a5; }
        .dark .cal-day.sunday { background: rgba(252,165,165,0.05); color: #7f1d1d; }
        .cal-day.today { border: 2px solid #4f46e5; font-weight: 700; }
        .time-chip { transition: all 0.2s; cursor: pointer; }
        .time-chip:hover { background: #4f46e5; color: #fff; transform: scale(1.06); }
        .time-chip.selected { background: #4f46e5 !important; color: #fff !important; box-shadow: 0 0 0 3px rgba(79,70,229,0.22); }
        .license-plate {
            font-family: 'JetBrains Mono', 'Courier New', monospace;
            background: linear-gradient(135deg, #fefce8, #fef9c3);
            border: 2px solid #ca8a04; border-radius: 8px; padding: 4px 12px;
            font-weight: 800; font-size: 13px; color: #1e293b; letter-spacing: 1.5px;
            box-shadow: inset 0 1px 2px rgba(0,0,0,0.08);
        }
        .diff-old { background: #fef2f2; border-left: 3px solid #ef4444; }
        .dark .diff-old { background: rgba(239,68,68,0.05); border-left-color: #ef4444; }
        .diff-new { background: #f0fdf4; border-left: 3px solid #10b981; }
        .dark .diff-new { background: rgba(16,185,129,0.05); border-left-color: #10b981; }
        /* Drawer animation */
        .drawer-backdrop { transition: opacity 0.3s; }
        .drawer-panel { transition: transform 0.35s cubic-bezier(.4,0,.2,1); transform: translateY(100%); }
        .drawer-panel.open { transform: translateY(0); }
        
        /* Body scroll lock */
        .modal-open { overflow: hidden !important; height: 100vh !important; }

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
        .flatpickr-months .flatpickr-prev-month, .flatpickr-months .flatpickr-next-month {
            color: #6366f1 !important;
            fill: #6366f1 !important;
            top: 15px !important;
        }
        .flatpickr-day.selected {
            background: #4f46e5 !important;
            border-color: #4f46e5 !important;
            border-radius: 12px !important;
        }
    </style>
    <!-- Flatpickr -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/airbnb.css">
</head>
<body class="antialiased text-slate-900 dark:text-slate-100 bg-slate-50 dark:bg-slate-950 transition-colors duration-300 min-h-screen pt-28 pb-16">
<%@ include file="customer_navbar.jsp" %>

<div class="max-w-3xl mx-auto px-4">
    <!-- HEADER -->
    <div class="mb-12 text-center fade-up">
        <h1 class="text-4xl font-black text-slate-900 dark:text-white tracking-tighter mb-4"><i class="fa-solid fa-calendar-days text-indigo-500 mr-3"></i>Reschedule Service</h1>
        <p class="text-base font-medium text-slate-500 dark:text-slate-400">Change your appointment time for appointment <span class="font-black text-indigo-600 dark:text-indigo-400 mono px-2 py-0.5 bg-indigo-50 dark:bg-indigo-950/50 rounded-lg"><%= apt.getAppointmentId() %></span></p>
    </div>

    <!-- DIFF VIEW: Current Appointment -->
    <div class="bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-[2.5rem] shadow-2xl shadow-slate-200/40 dark:shadow-none overflow-hidden mb-8 fade-up" style="animation-delay:0.1s">
        <div class="bg-slate-950 px-8 py-4">
            <h3 class="text-white text-[10px] font-black uppercase tracking-[0.3em] flex items-center gap-3"><i class="fa-solid fa-file-lines text-indigo-500"></i> Current Appointment</h3>
        </div>
        <div class="p-8 space-y-6">
            <div class="flex flex-wrap items-center gap-8">
                <div>
                    <span class="text-[9px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-widest block mb-2">Vehicle</span>
                    <span class="license-plate dark:bg-slate-950 dark:text-white dark:border-slate-800"><%= apt.getLicensePlate() %></span>
                </div>
                <div class="flex-1 min-w-[120px]">
                    <span class="text-[9px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-widest block mb-2">Service Type</span>
                    <span class="text-sm font-black text-slate-800 dark:text-white"><i class="fa-solid fa-wrench text-indigo-500 mr-2"></i><%= apt.getIssueDescription() %></span>
                </div>
            </div>
            <div class="diff-old rounded-2xl p-5 mt-4">
                <span class="text-[9px] font-black text-red-500 uppercase tracking-widest block mb-2"><i class="fa-solid fa-minus mr-1"></i>Old Schedule</span>
                <p class="text-sm font-black text-red-600 dark:text-red-400"><i class="fa-regular fa-calendar mr-2"></i><%= apt.getPreferredDate() %> <span class="mx-3 opacity-30">|</span> <i class="fa-regular fa-clock mr-2"></i><%= apt.getPreferredTime() %></p>
            </div>
            <div class="diff-new rounded-2xl p-5" id="newSchedulePreview" style="display:none">
                <span class="text-[9px] font-black text-emerald-500 uppercase tracking-widest block mb-2"><i class="fa-solid fa-plus mr-1"></i>Proposed Schedule</span>
                <p class="text-sm font-black text-emerald-600 dark:text-emerald-400" id="newScheduleText"></p>
            </div>
        </div>
    </div>

    <!-- RESCHEDULE FORM -->
    <form action="RescheduleAppointmentServlet" method="POST" id="rescheduleForm">
        <input type="hidden" name="appointmentId" value="<%= apt.getAppointmentId() %>">
        <input type="hidden" name="preferredDate" id="hiddenDate" value="<%= apt.getPreferredDate() %>" required>
        <input type="hidden" name="preferredTime" id="hiddenTime" value="<%= apt.getPreferredTime() %>" required>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-8 mb-8">
            <!-- Calendar -->
            <div class="bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-[2.5rem] p-8 shadow-2xl shadow-slate-200/40 dark:shadow-none fade-up" style="animation-delay:0.2s">
                <h3 class="text-[10px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-widest mb-6"><i class="fa-solid fa-calendar text-indigo-500 mr-2"></i>Select New Date</h3>
                <div id="inlineCalendar"></div>
            </div>

            <!-- Time Slots -->
            <div class="bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-[2.5rem] p-8 shadow-2xl shadow-slate-200/40 dark:shadow-none fade-up" style="animation-delay:0.3s">
                <h3 class="text-[10px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-widest mb-6"><i class="fa-regular fa-clock text-indigo-500 mr-2"></i>Select New Time</h3>
                <div id="inlineTime"></div>
            </div>
        </div>

        <!-- Reason Dropdown -->
        <div class="bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-[2rem] p-8 mb-8 shadow-2xl shadow-slate-200/40 dark:shadow-none fade-up" style="animation-delay:0.35s">
            <h3 class="text-[10px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-widest mb-4"><i class="fa-solid fa-comment-dots text-indigo-500 mr-2"></i>Reason for Rescheduling <span class="text-slate-300 dark:text-slate-800 font-normal ml-2 tracking-normal">(Optional)</span></h3>
            <select class="w-full px-6 py-4 bg-slate-50 dark:bg-slate-950 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black text-slate-900 dark:text-white focus:ring-8 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all cursor-pointer shadow-inner">
                <option value="">— Select a reason —</option>
                <option>Schedule conflict</option>
                <option>Found a more convenient time</option>
                <option>Vehicle not available on original date</option>
                <option>Weather conditions</option>
                <option>Personal emergency</option>
                <option>Other</option>
            </select>
        </div>

        <!-- Actions -->
        <div class="flex flex-col sm:flex-row gap-4 fade-up" style="animation-delay:0.4s">
            <button type="submit" id="btnConfirm" class="flex-1 py-5 rounded-2xl bg-slate-900 dark:bg-white text-white dark:text-slate-950 font-black text-[10px] uppercase tracking-[0.2em] shadow-2xl transition-all flex items-center justify-center gap-3 hover:-translate-y-1 active:scale-95 disabled:opacity-30 disabled:translate-y-0" disabled>
                <i class="fa-solid fa-check-double text-lg"></i> Confirm Changes
            </button>
            <button type="button" onclick="openCancelDrawer()" class="flex-1 py-5 rounded-2xl border border-rose-100 dark:border-rose-900/30 text-rose-600 dark:text-rose-400 font-black text-[10px] uppercase tracking-widest hover:bg-rose-50 dark:hover:bg-rose-950/30 transition-all flex items-center justify-center gap-3">
                <i class="fa-solid fa-xmark text-lg"></i> Cancel Appointment
            </button>
        </div>
        <a href="customer_dashboard.jsp" class="block text-center mt-4 text-sm font-bold text-slate-400 hover:text-slate-600 transition">← Back to Dashboard</a>
    </form>
</div>

<!-- CANCELLATION SLIDE-UP DRAWER -->
<div id="cancelDrawer" class="hidden fixed inset-0 z-50">
    <div class="drawer-backdrop absolute inset-0 bg-slate-950/60 backdrop-blur-md opacity-0" id="drawerBackdrop" onclick="closeCancelDrawer()"></div>
    <div class="drawer-panel absolute bottom-0 left-0 right-0 bg-white dark:bg-slate-900 rounded-t-[3rem] shadow-2xl max-w-lg mx-auto border-t border-slate-100 dark:border-slate-800 overflow-y-auto max-h-[calc(100vh-2rem)] sm:max-h-[90vh] custom-scrollbar" id="drawerPanel">
        <div class="w-16 h-1.5 bg-slate-200 dark:bg-slate-800 rounded-full mx-auto mt-6 mb-4"></div>
        <div class="p-6 pb-8">
            <div class="text-center mb-6">
                <div class="w-20 h-20 rounded-full bg-rose-50 dark:bg-rose-950 flex items-center justify-center mx-auto mb-6">
                    <i class="fa-solid fa-triangle-exclamation text-rose-500 text-3xl"></i>
                </div>
                <h3 class="text-3xl font-black text-slate-900 dark:text-white tracking-tighter">Cancel Appointment?</h3>
                <p class="text-sm font-medium text-slate-500 dark:text-slate-400 mt-4 leading-relaxed">This will cancel your appointment. This action cannot be undone.</p>
            </div>
            <div class="bg-slate-50 dark:bg-slate-950/60 border border-slate-100 dark:border-slate-800 rounded-[2rem] p-6 mb-8 flex items-center gap-6 shadow-inner">
                <span class="license-plate dark:bg-slate-900 dark:text-white dark:border-slate-800"><%= apt.getLicensePlate() %></span>
                <div class="min-w-0">
                    <p class="text-sm font-black text-slate-900 dark:text-white truncate"><%= apt.getIssueDescription() %></p>
                    <p class="text-[9px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-widest mt-1"><%= apt.getPreferredDate() %> • <%= apt.getPreferredTime() %></p>
                </div>
            </div>
            <div class="flex flex-col gap-4">
                <form action="CancelAppointmentServlet" method="POST">
                    <input type="hidden" name="appointmentId" value="<%= apt.getAppointmentId() %>">
                    <button type="submit" class="w-full py-5 rounded-2xl bg-rose-600 hover:bg-rose-700 text-white font-black text-[10px] uppercase tracking-[0.2em] shadow-xl shadow-rose-100 dark:shadow-none transition-all active:scale-95 flex items-center justify-center gap-4">
                        <i class="fa-solid fa-trash-can text-lg"></i> Confirm Cancellation
                    </button>
                </form>
                <button type="button" onclick="closeCancelDrawer()" class="w-full py-5 rounded-2xl bg-white dark:bg-slate-900 border-2 border-slate-100 dark:border-slate-800 text-slate-400 dark:text-slate-600 font-black text-[10px] uppercase tracking-[0.2em] hover:bg-slate-50 dark:hover:bg-slate-800 transition-all">
                    Go Back & Keep Appointment
                </button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<script>
let selectedDate = '<%= apt.getPreferredDate() %>';
let selectedTime = '<%= apt.getPreferredTime() %>';
const origDate = '<%= apt.getPreferredDate() %>';
const origTime = '<%= apt.getPreferredTime() %>';
let calYear, calMonth;

// Init Flatpickr
document.addEventListener("DOMContentLoaded", () => {
    flatpickr("#inlineCalendar", {
        inline: true,
        minDate: "today",
        defaultDate: "<%= apt.getPreferredDate() %>",
        dateFormat: "Y-m-d",
        monthSelectorType: "static",
        disable: [
            function(date) { return (date.getDay() === 0); }
        ],
        onChange: function(selectedDates, dateStr) {
            selectedDate = dateStr;
            document.getElementById('hiddenDate').value = dateStr;
            updatePreview(); checkChanged();
        }
    });

    flatpickr("#inlineTime", {
        inline: true,
        noCalendar: true,
        enableTime: true,
        defaultDate: "<%= apt.getPreferredTime() %>",
        dateFormat: "H:i",
        time_24hr: true,
        minTime: "08:00",
        maxTime: "18:00",
        onChange: function(selectedDates, timeStr) {
            selectedTime = timeStr;
            document.getElementById('hiddenTime').value = timeStr;
            updatePreview(); checkChanged();
        }
    });
    
    updatePreview(); checkChanged();
});

function selectDay(el, dateStr) {
    document.querySelectorAll('.cal-day').forEach(d => d.classList.remove('selected'));
    el.classList.add('selected');
    selectedDate = dateStr;
    document.getElementById('hiddenDate').value = dateStr;
    updatePreview(); checkChanged();
}

function selectTime(el, time) {
    document.querySelectorAll('.time-chip').forEach(c => c.classList.remove('selected'));
    el.classList.add('selected');
    selectedTime = time;
    document.getElementById('hiddenTime').value = time;
    updatePreview(); checkChanged();
}

function updatePreview() {
    const preview = document.getElementById('newSchedulePreview');
    const txt = document.getElementById('newScheduleText');
    if (selectedDate && selectedTime) {
        const d = new Date(selectedDate + 'T00:00:00');
        const formatted = d.toLocaleDateString('en-US',{weekday:'short',month:'short',day:'numeric',year:'numeric'});
        txt.innerHTML = '<i class="fa-regular fa-calendar mr-1"></i>' + formatted + ' <span class="mx-2 text-emerald-400">|</span> <i class="fa-regular fa-clock mr-1"></i>' + selectedTime;
        preview.style.display = 'block';
    }
}

function checkChanged() {
    const changed = (selectedDate !== origDate || selectedTime !== origTime);
    document.getElementById('btnConfirm').disabled = !changed;
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
        const isToday = dt.getTime() === today.getTime();
        const isSel = iso === selectedDate;
        let cls = 'cal-day p-2 text-sm font-medium';
        const isSunday = dt.getDay() === 0;
        const isBlocked = isPast || isSunday;
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

// Drawer controls
function openCancelDrawer() {
    const drawer = document.getElementById('cancelDrawer');
    const backdrop = document.getElementById('drawerBackdrop');
    const panel = document.getElementById('drawerPanel');
    drawer.classList.remove('hidden');
    document.body.classList.add('modal-open');
    setTimeout(() => { backdrop.style.opacity='1'; panel.classList.add('open'); }, 20);
}
function closeCancelDrawer() {
    const backdrop = document.getElementById('drawerBackdrop');
    const panel = document.getElementById('drawerPanel');
    backdrop.style.opacity='0'; panel.classList.remove('open');
    document.body.classList.remove('modal-open');
    setTimeout(() => document.getElementById('cancelDrawer').classList.add('hidden'), 350);
}
</script>
<%@ include file="logout_script.jsp" %>
</body>
</html>
