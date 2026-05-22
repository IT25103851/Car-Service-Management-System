<%@ include file="theme_script.jsp" %>
<nav class="nav-glass fixed top-0 w-full z-[100] transition-all duration-300">
  <div class="max-w-7xl mx-auto px-4 flex items-center justify-between h-20">
    <!-- Branding Section -->
    <div class="flex items-center gap-8">
      <button id="cust-mobile-menu-btn" class="text-slate-600 dark:text-slate-400 md:hidden focus:outline-none hover:text-indigo-600 transition-colors">
        <svg class="w-7 h-7" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path></svg>
      </button>
      <a href="customer_dashboard.jsp" class="flex items-center gap-3 group">
        <div class="w-10 h-10 bg-indigo-600 rounded-2xl flex items-center justify-center shadow-xl shadow-indigo-200 dark:shadow-none group-hover:scale-110 transition-transform border-b-4 border-indigo-800">
          <i class="fa-solid fa-car-side text-white text-sm"></i>
        </div>
        <span class="branding-text text-xl font-black tracking-tighter">SwiftDrive</span>
      </a>
    </div>

    <!-- Desktop Navigation -->
    <div id="cust-desktop-menu" class="hidden md:flex items-center gap-2">
      <!-- Injected by script with enhanced contrast -->
    </div>

    <!-- System Controls -->
    <div class="flex items-center gap-4">
      <button onclick="toggleTheme()" class="w-11 h-11 rounded-2xl bg-white dark:bg-slate-900 text-slate-500 dark:text-slate-400 hover:text-indigo-600 dark:hover:text-indigo-400 flex items-center justify-center transition-all border border-slate-100 dark:border-slate-800 shadow-sm hover:shadow-md active:scale-90 overflow-hidden">
        <i class="fa-solid fa-moon show-light text-lg"></i>
        <i class="fa-solid fa-sun show-dark text-lg"></i>
      </button>
      <div class="h-8 w-[1px] bg-slate-100 dark:bg-slate-800 hidden sm:block"></div>
      <a href="LogoutServlet" onclick="confirmLogout(event)" class="hidden md:inline-block bg-slate-900 dark:bg-white text-white dark:text-slate-950 text-[10px] font-black uppercase tracking-widest px-6 py-3 rounded-2xl transition-all shadow-xl shadow-slate-200/50 dark:shadow-none hover:translate-y-[-2px] active:scale-95">Logout</a>
    </div>
    </div>
  </div>
</nav>

<!-- Mobile Navigation -->
<div id="cust-mobile-menu" class="hidden bg-white dark:bg-slate-950 border-t border-slate-100 dark:border-slate-800 px-6 py-6 md:hidden animate-slide-up flex flex-col gap-4 shadow-xl">
  <div class="flex flex-col gap-3" id="cust-mobile-menu-list"></div>
  <div class="pt-4 border-t border-slate-100 dark:border-slate-800">
    <a href="LogoutServlet" onclick="confirmLogout(event)" class="w-full bg-slate-900 dark:bg-white text-white dark:text-slate-950 text-[10px] font-black uppercase tracking-widest px-6 py-4 rounded-2xl transition-all shadow-xl shadow-slate-200/50 dark:shadow-none hover:translate-y-[-2px] active:scale-95 flex items-center justify-center gap-2">
      <i class="fa-solid fa-right-from-bracket"></i> Logout
    </a>
  </div>
</div>

<script>
  const custTabs = [
    { name: 'Dashboard', link: 'customer_dashboard.jsp', icon: 'fa-table-columns' },
    { name: 'My Garage', link: 'customer_vehicles.jsp', icon: 'fa-warehouse' },
    { name: 'Book Service', link: 'book_appointment.jsp', icon: 'fa-calendar-plus' },
    { name: 'Reviews', link: 'reviews.jsp', icon: 'fa-star' }
  ];

  const cDesktopMenu = document.getElementById('cust-desktop-menu');
  const cMobileMenuList = document.getElementById('cust-mobile-menu-list');
  const cCurrentPage = window.location.pathname.split('/').pop() || 'customer_dashboard.jsp';

  function createCustomerTabs() {
    cDesktopMenu.innerHTML = '';
    cMobileMenuList.innerHTML = '';

    custTabs.forEach(tab => {
      const isActive = cCurrentPage === tab.link;

      // Desktop Node
      const dTab = document.createElement('a');
      dTab.href = tab.link;
      dTab.className = isActive 
        ? 'active-tab px-6 py-3 rounded-2xl text-[10px] font-black uppercase tracking-widest flex items-center gap-3 transition-all' 
        : 'text-slate-500 dark:text-slate-400 hover:text-indigo-600 dark:hover:text-indigo-400 hover:bg-slate-50 dark:hover:bg-slate-900/50 px-6 py-3 rounded-2xl text-[10px] font-black uppercase tracking-widest flex items-center gap-3 transition-all';
      dTab.innerHTML = `<i class="fa-solid ${tab.icon} text-xs"></i>` + tab.name;
      cDesktopMenu.appendChild(dTab);

      // Mobile Node
      const mTab = document.createElement('a');
      mTab.href = tab.link;
      mTab.className = isActive 
        ? 'bg-indigo-600 text-white px-6 py-4 rounded-2xl text-xs font-black uppercase tracking-widest flex items-center gap-4 shadow-xl shadow-indigo-100 dark:shadow-none' 
        : 'text-slate-500 dark:text-slate-400 px-6 py-4 rounded-2xl text-xs font-black uppercase tracking-widest flex items-center gap-4 hover:bg-slate-50 dark:hover:bg-slate-900 transition-colors';
      mTab.innerHTML = `<i class="fa-solid ${tab.icon} w-6 text-sm"></i>` + tab.name;
      cMobileMenuList.appendChild(mTab);
    });
  }

  createCustomerTabs();
  const cBtn = document.getElementById('cust-mobile-menu-btn');
  const cMobileMenu = document.getElementById('cust-mobile-menu');
  if (cBtn) cBtn.addEventListener('click', () => cMobileMenu.classList.toggle('hidden'));
  
  function confirmLogout(e) {
    if(!confirm("Are you sure you want to logout?")) e.preventDefault();
  }
</script>
<%@ include file="logout_script.jsp" %>
