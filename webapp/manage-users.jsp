<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.UserManager, model.AbstractUser, java.util.List" %>
<%@ include file="navbar.jsp" %>

<%
    // SECURITY Bouncer: Only the Admin (Shop Boss) is allowed in this room!
    String role = (String) session.getAttribute("userRole");
    String loggedInUser = (String) session.getAttribute("loggedInUser");

    if (!"admin".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Users - SwiftDrive</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style> body { background: #f9fafc; } </style>
</head>
<body class="antialiased text-gray-900 pt-24">

<div class="max-w-7xl mx-auto py-10 px-4 sm:px-6 lg:px-8">

    <div class="mb-8 flex flex-col sm:flex-row justify-between items-start sm:items-center">
        <div>
            <h1 class="text-3xl font-extrabold text-indigo-900"><i class="fa-solid fa-users-gear mr-3"></i>User Management</h1>
            <p class="mt-2 text-sm text-gray-600">View and remove registered accounts from the system.</p>
        </div>
        <a href="register.jsp" class="mt-4 sm:mt-0 bg-indigo-600 hover:bg-indigo-700 text-white font-bold py-2.5 px-6 rounded-xl shadow-md transition-colors duration-200 flex items-center gap-2">
            <i class="fa-solid fa-user-plus"></i> Register New User
        </a>
    </div>

    <div class="bg-white shadow-xl rounded-2xl border border-gray-100 overflow-hidden overflow-x-auto w-full">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-indigo-50">
                <tr>
                    <th class="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase">Username</th>
                    <th class="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase">Account Badge</th>
                    <th class="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase">Security</th>
                    <th class="px-6 py-4 text-left text-xs font-bold text-gray-500 uppercase">Actions</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200 bg-white">
                <%
                    UserManager uManager = new UserManager();
                    List<AbstractUser> allUsers = uManager.getAllUsers();

                    for (AbstractUser u : allUsers) {
                %>
                        <tr class="hover:bg-gray-50">
                            <td class="px-6 py-4 whitespace-nowrap text-sm font-bold text-indigo-600">
                                <%= u.getUsername() %>
                                <% if (u.getUsername().equals(loggedInUser)) { %>
                                    <span class="ml-2 text-xs text-gray-400 font-normal">(You)</span>
                                <% } %>
                            </td>

                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-700">
                                <% if (u.getRole().equals("admin")) { %>
                                    <span class="bg-purple-100 text-purple-800 px-3 py-1 rounded-full text-xs font-bold"><i class="fa-solid fa-star mr-1"></i> Admin</span>
                                <% } else { %>
                                    <span class="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-xs font-bold"><i class="fa-solid fa-user mr-1"></i> Customer</span>
                                <% } %>
                            </td>

                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 font-mono">
                                *******
                            </td>

                            <td class="px-6 py-4 whitespace-nowrap text-sm">
                                <% if (!u.getUsername().equals(loggedInUser)) { %>
                                    <a href="DeleteUserServlet?username=<%= u.getUsername() %>"
                                       class="inline-flex items-center gap-2 bg-white border border-red-200 text-red-600 hover:bg-red-50 hover:border-red-300 hover:text-red-700 px-3 py-1.5 rounded-lg transition-all duration-200 shadow-sm">
                                        <i class="fa-regular fa-trash-can"></i> Delete
                                    </a>
                                <% } else { %>
                                    <span class="text-xs text-gray-400 italic">Cannot delete active session</span>
                                <% } %>
                            </td>
                        </tr>
                <%
                    }
                %>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>