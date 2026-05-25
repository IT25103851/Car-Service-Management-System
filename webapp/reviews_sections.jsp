<%-- Customer Section: My Reviews --%>
<% if (isCustomer && !myFb.isEmpty()) { %>
<div class="mb-12 sm:mb-16">
    <div class="flex items-center gap-3 mb-6">
        <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-violet-500 to-purple-600 flex items-center justify-center text-white shadow-lg shadow-violet-200 dark:shadow-none">
            <i class="fa-solid fa-user-pen text-sm"></i>
        </div>
        <div>
            <h2 class="text-sm font-black text-slate-900 dark:text-white uppercase tracking-wider">My Reviews</h2>
            <p class="text-[9px] font-bold text-slate-400 uppercase tracking-widest mt-0.5"><%= myFb.size() %> review<%= myFb.size() != 1 ? "s" : "" %> submitted</p>
        </div>
    </div>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <% for (int i = myFb.size() - 1; i >= 0; i--) { Feedback fb = myFb.get(i); int rating = fb.getRating(); boolean hasReply = fb.getAdminReply() != null && !"none".equals(fb.getAdminReply()); %>
        <div class="fb-card bg-white dark:bg-slate-900 rounded-2xl border border-slate-100 dark:border-slate-800 p-5 sm:p-6 shadow-xl shadow-slate-200/20 dark:shadow-none relative overflow-hidden" id="mycard-<%= fb.getFeedbackId() %>">
            <!-- Gradient Top Border -->
            <div class="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-indigo-500 via-violet-500 to-purple-500"></div>

            <div id="myview-<%= fb.getFeedbackId() %>">
                <div class="flex items-center justify-between mb-4 sm:mb-5">
                    <div class="flex text-amber-500 text-xs gap-0.5 bg-amber-50 dark:bg-amber-950/30 px-3 py-1.5 rounded-xl border border-amber-100 dark:border-amber-900/20">
                        <% for(int s=1; s<=5; s++) { %><i class="<%= s <= rating ? "fa-solid" : "fa-regular" %> fa-star"></i><% } %>
                    </div>
                    <% if (fb.isApproved()) { %>
                    <span class="text-[8px] font-black text-emerald-500 bg-emerald-50 dark:bg-emerald-950/30 px-2.5 py-1.5 rounded-xl border border-emerald-100 dark:border-emerald-900/20 uppercase tracking-widest flex items-center gap-1">
                        <i class="fa-solid fa-circle-check"></i> Published
                    </span>
                    <% } else { %>
                    <span class="text-[8px] font-black text-amber-500 bg-amber-50 dark:bg-amber-950/30 px-2.5 py-1.5 rounded-xl border border-amber-100 dark:border-amber-900/20 uppercase tracking-widest flex items-center gap-1">
                        <i class="fa-solid fa-clock"></i> Pending
                    </span>
                    <% } %>
                </div>
                <p class="text-sm sm:text-base font-medium text-slate-700 dark:text-slate-300 leading-relaxed italic mb-4">"<%= fb.getMessage() %>"</p>
                <div class="pt-4 border-t border-slate-50 dark:border-slate-800">
                    <p class="text-[8px] font-black text-slate-400 uppercase tracking-widest mb-1">Service:</p>
                    <p class="text-[9px] font-black text-slate-900 dark:text-white mono bg-slate-50 dark:bg-slate-950 px-3 py-1.5 rounded-xl border border-slate-100 dark:border-slate-800 truncate"><%= fb.getServiceRef() %></p>
                </div>
                <% if (hasReply) { %>
                <div class="mt-4 bg-gradient-to-br from-indigo-50 to-violet-50 dark:from-indigo-950/20 dark:to-violet-950/10 rounded-xl p-4 border border-indigo-100/50 dark:border-indigo-800/30">
                    <p class="text-[8px] font-black text-indigo-600 uppercase tracking-widest mb-1.5"><i class="fa-solid fa-reply mr-1"></i> Team SwiftDrive</p>
                    <p class="text-xs font-bold text-slate-600 dark:text-slate-400"><%= fb.getAdminReply() %></p>
                </div>
                <% } %>
                <div class="flex justify-end gap-2 mt-4 pt-4 border-t border-slate-50 dark:border-slate-800">
                    <button onclick="toggleMyEdit('<%= fb.getFeedbackId() %>')" class="w-9 h-9 rounded-xl bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-800 text-slate-400 hover:text-indigo-600 hover:border-indigo-200 dark:hover:border-indigo-800 flex items-center justify-center transition-all active:scale-95" title="Edit"><i class="fa-solid fa-pen text-xs"></i></button>
                    <form id="deleteMyFbForm-<%= fb.getFeedbackId() %>" action="DeleteFeedbackServlet" method="POST" class="inline">
                        <input type="hidden" name="feedbackId" value="<%= fb.getFeedbackId() %>">
                        <button type="button" onclick="openConfirmModal('deleteMyFbForm-<%= fb.getFeedbackId() %>', 'Delete Review?', 'Are you sure you want to permanently delete this review?');" class="w-9 h-9 rounded-xl bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-800 text-slate-400 hover:text-rose-600 hover:border-rose-200 dark:hover:border-rose-800 flex items-center justify-center transition-all active:scale-95" title="Delete"><i class="fa-solid fa-trash text-xs"></i></button>
                    </form>
                </div>
            </div>
            <div id="myedit-<%= fb.getFeedbackId() %>" class="hidden">
                <form action="UpdateFeedbackServlet" method="POST" class="space-y-4">
                    <input type="hidden" name="feedbackId" value="<%= fb.getFeedbackId() %>">
                    <div class="rating-stars mb-3">
                        <input type="radio" id="me5-<%= fb.getFeedbackId() %>" name="rating" value="5" <%= rating==5?"checked":"" %>/><label for="me5-<%= fb.getFeedbackId() %>"><i class="fa-solid fa-star"></i></label>
                        <input type="radio" id="me4-<%= fb.getFeedbackId() %>" name="rating" value="4" <%= rating==4?"checked":"" %>/><label for="me4-<%= fb.getFeedbackId() %>"><i class="fa-solid fa-star"></i></label>
                        <input type="radio" id="me3-<%= fb.getFeedbackId() %>" name="rating" value="3" <%= rating==3?"checked":"" %>/><label for="me3-<%= fb.getFeedbackId() %>"><i class="fa-solid fa-star"></i></label>
                        <input type="radio" id="me2-<%= fb.getFeedbackId() %>" name="rating" value="2" <%= rating==2?"checked":"" %>/><label for="me2-<%= fb.getFeedbackId() %>"><i class="fa-solid fa-star"></i></label>
                        <input type="radio" id="me1-<%= fb.getFeedbackId() %>" name="rating" value="1" <%= rating==1?"checked":"" %>/><label for="me1-<%= fb.getFeedbackId() %>"><i class="fa-solid fa-star"></i></label>
                    </div>
                    <textarea name="message" rows="3" class="w-full p-4 bg-slate-50 dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 rounded-xl text-xs font-medium focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none dark:text-white resize-none"><%= fb.getMessage() %></textarea>
                    <div class="flex gap-2">
                        <button type="submit" class="flex-1 bg-gradient-to-r from-indigo-600 to-violet-600 hover:from-indigo-700 hover:to-violet-700 text-white font-black py-2.5 rounded-xl text-[9px] uppercase tracking-widest transition-all active:scale-95 shadow-lg shadow-indigo-200 dark:shadow-none">Update</button>
                        <button type="button" onclick="toggleMyEdit('<%= fb.getFeedbackId() %>')" class="px-4 py-2.5 rounded-xl border border-slate-100 dark:border-slate-800 text-slate-400 font-black text-[9px] uppercase tracking-widest active:scale-95 hover:bg-slate-50 dark:hover:bg-slate-800">Cancel</button>
                    </div>
                </form>
            </div>
        </div>
        <% } %>
    </div>
</div>
<% } %>

<%-- Admin Section: Moderation Panel --%>
<% if (isAdmin) { %>
<div class="mb-12 sm:mb-16">
    <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-6 sm:mb-8">
        <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-slate-800 to-slate-950 dark:from-slate-600 dark:to-slate-800 flex items-center justify-center text-white shadow-lg">
                <i class="fa-solid fa-shield-halved text-sm"></i>
            </div>
            <div>
                <h2 class="text-sm font-black text-slate-900 dark:text-white uppercase tracking-wider">Moderation Panel</h2>
                <p class="text-[9px] font-bold text-slate-400 uppercase tracking-widest mt-0.5"><%= allFb.size() %> total feedback entries</p>
            </div>
        </div>
        <div class="relative w-full md:w-80 group">
            <i class="fa-solid fa-magnifying-glass absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-indigo-500 text-xs transition-colors"></i>
            <input type="text" id="adminSearch" onkeyup="searchAdmin()" placeholder="Search by user, message, or service..." class="w-full pl-10 pr-4 py-3 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-xl text-xs font-bold focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none shadow-sm dark:text-white">
        </div>
    </div>

    <!-- Stats Grid -->
    <div class="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4 mb-6 sm:mb-8">
        <div class="stat-card bg-white dark:bg-slate-900 rounded-xl border border-slate-100 dark:border-slate-800 p-4 shadow-sm relative overflow-hidden">
            <div class="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-indigo-500 to-violet-500"></div>
            <p class="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-1.5">Total</p>
            <p class="text-xl sm:text-2xl font-black text-slate-900 dark:text-white mono"><%= allFb.size() %></p>
        </div>
        <div class="stat-card bg-white dark:bg-slate-900 rounded-xl border border-slate-100 dark:border-slate-800 p-4 shadow-sm relative overflow-hidden">
            <div class="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-emerald-400 to-emerald-600"></div>
            <p class="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-1.5">Positive</p>
            <p class="text-xl sm:text-2xl font-black text-emerald-600 mono"><%= posCount %></p>
        </div>
        <div class="stat-card bg-white dark:bg-slate-900 rounded-xl border border-slate-100 dark:border-slate-800 p-4 shadow-sm relative overflow-hidden">
            <div class="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-amber-400 to-amber-600"></div>
            <p class="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-1.5">Pending Reply</p>
            <p class="text-xl sm:text-2xl font-black text-amber-600 mono"><%= awaitingCount %></p>
        </div>
        <div class="stat-card bg-white dark:bg-slate-900 rounded-xl border border-slate-100 dark:border-slate-800 p-4 shadow-sm relative overflow-hidden">
            <div class="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-rose-400 to-rose-600"></div>
            <p class="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-1.5">Negative</p>
            <p class="text-xl sm:text-2xl font-black text-rose-600 mono"><%= negCount %></p>
        </div>
    </div>

    <!-- Filter Pills -->
    <div class="flex gap-2 mb-6 sm:mb-8 overflow-x-auto pb-2 no-scrollbar">
        <button class="filter-pill active text-[9px] font-black uppercase tracking-widest px-4 py-2.5 rounded-xl bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 shadow-sm" onclick="filterAdmin(this,'all')">All</button>
        <button class="filter-pill text-[9px] font-black uppercase tracking-widest px-3.5 py-2.5 rounded-xl bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 shadow-sm flex items-center gap-1.5" onclick="filterAdmin(this,'pending-approval')"><span class="w-2 h-2 rounded-full bg-indigo-500"></span> Pending Approval (<%= pendingApproval %>)</button>
        <button class="filter-pill text-[9px] font-black uppercase tracking-widest px-3.5 py-2.5 rounded-xl bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 shadow-sm flex items-center gap-1.5" onclick="filterAdmin(this,'awaiting')"><span class="w-2 h-2 rounded-full bg-amber-500"></span> Pending Replies</button>
        <button class="filter-pill text-[9px] font-black uppercase tracking-widest px-3.5 py-2.5 rounded-xl bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 shadow-sm flex items-center gap-1.5" onclick="filterAdmin(this,'positive')"><span class="w-2 h-2 rounded-full bg-emerald-500"></span> High Rated</button>
        <button class="filter-pill text-[9px] font-black uppercase tracking-widest px-3.5 py-2.5 rounded-xl bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 shadow-sm flex items-center gap-1.5" onclick="filterAdmin(this,'negative')"><span class="w-2 h-2 rounded-full bg-rose-500"></span> Low Rated</button>
    </div>

    <!-- Feedback List -->
    <div class="space-y-6" id="adminFeedbackList">
        <% for (int i = allFb.size() - 1; i >= 0; i--) {
            Feedback fb = allFb.get(i);
            boolean isPending = "none".equals(fb.getAdminReply());
            int rating = fb.getRating();
            String sentiment = rating >= 4 ? "positive" : rating <= 2 ? "negative" : "neutral";
        %>
        <div class="admin-fb-card fb-card bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 rounded-2xl overflow-hidden shadow-sm group relative"
             data-sentiment="<%= sentiment %>" data-status="<%= isPending ? "awaiting" : "replied" %>" data-approval="<%= fb.isApproved() ? "approved" : "pending" %>"
             data-search="<%= fb.getCustomerUsername().toLowerCase() %> <%= fb.getMessage().toLowerCase() %> <%= fb.getServiceRef().toLowerCase() %>">

            <!-- Gradient accent -->
            <div class="absolute top-0 left-0 right-0 h-0.5 bg-gradient-to-r from-indigo-500 via-violet-500 to-purple-500"></div>

            <div class="p-5 sm:p-6 md:p-8">
                <div class="flex flex-col sm:flex-row justify-between items-start mb-4 sm:mb-6 gap-4 sm:gap-6">
                    <div class="flex items-center gap-4">
                        <div class="relative flex-shrink-0">
                            <div class="avatar-gradient w-12 h-12 rounded-xl flex items-center justify-center text-white font-black text-base shadow-lg shadow-indigo-200 dark:shadow-none"><%= fb.getCustomerUsername().substring(0,1).toUpperCase() %></div>
                            <% if (fb.isApproved()) { %>
                            <div class="verified-badge absolute -bottom-1 -right-1 w-5 h-5 rounded-lg border-2 border-white dark:border-slate-900 flex items-center justify-center text-white text-[7px]"><i class="fa-solid fa-check"></i></div>
                            <% } %>
                        </div>
                        <div>
                            <h3 class="text-base font-black text-slate-900 dark:text-white tracking-tight flex flex-wrap items-center gap-2 leading-none"><%= fb.getCustomerUsername() %>
                                <span class="mono text-[8px] font-black px-2 py-0.5 rounded-lg bg-indigo-50 dark:bg-indigo-950 text-indigo-600 dark:text-indigo-400 border border-indigo-100 dark:border-indigo-800/50 uppercase tracking-widest max-w-[200px] truncate inline-block"><%= fb.getServiceRef() %></span>
                            </h3>
                            <div class="flex items-center gap-3 mt-1.5">
                                <div class="flex text-amber-500 text-[10px] gap-1"><% for(int s=1; s<=5; s++) { %><i class="<%= s <= rating ? "fa-solid" : "fa-regular" %> fa-star"></i><% } %></div>
                                <span class="text-[8px] font-black text-slate-400 uppercase tracking-widest"><%= fb.getDateSubmitted() %></span>
                            </div>
                        </div>
                    </div>
                    <div class="flex items-center gap-2">
                        <% if (!fb.isApproved()) { %>
                        <form action="ApproveFeedbackServlet" method="POST" class="inline"><input type="hidden" name="feedbackId" value="<%= fb.getFeedbackId() %>">
                            <button type="submit" class="bg-gradient-to-r from-emerald-500 to-emerald-600 hover:from-emerald-600 hover:to-emerald-700 text-white font-black text-[9px] uppercase tracking-widest px-4 py-2.5 rounded-xl shadow-md shadow-emerald-200 dark:shadow-none transition-all active:scale-95 flex items-center gap-1.5"><i class="fa-solid fa-thumbs-up"></i> Approve</button>
                        </form>
                        <% } %>
                        <form id="deleteAdminFbForm-<%= fb.getFeedbackId() %>" action="DeleteFeedbackServlet" method="POST" class="inline">
                            <input type="hidden" name="feedbackId" value="<%= fb.getFeedbackId() %>">
                            <button type="button" onclick="openConfirmModal('deleteAdminFbForm-<%= fb.getFeedbackId() %>', 'Delete Feedback?', 'Are you sure you want to permanently delete this feedback?');" class="w-9 h-9 rounded-xl bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-800 text-slate-400 hover:text-rose-600 hover:border-rose-200 flex items-center justify-center transition-all active:scale-95"><i class="fa-solid fa-trash-can text-xs"></i></button>
                        </form>
                    </div>
                </div>

                <!-- Review Message -->
                <div class="bg-slate-50 dark:bg-slate-950 border border-slate-100 dark:border-slate-800 rounded-xl p-4 sm:p-5 mb-4 sm:mb-6 relative overflow-hidden">
                    <span class="quote-mark absolute top-1 left-3">&ldquo;</span>
                    <p class="text-slate-700 dark:text-slate-300 text-xs sm:text-sm font-medium leading-relaxed italic relative z-10 pl-2"><%= fb.getMessage() %></p>
                </div>

                <!-- Admin Reply Section -->
                <div id="admin-reply-<%= fb.getFeedbackId() %>">
                    <% if (isPending) { %>
                    <form action="AdminReplyFeedbackServlet" method="POST">
                        <input type="hidden" name="feedbackId" value="<%= fb.getFeedbackId() %>">
                        <div class="relative group/reply">
                            <textarea name="adminReply" rows="2" required placeholder="Type your response..." class="w-full px-4 py-3 pb-14 bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-xl text-xs font-bold focus:ring-4 focus:ring-indigo-500/10 focus:border-indigo-500 outline-none resize-none shadow-sm dark:text-white"></textarea>
                            <div class="absolute bottom-3 right-3">
                                <button type="submit" class="bg-gradient-to-r from-indigo-600 to-violet-600 hover:from-indigo-700 hover:to-violet-700 text-white font-black text-[9px] uppercase tracking-widest px-4 py-2 rounded-lg shadow-md transition-all active:scale-95 flex items-center gap-1.5"><i class="fa-solid fa-paper-plane"></i> Send</button>
                            </div>
                        </div>
                    </form>
                    <% } else { %>
                    <div class="flex gap-4 sm:gap-6">
                        <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-slate-800 to-slate-950 border border-slate-700 flex items-center justify-center text-white text-[9px] font-black uppercase flex-shrink-0 shadow-md">ADM</div>
                        <div class="flex-1 bg-gradient-to-br from-indigo-50 to-violet-50 dark:from-indigo-950/30 dark:to-violet-950/20 border border-indigo-100/50 dark:border-indigo-800/30 rounded-xl p-4 sm:p-5 relative group/edit overflow-hidden min-h-[80px]">
                            <div id="adm-display-<%= fb.getFeedbackId() %>">
                                <div class="absolute top-2 right-2 flex gap-1.5 transition-all">
                                    <button onclick="enableAdmEdit('<%= fb.getFeedbackId() %>')" class="w-8 h-8 rounded-lg bg-white dark:bg-slate-900 text-indigo-500 shadow-md border border-indigo-100 dark:border-indigo-900 flex items-center justify-center hover:scale-105 active:scale-95 transition-all" title="Edit Response"><i class="fa-solid fa-pen-nib text-xs"></i></button>
                                    <form id="deleteReplyForm-<%= fb.getFeedbackId() %>" action="AdminReplyFeedbackServlet" method="POST" class="inline">
                                        <input type="hidden" name="feedbackId" value="<%= fb.getFeedbackId() %>">
                                        <input type="hidden" name="adminReply" value="none">
                                        <button type="button" onclick="openConfirmModal('deleteReplyForm-<%= fb.getFeedbackId() %>', 'Delete Admin Response?', 'Are you sure you want to delete this response?');" class="w-8 h-8 rounded-lg bg-white dark:bg-slate-900 text-rose-500 shadow-md border border-rose-100 dark:border-rose-900 flex items-center justify-center hover:scale-105 active:scale-95 transition-all" title="Delete Response"><i class="fa-solid fa-trash-can text-xs"></i></button>
                                    </form>
                                </div>
                                <p class="text-[8px] font-black text-indigo-600 uppercase tracking-widest mb-1.5">Admin Response</p>
                                <p class="text-xs font-bold text-slate-800 dark:text-slate-200 leading-relaxed"><%= fb.getAdminReply() %></p>
                            </div>
                            <div id="adm-edit-<%= fb.getFeedbackId() %>" class="hidden">
                                <form action="AdminReplyFeedbackServlet" method="POST" class="space-y-3">
                                    <input type="hidden" name="feedbackId" value="<%= fb.getFeedbackId() %>">
                                    <p class="text-[8px] font-black text-indigo-600 uppercase tracking-widest mb-1">Edit Response</p>
                                    <textarea name="adminReply" rows="2" required class="w-full px-4 py-2.5 bg-white dark:bg-slate-900 border border-indigo-500/20 rounded-lg text-xs font-bold outline-none focus:border-indigo-500 resize-none dark:text-white"><%= fb.getAdminReply() %></textarea>
                                    <div class="flex justify-end gap-3">
                                        <button type="button" onclick="disableAdmEdit('<%= fb.getFeedbackId() %>')" class="text-[8px] font-black text-slate-400 uppercase tracking-widest hover:text-rose-500">Cancel</button>
                                        <button type="submit" class="bg-gradient-to-r from-indigo-600 to-violet-600 text-white font-black text-[9px] uppercase tracking-widest px-4 py-1.5 rounded-lg shadow-md transition-all active:scale-95 flex items-center gap-1.5"><i class="fa-solid fa-cloud-arrow-up text-xs"></i> Update</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>
        <% } %>
    </div>
</div>

<script>
function searchAdmin() {
    const q = document.getElementById('adminSearch').value.toLowerCase();
    document.querySelectorAll('.admin-fb-card').forEach(card => { card.style.display = card.dataset.search.includes(q) ? '' : 'none'; });
}
function filterAdmin(btn, filter) {
    document.querySelectorAll('#adminFeedbackList').forEach(() => {
        btn.parentElement.querySelectorAll('.filter-pill').forEach(p => p.classList.remove('active'));
    });
    btn.classList.add('active');
    document.querySelectorAll('.admin-fb-card').forEach(card => {
        if (filter === 'all') { card.style.display = ''; return; }
        if (filter === 'awaiting') { card.style.display = card.dataset.status === 'awaiting' ? '' : 'none'; return; }
        if (filter === 'pending-approval') { card.style.display = card.dataset.approval === 'pending' ? '' : 'none'; return; }
        card.style.display = card.dataset.sentiment === filter ? '' : 'none';
    });
}
function enableAdmEdit(id) { document.getElementById('adm-display-'+id).classList.add('hidden'); document.getElementById('adm-edit-'+id).classList.remove('hidden'); }
function disableAdmEdit(id) { document.getElementById('adm-display-'+id).classList.remove('hidden'); document.getElementById('adm-edit-'+id).classList.add('hidden'); }
</script>
<% } %>

<%-- Customer edit toggle script --%>
<% if (isCustomer) { %>
<script>
function toggleMyEdit(id) {
    document.getElementById('myview-'+id).classList.toggle('hidden');
    document.getElementById('myedit-'+id).classList.toggle('hidden');
}
</script>
<% } %>
