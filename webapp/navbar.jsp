<%@ include file="theme_script.jsp" %>
<nav class="nav-glass fixed top-0 w-full z-[100] transition-all duration-300">
  <div class="max-w-7xl mx-auto px-4 flex items-center justify-between h-20">
    <!-- Branding Section -->
    <div class="flex items-center gap-8">
      <button id="mobile-menu-btn" class="text-slate-600 dark:text-slate-400 xl:hidden focus:outline-none hover:text-indigo-600 transition-colors">
        <svg class="w-7 h-7" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path></svg>
      </button>
      <a href="dashboard.jsp" class="flex items-center gap-3 group">
        <span class="branding-text text-xl font-black tracking-tighter">SwiftDrive <span class="text-indigo-600 dark:text-indigo-400">Admin</span></span>
      </a>
    </div>

    <!-- Desktop Navigation -->
    <div id="desktop-menu" class="hidden xl:flex items-center gap-1">
      <!-- Injected by script with high-contrast tokens -->
    </div>

    <!-- System Controls -->
    <div class="flex items-center gap-4">
      <button onclick="toggleTheme()" class="w-11 h-11 rounded-2xl bg-white dark:bg-slate-900 text-slate-500 dark:text-slate-400 hover:text-indigo-600 dark:hover:text-indigo-400 flex items-center justify-center transition-all border border-slate-100 dark:border-slate-800 shadow-sm hover:shadow-md active:scale-90 overflow-hidden">
        <i class="fa-solid fa-moon show-light text-lg"></i>
        <i class="fa-solid fa-sun show-dark text-lg"></i>
      </button>
      <div class="h-8 w-[1px] bg-slate-100 dark:bg-slate-800 hidden sm:block"></div>
      <a href="LogoutServlet" onclick="confirmLogout(event)" class="hidden xl:inline-block bg-rose-600 text-white text-[10px] font-black uppercase tracking-widest px-6 py-3 rounded-2xl transition-all shadow-xl shadow-rose-100 dark:shadow-none hover:translate-y-[-2px] active:scale-95 border-b-4 border-rose-800">Logout</a>
    </div>
  </div>
</nav>

<!-- Mobile Navigation (Sidebar Drawer) -->
<div id="mobile-menu" class="fixed inset-0 z-[150] hidden">
  <div id="mobile-menu-backdrop" class="absolute inset-0 bg-slate-955/60 backdrop-blur-sm opacity-0 transition-opacity duration-300"></div>
  <div id="mobile-menu-panel" class="absolute inset-y-0 left-0 w-80 bg-white dark:bg-slate-950 shadow-2xl transform -translate-x-full transition-transform duration-500 ease-out flex flex-col p-8 overflow-y-auto custom-scrollbar">
    <div class="flex items-center justify-between mb-12">
      <span class="text-xl font-black tracking-tighter">SwiftDrive</span>
      <button id="close-mobile-btn" class="text-slate-400 hover:text-indigo-600 transition-colors">
        <i class="fa-solid fa-xmark text-xl"></i>
      </button>
    </div>
    <div class="flex flex-col gap-4" id="mobile-menu-list"></div>
    
    <!-- Mobile Logout Button at the bottom -->
    <div class="mt-auto pt-6 border-t border-slate-100 dark:border-slate-800">
      <a href="LogoutServlet" onclick="confirmLogout(event)" class="w-full bg-rose-600 text-white text-[10px] font-black uppercase tracking-widest px-6 py-4 rounded-2xl transition-all shadow-xl shadow-rose-100 dark:shadow-none hover:translate-y-[-2px] active:scale-95 border-b-4 border-rose-800 flex items-center justify-center gap-2">
        <i class="fa-solid fa-right-from-bracket"></i> Logout
      </a>
    </div>
  </div>
</div>

<script>
  const adminTabs = [
    { name: 'Dashboard', link: 'dashboard.jsp', icon: 'fa-chart-pie' },
    { name: 'Inventory', link: 'inventory.jsp', icon: 'fa-boxes-stacked' },
    { name: 'Appointments', link: 'manage_appointments.jsp', icon: 'fa-calendar-check' },
    { name: 'Services', link: 'manage_services.jsp', icon: 'fa-screwdriver-wrench' },
    { name: 'Billing', link: 'billing_dashboard.jsp', icon: 'fa-file-invoice-dollar' },
    { name: 'Users', link: 'manage_users.jsp', icon: 'fa-users' },
    { name: 'Vehicles', link: 'manage_vehicles.jsp', icon: 'fa-car' },
    { name: 'Reviews', link: 'reviews.jsp', icon: 'fa-star' }
  ];

  const desktopMenu = document.getElementById('desktop-menu');
  const mobileMenuList = document.getElementById('mobile-menu-list');
  const currentPage = window.location.pathname.split('/').pop() || 'dashboard.jsp';

  function createAdminTabs() {
    desktopMenu.innerHTML = '';
    mobileMenuList.innerHTML = '';

    adminTabs.forEach(tab => {
      const isActive = currentPage === tab.link;
      
      // Desktop Node
      const dTab = document.createElement('a');
      dTab.href = tab.link;
      dTab.className = isActive 
        ? 'active-tab px-4 py-2.5 rounded-[1.25rem] text-[9px] font-black uppercase tracking-widest flex items-center gap-2.5 transition-all' 
        : 'nav-link hover:text-indigo-600 dark:hover:text-indigo-400 hover:bg-slate-50 dark:hover:bg-slate-900/50 px-4 py-2.5 rounded-[1.25rem] text-[9px] font-black uppercase tracking-widest flex items-center gap-2.5 transition-all';
      dTab.innerHTML = `<i class="fa-solid ${tab.icon} text-[10px]"></i>` + tab.name;
      desktopMenu.appendChild(dTab);

      // Mobile Node
      const mTab = document.createElement('a');
      mTab.href = tab.link;
      mTab.className = isActive 
        ? 'bg-indigo-600 text-white px-6 py-4 rounded-2xl text-xs font-black uppercase tracking-widest flex items-center gap-4 shadow-xl shadow-indigo-100 dark:shadow-none' 
        : 'text-slate-500 dark:text-slate-400 px-6 py-4 rounded-2xl text-xs font-black uppercase tracking-widest flex items-center gap-4 hover:bg-slate-50 dark:hover:bg-slate-900 transition-colors';
      mTab.innerHTML = `<i class="fa-solid ${tab.icon} w-6 text-sm"></i>` + tab.name;
      mobileMenuList.appendChild(mTab);
    });
  }

  createAdminTabs();
  const btn = document.getElementById('mobile-menu-btn');
  const closeBtn = document.getElementById('close-mobile-btn');
  const mobileMenu = document.getElementById('mobile-menu');
  const mobileBackdrop = document.getElementById('mobile-menu-backdrop');
  const mobilePanel = document.getElementById('mobile-menu-panel');

  function openMobileMenu() {
    mobileMenu.classList.remove('hidden');
    setTimeout(() => {
      mobileBackdrop.style.opacity = '1';
      mobilePanel.style.transform = 'translateX(0)';
    }, 10);
  }

  function closeMobileMenu() {
    mobileBackdrop.style.opacity = '0';
    mobilePanel.style.transform = 'translateX(-100%)';
    setTimeout(() => mobileMenu.classList.add('hidden'), 500);
  }

  if (btn) btn.addEventListener('click', openMobileMenu);
  if (closeBtn) closeBtn.addEventListener('click', closeMobileMenu);
  if (mobileBackdrop) mobileBackdrop.addEventListener('click', closeMobileMenu);
  
  function confirmLogout(e) {
    if(!confirm("Are you sure you want to logout?")) e.preventDefault();
  }
</script>
<%@ include file="logout_script.jsp" %>