<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
<div id="toast-container" class="fixed top-10 right-10 z-[250] flex flex-col gap-4 pointer-events-none"></div>

<script>
    function showToast(message, type) {
        if (!type) type = 'success';
        var container = document.getElementById('toast-container');
        
        var toast = document.createElement('div');
        
        var config = {
            success: { bg: 'bg-emerald-600', icon: 'fa-circle-check', title: 'Success!' },
            error: { bg: 'bg-rose-600', icon: 'fa-circle-exclamation', title: 'Error!' },
            warning: { bg: 'bg-amber-500', icon: 'fa-triangle-exclamation', title: 'Warning' },
            info: { bg: 'bg-blue-600', icon: 'fa-circle-info', title: 'Information' }
        };

        var current = config[type] || config.success;
        
        toast.className = "flex items-start w-80 shadow-[0_20px_50px_rgba(0,0,0,0.2)] rounded-2xl p-4 transition-all duration-700 cubic-bezier(0.34, 1.56, 0.64, 1) transform translate-x-[120%] " + current.bg + " text-white pointer-events-auto border border-white/10";
        
        toast.innerHTML = 
            '<div class="flex-shrink-0 text-xl mt-0.5"><i class="fa-solid ' + current.icon + '"></i></div>' +
            '<div class="ml-3 w-0 flex-1 relative">' +
                '<p class="font-black text-xs uppercase tracking-widest leading-tight opacity-70">' + current.title + '</p>' +
                '<p class="text-sm font-bold mt-1 text-white leading-snug">' + message + '</p>' +
            '</div>' +
            '<button onclick="this.parentElement.remove()" class="ml-4 flex-shrink-0 text-white/50 hover:text-white transition-colors">' +
                '<i class="fa-solid fa-xmark"></i>' +
            '</button>';
        
        container.appendChild(toast);
        
        setTimeout(function() { toast.classList.remove('translate-x-[120%]'); }, 50);
        
        setTimeout(function() {
            if (toast.parentElement) {
                toast.classList.add('translate-x-[120%]');
                setTimeout(function() { toast.remove(); }, 500);
            }
        }, 4000);
    }
</script>
