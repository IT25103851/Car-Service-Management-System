<%
  String tsRole = (String) session.getAttribute("userRole");
  String tsUsername = (String) session.getAttribute("username");
  if (tsUsername == null) tsUsername = (String) session.getAttribute("loggedInUser"); // fallback for some admin pages
  String themeKey = "theme";
  if (tsUsername != null) {
      themeKey = "theme_" + tsRole + "_" + tsUsername;
  }
%>
<script>
  const THEME_KEY = '<%= themeKey %>';

  // Robust Tailwind Configuration for Dark Mode
  (function() {
    const configTailwind = () => {
      if (window.tailwind) {
        tailwind.config = {
          darkMode: 'class',
          theme: {
            extend: {
              colors: {
                indigo: { 50: '#f5f7ff', 100: '#ebf0fe', 200: '#dae3fd', 300: '#bbccfb', 400: '#94acf7', 500: '#6366f1', 600: '#4f46e5', 700: '#4338ca', 800: '#3730a3', 900: '#312e81', 950: '#1e1b4b' },
                slate: { 950: '#020617' }
              }
            }
          }
        };
      } else {
        setTimeout(configTailwind, 10);
      }
    };
    configTailwind();
  })();

  // Initialize theme from localStorage
  (function() {
    const theme = localStorage.getItem(THEME_KEY) || 'light';
    if (theme === 'dark') {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  })();

  function toggleTheme() {
    const html = document.documentElement;
    const isDark = html.classList.contains('dark');
    if (isDark) {
      html.classList.remove('dark');
      localStorage.setItem(THEME_KEY, 'light');
    } else {
      html.classList.add('dark');
      localStorage.setItem(THEME_KEY, 'dark');
    }
  }
</script>
<style>
  /* Root Transitions */
  html { transition: background-color 0.4s ease, color 0.4s ease; scroll-behavior: smooth; }
  
  /* Modern Scrollbar */
  ::-webkit-scrollbar { width: 8px; height: 8px; }
  ::-webkit-scrollbar-track { background: transparent; }
  ::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 10px; }
  .dark ::-webkit-scrollbar-thumb { background: #334155; }
  ::-webkit-scrollbar-thumb:hover { background: #94a3b8; }

  /* Navbar Glassmorphism */
  .nav-glass {
    background: rgba(255, 255, 255, 0.8) !important;
    backdrop-filter: blur(20px) saturate(180%) !important;
    -webkit-backdrop-filter: blur(20px) saturate(180%) !important;
    border-bottom: 1px solid rgba(0, 0, 0, 0.1) !important;
  }
  .dark .nav-glass {
    background: rgba(2, 6, 23, 0.8) !important;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1) !important;
  }

  /* Branding & Logo Fixes */
  .branding-text { 
    color: #1e293b !important; 
    transition: color 0.3s ease;
  }
  .dark .branding-text { 
    color: #f8fafc !important; 
  }
  
  /* Navbar Link Visibility */
  .nav-link {
    color: #64748b !important; /* slate-500 */
    transition: all 0.3s ease;
  }
  .dark .nav-link {
    color: #94a3b8 !important; /* slate-400 */
  }
  .nav-link:hover { color: #4f46e5 !important; }
  .dark .nav-link:hover { color: #818cf8 !important; }

  /* Active Tab Parity */
  .active-tab {
    background-color: #4f46e5 !important;
    color: #ffffff !important;
    box-shadow: 0 10px 20px -5px rgba(79, 70, 229, 0.4) !important;
  }
  .dark .active-tab {
    background-color: rgba(79, 70, 229, 0.2) !important;
    color: #818cf8 !important; 
    border: 1px solid rgba(79, 70, 229, 0.4) !important;
    box-shadow: 0 0 20px rgba(79, 70, 229, 0.1) !important;
  }

  /* Theme Toggle Icons */
  .dark .show-light { display: none !important; }
  .show-dark { display: none !important; }
  .dark .show-dark { display: inline-block !important; }

  /* Fix for visible text in light mode - removed aggressive h1-h4 override */
  body:not(.dark) .text-contrast-fix {
    color: #0f172a !important;
  }
  
  /* Removed aggressive dark mode text overrides to allow native Tailwind styling */
  
  /* Fix for borders in dark mode */
  .dark .border-slate-100, .dark .border-slate-200 { border-color: #1e293b !important; }
  
  /* Inputs visibility - removed aggressive !important background to allow Tailwind overrides */
  .dark input, .dark select, .dark textarea {
    border-color: #334155 !important;
    color: #ffffff !important;
  }
  .dark input::placeholder, .dark textarea::placeholder {
    color: #475569 !important;
  }

  /* Fix 1: Placeholder text — slate-200 is invisible on slate-50 bg */
  body:not(.dark) input::placeholder,
  body:not(.dark) textarea::placeholder,
  body:not(.dark) select::placeholder {
      color: #94a3b8 !important;  /* slate-400 — clearly visible */
  }

  /* Fix 2: Input borders in light mode — transparent borders make inputs blend in */
  body:not(.dark) input,
  body:not(.dark) select,
  body:not(.dark) textarea {
      border-color: #e2e8f0 !important;  /* slate-200 — subtle but visible */
  }
</style>
