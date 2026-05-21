<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Gateway - SwiftDrive</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap"
            rel="stylesheet">
        <style>
            * {
                font-family: 'Plus Jakarta Sans', sans-serif;
            }

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
                -webkit-backdrop-filter: blur(25px) saturate(180%);
                border: 1px solid rgba(255, 255, 255, 0.1);
            }

            .login-btn {
                background: linear-gradient(135deg, rgba(255, 255, 255, 0.1) 0%, rgba(255, 255, 255, 0.05) 100%);
                border: 1px solid rgba(255, 255, 255, 0.1);
                transition: all 0.3s ease;
            }

            .login-btn:hover {
                background: rgba(255, 255, 255, 0.15);
                transform: translateY(-2px);
            }

            @keyframes slideUp {
                from {
                    opacity: 0;
                    transform: translateY(30px)
                }

                to {
                    opacity: 1;
                    transform: translateY(0)
                }
            }

            .animate-slide-up {
                animation: slideUp 0.8s cubic-bezier(0.16, 1, 0.3, 1) forwards;
            }

            /* Custom Checkbox */
            .custom-checkbox {
                appearance: none;
                width: 16px;
                height: 16px;
                border: 1px solid rgba(255, 255, 255, 0.2);
                border-radius: 4px;
                cursor: pointer;
                position: relative;
                background: rgba(0, 0, 0, 0.2);
            }

            .custom-checkbox:checked {
                background: #6366f1;
                border-color: #6366f1;
            }

            .custom-checkbox:checked::after {
                content: '\f00c';
                font-family: 'Font Awesome 6 Free';
                font-weight: 900;
                font-size: 10px;
                color: white;
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
            }
        </style>
    </head>

    <body class="mesh-gradient min-h-screen flex items-center justify-center p-6 overflow-y-auto">

        <!-- MAIN CONTAINER -->
        <div class="relative w-full max-w-md my-auto py-12 animate-slide-up">
            <!-- CIRCULAR USER ICON OVERLAY -->
            <div class="absolute -top-6 sm:-top-10 left-1/2 -translate-x-1/2 z-20">
                <div
                    class="w-20 h-20 sm:w-28 sm:h-28 rounded-full bg-[#020617] border-[4px] sm:border-[6px] border-[#1e293b] flex items-center justify-center shadow-2xl overflow-hidden group">
                    <i class="fa-regular fa-user text-white text-2xl sm:text-4xl relative z-10"></i>
                </div>
            </div>

            <!-- GLASS CARD -->
            <div
                class="glass-card rounded-[2.5rem] sm:rounded-[3rem] pt-16 sm:pt-24 pb-10 sm:pb-12 px-6 sm:px-10 shadow-2xl relative">

                <%-- Error/Success Handling (Pushing content naturally) --%>
                    <div class="min-h-[20px] sm:min-h-[40px]">
                        <% if ("invalid".equals(request.getParameter("error"))) { %>
                            <div class="flex justify-center mb-6 sm:mb-8">
                                <span
                                    class="text-[9px] sm:text-[10px] font-black text-rose-500 uppercase tracking-widest bg-rose-500/10 px-4 py-2 rounded-full border border-rose-500/20 shadow-lg shadow-rose-900/10 animate-pulse text-center">Access
                                    Denied: Verify Credentials</span>
                            </div>
                            <% } %>
                                <% if ("deactivated".equals(request.getParameter("error"))) { %>
                                    <div class="flex justify-center mb-6 sm:mb-8">
                                        <span
                                            class="text-[9px] sm:text-[10px] font-black text-rose-500 uppercase tracking-widest bg-rose-500/10 px-4 py-2 rounded-full border border-rose-500/20 shadow-lg shadow-rose-900/10 animate-pulse text-center">Account
                                            is deactivated.</span>
                                    </div>
                                    <% } %>
                                        <% if ("reset".equals(request.getParameter("success"))) { %>
                                            <div class="flex justify-center mb-6 sm:mb-8">
                                                <span
                                                    class="text-[9px] sm:text-[10px] font-black text-emerald-500 uppercase tracking-widest bg-emerald-500/10 px-4 py-2 rounded-full border border-emerald-500/20 shadow-lg shadow-emerald-900/10 text-center">Credential
                                                    Updated Successfully</span>
                                            </div>
                                            <% } %>
                    </div>

                    <form action="LoginServlet" method="POST" class="space-y-5 sm:space-y-6 mt-2">
                        <!-- USERNAME FIELD -->
                        <div class="relative group">
                            <div
                                class="flex items-center bg-[#1e293b]/60 border border-white/5 rounded-2xl p-1 focus-within:border-indigo-500/50 transition-all">
                                <div
                                    class="w-10 h-10 sm:w-12 sm:h-12 rounded-xl bg-[#020617] flex items-center justify-center text-slate-500 shadow-inner group-focus-within:text-indigo-400 transition-colors">
                                    <i class="fa-solid fa-user text-xs sm:text-sm"></i>
                                </div>
                                <input id="username" name="username" type="text" required
                                    placeholder="Email ID / Username"
                                    class="flex-1 bg-transparent border-none outline-none px-4 sm:px-5 text-white placeholder:text-slate-600 text-xs sm:text-sm font-medium">
                            </div>
                        </div>

                        <!-- PASSWORD FIELD -->
                        <div class="relative group">
                            <div
                                class="flex items-center bg-[#1e293b]/60 border border-white/5 rounded-2xl p-1 focus-within:border-indigo-500/50 transition-all">
                                <div
                                    class="w-10 h-10 sm:w-12 sm:h-12 rounded-xl bg-[#020617] flex items-center justify-center text-slate-500 shadow-inner group-focus-within:text-indigo-400 transition-colors">
                                    <i class="fa-solid fa-lock text-xs sm:text-sm"></i>
                                </div>
                                <input id="password" name="password" type="password" required
                                    placeholder="Security Password"
                                    class="flex-1 bg-transparent border-none outline-none px-4 sm:px-5 text-white placeholder:text-slate-600 text-xs sm:text-sm font-medium">
                                <button type="button" onclick="togglePassword()"
                                    class="w-10 h-10 sm:w-12 sm:h-12 flex items-center justify-center text-slate-500 hover:text-indigo-400 transition-colors mr-1">
                                    <i id="toggleIcon" class="fa-solid fa-eye text-xs sm:text-sm"></i>
                                </button>
                            </div>
                        </div>

                        <!-- OPTIONS ROW -->
                        <div class="flex items-center justify-between px-1 sm:px-2">
                            <label class="flex items-center gap-2 sm:gap-3 cursor-pointer group">
                                <input type="checkbox" name="remember" class="custom-checkbox">
                                <span
                                    class="text-[11px] sm:text-xs text-slate-400 group-hover:text-slate-300 transition-colors font-medium">Remember
                                    me</span>
                            </label>
                            <a href="forgot_password.jsp"
                                class="text-[11px] sm:text-xs text-slate-500 hover:text-indigo-400 italic transition-colors">Forgot
                                Password?</a>
                        </div>

                        <!-- LOGIN BUTTON -->
                        <button type="submit"
                            class="w-full py-4 sm:py-5 bg-white/5 login-btn text-white font-black text-[10px] sm:text-xs uppercase tracking-[0.25em] sm:tracking-[0.3em] rounded-2xl shadow-xl active:scale-95 mt-4">
                            LOGIN
                        </button>
                    </form>

                    <div class="mt-8 sm:mt-12 text-center">
                        <a href="index.jsp"
                            class="text-[9px] sm:text-[10px] font-black text-slate-500 hover:text-indigo-400 uppercase tracking-[0.3em] sm:tracking-[0.4em] transition-all flex items-center justify-center gap-3">
                            <i class="fa-solid fa-house-chimney"></i> Return Home
                        </a>
                    </div>
            </div>
        </div>

        <%@ include file="toast.jsp" %>
            <script>
                function togglePassword() {
                    const passwordInput = document.getElementById("password");
                    const toggleIcon = document.getElementById("toggleIcon");
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

                document.addEventListener("DOMContentLoaded", () => {
                    // COOKIE HELPER
                    function getCookie(name) {
                        let matches = document.cookie.match(new RegExp("(?:^|; )" + name.replace(/([\.$?*|{}\(\)\[\]\\\/\+^])/g, '\\$1') + "=([^;]*)"));
                        return matches ? decodeURIComponent(matches[1]) : undefined;
                    }

                    // AUTO-FILL REMEMBERED USER
                    const rememberedUser = getCookie("remembered_user");
                    if (rememberedUser) {
                        document.getElementById("username").value = rememberedUser;
                        document.querySelector(".custom-checkbox").checked = true;
                    }

                    const params = new URLSearchParams(window.location.search);
                    if (params.get("success") === "logout") showToast("Session ended securely.", "success");
                });
            </script>
    </body>

    </html>