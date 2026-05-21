<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
function confirmLogout(event) {
    event.preventDefault();
    const targetUrl = event.currentTarget.href;
    const isDark = document.documentElement.classList.contains('dark');
    
    Swal.fire({
      title: '<span class="font-black tracking-tight">Sign Out?</span>',
      text: "Are you sure you want to securely log out of SwiftDrive?",
      icon: 'question',
      iconColor: isDark ? '#818cf8' : '#4f46e5',
      showCancelButton: true,
      confirmButtonText: 'Yes, Sign Out',
      cancelButtonText: 'Cancel',
      reverseButtons: true,
      background: isDark ? '#1e293b' : '#ffffff',
      color: isDark ? '#f1f5f9' : '#1e293b',
      confirmButtonColor: '#ef4444',
      cancelButtonColor: isDark ? '#334155' : '#94a3b8',
      customClass: {
        popup: 'rounded-3xl border border-slate-200 dark:border-slate-700 shadow-2xl',
        title: 'text-2xl pt-4',
        htmlContainer: 'text-slate-500 dark:text-slate-400',
        confirmButton: 'rounded-xl px-6 py-3 font-bold',
        cancelButton: 'rounded-xl px-6 py-3 font-bold'
      }
    }).then((result) => {
      if (result.isConfirmed) {
        // Add a small delay for a smooth fade out
        Swal.fire({
          title: 'Logging out...',
          timer: 800,
          timerProgressBar: true,
          didOpen: () => { Swal.showLoading(); },
          background: isDark ? '#1e293b' : '#ffffff',
          color: isDark ? '#f1f5f9' : '#1e293b',
          showConfirmButton: false
        }).then(() => {
          window.location.href = targetUrl;
        });
      }
    });
}
</script>
