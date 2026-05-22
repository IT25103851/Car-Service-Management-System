<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.InventoryManager, model.InventoryItem, model.ServiceTypeManager, model.ServiceType, java.util.List" %>
<%
    InventoryManager modalIm = new InventoryManager();
    List<InventoryItem> modalParts = modalIm.getAllItems();

    ServiceTypeManager modalStm = new ServiceTypeManager();
    List<ServiceType> modalServices = modalStm.getAllServices();
%>
<!-- DYNAMIC DEFAULT LABOR PRICE DICTIONARY -->
<script>
    const serviceDefaultLabor = {
        <% 
        for (int i = 0; i < modalServices.size(); i++) {
            ServiceType st = modalServices.get(i);
        %>
            "<%= st.getServiceName().replace("\"", "\\\"") %>": <%= st.getDefaultBasePrice() %><%= i < modalServices.size() - 1 ? "," : "" %>
        <% } %>
    };
</script>

<!-- FINISH SERVICE MODAL OVERLAY -->
<div id="finishServiceModal" class="hidden fixed inset-0 z-[200] flex items-center justify-center p-4 sm:p-6">
    <!-- BACKDROP -->
    <div class="modal-backdrop absolute inset-0 bg-slate-950/80 backdrop-blur-xl opacity-0 transition-opacity duration-300" id="finishServiceBackdrop" onclick="closeFinishServiceModal()"></div>
    
    <!-- PANEL -->
    <div class="modal-panel relative bg-white dark:bg-slate-900 rounded-[2rem] sm:rounded-[3rem] shadow-2xl max-w-2xl w-full border border-slate-100 dark:border-slate-800/80 overflow-hidden transition-all duration-300 transform scale-90 translate-y-10 opacity-0 max-h-[calc(100vh-2rem)] sm:max-h-[90vh] flex flex-col" id="finishServicePanel">
        
        <!-- HEADER -->
        <div class="bg-slate-100 dark:bg-slate-950 px-6 sm:px-8 py-4 sm:py-6 flex flex-col sm:flex-row justify-between items-start sm:items-center border-b border-slate-200/60 dark:border-slate-800 gap-3 sm:gap-4 flex-shrink-0">
            <div>
                <span class="text-[9px] font-black text-slate-400 dark:text-slate-500 uppercase tracking-widest block mb-0.5">Vehicle</span>
                <h3 class="text-xl font-black text-slate-900 dark:text-white flex items-center gap-2">
                    <i class="fa-solid fa-car text-indigo-500"></i>
                    <span id="fsLicensePlate" class="mono text-[17px] tracking-wide"></span>
                </h3>
            </div>
            <div class="text-left sm:text-right">
                <span class="text-[9px] font-black text-slate-400 dark:text-slate-500 uppercase tracking-widest block mb-0.5">Service Provided</span>
                <h3 class="text-[17px] font-black text-indigo-600 dark:text-indigo-400" id="fsServiceName"></h3>
            </div>
        </div>

        <!-- FORM CONTAINER -->
        <div class="p-6 sm:p-8 md:p-10 flex-1 overflow-y-auto min-h-0 custom-scrollbar">
            <form action="FinishServiceServlet" method="POST">
                <!-- HIDDEN BINDINGS -->
                <input type="hidden" name="appId" id="fsAppIdInput">
                <input type="hidden" name="licensePlate" id="fsLicensePlateInput">
                <input type="hidden" name="customerUsername" id="fsCustomerUsernameInput">
                <input type="hidden" name="serviceName" id="fsServiceNameInput">

                <!-- PARTS SECTION -->
                <h4 class="text-[9px] font-black text-slate-400 dark:text-slate-500 uppercase tracking-[0.3em] mb-4 flex items-center gap-3">
                    <i class="fa-solid fa-boxes-stacked text-indigo-500"></i> Parts Used
                </h4>
                
                <!-- SCROLLABLE PARTS -->
                <div class="space-y-3 mb-6 max-h-60 overflow-y-auto pr-2 custom-scrollbar" id="fsPartsContainer">
                    <% if (modalParts.isEmpty()) { %>
                         <div class="p-6 text-center bg-slate-50 dark:bg-slate-950/40 rounded-2xl border-2 border-dashed border-slate-200 dark:border-slate-800">
                             <p class="text-xs font-semibold text-slate-400 dark:text-slate-500">No inventory parts available.</p>
                         </div>
                    <% } else { %>
                        <% for (InventoryItem part : modalParts) { 
                            if (part.getQuantity() > 0) {
                        %>
                            <div class="part-row flex items-center justify-between p-3.5 bg-slate-50 dark:bg-slate-955 border border-slate-100 dark:border-slate-800/60 rounded-2xl shadow-inner transition-colors duration-300" 
                                 data-applicable-service="<%= part.getApplicableService() %>">
                                <div class="flex items-center gap-3 min-w-0">
                                    <div class="bg-white dark:bg-slate-900 h-9 w-9 flex items-center justify-center rounded-xl shadow-sm text-indigo-500 dark:text-indigo-400 border border-indigo-50 dark:border-indigo-900/30 flex-shrink-0">
                                        <i class="fa-solid <%= part.getIconName() %> text-sm"></i>
                                    </div>
                                    <div class="min-w-0">
                                        <p class="font-black text-slate-800 dark:text-white text-xs truncate" title="<%= part.getItemName() %>"><%= part.getItemName() %></p>
                                        <p class="text-[9px] font-black text-slate-400 dark:text-slate-500 uppercase tracking-widest mt-0.5">LKR <%= String.format("%,.0f", part.getPrice()) %></p>
                                    </div>
                                </div>
                                <div class="w-16 flex-shrink-0">
                                    <input type="number" name="qty_<%= part.getItemId() %>" min="0" max="<%= part.getQuantity() %>" value="0"
                                           class="w-full px-2 py-1.5 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-lg focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all font-black text-slate-900 dark:text-white text-center shadow-sm text-xs">
                                </div>
                            </div>
                        <% } 
                           } %>
                         <div id="fsNoPartsMsg" class="hidden p-6 text-center bg-slate-50 dark:bg-slate-950/40 rounded-2xl border-2 border-dashed border-slate-200 dark:border-slate-800">
                             <p class="text-xs font-semibold text-slate-400 dark:text-slate-500">No inventory parts available or applicable for this service.</p>
                         </div>
                    <% } %>
                </div>

                <!-- LABOR FEE SECTION -->
                <div class="border-t border-slate-100 dark:border-slate-800 pt-5 mb-6">
                    <label class="block text-[9px] font-black text-slate-400 dark:text-slate-500 uppercase tracking-[0.3em] mb-2.5">
                        <i class="fa-solid fa-user-gear text-indigo-500 mr-2"></i> Labor Fee (LKR)
                    </label>
                    <input type="number" step="0.01" name="laborCost" id="fsLaborCostInput" required min="0"
                           class="w-full px-4 py-3 bg-slate-50 dark:bg-slate-950 border border-slate-200 dark:border-slate-800 rounded-xl text-sm font-black focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none transition-all text-slate-900 dark:text-white shadow-inner">
                    <p class="text-[9px] text-slate-400 dark:text-slate-500 mt-2 font-medium italic" id="fsLaborHelperText"></p>
                </div>

                <!-- ACTIONS -->
                <div class="flex flex-col sm:flex-row gap-3 pt-2">
                    <button type="submit" class="flex-[2] py-3.5 rounded-xl bg-slate-900 dark:bg-white text-white dark:text-slate-950 font-black text-[10px] uppercase tracking-[0.2em] shadow-2xl transition-all hover:-translate-y-0.5 active:scale-95 flex items-center justify-center gap-3">
                        <i class="fa-solid fa-file-invoice-dollar text-base"></i> Finish & Bill
                    </button>
                    <button type="button" onclick="closeFinishServiceModal()" class="flex-1 py-3.5 rounded-xl border border-slate-200 dark:border-slate-800 text-slate-450 dark:text-slate-500 font-black text-[10px] uppercase tracking-[0.2em] hover:bg-slate-50 dark:hover:bg-slate-900/50 transition-all flex items-center justify-center">
                        Cancel
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- MODAL CONTROLLER SCRIPT -->
<script>
function openFinishServiceModal(appId, licensePlate, customerUsername, serviceName) {
    // 1. Populate form inputs
    document.getElementById('fsAppIdInput').value = appId;
    document.getElementById('fsLicensePlateInput').value = licensePlate;
    document.getElementById('fsCustomerUsernameInput').value = customerUsername;
    document.getElementById('fsServiceNameInput').value = serviceName;

    // 2. Set dynamic header texts
    document.getElementById('fsLicensePlate').textContent = licensePlate;
    document.getElementById('fsServiceName').textContent = serviceName;

    // 3. Pre-fill default labor cost
    const defaultPrice = serviceDefaultLabor[serviceName] || 0.0;
    document.getElementById('fsLaborCostInput').value = defaultPrice;
    document.getElementById('fsLaborHelperText').textContent = "Pre-filled with the default base price for " + serviceName + ".";

    // 4. Dynamically filter and show parts
    let visiblePartsCount = 0;
    const parts = document.querySelectorAll('#fsPartsContainer .part-row');
    parts.forEach(row => {
        const appSvc = row.dataset.applicableService;
        const qtyInput = row.querySelector('input[type="number"]');
        if (qtyInput) qtyInput.value = 0; // reset quantity input on open

        if (appSvc === 'none' || appSvc === serviceName) {
            row.classList.remove('hidden');
            visiblePartsCount++;
        } else {
            row.classList.add('hidden');
        }
    });

    const noPartsMsg = document.getElementById('fsNoPartsMsg');
    if (noPartsMsg) {
        if (visiblePartsCount === 0) {
            noPartsMsg.classList.remove('hidden');
        } else {
            noPartsMsg.classList.add('hidden');
        }
    }

    // 5. Open animation
    const modal = document.getElementById('finishServiceModal');
    const backdrop = document.getElementById('finishServiceBackdrop');
    const panel = document.getElementById('finishServicePanel');

    modal.classList.remove('hidden');
    document.body.classList.add('modal-open');
    setTimeout(() => {
        backdrop.style.opacity = '1';
        panel.classList.remove('scale-90', 'translate-y-10', 'opacity-0');
        panel.classList.add('scale-100', 'translate-y-0', 'opacity-100');
    }, 20);
}

function closeFinishServiceModal() {
    const backdrop = document.getElementById('finishServiceBackdrop');
    const panel = document.getElementById('finishServicePanel');

    backdrop.style.opacity = '0';
    panel.classList.remove('scale-100', 'translate-y-0', 'opacity-100');
    panel.classList.add('scale-90', 'translate-y-10', 'opacity-0');
    document.body.classList.remove('modal-open');

    setTimeout(() => {
        document.getElementById('finishServiceModal').classList.add('hidden');
    }, 300);
}
</script>
