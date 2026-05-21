<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SwiftDrive - Premium Vehicle Service Tracker</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;700&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Plus Jakarta Sans', sans-serif; }
        .mono { font-family: 'JetBrains Mono', monospace; }
        
        .hero-gradient {
            background: radial-gradient(circle at 50% 50%, rgba(99, 102, 241, 0.1) 0%, transparent 50%);
        }
        
        .glass-panel {
            background: rgba(255, 255, 255, 0.02);
            backdrop-filter: blur(10px) saturate(180%);
            -webkit-backdrop-filter: blur(10px) saturate(180%);
            border: 1px solid rgba(255, 255, 255, 0.05);
        }
        
        .nav-btn { transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1); }
        .nav-btn:hover { transform: translateY(-4px); box-shadow: 0 20px 40px -10px rgba(99, 102, 241, 0.3); }
        
        @keyframes scanline {
            0% { transform: translateY(-100%); }
            100% { transform: translateY(100%); }
        }
        .scanline::after {
            content: ''; position: absolute; inset: 0;
            background: linear-gradient(to bottom, transparent 0%, rgba(99, 102, 241, 0.05) 50%, transparent 100%);
            animation: scanline 8s linear infinite;
            pointer-events: none;
        }
    </style>
</head>
<body class="relative h-screen h-[100dvh] flex flex-col justify-between items-center bg-slate-950 text-slate-100 overflow-hidden p-4 sm:p-8 md:p-12">
    
    <!-- CINEMATIC ATMOSPHERE -->
    <div class="fixed inset-0 z-0 overflow-hidden pointer-events-none scanline">
        <div class="absolute inset-0 bg-cover bg-center bg-no-repeat scale-110 opacity-40 mix-blend-overlay"
             style="background-image: url('https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?q=80&w=1983&auto=format&fit=crop');">
        </div>
        <div class="absolute inset-0 bg-slate-950/20"></div>
        <div class="absolute inset-0 hero-gradient"></div>
        
        <!-- Animated Particles/Lights -->
        <div class="absolute top-1/4 left-1/4 w-96 h-96 bg-indigo-600/10 rounded-full blur-[120px] animate-pulse"></div>
        <div class="absolute bottom-1/4 right-1/4 w-96 h-96 bg-blue-600/10 rounded-full blur-[120px] animate-pulse" style="animation-delay: 2s"></div>
    </div>

    <!-- MAIN PORTAL INTERFACE -->
    <div class="relative z-10 w-full max-w-5xl my-auto py-2">
        <div class="glass-panel rounded-[2rem] sm:rounded-[4rem] p-6 sm:p-12 md:p-16 lg:p-20 shadow-2xl text-center relative overflow-hidden group">
            <!-- Structural Accent -->
            <div class="absolute top-0 left-1/2 -translate-x-1/2 w-32 h-1 bg-indigo-600/50 rounded-b-full"></div>
            
            <div class="relative z-10">
                <!-- Branding Symbol -->
                <div class="flex items-center justify-center gap-4 mb-4 sm:mb-8">
                    <div class="w-12 h-12 sm:w-16 sm:h-16 rounded-xl sm:rounded-[1.5rem] bg-indigo-600/10 border border-indigo-500/20 flex items-center justify-center shadow-2xl group-hover:scale-110 transition-transform">
                        <i class="fa-solid fa-car-side text-indigo-400 text-xl sm:text-2xl"></i>
                    </div>
                </div>

                <!-- Primary Designation -->
                <h1 class="text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-black tracking-tighter leading-none mb-4 sm:mb-6">
                    <span class="bg-gradient-to-r from-white via-indigo-100 to-slate-500 bg-clip-text text-transparent">
                        SwiftDrive
                    </span>
                </h1>

                <!-- Operational Markers -->
                <div class="flex justify-center items-center gap-3 sm:gap-4 mb-4 sm:mb-6">
                    <span class="h-[1px] w-6 sm:w-10 bg-white/5"></span>
                    <p class="text-[8px] sm:text-[9px] font-black uppercase tracking-[0.25em] sm:tracking-[0.4em] text-indigo-400">
                        Modern Service Management
                    </p>
                    <span class="h-[1px] w-6 sm:w-10 bg-white/5"></span>
                </div>

                <!-- Value Proposition -->
                <p class="text-sm sm:text-lg md:text-xl text-slate-400 font-medium max-w-xl mx-auto leading-relaxed mb-6 sm:mb-10">
                    The ultimate platform for modern vehicle service management and customer care.
                </p>

                <!-- Action Matrix -->
                <div class="flex flex-col sm:flex-row items-center justify-center gap-3 sm:gap-4">
                    <a href="login.jsp" class="nav-btn group relative w-full sm:w-auto px-6 sm:px-10 py-4 sm:py-5 bg-indigo-600 text-white font-black rounded-xl sm:rounded-[1.5rem] shadow-2xl transition-all flex items-center justify-center gap-3 text-[9px] sm:text-[10px] uppercase tracking-[0.2em] overflow-hidden">
                        <div class="absolute inset-0 bg-white/10 opacity-0 group-hover:opacity-100 transition-opacity"></div>
                        <span class="relative z-10">Login</span>
                        <i class="fa-solid fa-arrow-right-long relative z-10 group-hover:translate-x-2 transition-transform"></i>
                    </a>
                </div>
            </div>
        </div>
    </div>

</body>
</html>