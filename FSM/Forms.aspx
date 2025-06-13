<%@ Page Title="Forms" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="Forms.aspx.cs" Inherits="FSM.Forms" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <!-- CSS Variables aligned with main site.css -->
    <style>
    
        }

        .forms-page-container {
            width: 100%;
            padding: 0 25px;
            margin: 0 auto;
            margin-top: 50px;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: calc(100vh - 100px);
        }

        .under-development {
            font-size: 24px;
            font-weight: 600;
            color: var(--text-gray-800);
            text-align: center;
        }

        [data-theme="dark"] .under-development {
            color: var(--text-gray-700);
        }
    </style>

    <!-- Page Content -->
    <div class="forms-page-container">
        <div class="under-development">Under Development</div>
    </div>

</asp:Content>