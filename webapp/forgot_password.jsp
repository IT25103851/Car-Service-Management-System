<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.AbstractUser" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Identity Recovery - SwiftDrive</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Plus Jakarta Sans', sans-serif; }
        .mesh-gradient {
            background-color: #0f172a;
            background-image: 
                radial-gradient(at 0% 0%, rgba(99, 102, 241, 0.15) 0px, transparent 50%),
                radial-gradient(at 100% 0%, rgba(139, 92, 246, 0.1) 0px, transparent 50%),
                radial-gradient(at 100% 100%, rgba(20, 184, 166, 0.1) 0px, transparent 50%),
                radial-gradient(at 0% 100%, rgba(244, 63, 94, 0.1) 0px, transparent 50%);
        }
        .glass-card {
            background: rgba(255, 255, 255, 0.03);
            backdrop-filter: blur(25px) saturate(180%);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
    </style>
</head>
<body class="mesh-gradient min-h-screen flex items-center justify-center p-6 overflow-x-hidden">
    
    <%
        String step = (String) request.getAttribute("step");
        if (step == null) step = "1";
        AbstractUser user = (AbstractUser) request.getAttribute("user");
    %>

    <div class="relative w-full max-w-md animate-slide-up">
        <!-- TOP ICON OVERLAY -->
        <div class="absolute -top-12 left-1/2 -translate-x-1/2 z-20">
            <div class="w-24 h-24 rounded-full bg-[#020617] border-4 border-[#1e293b] flex items-center justify-center shadow-2xl">
                <i class="fa-solid fa-user-shield text-indigo-400 text-3xl"></i>
            </div>
        </div>

        <div class="glass-card rounded-[2.5rem] pt-16 pb-12 px-10 shadow-2xl relative overflow-hidden">
            <div class="text-center mb-10">
                <h1 class="text-2xl font-black text-white tracking-tight">Identity Recovery</h1>
                <p class="text-slate-400 text-[10px] mt-2 font-black uppercase tracking-[0.3em]">Step <%= step %> of 2: <%= step.equals("1") ? "Locate Account" : "Verify Answer" %></p>
            </div>

            <form action="ForgotPasswordServlet" method="POST" class="space-y-6">
                <input type="hidden" name="step" value="<%= step %>">
                
                <% if (step.equals("1")) { %>
                    <!-- STEP 1: ENTER USERNAME -->
                    <div class="space-y-2">
                        <label class="block text-[10px] font-bold text-slate-500 uppercase tracking-widest ml-1">Account Identifier</label>
                        <div class="flex items-center bg-[#1e293b]/50 border border-white/5 rounded-2xl p-1 focus-within:border-indigo-500/50 transition-all">
                            <div class="w-11 h-11 rounded-xl bg-[#020617] flex items-center justify-center text-slate-500">
                                <i class="fa-solid fa-user-tag text-xs"></i>
                            </div>
                            <input name="username" type="text" required placeholder="Enter Username" class="flex-1 bg-transparent border-none outline-none px-4 text-white placeholder:text-slate-600 text-sm font-medium">
                        </div>
                    </div>
                    <button type="submit" class="w-full py-5 bg-indigo-600 text-white font-black text-xs uppercase tracking-[0.2em] rounded-2xl shadow-xl hover:bg-indigo-700 active:scale-95 transition-all mt-4">
                        Continue to Verification
                    </button>
                <% } else if (step.equals("2") && user != null) { %>
                    <!-- STEP 2: SECURITY QUESTION -->
                    <input type="hidden" name="username" value="<%= user.getUsername() %>">
                    
                    <div class="space-y-4">
                        <div class="p-5 rounded-2xl bg-indigo-500/5 border border-indigo-500/10">
                            <p class="text-[10px] font-black text-indigo-400 uppercase tracking-widest mb-2">Security Question</p>
                            <p class="text-white text-sm font-semibold italic">"<%= user.getSecurityQuestion() %>"</p>
                        </div>

                        <div class="space-y-2">
                            <label class="block text-[10px] font-bold text-slate-500 uppercase tracking-widest ml-1">Your Answer</label>
                            <div class="flex items-center bg-[#1e293b]/50 border border-white/5 rounded-2xl p-1 focus-within:border-indigo-500/50 transition-all">
                                <div class="w-11 h-11 rounded-xl bg-[#020617] flex items-center justify-center text-slate-500">
                                    <i class="fa-solid fa-comment-dots text-xs"></i>
                                </div>
                                <input name="securityAnswer" type="text" required placeholder="Type your answer..." class="flex-1 bg-transparent border-none outline-none px-4 text-white placeholder:text-slate-600 text-sm font-medium">
                            </div>
                        </div>

                        <div class="space-y-2">
                            <label class="block text-[10px] font-bold text-slate-500 uppercase tracking-widest ml-1">New Password</label>
                            <div class="flex items-center bg-[#1e293b]/50 border border-white/5 rounded-2xl p-1 focus-within:border-indigo-500/50 transition-all">
                                <div class="w-11 h-11 rounded-xl bg-[#020617] flex items-center justify-center text-slate-500">
                                    <i class="fa-solid fa-lock text-xs"></i>
                                </div>
                                <input id="newPassword" name="newPassword" type="password" required placeholder="Enter New Password" class="flex-1 bg-transparent border-none outline-none px-4 text-white placeholder:text-slate-600 text-sm font-medium">
                                <button type="button" onclick="togglePassword()" class="w-11 h-11 flex items-center justify-center text-slate-500 hover:text-indigo-400 transition-colors mr-1">
                                    <i id="toggleIcon" class="fa-solid fa-eye text-xs"></i>
                                </button>
                            </div>
                        </div>
                    </div>

                    <button type="submit" class="w-full py-5 bg-white text-slate-900 font-black text-xs uppercase tracking-[0.2em] rounded-2xl shadow-xl hover:bg-slate-100 active:scale-95 transition-all mt-4">
                        Reset Credential
                    </button>
                <% } %>
            </form>

            <div class="mt-10 text-center">
                <a href="login.jsp" class="text-[10px] font-black text-slate-500 hover:text-indigo-400 uppercase tracking-widest transition-colors flex items-center justify-center gap-2">
                    <i class="fa-solid fa-arrow-left"></i> Return to Login
                </a>
            </div>
        </div>
    </div>

    <%@ include file="toast.jsp" %>
    <script>
    function togglePassword() {
        const passwordInput = document.getElementById("newPassword");
        const toggleIcon = document.getElementById("toggleIcon");
        if (passwordInput) {
            if (passwordInput.type === "password") {
                passwordInput.type = "text";
                toggleIcon.classList.remove("fa-eye");
                toggleIcon.classList.add("fa-eye-slash");
            } else {
                passwordInput.type = "password";
                toggleIcon.classList.remove("fa-eye-slash");
                toggleIcon.classList.add("fa-eye");
            }
        }
    }

    document.addEventListener("DOMContentLoaded", () => {
        const params = new URLSearchParams(window.location.search);
        if (params.get("error") === "notfound") showToast("Identity not recognized in sector.", "error");
        if (params.get("error") === "wronganswer") showToast("Verification failed. Incorrect answer.", "error");
    });
    </script>
</body>
</html>
