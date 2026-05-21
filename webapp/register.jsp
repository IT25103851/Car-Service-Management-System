<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String role = (String) session.getAttribute("userRole");
    boolean isAdmin = "admin".equals(role);
    if (!isAdmin) { response.sendRedirect("login.jsp"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create User Account - SwiftDrive</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;700&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Plus Jakarta Sans', sans-serif; }
        .mono { font-family: 'JetBrains Mono', monospace; }
        .brand-panel { background: #020617; position: relative; overflow: hidden; }
        .brand-panel::before {
            content: ''; position: absolute; inset: 0;
            background: radial-gradient(circle at 20% 30%, rgba(99, 102, 241, 0.1) 0%, transparent 50%),
                        radial-gradient(circle at 80% 70%, rgba(79, 70, 229, 0.08) 0%, transparent 50%);
            pointer-events: none;
        }
        .strength-bar { height: 8px; border-radius: 100px; background: rgba(0,0,0,0.05); overflow: hidden; }
        .dark .strength-bar { background: rgba(255,255,255,0.05); }
        .strength-fill { height: 100%; border-radius: 100px; transition: width 0.4s, background 0.4s; }
        @keyframes slideUp { from{opacity:0;transform:translateY(20px)} to{opacity:1;transform:translateY(0)} }
        .animate-slide-up { animation: slideUp 0.6s cubic-bezier(0.4, 0, 0.2, 1) forwards; }
    </style>
</head>
<body class="h-screen overflow-hidden text-slate-900 dark:text-slate-100 bg-slate-50 dark:bg-slate-950 transition-colors duration-300">
<%@ include file="theme_script.jsp" %>

<div class="flex h-screen">
    <!-- LEFT: BRAND PANEL -->
    <div class="brand-panel hidden lg:flex lg:w-1/2 flex-col justify-center items-center px-16 relative">
        <div class="max-w-md relative z-10 text-center lg:text-left">
            <div class="mb-16">
                <div class="flex items-center justify-center lg:justify-start gap-4 mb-6">
                    <div class="w-16 h-16 rounded-[1.5rem] bg-indigo-600 border border-indigo-500/20 flex items-center justify-center shadow-2xl">
                        <i class="fa-solid fa-car-side text-white text-2xl"></i>
                    </div>
                    <h1 class="text-5xl font-black text-white tracking-tighter">SwiftDrive</h1>
                </div>
                <p class="text-indigo-300/40 text-[10px] font-black uppercase tracking-[0.4em] ml-2">User Registration System</p>
            </div>

            <div class="space-y-8">
                <div class="flex items-center gap-8 group">
                    <div class="w-14 h-14 rounded-2xl bg-white/5 border border-white/5 flex items-center justify-center flex-shrink-0 group-hover:scale-110 transition-transform shadow-2xl">
                        <i class="fa-solid fa-id-card text-indigo-400 text-xl"></i>
                    </div>
                    <div>
                        <p class="text-white font-black text-lg tracking-tight">User Account</p>
                        <p class="text-slate-500 text-xs mt-1 font-medium leading-relaxed">Manage user access and credentials in one place.</p>
                    </div>
                </div>
                <div class="flex items-center gap-8 group">
                    <div class="w-14 h-14 rounded-2xl bg-white/5 border border-white/5 flex items-center justify-center flex-shrink-0 group-hover:scale-110 transition-transform shadow-2xl">
                        <i class="fa-solid fa-fingerprint text-emerald-400 text-xl"></i>
                    </div>
                    <div>
                        <p class="text-white font-black text-lg tracking-tight">User Permissions</p>
                        <p class="text-slate-500 text-xs mt-1 font-medium leading-relaxed">Define what each user can see and do within the system.</p>
                    </div>
                </div>
            </div>

            <div class="mt-24 border-t border-white/10 pt-8">
                <p class="text-slate-600 text-[10px] font-black uppercase tracking-[0.3em]">&copy; 2026 SwiftDrive Systems Engineering</p>
            </div>
        </div>
    </div>

    <!-- RIGHT: REGISTER FORM -->
    <div class="w-full lg:w-1/2 bg-white dark:bg-slate-950 flex flex-col justify-center items-center px-8 relative overflow-y-auto no-scrollbar transition-colors duration-300">
        <!-- Theme Toggle -->
        <button onclick="toggleTheme()" class="absolute top-10 right-10 w-12 h-12 rounded-2xl bg-slate-50 dark:bg-slate-900 border border-slate-100 dark:border-slate-800 text-slate-400 dark:text-slate-600 hover:text-indigo-600 dark:hover:text-indigo-400 flex items-center justify-center transition-all shadow-sm active:scale-90 z-50">
            <i class="fa-solid fa-moon show-light text-lg"></i>
            <i class="fa-solid fa-sun show-dark text-lg"></i>
        </button>

        <div class="w-full max-w-md py-20 animate-slide-up">
            <h2 class="text-5xl font-black text-slate-900 dark:text-white tracking-tighter mb-4">Register New User</h2>
            <p class="text-slate-500 dark:text-slate-400 text-lg font-medium mb-12">Fill in the details below to create a new account.</p>

            <% if ("exists".equals(request.getParameter("error"))) { %>
            <div class="bg-rose-50 dark:bg-rose-950/30 border border-rose-100 dark:border-rose-900/30 text-rose-600 dark:text-rose-400 px-6 py-5 rounded-[2rem] mb-10 flex items-center gap-4 text-[10px] font-black uppercase tracking-widest shadow-inner">
                <i class="fa-solid fa-circle-exclamation text-rose-500 text-lg"></i> Username already exists. Please choose another.
            </div>
            <% } %>

            <form action="RegisterServlet" method="POST" id="regForm" class="space-y-8" onsubmit="return validateRegister()">
                <div class="input-group">
                    <label class="block text-[10px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-[0.3em] mb-4">Full Name</label>
                    <div class="flex items-center bg-slate-50 dark:bg-slate-900 border-2 border-transparent dark:border-slate-800 rounded-[2rem] focus-within:border-indigo-600 focus-within:ring-8 focus-within:ring-indigo-500/10 transition-all px-8">
                        <i class="fa-regular fa-id-card text-slate-400 dark:text-slate-700"></i>
                        <input name="fullName" id="fullName" type="text" required placeholder="John Doe" class="w-full py-5 px-4 bg-transparent outline-none font-black text-slate-900 dark:text-white">
                    </div>
                </div>

                <div class="input-group">
                    <label class="block text-[10px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-[0.3em] mb-4">Username</label>
                    <div class="flex items-center bg-slate-50 dark:bg-slate-900 border-2 border-transparent dark:border-slate-800 rounded-[2rem] focus-within:border-indigo-600 focus-within:ring-8 focus-within:ring-indigo-500/10 transition-all px-8">
                        <i class="fa-regular fa-user text-slate-400 dark:text-slate-700"></i>
                        <input name="username" id="username" type="text" required minlength="4" placeholder="user_node" class="w-full py-5 px-4 bg-transparent outline-none font-black text-slate-900 dark:text-white">
                    </div>
                    <!-- Suggestions container -->
                    <div id="usernameSuggestions" class="mt-3 hidden pl-4">
                        <span class="text-[9px] font-black text-slate-450 dark:text-slate-650 uppercase tracking-widest block mb-2">Suggested Usernames (Click to use)</span>
                        <div class="flex flex-wrap gap-2" id="suggestionsContainer"></div>
                    </div>
                </div>

                <div class="input-group">
                    <label class="block text-[10px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-[0.3em] mb-4">Password</label>
                    <div class="flex items-center bg-slate-50 dark:bg-slate-900 border-2 border-transparent dark:border-slate-800 rounded-[2rem] focus-within:border-indigo-600 focus-within:ring-8 focus-within:ring-indigo-500/10 transition-all px-8">
                        <i class="fa-solid fa-lock text-slate-400 dark:text-slate-700"></i>
                        <input id="regPwd" name="password" type="password" required minlength="8" placeholder="••••••••••••" class="w-full py-5 px-4 bg-transparent outline-none font-black text-slate-900 dark:text-white" oninput="checkStrength(this.value); checkMatch()">
                        <button type="button" onclick="togglePwd('regPwd', this)" class="text-slate-400 hover:text-indigo-500 transition-colors"><i class="fa-regular fa-eye"></i></button>
                    </div>
                    <div class="mt-4">
                        <div class="strength-bar"><div class="strength-fill" id="strengthFill" style="width:0%"></div></div>
                        <p class="text-[9px] font-black mt-2 uppercase tracking-widest" id="strengthLabel"><span class="text-slate-400 dark:text-slate-700">Waiting for input...</span></p>
                    </div>
                </div>

                <div class="input-group">
                    <label class="block text-[10px] font-black text-slate-400 dark:text-slate-600 uppercase tracking-[0.3em] mb-4">Confirm Password</label>
                    <div class="flex items-center bg-slate-50 dark:bg-slate-900 border-2 border-transparent dark:border-slate-800 rounded-[2rem] focus-within:border-indigo-600 focus-within:ring-8 focus-within:ring-indigo-500/10 transition-all px-8">
                        <i class="fa-solid fa-check-double text-slate-400 dark:text-slate-700"></i>
                        <input id="regPwdConfirm" type="password" required placeholder="••••••••••••" class="w-full py-5 px-4 bg-transparent outline-none font-black text-slate-900 dark:text-white" oninput="checkMatch()">
                        <span id="matchIcon" class="hidden"></span>
                    </div>
                    <p class="text-[9px] font-black mt-2 uppercase tracking-widest" id="matchLabel"></p>
                </div>

                <div class="bg-slate-50 dark:bg-slate-900/60 border border-slate-100 dark:border-slate-800 rounded-[2rem] p-6 group transition-all">
                    <label class="flex items-center gap-4 cursor-pointer">
                        <div class="relative flex items-center justify-center">
                            <input type="checkbox" id="adminToggle" class="peer appearance-none w-7 h-7 bg-white dark:bg-slate-800 border-2 border-slate-200 dark:border-slate-700 rounded-xl checked:bg-indigo-600 checked:border-indigo-600 transition-all" onchange="updateRole()">
                            <i class="fa-solid fa-check absolute text-white text-[10px] opacity-0 peer-checked:opacity-100 transition-opacity"></i>
                        </div>
                        <div class="flex items-center gap-3">
                            <i class="fa-solid fa-user-shield text-slate-400 dark:text-slate-700 text-lg"></i>
                            <span class="text-sm font-black text-slate-800 dark:text-white">Admin Access</span>
                        </div>
                    </label>
                    <p class="text-[10px] font-medium text-slate-400 dark:text-slate-500 mt-2 ml-11">Grant full administrative access to all system features.</p>
                </div>
                <input type="hidden" name="role" id="roleInput" value="customer">

                <button type="submit" class="w-full py-6 bg-slate-900 dark:bg-white text-white dark:text-slate-950 font-black text-[10px] uppercase tracking-[0.2em] rounded-[2.5rem] shadow-2xl transition-all active:scale-95 flex items-center justify-center gap-4">
                    <i class="fa-solid fa-user-plus text-lg"></i> Register User
                </button>

                <div class="text-center pt-4">
                    <a href="manage_users.jsp" class="text-[10px] font-black text-slate-400 dark:text-slate-600 hover:text-indigo-600 dark:hover:text-white uppercase tracking-widest flex items-center justify-center gap-3 transition-all"><i class="fa-solid fa-arrow-left"></i> Cancel</a>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
let userUsernameEdited = false;

function togglePwd(id, btn) {
    const input = document.getElementById(id);
    const icon = btn.querySelector('i');
    if (input.type === 'password') { input.type = 'text'; icon.className = 'fa-regular fa-eye-slash'; }
    else { input.type = 'password'; icon.className = 'fa-regular fa-eye'; }
}

function generateUsernames(fullName) {
    if (!fullName || fullName.trim().length === 0) return [];
    const clean = fullName.toLowerCase().replace(/[^a-z0-9\s]/g, '').trim();
    const parts = clean.split(/\s+/).filter(p => p.length > 0);
    if (parts.length === 0) return [];
    
    const suggestions = [];
    const first = parts[0];
    const last = parts.length > 1 ? parts[parts.length - 1] : "";
    const rand1 = Math.floor(100 + Math.random() * 900);
    const rand2 = Math.floor(10 + Math.random() * 90);
    
    if (last) {
        suggestions.push(`${first}${last}`);
        suggestions.push(`${first}.${last}`);
        suggestions.push(`${first.charAt(0)}${last}${rand2}`);
    } else {
        suggestions.push(`${first}${rand1}`);
        suggestions.push(`${first}_${rand2}`);
        suggestions.push(`iam${first}`);
    }
    
    while (suggestions.length < 3) {
        suggestions.push(`${first}${Math.floor(1000 + Math.random() * 9000)}`);
    }
    return [...new Set(suggestions)].slice(0, 3);
}

function checkStrength(pwd) {
    const fill = document.getElementById('strengthFill');
    const label = document.getElementById('strengthLabel');
    let score = 0;
    
    const hasLetter = /[a-zA-Z]/.test(pwd);
    const hasNumber = /[0-9]/.test(pwd);
    const hasSymbol = /[^a-zA-Z0-9]/.test(pwd);
    
    if (pwd.length >= 8) score++;
    if (hasLetter) score++;
    if (hasNumber) score++;
    if (hasSymbol) score++;

    if (pwd.length === 0) { 
        fill.style.width = '0%'; 
        label.innerHTML = '<span class="text-slate-400 dark:text-slate-700">Waiting for input...</span>'; 
        return; 
    }
    
    if (!hasLetter || !hasNumber || !hasSymbol) {
        fill.style.width = '50%'; 
        fill.style.background = '#F43F5E'; 
        label.innerHTML = '<span class="text-rose-500">Requires letters, numbers & symbols</span>';
    } else if (score < 4 || pwd.length < 8) {
        fill.style.width = '75%'; 
        fill.style.background = '#F59E0B'; 
        label.innerHTML = '<span class="text-amber-500">Medium (Short password)</span>';
    } else {
        fill.style.width = '100%'; 
        fill.style.background = '#10B981'; 
        label.innerHTML = '<span class="text-emerald-500">Strong Password</span>';
    }
}

function checkMatch() {
    const pwd = document.getElementById('regPwd').value;
    const confirm = document.getElementById('regPwdConfirm').value;
    const icon = document.getElementById('matchIcon');
    const label = document.getElementById('matchLabel');
    if (confirm.length === 0) { icon.classList.add('hidden'); label.innerHTML = ''; return; }
    icon.classList.remove('hidden');
    if (pwd === confirm) {
        icon.innerHTML = '<i class="fa-solid fa-circle-check text-emerald-500 ml-2"></i>';
        label.innerHTML = '<span class="text-emerald-500">Passwords match</span>';
    } else {
        icon.innerHTML = '<i class="fa-solid fa-circle-xmark text-rose-500 ml-2"></i>';
        label.innerHTML = '<span class="text-rose-500">Passwords do not match</span>';
    }
}

function updateRole() {
    document.getElementById('roleInput').value = document.getElementById('adminToggle').checked ? 'admin' : 'customer';
}

function validateRegister() {
    const pwd = document.getElementById('regPwd').value;
    const confirm = document.getElementById('regPwdConfirm').value;
    if (pwd !== confirm) return false;
    
    const hasLetter = /[a-zA-Z]/.test(pwd);
    const hasNumber = /[0-9]/.test(pwd);
    const hasSymbol = /[^a-zA-Z0-9]/.test(pwd);
    
    if (pwd.length < 8) {
        alert("Password must be at least 8 characters long.");
        return false;
    }
    
    if (!hasLetter || !hasNumber || !hasSymbol) {
        alert("Password must contain letters, numbers, and symbols.");
        return false;
    }
    return true;
}

document.addEventListener("DOMContentLoaded", () => {
    const usernameEl = document.getElementById('username');
    if (usernameEl) {
        usernameEl.addEventListener('input', () => {
            userUsernameEdited = true;
        });
    }

    const fullNameEl = document.getElementById('fullName');
    if (fullNameEl) {
        fullNameEl.addEventListener('input', function() {
            const nameVal = this.value;
            const suggestions = generateUsernames(nameVal);
            const container = document.getElementById('suggestionsContainer');
            const wrapper = document.getElementById('usernameSuggestions');
            
            if (suggestions.length > 0) {
                wrapper.classList.remove('hidden');
                container.innerHTML = '';
                suggestions.forEach(s => {
                    const btn = document.createElement('button');
                    btn.type = 'button';
                    btn.className = 'px-3 py-1.5 bg-slate-100 dark:bg-slate-900 text-indigo-600 dark:text-indigo-400 hover:bg-slate-200 dark:hover:bg-slate-800 rounded-lg text-xs font-black transition-all';
                    btn.textContent = s;
                    btn.onclick = () => {
                        document.getElementById('username').value = s;
                    };
                    container.appendChild(btn);
                });
                
                if (!userUsernameEdited) {
                    document.getElementById('username').value = suggestions[0];
                }
            } else {
                wrapper.classList.add('hidden');
            }
        });
    }
});
</script>
</body>
</html>
