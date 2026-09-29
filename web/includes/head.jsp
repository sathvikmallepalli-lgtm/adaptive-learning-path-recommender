<%--
    Shared <head> for every page.
    Include it AFTER setting the pageTitle variable, like this:
        <% String pageTitle = "Modules"; %>
        <%@ include file="/includes/head.jsp" %>
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><%= pageTitle %> &middot; Adaptive Learning</title>

    <!-- Bootstrap is stored in the project, so the app also works offline -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/bootstrap.min.css">

    <!-- Fonts are optional: if there is no internet the fallbacks are used -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;600;700&family=Inter:wght@400;500;600&family=JetBrains+Mono:wght@500;600;700&display=swap">

    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
