<%@ Page Title="Customer Site Details" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="CustomerDetails.aspx.cs" Inherits="FSM.CustomerDetails" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN" crossorigin="anonymous">
    <!-- Local Styles and Scripts -->
    <link rel="stylesheet" href="Content/customerdetails.css">


    <div class="custdet-main-container">
        <h1 class="display-6 mb-4">Site : <span id="siteName">
            <asp:Label ID="lblSiteName" runat="server" /></span></h1>

        <!-- Basic Information Container -->
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
                                <asp:Label ID="lblContact" runat="server" /></td>
                            <td>Phone</td>
                            <td id="customerPhone">
                                <asp:Label ID="lblPhone" runat="server" /></td>
                            <td>Mobile</td>
                            <td id="customerMobile">
                                <asp:Label ID="lblMobile" runat="server" /></td>
                        </tr>
                        <tr>
                            <td>Email</td>
                            <td id="customerEmail">
                                <asp:Label ID="lblEmail" runat="server" /></td>
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

        <!-- Service & Appointments Container -->
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
                <button id="apptExport" class="btn btn-primary d-none">Export to Excel</button>
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
                <button id="invExport" class="btn btn-primary d-none">Export to Excel</button>
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
                        <option value="HVAC">HVAC</option>
                        <option value="Generator">Generator</option>
                        <option value="Plumbing">Plumbing</option>
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
                            <th scope="col">Special Instruction</th>
                            <th scope="col">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="equipTableBody"></tbody>
                </table>
            </div>
            <div class="d-flex justify-content-between align-items-center mt-3">
                <button id="eqpPrev" class="btn btn-outline-secondary">Previous</button>
                <span id="eqpPageInfo" class="text-muted">Page 1 of 1</span>
                <button id="eqpNext" class="btn btn-outline-secondary">Next</button>
            </div>
        </div>

        <!-- Maintenance Agreements Container -->
        <div class="custdet-container d-none">
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
        <div class="custdet-container d-none">
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
        <div class="custdet-container d-none">
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
                            <input type="number" id="equipId" value="0" hidden="hidden">
                            <div class="mb-3">
                                <label for="equipName" class="form-label">Equipment Name <span class="text-danger">*</span></label>
                                <input type="text" id="equipName" class="form-control" required>
                            </div>
                            <div class="mb-3">
                                <label for="equipType" class="form-label">Type <span class="text-danger">*</span></label>
                                <select id="equipType" class="form-select" required>
                                    <option value="HVAC">HVAC</option>
                                    <option value="Generator">Generator</option>
                                    <option value="Plumbing">Plumbing</option>
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
                            <div class="mb-3">
                                <label for="instruction" class="form-label">Special Instruction</label>
                                <input type="text" id="instruction" class="form-control">
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
            // renderAppointments(1);
            //renderInvoices(1);
            //renderEquipment();
            //renderAgreements();
            //renderPictures('equipment');
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
            loadEquipment(customerId, siteId);
        }

        function loadAppoinments(customerId) {
            $.ajax({
                url: 'CustomerDetails.aspx/GetCustomerAppoinmets',
                type: "POST",
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify({ customerId: customerId }),
                dataType: 'json',
                success: function (rs) {
                    appointmentData = rs.d || [];
                    currentPage = 1;
                    applyFilters();
                },
                error: function (error) { }
            })
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


        function loadEquipment(customerId, siteId) {
            $.ajax({
                url: 'CustomerDetails.aspx/GetSiteEquipmentData',
                type: "POST",
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify({ siteId: siteId, customerId: customerId }),
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
                tbody.append('<tr><td colspan="7">No equipment found.</td></tr>');
                return;
            }

            pageData.forEach(item => {
                tbody.append(`
                <tr>
                <td>${item.EquipmentName || ''}</td>
                <td>${item.EquipmentType || ''}</td>
                <td>${item.InstallDate || ''}</td>
                <td>${item.WarrantyExpireDate || ''}</td>
                <td>${item.SpecialInstruction || ''}</td>
                <td>
                <button type=button class="btn btn-primary" onclick=editEqp(event,"${item.Id}")>Edit</button>
                <button type=button class="btn btn-danger" onclick=deleteEqp(event,"${item.Id}")>Delete</button>
                </td>
                </tr>`);
            });
        }

        function applyFiltersEqp() {
            const searchTerm = $('#equipSearch').val().trim().toLowerCase();
            const typeFilter = $('#equipFilter').val().trim().toLowerCase();

            filteredEquipmentData = equipmentData.filter(item => {

                // Filter by status if not "all"
                const matchesType = typeFilter === 'all' ||
                    (item.EquipmentType && item.EquipmentType.toLowerCase() === typeFilter);

                // Search in multiple fields
                const combinedText = [
                    item.EquipmentName,
                    item.EquipmentType,
                    item.InstallDate,
                    item.WarrantyExpireDate,
                    item.SpecialInstruction
                ].join(' ').toLowerCase();

                const matchesSearch = combinedText.includes(searchTerm);

                return matchesType && matchesSearch;
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

        $('#equipFilter').on('change', function () {
            applyFiltersEqp();
        });


        function equipmentSave(event) {
            event.preventDefault();
            if (validateForm()) {
                const equipment = {
                    Id: parseInt($('#equipId').val()),
                    SiteId: siteId,
                    CustomerID: customerId,
                    CustomerGuid: customerGuid,
                    SpecialInstruction: $('#instruction').val().trim(),
                    WarrantyExpireDate: $('#equipWarrantyExpiry').val().trim(),
                    InstallDate: $('#equipInstallDate').val().trim(),
                    EquipmentName: $('#equipName').val().trim(),
                    EquipmentType: $('#equipType').val().trim(),
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
                            loadEquipment(customerId, siteId);
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
                document.getElementById('equipName').value = equip.EquipmentName;
                document.getElementById('equipType').value = equip.EquipmentType;
                document.getElementById('equipInstallDate').value = equip.InstallDate || '';
                document.getElementById('equipWarrantyExpiry').value = equip.WarrantyExpireDate || '';
                document.getElementById('instruction').value = equip.SpecialInstruction || '';
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
                            loadEquipment(customerId, siteId)
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
            if ($("#equipName").val().trim() === "") {
                errorMessage += "Equipment Name is required.\n";
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
