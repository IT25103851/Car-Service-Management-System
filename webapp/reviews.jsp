<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.FeedbackManager, model.Feedback, java.util.List, java.util.ArrayList" %>
<%
    String role = (String) session.getAttribute("userRole");
    String username = (String) session.getAttribute("username");
    boolean isAdmin = "admin".equals(role);
    boolean isCustomer = username != null && !isAdmin;

    FeedbackManager manager = new FeedbackManager();
    List<Feedback> allFb = manager.getAllFeedback();
    List<Feedback> approved = manager.getApprovedFeedback();

    List<Feedback> myFb = new ArrayList<>();
    if (isCustomer) {
        for (Feedback fb : allFb) {
            if (fb.getCustomerUsername().equals(username)) myFb.add(fb);
        }
    }

    int total = approved.size();
    double avgRating = 0;
    int[] dist = new int[6];
    if (total > 0) {
        int sum = 0;
        for (Feedback fb : approved) { sum += fb.getRating(); dist[fb.getRating()]++; }
        avgRating = (double) sum / total;
    }

    int awaitingCount = 0, posCount = 0, negCount = 0, pendingApproval = 0;
    if (isAdmin) {
        for (Feedback fb : allFb) {
            if ("none".equals(fb.getAdminReply())) awaitingCount++;
            if (!fb.isApproved()) pendingApproval++;
            if (fb.getRating() >= 4) posCount++; else if (fb.getRating() <= 2) negCount++;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reviews Hub - SwiftDrive</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;700&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Plus Jakarta Sans', sans-serif; }
        .mono { font-family: 'JetBrains Mono', monospace; }

        /* ── Hero Glow ── */
        .hero-glow {
            position: absolute; width: 600px; height: 600px; border-radius: 50%;
            background: radial-gradient(circle, rgba(99,102,241,0.15) 0%, transparent 70%);
            pointer-events: none; top: -200px; right: -100px;
        }
        .dark .hero-glow { background: radial-gradient(circle, rgba(99,102,241,0.08) 0%, transparent 70%); }

        /* ── Glass Card ── */
        .glass-card {
            background: rgba(255,255,255,0.7);
            backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(255,255,255,0.5);
        }
        .dark .glass-card {
            background: rgba(15,23,42,0.6);
            border-color: rgba(51,65,85,0.4);
        }

        /* ── Review Cards ── */
        .review-card {
            transition: all 0.5s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative; overflow: hidden;
        }
        .review-card::before {
            content: ''; position: absolute; top: 0; left: 0; right: 0; height: 3px;
            background: linear-gradient(90deg, #6366f1, #8b5cf6, #a78bfa);
            opacity: 0; transition: opacity 0.4s;
        }
        .review-card:hover { transform: translateY(-8px); box-shadow: 0 25px 50px -12px rgba(99,102,241,0.15); }
        .review-card:hover::before { opacity: 1; }
        .dark .review-card:hover { box-shadow: 0 25px 50px -12px rgba(0,0,0,0.4); }

        /* ── Feedback Cards ── */
        .fb-card { transition: all 0.5s cubic-bezier(0.4, 0, 0.2, 1); }
        .fb-card:hover { transform: translateY(-6px); }

        /* ── Filter Pills ── */
        .filter-pill {
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1); cursor: pointer;
            position: relative; overflow: hidden;
        }
        .filter-pill.active {
            background: linear-gradient(135deg, #6366f1, #8b5cf6) !important;
            color: #fff !important;
            box-shadow: 0 10px 30px -5px rgba(99, 102, 241, 0.4);
            border-color: transparent !important;
        }
        .filter-pill:not(.active):hover {
            border-color: #6366f1 !important;
            color: #6366f1 !important;
        }

        /* ── Stat Cards ── */
        .stat-card { transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1); }
        .stat-card:hover { transform: translateY(-4px); box-shadow: 0 20px 40px -10px rgba(0,0,0,0.1); }

        /* ── Rating Stars (for edit forms) ── */
        .rating-stars { display: flex; flex-direction: row-reverse; justify-content: flex-end; gap: 0.5rem; }
        .rating-stars input { display: none; }
        .rating-stars label { cursor: pointer; color: #e2e8f0; font-size: 2.25rem; transition: all 0.3s; }
        .dark .rating-stars label { color: #1e293b; }
        .rating-stars input:checked ~ label,
        .rating-stars label:hover,
        .rating-stars label:hover ~ label { color: #facc15; transform: scale(1.15); }

        /* ── Distribution Bars ── */
        .dist-bar-fill {
            background: linear-gradient(90deg, #6366f1, #818cf8);
            transition: width 1.2s cubic-bezier(0.4, 0, 0.2, 1);
        }

        /* ── Avatar Gradients ── */
        .avatar-gradient {
            background: linear-gradient(135deg, #6366f1, #8b5cf6);
        }
        .avatar-gradient-sm {
            background: linear-gradient(135deg, #6366f1, #8b5cf6);
        }

        /* ── Verified Badge ── */
        .verified-badge {
            background: linear-gradient(135deg, #10b981, #059669);
        }

        /* ── Scrollbar ── */
        .no-scrollbar::-webkit-scrollbar { display: none; }
        .no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }

        /* ── Animations ── */
        @keyframes slideUp {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
        @keyframes countUp {
            from { opacity: 0; transform: scale(0.5); }
            to { opacity: 1; transform: scale(1); }
        }
        .animate-slide-up { animation: slideUp 0.7s cubic-bezier(0.4, 0, 0.2, 1) forwards; }
        .animate-fade-in { animation: fadeIn 0.6s ease forwards; }
        .animate-count { animation: countUp 0.8s cubic-bezier(0.34, 1.56, 0.64, 1) forwards; }

        .review-card:nth-child(1) { animation-delay: 0.05s; }
        .review-card:nth-child(2) { animation-delay: 0.1s; }
        .review-card:nth-child(3) { animation-delay: 0.15s; }
        .review-card:nth-child(4) { animation-delay: 0.2s; }
        .review-card:nth-child(5) { animation-delay: 0.25s; }
        .review-card:nth-child(6) { animation-delay: 0.3s; }

        /* ── Quote ── */
        .quote-mark { 
            font-family: Georgia, serif; font-size: 4rem; line-height: 1;
            background: linear-gradient(135deg, #6366f1, #a78bfa);
            -webkit-background-clip: text; -webkit-text-fill-color: transparent;
            opacity: 0.2;
        }
    </style>
</head>
<body class="antialiased text-slate-900 dark:text-slate-100 bg-slate-50 dark:bg-slate-950 transition-colors duration-300 min-h-screen pt-28 pb-20">
<% if (isAdmin) { %>
    <%@ include file="navbar.jsp" %>
<% } else if (isCustomer) { %>
    <%@ include file="customer_navbar.jsp" %>
<% } else { %>
    <nav class="fixed top-0 w-full bg-white/80 dark:bg-slate-950/80 backdrop-blur-md z-[100] h-20 border-b border-slate-100 dark:border-slate-800 flex items-center px-8">
        <a href="index.jsp" class="text-xl font-black tracking-tighter">SwiftDrive</a>
    </nav>
<% } %>

<div class="max-w-7xl mx-auto px-4">

    <!-- ═══════════════════════════════════════════ -->
    <!-- SECTION 1: HERO RATING SUMMARY             -->
    <!-- ═══════════════════════════════════════════ -->
    <div class="relative mb-12 md:mb-16 animate-slide-up">
        <div class="hero-glow"></div>
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 md:gap-8 lg:gap-12 items-center">

            <!-- Left: Tagline -->
            <div class="lg:col-span-1 relative z-10">
                <div class="inline-flex items-center gap-2 bg-indigo-50 dark:bg-indigo-950/50 border border-indigo-100 dark:border-indigo-900/30 px-3 py-1.5 rounded-full mb-4">
                    <span class="w-2 h-2 bg-indigo-500 rounded-full animate-pulse"></span>
                    <span class="text-[9px] font-black text-indigo-600 dark:text-indigo-400 uppercase tracking-widest">Live Reviews</span>
                </div>
                <h1 class="text-3xl sm:text-4xl lg:text-5xl font-black text-slate-900 dark:text-white tracking-tighter leading-[0.9] mb-4">
                    Trusted by<br/><span class="bg-clip-text text-transparent bg-gradient-to-r from-indigo-600 via-violet-600 to-purple-600">our drivers</span>.
                </h1>
                <p class="text-sm sm:text-base font-medium text-slate-500 dark:text-slate-400 leading-relaxed">Our commitment to excellence, reflected in every review from our community.</p>
                <% if (isCustomer) { %>
                <a href="customer_dashboard.jsp" class="mt-6 inline-flex items-center gap-2.5 bg-gradient-to-r from-indigo-600 to-violet-600 hover:from-indigo-700 hover:to-violet-700 text-white px-6 py-3.5 rounded-2xl font-black text-[10px] uppercase tracking-widest shadow-xl shadow-indigo-500/20 dark:shadow-indigo-500/10 transition-all active:scale-95 hover:-translate-y-0.5">
                    <i class="fa-solid fa-pen-to-square text-base"></i> Write a Review
                </a>
                <% } %>
            </div>

            <!-- Right: Rating Summary Card -->
            <div class="lg:col-span-2 glass-card rounded-3xl p-6 sm:p-8 shadow-2xl shadow-slate-200/40 dark:shadow-none relative z-10">
                <div class="flex flex-col sm:flex-row items-center gap-8 md:gap-12">
                    <!-- Score -->
                    <div class="text-center flex-shrink-0">
                        <div class="relative inline-block">
                            <p class="text-6xl sm:text-7xl lg:text-8xl font-black text-slate-900 dark:text-white tracking-tighter animate-count"><%= String.format("%.1f", avgRating) %></p>
                            <div class="absolute -top-2 -right-4 w-8 h-8 bg-gradient-to-br from-amber-400 to-orange-500 rounded-xl flex items-center justify-center shadow-lg shadow-amber-200 dark:shadow-none rotate-12">
                                <i class="fa-solid fa-star text-white text-xs"></i>
                            </div>
                        </div>
                        <div class="flex justify-center text-amber-500 gap-1.5 mt-3 mb-1.5">
                            <% for(int i=1; i<=5; i++) { %>
                                <i class="<%= i <= Math.round(avgRating) ? "fa-solid" : "fa-regular" %> fa-star text-lg transition-all hover:scale-125"></i>
                            <% } %>
                        </div>
                        <p class="text-[9px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-widest">Based on <%= total %> reviews</p>
                    </div>
                    <!-- Distribution -->
                    <div class="flex-1 w-full space-y-2.5">
                        <% for(int i=5; i>=1; i--) { int pct = total > 0 ? (dist[i] * 100 / total) : 0; %>
                        <div class="flex items-center gap-3 group">
                            <span class="text-xs font-black text-slate-500 dark:text-slate-400 w-6 text-right group-hover:text-indigo-500 transition-colors"><%= i %><i class="fa-solid fa-star text-[8px] ml-0.5 text-amber-400"></i></span>
                            <div class="flex-1 h-3 bg-slate-100 dark:bg-slate-800 rounded-full overflow-hidden">
                                <div class="dist-bar-fill h-full rounded-full" style="width: <%= pct %>%"></div>
                            </div>
                            <span class="text-[10px] font-black text-slate-900 dark:text-white w-10 text-right mono"><%= dist[i] %></span>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- ═══════════════════════════════════════════ -->
    <!-- SECTION 2: PUBLIC REVIEW WALL               -->
    <!-- ═══════════════════════════════════════════ -->
    <div class="mb-12 md:mb-16">
        <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-8">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-indigo-500 to-violet-500 flex items-center justify-center text-white shadow-lg shadow-indigo-200 dark:shadow-none">
                    <i class="fa-solid fa-globe text-sm"></i>
                </div>
                <div>
                    <h2 class="text-sm font-black text-slate-900 dark:text-white uppercase tracking-wider">Community Reviews</h2>
                    <p class="text-[9px] font-bold text-slate-400 uppercase tracking-widest mt-0.5"><%= total %> verified reviews</p>
                </div>
            </div>
            <div class="flex flex-wrap gap-1.5 sm:gap-2 w-full sm:w-auto" id="starFilterContainer">
                <button class="filter-pill active text-[9px] font-black uppercase tracking-widest px-4 py-2.5 rounded-xl bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 shadow-sm" onclick="filterStars(this,'all')">All</button>
                <% for(int i=5; i>=1; i--) { %>
                <button class="filter-pill text-[9px] font-black uppercase tracking-widest px-3.5 py-2.5 rounded-xl bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 shadow-sm flex items-center gap-1.5" onclick="filterStars(this,'<%= i %>')">
                    <i class="fa-solid fa-star text-amber-400 text-[8px]"></i> <%= i %>
                </button>
                <% } %>
            </div>
        </div>

        <div class="columns-1 sm:columns-2 lg:columns-3 gap-6 space-y-6" id="publicWall">
            <% for (int i = approved.size() - 1; i >= 0; i--) { Feedback fb = approved.get(i);
                int fbRating = fb.getRating();
                String ratingColor = fbRating >= 4 ? "emerald" : fbRating >= 3 ? "amber" : "rose";
                boolean hasAdminReply = fb.getAdminReply() != null && !"none".equals(fb.getAdminReply());
            %>
            <div class="review-card break-inside-avoid bg-white dark:bg-slate-900 border border-slate-100 dark:border-slate-800 rounded-2xl p-5 sm:p-6 shadow-xl shadow-slate-200/20 dark:shadow-none flex flex-col group animate-slide-up mb-6" data-stars="<%= fbRating %>">

                <!-- Quote Mark & Rating Row -->
                <div class="flex items-start justify-between mb-4">
                    <span class="quote-mark">&ldquo;</span>
                    <div class="flex items-center gap-2">
                        <div class="flex text-amber-500 text-xs gap-0.5">
                            <% for(int s=1; s<=5; s++) { %><i class="<%= s <= fbRating ? "fa-solid" : "fa-regular" %> fa-star"></i><% } %>
                        </div>
                        <span class="text-[8px] font-black px-2 py-1 rounded-lg bg-<%= ratingColor %>-50 dark:bg-<%= ratingColor %>-950/30 text-<%= ratingColor %>-600 dark:text-<%= ratingColor %>-400 border border-<%= ratingColor %>-100 dark:border-<%= ratingColor %>-900/20 uppercase tracking-widest"><%= fbRating %>.0</span>
                    </div>
                </div>

                <!-- Review Message -->
                <p class="text-sm font-medium text-slate-700 dark:text-slate-300 leading-relaxed mb-5 flex-1">"<%= fb.getMessage() %>"</p>

                <!-- User Info -->
                <div class="flex items-center gap-3 pt-4 border-t border-slate-100 dark:border-slate-800">
                    <div class="relative">
                        <div class="avatar-gradient-sm w-10 h-10 rounded-xl flex items-center justify-center text-white font-black text-sm shadow-md"><%= fb.getCustomerUsername().substring(0,1).toUpperCase() %></div>
                        <div class="verified-badge absolute -bottom-1 -right-1 w-4 h-4 rounded-md border-2 border-white dark:border-slate-900 flex items-center justify-center text-white text-[6px]"><i class="fa-solid fa-check"></i></div>
                    </div>
                    <div class="min-w-0 flex-1">
                        <h4 class="text-xs font-black text-slate-900 dark:text-white leading-none truncate"><%= fb.getCustomerUsername() %></h4>
                        <p class="text-[8px] font-bold text-slate-400 uppercase tracking-widest mt-1 truncate"><%= fb.getServiceRef() %></p>
                    </div>
                    <span class="text-[8px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-widest flex-shrink-0"><%= fb.getDateSubmitted().split(" ")[0] %></span>
                </div>

                <!-- Admin Reply -->
                <% if (hasAdminReply) { %>
                <div class="mt-4 bg-gradient-to-br from-indigo-50 to-violet-50 dark:from-indigo-950/30 dark:to-violet-950/20 rounded-xl p-4 border border-indigo-100/50 dark:border-indigo-800/30 relative overflow-hidden">
                    <div class="absolute top-0 right-0 w-16 h-16 bg-indigo-500/5 rounded-full -translate-y-1/2 translate-x-1/2"></div>
                    <p class="text-[8px] font-black text-indigo-600 dark:text-indigo-400 uppercase tracking-widest mb-1.5 flex items-center gap-1.5 relative z-10">
                        <i class="fa-solid fa-reply"></i> Team SwiftDrive
                    </p>
                    <p class="text-xs font-bold text-slate-600 dark:text-slate-400 leading-relaxed relative z-10"><%= fb.getAdminReply() %></p>
                </div>
                <% } %>
            </div>
            <% } %>

            <% if (approved.isEmpty()) { %>
            <div class="col-span-full bg-white dark:bg-slate-900 rounded-3xl border-2 border-dashed border-slate-100 dark:border-slate-800 p-12 sm:p-16 text-center">
                <div class="w-20 h-20 rounded-2xl bg-slate-50 dark:bg-slate-800 flex items-center justify-center mx-auto mb-6 shadow-inner">
                    <i class="fa-solid fa-comment-slash text-slate-300 dark:text-slate-700 text-3xl"></i>
                </div>
                <h3 class="text-lg sm:text-xl font-black text-slate-900 dark:text-white tracking-tighter mb-2">No Reviews Yet</h3>
                <p class="text-slate-500 text-xs font-medium mb-6">Be the first to share your SwiftDrive experience.</p>
                <% if (isCustomer) { %>
                <a href="customer_dashboard.jsp" class="inline-flex items-center gap-2 bg-gradient-to-r from-indigo-600 to-violet-600 text-white px-5 py-2.5 rounded-xl font-black text-[9px] uppercase tracking-widest shadow-lg transition-all hover:-translate-y-0.5 active:scale-95">
                    <i class="fa-solid fa-pen"></i> Write First Review
                </a>
                <% } %>
            </div>
            <% } %>
        </div>
    </div>

    <%@ include file="reviews_sections.jsp" %>

</div>

<!-- CUSTOM CONFIRMATION MODAL -->
<div id="customConfirmModal" class="hidden fixed inset-0 z-[200] flex items-center justify-center p-4 sm:p-6">
    <div class="absolute inset-0 bg-slate-950/80 backdrop-blur-xl opacity-0 transition-opacity duration-300" id="confirmBackdrop" onclick="closeConfirmModal()"></div>
    <div class="relative bg-white dark:bg-slate-900 rounded-[2rem] shadow-2xl max-w-sm w-full border border-slate-100 dark:border-slate-800 overflow-y-auto max-h-[calc(100vh-2rem)] sm:max-h-[90vh] custom-scrollbar transform scale-95 opacity-0 transition-all duration-300" id="confirmPanel">
        <div class="p-6 sm:p-10 text-center">
            <div class="w-16 h-16 rounded-[1.5rem] bg-rose-50 dark:bg-rose-950/30 flex items-center justify-center mx-auto mb-6 text-rose-500 shadow-inner border border-rose-100 dark:border-rose-900/30">
                <i class="fa-solid fa-triangle-exclamation text-3xl"></i>
            </div>
            <h3 class="text-2xl font-black text-slate-900 dark:text-white tracking-tighter" id="confirmTitle">Confirm Deletion</h3>
            <p class="text-sm font-medium text-slate-500 dark:text-slate-400 mt-3 leading-relaxed" id="confirmMessage">
                Are you sure you want to proceed?
            </p>
            
            <div class="flex flex-col gap-3 mt-8">
                <button type="button" id="confirmProceedBtn" class="w-full py-4 rounded-xl bg-rose-600 hover:bg-rose-700 text-white font-black text-[10px] uppercase tracking-[0.2em] shadow-xl shadow-rose-100 dark:shadow-none transition-all active:scale-95 flex items-center justify-center gap-3">
                    <i class="fa-solid fa-check text-base"></i> Yes, Proceed
                </button>
                <button type="button" onclick="closeConfirmModal()" class="w-full py-4 rounded-xl bg-white dark:bg-slate-950 border-2 border-slate-100 dark:border-slate-800 text-slate-400 dark:text-slate-700 font-black text-[10px] uppercase tracking-[0.2em] hover:bg-slate-50 dark:hover:bg-slate-800 transition-all">
                    Cancel
                </button>
            </div>
        </div>
    </div>
</div>

<%@ include file="toast.jsp" %>
<script>
let pendingFormIdToSubmit = null;

function openConfirmModal(formId, title, message) {
    pendingFormIdToSubmit = formId;
    document.getElementById('confirmTitle').innerText = title;
    document.getElementById('confirmMessage').innerText = message;
    
    const m = document.getElementById('customConfirmModal');
    const b = document.getElementById('confirmBackdrop');
    const p = document.getElementById('confirmPanel');
    
    m.classList.remove('hidden');
    document.body.style.overflow = 'hidden';
    setTimeout(() => { b.style.opacity='1'; p.classList.remove('scale-95', 'opacity-0'); p.classList.add('scale-100', 'opacity-100'); }, 20);
}

function closeConfirmModal() {
    pendingFormIdToSubmit = null;
    const b = document.getElementById('confirmBackdrop');
    const p = document.getElementById('confirmPanel');
    b.style.opacity='0'; p.classList.remove('scale-100', 'opacity-100'); p.classList.add('scale-95', 'opacity-0');
    document.body.style.overflow = 'auto';
    setTimeout(() => document.getElementById('customConfirmModal').classList.add('hidden'), 300);
}

document.addEventListener("DOMContentLoaded", () => {
    const btn = document.getElementById('confirmProceedBtn');
    if (btn) {
        btn.addEventListener('click', () => {
            if (pendingFormIdToSubmit) {
                const form = document.getElementById(pendingFormIdToSubmit);
                if (form) form.submit();
            }
            closeConfirmModal();
        });
    }
});
function filterStars(btn, star) {
    document.querySelectorAll('#starFilterContainer .filter-pill').forEach(p => p.classList.remove('active'));
    btn.classList.add('active');
    document.querySelectorAll('#publicWall .review-card').forEach(card => {
        if (star === 'all' || card.dataset.stars === star) { card.style.display = ''; } else { card.style.display = 'none'; }
    });
}

document.addEventListener("DOMContentLoaded", () => {
    const params = new URLSearchParams(window.location.search);
    if (params.get("success") === "true" || params.get("success") === "replied") showToast("Reply sent successfully.", "success");
    if (params.get("success") === "updated") showToast("Feedback updated.", "success");
    if (params.get("success") === "deleted") showToast("Feedback deleted.", "success");
    if (params.get("success") === "approved") showToast("Review approved and published!", "success");
});
</script>
<% if (isAdmin || isCustomer) { %>
<%@ include file="logout_script.jsp" %>
<% } %>
</body>
</html>
