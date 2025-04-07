<%@ Page Title="Customer Site Details" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="CustomerDetails.aspx.cs" Inherits="FSM.CustomerDetails" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style type="text/css">
        .custdet-container { padding: 20px; margin-top: 35px; }
        .custdet-title { font-size: 28px; font-weight: bold; color: #2d3748; margin-bottom: 20px; }
        .custdet-content { background: #fff; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); padding: 20px; }
        .custdet-section { margin-bottom: 30px; }
        .custdet-section-title { font-size: 20px; font-weight: 600; color: #4a5568; margin-bottom: 15px; }
        
        .custdet-table { width: 100%; border-collapse: collapse; margin-bottom: 15px; }
        .custdet-table th, .custdet-table td { padding: 10px; border: 1px solid #e2e8f0; }
        .custdet-table th { background: #edf2f7; font-weight: 600; color: #4a5568; }
        .custdet-table td { color: #2d3748; }
        
        .custdet-controls { display: flex; gap: 10px; margin-bottom: 15px; flex-wrap: wrap; }
        .custdet-input { padding: 8px; border: 1px solid #cbd5e0; border-radius: 4px; flex: 1; min-width: 200px; }
        .custdet-select { padding: 8px; border: 1px solid #cbd5e0; border-radius: 4px; min-width: 150px; }
        .custdet-btn { padding: 8px 16px; border-radius: 4px; border: none; cursor: pointer; }
        .custdet-btn-primary { background: #3182ce; color: #fff; }
        .custdet-btn-primary:hover { background: #2b6cb0; }
        .custdet-btn-secondary { background: #e2e8f0; color: #4a5568; }
        .custdet-btn-secondary:hover { background: #cbd5e0; }
        
        .custdet-pagination { display: flex; justify-content: space-between; align-items: center; margin-top: 10px; }
        .custdet-page-info { color: #4a5568; }
        
        .custdet-gallery { display: flex; flex-wrap: wrap; gap: 10px; }
        .custdet-gallery-item { position: relative; }
        .custdet-gallery img { max-width: 120px; max-height: 120px; border-radius: 4px; object-fit: cover; }
        .custdet-delete-btn { position: absolute; top: 5px; right: 5px; background: #e53e3e; color: #fff; border: none; border-radius: 50%; width: 20px; height: 20px; cursor: pointer; }
        
        .custdet-overview { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .custdet-card { 
            padding: 20px; 
            border-radius: 12px; 
            color: #fff; 
            text-align: center; 
            box-shadow: 0 4px 6px rgba(0,0,0,0.1), 0 1px 3px rgba(0,0,0,0.08); 
            transition: transform 0.2s ease, box-shadow 0.2s ease; 
        }
        .custdet-card:hover { 
            transform: translateY(-2px); 
            box-shadow: 0 7px 14px rgba(0,0,0,0.1), 0 3px 6px rgba(0,0,0,0.08); 
        }
        .custdet-card.appointment { 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
        }
        .custdet-card.invoice { 
            background: linear-gradient(135deg, #48bb78 0%, #38a169 100%); 
        }
        .custdet-card h3 { font-size: 16px; font-weight: 600; margin-bottom: 12px; opacity: 0.9; }
        .custdet-card p { font-size: 28px; font-weight: bold; }
    </style>

    <div class="custdet-container">
        <h1 class="custdet-title">Site Details: <span id="siteName">Loading...</span></h1>
        <div class="custdet-content">
            <!-- Overview -->
            <div class="custdet-section">
                <h2 class="custdet-section-title">Overview</h2>
                <div class="custdet-overview">
                    <div class="custdet-card appointment">
                        <h3>Pending Appointments</h3>
                        <p id="pendingAppts"><asp:Label ID="lblpendingAppts" runat="server" /></p>
                    </div>
                    <div class="custdet-card appointment">
                        <h3>Scheduled Appointments</h3>
                        <p id="scheduledAppts"><asp:Label ID="lblscheduledAppts" runat="server" /></p>
                    </div>
                    <div class="custdet-card appointment">
                        <h3>Completed Appointments</h3>
                        <p id="completedAppts"><asp:Label ID="lblcompletedAppts" runat="server" /></p>
                    </div>
                    <div class="custdet-card appointment">
                        <h3>Custom Tags</h3>
                        <p id="customTags"><asp:Label ID="lblcustomTags" runat="server" /></p>
                    </div>
                    <div class="custdet-card invoice">
                        <h3>Estimates</h3>
                        <p id="estimates"><asp:Label ID="lblestimates" runat="server" /></p>
                    </div>
                    <div class="custdet-card invoice">
                        <h3>Open Invoices</h3>
                        <p id="openInvoices"><asp:Label ID="lblopenInvoices" runat="server" /></p>
                    </div>
                    <div class="custdet-card invoice">
                        <h3>Unpaid Invoices</h3>
                        <p id="unpaidInvoices"><asp:Label ID="lblunpaidInvoices" runat="server" /></p>
                    </div>
                    <div class="custdet-card invoice">
                        <h3>Paid Invoices</h3>
                        <p id="paidInvoices"><asp:Label ID="lblpaidInvoices" runat="server" /></p>
                    </div>
                </div>
            </div>

            <!-- Basic Information -->
            <div class="custdet-section">
                <h2 class="custdet-section-title">Basic Information</h2>
                <table class="custdet-table">
                    <thead>
                        <tr>
                            <th>Field</th>
                            <th>Value</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr><td>Customer Name</td><td id="customerName"><asp:Label ID="lblCustomerName" runat="server" /></td></tr>
                        <tr><td>Site Contact</td><td id="siteContact"><asp:Label ID="lblPhone" runat="server" /></td></tr>
                        <tr><td>Address</td><td id="siteAddress"><asp:Label ID="lblAddress1" runat="server" /></td></tr>
                        <tr><td>Status</td><td id="siteStatus">Loading...</td></tr>
                        <tr><td>Description</td><td id="siteDescription">Loading...</td></tr>
                        <tr><td>Special Instructions</td><td id="siteInstructions">Loading...</td></tr>
                    </tbody>
                </table>
            </div>

            <!-- Service & Appointments -->
            <div class="custdet-section">
                <h2 class="custdet-section-title">Service & Appointments</h2>
                <div class="custdet-controls">
                    <input type="text" id="apptSearch" class="custdet-input" placeholder="Search appointments...">
                    <select id="apptFilter" class="custdet-select">
                        <option value="all">All Status</option>
                        <option value="scheduler">Scheduler</option>
                        <option value="pending">Pending</option>
                        <option value="completed">Completed</option>
                    </select>
                    <button id="apptExport" class="custdet-btn custdet-btn-primary">Export to Excel</button>
                </div>
                <table class="custdet-table">
                    <thead>
                        <tr>
                            <th>Request Date</th>
                            <th>Time Slot</th>
                            <th>Service Type</th>
                            <th>Status</th>
                            <th>Resource</th>
                            <th>Ticket Status</th>
                            <th>Custom Tags</th>
                        </tr>
                    </thead>
                    <tbody id="apptTableBody"></tbody>
                </table>
                <div class="custdet-pagination">
                    <button id="apptPrev" class="custdet-btn custdet-btn-secondary">Previous</button>
                    <span id="apptPageInfo" class="custdet-page-info">Page 1 of 1</span>
                    <button id="apptNext" class="custdet-btn custdet-btn-secondary">Next</button>
                </div>
            </div>

            <!-- Invoices & Estimates -->
            <div class="custdet-section">
                <h2 class="custdet-section-title">Invoices & Estimates</h2>
                <div class="custdet-controls">
                    <input type="text" id="invSearch" class="custdet-input" placeholder="Search invoices...">
                    <select id="invFilter" class="custdet-select">
                        <option value="all">All Status</option>
                        <option value="in-progress">In Progress</option>
                        <option value="complete-unpaid">Complete/Unpaid</option>
                        <option value="paid">Paid</option>
                    </select>
                    <button id="invExport" class="custdet-btn custdet-btn-primary">Export to Excel</button>
                </div>
                <table class="custdet-table">
                    <thead>
                        <tr>
                            <th>Type</th>
                            <th>Number</th>
                            <th>Date</th>
                            <th>Subtotal</th>
                            <th>Discount</th>
                            <th>Tax</th>
                            <th>Total</th>
                            <th>Due</th>
                            <th>Status</th>
                            <th>Custom Tags</th>
                        </tr>
                    </thead>
                    <tbody id="invTableBody"></tbody>
                </table>
                <div class="custdet-pagination">
                    <button id="invPrev" class="custdet-btn custdet-btn-secondary">Previous</button>
                    <span id="invPageInfo" class="custdet-page-info">Page 1 of 1</span>
                    <button id="invNext" class="custdet-btn custdet-btn-secondary">Next</button>
                </div>
            </div>

            <!-- Equipment -->
            <div class="custdet-section">
                <h2 class="custdet-section-title">Equipment</h2>
                <table class="custdet-table">
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Serial</th>
                            <th>Warranty</th>
                            <th>Pictures</th>
                        </tr>
                    </thead>
                    <tbody id="equipTableBody"></tbody>
                </table>
            </div>

            <!-- Service Agreements -->
            <div class="custdet-section">
                <h2 class="custdet-section-title">Service Agreements</h2>
                <table class="custdet-table">
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Details</th>
                            <th>Alarms</th>
                        </tr>
                    </thead>
                    <tbody id="agreementTableBody"></tbody>
                </table>
            </div>

            <!-- Documents -->
            <div class="custdet-section">
                <h2 class="custdet-section-title">Documents</h2>
                <table class="custdet-table">
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Status</th>
                            <th>Link</th>
                        </tr>
                    </thead>
                    <tbody id="docTableBody"></tbody>
                </table>
            </div>

            <!-- Custom Fields -->
            <div class="custdet-section">
                <h2 class="custdet-section-title">Custom Fields</h2>
                <table class="custdet-table">
                    <thead>
                        <tr>
                            <th>Field</th>
                            <th>Value</th>
                        </tr>
                    </thead>
                    <tbody id="customTableBody"></tbody>
                </table>
            </div>

            <!-- Pictures -->
            <div class="custdet-section">
                <h2 class="custdet-section-title">Pictures</h2>
                <div class="custdet-controls">
                    <select id="picCategory" class="custdet-select">
                        <option value="equipment">Equipment</option>
                        <option value="service">Service</option>
                        <option value="folder">Folder</option>
                    </select>
                    <input type="file" id="picUpload" accept="image/*" class="custdet-input">
                    <button id="picUploadBtn" class="custdet-btn custdet-btn-primary">Upload</button>
                </div>
                <div class="custdet-gallery" id="picGallery"></div>
            </div>

            <!-- Customer Message -->
            <div class="custdet-section">
                <h2 class="custdet-section-title">Customer Message</h2>
                <div class="custdet-controls">
                    <select id="msgTemplate" class="custdet-select">
                        <option value="">Select Template</option>
                        <option value="service">Service Scheduled</option>
                        <option value="invoice">Invoice Ready</option>
                    </select>
                    <button id="msgSend" class="custdet-btn custdet-btn-primary">Send</button>
                </div>
            </div>

            <!-- Back Button -->
            <div style="text-align: right;">
                <a href="Customer.aspx" class="custdet-btn custdet-btn-secondary">Back to Customers</a>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const ITEMS_PER_PAGE = 5;

            // Dummy Data
            const siteData = {
                1: {
                    name: "Main Office",
                    customerName: "Acme Corp",
                    siteContact: "John Doe - (555) 123-4567",
                    address: "123 Business St, City, ST 12345",
                    status: "Active",
                    description: "Primary business location",
                    specialInstructions: "Use back entrance after 5 PM",
                    appointments: [
                        { requestDate: "2025-03-25", timeSlot: "09:00-11:00", serviceType: "HVAC Maintenance", status: "scheduler", resource: "Tech A", ticketStatus: "Open", customTags: ["urgent"] },
                        { requestDate: "2025-03-20", timeSlot: "13:00-15:00", serviceType: "Electrical Check", status: "pending", resource: "Tech B", ticketStatus: "Open", customTags: [] },
                        { requestDate: "2025-03-15", timeSlot: "10:00-12:00", serviceType: "Plumbing", status: "completed", resource: "Tech C", ticketStatus: "Closed", customTags: ["follow-up"] }
                    ],
                    invoices: [
                        { type: "invoice", number: "INV-001", date: "2025-03-20", subtotal: "$500", discount: "$0", tax: "$40", total: "$540", due: "$540", status: "in-progress", customTags: [] },
                        { type: "estimate", number: "EST-001", date: "2025-03-18", subtotal: "$1200", discount: "$100", tax: "$80", total: "$1180", due: "$1180", status: "in-progress", customTags: ["urgent"] },
                        { type: "invoice", number: "INV-002", date: "2025-03-10", subtotal: "$300", discount: "$0", tax: "$24", total: "$324", due: "$0", status: "paid", customTags: [] }
                    ],
                    equipment: [
                        { name: "HVAC Unit", serial: "HV12345", warranty: "Until 2026" },
                        { name: "Generator", serial: "GN67890", warranty: "Until 2027" }
                    ],
                    serviceAgreements: [
                        { name: "Annual Maintenance", details: "Signed 2025-01-01", alarms: "Next due 2026-01-01" }
                    ],
                    documents: [
                        { name: "Contract", status: "Signed", link: "#" }
                    ],
                    internalNotes: "Check HVAC filters quarterly",
                    billableItems: "Maintenance - $500",
                    overview: {
                        appointments: { pending: 1, scheduled: 1, completed: 1, custom: 1 },
                        invoices: { estimates: 1, open: 1, unpaid: 0, paid: 1 }
                    }
                }
            };

            const urlParams = new URLSearchParams(window.location.search);
            const siteId = urlParams.get('siteId');
            const site = siteData[siteId] || {
                name: "Unknown Site",
                //customerName: "Unknown",
                //siteContact: "N/A",
                //address: "N/A",
                status: "N/A",
                description: "N/A",
                specialInstructions: "N/A",
                appointments: [],
                invoices: [],
                equipment: [],
                serviceAgreements: [],
                documents: [],
                internalNotes: "N/A",
                billableItems: "N/A",
                overview: { appointments: { pending: 0, scheduled: 0, completed: 0, custom: 0 }, invoices: { estimates: 0, open: 0, unpaid: 0, paid: 0 } }
            };

            // Populate Overview
            //document.getElementById('pendingAppts').textContent = site.overview.appointments.pending;
            //document.getElementById('scheduledAppts').textContent = site.overview.appointments.scheduled;
            //document.getElementById('completedAppts').textContent = site.overview.appointments.completed;
            //document.getElementById('customTags').textContent = site.overview.appointments.custom;
            //document.getElementById('estimates').textContent = site.overview.invoices.estimates;
            //document.getElementById('openInvoices').textContent = site.overview.invoices.open;
            //document.getElementById('unpaidInvoices').textContent = site.overview.invoices.unpaid;
            //document.getElementById('paidInvoices').textContent = site.overview.invoices.paid;

            // Basic Info
            document.getElementById('siteName').textContent = site.name;
            //document.getElementById('customerName').textContent = site.customerName;
            //document.getElementById('siteContact').textContent = site.siteContact;
            //document.getElementById('siteAddress').textContent = site.address;
            document.getElementById('siteStatus').textContent = site.status;
            document.getElementById('siteDescription').textContent = site.description;
            document.getElementById('siteInstructions').textContent = site.specialInstructions;

            // Appointments
            function renderAppointments(page = 1, filter = 'all', search = '') {
                const tbody = document.getElementById('apptTableBody');
                const filtered = site.appointments.filter(a => 
                    (filter === 'all' || a.status === filter) &&
                    (!search || Object.values(a).some(v => v.toString().toLowerCase().includes(search)))
                );
                const totalPages = Math.ceil(filtered.length / ITEMS_PER_PAGE);
                const start = (page - 1) * ITEMS_PER_PAGE;
                const paginated = filtered.slice(start, start + ITEMS_PER_PAGE);

                tbody.innerHTML = paginated.map(a => `
                    <tr>
                        <td>${a.requestDate}</td>
                        <td>${a.timeSlot}</td>
                        <td>${a.serviceType}</td>
                        <td>${a.status}</td>
                        <td>${a.resource}</td>
                        <td>${a.ticketStatus}</td>
                        <td>${a.customTags.join(', ')}</td>
                    </tr>
                `).join('') || '<tr><td colspan="7">No appointments found</td></tr>';
                
                document.getElementById('apptPageInfo').textContent = `Page ${page} of ${totalPages}`;
                document.getElementById('apptPrev').disabled = page === 1;
                document.getElementById('apptNext').disabled = page === totalPages || totalPages === 0;
                return filtered;
            }

            let apptPage = 1;
            document.getElementById('apptPrev').addEventListener('click', () => { apptPage--; renderAppointments(apptPage, document.getElementById('apptFilter').value, document.getElementById('apptSearch').value.toLowerCase()); });
            document.getElementById('apptNext').addEventListener('click', () => { apptPage++; renderAppointments(apptPage, document.getElementById('apptFilter').value, document.getElementById('apptSearch').value.toLowerCase()); });
            document.getElementById('apptFilter').addEventListener('change', (e) => { apptPage = 1; renderAppointments(1, e.target.value, document.getElementById('apptSearch').value.toLowerCase()); });
            document.getElementById('apptSearch').addEventListener('input', (e) => { apptPage = 1; renderAppointments(1, document.getElementById('apptFilter').value, e.target.value.toLowerCase()); });
            document.getElementById('apptExport').addEventListener('click', () => {
                const data = renderAppointments(apptPage, document.getElementById('apptFilter').value, document.getElementById('apptSearch').value.toLowerCase());
                exportToExcel(data, 'appointments.xlsx', ['Request Date', 'Time Slot', 'Service Type', 'Status', 'Resource', 'Ticket Status', 'Custom Tags']);
            });

            // Invoices
            function renderInvoices(page = 1, filter = 'all', search = '') {
                const tbody = document.getElementById('invTableBody');
                const filtered = site.invoices.filter(i => 
                    (filter === 'all' || i.status === filter) &&
                    (!search || Object.values(i).some(v => v.toString().toLowerCase().includes(search)))
                );
                const totalPages = Math.ceil(filtered.length / ITEMS_PER_PAGE);
                const start = (page - 1) * ITEMS_PER_PAGE;
                const paginated = filtered.slice(start, start + ITEMS_PER_PAGE);

                tbody.innerHTML = paginated.map(i => `
                    <tr>
                        <td>${i.type}</td>
                        <td>${i.number}</td>
                        <td>${i.date}</td>
                        <td>${i.subtotal}</td>
                        <td>${i.discount}</td>
                        <td>${i.tax}</td>
                        <td>${i.total}</td>
                        <td>${i.due}</td>
                        <td>${i.status}</td>
                        <td>${i.customTags.join(', ')}</td>
                    </tr>
                `).join('') || '<tr><td colspan="10">No invoices found</td></tr>';

                document.getElementById('invPageInfo').textContent = `Page ${page} of ${totalPages}`;
                document.getElementById('invPrev').disabled = page === 1;
                document.getElementById('invNext').disabled = page === totalPages || totalPages === 0;
                return filtered;
            }

            let invPage = 1;
            document.getElementById('invPrev').addEventListener('click', () => { invPage--; renderInvoices(invPage, document.getElementById('invFilter').value, document.getElementById('invSearch').value.toLowerCase()); });
            document.getElementById('invNext').addEventListener('click', () => { invPage++; renderInvoices(invPage, document.getElementById('invFilter').value, document.getElementById('invSearch').value.toLowerCase()); });
            document.getElementById('invFilter').addEventListener('change', (e) => { invPage = 1; renderInvoices(1, e.target.value, document.getElementById('invSearch').value.toLowerCase()); });
            document.getElementById('invSearch').addEventListener('input', (e) => { invPage = 1; renderInvoices(1, document.getElementById('invFilter').value, e.target.value.toLowerCase()); });
            document.getElementById('invExport').addEventListener('click', () => {
                const data = renderInvoices(invPage, document.getElementById('invFilter').value, document.getElementById('invSearch').value.toLowerCase());
                exportToExcel(data, 'invoices.xlsx', ['Type', 'Number', 'Date', 'Subtotal', 'Discount', 'Tax', 'Total', 'Due', 'Status', 'Custom Tags']);
            });

            // Equipment
            const equipBody = document.getElementById('equipTableBody');
            equipBody.innerHTML = site.equipment.map(e => `
                <tr>
                    <td>${e.name}</td>
                    <td>${e.serial}</td>
                    <td>${e.warranty}</td>
                    <td><button class="custdet-btn custdet-btn-secondary" onclick="showPictures('equipment', '${e.serial}')">View Pictures</button></td>
                </tr>
            `).join('') || '<tr><td colspan="4">No equipment</td></tr>';

            // Service Agreements
            const agreeBody = document.getElementById('agreementTableBody');
            agreeBody.innerHTML = site.serviceAgreements.map(a => `
                <tr>
                    <td>${a.name}</td>
                    <td>${a.details}</td>
                    <td>${a.alarms}</td>
                </tr>
            `).join('') || '<tr><td colspan="3">No agreements</td></tr>';

            // Documents
            const docBody = document.getElementById('docTableBody');
            docBody.innerHTML = site.documents.map(d => `
                <tr>
                    <td>${d.name}</td>
                    <td>${d.status}</td>
                    <td><a href="${d.link}" target="_blank">View</a></td>
                </tr>
            `).join('') || '<tr><td colspan="3">No documents</td></tr>';

            // Custom Fields
            const customBody = document.getElementById('customTableBody');
            customBody.innerHTML = `
                <tr><td>Internal Notes</td><td>${site.internalNotes}</td></tr>
                <tr><td>Site History</td><td><a href="#" target="_blank">View History</a></td></tr>
                <tr><td>Billable Items</td><td>${site.billableItems}</td></tr>
            `;

            // Pictures
            let pictures = { equipment: {}, service: {}, folder: {} };
            function renderPictures(category, id = '') {
                const gallery = document.getElementById('picGallery');
                const pics = pictures[category][id] || [];
                gallery.innerHTML = pics.map((p, i) => `
                    <div class="custdet-gallery-item">
                        <img src="${p}" alt="Picture">
                        <button class="custdet-delete-btn" onclick="deletePicture('${category}', '${id}', ${i})">X</button>
                    </div>
                `).join('') || 'No pictures available';
            }

            window.showPictures = (category, id) => {
                document.getElementById('picCategory').value = category;
                renderPictures(category, id);
            };

            document.getElementById('picUploadBtn').addEventListener('click', () => {
                const file = document.getElementById('picUpload').files[0];
                const category = document.getElementById('picCategory').value;
                if (file) {
                    const reader = new FileReader();
                    reader.onload = (e) => {
                        const id = category === 'folder' ? '' : 'default';
                        if (!pictures[category][id]) pictures[category][id] = [];
                        pictures[category][id].push(e.target.result);
                        renderPictures(category, id);
                    };
                    reader.readAsDataURL(file);
                }
            });

            window.deletePicture = (category, id, index) => {
                pictures[category][id].splice(index, 1);
                renderPictures(category, id);
            };

            // Message
            document.getElementById('msgSend').addEventListener('click', () => {
                const template = document.getElementById('msgTemplate').value;
                if (template) alert(`Sending ${template} message...`);
            });

            // Excel Export (using SheetJS)
            function exportToExcel(data, filename, headers) {
                if (typeof XLSX === 'undefined') {
                    alert('SheetJS library is required for Excel export. Please include it in your project.');
                    return;
                }

                const mappedData = data.map(item => {
                    const row = {};
                    headers.forEach((header, index) => {
                        const key = Object.keys(item)[index];
                        row[header] = item[key];
                    });
                    return row;
                });

                const ws = XLSX.utils.json_to_sheet(mappedData, { header: headers });
                const wb = XLSX.utils.book_new();
                XLSX.utils.book_append_sheet(wb, ws, "Sheet1");
                XLSX.writeFile(wb, filename);
            }

            // Initial Render
            renderAppointments(1);
            renderInvoices(1);
            renderPictures('equipment');
        });
    </script>
</asp:Content>