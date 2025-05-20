<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="FSM.Dashboard" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        :root {
            --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1);
            --text-gray-700: #4b5563;
            --text-blue-700: #1e40af;
        }

        [data-theme="dark"] {
            --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.3), 0 4px 6px -4px rgba(0, 0, 0, 0.2);
            --text-gray-700: #ffffff;
            --text-blue-700: #ffffff;
        }

        .container-fluid {
            padding: 20px;
            margin-top: 60px;
            max-width: 100%;
        }

        [data-theme="dark"] .container-fluid {
            background: transparent;
        }

        .page-title {
            font-size: 32px;
            font-weight: 700;
            color: var(--text-blue-700);
            text-align: center;
            margin-bottom: 10px;
        }

        .subtitle {
            font-size: 20px;
            font-weight: 500;
            color: var(--text-gray-700);
            text-align: center;
            margin-bottom: 20px;
        }

        .welcome-card {
            background: #ffffff;
            box-shadow: var(--shadow-lg);
            border-radius: 12px;
            padding: 40px;
            max-width: 600px;
            margin: 0 auto;
            transition: transform 0.2s ease;
        }

        [data-theme="dark"] .welcome-card {
            background: rgba(255, 255, 255, 0.14);
            box-shadow: var(--shadow-lg);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
        }

        .welcome-card:hover {
            transform: translateY(-2px);
        }

        .logo-image {
            display: block;
            max-width: 300px;
            height: auto;
            margin: 20px auto 0;
            border-radius: 8px;
            content: url('https://testsite.myserviceforce.com/fsm/images/xceleran.png');
        }

        [data-theme="dark"] .logo-image {
            content: url('https://testsite.myserviceforce.com/fsm/images/xceleranwhite.png');
        }

        @media (max-width: 768px) {
            .welcome-card {
                padding: 20px;
            }

            .page-title {
                font-size: 24px;
            }

            .subtitle {
                font-size: 16px;
            }

            .logo-image {
                max-width: 150px;
            }
        }
    </style>
    <main class="main-content container-fluid">
        <div class="welcome-card">
            <h1 class="page-title">Welcome to FSM</h1>
            <p class="subtitle">Field Service Module</p>
            <img class="logo-image" alt="FSM Logo">
        </div>
    </main>
</asp:Content>
