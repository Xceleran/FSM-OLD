<%@ Page Title="Customer Site Details" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="CustomerDetails.aspx.cs" Inherits="FSM.CustomerDetails" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    <!-- Local Styles and Scripts -->
    <link rel="stylesheet" href="Content/customerdetails.css">

    <div class="custdet-main-container">
        <h1 class="display-6 mb-4">Site : <span id="siteName">
            <asp:Label ID="lblSiteName" runat="server" /></span></h1>

        <!-- Tab Navigation -->
        <ul class="nav nav-tabs mb-3" id="custdetTabs" role="tablist">
            <li class="nav-item" role="presentation">
                <button class="nav-link active" id="basic-tab" data-bs-toggle="tab" data-bs-target="#basic" type="button" role="tab" aria-controls="basic" aria-selected="true">Basic Information</button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="appointments-tab" data-bs-toggle="tab" data-bs-target="#appointments" type="button" role="tab" aria-controls="appointments" aria-selected="false">Service & Appointments</button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="invoices-tab" data-bs-toggle="tab" data-bs-target="#invoices" type="button" role="tab" aria-controls="invoices" aria-selected="false">Invoices & Estimates</button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="equipment-tab" data-bs-toggle="tab" data-bs-target="#equipment" type="button" role="tab" aria-controls="equipment" aria-selected="false">Equipment</button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="agreements-tab" data-bs-toggle="tab" data-bs-target="#agreements" type="button" role="tab" aria-controls="agreements" aria-selected="false">Maintenance Agreements</button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="documents-tab" data-bs-toggle="tab" data-bs-target="#documents" type="button" role="tab" aria-controls="documents" aria-selected="false">Proposals</button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="pictures-tab" data-bs-toggle="tab" data-bs-target="#pictures" type="button" role="tab" aria-controls="pictures" aria-selected="false">Pictures</button>
            </li>
        </ul>

        <!-- Tab Content -->
        <div class="tab-content" id="custdetTabContent">
            <!-- Basic Information -->
            <div class="tab-pane fade show active" id="basic" role="tabpanel" aria-labelledby="basic-tab">
                <div class="custdet-container">
                    <h2 class="h4 mb-3">Basic Information</h2>
                    <asp:Label Style="display: none;" ID="lblCustomerId" runat="server" />
                    <asp:Label Style="display: none;" ID="lblSiteId" runat="server" />
                    <asp:Label Style="display: none;" ID="lblCustomerGuid" runat="server" />
                    <div class="table-responsive">
                        <table class="table table-bordered table-hover">
                            <thead class="table-light">
                                <tr>
                                    <th scope="col">Field</th>
                                    <th scope="col">Value</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>Customer Name</td>
                                    <td id="customerName">
                                        <asp:Label ID="lblCustomerName" runat="server" /></td>
                                </tr>
                                <tr>
                                    <td>Site Contact</td>
                                    <td id="siteContact">
                                        <asp:Label ID="lblContact" runat="server" /><br />
                                        <i class="fas fa-phone me-1" style="font-size: 13px;"></i>Phone:
                                        <asp:HyperLink ID="hlPhone" runat="server" /><br />
                                        <i class="fas fa-mobile-alt me-1"></i>Mobile:
                                        <asp:HyperLink ID="hlMobile" runat="server" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>Email</td>
                                    <td id="customerEmail">
                                        <asp:HyperLink ID="hlEmail" runat="server" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>Address</td>
                                    <td id="siteAddress">
                                        <asp:Label ID="lblAddress" runat="server" /></td>
                                </tr>
                                <tr>
                                    <td>Status</td>
                                    <td id="siteStatus">
                                        <asp:Label ID="lblActive" runat="server" /></td>
                                </tr>
                                <tr>
                                    <td>Special Instructions</td>
                                    <td id="siteInstructions">
                                        <asp:Label ID="lblNote" runat="server" /></td>
                                </tr>
                                <tr>
                                    <td>Created On</td>
                                    <td id="siteDescription">
                                        <asp:Label ID="lblCreatedOn" runat="server" /></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Service & Appointments -->
            <div class="tab-pane fade" id="appointments" role="tabpanel" aria-labelledby="appointments-tab">
                <div class="custdet-container">
                    <h2 class="h4 mb-3">Service & Appointments</h2>
                    <div class="custdet-controls mb-3 d-flex align-items-center flex-wrap gap-2">
                        <div class="input-group">
                            <input type="text" id="apptSearch" class="form-control" placeholder="Search appointments...">
                            <select runat="server" id="apptFilter" class="form-select">
                                <option value="all">All Status</option>
                            </select>
                            <select runat="server" id="ticketStatus" class="form-select">
                                <option value="all">All Status</option>
                            </select>
                            <%-- <select id="apptFilter" class="form-select">
                                <option value="all">All Status</option>
                                <option value="scheduled">Scheduled</option>
                                <option value="pending">Pending</option>
                                <option value="closed">Closed</option>
                            </select>--%>
                        </div>
                        <button type="button" id="apptExport" class="btn btn-primary d-none">Export to Excel</button>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-bordered table-hover">
                            <thead class="table-light">
                                <tr>
                                    <th scope="col">Request Date</th>
                                    <th scope="col">Time Slot</th>
                                    <th scope="col">Appointment Type</th>
                                    <th scope="col">Status</th>
                                    <th scope="col">Resource</th>
                                    <th scope="col">Ticket Status</th>
                                </tr>
                            </thead>
                            <tbody id="apptTableBody"></tbody>
                        </table>
                    </div>
                    <div class="d-flex justify-content-between align-items-center mt-3">
                        <button type="button" id="apptPrev" class="btn btn-outline-secondary">Previous</button>
                        <span id="apptPageInfo" class="text-muted">Page 1 of 1</span>
                        <button type="button" id="apptNext" class="btn btn-outline-secondary">Next</button>
                    </div>
                </div>
            </div>

            <!-- Invoices & Estimates -->
            <div class="tab-pane fade" id="invoices" role="tabpanel" aria-labelledby="invoices-tab">
                <div class="custdet-container">
                    <h2 class="h4 mb-3">Invoices & Estimates</h2>
                    <div class="custdet-controls mb-3 d-flex align-items-center flex-wrap gap-2">
                        <div class="input-group">
                            <input type="text" id="invSearch" class="form-control" placeholder="Search invoices...">
                            <select id="invFilter" class="form-select">
                                <option value="all">All Status</option>
                                <option value="unpaid">Due</option>
                                <option value="paid">Paid</option>
                            </select>
                            <select id="invFilterType" class="form-select">
                                <option value="all">All Type</option>
                                <option value="invoice">Invoice</option>
                                <option value="proposal">Estimate</option>
                            </select>
                        </div>
                        <a class="btn btn-primary" onclick="redirectToInvoice('Invoice')">Create Invoice</a>
                        <a class="btn btn-primary" onclick="redirectToInvoice('Proposal')">Create Estimate</a>
                        <button type="button" id="invExport" class="btn btn-primary d-none">Export to Excel</button>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-bordered table-hover">
                            <thead class="table-light">
                                <tr>
                                    <th scope="col">Number</th>
                                    <th scope="col">Appointment ID</th>
                                    <th scope="col">Type</th>
                                    <th scope="col">Date</th>
                                    <th scope="col">Subtotal</th>
                                    <th scope="col">Discount</th>
                                    <th scope="col">Tax</th>
                                    <th scope="col">Total</th>
                                    <th scope="col">Due</th>
                                    <th scope="col">Diposit</th>
                                    <th scope="col">Status</th>
                                </tr>
                            </thead>
                            <tbody id="invTableBody"></tbody>
                        </table>
                    </div>
                    <div class="d-flex justify-content-between align-items-center mt-3">
                        <button type="button" id="invPrev" class="btn btn-outline-secondary">Previous</button>
                        <span id="invPageInfo" class="text-muted">Page 1 of 1</span>
                        <button type="button" id="invNext" class="btn btn-outline-secondary">Next</button>
                    </div>
                </div>
            </div>

            <!-- Equipment -->
            <div class="tab-pane fade" id="equipment" role="tabpanel" aria-labelledby="equipment-tab">
                <div class="custdet-container">
                    <h2 class="h4 mb-3">Equipment</h2>
                    <div class="custdet-controls mb-3 d-flex align-items-center flex-wrap gap-2">
                        <div class="input-group">
                            <input type="text" id="equipSearch" class="form-control col-4" placeholder="Search equipment...">
                            <%-- <select id="equipFilter" class="form-select">
                                <option value="all">All Types</option>
                                <option value="HVAC">HVAC</option>
                                <option value="Generator">Generator</option>
                                <option value="Plumbing">Plumbing</option>
                            </select>--%>
                        </div>
                        <button type="button" id="equipAdd" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#equipModal">Add Equipment</button>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-bordered table-hover">
                            <thead class="table-light">
                                <tr>
                                    <th scope="col">Type</th>
                                    <th scope="col">Serial Number</th>
                                    <th scope="col">Make</th>
                                    <th scope="col">Model</th>
                                    <th scope="col">Warranty Start</th>
                                    <th scope="col">Warranty Date</th>
                                    <th scope="col">Labor Warranty Start</th>
                                    <th scope="col">Labor Warranty Date</th>
                                    <th scope="col">Barcode</th>
                                    <th scope="col">Install Date</th>
                                    <th scope="col">Notes</th>
                                    <th scope="col">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="equipTableBody"></tbody>
                        </table>
                    </div>
                    <div class="d-flex justify-content-between align-items-center mt-3">
                        <button type="button" id="eqpPrev" class="btn btn-outline-secondary">Previous</button>
                        <span id="eqpPageInfo" class="text-muted">Page 1 of 1</span>
                        <button type="button" id="eqpNext" class="btn btn-outline-secondary">Next</button>
                    </div>
                </div>
            </div>

            <!-- Maintenance Agreements -->
            <div class="tab-pane fade" id="agreements" role="tabpanel" aria-labelledby="agreements-tab">
                <div class="custdet-container">
                    <h2 class="h4 mb-3">Maintenance Agreements</h2>
                    <div class="custdet-controls mb-3 d-flex align-items-center flex-wrap gap-2">
                        <div class="input-group">
                            <input type="text" id="agreeSearch" class="form-control" placeholder="Search agreements...">
                        </div>
                        <button type="button" id="agreeAdd" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#agreeModal">Upload Agreement</button>
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
            </div>

            <!-- Documents -->
            <div class="tab-pane fade" id="documents" role="tabpanel" aria-labelledby="documents-tab">
                <div class="custdet-container">
                    <h2 class="h4 mb-3">Documents</h2>
                    <div class="custdet-controls mb-3 d-flex align-items-center flex-wrap gap-2">
                        <div class="input-group">
                            <input type="text" id="docSearch" class="form-control" placeholder="Search documents...">
                        </div>
                    </div>
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
            </div>

            <!-- Pictures -->
            <div class="tab-pane fade" id="pictures" role="tabpanel" aria-labelledby="pictures-tab">
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
                        <button type="button" id="picUploadBtn" class="btn btn-primary">Upload</button>
                    </div>
                    <div class="custdet-gallery d-flex flex-wrap gap-3" id="picGallery"></div>
                </div>
            </div>
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
                            <input type="number" id="equipId" value="0" hidden="hidden">
                            <div class="row mb-4">
                                <div class="col-6">
                                    <label for="SerialNumber" class="form-label">Serial Number <span class="text-danger">*</span></label>
                                    <input type="text" id="SerialNumber" class="form-control" required>
                                </div>
                                <div class="col-6">
                                    <label for="equipType" class="form-label">Type <span class="text-danger">*</span></label>
                                    <input type="text" id="equipType" class="form-control" required>
                                    <%--                                <select id="equipType" class="form-select" required>
        <option value="HVAC">HVAC</option>
        <option value="Generator">Generator</option>
        <option value="Plumbing">Plumbing</option>
    </select>--%>
                                </div>
                            </div>
                            <div class="row mb-4">
                                <div class="col-4">
                                    <label for="Make" class="form-label">Make </label>
                                    <input type="text" id="Make" class="form-control">
                                </div>
                                <div class="col-4">
                                    <label for="Model" class="form-label">Model </label>
                                    <input type="text" id="Model" class="form-control">
                                </div>
                                <div class="col-4">
                                    <label for="Barcode" class="form-label">Barcode </label>
                                    <input type="text" id="Barcode" class="form-control">
                                </div>
                            </div>
                            <div class="row mb-4">
                                <div class="col-6">
                                    <label for="WarrantyStart" class="form-label">Warranty Start</label>
                                    <input type="date" id="WarrantyStart" class="form-control">
                                </div>
                                <div class="col-6">
                                    <label for="WarrantyEnd" class="form-label">Warranty End</label>
                                    <input type="date" id="WarrantyEnd" class="form-control">
                                </div>
                            </div>
                            <div class="row mb-4">
                                <div class="col-6">
                                    <label for="LaborWarrantyStart" class="form-label">Labor Warranty Start</label>
                                    <input type="date" id="LaborWarrantyStart" class="form-control">
                                </div>
                                <div class="col-6">
                                    <label for="LaborWarrantyEnd" class="form-label">Labor Warranty End</label>
                                    <input type="date" id="LaborWarrantyEnd" class="form-control">
                                </div>
                            </div>
                            <div class="row mb-4">
                                <div class="col-6">
                                    <label for="equipInstallDate" class="form-label">Install Date</label>
                                    <input type="date" id="equipInstallDate" class="form-control">
                                </div>
                                <div class="col-6">
                                    <label for="instruction" class="form-label">Notes</label>
                                    <input type="text" id="instruction" class="form-control">
                                </div>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="button" onclick="equipmentSave(event)" id="equipSave" class="btn btn-primary">Save</button>
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
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <script>
        // Toast Notification
        function showToast(message) {
            const toast = new bootstrap.Toast(document.getElementById('toast'));
            document.querySelector('#toast .toast-body').textContent = message;
            toast.show();
        }

        function closeModal(modalId) {
            const modal = document.getElementById(modalId);
            if (modal) {
                modal.style.display = 'none';
            }
        }

        document.addEventListener('DOMContentLoaded', () => {
            const ITEMS_PER_PAGE = 5;
            const urlParams = new URLSearchParams(window.location.search);

            // Equipment Modal
            let editingEquipId = null;

            document.getElementById('equipAdd').addEventListener('click', () => {
                editingEquipId = null;
                document.getElementById('equipModalLabel').textContent = 'Add Equipment';
                document.getElementById('equipForm').reset();
            });

            window.assignWorkOrder = (id) => {
                showToast(`Assigning equipment ${id} to work order...`);
            };

            // Maintenance Agreements
            function renderAgreements(searchTerm = '') {
                const tbody = document.getElementById('agreementTableBody');
                const filteredAgreements = site.serviceAgreements.filter(a => 
                    (a.file || '').toLowerCase().includes(searchTerm.toLowerCase())
                );
                tbody.innerHTML = filteredAgreements.map(a => `
                    <tr>
                        <td>${a.file ? 'Agreement PDF' : 'No file'}</td>
                        <td>
                            ${a.file ? `<a href="${a.file}" class="btn btn-sm btn-outline-primary me-1" download>Download</a>` : ''}
                            <button type="button" class="btn btn-sm btn-outline-primary me-1" onclick="editAgreement('${a.id}')">Edit</button>
                            <button type="button" class="btn btn-sm btn-outline-danger" onclick="deleteAgreement('${a.id}')">Delete</button>
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
                        preview.innerHTML = `<iframe src="${agree.file}" style="width:100%;height:100%;"></iframe>`;
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

            // Agreements Search
            document.getElementById('agreeSearch').addEventListener('input', () => {
                const searchTerm = document.getElementById('agreeSearch').value;
                renderAgreements(searchTerm);
            });

            // Documents Search
            function renderDocuments(searchTerm = '') {
                const tbody = document.getElementById('docTableBody');
                // Placeholder data (replace with actual data source)
                const documents = [
                    { name: 'Doc1.pdf', status: 'Active', link: '#' },
                    { name: 'Doc2.pdf', status: 'Pending', link: '#' }
                ];
                const filteredDocs = documents.filter(d => 
                    d.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                    d.status.toLowerCase().includes(searchTerm.toLowerCase())
                );
                tbody.innerHTML = filteredDocs.map(d => `
                    <tr>
                        <td>${d.name}</td>
                        <td>${d.status}</td>
                        <td><a href="${d.link}" class="invoice-link">View</a></td>
                    </tr>
                `).join('') || '<tr><td colspan="3">No documents found</td></tr>';
            }

            document.getElementById('docSearch').addEventListener('input', () => {
                const searchTerm = document.getElementById('docSearch').value;
                renderDocuments(searchTerm);
            });

            // Pictures
            let pictures = { equipment: {}, service: {}, folder: {} };
            function renderPictures(category, id = '') {
                const gallery = document.getElementById('picGallery');
                const pics = pictures[category][id] || [];
                gallery.innerHTML = pics.map((p, i) => `
                    <div class="custdet-gallery-item">
                        <img src="${p}" alt="Picture">
                        <button type="button" class="custdet-delete-btn" onclick="deletePicture('${category}', '${id}', ${i})">X</button>
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
            renderAgreements();
            renderDocuments();
            renderPictures('equipment');
        });

        let appointmentData = [];
        let filteredData = [];
        let currentPage = 1;
        const pageSize = 10;

        let invoiceData = [];
        let filteredInvoiceData = [];
        let currentPageInv = 1;
        const pageSizeInv = 10;

        let equipmentData = [];
        let filteredEquipmentData = [];
        let currentPageEqp = 1;
        const pageSizeEqp = 10;

        var customerId = document.getElementById('<%= lblCustomerId.ClientID %>').innerText;
        var siteId = parseInt(document.getElementById('<%= lblSiteId.ClientID %>').innerText);
        var customerGuid = document.getElementById('<%= lblCustomerGuid.ClientID %>').innerText;

        loadData();

        function loadData() {
            loadAppoinments(customerId);
            loadInvoices(customerId);
            loadEquipment(siteId, customerGuid);
        }

        function loadAppoinments(customerId) {
            // Get siteId from the page (already available in your code)
            var siteId = parseInt(document.getElementById('<%= lblSiteId.ClientID %>').innerText);

     $.ajax({
         url: 'CustomerDetails.aspx/GetCustomerAppoinmets',
         type: "POST",
         contentType: "application/json; charset=utf-8",
         data: JSON.stringify({
             customerId: customerId,
             siteId: siteId  // Add this parameter
         }),
         dataType: 'json',
         success: function (rs) {
             appointmentData = rs.d || [];
             currentPage = 1;
             applyFilters();
         },
         error: function (error) {
             showToast("Failed to load appointments");
         }
     });
 }

        function renderAppointments() {
            const startIndex = (currentPage - 1) * pageSize;
            const pageData = filteredData.slice(startIndex, startIndex + pageSize);
            const tbody = $('#apptTableBody');
            tbody.empty();

            if (pageData.length === 0) {
                tbody.append('<tr><td colspan="7">No appointments found.</td></tr>');
                return;
            }

            pageData.forEach(item => {
                tbody.append(`
                <tr>
                    <td>${item.RequestDate || ''}</td>
                    <td>${item.TimeSlot || ''}</td>
                    <td>${item.ServiceType || ''}</td>
                    <td>${item.AppoinmentStatus || ''}</td>
                    <td>${item.ResourceName || ''}</td>
                    <td>${item.TicketStatus || ''}</td>
                </tr>
            `);
            });
        }

        function updatePagination() {
            const totalPages = Math.ceil(filteredData.length / pageSize);
            $('#apptPageInfo').text(`Page ${currentPage} of ${totalPages || 1}`);

            $('#apptPrev').prop('disabled', currentPage <= 1);
            $('#apptNext').prop('disabled', currentPage >= totalPages);
        }

        $('#apptPrev').click(function () {
            if (currentPage > 1) {
                currentPage--;
                renderAppointments();
                updatePagination();
            }
        });

        $('#apptNext').click(function () {
            const totalPages = Math.ceil(filteredData.length / pageSize);
            if (currentPage < totalPages) {
                currentPage++;
                renderAppointments();
                updatePagination();
            }
        });

        function applyFilters() {
            const searchTerm = $('#apptSearch').val().trim().toLowerCase();
            const statusFilter = $('#MainContent_apptFilter').val();
            const ticketFilter = $('#MainContent_ticketStatus').val();

            filteredData = appointmentData.filter(item => {
                // Filter by status if not "all"
                const matchesStatus = statusFilter === '' ||
                    (item.AppoinmentStatus === statusFilter);

                const matchesTicketStatus = ticketFilter === '' ||
                    (item.TicketStatus === ticketFilter);

                // Search in multiple fields
                const combinedText = [
                    item.RequestDate,
                    item.TimeSlot,
                    item.ServiceType,
                    item.AppoinmentStatus,
                    item.ResourceName,
                    item.TicketStatus
                ].join(' ').toLowerCase();

                const matchesSearch = combinedText.includes(searchTerm);

                return matchesStatus && matchesTicketStatus && matchesSearch;
            });

            currentPage = 1;
            renderAppointments();
            updatePagination();
        }

        $('#apptSearch').on('input', function () {
            applyFilters();
        });

        $('#MainContent_apptFilter').on('change', function () {
            applyFilters();
        });

        $('#MainContent_ticketStatus').on('change', function () {
            applyFilters();
        });

        function loadInvoices(customerId) {
            $.ajax({
                url: 'CustomerDetails.aspx/GetCustomerInvoices',
                type: "POST",
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify({ customerId: customerId }),
                dataType: 'json',
                success: function (rs) {
                    invoiceData = rs.d || [];
                    console.log(invoiceData);
                    currentPage = 1;
                    applyFiltersInv();
                },
                error: function (error) { }
            })
        }

        function renderInvoices() {
            const startIndex = (currentPageInv - 1) * pageSizeInv;
            const pageData = filteredInvoiceData.slice(startIndex, startIndex + pageSizeInv);
            const tbody = $('#invTableBody');
            tbody.empty();

            if (pageData.length === 0) {
                tbody.append('<tr><td colspan="11">No invoices found.</td></tr>');
                return;
            }

            pageData.forEach(item => {
                tbody.append(`
                <tr>
                <td><a href="#" class="invoice-link"
                   data-id="${item.ID}" 
                   data-type="${item.InvoiceType}" 
                   data-appid="${item.AppointmentId}">${item.InvoiceNumber || ''}</a></td>
                <td>${item.AppointmentId || ''}</td>
                <td>${item.InvoiceType || ''}</td>
                <td>${item.InvoiceDate || ''}</td>
                <td>${item.Subtotal || ''}</td>
                <td>${item.Discount || ''}</td>
                <td>${item.Tax || ''}</td>
                <td>${item.Total || ''}</td>
                <td>${item.Due || ''}</td>
                <td>${item.DepositAmount || ''}</td>
                <td>${item.InvoiceStatus || ''}</td>
                </tr>
                `);
            });
        }

        function updatePaginationInv() {
            const totalPages = Math.ceil(filteredInvoiceData.length / pageSizeInv);
            $('#invPageInfo').text(`Page ${currentPageInv} of ${totalPages || 1}`);

            $('#invPrev').prop('disabled', currentPageInv <= 1);
            $('#invNext').prop('disabled', currentPageInv >= totalPages);
        }

        $('#invPrev').click(function () {
            if (currentPageInv > 1) {
                currentPageInv--;
                renderInvoices();
                updatePaginationInv();
            }
        });

        $('#invNext').click(function () {
            const totalPages = Math.ceil(filteredInvoiceData.length / pageSizeInv);
            if (currentPageInv < totalPages) {
                currentPageInv++;
                renderInvoices();
                updatePaginationInv();
            }
        });

        function applyFiltersInv() {
            const searchTerm = $('#invSearch').val().trim().toLowerCase();
            const statusFilter = $('#invFilter').val().trim().toLowerCase();
            const typeFilter = $('#invFilterType').val().trim().toLowerCase();

            filteredInvoiceData = invoiceData.filter(item => {
                if (item.InvoiceType == "Proposal") {
                    item.InvoiceType = "Estimate"
                }

                // Filter by status if not "all"
                const matchesStatus = statusFilter === 'all' ||
                    (item.InvoiceStatus && item.InvoiceStatus.toLowerCase() === statusFilter);

                const matchesType = typeFilter === 'all' ||
                    (item.InvoiceType && item.InvoiceType.toLowerCase() === typeFilter);

                // Search in multiple fields
                const combinedText = [
                    item.InvoiceNumber,
                    item.AppointmentId,
                    item.InvoiceType,
                    item.InvoiceDate,
                    item.Subtotal,
                    item.Discount,
                    item.Tax,
                    item.Total,
                    item.Due,
                    item.DepositAmount,
                    item.InvoiceStatus,
                ].join(' ').toLowerCase();

                const matchesSearch = combinedText.includes(searchTerm);

                return matchesStatus && matchesType && matchesSearch;
            });

            currentPage = 1;
            renderInvoices();
            updatePaginationInv();
        }

        $('#invSearch').on('input', function () {
            applyFiltersInv();
        });

        $('#invFilter').on('change', function () {
            applyFiltersInv();
        });

        $('#invFilterType').on('change', function () {
            applyFiltersInv();
        });

        function loadEquipment(siteId, customerGuid) {
            $.ajax({
                url: 'CustomerDetails.aspx/GetSiteEquipmentData',
                type: "POST",
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify({ siteId: siteId, customerGuid: customerGuid }),
                dataType: 'json',
                success: function (rs) {
                    equipmentData = rs.d || [];
                    console.log(rs.d);
                    currentPage = 1;
                    applyFiltersEqp();
                },
                error: function (error) { }
            })
        }

        function renderEquipments() {
            const startIndex = (currentPage - 1) * pageSize;
            const pageData = filteredEquipmentData.slice(startIndex, startIndex + pageSize);
            const tbody = $('#equipTableBody');
            tbody.empty();

            if (pageData.length === 0) {
                tbody.append('<tr><td colspan="12">No equipment found.</td></tr>');
                return;
            }

            pageData.forEach(item => {
                tbody.append(`
                <tr>
                <td>${item.EquipmentType || ''}</td>
                <td>${item.SerialNumber || ''}</td>
                <td>${item.Make || ''}</td>
                <td>${item.Model || ''}</td>
                <td>${item.WarrantyStart || ''}</td>
                <td>${item.WarrantyEnd || ''}</td>
                <td>${item.LaborWarrantyStart || ''}</td>
                <td>${item.LaborWarrantyEnd || ''}</td>
                <td>${item.Barcode || ''}</td>
                <td>${item.InstallDate || ''}</td>
                <td>${item.Notes || ''}</td>
                <td>
                <button type="button" class="btn btn-primary" onclick="editEqp(event,'${item.Id}')">Edit</button>
                <button type="button" class="btn btn-danger" onclick="deleteEqp(event,'${item.Id}')">Delete</button>
                </td>
                </tr>`);
            });
        }

        function applyFiltersEqp() {
            const searchTerm = $('#equipSearch').val().trim().toLowerCase();
            // const typeFilter = $('#equipFilter').val().trim().toLowerCase();

            filteredEquipmentData = equipmentData.filter(item => {
                // Filter by status if not "all"
                //const matchesType = typeFilter === 'all' ||
                //    (item.EquipmentType && item.EquipmentType.toLowerCase() === typeFilter);

                // Search in multiple fields
                const combinedText = [
                    item.EquipmentType,
                    item.SerialNumber,
                    item.Make,
                    item.Model,
                    item.WarrantyStart,
                    item.WarrantyEnd,
                    item.LaborWarrantyStart,
                    item.LaborWarrantyEnd,
                    item.Barcode,
                    item.InstallDate,
                    item.Notes
                ].join(' ').toLowerCase();

                const matchesSearch = combinedText.includes(searchTerm);

                return matchesSearch;
            });

            currentPage = 1;
            renderEquipments();
            updatePagination();
        }

        function updatePaginationInv() {
            const totalPages = Math.ceil(filteredEquipmentData.length / pageSizeEqp);
            $('#eqpPageInfo').text(`Page ${currentPageEqp} of ${totalPages || 1}`);

            $('#eqpPrev').prop('disabled', currentPageEqp <= 1);
            $('#eqpNext').prop('disabled', currentPageEqp >= totalPages);
        }

        $('#equipSearch').on('input', function () {
            applyFiltersEqp();
        });

        //$('#equipFilter').on('change', function () {
        //    applyFiltersEqp();
        //});

        function equipmentSave(event) {
            event.preventDefault();
            if (validateForm()) {
                const equipment = {
                    Id: parseInt($('#equipId').val()),
                    SiteId: siteId,
                    CustomerID: customerId,
                    CustomerGuid: customerGuid,
                    Notes: $('#instruction').val().trim(),
                    WarrantyStart: $('#WarrantyStart').val().trim(),
                    WarrantyEnd: $('#WarrantyEnd').val().trim(),
                    LaborWarrantyStart: $('#LaborWarrantyStart').val().trim(),
                    LaborWarrantyEnd: $('#LaborWarrantyEnd').val().trim(),
                    InstallDate: $('#equipInstallDate').val().trim(),
                    SerialNumber: $('#SerialNumber').val().trim(),
                    EquipmentType: $('#equipType').val().trim(),
                    Barcode: $('#Barcode').val().trim(),
                    Model: $('#Model').val().trim(),
                    Make: $('#Make').val().trim(),
                };

                let message = "saved";
                if (equipment.Id > 0) {
                    message = "updated";
                }

                $.ajax({
                    type: "POST",
                    url: "CustomerDetails.aspx/SaveEquipmentData",
                    data: JSON.stringify({ equipment: equipment }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        console.log(response);
                        if (response.d) {
                            closeModal('equipModal');
                            document.querySelectorAll('.modal-backdrop').forEach(el => el.remove());
                            showToast("Equipment " + message + " successfully!");
                            loadEquipment(siteId, customerGuid);
                        }
                        else {
                            showToast("Something went wrong!");
                        }
                    },
                    error: function (xhr, status, error) {
                        console.error("Error updating details: ", error);
                    }
                });
            }
        }

        function editEqp(event, data) {
            event.preventDefault();
            const equip = equipmentData.find(e => e.Id == data);
            if (equip) {
                document.getElementById('equipModalLabel').textContent = 'Edit Equipment';
                document.getElementById('equipId').value = data;
                document.getElementById('SerialNumber').value = equip.SerialNumber;
                document.getElementById('equipType').value = equip.EquipmentType;
                document.getElementById('Barcode').value = equip.Barcode;
                document.getElementById('Model').value = equip.Model;
                document.getElementById('Make').value = equip.Make;
                document.getElementById('equipInstallDate').value = equip.InstallDate || '';
                document.getElementById('WarrantyStart').value = equip.WarrantyStart || '';
                document.getElementById('WarrantyEnd').value = equip.WarrantyEnd || '';
                document.getElementById('LaborWarrantyStart').value = equip.LaborWarrantyStart || '';
                document.getElementById('LaborWarrantyEnd').value = equip.LaborWarrantyEnd || '';
                document.getElementById('instruction').value = equip.Notes || '';
                const modal = new bootstrap.Modal(document.getElementById('equipModal'));
                modal.show();
            }
        }

        function deleteEqp(e, data) {
            e.preventDefault();
            if (confirm('Are you sure you want to delete this equipment?')) {
                $.ajax({
                    url: 'CustomerDetails.aspx/DeleteEquipment',
                    type: "POST",
                    contentType: 'application/json',
                    data: "{ equipmentId: '" + data + "'}",
                    dataType: 'json',
                    success: function (rs) {
                        if (rs.d) {
                            showToast('Deleted Successfully');
                            loadEquipment(siteId, customerGuid)
                        }
                    },
                    error: function (error) { }
                })
            }
        }

        function validateForm() {
            let isValid = true;
            let errorMessage = "";

            // Required field validation
            if ($("#SerialNumber").val().trim() === "") {
                errorMessage += "Serial Number is required.\n";
                isValid = false;
            }

            if ($("#equipType").val().trim() === "") {
                errorMessage += "Equipment type is required.\n";
                isValid = false;
            }

            if (!isValid) {
                showToast(errorMessage);
            }
            return isValid;
        }

        function redirectToInvoice(type) {
            var cid = customerGuid;
            window.location.href = 'InvoiceCreate.aspx?InvNum=0&cId=' + cid + '&InType=' + type + '';
        }

        function redirectToInvoiceModify(InvNum, Type, apptID) {
            var cID = customerGuid;
            window.location.href = "InvoiceCreate.aspx?InvNum=" + InvNum + "&cId=" + cID + "&InType=" + Type + "&AppID=" + apptID + "&FromCustomer=1";
        }

        $(document).on('click', '.invoice-link', function (e) {
            e.preventDefault(); // Prevent page reload
            const id = $(this).data('id');
            const type = $(this).data('type');
            const appId = $(this).data('appid');
            redirectToInvoiceModify(id, type, appId);
        });
    </script>
</asp:Content>