<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.BillingManager, model.Invoice, model.PaymentManager, model.Payment, java.util.Stack, java.util.List, java.time.LocalDate, java.time.temporal.ChronoUnit" %>
<%
    String role = (String) session.getAttribute("userRole");
    if (!"admin".equals(role)) { response.sendRedirect("login.jsp"); return; }

    BillingManager bm = new BillingManager();
    Stack<Invoice> invoiceStack = bm.getAllInvoices();
    
    PaymentManager pm = new PaymentManager();
    List<Payment> allPayments = pm.getAllPayments();

    double totalRevenue = 0, outstandingBalance = 0;
    int unpaidCount = 0, voidCount = 0, recoverableCount = 0;
    LocalDate now = LocalDate.now();

    for (Invoice inv : invoiceStack) {
        if ("PAID".equals(inv.getStatus())) { 
            totalRevenue += inv.getTotalAmount(); 
        } else if ("VOID".equals(inv.getStatus())) { 
            voidCount++; 
            LocalDate issued = LocalDate.parse(inv.getDateIssued());
            if (now.isBefore(issued.plusMonths(6)) || now.isEqual(issued.plusMonths(6))) {
                recoverableCount++;
            }
        } else { 
            outstandingBalance += inv.getTotalAmount(); 
            unpaidCount++; 
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Billing Dashboard - SwiftDrive</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;700&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Plus Jakarta Sans', sans-serif; }
        .mono { font-family: 'JetBrains Mono', monospace; }
        .stat-card { transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1); }
        .stat-card:hover { transform: translateY(-4px); }
        .inv-row { transition: all 0.3s ease; }
        .inv-row:hover { background: rgba(99, 102, 241, 0.03) !important; }
        .modal-backdrop { transition: opacity 0.3s; -webkit-backdrop-filter: blur(8px); backdrop-filter: blur(8px); }
        .modal-panel { transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1), opacity 0.3s; transform: scale(0.9) translateY(20px); opacity: 0; }
        .modal-panel.open { transform: scale(1) translateY(0); opacity: 1; }
        .modal-open { overflow: hidden !important; height: 100vh !important; }
        
        /* Tabs */
        .tab-btn { transition: all 0.3s ease; }
        .tab-btn.active { background: #fff; color: #4f46e5; box-shadow: 0 10px 20px -5px rgba(99, 102, 241, 0.1); }
        .dark .tab-btn.active { background: #1e293b; color: #818cf8; }
        .tab-content { display: none; animation: fadeIn 0.4s ease forwards; }
        .tab-content.active { display: block; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
    </style>
</head>
<body class="antialiased text-slate-900 dark:text-slate-100 bg-slate-50 dark:bg-slate-950 transition-colors duration-300 min-h-screen pt-28 pb-20">
<%@ include file="navbar.jsp" %>

<div class="max-w-7xl mx-auto px-4">
    <!-- HEADER -->
    <div class="flex flex-col md:flex-row justify-between items-stretch md:items-start mb-8 sm:mb-12 gap-6 sm:gap-8">
        <div>
            <h1 class="text-3xl sm:text-4xl font-black text-slate-900 dark:text-white tracking-tighter leading-none flex items-center gap-3 sm:gap-4">
                <i class="fa-solid fa-file-invoice-dollar text-indigo-500"></i> Billing Operations
            </h1>
            <p class="mt-3 sm:mt-4 text-sm sm:text-base font-medium text-slate-500 dark:text-slate-400">Manage invoices, record payments, and handle void recovery.</p>
        </div>
        <a href="generate_bill.jsp" class="bg-indigo-600 hover:bg-indigo-700 text-white px-8 sm:px-10 py-4 sm:py-5 rounded-2xl sm:rounded-[2rem] shadow-xl shadow-indigo-200 dark:shadow-none font-black text-[10px] uppercase tracking-[0.2em] transition-all flex items-center justify-center gap-3 active:scale-95 w-full md:w-auto">
            <i class="fa-solid fa-plus text-base sm:text-lg"></i> New Invoice
        </a>
    </div>

    <!-- KEY STATISTICS -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 mb-8 sm:mb-12">
        <div class="stat-card bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] border border-slate-100 dark:border-slate-800 p-6 sm:p-8 relative overflow-hidden shadow-sm">
            <p class="text-[9px] font-black text-slate-400 uppercase tracking-[0.3em] mb-3 sm:mb-4">Total Revenue</p>
            <p class="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white mono">LKR <%= String.format("%,.0f", totalRevenue) %></p>
            <div class="mt-4 sm:mt-6 inline-flex text-[9px] font-black text-emerald-500 bg-emerald-50 dark:bg-emerald-900/20 px-4 py-1.5 rounded-xl uppercase tracking-widest"><i class="fa-solid fa-arrow-trend-up mr-2"></i> Collected</div>
        </div>
        <div class="stat-card bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] border border-slate-100 dark:border-slate-800 p-6 sm:p-8 relative overflow-hidden shadow-sm border-l-4 border-l-rose-500">
            <p class="text-[9px] font-black text-slate-400 uppercase tracking-[0.3em] mb-3 sm:mb-4">Outstanding</p>
            <p class="text-2xl sm:text-3xl font-black text-rose-600 mono">LKR <%= String.format("%,.0f", outstandingBalance) %></p>
            <div class="mt-4 sm:mt-6 inline-flex text-[9px] font-black text-rose-500 bg-rose-50 dark:bg-rose-900/20 px-4 py-1.5 rounded-xl uppercase tracking-widest"><i class="fa-solid fa-hourglass-half mr-2"></i> Pending (<%= unpaidCount %>)</div>
        </div>
        <div class="stat-card bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] border border-slate-100 dark:border-slate-800 p-6 sm:p-8 relative overflow-hidden shadow-sm border-l-4 border-l-amber-500">
            <p class="text-[9px] font-black text-slate-400 uppercase tracking-[0.3em] mb-3 sm:mb-4">Recoverable Voided</p>
            <p class="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white mono"><%= recoverableCount %></p>
            <div class="mt-4 sm:mt-6 inline-flex text-[9px] font-black text-amber-500 bg-amber-50 dark:bg-amber-900/20 px-4 py-1.5 rounded-xl uppercase tracking-widest"><i class="fa-solid fa-clock-rotate-left mr-2"></i> Grace Period</div>
        </div>
        <div class="stat-card bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] border border-slate-100 dark:border-slate-800 p-6 sm:p-8 relative overflow-hidden shadow-sm border-l-4 border-l-indigo-500">
            <p class="text-[9px] font-black text-slate-400 uppercase tracking-[0.3em] mb-3 sm:mb-4">Total Payments</p>
            <p class="text-2xl sm:text-3xl font-black text-slate-900 dark:text-white mono"><%= allPayments.size() %></p>
            <div class="mt-4 sm:mt-6 inline-flex text-[9px] font-black text-indigo-500 bg-indigo-50 dark:bg-indigo-900/20 px-4 py-1.5 rounded-xl uppercase tracking-widest"><i class="fa-solid fa-money-bill-wave mr-2"></i> Transactions</div>
        </div>
    </div>

    <!-- TABS -->
    <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-2 p-2 bg-slate-100 dark:bg-slate-900 rounded-[1.5rem] sm:rounded-[2rem] w-full sm:w-fit mb-8 border border-slate-200 dark:border-slate-800">
        <button onclick="switchTab('invoices')" id="tabBtn-invoices" class="tab-btn active px-4 sm:px-8 py-3.5 sm:py-4 rounded-xl sm:rounded-[1.5rem] text-[9px] sm:text-[10px] font-black uppercase tracking-widest text-slate-500 flex items-center justify-center gap-2">
            <i class="fa-solid fa-file-invoice"></i> Invoices
        </button>
        <button onclick="switchTab('payments')" id="tabBtn-payments" class="tab-btn px-4 sm:px-8 py-3.5 sm:py-4 rounded-xl sm:rounded-[1.5rem] text-[9px] sm:text-[10px] font-black uppercase tracking-widest text-slate-500 flex items-center justify-center gap-2">
            <i class="fa-solid fa-money-bill-transfer"></i> Payment Records
        </button>
    </div>

    <!-- INVOICES TAB -->
    <div id="tab-invoices" class="tab-content active">
        <div class="bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 rounded-2xl overflow-hidden shadow-sm">
            <div class="px-6 sm:px-10 py-4 sm:py-6 border-b border-slate-50 dark:border-slate-800 bg-slate-50/50 dark:bg-slate-950/50 flex flex-col sm:flex-row justify-between items-stretch sm:items-center gap-4">
                <h2 class="text-[9px] sm:text-[10px] font-black text-slate-500 uppercase tracking-[0.3em] flex items-center gap-3">
                    <i class="fa-solid fa-list-ul"></i> Invoice Directory
                </h2>
                <!-- Filter -->
                <select id="invoiceFilter" onchange="filterInvoices()" class="bg-white dark:bg-slate-900 border-2 border-slate-100 dark:border-slate-800 rounded-xl px-4 py-2.5 text-[9px] font-black uppercase tracking-widest outline-none text-slate-500 cursor-pointer">
                    <option value="all">All Invoices</option>
                    <option value="unpaid">Unpaid Only</option>
                    <option value="paid">Paid Only</option>
                    <option value="void">Archive (Voided)</option>
                </select>
            </div>
            
            <!-- DESKTOP TABLE VIEW -->
            <div class="hidden md:block overflow-x-auto">
                <table class="w-full border-collapse">
                    <thead>
                        <tr class="bg-slate-50/30 dark:bg-slate-950/30 border-b border-slate-100 dark:border-slate-800">
                            <th class="w-[20%] px-6 lg:px-8 py-5 text-left text-[9px] font-black text-slate-400 uppercase tracking-[0.2em]">Invoice ID</th>
                            <th class="w-[35%] px-6 lg:px-8 py-5 text-left text-[9px] font-black text-slate-400 uppercase tracking-[0.2em]">Customer / Vehicle</th>
                            <th class="w-[15%] px-6 lg:px-8 py-5 text-right text-[9px] font-black text-slate-400 uppercase tracking-[0.2em]">Amount</th>
                            <th class="w-[15%] px-6 lg:px-8 py-5 text-center text-[9px] font-black text-slate-400 uppercase tracking-[0.2em]">Status</th>
                            <th class="w-[15%] px-6 lg:px-8 py-5 text-center text-[9px] font-black text-slate-400 uppercase tracking-[0.2em]">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-50 dark:divide-slate-800/50">
                        <% for (int i = invoiceStack.size() - 1; i >= 0; i--) {
                            Invoice inv = invoiceStack.get(i);
                            boolean isVoid = "VOID".equals(inv.getStatus());
                            boolean isPaid = "PAID".equals(inv.getStatus());
                            boolean canReinstate = false;
                            if (isVoid) {
                                LocalDate issued = LocalDate.parse(inv.getDateIssued());
                                if (!now.isAfter(issued.plusMonths(6))) canReinstate = true;
                            }
                            double totalPaidForInv = 0;
                            for (Payment p : allPayments) {
                                if (p.getInvoiceId().equals(inv.getInvoiceId())) {
                                    totalPaidForInv += p.getAmount();
                                }
                            }
                            double balanceForInv = inv.getTotalAmount() - totalPaidForInv;
                            if (balanceForInv < 0) balanceForInv = 0;
                        %>
                        <tr class="inv-row hover:bg-slate-50/50 transition-colors" data-status="<%= inv.getStatus().toLowerCase() %>">
                            <td class="w-[20%] px-6 lg:px-8 py-6">
                                <a href="invoice_detail.jsp?id=<%= inv.getInvoiceId() %>" class="mono text-sm font-bold text-indigo-600 hover:underline"><%= inv.getInvoiceId() %></a>
                                <p class="text-[9px] font-black text-slate-400 uppercase tracking-widest mt-1"><%= inv.getDateIssued() %></p>
                            </td>
                            <td class="w-[35%] px-6 lg:px-8 py-6 break-words">
                                <p class="text-sm font-bold text-slate-800 dark:text-slate-200"><%= inv.getCustomerUsername() %></p>
                                <span class="inline-block mt-1 mono text-[9px] font-black text-slate-500 bg-slate-100 dark:bg-slate-800 px-2 py-0.5 rounded uppercase tracking-widest"><%= inv.getLicensePlate() %></span>
                            </td>
                            <td class="w-[15%] px-6 lg:px-8 py-6 text-right whitespace-nowrap">
                                <span class="mono font-black text-slate-800 dark:text-white">LKR <%= String.format("%,.0f", inv.getTotalAmount()) %></span>
                            </td>
                            <td class="w-[15%] px-6 lg:px-8 py-6 text-center">
                                <% if (isPaid) { %>
                                <span class="text-[9px] font-black text-emerald-600 bg-emerald-50 border border-emerald-100 px-3 py-1 rounded-full uppercase tracking-widest"><i class="fa-solid fa-check"></i> Paid</span>
                                <% } else if (isVoid) { %>
                                <span class="text-[9px] font-black text-rose-500 bg-rose-50 border border-rose-100 px-3 py-1 rounded-full uppercase tracking-widest"><i class="fa-solid fa-ban"></i> Voided</span>
                                <% } else { %>
                                <span class="text-[9px] font-black text-amber-600 bg-amber-50 border border-amber-100 px-3 py-1 rounded-full uppercase tracking-widest">Unpaid</span>
                                <% } %>
                            </td>
                            <td class="w-[15%] px-6 lg:px-8 py-6 text-center">
                                <div class="flex items-center justify-center gap-2">
                                    <a href="invoice_detail.jsp?id=<%= inv.getInvoiceId() %>" class="w-9 h-9 rounded-xl bg-slate-50 dark:bg-slate-950 text-slate-400 dark:text-slate-700 hover:text-indigo-600 flex items-center justify-center border border-slate-200 dark:border-slate-800 transition-colors active:scale-90 shadow-sm" title="View Details"><i class="fa-solid fa-eye text-xs"></i></a>
                                    
                                    <% if (!isVoid && !isPaid) { %>
                                    <button onclick="openPayModal('<%= inv.getInvoiceId() %>', <%= balanceForInv %>)" class="w-9 h-9 rounded-xl bg-emerald-50 dark:bg-emerald-950 text-emerald-600 hover:bg-emerald-600 hover:text-white flex items-center justify-center border border-emerald-100 dark:border-emerald-800 transition-colors active:scale-90 shadow-sm" title="Record Payment"><i class="fa-solid fa-hand-holding-dollar text-xs"></i></button>
                                    <button onclick="openVoidModal('<%= inv.getInvoiceId() %>')" class="w-9 h-9 rounded-xl bg-rose-50 dark:bg-rose-950 text-rose-500 hover:bg-rose-600 hover:text-white flex items-center justify-center border border-rose-100 dark:border-rose-800 transition-colors active:scale-90 shadow-sm" title="Void Invoice"><i class="fa-solid fa-ban text-xs"></i></button>
                                    <% } %>
                                    
                                    <% if (isVoid && canReinstate) { %>
                                    <button onclick="openReinstateModal('<%= inv.getInvoiceId() %>')" class="w-9 h-9 rounded-xl bg-amber-50 dark:bg-amber-950 text-amber-600 hover:bg-amber-500 hover:text-white flex items-center justify-center border border-amber-100 dark:border-amber-800 transition-colors active:scale-90 shadow-sm" title="Reinstate Invoice"><i class="fa-solid fa-clock-rotate-left text-xs"></i></button>
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
                <% for (int i = invoiceStack.size() - 1; i >= 0; i--) {
                    Invoice inv = invoiceStack.get(i);
                    boolean isVoid = "VOID".equals(inv.getStatus());
                    boolean isPaid = "PAID".equals(inv.getStatus());
                    boolean canReinstate = false;
                    if (isVoid) {
                        LocalDate issued = LocalDate.parse(inv.getDateIssued());
                        if (!now.isAfter(issued.plusMonths(6))) canReinstate = true;
                    }
                    double totalPaidForInv = 0;
                    for (Payment p : allPayments) {
                        if (p.getInvoiceId().equals(inv.getInvoiceId())) {
                            totalPaidForInv += p.getAmount();
                        }
                    }
                    double balanceForInv = inv.getTotalAmount() - totalPaidForInv;
                    if (balanceForInv < 0) balanceForInv = 0;
                %>
                <div class="inv-card p-5 bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-800 rounded-2xl space-y-4" data-status="<%= inv.getStatus().toLowerCase() %>">
                    <div class="flex justify-between items-center">
                        <a href="invoice_detail.jsp?id=<%= inv.getInvoiceId() %>" class="mono text-sm font-bold text-indigo-600 hover:underline"><%= inv.getInvoiceId() %></a>
                        <span class="text-xs font-bold text-slate-500 dark:text-slate-400 mono"><%= inv.getDateIssued() %></span>
                    </div>
                    
                    <div class="flex justify-between items-start gap-4">
                        <div>
                            <p class="text-[9px] font-black text-slate-500 dark:text-slate-600 uppercase tracking-[0.3em] mb-1">Customer / Vehicle</p>
                            <p class="text-sm font-bold text-slate-800 dark:text-slate-200"><%= inv.getCustomerUsername() %></p>
                            <span class="inline-block mt-1 mono text-[9px] font-black text-slate-500 bg-indigo-50 dark:bg-indigo-950 border border-indigo-100 dark:border-indigo-800 px-2 py-0.5 rounded uppercase tracking-widest shadow-inner"><%= inv.getLicensePlate() %></span>
                        </div>
                        <div class="text-right">
                            <p class="text-[9px] font-black text-slate-500 dark:text-slate-600 uppercase tracking-[0.3em] mb-1">Amount</p>
                            <span class="mono font-black text-slate-800 dark:text-white text-sm">LKR <%= String.format("%,.0f", inv.getTotalAmount()) %></span>
                        </div>
                    </div>
                    
                    <div class="flex justify-between items-center pt-2 border-t border-slate-100 dark:border-slate-800">
                        <div>
                            <% if (isPaid) { %>
                            <span class="text-[9px] font-black text-emerald-600 bg-emerald-50 border border-emerald-100 px-3 py-1 rounded-full uppercase tracking-widest"><i class="fa-solid fa-check"></i> Paid</span>
                            <% } else if (isVoid) { %>
                            <span class="text-[9px] font-black text-rose-500 bg-rose-50 border border-rose-100 px-3 py-1 rounded-full uppercase tracking-widest"><i class="fa-solid fa-ban"></i> Voided</span>
                            <% } else { %>
                            <span class="text-[9px] font-black text-amber-600 bg-amber-50 border border-amber-100 px-3 py-1 rounded-full uppercase tracking-widest">Unpaid</span>
                            <% } %>
                        </div>
                        
                        <div class="flex items-center gap-2">
                            <a href="invoice_detail.jsp?id=<%= inv.getInvoiceId() %>" class="w-9 h-9 rounded-xl bg-white dark:bg-slate-900 text-slate-400 dark:text-slate-700 hover:text-indigo-600 flex items-center justify-center border border-slate-200 dark:border-slate-800 transition-colors shadow-sm active:scale-95" title="View Details"><i class="fa-solid fa-eye text-xs"></i></a>
                            
                            <% if (!isVoid && !isPaid) { %>
                            <button onclick="openPayModal('<%= inv.getInvoiceId() %>', <%= balanceForInv %>)" class="w-9 h-9 rounded-xl bg-white dark:bg-slate-900 text-emerald-600 hover:bg-emerald-600 hover:text-white flex items-center justify-center border border-slate-200 dark:border-slate-800 transition-colors shadow-sm active:scale-95" title="Record Payment"><i class="fa-solid fa-hand-holding-dollar text-xs"></i></button>
                            <button onclick="openVoidModal('<%= inv.getInvoiceId() %>')" class="w-9 h-9 rounded-xl bg-white dark:bg-slate-900 text-rose-500 hover:bg-rose-600 hover:text-white flex items-center justify-center border border-slate-200 dark:border-slate-800 transition-colors shadow-sm active:scale-95" title="Void Invoice"><i class="fa-solid fa-ban text-xs"></i></button>
                            <% } %>
                            
                            <% if (isVoid && canReinstate) { %>
                            <button onclick="openReinstateModal('<%= inv.getInvoiceId() %>')" class="w-9 h-9 rounded-xl bg-white dark:bg-slate-900 text-amber-600 hover:bg-amber-500 hover:text-white flex items-center justify-center border border-slate-200 dark:border-slate-800 transition-colors shadow-sm active:scale-95" title="Reinstate Invoice"><i class="fa-solid fa-clock-rotate-left text-xs"></i></button>
                            <% } %>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
        </div>
    </div>

    <!-- PAYMENTS TAB -->
    <div id="tab-payments" class="tab-content">
        <div class="bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 rounded-2xl overflow-hidden shadow-sm">
            <div class="px-6 sm:px-10 py-4 sm:py-6 border-b border-slate-50 dark:border-slate-800 bg-slate-50/50 dark:bg-slate-950/50 flex justify-between items-center">
                <h2 class="text-[9px] sm:text-[10px] font-black text-slate-500 uppercase tracking-[0.3em] flex items-center gap-3">
                    <i class="fa-solid fa-money-check-dollar"></i> Transaction Log
                </h2>
            </div>
            
            <!-- DESKTOP PAYMENTS TABLE -->
            <div class="hidden md:block overflow-x-auto">
                <table class="w-full border-collapse">
                    <thead>
                        <tr class="bg-slate-50/30 dark:bg-slate-950/30 border-b border-slate-100 dark:border-slate-800">
                            <th class="w-[25%] px-6 lg:px-8 py-5 text-left text-[9px] font-black text-slate-400 uppercase tracking-[0.2em]">Txn ID</th>
                            <th class="w-[25%] px-6 lg:px-8 py-5 text-left text-[9px] font-black text-slate-400 uppercase tracking-[0.2em]">Linked Invoice</th>
                            <th class="w-[30%] px-6 lg:px-8 py-5 text-left text-[9px] font-black text-slate-400 uppercase tracking-[0.2em]">Date / Method</th>
                            <th class="w-[20%] px-6 lg:px-8 py-5 text-right text-[9px] font-black text-slate-400 uppercase tracking-[0.2em]">Amount</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-50 dark:divide-slate-800/50">
                        <% if (allPayments.isEmpty()) { %>
                        <tr><td colspan="4" class="text-center py-10 text-sm font-bold text-slate-400">No payment records found.</td></tr>
                        <% } else {
                           for (int i = allPayments.size() - 1; i >= 0; i--) {
                               Payment p = allPayments.get(i);
                        %>
                        <tr class="hover:bg-slate-50/50 transition-colors">
                            <td class="w-[25%] px-6 lg:px-8 py-5 mono text-xs font-bold text-slate-600"><%= p.getPaymentId() %></td>
                            <td class="w-[25%] px-6 lg:px-8 py-5"><a href="invoice_detail.jsp?id=<%= p.getInvoiceId() %>" class="mono text-xs font-bold text-indigo-600 hover:underline"><%= p.getInvoiceId() %></a></td>
                            <td class="w-[30%] px-6 lg:px-8 py-5">
                                <p class="text-xs font-bold text-slate-800"><%= p.getPaymentDate() %></p>
                                <span class="text-[9px] font-black uppercase tracking-widest text-slate-400"><%= p.getPaymentMethod() %></span>
                            </td>
                            <td class="w-[20%] px-6 lg:px-8 py-5 text-right mono font-bold text-emerald-600 whitespace-nowrap">LKR <%= String.format("%,.2f", p.getAmount()) %></td>
                        </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>

            <!-- MOBILE PAYMENTS CARDS -->
            <div class="block md:hidden p-4 space-y-4">
                <% if (allPayments.isEmpty()) { %>
                <div class="text-center py-10 text-sm font-bold text-slate-400">No payment records found.</div>
                <% } else {
                   for (int i = allPayments.size() - 1; i >= 0; i--) {
                       Payment p = allPayments.get(i);
                %>
                <div class="p-5 bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-800 rounded-2xl space-y-4">
                    <div class="flex justify-between items-center">
                        <span class="mono text-xs font-bold text-slate-600"><%= p.getPaymentId() %></span>
                        <span class="text-xs font-bold text-slate-500 dark:text-slate-400 mono"><%= p.getPaymentDate() %></span>
                    </div>
                    
                    <div class="flex justify-between items-end">
                        <div>
                            <p class="text-[9px] font-black text-slate-500 dark:text-slate-600 uppercase tracking-[0.3em] mb-1">Linked Invoice</p>
                            <a href="invoice_detail.jsp?id=<%= p.getInvoiceId() %>" class="mono text-xs font-bold text-indigo-600 hover:underline"><%= p.getInvoiceId() %></a>
                        </div>
                        <div class="text-right">
                            <p class="text-[9px] font-black text-slate-500 dark:text-slate-600 uppercase tracking-[0.3em] mb-1">Method</p>
                            <span class="text-[9px] font-black uppercase tracking-widest text-slate-400"><%= p.getPaymentMethod() %></span>
                        </div>
                    </div>
                    
                    <div class="pt-2 border-t border-slate-100 dark:border-slate-800 flex justify-between items-center">
                        <p class="text-[9px] font-black text-slate-500 dark:text-slate-600 uppercase tracking-[0.3em]">Amount Collected</p>
                        <span class="mono font-bold text-emerald-600 text-sm">LKR <%= String.format("%,.2f", p.getAmount()) %></span>
                    </div>
                </div>
                <% } } %>
            </div>
        </div>
    </div>
</div>

<!-- PAYMENT MODAL (Inline Record Payment) -->
<div id="payModal" class="hidden fixed inset-0 z-[200] flex items-center justify-center p-4">
    <div class="modal-backdrop absolute inset-0 bg-slate-950/60 opacity-0" id="payBackdrop" onclick="closePayModal()"></div>
    <div class="modal-panel relative bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] shadow-2xl max-w-md w-full border border-slate-100 dark:border-slate-800 overflow-y-auto max-h-[calc(100vh-2rem)] sm:max-h-[90vh] custom-scrollbar" id="payPanel">
        <form action="AddPaymentServlet" method="POST">
            <input type="hidden" name="invoiceId" id="payInvIdInput">
            <div class="p-6 sm:p-10 border-b border-slate-100 dark:border-slate-800 bg-slate-50/50 dark:bg-slate-955/50">
                <div class="w-12 h-12 sm:w-16 sm:h-16 rounded-[1rem] sm:rounded-[1.5rem] bg-emerald-50 dark:bg-emerald-950 flex items-center justify-center mb-4 sm:mb-6 text-emerald-500"><i class="fa-solid fa-hand-holding-dollar text-xl sm:text-2xl"></i></div>
                <h3 class="text-xl sm:text-2xl font-black text-slate-900 dark:text-white tracking-tighter">Record Payment</h3>
                <p class="text-xs font-bold text-slate-500 mt-1 sm:mt-2">Invoice <span id="payInvLabel" class="mono text-indigo-600"></span></p>
            </div>
            <div class="p-6 sm:p-10 space-y-4 sm:space-y-6">
                <div>
                    <label class="block text-[9px] font-black text-slate-400 uppercase tracking-widest mb-2">Amount (LKR)</label>
                    <input type="number" name="amount" id="payAmountInput" step="0.01" required class="w-full px-4 sm:px-5 py-3 sm:py-4 bg-slate-50 dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 rounded-2xl text-sm font-black mono outline-none focus:border-indigo-500 dark:text-white shadow-inner">
                </div>
                <div>
                    <label class="block text-[9px] font-black text-slate-400 uppercase tracking-widest mb-2">Payment Method</label>
                    <select name="paymentMethod" required class="w-full px-4 sm:px-5 py-3 sm:py-4 bg-slate-50 dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 rounded-2xl text-sm font-black outline-none focus:border-indigo-500 cursor-pointer dark:text-white shadow-inner">
                        <option value="Cash">Cash</option>
                        <option value="Card">Credit/Debit Card</option>
                        <option value="Bank Transfer">Bank Transfer</option>
                        <option value="Online">Online Gateway</option>
                    </select>
                </div>
                <div>
                    <label class="block text-[9px] font-black text-slate-400 uppercase tracking-widest mb-2">Reference Note (Optional)</label>
                    <input type="text" name="referenceNote" placeholder="Cheque No, Txn ID..." class="w-full px-4 sm:px-5 py-3 sm:py-4 bg-slate-50 dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 rounded-2xl text-sm font-black outline-none focus:border-indigo-500 dark:text-white shadow-inner">
                </div>
                <button type="submit" class="w-full py-4 sm:py-5 rounded-2xl bg-emerald-600 hover:bg-emerald-700 text-white font-black text-[10px] uppercase tracking-widest transition-all">Submit Payment</button>
            </div>
        </form>
    </div>
</div>

<!-- VOID MODAL -->
<div id="voidModal" class="hidden fixed inset-0 z-[200] flex items-center justify-center p-4">
    <div class="modal-backdrop absolute inset-0 bg-slate-950/60 opacity-0" id="voidBackdrop" onclick="closeVoidModal()"></div>
    <div class="modal-panel relative bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] shadow-2xl max-w-sm w-full border border-slate-100 dark:border-slate-800 overflow-y-auto max-h-[calc(100vh-2rem)] sm:max-h-[90vh] custom-scrollbar" id="voidPanel">
        <form action="VoidInvoiceServlet" method="POST">
            <input type="hidden" name="invoiceId" id="voidInvIdInput">
            <div class="p-6 sm:p-10 text-center">
                <div class="w-16 h-16 sm:w-20 sm:h-20 rounded-[1.25rem] sm:rounded-[1.5rem] bg-rose-50 dark:bg-rose-955 flex items-center justify-center mx-auto mb-4 sm:mb-6 text-rose-500 shadow-inner border border-rose-100 dark:border-rose-900/30"><i class="fa-solid fa-ban text-2xl sm:text-3xl"></i></div>
                <h3 class="text-xl sm:text-2xl font-black text-slate-900 dark:text-white tracking-tighter">Void Invoice</h3>
                <p class="text-xs font-bold text-slate-500 mt-1.5 mb-4 sm:mb-6">Invoice <span id="voidInvLabel" class="mono text-rose-600"></span></p>
                <div class="text-left mb-6 sm:mb-8">
                    <label class="block text-[9px] font-black text-slate-400 uppercase tracking-widest mb-2">Void Reason <span class="text-rose-500">*</span></label>
                    <input type="text" name="voidReason" required placeholder="e.g., Created by mistake" class="w-full px-4 sm:px-5 py-3 sm:py-4 bg-slate-50 dark:bg-slate-955 border-2 border-slate-105 dark:border-slate-800 rounded-2xl text-sm font-black outline-none focus:border-rose-500 dark:text-white shadow-inner">
                </div>
                <div class="flex flex-col gap-3">
                    <button type="submit" class="w-full py-3.5 rounded-xl bg-rose-600 text-white font-black text-[10px] uppercase tracking-widest hover:bg-rose-700 active:scale-95 transition-all">Confirm Void</button>
                    <button type="button" onclick="closeVoidModal()" class="w-full py-3.5 rounded-xl border-2 border-slate-100 dark:border-slate-800 text-slate-400 dark:text-slate-700 font-black text-[10px] uppercase tracking-widest hover:bg-slate-50 dark:hover:bg-slate-800 transition-all">Cancel</button>
                </div>
            </div>
        </form>
    </div>
</div>

<!-- REINSTATE MODAL -->
<div id="reinstateModal" class="hidden fixed inset-0 z-[200] flex items-center justify-center p-4">
    <div class="modal-backdrop absolute inset-0 bg-slate-950/60 opacity-0" id="reinstateBackdrop" onclick="closeReinstateModal()"></div>
    <div class="modal-panel relative bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] shadow-2xl max-w-sm w-full border border-slate-100 dark:border-slate-800 overflow-y-auto max-h-[calc(100vh-2rem)] sm:max-h-[90vh] custom-scrollbar" id="reinstatePanel">
        <form action="ReinstateInvoiceServlet" method="POST">
            <input type="hidden" name="invoiceId" id="reinstateInvIdInput">
            <div class="p-6 sm:p-10 text-center">
                <div class="w-16 h-16 sm:w-20 sm:h-20 rounded-[1.25rem] sm:rounded-[1.5rem] bg-emerald-50 dark:bg-emerald-950 flex items-center justify-center mx-auto mb-4 sm:mb-6 text-emerald-500 shadow-inner border border-emerald-100 dark:border-emerald-900/30"><i class="fa-solid fa-clock-rotate-left text-2xl sm:text-3xl"></i></div>
                <h3 class="text-xl sm:text-2xl font-black text-slate-900 dark:text-white tracking-tighter">Reinstate Invoice</h3>
                <p class="text-xs font-bold text-slate-500 mt-1.5 mb-2">Invoice <span id="reinstateInvLabel" class="mono text-emerald-600"></span></p>
                <p class="text-xs sm:text-sm font-medium text-slate-500 mb-6 sm:mb-8 leading-relaxed">Reinstate this invoice to PAID status? A payment record will be auto-generated.</p>
                <div class="flex flex-col gap-3">
                    <button type="submit" class="w-full py-3.5 rounded-xl bg-emerald-600 text-white font-black text-[10px] uppercase tracking-widest hover:bg-emerald-700 active:scale-95 transition-all">Confirm Reinstate</button>
                    <button type="button" onclick="closeReinstateModal()" class="w-full py-3.5 rounded-xl border-2 border-slate-100 dark:border-slate-800 text-slate-400 dark:text-slate-700 font-black text-[10px] uppercase tracking-widest hover:bg-slate-50 dark:hover:bg-slate-800 transition-all">Cancel</button>
                </div>
            </div>
        </form>
    </div>
</div>

<%@ include file="toast.jsp" %>
<script>
function switchTab(tabId) {
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
    document.getElementById('tabBtn-' + tabId).classList.add('active');
    document.getElementById('tab-' + tabId).classList.add('active');
}

function filterInvoices() {
    const filter = document.getElementById('invoiceFilter').value;
    
    // Filter desktop rows
    document.querySelectorAll('.inv-row').forEach(row => {
        const status = row.getAttribute('data-status');
        row.style.display = (filter === 'all' || status === filter) ? '' : 'none';
    });

    // Filter mobile cards
    document.querySelectorAll('.inv-card').forEach(card => {
        const status = card.getAttribute('data-status');
        card.style.display = (filter === 'all' || status === filter) ? '' : 'none';
    });
}

function openPayModal(id, amount) {
    document.getElementById('payInvIdInput').value = id;
    document.getElementById('payInvLabel').textContent = '#' + id;
    document.getElementById('payAmountInput').value = amount;
    const m = document.getElementById('payModal'); m.classList.remove('hidden');
    document.body.classList.add('modal-open');
    setTimeout(() => { document.getElementById('payBackdrop').style.opacity='1'; document.getElementById('payPanel').classList.add('open'); }, 20);
}
function closePayModal() {
    document.getElementById('payBackdrop').style.opacity='0'; document.getElementById('payPanel').classList.remove('open');
    document.body.classList.remove('modal-open');
    setTimeout(() => document.getElementById('payModal').classList.add('hidden'), 300);
}

function openVoidModal(id) {
    document.getElementById('voidInvIdInput').value = id;
    document.getElementById('voidInvLabel').textContent = '#' + id;
    const m = document.getElementById('voidModal'); m.classList.remove('hidden');
    document.body.classList.add('modal-open');
    setTimeout(() => { document.getElementById('voidBackdrop').style.opacity='1'; document.getElementById('voidPanel').classList.add('open'); }, 20);
}
function closeVoidModal() {
    document.getElementById('voidBackdrop').style.opacity='0'; document.getElementById('voidPanel').classList.remove('open');
    document.body.classList.remove('modal-open');
    setTimeout(() => document.getElementById('voidModal').classList.add('hidden'), 300);
}

function openReinstateModal(id) {
    document.getElementById('reinstateInvIdInput').value = id;
    document.getElementById('reinstateInvLabel').textContent = '#' + id;
    const m = document.getElementById('reinstateModal'); m.classList.remove('hidden');
    document.body.classList.add('modal-open');
    setTimeout(() => { document.getElementById('reinstateBackdrop').style.opacity='1'; document.getElementById('reinstatePanel').classList.add('open'); }, 20);
}
function closeReinstateModal() {
    document.getElementById('reinstateBackdrop').style.opacity='0'; document.getElementById('reinstatePanel').classList.remove('open');
    document.body.classList.remove('modal-open');
    setTimeout(() => document.getElementById('reinstateModal').classList.add('hidden'), 300);
}

document.addEventListener("DOMContentLoaded", () => {
    <% if (request.getParameter("success") != null) { %>
        let msg = "Operation completed.";
        if ('<%= request.getParameter("success") %>' === 'payment_added') msg = "Payment recorded successfully.";
        if ('<%= request.getParameter("success") %>' === 'reinstated') msg = "Invoice reinstated to PAID.";
        if ('<%= request.getParameter("success") %>' === 'voided') msg = "Invoice voided.";
        showToast(msg, "success");
    <% } %>
});
</script>
</body>
</html>