<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.BillingManager, model.Invoice" %>
<%
    String role = (String) session.getAttribute("userRole");
    if (!"admin".equals(role)) { response.sendRedirect("login.jsp"); return; }

    String invoiceId = request.getParameter("id");
    BillingManager bm = new BillingManager();
    Invoice inv = bm.getInvoiceById(invoiceId);

    if (inv == null) {
        response.sendRedirect("billing_dashboard.jsp?error=notfound");
        return;
    }
    
    if ("PAID".equals(inv.getStatus())) {
        response.sendRedirect("billing_dashboard.jsp?error=locked");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Invoice #<%= inv.getInvoiceId() %> - SwiftDrive</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;700&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Plus Jakarta Sans', sans-serif; }
        .mono { font-family: 'JetBrains Mono', monospace; }
        @keyframes slideUp { from{opacity:0;transform:translateY(20px)} to{opacity:1;transform:translateY(0)} }
        .animate-slide-up { animation: slideUp 0.6s cubic-bezier(0.4, 0, 0.2, 1) forwards; }
    </style>
</head>
<body class="antialiased text-slate-900 dark:text-slate-100 bg-slate-50 dark:bg-slate-950 transition-colors duration-300 min-h-screen pt-28 pb-20">
<%@ include file="navbar.jsp" %>

<div class="max-w-3xl mx-auto px-4">
    <div class="mb-12 animate-slide-up">
        <a href="billing_dashboard.jsp" class="inline-flex items-center gap-2 text-[10px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-[0.2em] hover:text-indigo-600 dark:hover:text-indigo-400 transition-colors mb-6">
            <i class="fa-solid fa-arrow-left"></i> Back to Dashboard
        </a>
        <h1 class="text-4xl font-black text-slate-900 dark:text-white tracking-tighter leading-none flex items-center gap-4">
            <i class="fa-solid fa-pen-to-square text-indigo-500"></i> Edit Invoice
        </h1>
        <p class="mt-4 text-base font-medium text-slate-500 dark:text-slate-400">Update line items for invoice <span class="mono text-indigo-600 dark:text-indigo-400">#<%= inv.getInvoiceId() %></span></p>
    </div>

    <div class="bg-white dark:bg-slate-900 rounded-[3rem] border border-slate-100 dark:border-slate-800 p-12 shadow-2xl shadow-slate-200/40 dark:shadow-none animate-slide-up">
        <form action="UpdateInvoiceServlet" method="POST" class="space-y-8">
            <input type="hidden" name="invoiceId" value="<%= inv.getInvoiceId() %>">
            
            <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                <div>
                    <label class="block text-[9px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-widest mb-3">Customer</label>
                    <div class="w-full px-6 py-4 bg-slate-50 dark:bg-slate-950/50 border-2 border-transparent dark:border-slate-800/50 rounded-2xl text-sm font-black text-slate-400 dark:text-slate-600 shadow-inner flex items-center gap-3">
                        <i class="fa-solid fa-user"></i> <%= inv.getCustomerUsername() %>
                    </div>
                </div>
                <div>
                    <label class="block text-[9px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-widest mb-3">Vehicle Plate</label>
                    <div class="w-full px-6 py-4 bg-slate-50 dark:bg-slate-950/50 border-2 border-transparent dark:border-slate-800/50 rounded-2xl text-sm font-black text-slate-400 dark:text-slate-600 shadow-inner flex items-center gap-3 mono">
                        <i class="fa-solid fa-car"></i> <%= inv.getLicensePlate() %>
                    </div>
                </div>
            </div>

            <div>
                <label class="block text-[9px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-widest mb-3">Service Description</label>
                <input type="text" name="serviceDescription" value="<%= inv.getServiceDescription() %>" required 
                       class="w-full px-6 py-4 bg-slate-50 dark:bg-slate-950 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-8 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white shadow-inner">
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                <div>
                    <label class="block text-[9px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-widest mb-3">Parts Cost (LKR)</label>
                    <input type="number" step="0.01" name="partsCost" id="partsCost" value="<%= inv.getPartsCost() %>" required oninput="calculateTotal()"
                           class="w-full px-6 py-4 bg-slate-50 dark:bg-slate-950 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-8 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white mono shadow-inner">
                </div>
                <div>
                    <label class="block text-[9px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-widest mb-3">Labor Cost (LKR)</label>
                    <input type="number" step="0.01" name="laborCost" id="laborCost" value="<%= inv.getLaborCost() %>" required oninput="calculateTotal()"
                           class="w-full px-6 py-4 bg-slate-50 dark:bg-slate-950 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black focus:ring-8 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all dark:text-white mono shadow-inner">
                </div>
            </div>

            <div class="p-8 bg-indigo-50 dark:bg-indigo-950/30 rounded-[2rem] border border-indigo-100 dark:border-indigo-900/50 flex justify-between items-center">
                <div>
                    <p class="text-[9px] font-black text-indigo-400 dark:text-indigo-600 uppercase tracking-[0.3em] mb-1">Estimated Total</p>
                    <p class="text-3xl font-black text-slate-900 dark:text-white tracking-tighter">LKR <span id="totalCost" class="mono"><%= String.format("%,.2f", inv.getTotalAmount()) %></span></p>
                </div>
                <div class="w-14 h-14 bg-white dark:bg-slate-900 rounded-2xl flex items-center justify-center text-indigo-500 shadow-xl shadow-indigo-100 dark:shadow-none">
                    <i class="fa-solid fa-calculator text-xl"></i>
                </div>
            </div>

            <button type="submit" class="w-full py-6 rounded-[2rem] bg-indigo-600 hover:bg-indigo-700 text-white font-black text-[11px] uppercase tracking-[0.2em] shadow-2xl shadow-indigo-200 dark:shadow-none transition-all active:scale-[0.98] flex items-center justify-center gap-4">
                <i class="fa-solid fa-cloud-arrow-up text-lg"></i> Save Invoice
            </button>
        </form>
    </div>
</div>

<script>
function calculateTotal() {
    const parts = parseFloat(document.getElementById('partsCost').value) || 0;
    const labor = parseFloat(document.getElementById('laborCost').value) || 0;
    const total = parts + labor;
    document.getElementById('totalCost').textContent = total.toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2});
}
</script>
</body>
</html>
