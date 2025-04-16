<%@ Page Title="Customers" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="Customer.aspx.cs" Inherits="FSM.Customer" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <link rel="stylesheet" href="https://cdn.datatables.net/2.2.2/css/dataTables.dataTables.min.css">
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/select/3.0.0/css/select.dataTables.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.datatables.net/2.2.2/js/dataTables.min.js"></script>
    <script type="text/javascript" src="https://cdn.datatables.net/select/3.0.0/js/dataTables.select.min.js"></script>

    <style type="text/css">
        /* Unique raw CSS classes */
        .cust-page-container {
            width: 100%;
            padding: 0;
            margin: 0 auto;
            margin-top: 50px;
            padding: 0 25px;
        }

        .cust-header {
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            margin-bottom: 20px;
        }

        .cust-title {
            font-size: 24px;
            font-weight: bold;
            color: #ff520d;
        }

        .cust-search-container {
            display: flex;
            flex-direction: column;
            gap: 10px;
            width: 100%;
        }

        .cust-search-input {
            border: 1px solid #d1d5db;
            border-radius: 8px;
            padding: 8px;
            width: 100%;
            box-sizing: border-box;
        }

        .cust-add-btn {
            background-color: #2563eb;
            color: #ffffff;
            padding: 8px 16px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
        }

            .cust-add-btn:hover {
                background-color: #1d4ed8;
            }

        div.dt-container div.dt-layout-row {
            padding: 15px;
        }

        .cust-section {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .cust-list-container {
            width: 100%;
            background-color: #ffffff;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }

        .cust-list-header {
            display: none;
            grid-template-columns: repeat(3, 1fr);
            padding: 10px;
            background-color: #f3f4f6;
            color: #6b7280;
            font-weight: 500;
            font-size: 14px;
            position: sticky;
            top: 0;
            z-index: 10;
        }

            .cust-list-header th {
                overflow: hidden;
                text-overflow: ellipsis;
                white-space: nowrap;
                padding: 12px;
            }

        .cust-list {
            max-height: calc(100vh - 192px);
            overflow-y: auto;
            padding: 8px;
        }

        .cust-item {
            padding: 12px;
            border-bottom: 1px solid #e5e7eb;
            cursor: pointer;
        }

            .cust-item:hover {
                background-color: #f9fafb;
            }

        .cust-item-active {
            background-color: #ccfbf1;
        }

        .cust-item-field {
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .cust-item-label {
            font-weight: 500;
            color: #374151;
            display: inline;
        }

        .cust-details-container {
            width: 100%;
            background-color: #ffffff;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            padding: 16px;
            overflow: hidden;
        }

        .cust-details-header {
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            margin-bottom: 20px;
            gap: 10px;
        }

        .cust-details-title {
            font-size: 20px;
            font-weight: 600;
            color: #1f2937;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .cust-details-btns {
            display: flex;
            flex-direction: column;
            gap: 8px;
            width: 100%;
        }

        .cust-edit-btn, .cust-message-btn {
            background-color: #e5e7eb;
            color: #374151;
            padding: 4px 12px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
        }

            .cust-edit-btn:hover, .cust-message-btn:hover {
                background-color: #d1d5db;
            }

        .cust-details-content {
            max-height: calc(100vh - 192px);
            overflow-y: auto;
        }

        .cust-section-block {
            border-bottom: 1px solid #e5e7eb;
        }

        .cust-section-toggle {
            width: 100%;
            padding: 16px;
            background-color: #f9fafb;
            text-align: left;
            font-weight: 500;
            color: #374151;
            border: none;
            cursor: pointer;
            position: relative;
        }

            .cust-section-toggle::after {
                content: '\25BC'; /* Unicode for downward arrow */
                position: absolute;
                right: 16px;
                top: 50%;
                transform: translateY(-50%);
                transition: transform 0.3s ease;
                font-size: 12px;
            }

            .cust-section-toggle.active::after {
                transform: translateY(-50%) rotate(180deg); /* Rotate arrow when active */
            }

            .cust-section-toggle:hover {
                background-color: #f3f4f6;
            }

        .cust-section-content {
            padding: 16px;
            display: none;
        }

        .cust-info-text {
            margin-bottom: 8px;
        }

        .cust-info-label {
            color: #4b5563;
            font-weight: 500;
        }

        .cust-info-value {
            color: #1f2937;
            word-wrap: break-word;
        }

        .cust-site-card {
            padding: 16px;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            margin-bottom: 16px;
        }

        .cust-site-title {
            font-size: 18px;
            font-weight: 500;
            color: #1f2937;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .cust-site-info {
            color: #4b5563;
            margin: 4px 0;
        }

        .cust-site-actions {
            margin-top: 8px;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .cust-site-edit-btn {
            background-color: #e5e7eb;
            color: #374151;
            padding: 4px 8px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
        }

            .cust-site-edit-btn:hover {
                background-color: #d1d5db;
            }

        .cust-site-view-link {
            background-color: #2563eb;
            color: #ffffff;
            padding: 4px 8px;
            border-radius: 8px;
            text-decoration: none;
            display: inline-block;
        }

            .cust-site-view-link:hover {
                background-color: #1d4ed8;
                color: white;
            }

        .cust-site-add-btn {
            background-color: #e5e7eb;
            color: #374151;
            padding: 8px 16px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
        }

            .cust-site-add-btn:hover {
                background-color: #d1d5db;
            }

        .cust-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            justify-content: center;
            align-items: center;
            z-index: 1000;
        }

        .cust-modal-content {
            background-color: #ffffff;
            padding: 16px;
            border-radius: 8px;
            width: 90%;
            max-width: 500px;
        }

        .cust-modal-title {
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 16px;
        }

        .cust-modal-form {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .cust-modal-field {
            display: flex;
            flex-direction: column;
        }

        .cust-modal-label {
            margin-bottom: 4px;
        }

        .cust-modal-input {
            width: 100%;
            padding: 8px;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            box-sizing: border-box;
        }

        .cust-modal-btns {
            display: flex;
            gap: 8px;
        }

        .cust-modal-submit {
            background-color: #2563eb;
            color: #ffffff;
            padding: 8px 16px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
        }

            .cust-modal-submit:hover {
                background-color: #1d4ed8;
            }

        .cust-modal-cancel {
            background-color: #e5e7eb;
            color: #374151;
            padding: 8px 16px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
        }

            .cust-modal-cancel:hover {
                background-color: #d1d5db;
            }

        .cust-pdf-preview {
            width: 100%;
            height: 200px;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            margin-top: 8px;
            display: none;
        }

        .cust-dashboard-item.invoice {
            background-color: #16a34a;
        }

        #customerTable_wrapper {
            background-color: #ffffff;
            border-radius: 8px;
            overflow: hidden;
        }

        #customerTable thead {
            background-color: #f3f4f6;
            color: #6b7280;
            font-weight: 500;
            font-size: 14px;
        }

            #customerTable thead th {
                padding: 12px;
                text-align: left;
            }

        #customerTable tbody tr {
            border-bottom: 1px solid #e5e7eb;
            cursor: pointer;
        }

            #customerTable tbody tr:hover {
                background-color: #f9fafb;
            }

            #customerTable tbody tr.selected {
                background-color: #ccfbf1;
            }

        #customerTable tbody td {
            padding: 12px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        #customerTable_wrapper .dataTables_paginate {
            padding: 10px;
        }

        #customerTable_wrapper .dataTables_info {
            padding: 10px;
        }

        #customerTable_wrapper .dataTables_length {
            padding: 10px;
        }

        #customerTable_wrapper .dataTables_filter {
            padding: 10px;
        }

        /* Responsive adjustments */
        @media (min-width: 768px) {
            .cust-header {
                flex-direction: row;
                align-items: center;
            }

            .cust-search-container {
                flex-direction: row;
                width: auto;
            }

            .cust-search-input {
                width: 256px;
            }

            .cust-section {
                flex-direction: row;
            }

            .cust-list-container, .cust-details-container {
                width: 66.66%;
            }

            .cust-details-header {
                flex-direction: row;
                align-items: center;
            }

            .cust-details-btns {
                flex-direction: row;
                width: auto;
            }

            .cust-site-actions {
                flex-direction: row;
            }

            .cust-dashboard-item {
                flex: 1 1 45%;
            }
        }

        @media (min-width: 1280px) {
            .cust-list-header {
                display: grid;
            }

            .cust-item {
                display: grid;
                grid-template-columns: repeat(3, 1fr);
            }

            .cust-item-label {
                display: none;
            }

            .cust-dashboard-item {
                flex: 1 1 22%;
            }
        }
    </style>

    <div class="cust-page-container">
        <!-- Page Header -->
        <header class="cust-header mt-3">
            <h1 class="cust-title">Customers</h1>
            <%-- <div class="cust-search-container">
                <input type="text" placeholder="Search customers..." class="cust-search-input" id="customerSearch" />
                <button class="cust-add-btn" id="addCustomerBtn">+ Add Customer</button>
            </div>--%>
        </header>

        <!-- Customer Section -->
        <section class="cust-section">
            <!-- Customer List -->
            <div class="cust-list-container">
                <table id="customerTable" class="display" style="width: 100%">
                    <thead>
                        <tr>
                            <th>First Name</th>
                            <th>Last Name</th>
                            <th>Email</th>
                        </tr>
                    </thead>
                </table>
            </div>

            <!-- Customer Details -->
            <div class="cust-details-container">
                <div class="cust-details-header">
                    <h2 class="cust-details-title" id="customerName">Select a Customer</h2>
                    <%--<div class="cust-details-btns">
                        <button class="cust-edit-btn" id="editCustomerBtn" disabled>Edit</button>
                        <button class="cust-message-btn" id="messageCustomerBtn" disabled>Message</button>
                    </div>--%>
                </div>
                <div class="cust-details-content">
                    <!-- Contact Info -->
                    <div class="cust-section-block">
                        <button class="cust-section-toggle" data-section="contact" id="contactBtn">Contact Info</button>
                        <div class="cust-section-content" id="contact">
                            <p class="cust-info-text"><span class="cust-info-label">Email:</span> <span class="cust-info-value" id="customerEmail">-</span></p>
                            <p class="cust-info-text"><span class="cust-info-label">Phone:</span> <span class="cust-info-value" id="customerPhone">-</span></p>
                        </div>
                    </div>

                    <!-- Sites & Locations -->
                    <div class="cust-section-block">
                        <button class="cust-section-toggle" data-section="sites" id="sitesBtn">Sites & Locations</button>
                        <div class="cust-section-content" id="sites">
                            <div class="cust-site-card" data-site-id="1">
                                <h3 class="cust-site-title">Main Residence</h3>
                                <p class="cust-site-info" id="address-1">Address: 123 Elm St, City, ST 12345</p>
                                <p class="cust-site-info">Contact: Jane Smith (555-987-6543)</p>
                                <div class="cust-site-actions">
                                    <button class="cust-site-edit-btn" data-site-id="1">Edit</button>
                                    <a href="CustomerDetails.aspx?siteId=1" class="cust-site-view-link">View Details</a>
                                </div>
                            </div>
                            <div class="cust-site-card" data-site-id="2">
                                <h3 class="cust-site-title">Vacation Home</h3>
                                <p class="cust-site-info" id="address-2">Address: 456 Oak Rd, City, ST 12345</p>
                                <p class="cust-site-info">Contact: Bob Johnson (555-456-7890)</p>
                                <div class="cust-site-actions">
                                    <button class="cust-site-edit-btn" data-site-id="2">Edit</button>
                                    <a href="CustomerDetails.aspx?siteId=2" class="cust-site-view-link">View Details</a>
                                </div>
                            </div>
                            <button class="cust-site-add-btn" id="addSiteBtn">+ Add Site</button>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </div>

    <!-- Add Customer Modal -->
    <div class="cust-modal" id="addCustomerModal">
        <div class="cust-modal-content">
            <h2 class="cust-modal-title">Add New Customer</h2>
            <form id="addCustomerForm" class="cust-modal-form">
                <div class="cust-modal-field">
                    <label class="cust-modal-label">First Name</label>
                    <input type="text" name="firstName" class="cust-modal-input" required />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Last Name</label>
                    <input type="text" name="lastName" class="cust-modal-input" required />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Email</label>
                    <input type="email" name="email" class="cust-modal-input" required />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Phone</label>
                    <input type="text" name="phone" class="cust-modal-input" />
                </div>
                <div class="cust-modal-btns">
                    <button type="submit" class="cust-modal-submit">Add Customer</button>
                    <button type="button" class="cust-modal-cancel" id="closeAddCustomer">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Edit Customer Modal -->
    <div class="cust-modal" id="editCustomerModal">
        <div class="cust-modal-content">
            <h2 class="cust-modal-title">Edit Customer</h2>
            <form id="editCustomerForm" class="cust-modal-form">
                <div class="cust-modal-field">
                    <label class="cust-modal-label">First Name</label>
                    <input type="text" name="firstName" id="editFirstName" class="cust-modal-input" required />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Last Name</label>
                    <input type="text" name="lastName" id="editLastName" class="cust-modal-input" required />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Email</label>
                    <input type="email" name="email" id="editEmail" class="cust-modal-input" required />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Phone</label>
                    <input type="text" name="phone" id="editPhone" class="cust-modal-input" />
                </div>
                <div class="cust-modal-btns">
                    <button type="submit" class="cust-modal-submit">Save Changes</button>
                    <button type="button" class="cust-modal-cancel" id="closeEditCustomer">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Add Site Modal -->
    <div class="cust-modal" id="addSiteModal">
        <div class="cust-modal-content">
            <h2 class="cust-modal-title">Add New Site</h2>
            <input type="number" id="SiteId" value="0" hidden="hidden" />
            <input type="text" id="CustomerID" hidden="hidden" />
            <input type="text" id="CustomerGuid" hidden="hidden" />
            <form id="addSiteForm" class="cust-modal-form">
                <div class="cust-modal-field">
                    <label for="siteName" class="cust-modal-label">Site Name</label>
                    <input type="text" id="siteName" name="siteName" class="cust-modal-input" required />
                </div>
                <div class="cust-modal-field">
                    <label for="address" class="cust-modal-label">Address</label>
                    <input type="text" id="address" name="address" class="cust-modal-input" required />
                </div>
                <div class="cust-modal-field">
                    <label for="contact" class="cust-modal-label">Site Contact</label>
                    <input type="text" id="siteContact" name="contact" class="cust-modal-input" />
                </div>
                <%--<div class="cust-modal-field">
                    <label class="cust-modal-label">Equipment Name</label>
                    <input type="text" name="equipName" class="cust-modal-input" />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Equipment Type</label>
                    <select name="equipType" class="cust-modal-input">
                        <option value="">Select Type</option>
                        <option value="hvac">HVAC</option>
                        <option value="generator">Generator</option>
                        <option value="plumbing">Plumbing</option>
                    </select>
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Install Date</label>
                    <input type="date" name="equipInstallDate" class="cust-modal-input" />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Warranty Expiry</label>
                    <input type="date" name="equipWarrantyExpiry" class="cust-modal-input" />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Service Agreement</label>
                    <input type="file" name="serviceAgreement" accept=".pdf" class="cust-modal-input" />
                    <div id="addSiteAgreementPreview" class="cust-pdf-preview"></div>
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Alarms</label>
                    <input type="text" name="alarms" class="cust-modal-input" />
                </div>--%>
                <div class="cust-modal-field">
                    <label for="note" class="cust-modal-label">Note</label>
                    <input id="note" type="text" name="note" class="cust-modal-input" />
                </div>
                <div class="cust-modal-field">
                    <label>
                        <input type="checkbox" id="isActive" checked />
                        Active
                    </label>
                </div>
                <div class="cust-modal-btns">
                    <button type="button" onclick="saveSite(event)" class="cust-modal-submit">Add Site</button>
                    <button type="button" class="cust-modal-cancel" id="closeAddSite">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            // Add Customer
            const addCustomerBtn = document.getElementById('addCustomerBtn');
            if (addCustomerBtn) {
                addCustomerBtn.addEventListener('click', () => {
                    document.getElementById('addCustomerForm').reset();
                    openModal('addCustomerModal');
                });
            }

            const closeAddCustomerBtn = document.getElementById('closeAddCustomer');
            if (closeAddCustomerBtn) {
                closeAddCustomerBtn.addEventListener('click', () => closeModal('addCustomerModal'));
            }

            // Add Site
            const addSiteBtn = document.getElementById('addSiteBtn');
            if (addSiteBtn) {
                addSiteBtn.addEventListener('click', () => {
                    document.getElementById('addSiteForm').reset();
                    $('.cust-modal-title').text("Add Site");
                    $('.cust-modal-submit').text("Save");
                    openModal('addSiteModal');
                });
            }

            const closeAddSiteBtn = document.getElementById('closeAddSite');
            if (closeAddSiteBtn) {
                closeAddSiteBtn.addEventListener('click', () => closeModal('addSiteModal'));
            }


            // Search Customers
            const customerSearch = document.getElementById('customerSearch');
            if (customerSearch) {
                customerSearch.addEventListener('input', (e) => {
                    table.search(e.target.value).draw();
                });
            }

            // Message Customer
            const messageCustomerBtn = document.getElementById('messageCustomerBtn');
            if (messageCustomerBtn) {
                messageCustomerBtn.addEventListener('click', () => {
                    const email = document.getElementById('customerEmail').textContent;
                    alert(`Sending message to ${email}...`);
                });
            }

            // Accordion Functionality
            const accordionButtons = document.querySelectorAll('.cust-section-toggle');
            if (accordionButtons) {
                accordionButtons.forEach(btn => {
                    btn.addEventListener('click', () => {
                        const sectionId = btn.dataset.section;
                        const content = document.getElementById(sectionId);
                        const isActive = content.style.display === 'block';
                        accordionButtons.forEach(b => {
                            const sectionContent = document.getElementById(b.dataset.section);
                            if (sectionContent) {
                                sectionContent.style.display = 'none';
                                b.classList.remove('active');
                            }
                        });
                        if (!isActive) {
                            content.style.display = 'block';
                            btn.classList.add('active');
                        }
                    });
                });
            }
        });

        var sites = [];

        function openModal(modalId) {
            const modal = document.getElementById(modalId);
            if (modal) {
                modal.style.display = 'flex';
            }
        }

        function closeModal(modalId) {
            const modal = document.getElementById(modalId);
            if (modal) {
                modal.style.display = 'none';
            }
        }


        // Customer DataTable
        let table = null;
        loadCustomers();

        function loadCustomers() {
            table = $('#customerTable').DataTable({
                "processing": true,
                "serverSide": true,
                "filter": true,
                "ajax": {
                    "url": "Customer.aspx/LoadCustomers",
                    "type": "POST",
                    "contentType": "application/json; charset=utf-8",
                    "dataType": "json",
                    "data": function (d) {
                        return JSON.stringify({
                            draw: d.draw,
                            start: d.start,
                            length: d.length,
                            searchValue: d.search.value,
                            sortColumn: d.columns[d.order[0].column].data,
                            sortDirection: d.order[0].dir
                        });
                    },
                    "dataSrc": function (json) {
                        console.log(json);
                        if (json.error) {
                            alert(json.error);
                            return [];
                        }
                        return json.data;
                    }
                },
                "paging": true,
                "pageLength": 10,
                "columns": [
                    { "data": "FirstName", "name": "First Name", "autoWidth": true },
                    { "data": "LastName", "name": "Last Name", "autoWidth": true },
                    { "data": "Email", "name": "Email", "autoWidth": true },
                ],
                "select": {
                    "style": "single"
                },
                "drawCallback": function (settings) {
                    var api = this.api();
                    if (api.rows().count() > 0 && !$('#customerTable tbody tr').hasClass('selected')) {
                        api.row(0).select();
                        var firstRowData = api.row(0).data();
                        generateCustomerDetails(firstRowData);
                    }
                }
            });
        }

        $('#customerTable tbody').on('click', 'tr', function () {
            var data = table.row(this).data();
            if (data) {
                generateCustomerDetails(data);
            }
        });

        function generateCustomerDetails(data) {
            console.log(data);
            if (data) {
                document.getElementById('customerName').textContent = data.FirstName + " " + data.LastName;
                document.getElementById('customerEmail').textContent = data.Email || '-';
                document.getElementById('customerPhone').textContent = data.Phone || '-';
                document.getElementById('CustomerID').value = data.CustomerID;
                document.getElementById('CustomerGuid').value = data.CustomerGuid;
                loadCustomerSiteData(data.CustomerID);
            }
        }

        function loadCustomerSiteData(customerId) {
            if (customerId) {
                sites = [];
                $.ajax({
                    type: "POST",
                    url: "Customer.aspx/GetCustomerSiteData",
                    data: JSON.stringify({ customerId: customerId }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        console.log(response);
                        if (response.d) {
                            sites = response.d;

                            // Render Sites
                            const sitesContainer = document.getElementById('sites');
                            const addSiteBtn = sitesContainer.querySelector('#addSiteBtn');
                            sitesContainer.innerHTML = '';
                            sites.forEach(site => {
                                const siteCard = document.createElement('div');
                                siteCard.className = 'cust-site-card';
                                siteCard.dataset.siteId = site.Id;
                                siteCard.innerHTML = `
                                <h3 class="cust-site-title">${site.SiteName}</h3>
                                <p class="cust-site-info">Address: ${site.Address}</p>
                                <p class="cust-site-info">Contact: ${site.Contact || '-'}</p>
                                <div class="cust-site-actions">
                                <button class="cust-site-edit-btn" data-site-id="${site.Id}">Edit</button>
                                <a href="CustomerDetails.aspx?siteId=${site.Id}&custId=${site.CustomerID}" class="cust-site-view-link">View Details</a>
                                </div>`;
                                sitesContainer.appendChild(siteCard);
                            });
                            sitesContainer.appendChild(addSiteBtn);


                            // Reattach Edit Site Handlers
                            document.querySelectorAll('.cust-site-edit-btn').forEach(btn => {
                                btn.addEventListener('click', () => {
                                    const siteId = btn.dataset.siteId;
                                    console.log(siteId);
                                    console.log(sites);
                                    const site = sites.find(s => s.Id == siteId);
                                    console.log(site);
                                    if (site) {
                                        $('.cust-modal-title').text("Edit Site");
                                        $('.cust-modal-submit').text("Update");
                                        document.getElementById('SiteId').value = site.Id;
                                        document.getElementById('CustomerGuid').value = site.CustomerGuid;
                                        document.getElementById('CustomerID').value = site.CustomerID;
                                        document.getElementById('siteName').value = site.SiteName;
                                        document.getElementById('address').value = site.Address;
                                        document.getElementById('siteContact').value = site.Contact || '';
                                        document.getElementById('isActive').checked = site.IsActive;
                                        document.getElementById('note').value = site.Note || '';
                                        openModal('addSiteModal');
                                    }
                                });
                            });
                        }
                        else {
                            alert("Something went wrong!");
                        }
                    },
                    error: function (xhr, status, error) {
                        console.error("Error loading site data: ", error);
                    }
                });
            }
        }

        function saveSite(event) {
            event.preventDefault();
            if (validateSiteForm()) {
                const site = {
                    Id: parseInt($('#SiteId').val()),
                    CustomerID: $('#CustomerID').val(),
                    CustomerGuid: $('#CustomerGuid').val(),
                    Note: $('#note').val().trim(),
                    Contact: $('#siteContact').val().trim(),
                    Address: $('#address').val().trim(),
                    SiteName: $('#siteName').val().trim(),
                    IsActive: document.getElementById("isActive").checked
                };
                console.log(site);

                let message = "saved";
                if (site.Id > 0) {
                    message = "updated";
                }

                $.ajax({
                    type: "POST",
                    url: "Customer.aspx/SaveCustomerSiteData",
                    data: JSON.stringify({ site: site }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        console.log(response);
                        if (response.d) {
                            alert("Site "+ message +" successfully!");
                            closeModal('addSiteModal');
                            loadCustomerSiteData(site.CustomerID);
                        }
                        else {
                            alert("Something went wrong!");
                        }
                    },
                    error: function (xhr, status, error) {
                        console.error("Error updating details: ", error);
                    }
                });
            }



        }

        function validateSiteForm() {
            let isValid = true;
            let errorMessage = "";

            // Required field validation
            if ($("#siteName").val().trim() === "") {
                errorMessage += "Site Name is required.\n";
                isValid = false;
            }
            if ($("#address").val().trim() === "") {
                errorMessage += "Adress is required.\n";
                isValid = false;
            }

            if (!isValid) {
                alert(errorMessage);
            }
            return isValid;
        }
    </script>
</asp:Content>
