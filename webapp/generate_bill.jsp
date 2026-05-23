<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%-- Navbar moved --%>
<%
    String role = (String) session.getAttribute("userRole");
    if (!"admin".equals(role)) { response.sendRedirect("login.jsp"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Generate Invoice - SwiftDrive</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&family=DM+Mono:wght@400;500&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Inter', sans-serif; }
        .mono { font-family: 'DM Mono', 'Courier New', monospace; }
        .invoice-preview { position: relative; overflow: hidden; }
        .watermark { position: absolute; top: 50%; left: 50%; transform: translate(-50%,-50%) rotate(-35deg); font-size: 120px; font-weight: 900; opacity: 0.06; pointer-events: none; z-index: 0; letter-spacing: 0.1em; }
        @media print {
            body * { visibility: hidden; }
            .print-zone, .print-zone * { visibility: visible; }
            .print-zone { position: absolute; left: 0; top: 0; width: 100%; padding: 40px; }
            .no-print { display: none !important; }
        }
    </style>
</head>
<body class="antialiased text-slate-900 dark:text-slate-100 bg-slate-50 dark:bg-slate-950 transition-colors duration-300 min-h-screen">
<%@ include file="navbar.jsp" %>
<div class="pt-24">

<div class="max-w-4xl mx-auto py-8 px-4">
    <!-- HEADER -->
    <div class="flex items-center justify-between mb-8 no-print">
        <div>
            <h1 class="text-3xl font-black text-slate-900 dark:text-white tracking-tighter"><i class="fa-solid fa-file-invoice text-teal-600 mr-3"></i>Generate Invoice</h1>
            <p class="mt-2 text-base font-medium text-slate-500 dark:text-slate-400">Create a professional invoice for completed services.</p>
        </div>
        <a href="billing_dashboard.jsp" class="px-6 py-3 rounded-xl border border-slate-200 dark:border-slate-800 text-sm font-black text-slate-400 hover:text-teal-600 transition flex items-center gap-2">
            <i class="fa-solid fa-arrow-left"></i> Back to Invoices
        </a>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-5 gap-6">
        <!-- LEFT: FORM -->
        <div class="lg:col-span-2 no-print">
            <div class="bg-white dark:bg-slate-900 rounded-[2.5rem] border border-slate-200 dark:border-slate-800 p-8 sticky top-28 shadow-2xl shadow-slate-200/40 dark:shadow-none">
                <h3 class="text-[10px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mb-8 flex items-center gap-3"><i class="fa-solid fa-pen text-teal-500"></i> Invoice Details</h3>
                <form action="GenerateBillServlet" method="POST" id="billForm" class="space-y-3">
                    <div>
                        <label class="block text-[9px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mb-3">Customer Name</label>
                        <input type="text" name="customerUsername" id="fCustomer" placeholder="e.g., saman" required
                               class="w-full px-6 py-4 bg-slate-50 dark:bg-slate-950 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black text-slate-900 dark:text-white focus:ring-8 focus:ring-teal-500/10 focus:border-teal-500 outline-none transition-all shadow-inner"
                               oninput="updatePreview()">
                    </div>
                    <div>
                        <label class="block text-[9px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mb-3">Vehicle Plate</label>
                        <input type="text" name="licensePlate" id="fPlate" placeholder="e.g., CAB-1234" required
                               class="w-full px-6 py-4 bg-slate-50 dark:bg-slate-950 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black mono uppercase text-slate-900 dark:text-white focus:ring-8 focus:ring-teal-500/10 focus:border-teal-500 outline-none transition-all shadow-inner"
                               oninput="updatePreview()">
                    </div>
                    <div>
                        <label class="block text-[9px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mb-3">Service Type</label>
                        <input type="text" name="serviceDescription" id="fService" placeholder="e.g., Full Engine Tuning" required
                               class="w-full px-6 py-4 bg-slate-50 dark:bg-slate-950 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black text-slate-900 dark:text-white focus:ring-8 focus:ring-teal-500/10 focus:border-teal-500 outline-none transition-all shadow-inner"
                               oninput="updatePreview()">
                    </div>
                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="block text-[9px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mb-3">Parts Cost (LKR)</label>
                            <input type="number" name="partsCost" id="fParts" placeholder="0.00" required step="0.01" min="0"
                                   class="w-full px-6 py-4 bg-slate-50 dark:bg-slate-950 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black mono text-slate-900 dark:text-white focus:ring-8 focus:ring-teal-500/10 focus:border-teal-500 outline-none transition-all shadow-inner"
                                   oninput="updatePreview()">
                        </div>
                        <div>
                            <label class="block text-[9px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mb-3">Labor Cost (LKR)</label>
                            <input type="number" name="laborCost" id="fLabor" placeholder="0.00" required step="0.01" min="0"
                                   class="w-full px-6 py-4 bg-slate-50 dark:bg-slate-950 border-2 border-transparent dark:border-slate-800 rounded-2xl text-sm font-black mono text-slate-900 dark:text-white focus:ring-8 focus:ring-teal-500/10 focus:border-teal-500 outline-none transition-all shadow-inner"
                                   oninput="updatePreview()">
                        </div>
                    </div>
                    <div class="flex flex-col gap-4 pt-6">
                        <button type="submit" class="w-full py-5 rounded-2xl bg-teal-600 hover:bg-teal-700 text-white font-black text-[10px] uppercase tracking-[0.2em] shadow-xl shadow-teal-100 dark:shadow-none transition-all active:scale-95 flex items-center justify-center gap-4">
                            <i class="fa-solid fa-file-invoice text-lg"></i> Generate & Save
                        </button>
                        <button type="button" onclick="window.print()" class="w-full py-5 rounded-2xl border-2 border-slate-100 dark:border-slate-800 text-slate-400 dark:text-slate-600 font-black text-[10px] uppercase tracking-[0.2em] hover:bg-slate-50 dark:hover:bg-slate-800 transition-all flex items-center justify-center gap-4">
                            <i class="fa-solid fa-print text-lg"></i> Print Invoice
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- RIGHT: INVOICE PREVIEW -->
        <div class="lg:col-span-3 print-zone">
            <div class="invoice-preview bg-white dark:bg-slate-900 rounded-[2.5rem] border border-slate-200 dark:border-slate-800 p-12 relative shadow-2xl shadow-slate-200/40 dark:shadow-none">
                <div class="watermark text-rose-500 dark:text-rose-900" id="watermark">UNPAID</div>

                <!-- Invoice Header -->
                <div class="flex justify-between items-start mb-12 relative z-10">
                    <div>
                        <h2 class="text-2xl font-black text-slate-900 dark:text-white tracking-tighter flex items-center gap-3">
                            <i class="fa-solid fa-car-side text-teal-600"></i> SwiftDrive
                        </h2>
                        <p class="text-[9px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mt-2">Automotive Service Center</p>
                        <p class="text-[9px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest">No. 42, Galle Road, Colombo 03</p>
                        <p class="text-[9px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest">Sri Lanka</p>
                    </div>
                    <div class="text-right">
                        <p class="mono text-xl font-black text-teal-700 dark:text-teal-400" id="pvInvId">INVOICE</p>
                        <p class="text-[9px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest mt-2">Date: <span class="text-slate-900 dark:text-white" id="pvDate"><%= java.time.LocalDate.now() %></span></p>
                        <span class="text-[8px] font-black text-rose-600 bg-rose-50 dark:bg-rose-950/40 border border-rose-100 dark:border-rose-900/50 px-3 py-1 rounded-full mt-3 inline-block uppercase tracking-widest" id="pvStatusBadge">⏳ UNPAID</span>
                    </div>
                </div>

                <!-- Bill To -->
                <div class="grid grid-cols-2 gap-8 mb-12 relative z-10">
                    <div class="bg-slate-50 dark:bg-slate-950/60 rounded-2xl p-6 border border-slate-100 dark:border-slate-800 shadow-inner">
                        <p class="text-[9px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-widest mb-2">Customer</p>
                        <p class="text-sm font-black text-slate-900 dark:text-white" id="pvCustomer">—</p>
                    </div>
                    <div class="bg-slate-50 dark:bg-slate-950/60 rounded-2xl p-6 border border-slate-100 dark:border-slate-800 shadow-inner">
                        <p class="text-[9px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-widest mb-2">Vehicle</p>
                        <p class="mono text-sm font-black text-slate-900 dark:text-white uppercase" id="pvPlate">—</p>
                    </div>
                </div>

                <!-- Line Items -->
                <div class="relative z-10 mb-6">
                    <table class="w-full">
                        <thead>
                            <tr class="border-b-2 border-slate-100 dark:border-slate-800">
                                <th class="text-left text-[9px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest pb-4">Service</th>
                                <th class="text-center text-[9px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest pb-4">Unit</th>
                                <th class="text-right text-[9px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest pb-4">Rate</th>
                                <th class="text-right text-[9px] font-black text-slate-500 dark:text-slate-400 uppercase tracking-widest pb-4">Subtotal</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                            <tr>
                                <td class="py-5 text-sm font-black text-slate-800 dark:text-slate-200" id="pvServiceName">Service work</td>
                                <td class="py-5 text-center text-sm font-black text-slate-400 dark:text-slate-700">1</td>
                                <td class="py-5 text-right mono text-sm text-slate-600 dark:text-slate-400" id="pvLaborUnit">0.00</td>
                                <td class="py-5 text-right mono text-sm font-black text-slate-900 dark:text-white" id="pvLaborTotal">0.00</td>
                            </tr>
                            <tr>
                                <td class="py-5 text-sm font-black text-slate-800 dark:text-slate-200">Replacement Parts</td>
                                <td class="py-5 text-center text-sm font-black text-slate-400 dark:text-slate-700">1</td>
                                <td class="py-5 text-right mono text-sm text-slate-600 dark:text-slate-400" id="pvPartsUnit">0.00</td>
                                <td class="py-5 text-right mono text-sm font-black text-slate-900 dark:text-white" id="pvPartsTotal">0.00</td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <!-- Totals -->
                <div class="relative z-10 flex justify-end">
                    <div class="w-64">
                        <div class="flex justify-between text-sm py-2">
                            <span class="text-[9px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-widest">Subtotal</span>
                            <span class="mono font-black text-slate-700 dark:text-slate-300" id="pvSubtotal">LKR 0.00</span>
                        </div>
                        <div class="flex justify-between text-sm py-2">
                            <span class="text-[9px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-widest">Tax (0%)</span>
                            <span class="mono text-slate-400 dark:text-slate-800 font-black">LKR 0.00</span>
                        </div>
                        <div class="flex justify-between text-sm py-4 border-t-4 border-slate-900 dark:border-white mt-4">
                            <span class="text-[10px] font-black text-slate-900 dark:text-white uppercase tracking-[0.2em]">Total</span>
                            <span class="mono text-2xl font-black text-teal-700 dark:text-teal-400 tracking-tighter" id="pvTotal">LKR 0.00</span>
                        </div>
                    </div>
                </div>

                <!-- Footer -->
                <div class="relative z-10 mt-12 pt-8 border-t border-slate-100 dark:border-slate-800 text-center">
                    <p class="text-[9px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-[0.2em]">Certified Digital Document · SwiftDrive Automotive Services</p>
                    <p class="text-[9px] font-black text-slate-400 dark:text-slate-700 uppercase tracking-[0.2em] mt-2">Remittance due within 30 days</p>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
function fmt(n) { return n.toLocaleString('en-US', {minimumFractionDigits:2, maximumFractionDigits:2}); }

function updatePreview() {
    const customer = document.getElementById('fCustomer').value || '—';
    const plate = document.getElementById('fPlate').value || '—';
    const service = document.getElementById('fService').value || 'Service work';
    const parts = parseFloat(document.getElementById('fParts').value) || 0;
    const labor = parseFloat(document.getElementById('fLabor').value) || 0;
    const total = parts + labor;

    document.getElementById('pvCustomer').textContent = customer;
    document.getElementById('pvPlate').textContent = plate.toUpperCase();
    document.getElementById('pvServiceName').textContent = service;
    document.getElementById('pvLaborUnit').textContent = fmt(labor);
    document.getElementById('pvLaborTotal').textContent = fmt(labor);
    document.getElementById('pvPartsUnit').textContent = fmt(parts);
    document.getElementById('pvPartsTotal').textContent = fmt(parts);
    document.getElementById('pvSubtotal').textContent = 'LKR ' + fmt(total);
    document.getElementById('pvTotal').textContent = 'LKR ' + fmt(total);
}
</script>
</body>
</html>