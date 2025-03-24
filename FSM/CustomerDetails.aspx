<%@ Page Title="Customer Site Details" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="CustomerDetails.aspx.cs" Inherits="FSM.CustomerDetails" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style type="text/css">
        /* Unique raw CSS classes for CustomerDetails */
        .custdet-container { padding: 24px; width: 100%; box-sizing: border-box; margin-top: 35px; }
        .custdet-title { font-size: 24px; font-weight: 600; color: #1f2937; margin-bottom: 24px; }
        .custdet-content { background-color: #ffffff; border-radius: 8px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); padding: 24px; }
        .custdet-section { margin-bottom: 24px; }
        .custdet-section-title { font-size: 20px; font-weight: 500; color: #374151; margin-bottom: 8px; }
        .custdet-table { width: 100%; border-collapse: collapse; border: 1px solid #e5e7eb; }
        .custdet-table th, .custdet-table td { border: 1px solid #e5e7eb; padding: 8px; text-align: left; }
        .custdet-table th { background-color: #f3f4f6; color: #374151; font-weight: 500; }
        .custdet-table td { color: #1f2937; }
        .custdet-table-label { font-weight: 500; color: #374151; }
        .custdet-link { color: #2563eb; text-decoration: none; }
        .custdet-link:hover { text-decoration: underline; }
        .custdet-gallery { display: flex; flex-wrap: wrap; gap: 8px; }
        .custdet-no-pics { color: #1f2937; }
        .custdet-message-container { display: flex; flex-direction: column; gap: 8px; }
        .custdet-message-select { border: 1px solid #d1d5db; border-radius: 8px; padding: 8px; width: 100%; box-sizing: border-box; }
        .custdet-send-btn { background-color: #e5e7eb; color: #374151; padding: 8px 16px; border-radius: 8px; border: none; cursor: pointer; }
        .custdet-send-btn:hover { background-color: #d1d5db; }
        .custdet-back-btn { background-color: #e5e7eb; color: #374151; padding: 8px 16px; border-radius: 8px; border: none; cursor: pointer; text-decoration: none; display: inline-block; }
        .custdet-back-btn:hover { background-color: #d1d5db; }
        .custdet-back-container { display: flex; justify-content: flex-end; }
        .custdet-dashboard { display: flex; flex-wrap: wrap; gap: 16px; margin-bottom: 24px; }
        .custdet-dashboard-item { background-color: #3b82f6; color: white; border-radius: 8px; flex: 1; min-width: 150px; text-align: center; }
        .custdet-dashboard-item.green { background-color: #16a34a; }
        .custdet-dashboard-item h3 { font-size: 16px; margin-bottom: 8px; }
        .custdet-dashboard-item p { font-size: 20px; font-weight: 600; }

        /* Filter and List Styles */
        .custdet-filter-container { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 16px; }
        .custdet-filter-btn { background-color: #e5e7eb; color: #374151; padding: 6px 12px; border-radius: 8px; border: none; cursor: pointer; }
        .custdet-filter-btn.active { background-color: #2563eb; color: #ffffff; }
        .custdet-filter-btn:hover { background-color: #d1d5db; }
        .custdet-filter-btn.active:hover { background-color: #1d4ed8; }
        .custdet-list { border: 1px solid #e5e7eb; border-radius: 8px; overflow: hidden; }
        .custdet-list-item { padding: 12px; border-bottom: 1px solid #e5e7eb; }
        .custdet-list-item:last-child { border-bottom: none; }
        .custdet-list-item span { display: block; margin-bottom: 4px; }
        .custdet-no-items { padding: 12px; color: #1f2937; }

        /* Responsive adjustments */
        @media (min-width: 768px) {
            .custdet-message-container { flex-direction: row; }
            .custdet-dashboard-item { flex: 0 0 calc(25% - 12px); }
            .custdet-filter-container { flex-wrap: nowrap; }
        }
        @media (max-width: 767px) {
            .custdet-dashboard-item { flex: 0 0 calc(50% - 8px); }
        }
    </style>

    <div class="custdet-container">
        <h1 class="custdet-title">Site Details: <span id="siteDetailsName">Loading...</span></h1>
        <div class="custdet-content">
            <!-- Appointment and Invoice Dashboard -->
            <div class="custdet-section">
                <h2 class="custdet-section-title">Overview</h2>
                <div class="custdet-dashboard">
                    <div class="custdet-dashboard-item">
                        <h3>Pending Appointments</h3>
                        <p id="pendingAppointments">0</p>
                    </div>
                    <div class="custdet-dashboard-item">
                        <h3>Scheduled Appointments</h3>
                        <p id="scheduledAppointments">0</p>
                    </div>
                    <div class="custdet-dashboard-item">
                        <h3>Completed Appointments</h3>
                        <p id="completedAppointments">0</p>
                    </div>
                    <div class="custdet-dashboard-item">
                        <h3>Custom Tabs</h3>
                        <p id="customTabs">0</p>
                    </div>
                    <div class="custdet-dashboard-item green">
                        <h3>Estimates</h3>
                        <p id="estimates">0</p>
                    </div>
                    <div class="custdet-dashboard-item green">
                        <h3>Open Invoices</h3>
                        <p id="openInvoices">0</p>
                    </div>
                    <div class="custdet-dashboard-item green">
                        <h3>Unpaid Invoices</h3>
                        <p id="unpaidInvoices">0</p>
                    </div>
                    <div class="custdet-dashboard-item green">
                        <h3>Paid Invoices</h3>
                        <p id="paidInvoices">0</p>
                    </div>
                </div>
            </div>

            <!-- Basic Info -->
            <div class="custdet-section">
                <h2 class="custdet-section-title">Basic Information</h2>
                <table class="custdet-table">
                    <thead>
                        <tr>
                            <th>Field</th>
                            <th>Details</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td class="custdet-table-label">Customer Name</td>
                            <td id="customerName">Loading...</td>
                        </tr>
                        <tr>
                            <td class="custdet-table-label">Site Contact</td>
                            <td id="siteContactInfo">Loading...</td>
                        </tr>
                        <tr>
                            <td class="custdet-table-label">Address</td>
                            <td id="siteAddress">Loading...</td>
                        </tr>
                        <tr>
                            <td class="custdet-table-label">Status</td>
                            <td id="siteStatus">Loading...</td>
                        </tr>
                        <tr>
                            <td class="custdet-table-label">Description</td>
                            <td id="siteDescription">Loading...</td>
                        </tr>
                        <tr>
                            <td class="custdet-table-label">Special Instructions</td>
                            <td id="siteSpecialInstructions">Loading...</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Service & Appointments -->
            <div class="custdet-section">
                <h2 class="custdet-section-title">Service & Appointments</h2>
                <div class="custdet-filter-container" id="appointmentFilter">
                    <button class="custdet-filter-btn active" data-status="all">All</button>
                    <button class="custdet-filter-btn" data-status="scheduler">Scheduler</button>
                    <button class="custdet-filter-btn" data-status="pending">Pending</button>
                    <button class="custdet-filter-btn" data-status="completed">Completed</button>
                    <!-- Custom tags will be dynamically added here -->
                </div>
                <div class="custdet-list" id="appointmentList">
                    <div class="custdet-no-items">No appointments available</div>
                </div>
            </div>

            <!-- Invoices & Estimates -->
            <div class="custdet-section">
                <h2 class="custdet-section-title">Invoices & Estimates</h2>
                <div class="custdet-filter-container" id="invoiceFilter">
                    <button class="custdet-filter-btn active" data-status="all">All</button>
                    <button class="custdet-filter-btn" data-status="in-progress">In Progress</button>
                    <button class="custdet-filter-btn" data-status="complete-unpaid">Complete/Unpaid</button>
                    <button class="custdet-filter-btn" data-status="paid">Paid</button>
                    <!-- Custom tags will be dynamically added here -->
                </div>
                <div class="custdet-list" id="invoiceList">
                    <div class="custdet-no-items">No invoices or estimates available</div>
                </div>
            </div>

            <!-- Equipment -->
            <div class="custdet-section">
                <h2 class="custdet-section-title">Equipment</h2>
                <table class="custdet-table">
                    <thead>
                        <tr>
                            <th>Equipment</th>
                            <th>Serial</th>
                            <th>Warranty</th>
                        </tr>
                    </thead>
                    <tbody id="siteEquipmentList">
                        <tr>
                            <td colspan="3">Loading...</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Work Order -->
            <div class="custdet-section">
                <h2 class="custdet-section-title">Work Order</h2>
                <table class="custdet-table">
                    <thead>
                        <tr>
                            <th>Field</th>
                            <th>Details</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td class="custdet-table-label">Work Order Description</td>
                            <td id="siteWorkOrderDesc">Loading...</td>
                        </tr>
                        <tr>
                            <td class="custdet-table-label">Work Order Status</td>
                            <td id="siteWorkOrderStatus">Loading...</td>
                        </tr>
                        <tr>
                            <td class="custdet-table-label">Resource Assignments</td>
                            <td id="siteResourceAssignments">Loading...</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Service Agreements -->
            <div class="custdet-section">
                <h2 class="custdet-section-title">Service Agreements</h2>
                <table class="custdet-table">
                    <thead>
                        <tr>
                            <th>Agreement</th>
                            <th>Details</th>
                            <th>Alarms</th>
                        </tr>
                    </thead>
                    <tbody id="siteServiceAgreements">
                        <tr>
                            <td colspan="3">Loading...</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Documents -->
            <div class="custdet-section">
                <h2 class="custdet-section-title">Documents</h2>
                <table class="custdet-table">
                    <thead>
                        <tr>
                            <th>Document</th>
                            <th>Status</th>
                            <th>Link</th>
                        </tr>
                    </thead>
                    <tbody id="siteDocuments">
                        <tr>
                            <td colspan="3">Loading...</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Additional Details -->
            <div class="custdet-section">
                <h2 class="custdet-section-title">Additional Details</h2>
                <table class="custdet-table">
                    <thead>
                        <tr>
                            <th>Field</th>
                            <th>Details</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td class="custdet-table-label">Internal Notes</td>
                            <td id="siteInternalNotes">Loading...</td>
                        </tr>
                        <tr>
                            <td class="custdet-table-label">Site History Link</td>
                            <td><a href="#" class="custdet-link" id="siteHistoryLink">View Full History</a></td>
                        </tr>
                        <tr>
                            <td class="custdet-table-label">Billable Items</td>
                            <td id="siteBillableItems">Loading...</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Pictures Section -->
            <div class="custdet-section">
                <h2 class="custdet-section-title">Pictures</h2>
                <div class="custdet-gallery" id="sitePictures">
                    <span class="custdet-no-pics">No pictures uploaded</span>
                </div>
            </div>

            <!-- Customer Message Section -->
            <div class="custdet-section">
                <h2 class="custdet-section-title">Customer Message</h2>
                <div class="custdet-message-container">
                    <select id="siteMessageTemplate" class="custdet-message-select">
                        <option value="">Select a template (from CEC)</option>
                        <option value="Service Scheduled">Service Scheduled</option>
                        <option value="Invoice Ready">Invoice Ready</option>
                    </select>
                    <button class="custdet-send-btn" id="sendMessageBtn">Send</button>
                </div>
            </div>

            <!-- Back Button -->
            <div class="custdet-back-container">
                <a href="Customer.aspx" class="custdet-back-btn">Back to Customers</a>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            // Get siteId from URL query parameter
            const urlParams = new URLSearchParams(window.location.search);
            const siteId = urlParams.get('siteId');

            // Mock data for demonstration (client-side only)
            const siteData = {
                1: {
                    customerName: 'John Doe',
                    name: 'Main Residence',
                    address: '123 Elm St, City, ST 12345',
                    siteContact: 'Jane Smith (Site Manager) - (555) 987-6543',
                    status: 'Active',
                    description: 'Primary residence location',
                    specialInstructions: 'Ensure gate is locked after entry',
                    equipment: [
                        { name: 'HVAC Unit', serial: 'ABC123', warranty: 'Active until 2026' }
                    ],
                    appointments: [
                        { id: 1, description: 'HVAC maintenance', status: 'scheduler', date: '04/01/2025', customTags: ['urgent'] },
                        { id: 2, description: 'Filter replacement', status: 'pending', date: '04/05/2025', customTags: ['follow-up'] },
                        { id: 3, description: 'Annual checkup', status: 'completed', date: '03/10/2025', customTags: [] },
                        { id: 4, description: 'System inspection', status: 'completed', date: '02/01/2025', customTags: ['urgent'] },
                        { id: 5, description: 'Thermostat repair', status: 'completed', date: '01/15/2025', customTags: [] },
                        { id: 6, description: 'Duct cleaning', status: 'completed', date: '12/01/2024', customTags: ['follow-up'] },
                        { id: 7, description: 'Emergency repair', status: 'completed', date: '11/01/2024', customTags: ['urgent'] },
                        { id: 8, description: 'Routine maintenance', status: 'completed', date: '10/01/2024', customTags: [] }
                    ],
                    invoices: [
                        { id: 1, type: 'estimate', description: 'HVAC upgrade estimate', amount: '$1200', status: 'in-progress', customTags: ['urgent'] },
                        { id: 2, type: 'invoice', description: 'HVAC maintenance', amount: '$450', status: 'in-progress', customTags: [] },
                        { id: 3, type: 'invoice', description: 'Filter replacement', amount: '$150', status: 'complete-unpaid', customTags: ['follow-up'] },
                        { id: 4, type: 'invoice', description: 'Annual checkup', amount: '$300', status: 'complete-unpaid', customTags: [] },
                        { id: 5, type: 'invoice', description: 'System inspection', amount: '$200', status: 'complete-unpaid', customTags: ['urgent'] },
                        { id: 6, type: 'invoice', description: 'Thermostat repair', amount: '$250', status: 'complete-unpaid', customTags: [] },
                        { id: 7, type: 'invoice', description: 'Duct cleaning', amount: '$400', status: 'complete-unpaid', customTags: ['follow-up'] },
                        { id: 8, type: 'invoice', description: 'Emergency repair', amount: '$600', status: 'complete-unpaid', customTags: ['urgent'] },
                        { id: 9, type: 'invoice', description: 'Routine maintenance', amount: '$300', status: 'paid', customTags: [] },
                        { id: 10, type: 'invoice', description: 'Filter replacement', amount: '$150', status: 'paid', customTags: [] },
                        { id: 11, type: 'invoice', description: 'Annual checkup', amount: '$300', status: 'paid', customTags: [] }
                    ],
                    workOrder: {
                        description: 'HVAC maintenance scheduled',
                        status: 'Open',
                        resourceAssignments: 'Tech: Jane Doe'
                    },
                    serviceAgreements: [
                        { name: 'Annual Maintenance', details: 'Contract signed on 01/01/2025', alarms: 'Next service due: 01/01/2026' }
                    ],
                    documents: [
                        { name: 'Service Contract', status: 'Signed', link: '#' }
                    ],
                    internalNotes: 'Check filter replacement on next visit',
                    billableItems: 'HVAC Service - $450 (Synced to QBO)',
                    pictures: [],
                    dashboard: {
                        appointments: { pending: 1, scheduled: 1, completed: 6, custom: 3 },
                        invoices: { estimates: 1, open: 1, unpaid: 6, paid: 3 }
                    }
                },
                2: {
                    customerName: 'John Doe',
                    name: 'Vacation Home',
                    address: '456 Oak Rd, City, ST 12345',
                    siteContact: 'Mike Johnson (Caretaker) - (555) 456-7890',
                    status: 'Active',
                    description: 'Secondary vacation property',
                    specialInstructions: 'Access through back entrance only',
                    equipment: [
                        { name: 'Generator', serial: 'XYZ456', warranty: 'Active until 2027' }
                    ],
                    appointments: [
                        { id: 1, description: 'Generator maintenance', status: 'scheduler', date: '04/15/2025', customTags: ['urgent'] },
                        { id: 2, description: 'Fuel check', status: 'completed', date: '02/15/2025', customTags: [] },
                        { id: 3, description: 'System inspection', status: 'completed', date: '01/10/2025', customTags: ['follow-up'] },
                        { id: 4, description: 'Routine maintenance', status: 'completed', date: '12/01/2024', customTags: [] },
                        { id: 5, description: 'Emergency repair', status: 'completed', date: '11/01/2024', customTags: ['urgent'] }
                    ],
                    invoices: [
                        { id: 1, type: 'invoice', description: 'Generator maintenance', amount: '$300', status: 'in-progress', customTags: [] },
                        { id: 2, type: 'invoice', description: 'Fuel check', amount: '$100', status: 'complete-unpaid', customTags: ['follow-up'] },
                        { id: 3, type: 'invoice', description: 'System inspection', amount: '$200', status: 'complete-unpaid', customTags: [] },
                        { id: 4, type: 'invoice', description: 'Routine maintenance', amount: '$250', status: 'complete-unpaid', customTags: [] },
                        { id: 5, type: 'invoice', description: 'Emergency repair', amount: '$500', status: 'paid', customTags: ['urgent'] },
                        { id: 6, type: 'invoice', description: 'Fuel check', amount: '$100', status: 'paid', customTags: [] }
                    ],
                    workOrder: {
                        description: 'Generator maintenance scheduled',
                        status: 'Open',
                        resourceAssignments: 'Tech: Bob Smith'
                    },
                    serviceAgreements: [
                        { name: 'Generator Service Plan', details: 'Contract signed on 01/15/2025', alarms: 'Next service due: 01/15/2026' }
                    ],
                    documents: [
                        { name: 'Generator Contract', status: 'Signed', link: '#' }
                    ],
                    internalNotes: 'Verify fuel levels on next visit',
                    billableItems: 'Generator Service - $300 (Synced to QBO)',
                    pictures: [],
                    dashboard: {
                        appointments: { pending: 0, scheduled: 1, completed: 4, custom: 2 },
                        invoices: { estimates: 0, open: 1, unpaid: 3, paid: 2 }
                    }
                }
            };

            // Default to unknown site if no siteId or invalid
            const site = siteData[siteId] || {
                customerName: 'Unknown Customer',
                name: 'Unknown Site',
                address: 'N/A',
                siteContact: 'N/A',
                status: 'Unknown',
                description: 'No description available',
                specialInstructions: 'N/A',
                equipment: [],
                appointments: [],
                invoices: [],
                workOrder: {
                    description: 'N/A',
                    status: 'N/A',
                    resourceAssignments: 'N/A'
                },
                serviceAgreements: [],
                documents: [],
                internalNotes: 'N/A',
                billableItems: 'N/A',
                pictures: [],
                dashboard: {
                    appointments: { pending: 0, scheduled: 0, completed: 0, custom: 0 },
                    invoices: { estimates: 0, open: 0, unpaid: 0, paid: 0 }
                }
            };

            // Populate Dashboard
            document.getElementById('pendingAppointments').textContent = site.dashboard.appointments.pending;
            document.getElementById('scheduledAppointments').textContent = site.dashboard.appointments.scheduled;
            document.getElementById('completedAppointments').textContent = site.dashboard.appointments.completed;
            document.getElementById('customTabs').textContent = site.dashboard.appointments.custom;
            document.getElementById('estimates').textContent = site.dashboard.invoices.estimates;
            document.getElementById('openInvoices').textContent = site.dashboard.invoices.open;
            document.getElementById('unpaidInvoices').textContent = site.dashboard.invoices.unpaid;
            document.getElementById('paidInvoices').textContent = site.dashboard.invoices.paid;

            // Populate Basic Info
            document.getElementById('siteDetailsName').textContent = site.name;
            document.getElementById('customerName').textContent = site.customerName;
            document.getElementById('siteContactInfo').textContent = site.siteContact;
            document.getElementById('siteAddress').textContent = site.address;
            document.getElementById('siteStatus').textContent = site.status;
            document.getElementById('siteDescription').textContent = site.description;
            document.getElementById('siteSpecialInstructions').textContent = site.specialInstructions;

            // Populate Appointments with Filters
            const appointmentFilter = document.getElementById('appointmentFilter');
            const appointmentList = document.getElementById('appointmentList');

            // Extract unique custom tags for appointments
            const appointmentCustomTags = [...new Set(site.appointments.flatMap(app => app.customTags))];
            appointmentCustomTags.forEach(tag => {
                const btn = document.createElement('button');
                btn.className = 'custdet-filter-btn';
                btn.dataset.status = tag;
                btn.textContent = tag.charAt(0).toUpperCase() + tag.slice(1);
                appointmentFilter.appendChild(btn);
            });

            // Function to render appointments based on filter
            function renderAppointments(filterStatus) {
                appointmentList.innerHTML = '';
                const filteredAppointments = filterStatus === 'all'
                    ? site.appointments
                    : site.appointments.filter(app =>
                        filterStatus === app.status || app.customTags.includes(filterStatus)
                    );

                if (filteredAppointments.length > 0) {
                    filteredAppointments.forEach(app => {
                        const item = document.createElement('div');
                        item.className = 'custdet-list-item';
                        item.innerHTML = `
                            <span><strong>ID:</strong> ${app.id}</span>
                            <span><strong>Description:</strong> ${app.description}</span>
                            <span><strong>Status:</strong> ${app.status.charAt(0).toUpperCase() + app.status.slice(1)}</span>
                            <span><strong>Date:</strong> ${app.date}</span>
                            <span><strong>Custom Tags:</strong> ${app.customTags.length > 0 ? app.customTags.join(', ') : 'None'}</span>
                        `;
                        appointmentList.appendChild(item);
                    });
                } else {
                    appointmentList.innerHTML = '<div class="custdet-no-items">No appointments for this status</div>';
                }
            }

            // Initial render
            renderAppointments('all');

            // Add filter event listeners
            appointmentFilter.querySelectorAll('.custdet-filter-btn').forEach(btn => {
                btn.addEventListener('click', () => {
                    appointmentFilter.querySelectorAll('.custdet-filter-btn').forEach(b => b.classList.remove('active'));
                    btn.classList.add('active');
                    renderAppointments(btn.dataset.status);
                });
            });

            // Populate Invoices & Estimates with Filters
            const invoiceFilter = document.getElementById('invoiceFilter');
            const invoiceList = document.getElementById('invoiceList');

            // Extract unique custom tags for invoices
            const invoiceCustomTags = [...new Set(site.invoices.flatMap(inv => inv.customTags))];
            invoiceCustomTags.forEach(tag => {
                const btn = document.createElement('button');
                btn.className = 'custdet-filter-btn';
                btn.dataset.status = tag;
                btn.textContent = tag.charAt(0).toUpperCase() + tag.slice(1);
                invoiceFilter.appendChild(btn);
            });

            // Function to render invoices based on filter
            function renderInvoices(filterStatus) {
                invoiceList.innerHTML = '';
                const filteredInvoices = filterStatus === 'all'
                    ? site.invoices
                    : site.invoices.filter(inv =>
                        filterStatus === inv.status || inv.customTags.includes(filterStatus)
                    );

                if (filteredInvoices.length > 0) {
                    filteredInvoices.forEach(inv => {
                        const item = document.createElement('div');
                        item.className = 'custdet-list-item';
                        item.innerHTML = `
                            <span><strong>ID:</strong> ${inv.id}</span>
                            <span><strong>Type:</strong> ${inv.type.charAt(0).toUpperCase() + inv.type.slice(1)}</span>
                            <span><strong>Description:</strong> ${inv.description}</span>
                            <span><strong>Amount:</strong> ${inv.amount}</span>
                            <span><strong>Status:</strong> ${inv.status.replace('-', ' ').split(' ').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ')}</span>
                            <span><strong>Custom Tags:</strong> ${inv.customTags.length > 0 ? inv.customTags.join(', ') : 'None'}</span>
                        `;
                        invoiceList.appendChild(item);
                    });
                } else {
                    invoiceList.innerHTML = '<div class="custdet-no-items">No invoices or estimates for this status</div>';
                }
            }

            // Initial render
            renderInvoices('all');

            // Add filter event listeners
            invoiceFilter.querySelectorAll('.custdet-filter-btn').forEach(btn => {
                btn.addEventListener('click', () => {
                    invoiceFilter.querySelectorAll('.custdet-filter-btn').forEach(b => b.classList.remove('active'));
                    btn.classList.add('active');
                    renderInvoices(btn.dataset.status);
                });
            });

            // Populate Equipment Table
            const equipmentList = document.getElementById('siteEquipmentList');
            equipmentList.innerHTML = '';
            if (site.equipment && site.equipment.length > 0) {
                site.equipment.forEach(item => {
                    equipmentList.innerHTML += `
                        <tr>
                            <td>${item.name}</td>
                            <td>${item.serial}</td>
                            <td>${item.warranty}</td>
                        </tr>
                    `;
                });
            } else {
                equipmentList.innerHTML = '<tr><td colspan="3">No equipment listed</td></tr>';
            }

            // Populate Work Order
            document.getElementById('siteWorkOrderDesc').textContent = site.workOrder.description;
            document.getElementById('siteWorkOrderStatus').textContent = site.workOrder.status;
            document.getElementById('siteResourceAssignments').textContent = site.workOrder.resourceAssignments;

            // Populate Service Agreements
            const serviceAgreementsList = document.getElementById('siteServiceAgreements');
            serviceAgreementsList.innerHTML = '';
            if (site.serviceAgreements && site.serviceAgreements.length > 0) {
                site.serviceAgreements.forEach(agreement => {
                    serviceAgreementsList.innerHTML += `
                        <tr>
                            <td>${agreement.name}</td>
                            <td>${agreement.details}</td>
                            <td>${agreement.alarms}</td>
                        </tr>
                    `;
                });
            } else {
                serviceAgreementsList.innerHTML = '<tr><td colspan="3">No service agreements</td></tr>';
            }

            // Populate Documents
            const documentsList = document.getElementById('siteDocuments');
            documentsList.innerHTML = '';
            if (site.documents && site.documents.length > 0) {
                site.documents.forEach(doc => {
                    documentsList.innerHTML += `
                        <tr>
                            <td>${doc.name}</td>
                            <td>${doc.status}</td>
                            <td><a href="${doc.link}" class="custdet-link">View Document</a></td>
                        </tr>
                    `;
                });
            } else {
                documentsList.innerHTML = '<tr><td colspan="3">No documents available</td></tr>';
            }

            // Populate Additional Details
            document.getElementById('siteInternalNotes').textContent = site.internalNotes;
            document.getElementById('siteBillableItems').textContent = site.billableItems;

            // Populate Pictures
            const imageGallery = document.getElementById('sitePictures');
            imageGallery.innerHTML = '';
            if (site.pictures && site.pictures.length > 0) {
                site.pictures.forEach(src => {
                    const img = document.createElement('img');
                    img.src = src;
                    img.style.cssText = 'max-width: 100px; max-height: 100px; border-radius: 8px; object-fit: cover;';
                    imageGallery.appendChild(img);
                });
            } else {
                imageGallery.innerHTML = '<span class="custdet-no-pics">No pictures uploaded</span>';
            }

            // Send Message Button
            const sendMessageBtn = document.getElementById('sendMessageBtn');
            if (sendMessageBtn) {
                sendMessageBtn.addEventListener('click', () => {
                    const template = document.getElementById('siteMessageTemplate').value;
                    if (template) {
                        alert(`Sending "${template}" to customer for ${site.name}...`);
                    } else {
                        alert('Please select a message template.');
                    }
                });
            }
        });
    </script>
</asp:Content>