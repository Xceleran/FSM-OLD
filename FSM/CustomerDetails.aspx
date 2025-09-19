<%@ Page Title="Customer Site Details" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="CustomerDetails.aspx.cs" Inherits="FSM.CustomerDetails" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- External CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.css" />

    <link rel="stylesheet" href="Content/customerdetails.css">

    <!-- Inline Styles -->
    <style>
        #appointments .table-responsive {
            overflow: visible;
        }

        #appointments .dropdown-menu {
            z-index: 1080;
        }

        .icon-btn.dropdown-toggle::after {
            display: none !important;
        }
    </style>

    <div class="custdet-main-container">
        <h1 class="display-6 mb-4">Site :
            <asp:Label ID="lblSiteName" runat="server" /></h1>

        <!-- Hidden Labels to pass data from Server to JavaScript -->
        <asp:Label Style="display: none;" ID="lblCustomerId" runat="server" />
        <asp:Label Style="display: none;" ID="lblSiteId" runat="server" />
        <asp:Label Style="display: none;" ID="lblCustomerGuid" runat="server" />

        <!-- Tab Navigation -->
        <ul class="nav nav-tabs mb-3" id="custdetTabs" role="tablist">
            <li class="nav-item" role="presentation">
                <button class="nav-link active" id="basic-tab" data-bs-toggle="tab" data-bs-target="#basic" type="button" role="tab" aria-controls="basic" aria-selected="true">Basic Information</button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="appointments-tab" data-bs-toggle="tab" data-bs-target="#appointments" type="button" role="tab" aria-controls="appointments" aria-selected="false">Appointments</button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="invoices-tab" data-bs-toggle="tab" data-bs-target="#invoices" type="button" role="tab" aria-controls="invoices" aria-selected="false">Invoices/Estimates</button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="equipment-tab" data-bs-toggle="tab" data-bs-target="#equipment" type="button" role="tab" aria-controls="equipment" aria-selected="false">Equipments</button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="agreements-tab" data-bs-toggle="tab" data-bs-target="#agreements" type="button" role="tab" aria-controls="agreements" aria-selected="false">Maintenance Agreements</button>
            </li>
       <li class="nav-item" role="presentation">
    <button class="nav-link" id="files-tab" data-bs-toggle="tab" data-bs-target="#files" type="button" role="tab" aria-controls="files" aria-selected="false">Files</button>
</li>

        </ul>

        <!-- Tab Content -->
        <div class="tab-content" id="custdetTabContent">
            <!-- Basic Information -->
            <div class="tab-pane fade show active" id="basic" role="tabpanel" aria-labelledby="basic-tab">
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
                                <tr>
                                    <td>Customer Name</td>
                                    <td>
                                        <asp:Label ID="lblCustomerName" runat="server" /></td>
                                </tr>
                                <tr>
                                    <td>Site Contact</td>
                                    <td>
                                        <asp:Label ID="lblContact" runat="server" />

                                        <i class="fas fa-phone me-1" style="font-size: 13px;"></i>Phone:
                                        <asp:HyperLink ID="hlPhone" runat="server" />

                                        <i class="fas fa-mobile-alt me-1"></i>Mobile:
                                        <asp:HyperLink ID="hlMobile" runat="server" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>Email</td>
                                    <td>
                                        <asp:HyperLink ID="hlEmail" runat="server" /></td>
                                </tr>
                                <tr>
                                    <td>Address</td>
                                    <td>
                                        <asp:Label ID="lblAddress" runat="server" /></td>
                                </tr>
                                <tr>
                                    <td>Status</td>
                                    <td>
                                        <asp:Label ID="lblActive" runat="server" /></td>
                                </tr>
                                <tr>
                                    <td>Special Instructions</td>
                                    <td>
                                        <asp:Label ID="lblNote" runat="server" /></td>
                                </tr>
                                <tr>
                                    <td>Created On</td>
                                    <td>
                                        <asp:Label ID="lblCreatedOn" runat="server" /></td>
                                </tr>
                                <tr>
                                    <td>MMS or SMS</td>
                                    <td>
                                        <a id="btnSms" class="btn btn-sm btn-outline-primary me-2" href="#"><i class="fa-solid fa-message me-1"></i>SMS</a>
                                        <a id="btnMms" class="btn btn-sm btn-outline-dark" href="#"><i class="fa-solid fa-photo-film me-1"></i>MMS</a>
                                        <small id="smsHint" class="text-muted ms-2 d-none">Works best on mobile</small>
                                    </td>
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
                            <asp:DropDownList ID="apptFilter" runat="server" CssClass="form-select" />
                            <asp:DropDownList ID="ticketStatus" runat="server" CssClass="form-select" />
                        </div>
                        <button type="button" id="apptExport" class="btn btn-primary d-none">Export to Excel</button>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-bordered table-hover">
                            <thead class="table-light">
                                <tr>
                                    <th scope="col" style="width: 1%">Actions</th>
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
                                <option value="estimate">Estimate</option>
                            </select>
                            <button id="invDateRangePicker" class="btn btn-outline-secondary">
                                <i class="fa fa-calendar"></i>&nbsp;
    <span>Date Range</span> <i class="fa fa-caret-down"></i>
                            </button>

                        </div>
                        <a class="btn btn-primary" id="createInvoiceBtn">Create Invoice</a>
                        <a class="btn btn-primary" id="createEstimateBtn">Create Estimate</a>
                        <button type="button" id="invExport" class="btn btn-primary d-none">Export to Excel</button>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-bordered table-hover">
                            <thead class="table-light">
                                <tr>
                                    <th scope="col" class="sortable-header" data-sort="InvoiceNumber">Number <i class="fas fa-sort"></i></th>
                                    <th scope="col" class="sortable-header" data-sort="InvoiceType">Type <i class="fas fa-sort"></i></th>
                                    <th scope="col" class="sortable-header" data-sort="InvoiceDate">Date <i class="fas fa-sort"></i></th>
                                    <th scope="col" class="sortable-header" data-sort="Subtotal">Subtotal <i class="fas fa-sort"></i></th>
                                    <th scope="col" class="sortable-header" data-sort="Discount">Discount <i class="fas fa-sort"></i></th>
                                    <th scope="col" class="sortable-header" data-sort="Tax">Tax <i class="fas fa-sort"></i></th>
                                    <th scope="col" class="sortable-header" data-sort="Total">Total <i class="fas fa-sort"></i></th>
                                    <th scope="col" class="sortable-header" data-sort="Due">Due <i class="fas fa-sort"></i></th>
                                    <th scope="col" class="sortable-header" data-sort="DepositAmount">Deposit <i class="fas fa-sort"></i></th>
                                    <th scope="col" class="sortable-header" data-sort="InvoiceStatus">Status <i class="fas fa-sort"></i></th>
                                    <th scope="col">Actions</th>
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
                                    <th scope="col">Warranty End</th>
                                    <th scope="col">Labor Warranty Start</th>
                                    <th scope="col">Labor Warranty End</th>
                                    <th scope="col">SKU</th>
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
<!-- Files Tab -->
    <div class="tab-pane fade" id="files" role="tabpanel" aria-labelledby="files-tab">
    <div class="custdet-container">
        <h2 class="h4 mb-3">Files</h2>
        <div class="custdet-controls mb-3 d-flex align-items-center flex-wrap gap-2">

            <input type="file" id="fileUploadInput" class="d-none" multiple>

            <button type="button" id="uploadFileBtn" class="btn btn-primary">
                <i class="fas fa-upload me-2"></i>Upload Files
            </button>
        </div>

        <!-- Table to display uploaded files -->
        <div class="table-responsive">
            <table class="table table-bordered table-hover">
                <thead class="table-light">
                    <tr>
                        <th scope="col">File Name</th>
                        <th scope="col">Type</th>
                        <th scope="col">Date Uploaded</th>
                        <th scope="col" style="width: 15%;">Actions</th>
                    </tr>
                </thead>
                <tbody id="filesTableBody"></tbody>
            </table>
        </div>
    </div>
</div>
        </div>

        <!-- Back Button -->
        <div class="custdet-container text-end mt-4">
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
                                </div>
                            </div>
                            <div class="row mb-4">
                                <div class="col-4">
                                    <label for="Make" class="form-label">Make</label>
                                    <input type="text" id="Make" class="form-control">
                                </div>
                                <div class="col-4">
                                    <label for="Model" class="form-label">Model</label>
                                    <input type="text" id="Model" class="form-control">
                                </div>
                                <div class="col-4">
                                    <label for="Barcode" class="form-label">Barcode</label>
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
                        <button type="button" id="equipSave" class="btn btn-primary">Save</button>
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

    <!-- External Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL" crossorigin="anonymous"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
    <script type="text/javascript" src="https://cdn.jsdelivr.net/momentjs/latest/moment.min.js"></script>
    <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.min.js"></script>


    <!-- Your Custom Local Script -->
    <script src="Scripts/customerdetails.js"></script>

</asp:Content>
