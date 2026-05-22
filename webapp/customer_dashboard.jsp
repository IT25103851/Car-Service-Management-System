<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.ServiceHistoryList, model.ServiceRecord, model.Node" %>
<%@ page import="model.BookingManager, model.Appointment, java.util.List" %>
<%@ page import="model.VehicleManager, model.Vehicle" %>
<%@ page import="model.BillingManager, model.Invoice, java.util.Stack" %>
<%@ page import="model.FeedbackManager, model.Feedback, java.util.ArrayList" %>
<%@ page import="model.AbstractUser, model.CustomerUser" %>
<%@ page import="model.ChatManager, model.ChatMessage" %>
<%
    String username = (String) session.getAttribute("username");
    if (username == null) { response.sendRedirect("login.jsp"); return; }
    AbstractUser userObj = (AbstractUser) session.getAttribute("userObject");

    // Pre-load all data
    VehicleManager vm = new VehicleManager();
    List<Vehicle> allVehicles = vm.getAllVehicles();
    List<Vehicle> myCars = new ArrayList<>();
    for(Vehicle v : allVehicles) { if(v.getOwnerUsername().equals(username)) myCars.add(v); }

    BookingManager bm = new BookingManager();
    ChatManager chatManager = new ChatManager();
    List<Appointment> allApps = bm.getAllAppointmentsNatively();
    List<Appointment> myApps = new ArrayList<>();
    for(Appointment a : allApps) { if(a.getCustomerUsername().equals(username)) myApps.add(a); }

    ServiceHistoryList list = (ServiceHistoryList) session.getAttribute("serviceList");
    if (list == null) { 
        list = new ServiceHistoryList(); 
        list.loadFromFile(); 
        session.setAttribute("serviceList", list);
    }
    list.sortHistoryByDate();

    FeedbackManager fbMgr = new FeedbackManager();
    List<Feedback> allFeedback = fbMgr.getAllFeedback();
    List<Feedback> myFBs = new ArrayList<>();
    for(Feedback fb : allFeedback) { if(fb.getCustomerUsername().equals(username)) myFBs.add(fb); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Dashboard - SwiftDrive</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Plus Jakarta Sans', sans-serif; }
        .rating-stars { display: flex; flex-direction: row-reverse; justify-content: flex-end; gap: .25rem; }
        .rating-stars input { display: none; }
        .rating-stars label { cursor: pointer; color: #e2e8f0; font-size: 1.5rem; transition: color .2s; }
        .rating-stars input:checked ~ label,
        .rating-stars label:hover,
        .rating-stars label:hover ~ label { color: #facc15; }
        
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
        .no-scrollbar::-webkit-scrollbar { display: none; }
        .no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
        .dark .plate-tag {
            background: #1e293b;
            color: #f8fafc;
            border-color: #f8fafc;
        }

        .modal-panel {
            -webkit-font-smoothing: antialiased;
            backface-visibility: hidden;
        }
        
        .card { 
            background: #fff; 
            border-radius: 1rem; 
            border: 1px solid #e2e8f0; 
            box-shadow: 0 1px 3px rgba(0,0,0,.04); 
            transition: all 0.3s ease;
        }
        .dark .card {
            background: rgba(30, 41, 59, 0.4);
            border-color: rgba(51, 65, 85, 0.5);
            box-shadow: none;
        }

        .card-hdr { 
            background: #EEF2FF; 
            border-bottom: 1px solid #e2e8f0; 
            padding: 1rem 1.25rem; 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            border-radius: 1rem 1rem 0 0; 
        }
        .dark .card-hdr {
            background: rgba(79, 70, 229, 0.1);
            border-bottom-color: rgba(51, 65, 85, 0.5);
        }

        .v-item { transition: all .15s; }
        .v-item:hover { background: #F8FAFC; transform: translateX(3px); }
        .dark .v-item:hover { background: rgba(51, 65, 85, 0.3); }

    </style>
</head>
<body class="antialiased text-slate-900 dark:text-slate-100 bg-slate-50 dark:bg-slate-950 transition-colors duration-300">
<%@ include file="customer_navbar.jsp" %>

<div class="max-w-7xl mx-auto py-6 px-4 pt-24">

    <!-- WELCOME HEADER -->
    <div class="mb-6 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div>
            <h1 class="text-2xl sm:text-3xl font-black tracking-tight text-slate-900 dark:text-white leading-none">
                Welcome back, <span class="bg-clip-text text-transparent bg-gradient-to-r from-indigo-600 to-violet-600"><%= username %></span>!
            </h1>
            <p class="text-slate-500 dark:text-slate-400 text-xs sm:text-sm mt-1.5 font-medium">Manage your vehicles, book services, and track maintenance history.</p>
            
            <% if (userObj instanceof CustomerUser) {
                CustomerUser cUser = (CustomerUser) userObj;
                if (cUser.getServiceDiscount() > 0) { %>
                <div class="mt-2.5 inline-flex items-center gap-1.5 bg-indigo-50 dark:bg-indigo-900/30 border border-indigo-100 dark:border-indigo-800/50 text-indigo-750 dark:text-indigo-300 px-3 py-1 rounded-xl text-[9px] font-black uppercase tracking-wider">
                    <i class="fa-solid fa-crown text-amber-500"></i> <%= cUser.getMembershipTier() %> &bull; <%=(int)(cUser.getServiceDiscount() * 100)%>% Discount
                </div>
            <% } } %>
        </div>
        
        <div class="flex gap-2">
            <div class="bg-white dark:bg-slate-800/50 backdrop-blur-md p-3 rounded-2xl border border-slate-200 dark:border-slate-800 shadow-sm flex items-center gap-3">
                <div class="w-10 h-10 rounded-xl bg-indigo-50 dark:bg-indigo-900/40 flex items-center justify-center text-indigo-600 dark:text-indigo-400">
                    <i class="fa-solid fa-car-side text-lg"></i>
                </div>
                <div>
                    <p class="text-[8px] font-black text-slate-400 uppercase tracking-widest leading-none">Fleet Size</p>
                    <p class="text-base font-black text-slate-850 dark:text-white mt-1 leading-none"><%= myCars.size() %> Vehicles</p>
                </div>
            </div>
        </div>
    </div>

    <!-- MAIN DASHBOARD GRID -->
    <div class="grid grid-cols-1 lg:grid-cols-12 gap-6">

        <!-- LEFT/CENTER: HISTORY & APPOINTMENTS (COL 8) -->
        <div class="lg:col-span-8 space-y-6">
            
            <!-- APPOINTMENTS SECTION -->
            <section>
                <div class="flex items-center justify-between mb-3 px-1">
                    <h2 class="text-sm font-black text-slate-800 dark:text-white flex items-center gap-2">
                        <i class="fa-regular fa-calendar-check text-indigo-600"></i> Upcoming Appointments
                    </h2>
                    <a href="book_appointment.jsp" class="bg-indigo-600 hover:bg-indigo-700 text-white text-[9px] font-black px-4 py-2 rounded-lg shadow-sm transition-all hover:-translate-y-0.5 uppercase tracking-wider">
                        <i class="fa-solid fa-calendar-plus mr-1"></i>Book New
                    </a>
                </div>
                
                <div class="max-h-[380px] overflow-y-auto pr-1 no-scrollbar">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-3 sm:gap-4">
                        <% boolean hasApp = false;
                           for (Appointment app : myApps) {
                               hasApp = true;
                               String statusText = app.getStatus();
                               String cardCls = "bg-white dark:bg-slate-800/40 border-slate-200 dark:border-slate-700";
                               String statusPill = "bg-amber-50 text-amber-600 border-amber-100 dark:bg-amber-900/30 dark:text-amber-400 dark:border-amber-900/10";
                               
                               if ("Under Maintenance".equals(statusText)) {
                                   statusPill = "bg-orange-50 text-orange-600 border-orange-100 dark:bg-orange-900/30 dark:text-orange-400 dark:border-orange-900/10";
                               } else if ("Completed".equals(statusText)) {
                                   statusPill = "bg-emerald-50 text-emerald-600 border-emerald-100 dark:bg-emerald-900/30 dark:text-emerald-400 dark:border-emerald-900/10";
                               } %>
                            <div class="card p-4 group hover:border-indigo-300 dark:hover:border-indigo-700 transition-all">
                                <div class="flex justify-between items-start mb-3">
                                    <div class="w-8 h-8 rounded-lg bg-slate-50 dark:bg-slate-900/60 flex items-center justify-center text-slate-450 group-hover:text-indigo-500 transition-colors">
                                        <i class="fa-solid fa-wrench text-sm"></i>
                                    </div>
                                    <span class="text-[8px] font-black px-2 py-0.5 rounded-md border uppercase tracking-wider <%= statusPill %>"><%= statusText %></span>
                                </div>
                                <h3 class="font-black text-slate-800 dark:text-white text-sm"><%= app.getLicensePlate() %></h3>
                                <p class="text-[11px] text-slate-500 dark:text-slate-400 mt-1 line-clamp-1"><%= app.getIssueDescription() %></p>
                                
                                <div class="mt-3 flex items-center gap-3 text-[10px] font-black text-slate-400">
                                    <span class="flex items-center gap-1"><i class="fa-regular fa-calendar text-indigo-500"></i> <%= app.getPreferredDate() %></span>
                                    <span class="flex items-center gap-1"><i class="fa-regular fa-clock text-indigo-500"></i> <%= app.getPreferredTime() %></span>
                                </div>

                                <div class="mt-4 pt-3 border-t border-slate-100 dark:border-slate-750 flex gap-2">
                                    <% 
                                        boolean isChatOpen = ChatManager.isChatWindowOpen(app.getCompletedDate(), 7);
                                        if (isChatOpen) {
                                            int unread = chatManager.getUnreadCountForUser(app.getAppointmentId(), "customer"); 
                                            long daysLeft = ChatManager.getRemainingDays(app.getCompletedDate(), 7);
                                    Long rawDays = (daysLeft >= 0) ? daysLeft : 0L;
                                    %>
                                    <a href="appointment_chat.jsp?appId=<%= app.getAppointmentId() %>" class="relative flex-[0.3] flex flex-col items-center justify-center bg-slate-50 dark:bg-slate-900/60 text-slate-500 hover:text-indigo-600 rounded-lg transition-all border border-transparent hover:border-indigo-100/50 py-1">
                                        <i class="fa-solid fa-comments text-base"></i>
                                        <% if ("Completed".equals(statusText)) { %>
                                            <span class="text-[7px] font-black uppercase text-slate-400 mt-0.5"><%= rawDays %>d left</span>
                                        <% } %>
                                        <% if (unread > 0) { %>
                                            <span class="absolute -top-1 -right-1 w-3.5 h-3.5 bg-rose-500 text-white rounded-full flex items-center justify-center text-[7px] animate-pulse"><%= unread %></span>
                                        <% } %>
                                    </a>
                                    <% } else { %>
                                    <div class="relative flex-[0.3] flex flex-col items-center justify-center bg-slate-50 dark:bg-slate-900/60 text-slate-400 rounded-lg py-1 opacity-50 cursor-not-allowed">
                                        <i class="fa-solid fa-comments text-base"></i>
                                        <span class="text-[7px] font-black uppercase text-slate-455 mt-0.5">Expired</span>
                                    </div>
                                    <% } %>
                                    
                                    <% if ("Pending".equals(statusText)) { %>
                                        <a href="reschedule_appointment.jsp?id=<%= app.getAppointmentId() %>" class="flex-1 text-center bg-slate-50 dark:bg-slate-900/60 text-slate-700 dark:text-slate-300 hover:bg-indigo-600 hover:text-white text-[10px] font-black py-2 rounded-lg transition-all flex items-center justify-center uppercase tracking-wider">Reschedule</a>
                                        <button type="button" onclick="openCancelAppModal('<%= app.getAppointmentId() %>')" class="flex-1 bg-slate-50 dark:bg-slate-900/60 text-red-500 hover:bg-red-500 hover:text-white text-[10px] font-black py-2 rounded-lg transition-all uppercase tracking-wider">Cancel</button>
                                    <% } else { %>
                                        <button disabled class="flex-1 bg-slate-50 dark:bg-slate-900/30 text-slate-400 dark:text-slate-600 text-[10px] font-black py-2 rounded-lg cursor-not-allowed uppercase tracking-wider">Locked</button>
                                    <% } %>
                                </div>
                            </div>
                        <% } if (!hasApp) { %>
                            <div class="col-span-full bg-white dark:bg-slate-800/40 border-2 border-dashed border-slate-200 dark:border-slate-800 rounded-2xl p-6 text-center w-full">
                                <div class="w-12 h-12 bg-slate-50 dark:bg-slate-900 rounded-full flex items-center justify-center mx-auto mb-3">
                                    <i class="fa-regular fa-calendar text-slate-400 text-lg"></i>
                                </div>
                                <p class="text-xs text-slate-500 dark:text-slate-400 font-bold">No active appointments found.</p>
                                <a href="book_appointment.jsp" class="text-indigo-600 dark:text-indigo-400 text-[11px] font-black mt-1 inline-block hover:underline">Book your first service &rarr;</a>
                            </div>
                        <% } %>
                    </div>
                </div>
            </section>

            <!-- SERVICE HISTORY SECTION -->
            <section class="card overflow-hidden">
                <div class="px-4 py-3.5 border-b border-slate-100 dark:border-slate-800/80 flex justify-between items-center">
                    <h2 class="text-sm font-black text-slate-800 dark:text-white flex items-center gap-2">
                        <i class="fa-solid fa-clipboard-list text-indigo-600"></i> Service History
                    </h2>
                    <span class="text-[8px] font-black uppercase tracking-widest text-slate-400 bg-slate-100 dark:bg-slate-800 px-2 py-1 rounded-md">Recent Logs</span>
                </div>
                <div class="overflow-x-auto max-h-[200px] overflow-y-auto pr-1">
                    <table class="min-w-full">
                        <thead>
                            <tr class="bg-slate-50 dark:bg-slate-800/50">
                                <th class="px-4 py-3 text-left text-[9px] font-black text-slate-400 uppercase tracking-widest">Date</th>
                                <th class="px-4 py-3 text-left text-[9px] font-black text-slate-400 uppercase tracking-widest">Vehicle</th>
                                <th class="px-4 py-3 text-left text-[9px] font-black text-slate-400 uppercase tracking-widest">Service Type</th>
                                <th class="px-4 py-3 text-left text-[9px] font-black text-slate-400 uppercase tracking-widest text-right">Review</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100 dark:divide-slate-800/50">
                            <% Node current = list.head;
                               boolean hasHistory = false;
                               while (current != null) {
                                   boolean belongsToUser = false;
                                   for(Vehicle c : myCars) { if(c.getLicensePlate().equals(current.data.getLicensePlate())) { belongsToUser = true; break; } }
                                   if(belongsToUser) {
                                       hasHistory = true;
                                       String expectedRef = current.data.getDate() + " - " + current.data.getServiceType() + " [" + current.data.getLicensePlate() + "]";
                                       Feedback matchedFb = null;
                                       for(Feedback f : myFBs) { if(f.getServiceRef().equals(expectedRef)) { matchedFb = f; break; } }
                                       boolean hasFb = matchedFb != null;
                                       int rating = hasFb ? matchedFb.getRating() : 0;
                                       String reply = hasFb ? matchedFb.getAdminReply() : "";
                                       String fbId = hasFb ? matchedFb.getFeedbackId() : "";
                                       String msg = hasFb ? matchedFb.getMessage() : "";
                                       
                                       java.util.Base64.Encoder encoder = java.util.Base64.getEncoder();
                                       String b64Service = encoder.encodeToString((current.data.getServiceType() != null ? current.data.getServiceType() : "").getBytes(java.nio.charset.StandardCharsets.UTF_8));
                                       String b64Parts = encoder.encodeToString((current.data.getPartsUsed() != null ? current.data.getPartsUsed() : "").getBytes(java.nio.charset.StandardCharsets.UTF_8));
                                       String b64Reply = encoder.encodeToString((reply != null ? reply : "").getBytes(java.nio.charset.StandardCharsets.UTF_8));
                                       String b64Msg = encoder.encodeToString((msg != null ? msg : "").getBytes(java.nio.charset.StandardCharsets.UTF_8));
                            %>
                            <tr class="group hover:bg-indigo-50/50 dark:hover:bg-indigo-900/10 cursor-pointer transition-all"
                                data-date="<%= current.data.getDate() %>"
                                data-plate="<%= current.data.getLicensePlate() %>"
                                data-cost="<%= String.format("%,.2f", current.data.getCost()) %>"
                                data-hasfb="<%= hasFb %>"
                                data-rating="<%= rating %>"
                                data-fbid="<%= fbId %>"
                                data-b64-service="<%= b64Service %>"
                                data-b64-parts="<%= b64Parts %>"
                                data-b64-reply="<%= b64Reply %>"
                                data-b64-msg="<%= b64Msg %>"
                                onclick="openHistoryModalFromElement(this)">
                                <td class="px-4 py-3 text-xs font-bold text-slate-700 dark:text-slate-300"><%= current.data.getDate() %></td>
                                <td class="px-4 py-3">
                                    <span class="plate-tag text-[9px] font-black bg-white dark:bg-slate-900 border border-slate-900 dark:border-slate-100 text-slate-900 dark:text-white px-2 py-0.5 rounded"><%= current.data.getLicensePlate() %></span>
                                </td>
                                <td class="px-4 py-3">
                                    <div class="flex flex-col">
                                        <span class="text-xs font-black text-slate-850 dark:text-white leading-tight"><%= current.data.getServiceType() %></span>
                                        <span class="text-[9px] text-slate-400 dark:text-slate-500 mt-0.5 leading-none"><%= current.data.getPartsUsed() != null ? current.data.getPartsUsed() : "Full Inspection" %></span>
                                    </div>
                                </td>
                                <td class="px-4 py-3 text-right">
                                    <% if(hasFb) { %>
                                        <div class="flex justify-end text-yellow-500 text-[10px] gap-0.5">
                                            <% for(int s=1;s<=5;s++) { %><i class="<%= (s<=rating)?"fa-solid":"fa-regular" %> fa-star"></i><% } %>
                                        </div>
                                    <% } else { %>
                                        <span class="text-[8px] font-black text-indigo-650 dark:text-indigo-400 bg-indigo-50 dark:bg-indigo-900/40 px-2 py-0.5 rounded uppercase tracking-wider">Rate</span>
                                    <% } %>
                                </td>
                            </tr>
                            <% } current = current.next; } if (!hasHistory) { %>
                            <tr><td colspan="4" class="px-4 py-8 text-center text-slate-400 italic text-xs font-medium">Your service journey starts here. No logs yet.</td></tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </section>
        </div>

        <!-- RIGHT COLUMN: GARAGE & BILLING (COL 4) -->
        <div class="lg:col-span-4 space-y-6">
            
            <!-- GARAGE CARD -->
            <section class="card overflow-hidden">
                <div class="px-4 py-3.5 border-b border-slate-100 dark:border-slate-800/80 flex justify-between items-center bg-slate-50/50 dark:bg-slate-800/30">
                    <h2 class="text-xs font-black text-slate-800 dark:text-white uppercase tracking-wider flex items-center gap-2">
                        <i class="fa-solid fa-warehouse text-indigo-600"></i> My Garage
                    </h2>
                    <a href="customer_vehicles.jsp" class="text-indigo-650 dark:text-indigo-400 hover:underline text-[10px] font-black uppercase tracking-wider">View All</a>
                </div>
                <div class="p-4 max-h-[320px] overflow-y-auto space-y-3 pr-1">
                    <% boolean hasGarage = false; int vIdx=0;
                       for(Vehicle car : myCars) { hasGarage = true; String vId = "v" + vIdx++; %>
                        <div class="p-3 bg-slate-50 dark:bg-slate-900/40 rounded-xl border border-slate-100 dark:border-slate-800/50 group transition-all hover:bg-white dark:hover:bg-slate-800 hover:shadow-md hover:shadow-slate-200/40 dark:hover:shadow-none">
                            <div class="flex items-start gap-3">
                                <div class="w-9 h-9 rounded-lg bg-white dark:bg-slate-800 shadow-sm flex items-center justify-center text-slate-400 group-hover:text-indigo-500 transition-colors">
                                    <i class="fa-solid fa-car text-base"></i>
                                </div>
                                <div class="flex-1 min-w-0">
                                    <h3 class="font-black text-slate-800 dark:text-white text-xs truncate"><%= car.getMake() %> <%= car.getModel() %></h3>
                                    <div class="flex items-center gap-1.5 mt-1.5">
                                        <span class="plate-tag text-[8px] bg-white dark:bg-slate-900 border border-slate-900 dark:border-slate-100 text-slate-900 dark:text-white px-1.5 py-0.5 rounded"><%= car.getLicensePlate() %></span>
                                        <span class="text-[9px] font-bold text-slate-400 dark:text-slate-500"><%= car.getMileage() %> KM</span>
                                    </div>
                                </div>
                            </div>
                            <div class="mt-3 pt-3 border-t border-slate-200/50 dark:border-slate-800 flex gap-1.5">
                                <button onclick="toggleMileageForm('<%= vId %>')" class="flex-1 bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-650 dark:text-slate-400 hover:bg-indigo-50 dark:hover:bg-indigo-900/30 text-[9px] font-black py-1.5 rounded-lg transition-all uppercase tracking-wider">Update KM</button>
                                <a href="customer_vehicles.jsp" class="bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-650 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-700 p-1.5 rounded-lg text-[9px] transition-all"><i class="fa-solid fa-chevron-right text-xs"></i></a>
                            </div>
                            <div id="<%= vId %>" style="max-height:0;overflow:hidden;transition:all 0.3s ease">
                                <form action="UpdateMileageServlet" method="POST" class="mt-2 pt-2 flex gap-1.5 border-t border-dashed border-slate-200 dark:border-slate-850">
                                    <input type="hidden" name="plate" value="<%= car.getLicensePlate() %>">
                                    <input type="number" name="mileage" min="0" required placeholder="<%= car.getMileage() %>" class="flex-1 bg-white dark:bg-slate-900 px-2.5 py-1 rounded-lg text-[11px] border border-slate-200 dark:border-slate-700 outline-none focus:ring-1 focus:ring-indigo-500 dark:text-white">
                                    <button type="submit" class="bg-indigo-600 text-white text-[9px] font-black px-3 py-1 rounded-lg uppercase tracking-wider">Save</button>
                                </form>
                            </div>
                        </div>
                    <% } if(!hasGarage) { %>
                        <div class="py-6 text-center"><i class="fa-solid fa-car-tunnel text-slate-450 dark:text-slate-850 text-3xl mb-2 block"></i><p class="text-[10px] text-slate-500 dark:text-slate-450 font-black uppercase tracking-wider">No vehicles in garage.</p></div>
                    <% } %>
                </div>
            </section>

            <!-- RECENT BILLING -->
            <section class="card overflow-hidden">
                <div class="px-4 py-3.5 border-b border-slate-100 dark:border-slate-800/80 flex justify-between items-center bg-slate-50/50 dark:bg-slate-800/30">
                    <h2 class="text-xs font-black text-slate-800 dark:text-white uppercase tracking-wider flex items-center gap-2">
                        <i class="fa-solid fa-file-invoice-dollar text-indigo-600"></i> Recent Invoices
                    </h2>
                </div>
                <div class="p-4 max-h-[260px] overflow-y-auto space-y-3 pr-1">
                    <% boolean hasBills = false; Stack<Invoice> allBills = new BillingManager().getAllInvoices();
                       for (int i = allBills.size() - 1; i >= 0 && i >= allBills.size()-5; i--) {
                           Invoice inv = allBills.get(i);
                           if (inv.getCustomerUsername().equals(username)) {
                               hasBills = true;
                               String statusCls = "PAID".equals(inv.getStatus()) ? "text-emerald-500 bg-emerald-50 dark:bg-emerald-900/30 border-emerald-100 dark:border-emerald-800/50" : "text-rose-500 bg-rose-50 dark:bg-rose-900/30 border-rose-100 dark:border-rose-800/50";
                    %>
                        <div class="flex justify-between items-center p-2.5 border-b border-slate-50 dark:border-slate-850 last:border-0 group">
                            <div class="min-w-0">
                                <p class="text-xs font-bold text-slate-805 dark:text-white truncate leading-tight"><%= inv.getServiceDescription() %></p>
                                <p class="text-[9px] font-bold text-slate-400 mt-1 leading-none"><%= inv.getInvoiceId() %> &bull; <%= inv.getLicensePlate() %></p>
                            </div>
                            <div class="text-right">
                                <p class="text-xs font-black text-slate-900 dark:text-white leading-none">LKR <%= String.format("%,.0f", inv.getTotalAmount()) %></p>
                                <span class="text-[7px] font-black uppercase px-1.5 py-0.5 rounded border inline-block mt-1 tracking-wider <%= statusCls %>"><%= inv.getStatus() %></span>
                            </div>
                        </div>
                    <% } } if(!hasBills) { %>
                        <div class="py-6 text-center"><i class="fa-solid fa-receipt text-slate-450 dark:text-slate-850 text-3xl mb-2 block"></i><p class="text-[10px] text-slate-500 dark:text-slate-450 font-black uppercase tracking-wider">No billing activity.</p></div>
                    <% } %>
                </div>
            </section>
        </div>
    </div>
</div>

<!-- MODAL OVERLAY -->
<div id="historyModal" class="hidden fixed inset-0 z-[200] overflow-y-auto no-scrollbar">
    <div class="fixed inset-0 bg-slate-950/40 backdrop-blur-sm transition-opacity" onclick="closeHistoryModal()"></div>
    
    <!-- Wrapper for centering -->
    <div class="flex min-h-full justify-center p-4 text-center">
        <div class="modal-panel relative bg-white dark:bg-slate-900 rounded-2xl shadow-2xl max-w-md w-full p-6 border border-slate-200 dark:border-slate-800 text-left transition-all my-auto" id="hModalPanel">
            
            <div class="flex justify-between items-start mb-6">
                <div class="flex items-center gap-3">
                    <div class="w-10 h-10 rounded-xl bg-indigo-650 flex items-center justify-center text-white shadow-sm">
                        <i class="fa-solid fa-book-open text-lg"></i>
                    </div>
                    <div>
                        <h3 class="text-sm font-black text-slate-900 dark:text-white uppercase tracking-wider">Service History Details</h3>
                        <p id="modalDate" class="text-[10px] font-black text-slate-400 mt-0.5"></p>
                    </div>
                </div>
                <button onclick="closeHistoryModal()" class="w-7 h-7 rounded-lg bg-slate-50 dark:bg-slate-800 hover:bg-red-50 dark:hover:bg-red-900/30 text-slate-400 hover:text-red-500 transition-all flex items-center justify-center">
                    <i class="fa-solid fa-xmark text-sm"></i>
                </button>
            </div>

            <div class="space-y-4">
                <div class="grid grid-cols-2 gap-3">
                    <div class="bg-slate-50 dark:bg-slate-800/40 p-3 rounded-xl border border-slate-100 dark:border-slate-800/40">
                        <span class="text-[8px] font-black uppercase text-slate-400 tracking-widest block mb-1">Vehicle</span>
                        <span id="modalPlate" class="plate-tag text-[9px] font-black bg-white dark:bg-slate-900 border border-slate-900 dark:border-slate-100"></span>
                    </div>
                    <div class="bg-slate-50 dark:bg-slate-800/40 p-3 rounded-xl border border-slate-100 dark:border-slate-800/40">
                        <span class="text-[8px] font-black uppercase text-slate-400 tracking-widest block mb-1">Type</span>
                        <span id="modalService" class="text-xs font-black text-slate-800 dark:text-white block truncate"></span>
                    </div>
                </div>

                <div class="p-3.5 bg-indigo-600 rounded-xl text-white flex justify-between items-center shadow-md">
                    <div>
                        <span class="text-[8px] font-black uppercase tracking-widest text-indigo-200 block mb-0.5">Total Paid</span>
                        <span id="modalCost" class="text-lg font-black"></span>
                    </div>
                    <i class="fa-solid fa-check-double text-xl text-indigo-400/50"></i>
                </div>

                <div class="bg-slate-50 dark:bg-slate-800/40 p-3.5 rounded-xl border border-slate-100 dark:border-slate-800/40">
                    <span class="text-[8px] font-black uppercase text-slate-400 tracking-widest block mb-1.5"><i class="fa-solid fa-layer-group mr-1 text-indigo-500"></i>Parts & Service Details</span>
                    <p id="modalParts" class="text-xs font-bold text-slate-700 dark:text-slate-300 leading-relaxed"></p>
                </div>

                <!-- FEEDBACK BLOCK -->
                <div id="feedbackFormBlock" class="pt-1">
                    <h4 class="text-xs font-black text-slate-900 dark:text-white uppercase tracking-wider mb-2.5">Rate your experience</h4>
                    <form action="SubmitFeedbackServlet" method="POST" id="mainFeedbackForm" class="space-y-3">
                        <input type="hidden" name="serviceRef" id="feedbackServiceRef">
                        <input type="hidden" name="feedbackId" id="editFeedbackId">
                        <input type="hidden" id="deleteFeedbackId">
                        <div class="rating-stars mb-2">
                            <input type="radio" id="star5" name="rating" value="5" required/><label for="star5" class="text-base"><i class="fa-solid fa-star"></i></label>
                            <input type="radio" id="star4" name="rating" value="4"/><label for="star4" class="text-base"><i class="fa-solid fa-star"></i></label>
                            <input type="radio" id="star3" name="rating" value="3"/><label for="star3" class="text-base"><i class="fa-solid fa-star"></i></label>
                            <input type="radio" id="star2" name="rating" value="2"/><label for="star2" class="text-base"><i class="fa-solid fa-star"></i></label>
                            <input type="radio" id="star1" name="rating" value="1"/><label for="star1" class="text-base"><i class="fa-solid fa-star"></i></label>
                        </div>
                        <textarea name="message" id="feedbackMessageArea" rows="2" class="w-full bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl p-3 text-xs font-medium focus:ring-1 focus:ring-indigo-500/30 focus:border-indigo-500 outline-none transition-all dark:text-white" placeholder="Any comments for our team?"></textarea>
                        <button type="submit" id="feedbackSubmitBtn" class="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-black py-2.5 rounded-xl shadow-sm text-[10px] uppercase tracking-wider transition-all hover:scale-[1.01] active:scale-[0.99]">Post Review</button>
                    </form>
                </div>

                <div id="feedbackSubmittedBlock" class="hidden pt-1">
                    <div class="flex items-center justify-between mb-2.5">
                        <h4 class="text-xs font-black text-slate-900 dark:text-white uppercase tracking-wider flex items-center gap-1.5">
                            <i class="fa-solid fa-circle-check text-emerald-500"></i> Feedback Posted
                        </h4>
                        <div class="flex gap-3">
                            <button onclick="enableFeedbackEdit()" class="text-[10px] font-black text-indigo-600 dark:text-indigo-400 hover:underline uppercase tracking-wider">Edit</button>
                            <button type="button" onclick="openDeleteFeedbackModal()" class="text-[10px] font-black text-red-500 hover:underline uppercase tracking-wider">Delete</button>
                        </div>
                    </div>
                    <div class="bg-slate-50 dark:bg-slate-800/40 p-4 rounded-xl border border-slate-100 dark:border-slate-800/40">
                        <div class="flex items-center gap-1.5 mb-2.5"><span class="text-[8px] font-black uppercase text-slate-400 tracking-widest">Rating:</span><div class="flex text-yellow-500 gap-0.5 text-xs" id="modalDisplayStars"></div></div>
                        <p id="modalUserComment" class="text-xs font-bold text-slate-700 dark:text-slate-300 italic leading-relaxed"></p>
                        <div id="modalAdminReplyBlock" class="mt-3 pt-3 border-t border-slate-200/50 dark:border-slate-800">
                            <span class="text-[8px] font-black uppercase text-indigo-500 tracking-widest block mb-1.5">Team SwiftDrive Reply:</span>
                            <p class="text-xs font-black text-indigo-700 dark:text-indigo-300 bg-white dark:bg-indigo-900/30 p-3 rounded-lg border border-indigo-100 dark:border-indigo-900/40" id="modalAdminReplyText"></p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
function decodeB64UTF8(str) {
    if (!str) return "";
    try {
        return decodeURIComponent(escape(window.atob(str)));
    } catch(e) {
        return "";
    }
}

function openHistoryModalFromElement(el) {
    var date = el.getAttribute('data-date');
    var plate = el.getAttribute('data-plate');
    var cost = el.getAttribute('data-cost');
    var hasFb = el.getAttribute('data-hasfb') === 'true';
    var rating = parseInt(el.getAttribute('data-rating')) || 0;
    var fbId = el.getAttribute('data-fbid') || "";
    
    var service = decodeB64UTF8(el.getAttribute('data-b64-service'));
    var parts = decodeB64UTF8(el.getAttribute('data-b64-parts'));
    var adminReply = decodeB64UTF8(el.getAttribute('data-b64-reply'));
    var userComment = decodeB64UTF8(el.getAttribute('data-b64-msg'));

    openHistoryModal(date, plate, service, parts, cost, hasFb, rating, adminReply, fbId, userComment);
}
function openHistoryModal(date, plate, service, parts, cost, hasFb, rating, adminReply, fbId, userComment) {
    document.body.style.overflow = 'hidden';
    document.getElementById('modalDate').innerText = date;
    document.getElementById('modalPlate').innerText = plate;
    document.getElementById('modalService').innerText = service;
    document.getElementById('modalParts').innerText = parts && parts !== 'null' ? parts : 'No specific parts replaced.';
    document.getElementById('modalCost').innerText = 'LKR ' + cost;
    document.getElementById('feedbackServiceRef').value = date + " - " + service + " [" + plate + "]";
    document.getElementById('editFeedbackId').value = fbId;
    document.getElementById('deleteFeedbackId').value = fbId;
    document.getElementById('feedbackMessageArea').value = userComment || '';
    
    if (hasFb) {
        document.getElementById('feedbackFormBlock').classList.add('hidden');
        document.getElementById('feedbackSubmittedBlock').classList.remove('hidden');
        document.getElementById('modalUserComment').innerText = userComment ? '"' + userComment + '"' : 'No comments provided.';
        let s = ''; for (let i = 1; i <= 5; i++) s += '<i class="' + (i <= rating ? 'fa-solid' : 'fa-regular') + ' fa-star"></i>';
        document.getElementById('modalDisplayStars').innerHTML = s;
        
        // Pre-select the rating in the edit form rating-stars
        const starRadio = document.getElementById('star' + rating);
        if (starRadio) starRadio.checked = true;
        
        if (adminReply && adminReply !== 'none') { 
            document.getElementById('modalAdminReplyBlock').classList.remove('hidden'); 
            document.getElementById('modalAdminReplyText').innerText = adminReply; 
        } else { 
            document.getElementById('modalAdminReplyBlock').classList.add('hidden'); 
        }
    } else {
        document.getElementById('feedbackFormBlock').classList.remove('hidden');
        document.getElementById('feedbackSubmittedBlock').classList.add('hidden');
        document.getElementById('mainFeedbackForm').action = 'SubmitFeedbackServlet';
        document.getElementById('feedbackSubmitBtn').innerText = 'Post Review';
        document.querySelectorAll('.rating-stars input').forEach(i => i.checked = false);
    }
    document.getElementById('historyModal').classList.remove('hidden');
}

function enableFeedbackEdit() {
    document.getElementById('feedbackSubmittedBlock').classList.add('hidden');
    document.getElementById('feedbackFormBlock').classList.remove('hidden');
    document.getElementById('mainFeedbackForm').action = 'UpdateFeedbackServlet';
    document.getElementById('feedbackSubmitBtn').innerText = 'Update Review';
}

function closeHistoryModal() {
    document.getElementById('historyModal').classList.add('hidden');
    document.body.style.overflow = 'auto';
}
function toggleMileageForm(id){
    const el=document.getElementById(id);
    if(el.style.maxHeight==='0px'||el.style.maxHeight===''){el.style.maxHeight=el.scrollHeight+20+'px';}else{el.style.maxHeight='0px';}
}

function openCancelAppModal(appId) {
    document.getElementById('cancelAppIdInput').value = appId;
    document.getElementById('cancelAppDisplay').textContent = appId;
    
    document.body.classList.add('overflow-hidden');
    const m = document.getElementById('cancelAppModal'); m.classList.remove('hidden');
    setTimeout(() => { 
        document.getElementById('cancelAppBackdrop').style.opacity = '1'; 
        document.getElementById('cancelAppPanel').classList.remove('scale-95', 'opacity-0');
        document.getElementById('cancelAppPanel').classList.add('scale-100', 'opacity-100');
    }, 20);
}

function closeCancelAppModal() {
    document.getElementById('cancelAppBackdrop').style.opacity = '0';
    document.getElementById('cancelAppPanel').classList.remove('scale-100', 'opacity-100');
    document.getElementById('cancelAppPanel').classList.add('scale-95', 'opacity-0');
    document.body.classList.remove('overflow-hidden');
    setTimeout(() => document.getElementById('cancelAppModal').classList.add('hidden'), 300);
}

function openDeleteFeedbackModal() {
    document.getElementById('deleteFeedbackModalInput').value = document.getElementById('deleteFeedbackId').value;
    
    // Ensure history modal doesn't trap focus or look weird
    const m = document.getElementById('deleteFeedbackModal'); m.classList.remove('hidden');
    setTimeout(() => { 
        document.getElementById('deleteFeedbackBackdrop').style.opacity = '1'; 
        document.getElementById('deleteFeedbackPanel').classList.remove('scale-95', 'opacity-0');
        document.getElementById('deleteFeedbackPanel').classList.add('scale-100', 'opacity-100');
    }, 20);
}

function closeDeleteFeedbackModal() {
    document.getElementById('deleteFeedbackBackdrop').style.opacity = '0';
    document.getElementById('deleteFeedbackPanel').classList.remove('scale-100', 'opacity-100');
    document.getElementById('deleteFeedbackPanel').classList.add('scale-95', 'opacity-0');
    setTimeout(() => document.getElementById('deleteFeedbackModal').classList.add('hidden'), 300);
}
</script>

<!-- CANCEL APPOINTMENT MODAL -->
<div id="cancelAppModal" class="hidden fixed inset-0 z-[200] flex items-center justify-center p-4">
    <div class="absolute inset-0 bg-slate-950/60 backdrop-blur-sm opacity-0 transition-opacity duration-300" id="cancelAppBackdrop" onclick="closeCancelAppModal()"></div>
    <div class="relative bg-white dark:bg-slate-900 rounded-2xl shadow-2xl max-w-xs w-full border border-slate-100 dark:border-slate-800 overflow-y-auto max-h-[calc(100vh-2rem)] sm:max-h-[90vh] custom-scrollbar transform scale-95 opacity-0 transition-all duration-300" id="cancelAppPanel">
        <div class="p-6 text-center">
            <div class="w-14 h-14 rounded-xl bg-rose-50 dark:bg-rose-950/30 flex items-center justify-center mx-auto mb-4 text-rose-500 shadow-inner border border-rose-100 dark:border-rose-900/30">
                <i class="fa-solid fa-trash-can text-xl"></i>
            </div>
            <h3 class="text-base font-black text-slate-900 dark:text-white uppercase tracking-wider">Cancel Appointment?</h3>
            <p class="text-xs font-medium text-slate-500 dark:text-slate-400 mt-2 leading-relaxed">
                Are you sure you want to cancel appointment <span id="cancelAppDisplay" class="font-bold text-slate-900 dark:text-white"></span>?
            </p>
            
            <form action="CancelAppointmentServlet" method="POST" class="flex flex-col gap-2 mt-6">
                <input type="hidden" name="appointmentId" id="cancelAppIdInput">
                <button type="submit" class="w-full py-2.5 rounded-lg bg-rose-600 hover:bg-rose-700 text-white font-black text-[9px] uppercase tracking-wider transition-all active:scale-95 flex items-center justify-center gap-2">
                    <i class="fa-solid fa-trash-can text-sm"></i> Confirm & Cancel
                </button>
                <button type="button" onclick="closeCancelAppModal()" class="w-full py-2.5 rounded-lg bg-white dark:bg-slate-950 border border-slate-200 dark:border-slate-800 text-slate-500 dark:text-slate-450 font-black text-[9px] uppercase tracking-wider hover:bg-slate-50 dark:hover:bg-slate-900 transition-all">
                    Keep Appointment
                </button>
            </form>
        </div>
    </div>
</div>

<!-- DELETE FEEDBACK MODAL -->
<div id="deleteFeedbackModal" class="hidden fixed inset-0 z-[300] flex items-center justify-center p-4">
    <div class="absolute inset-0 bg-slate-950/60 backdrop-blur-sm opacity-0 transition-opacity duration-300" id="deleteFeedbackBackdrop" onclick="closeDeleteFeedbackModal()"></div>
    <div class="relative bg-white dark:bg-slate-900 rounded-2xl shadow-2xl max-w-xs w-full border border-slate-100 dark:border-slate-800 overflow-y-auto max-h-[calc(100vh-2rem)] sm:max-h-[90vh] custom-scrollbar transform scale-95 opacity-0 transition-all duration-300" id="deleteFeedbackPanel">
        <div class="p-6 text-center">
            <div class="w-14 h-14 rounded-xl bg-rose-50 dark:bg-rose-950/30 flex items-center justify-center mx-auto mb-4 text-rose-500 shadow-inner border border-rose-100 dark:border-rose-900/30">
                <i class="fa-solid fa-trash-can text-xl"></i>
            </div>
            <h3 class="text-base font-black text-slate-900 dark:text-white uppercase tracking-wider">Delete Review?</h3>
            <p class="text-xs font-medium text-slate-500 dark:text-slate-400 mt-2 leading-relaxed">
                Are you sure you want to permanently delete this review? This action cannot be undone.
            </p>
            
            <form action="DeleteFeedbackServlet" method="POST" class="flex flex-col gap-2 mt-6">
                <input type="hidden" name="feedbackId" id="deleteFeedbackModalInput">
                <button type="submit" class="w-full py-2.5 rounded-lg bg-rose-600 hover:bg-rose-700 text-white font-black text-[9px] uppercase tracking-wider transition-all active:scale-95 flex items-center justify-center gap-2">
                    Confirm & Delete
                </button>
                <button type="button" onclick="closeDeleteFeedbackModal()" class="w-full py-2.5 rounded-lg bg-white dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 text-slate-400 dark:text-slate-700 font-black text-[10px] uppercase tracking-[0.2em] hover:bg-slate-50 dark:hover:bg-slate-800 transition-all">
                    Cancel
                </button>
            </form>
        </div>
    </div>
</div>
<%@ include file="toast.jsp" %>
<script>
document.addEventListener("DOMContentLoaded",()=>{
    <% if ("true".equals(request.getParameter("feedbackSuccess"))) { %>showToast("Thank you! Your feedback has been posted.","success");<% } %>
    <% if ("true".equals(request.getParameter("feedbackUpdated"))) { %>showToast("Review updated and pending re-approval.","success");<% } %>
    <% if ("deleted".equals(request.getParameter("success"))) { %>showToast("Your review has been deleted.","success");<% } %>
    <% if ("true".equals(request.getParameter("rescheduleSuccess"))) { %>showToast("Appointment successfully rescheduled.","success");<% } %>
    <% if ("true".equals(request.getParameter("cancelSuccess"))) { %>showToast("Appointment successfully cancelled.","success");<% } %>
    <% if ("cancelFailed".equals(request.getParameter("error"))) { %>showToast("Failed to cancel appointment.","error");<% } %>
    <% if ("rescheduleFailed".equals(request.getParameter("error"))) { %>showToast("Failed to reschedule.","error");<% } %>
    <% if ("invalidData".equals(request.getParameter("error"))) { %>showToast("Invalid appointment data.","error");<% } %>
    <% if ("invalidId".equals(request.getParameter("error"))) { %>showToast("Invalid appointment ID.","error");<% } %>
    <% if ("true".equals(request.getParameter("mileageUpdated"))) { %>showToast("Vehicle mileage updated!","success");<% } %>
    <% if ("true".equals(request.getParameter("vehicleDeleted"))) { %>showToast("Vehicle removed from your account.","success");<% } %>
    <% if ("unauthorized".equals(request.getParameter("error"))) { %>showToast("Unauthorized action.","error");<% } %>
});
</script>
<%@ include file="logout_script.jsp" %>
</body>
</html>
