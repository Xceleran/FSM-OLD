<%@ Page Title="Customer Site Details" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="CustomerDetails.aspx.cs" Inherits="FSM.CustomerDetails" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN" crossorigin="anonymous">
    
    <style type="text/css">
        .custdet-main-container { padding: 20px; margin-top: 35px; }
        .custdet-container { background: #fff; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); padding: 20px; margin-bottom: 20px; }
        .custdet-controls .input-group { max-width: 500px; display: flex; gap: 10px; }
        .custdet-controls .input-group .form-control,
        .custdet-controls .input-group .form-select { flex: 1; }
        .custdet-controls .btn { margin-left: 10px; }
        .custdet-gallery img { max-width: 120px; max-height: 120px; border-radius: 4px; object-fit: cover; }
        .custdet-gallery-item { position: relative; }
        .custdet-delete-btn { position: absolute; top: 5px; right: 5px; background: #dc3545; color: #fff; border: none; border-radius: 50%; width: 20px; height: 20px; font-size: 12px; line-height: 20px; text-align: center; cursor: pointer; }
        .custdet-pdf-preview { width: 100%; height: 300px; border: 1px solid #dee2e6; border-radius: 4px; }
        @media (max-width: 576px) {
            .custdet-controls .input-group { flex-direction: column; max-width: 100%; gap: 10px; }
            .custdet-controls .input-group > * { width: 100%; }
            .custdet-controls .btn { width: 100%; margin-left: 0; margin-top: 10px; }
        }
    </style>

    <div class="custdet-main-container">
        <h1 class="display-6 mb-4">Site Details: <span id="siteName">Loading...</span></h1>

        <!-- Basic Information Container -->
        <div class="custdet-container">
            <h2 class="h4 mb-3">Basic Information</h2>
            <div class="table-responsive">
                <table class="table table-bordered table-hover">
                    <thead class="table-light">
                        <tr>
                            <th scope="col">Field</th>
                            <th scope="col">Value</th>
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
        </div>

        <!-- Service & Appointments Container -->
        <div class="custdet-container">
            <h2 class="h4 mb-3">Service & Appointments</h2>
            <div class="custdet-controls mb-3 d-flex align-items-center flex-wrap gap-2">
                <div class="input-group">
                    <input type="text" id="apptSearch" class="form-control" placeholder="Search appointments...">
                    <select id="apptFilter" class="form-select">
                        <option value="all">All Status</option>
                        <option value="scheduler">Scheduler</option>
                        <option value="pending">Pending</option>
                        <option value="completed">Completed</option>
                    </select>
                </div>
                <button id="apptExport" class="btn btn-primary">Export to Excel</button>
            </div>
            <div class="table-responsive">
                <table class="table table-bordered table-hover">
                    <thead class="table-light">
                        <tr>
                            <th scope="col">Request Date</th>
                            <th scope="col">Time Slot</th>
                            <th scope="col">Service Type</th>
                            <th scope="col">Status</th>
                            <th scope="col">Resource</th>
                            <th scope="col">Ticket Status</th>
                            <th scope="col">Custom Tags</th>
                        </tr>
                    </thead>
                    <tbody id="apptTableBody"></tbody>
                </table>
            </div>
            <div class="d-flex justify-content-between align-items-center mt-3">
                <button id="apptPrev" class="btn btn-outline-secondary">Previous</button>
                <span id="apptPageInfo" class="text-muted">Page 1 of 1</span>
                <button id="apptNext" class="btn btn-outline-secondary">Next</button>
            </div>
        </div>

        <!-- Invoices & Estimates Container -->
        <div class="custdet-container">
            <h2 class="h4 mb-3">Invoices & Estimates</h2>
            <div class="custdet-controls mb-3 d-flex align-items-center flex-wrap gap-2">
                <div class="input-group">
                    <input type="text" id="invSearch" class="form-control" placeholder="Search invoices...">
                    <select id="invFilter" class="form-select">
                        <option value="all">All Status</option>
                        <option value="in-progress">In Progress</option>
                        <option value="complete-unpaid">Complete/Unpaid</option>
                        <option value="paid">Paid</option>
                    </select>
                </div>
                <button id="invExport" class="btn btn-primary">Export to Excel</button>
            </div>
            <div class="table-responsive">
                <table class="table table-bordered table-hover">
                    <thead class="table-light">
                        <tr>
                            <th scope="col">Type</th>
                            <th scope="col">Number</th>
                            <th scope="col">Date</th>
                            <th scope="col">Subtotal</th>
                            <th scope="col">Discount</th>
                            <th scope="col">Tax</th>
                            <th scope="col">Total</th>
                            <th scope="col">Due</th>
                            <th scope="col">Status</th>
                            <th scope="col">Custom Tags</th>
                        </tr>
                    </thead>
                    <tbody id="invTableBody"></tbody>
                </table>
            </div>
            <div class="d-flex justify-content-between align-items-center mt-3">
                <button id="invPrev" class="btn btn-outline-secondary">Previous</button>
                <span id="invPageInfo" class="text-muted">Page 1 of 1</span>
                <button id="invNext" class="btn btn-outline-secondary">Next</button>
            </div>
        </div>

        <!-- Equipment Container -->
        <div class="custdet-container">
            <h2 class="h4 mb-3">Equipment</h2>
            <div class="custdet-controls mb-3 d-flex align-items-center flex-wrap gap-2">
                <div class="input-group">
                    <input type="text" id="equipSearch" class="form-control" placeholder="Search equipment...">
                    <select id="equipFilter" class="form-select">
                        <option value="all">All Types</option>
                        <option value="hvac">HVAC</option>
                        <option value="generator">Generator</option>
                        <option value="plumbing">Plumbing</option>
                    </select>
                </div>
                <button id="equipAdd" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#equipModal">Add Equipment</button>
            </div>
            <div class="table-responsive">
                <table class="table table-bordered table-hover">
                    <thead class="table-light">
                        <tr>
                            <th scope="col">Name</th>
                            <th scope="col">Type</th>
                            <th scope="col">Install Date</th>
                            <th scope="col">Warranty Expiry</th>
                            <th scope="col">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="equipTableBody"></tbody>
                </table>
            </div>
        </div>

        <!-- Maintenance Agreements Container -->
        <div class="custdet-container">
            <h2 class="h4 mb-3">Maintenance Agreements</h2>
            <div class="custdet-controls mb-3 d-flex justify-content-end flex-wrap gap-2">
                <button id="agreeAdd" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#agreeModal">Upload Agreement</button>
            </div>
            <div class="table-responsive">
                <table class="table table-bordered table-hover">
                    <thead class="table-light">
                        <tr>
                            <th scope="col">Document</th>
                            <th scope="col">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="agreementTableBody"></tbody>
                </table>
            </div>
        </div>

        <!-- Documents Container -->
        <div class="custdet-container">
            <h2 class="h4 mb-3">Documents</h2>
            <div class="table-responsive">
                <table class="table table-bordered table-hover">
                    <thead class="table-light">
                        <tr>
                            <th scope="col">Name</th>
                            <th scope="col">Status</th>
                            <th scope="col">Link</th>
                        </tr>
                    </thead>
                    <tbody id="docTableBody"></tbody>
                </table>
            </div>
        </div>

        <!-- Pictures Container -->
        <div class="custdet-container">
            <h2 class="h4 mb-3">Pictures</h2>
            <div class="custdet-controls mb-3 d-flex align-items-center flex-wrap gap-2">
                <div class="input-group">
                    <select id="picCategory" class="form-select">
                        <option value="equipment">Equipment</option>
                        <option value="service">Service</option>
                        <option value="folder">Folder</option>
                    </select>
                    <input type="file" id="picUpload" accept="image/*" class="form-control">
                </div>
                <button id="picUploadBtn" class="btn btn-primary">Upload</button>
            </div>
            <div class="custdet-gallery d-flex flex-wrap gap-3" id="picGallery"></div>
        </div>

        <!-- Back Button -->
        <div class="custdet-container text-end">
            <a href="Customer.aspx" class="btn btn-outline-secondary">Back to Customers</a>
        </div>

        <!-- Equipment Modal -->
        <div class="modal fade" id="equipModal" tabindex="-1" aria-labelledby="equipModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="equipModalLabel">Add Equipment</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <form id="equipForm">
                            <div class="mb-3">
                                <label for="equipName" class="form-label">Equipment Name <span class="text-danger">*</span></label>
                                <input type="text" id="equipName" class="form-control" required>
                            </div>
                            <div class="mb-3">
                                <label for="equipType" class="form-label">Type <span class="text-danger">*</span></label>
                                <select id="equipType" class="form-select" required>
                                    <option value="hvac">HVAC</option>
                                    <option value="generator">Generator</option>
                                    <option value="plumbing">Plumbing</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label for="equipInstallDate" class="form-label">Install Date</label>
                                <input type="date" id="equipInstallDate" class="form-control">
                            </div>
                            <div class="mb-3">
                                <label for="equipWarrantyExpiry" class="form-label">Warranty Expiry</label>
                                <input type="date" id="equipWarrantyExpiry" class="form-control">
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="button" id="equipSave" class="btn btn-primary">Save Equipment</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Maintenance Agreement Modal -->
        <div class="modal fade" id="agreeModal" tabindex="-1" aria-labelledby="agreeModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="agreeModalLabel">Upload Agreement</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <form id="agreeForm">
                            <div class="mb-3">
                                <label for="agreeFile" class="form-label">Upload PDF <span class="text-danger">*</span></label>
                                <input type="file" id="agreeFile" accept=".pdf" class="form-control" required>
                                <div id="agreeFilePreview" class="custdet-pdf-preview mt-2" style="display: none;"></div>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="button" id="agreeSave" class="btn btn-primary">Save Agreement</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Toast Container -->
        <div class="toast-container position-fixed bottom-0 end-0 p-3">
            <div id="toast" class="toast" role="alert" aria-live="assertive" aria-atomic="true">
                <div class="toast-body"></div>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS and Popper.js -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL" crossorigin="anonymous"></script>

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
                        { id: "1", name: "HVAC Unit", type: "hvac", installDate: "2023-06-15", warrantyExpiry: "2026-06-15" },
                        { id: "2", name: "Generator", type: "generator", installDate: "2022-09-01", warrantyExpiry: "2027-09-01" }
                    ],
                    serviceAgreements: [
                        { id: "1", file: null }
                    ],
                    documents: [
                        { name: "Contract", status: "Signed", link: "#" }
                    ]
                }
            };

            const urlParams = new URLSearchParams(window.location.search);
            const siteId = urlParams.get('siteId');
            const site = siteData[siteId] || {
                name: "Unknown Site",
                status: "N/A",
                description: "N/A",
                specialInstructions: "N/A",
                appointments: [],
                invoices: [],
                equipment: [],
                serviceAgreements: [],
                documents: []
            };

            // Basic Info
            document.getElementById('siteName').textContent = site.name;
            document.getElementById('siteStatus').textContent = site.status;
            document.getElementById('siteDescription').textContent = site.description;
            document.getElementById('siteInstructions').textContent = site.specialInstructions;

            // Toast Notification
            function showToast(message) {
                const toast = new bootstrap.Toast(document.getElementById('toast'));
                document.querySelector('#toast .toast-body').textContent = message;
                toast.show();
            }

            // Equipment
            function renderEquipment() {
                const tbody = document.getElementById('equipTableBody');
                const filtered = site.equipment.filter(e =>
                    document.getElementById('equipFilter').value === 'all' ||
                    e.type === document.getElementById('equipFilter').value
                ).filter(e =>
                    !document.getElementById('equipSearch').value ||
                    Object.values(e).some(v => v.toString().toLowerCase().includes(document.getElementById('equipSearch').value.toLowerCase()))
                );

                tbody.innerHTML = filtered.map(e => `
                    <tr>
                        <td>${e.name}</td>
                        <td>${e.type.charAt(0).toUpperCase() + e.type.slice(1)}</td>
                        <td>${e.installDate || 'N/A'}</td>
                        <td>${e.warrantyExpiry || 'N/A'}</td>
                        <td>
                            <button class="btn btn-sm btn-outline-primary me-1" onclick="editEquipment('${e.id}')">Edit</button>
                            <button class="btn btn-sm btn-outline-primary me-1" onclick="assignWorkOrder('${e.id}')">Assign to WO</button>
                            <button class="btn btn-sm btn-outline-primary me-1" onclick="showPictures('equipment', '${e.id}')">View Pictures</button>
                            <button class="btn btn-sm btn-outline-danger" onclick="deleteEquipment('${e.id}')">Delete</button>
                        </td>
                    </tr>
                `).join('') || '<tr><td colspan="5">No equipment</td></tr>';
            }

            document.getElementById('equipFilter').addEventListener('change', renderEquipment);
            document.getElementById('equipSearch').addEventListener('input', renderEquipment);

            // Equipment Modal
            let editingEquipId = null;

            document.getElementById('equipAdd').addEventListener('click', () => {
                editingEquipId = null;
                document.getElementById('equipModalLabel').textContent = 'Add Equipment';
                document.getElementById('equipForm').reset();
            });

            window.editEquipment = (id) => {
                const equip = site.equipment.find(e => e.id === id);
                if (equip) {
                    editingEquipId = id;
                    document.getElementById('equipModalLabel').textContent = 'Edit Equipment';
                    document.getElementById('equipName').value = equip.name;
                    document.getElementById('equipType').value = equip.type;
                    document.getElementById('equipInstallDate').value = equip.installDate || '';
                    document.getElementById('equipWarrantyExpiry').value = equip.warrantyExpiry || '';
                    const modal = new bootstrap.Modal(document.getElementById('equipModal'));
                    modal.show();
                }
            };

            window.assignWorkOrder = (id) => {
                showToast(`Assigning equipment ${id} to work order...`);
            };

            window.deleteEquipment = (id) => {
                if (confirm('Are you sure you want to delete this equipment?')) {
                    const index = site.equipment.findIndex(e => e.id === id);
                    if (index !== -1) {
                        site.equipment.splice(index, 1);
                        renderEquipment();
                        showToast('Equipment deleted successfully');
                    }
                }
            };

            document.getElementById('equipSave').addEventListener('click', () => {
                if (!document.getElementById('equipForm').checkValidity()) {
                    document.getElementById('equipForm').reportValidity();
                    return;
                }

                const equip = {
                    id: editingEquipId || String(site.equipment.length + 1),
                    name: document.getElementById('equipName').value,
                    type: document.getElementById('equipType').value,
                    installDate: document.getElementById('equipInstallDate').value || null,
                    warrantyExpiry: document.getElementById('equipWarrantyExpiry').value || null
                };

                if (editingEquipId) {
                    const index = site.equipment.findIndex(e => e.id === editingEquipId);
                    site.equipment[index] = equip;
                } else {
                    site.equipment.push(equip);
                }

                renderEquipment();
                const modal = bootstrap.Modal.getInstance(document.getElementById('equipModal'));
                modal.hide();
                document.body.classList.remove('modal-open');
                document.querySelectorAll('.modal-backdrop').forEach(el => el.remove());
                showToast(editingEquipId ? 'Equipment updated successfully' : 'Equipment added successfully');
            });

            // Maintenance Agreements
            function renderAgreements() {
                const tbody = document.getElementById('agreementTableBody');
                tbody.innerHTML = site.serviceAgreements.map(a => `
                    <tr>
                        <td>${a.file ? 'Agreement PDF' : 'No file'}</td>
                        <td>
                            ${a.file ? `<a href="${a.file}" class="btn btn-sm btn-outline-primary me-1" download>Download</a>` : ''}
                            <button class="btn btn-sm btn-outline-primary me-1" onclick="editAgreement('${a.id}')">Edit</button>
                            <button class="btn btn-sm btn-outline-danger" onclick="deleteAgreement('${a.id}')">Delete</button>
                        </td>
                    </tr>
                `).join('') || '<tr><td colspan="2">No agreements</td></tr>';
            }

            // Agreement Modal
            let editingAgreeId = null;

            document.getElementById('agreeAdd').addEventListener('click', () => {
                editingAgreeId = null;
                document.getElementById('agreeModalLabel').textContent = 'Upload Agreement';
                document.getElementById('agreeForm').reset();
                document.getElementById('agreeFilePreview').style.display = 'none';
            });

            window.editAgreement = (id) => {
                const agree = site.serviceAgreements.find(a => a.id === id);
                if (agree) {
                    editingAgreeId = id;
                    document.getElementById('agreeModalLabel').textContent = 'Edit Agreement';
                    document.getElementById('agreeFile').value = '';
                    const preview = document.getElementById('agreeFilePreview');
                    if (agree.file) {
                        preview.innerHTML = `<iframe src="${a.file}" style="width:100%;height:100%;"></iframe>`;
                        preview.style.display = 'block';
                    } else {
                        preview.style.display = 'none';
                    }
                    const modal = new bootstrap.Modal(document.getElementById('agreeModal'));
                    modal.show();
                }
            };

            window.deleteAgreement = (id) => {
                if (confirm('Are you sure you want to delete this agreement?')) {
                    const index = site.serviceAgreements.findIndex(a => a.id === id);
                    if (index !== -1) {
                        site.serviceAgreements.splice(index, 1);
                        renderAgreements();
                        showToast('Agreement deleted successfully');
                    }
                }
            };

            document.getElementById('agreeFile').addEventListener('change', (e) => {
                const file = e.target.files[0];
                const preview = document.getElementById('agreeFilePreview');
                if (file && file.type === 'application/pdf') {
                    const url = URL.createObjectURL(file);
                    preview.innerHTML = `<iframe src="${url}" style="width:100%;height:100%;"></iframe>`;
                    preview.style.display = 'block';
                } else {
                    preview.style.display = 'none';
                    if (file) showToast('Please upload a PDF file.');
                }
            });

            document.getElementById('agreeSave').addEventListener('click', () => {
                if (!document.getElementById('agreeForm').checkValidity()) {
                    document.getElementById('agreeForm').reportValidity();
                    return;
                }

                const fileInput = document.getElementById('agreeFile');
                let file = null;
                if (fileInput.files[0]) {
                    if (fileInput.files[0].type === 'application/pdf') {
                        file = URL.createObjectURL(fileInput.files[0]);
                    } else {
                        showToast('Please upload a PDF file.');
                        return;
                    }
                } else if (editingAgreeId) {
                    file = site.serviceAgreements.find(a => a.id === editingAgreeId).file;
                }

                const agree = {
                    id: editingAgreeId || String(site.serviceAgreements.length + 1),
                    file
                };

                if (editingAgreeId) {
                    const index = site.serviceAgreements.findIndex(a => a.id === editingAgreeId);
                    site.serviceAgreements[index] = agree;
                } else {
                    site.serviceAgreements.push(agree);
                }

                renderAgreements();
                const modal = bootstrap.Modal.getInstance(document.getElementById('agreeModal'));
                modal.hide();
                document.body.classList.remove('modal-open');
                document.querySelectorAll('.modal-backdrop').forEach(el => el.remove());
                showToast(editingAgreeId ? 'Agreement updated successfully' : 'Agreement uploaded successfully');
            });

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

            // Documents
            const docBody = document.getElementById('docTableBody');
            docBody.innerHTML = site.documents.map(d => `
                <tr>
                    <td>${d.name}</td>
                    <td>${d.status}</td>
                    <td><a href="${d.link}" target="_blank">View</a></td>
                </tr>
            `).join('') || '<tr><td colspan="3">No documents</td></tr>';

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

            // Excel Export
            function exportToExcel(data, filename, headers) {
                if (typeof XLSX === 'undefined') {
                    showToast('SheetJS library is required for Excel export.');
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
            renderEquipment();
            renderAgreements();
            renderPictures('equipment');
        });
    </script>
</asp:Content>