<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Settings.aspx.cs" Inherits="FSM.Settings" MasterPageFile="~/FSM.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .page-title {
            font-size: 28px;
            font-weight: 700;
            color: #f84700;
            margin-bottom: 20px;
        }

        .tab-container {
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            overflow: hidden;
        }

        .tab-nav {
            display: flex;
            border-bottom: 1px solid #e5e7eb;
            background: #f9fafb;
        }

        .tab-button {
            flex: 1;
            padding: 15px 20px;
            text-align: center;
            font-weight: 600;
            color: #6b7280;
            cursor: pointer;
            border: none;
            background: none;
            transition: all 0.3s ease;
        }

            .tab-button.active {
                color: #f84700;
                border-bottom: 2px solid #f84700;
                background: #fff;
            }

            .tab-button:hover:not(.active) {
                color: #4b5563;
                background: #f1f3f5;
            }

        .tab-content {
            padding: 20px;
            display: none;
        }

            .tab-content.active {
                display: block;
            }

        .form-group {
            margin-bottom: 20px;
        }

            .form-group label {
                display: block;
                font-weight: 500;
                color: #374151;
                margin-bottom: 5px;
            }

        .form-control {
            width: 100%;
            padding: 10px;
            border: 1px solid #d1d5db;
            border-radius: 6px;
            font-size: 14px;
        }

        .form-check {
            margin: 10px 0;
        }

        .form-check-input {
            margin-right: 10px;
        }

        .form-check-label {
            color: #4b5563;
        }

        .settings-actions {
            margin-top: 30px;
            text-align: right;
            padding: 25px;
        }

        .btn {
            padding: 10px 20px;
            margin-left: 10px;
            border-radius: 6px;
            border: none;
            cursor: pointer;
            font-weight: 500;
        }

        .btn-success {
            background-color: #28a745;
            color: white;
        }

            .btn-success:hover {
                background-color: #218838;
            }

        .btn-secondary {
            background-color: #6c757d;
            color: white;
        }

            .btn-secondary:hover {
                background-color: #5a6268;
            }

        @media (max-width: 768px) {
            .settings-container {
                padding: 10px;
            }

            .tab-nav {
                flex-direction: column;
            }

            .tab-button {
                padding: 12px;
                text-align: left;
            }
        }
    </style>

    <div class="row mx-0 my-3 g-3 px-3 py-5">
        <h1 class="page-title">Settings</h1>

        <div class="tab-container">
            <div class="tab-nav">
                <button class="tab-button active" data-tab="profile">Profile</button>
                <button class="tab-button" data-tab="notifications">Notifications</button>
                <button class="tab-button" data-tab="login-security">Login & Security</button>
            </div>

            <div class="tab-content active" id="profile">
                <h2>Profile Settings</h2>
                <div class="form-group">
                    <label for="companyName">Company Name</label>
                    <input type="text" id="companyName" class="form-control" placeholder="Your Company Name">
                </div>
                <div class="form-group">
                    <label for="invoicePrefix">Invoice Number Prefix</label>
                    <input type="text" id="invoicePrefix" class="form-control" maxlength="5" placeholder="INV-">
                </div>
                <div class="form-group">
                    <label for="defaultLaborRate">Default Labor Rate ($/hr)</label>
                    <input type="number" id="defaultLaborRate" class="form-control" min="0" step="0.01">
                </div>
                <div class="form-check">
                    <input type="checkbox" id="autoInvoiceNumber" class="form-check-input">
                    <label class="form-check-label" for="autoInvoiceNumber">Auto-generate Invoice Numbers</label>
                </div>
            </div>

            <div class="tab-content" id="notifications">
                <h2>Notification Settings</h2>
                <div class="form-group">
                    <label for="emailNotifications">Notification Email</label>
                    <input type="email" id="emailNotifications" class="form-control" placeholder="notifications@yourcompany.com">
                </div>
                <div class="form-check">
                    <input type="checkbox" id="notifyInvoiceDue" class="form-check-input">
                    <label class="form-check-label" for="notifyInvoiceDue">Notify on Invoice Due</label>
                </div>
                <div class="form-check">
                    <input type="checkbox" id="notifyAppointment" class="form-check-input">
                    <label class="form-check-label" for="notifyAppointment">Notify on New Appointments</label>
                </div>
                <div class="form-group">
                    <label for="notificationInterval">Notification Interval</label>
                    <select id="notificationInterval" class="form-control">
                        <option value="daily">Daily</option>
                        <option value="weekly">Weekly</option>
                        <option value="monthly">Monthly</option>
                    </select>
                </div>
            </div>

            <div class="tab-content" id="login-security">
                <h2>Login & Security Settings</h2>
                <div class="form-group">
                    <label for="currentPassword">Current Password</label>
                    <input type="password" id="currentPassword" class="form-control" placeholder="Enter current password">
                </div>
                <div class="form-group">
                    <label for="newPassword">New Password</label>
                    <input type="password" id="newPassword" class="form-control" placeholder="Enter new password">
                </div>
                <div class="form-group">
                    <label for="confirmPassword">Confirm New Password</label>
                    <input type="password" id="confirmPassword" class="form-control" placeholder="Confirm new password">
                </div>
                <div class="form-check">
                    <input type="checkbox" id="enable2FA" class="form-check-input">
                    <label class="form-check-label" for="enable2FA">Enable Two-Factor Authentication</label>
                </div>
            </div>

            <div class="settings-actions">
                <button id="saveSettings" class="btn btn-success">Save Settings</button>
                <button id="resetSettings" class="btn btn-secondary">Reset to Defaults</button>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const tabs = document.querySelectorAll('.tab-button');
            const contents = document.querySelectorAll('.tab-content');

            tabs.forEach(tab => {
                tab.addEventListener('click', () => {
                    tabs.forEach(t => t.classList.remove('active'));
                    contents.forEach(c => c.classList.remove('active'));

                    tab.classList.add('active');
                    document.getElementById(tab.dataset.tab).classList.add('active');
                });
            });

            loadSettings();

            document.getElementById('saveSettings').addEventListener('click', () => {
                if (validateSettings()) {
                    saveSettings();
                    alert('Settings saved successfully!');
                }
            });

            document.getElementById('resetSettings').addEventListener('click', () => {
                if (confirm('Are you sure you want to reset all settings to default?')) {
                    resetSettings();
                }
            });
        });

        function loadSettings() {
            const defaultSettings = {
                companyName: 'Your Company',
                invoicePrefix: 'INV-',
                defaultLaborRate: 75.00,
                autoInvoiceNumber: true,
                emailNotifications: 'notifications@yourcompany.com',
                notifyInvoiceDue: true,
                notifyAppointment: false,
                notificationInterval: 'daily',
                currentPassword: '',
                newPassword: '',
                confirmPassword: '',
                enable2FA: false
            };

            const settings = {
                companyName: localStorage.getItem('companyName') || defaultSettings.companyName,
                invoicePrefix: localStorage.getItem('invoicePrefix') || defaultSettings.invoicePrefix,
                defaultLaborRate: localStorage.getItem('defaultLaborRate') || defaultSettings.defaultLaborRate,
                autoInvoiceNumber: localStorage.getItem('autoInvoiceNumber') !== 'false',
                emailNotifications: localStorage.getItem('emailNotifications') || defaultSettings.emailNotifications,
                notifyInvoiceDue: localStorage.getItem('notifyInvoiceDue') !== 'false',
                notifyAppointment: localStorage.getItem('notifyAppointment') === 'true',
                notificationInterval: localStorage.getItem('notificationInterval') || defaultSettings.notificationInterval,
                currentPassword: localStorage.getItem('currentPassword') || defaultSettings.currentPassword,
                newPassword: localStorage.getItem('newPassword') || defaultSettings.newPassword,
                confirmPassword: localStorage.getItem('confirmPassword') || defaultSettings.confirmPassword,
                enable2FA: localStorage.getItem('enable2FA') === 'true'
            };

            document.getElementById('companyName').value = settings.companyName;
            document.getElementById('invoicePrefix').value = settings.invoicePrefix;
            document.getElementById('defaultLaborRate').value = settings.defaultLaborRate;
            document.getElementById('autoInvoiceNumber').checked = settings.autoInvoiceNumber;
            document.getElementById('emailNotifications').value = settings.emailNotifications;
            document.getElementById('notifyInvoiceDue').checked = settings.notifyInvoiceDue;
            document.getElementById('notifyAppointment').checked = settings.notifyAppointment;
            document.getElementById('notificationInterval').value = settings.notificationInterval;
            document.getElementById('currentPassword').value = settings.currentPassword;
            document.getElementById('newPassword').value = settings.newPassword;
            document.getElementById('confirmPassword').value = settings.confirmPassword;
            document.getElementById('enable2FA').checked = settings.enable2FA;
        }

        function validateSettings() {
            const laborRate = document.getElementById('defaultLaborRate').value;
            const newPassword = document.getElementById('newPassword').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            const email = document.getElementById('emailNotifications').value;

            if (laborRate < 0) {
                alert('Labor rate cannot be negative');
                return false;
            }
            if (newPassword && newPassword !== confirmPassword) {
                alert('New password and confirmation do not match');
                return false;
            }
            if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
                alert('Please enter a valid email address for notifications');
                return false;
            }
            return true;
        }

        function saveSettings() {
            const settings = {
                companyName: document.getElementById('companyName').value,
                invoicePrefix: document.getElementById('invoicePrefix').value,
                defaultLaborRate: document.getElementById('defaultLaborRate').value,
                autoInvoiceNumber: document.getElementById('autoInvoiceNumber').checked,
                emailNotifications: document.getElementById('emailNotifications').value,
                notifyInvoiceDue: document.getElementById('notifyInvoiceDue').checked,
                notifyAppointment: document.getElementById('notifyAppointment').checked,
                notificationInterval: document.getElementById('notificationInterval').value,
                currentPassword: document.getElementById('currentPassword').value,
                newPassword: document.getElementById('newPassword').value,
                confirmPassword: document.getElementById('confirmPassword').value,
                enable2FA: document.getElementById('enable2FA').checked
            };

            Object.entries(settings).forEach(([key, value]) => {
                localStorage.setItem(key, value);
            });
        }

        function resetSettings() {
            localStorage.clear();
            loadSettings();
        }
    </script>
</asp:Content>
