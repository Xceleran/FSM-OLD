<%@ Page Title="Billable Items" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="BillableItems.aspx.cs" Inherits="FSM.BillableItems" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>


        #categoryFilter option {
            background: #ffffffcc !important;
            color: black;
        }

        select#itemType option {
            color: black;
        }

        .bill-container {
            width: 100%;
            margin-top: 75px;
            padding: 0 15px;
        }
        i.fa.fa-plus {
    margin-right: 5px;
    font-size: 14px;
}
        .bill-title {
            font-size: 32px;
            font-weight: bold;
            color: var(--text-orange-700); /* Matches Invoice.aspx page-title */
        }

        [data-theme="dark"] .bill-title {
            color: var(--bg-orange-200);
        }

        [data-theme="dark"] .form-check {
            color: white;
        }

        .bill-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            background: rgba(255, 255, 255, 0.12);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }

        [data-theme="dark"] .bill-table {
            background: rgba(255, 255, 255, 0.25);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .bill-table th,
        .bill-table td {
            /* padding: 12px;*/
            text-align: left;
            border-bottom: 1px solid var(--bg-gray-300);
            color: var(--text-gray-800);
        }

        [data-theme="dark"] .bill-table th,
        [data-theme="dark"] .bill-table td {
            color: var(--text-gray-700);
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .bill-table th {
            font-size: 12px;
            text-transform: uppercase;
            background: var(--bg-gray-100);
            font-weight: 600;
        }

        [data-theme="dark"] .bill-table th {
            background: transparent;
            border-right: none;
            border-left: none;
        }

        .bill-table tbody tr:hover {
            background: var(--bg-orange-200);
        }

        [data-theme="dark"] .bill-table tbody tr:hover {
            background: rgba(255, 255, 255, 0.2);
        }

        .d-flex.align-items-center.gap-2 > span {
            color: var(--text-gray-800);
            font-size: 14px;
        }

        [data-theme="dark"] .d-flex.align-items-center.gap-2 > span {
            color: var(--text-gray-700);
        }

        .bill-edit-btn,
        .bill-delete-btn {
            font-weight: 600;
            background: none;
            border: none;
            cursor: pointer;
            padding: 0 8px;
        }

        .bill-edit-btn {
            color: var(--text-orange-700); /* Matches edit button color scheme */
        }

            .bill-edit-btn:hover {
                color: var(--text-orange-500);
            }

        [data-theme="dark"] .bill-edit-btn {
            color: var(--bg-orange-200);
        }

            [data-theme="dark"] .bill-edit-btn:hover {
                color: rgb(176, 205, 235); /* Matches hover effect from Invoice.aspx */
            }

        .bill-delete-btn {
            color: #dc2626; /* Keep the red color for delete, but adjust for dark mode */
        }

            .bill-delete-btn:hover {
                color: #b91c1c;
            }

        [data-theme="dark"] .bill-delete-btn {
            color: #ff4d4f; /* Matches status-icon-due from Invoice.aspx */
        }

            [data-theme="dark"] .bill-delete-btn:hover {
                color: #ff7875; /* Slightly lighter red for hover */
            }

        .bill-image-view {
            display: none;
        }

        .bill-image-card {
            text-align: center;
            background: var(--bg-white);
            border: 1px solid var(--bg-gray-300);
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 15px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
        }

        [data-theme="dark"] .bill-image-card {
            background: rgba(255, 255, 255, 0.12);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
        }

        .bill-image {
            width: 128px;
            height: 128px;
            object-fit: cover;
            border-radius: 8px;
            margin-bottom: 8px;
            border: 1px solid var(--bg-gray-300);
        }

        [data-theme="dark"] .bill-image {
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .bill-image-title {
            font-size: 18px;
            font-weight: 600;
            color: var(--text-gray-800);
        }

        [data-theme="dark"] .bill-image-title {
            color: var(--text-gray-700);
        }

        .bill-image-text {
            font-size: 14px;
            color: var(--text-gray-600);
        }

        [data-theme="dark"] .bill-image-text {
            color: var(--text-gray-700);
        }

        .bill-modal-image-preview {
            max-width: 100%;
            height: auto;
            border-radius: 8px;
            display: none;
            border: 1px solid var(--bg-gray-300);
        }

        [data-theme="dark"] .bill-modal-image-preview {
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .bill-modal-error {
            color: #dc2626;
            font-size: 14px;
            margin-top: 4px;
            display: none;
        }

        [data-theme="dark"] .bill-modal-error {
            color: #ff4d4f;
        }

        /* Style form elements to match Invoice.aspx */
        .form-select,
        .form-control {
            background: var(--bg-white);
            color: var(--text-gray-800);
            border: 1px solid var(--bg-gray-300);
            border-radius: 6px;
            padding: 8px;
            font-size: 14px;
        }

        [data-theme="dark"] .form-select,
        [data-theme="dark"] .form-control {
            background: rgba(255, 255, 255, 0.12);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            color: var(--text-gray-700);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .form-label {
            color: var(--text-gray-800);
            font-size: 14px;
        }

        [data-theme="dark"] .form-label {
            color: var(--text-gray-700);
        }

        /* Modal styling to match Invoice.aspx */
        .modal-content {
            background: var(--bg-white);
            border-radius: 8px;
            border: 1px solid var(--bg-gray-300);
            box-shadow: var(--shadow-lg);
        }

        [data-theme="dark"] .modal-content {
            background: rgba(255, 255, 255, 0.12);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
        }

        .modal-header {
            border-bottom: 1px solid var(--bg-gray-300);
        }

        [data-theme="dark"] .modal-header {
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .modal-title {
            color: var(--text-gray-800);
        }

        [data-theme="dark"] .modal-title {
            color: var(--text-gray-700);
        }

        .modal-footer {
            border-top: 1px solid var(--bg-gray-300);
        }

        [data-theme="dark"] .modal-footer {
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }

        /* Button styling to match Invoice.aspx */
        . /*btn-primary {
            background-color: var(--text-orange-500);
            color: var(--bg-white);
            border-radius: 6px;
            padding: 8px 16px;
            font-size: 14px;
        }

            .btn-primary:hover {
                background-color: var(--text-orange-700);
                color: var(--bg-white);
            }

        [data-theme="dark"] .btn-primary {
            background: rgba(255, 255, 255, 0.12);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            color: var(--text-gray-700);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

            [data-theme="dark"] .btn-primary:hover {
                background: rgb(12, 23, 54);
                color: var(--text-gray-700);
            }*/
        .buttons {
            margin: 10%;
            text-align: center;
        }

        .edit-btn {
            font-size: 16px !important;
            color: #fff !important;
            cursor: pointer;
            border: none !important;
            background-size: 300% 100% !important;
            border-radius: 5px !important;
            transition: all .4s ease-in-out !important;
            background-image: linear-gradient(to right, #617dfc, #406fff, #3d6dd6, #0e407d);
            padding: 7px 15px;
        }

            /* Hover state */
            .edit-btn:hover {
                background-position: 100% 0 !important;
                transition: all .4s ease-in-out !important;
            }

            /* Focus state */
            .edit-btn:focus {
                outline: none !important;
            }

        .btn-secondary {
            background: #6b7280;
            border: none;
            color: #fff;
            border-radius: 6px;
            padding: 8px 16px;
            font-size: 14px;
        }

            .btn-secondary:hover {
                background: #4b5563;
            }

        .btn-primary {
            background: #5e7cfd;
        }

            .btn-primary:hover {
                background: #3d53b4;
            }

        .btn-outline-secondary {
            color: var(--text-gray-800);
            border-color: var(--bg-gray-300);
        }

        [data-theme="dark"] .btn-outline-secondary {
            color: var(--text-gray-700);
            border-color: rgba(255, 255, 255, 0.1);
        }

        .btn-outline-secondary:hover {
            background: var(--bg-orange-200);
            color: var(--text-gray-800);
        }

        [data-theme="dark"] .btn-outline-secondary:hover {
            background: rgba(255, 255, 255, 0.2);
            color: var(--text-gray-700);
        }

        tr td:nth-child(8) {
            text-align: center;
        }

        /* Card styling to match Invoice.aspx */
        .card {
            /*border: 1px solid var(--bg-gray-300);*/
            border: none;
            border-radius: 8px;
            background: rgba(255, 255, 255, 0.12);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            /*box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);*/
        }

        [data-theme="dark"] .card {
            /*background: rgba(255, 255, 255, 0.12);*/
            background: none; /* Alternate for dark mode */
            border: none; /* Alternate for dark mode */
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            /*border: 1px solid rgba(255, 255, 255, 0.1);
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);*/
        }

        /* Text-muted for footer */
        .text-muted {
            color: var(--text-gray-600);
        }

        [data-theme="dark"] .text-muted {
            color: var(--text-gray-700);
        }

        @media (max-width: 576px) {
            .bill-table {
                font-size: 14px;
            }

                .bill-table th,
                .bill-table td {
                    padding: 8px;
                }

            .bill-image {
                width: 100px;
                height: 100px;
            }

            .bill-title {
                font-size: 18px;
            }

            .form-select,
            .form-control {
                font-size: 12px;
                padding: 6px;
            }

            .btn-primary,
            .btn-secondary,
            .btn-outline-secondary {
                font-size: 12px;
                padding: 6px;
            }

            .bill-image-title {
                font-size: 16px;
            }

            .bill-image-text {
                font-size: 12px;
            }
        }

        /*Extra CSS for dropdowns*/
        .custom-select-wrapper {
            position: relative;
            display: inline-block;
        }

            .custom-select-wrapper select {
                appearance: none;
                -webkit-appearance: none;
                -moz-appearance: none;
                padding-right: 2rem;
                background: white url('data:image/svg+xml;utf8,<svg fill="gray" height="20" viewBox="0 0 24 24" width="20" xmlns="http://www.w3.org/2000/svg"><path d="M7 10l5 5 5-5z"/></svg>') no-repeat right 0.5rem center !important;
                background-size: 1rem;
                color: var(--text-gray-800);
            }

        select#entriesPerPage option {
            color: black;
        }
        /* Ensure #categoryFilter options have consistent styling */
        #categoryFilter option {
            background: #ffffffcc !important;
            color: black;
        }

        [data-theme="dark"] span#pageInfo {
            color: white;
        }

        [data-theme="dark"] #categoryFilter option {
            background: rgba(255, 255, 255, 0.12) !important;
            color: black;
        }

        [data-theme="dark"] .custom-select-wrapper select {
            background: rgba(255, 255, 255, 0.12) url('data:image/svg+xml;utf8,<svg fill="rgb(239,242,247)" height="20" viewBox="0 0 24 24" width="20" xmlns="http://www.w3.org/2000/svg"><path d="M7 10l5 5 5-5z"/></svg>') no-repeat right 0.5rem center !important;
            background-size: 1rem;
            color: var(--text-gray-700);
        }

        #loadingOverlay img {
            width: 60px;
            margin-bottom: 10px;
        }

    </style>

    <!-- SweetAlert2 CSS & JS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>


    <input type="hidden" id="companyId" value="" runat="server"/>

    <div class="bill-container">
        <header class="mb-4">
            <div class="row align-items-center">
                <div class="col-md-6">
                    <h1 class="bill-title mb-3 mb-md-0">Billable Items</h1>
                </div>
                <%-- <div class="col-md-6 text-md-end">
                    <button class="btn btn-success me-2 mb-2 mb-md-0" id="syncBtn">Sync with CEC/QBO</button>
                    <button class="btn btn-primary" id="addItemBtn">+ Add Item</button>
                </div>--%>
            </div>
        </header>
        <section class="mb-4">
            <div class="row align-items-center">
                <%--<div class="float-start">
                    <p style="display: none" id="ProgressGIF">
                        <img id="imgProcess" src="images/Rolling.gif" />
                        Sync on progress....
                    </p>
                </div>--%>
                <div id="loadingOverlay" style="display: none; position: fixed; z-index: 9999; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(255, 255, 255, 0.8); text-align: center;">
                    <div style="position: relative; top: 40%;">
                        <div class="spinner-border text-success" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                        <h5>Syncing with QuickBooks Online...</h5>
                        <p>Time elapsed: <span id="syncTimer">0</span> seconds</p>
                    </div>
                </div>

                <div class="col-md-6">
                    <span class="btn btn-primary" title="QuickBooks Online Sync" runat="server" id="SyncQuickBook" onclick="SyncQuickBook()">QuickBooks Online Sync</span>
                </div>
               <div class="col-md-6">
    <a href="https://testsite.myserviceforce.com/cec/Item.aspx" target="_blank" class="btn btn-primary float-end" title="Add Item" id="spnAddNew">
        <i class="fa fa-plus"></i>Create New
    </a>
</div>

            </div>
        </section>
        <section class="mb-4">
            <div class="row align-items-center">
                <div class="col-md-6 mb-3 mb-md-0">
                    <div class="d-flex align-items-center gap-2">
                        <span>Show</span>
                        <div class="custom-select-wrapper">
                            <select id="entriesPerPage" class="form-select w-auto">
                                <option value="10">10</option>
                                <option value="25">25</option>
                                <option value="50">50</option>
                                <option value="100">100</option>
                            </select>
                        </div>
                        <span>entries</span>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="d-flex justify-content-md-end gap-2 flex-wrap">
                        <div class="custom-select-wrapper">
                            <select id="categoryFilter" class="form-select w-auto"></select>
                        </div>
                        <%--<select id="viewToggle" class="form-select w-auto">
                            <option value="list" selected>List View</option>
                            <option value="image">Image View</option>
                        </select>--%>
                        <input type="text" id="searchBar" class="form-control w-auto" placeholder="Search..." />
                        <button id="clearSearchBtn" class="btn btn-outline-secondary" type="button">Clear</button>
                    </div>
                </div>
            </div>
        </section>

        <section id="listView" class="card mb-4">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="bill-table table table-bordered">
                        <thead class="table-light">
                            <tr>
                                <th>#</th>
                                <th>Item Name</th>
                                <th>Category</th>
                                <th>Description</th>
                                <th>SKU</th>
                                <th>Qty on Hand</th>
                                <th>Price</th>
                                <th>Is Taxable</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="itemList"></tbody>
                    </table>
                </div>
            </div>
        </section>

        <section id="imageView" class="bill-image-view row"></section>

        <footer class="d-flex justify-content-center align-items-center gap-3">
            <button class="btn btn-secondary" id="prevPage">Previous</button>
            <span id="pageInfo" class="fw-medium"></span>
            <button class="btn btn-primary" id="nextPage">Next</button>
            <p id="itemSummary" class="mt-3 text-muted"></p>
        </footer>

<%--        <div class="modal fade" id="itemModal" tabindex="-1" aria-labelledby="modalTitle" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h2 class="modal-title fs-5" id="modalTitle">Add New Item</h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form id="itemForm" class="modal-body">
                        <input type="text" id="Id" hidden="hidden" />
                        <input type="text" id="QboId" hidden="hidden" />
                        <div class="row p-3">
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-medium">Item Name</label>
                                <input name="itemName" type="text" id="itemName" class="form-control" required />
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-medium">Sku</label>
                                <input name="Sku" type="text" id="Sku" class="form-control" />
                            </div>
                            <div class="col-md-3 mb-3">
                                <label class="form-label fw-medium">Taxable</label>
                                <div class="d-flex gap-3">
                                    <div class="form-check">
                                        <input type="radio" name="taxable" value="1" id="taxYes" class="form-check-input" />
                                        <label class="form-check-label" for="taxYes">Yes</label>
                                    </div>
                                    <div class="form-check">
                                        <input type="radio" name="taxable" value="0" id="taxNo" class="form-check-input" checked />
                                        <label class="form-check-label" for="taxNo">No</label>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3 mb-3">
                                <label class="form-label fw-medium">Quantity</label>
                                <input name="quantity" type="number" id="quantity" class="form-control" step="1"  />
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-medium">Price</label>
                                <input name="price" type="number" id="price" class="form-control" step="0.01" required />
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-medium">Item Type</label>
                                <select id="itemType" class="form-select"></select>
                            </div>
                           <%-- <div class="col-md-6 mb-3">
                                <label class="form-label fw-medium">Item Type</label>
                                <select id="qboType" class="form-select">
                                    <option value="0">Select QBO Type</option>
                                    <option value="1">Service</option>
                                    <option value="2">Non-Inventory</option>
                                    <option value="3">Inventory</option>
                                    <option value="4">Other Charge</option>
                                    <option value="5">Payment</option>
                                    <option value="6">Discount</option>
                                    <option value="7">Sales Tax</option>
                                </select>
                            </div>--%>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-medium">Location</label>
                                <input name="location" type="text" id="location" class="form-control" />
                            </div>
                            <div class="col-md-12 mb-3">
                                <label class="form-label fw-medium">Description</label>
                                <textarea name="location" id="description" class="form-control"></textarea>
                            </div>
                            <%--<div class="col-12 mb-3 bill-modal-image-section" id="imageSection" style="display: none;">
                                <label class="form-label fw-medium">Item Image</label>
                                <input type="file" id="itemImage" class="form-control" accept="image/*" />
                                <img id="imagePreview" class="bill-modal-image-preview mt-2" alt="Preview" />
                                <span id="imageError" class="bill-modal-error"></span>
                            </div>--%>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" id="cancelBtn" data-bs-dismiss="modal">Cancel</button>
                            <button type="button" onclick="updateItem(event)" class="btn btn-primary" id="submitBtn">Add Item</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>--%>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', () => {

            //let itemsPerPage = parseInt(entriesPerPage.value);
            let currentView = 'list';
            const maxImageSize = 500;

            // Validate image
            function validateImage(file) {
                return new Promise((resolve, reject) => {
                    const img = new Image();
                    img.onload = () => {
                        if (img.width !== img.height) reject('Image must be square');
                        else if (img.width > maxImageSize) reject(`Image must not exceed ${maxImageSize}px`);
                        else resolve();
                    };
                    img.onerror = () => reject('Invalid image');
                    img.src = URL.createObjectURL(file);
                });
            }

            // Initialize
            function initialize() {
                //listView.style.display = 'block';
            }
        });


        let itemData = [];
        let filteredData = [];
        let currentPage = 1;
        let pageSize = 10;
        let itemTypes = [];
        const itemModal = new bootstrap.Modal(document.getElementById('itemModal'));
        const cancelBtn = document.getElementById('cancelBtn');
        const modalTitle = document.getElementById('modalTitle');
        const submitBtn = document.getElementById('submitBtn');

        cancelBtn.addEventListener('click', () => {
            itemModal.hide();
        });

        loadCategory();

        function loadItems() {
            $.ajax({
                url: 'BillableItems.aspx/GetBillableItems',
                type: "POST",
                contentType: "application/json; charset=utf-8",
                data: {},
                dataType: 'json',
                success: function (rs) {
                    itemData = rs.d || [];
                    console.log(itemData);
                    currentPage = 1;
                    applyFilters();
                },
                error: function (error) { }
            })
        }

        function applyFilters() {
            const searchTerm = $('#searchBar').val().trim().toLowerCase();
            const selectedType = $('#categoryFilter').val().toLowerCase();

            filteredData = itemData.filter(item => {
                const typeName = (itemTypes.find(t => t.Id === item.ItemTypeId)?.Name || "").toLowerCase();
                const matchesType = selectedType === 'all' || selectedType === "" || typeName === selectedType;
                const combinedText = [
                    item.ItemName,
                    item.typeName,
                    item.Description,
                    item.Sku,
                    item.Quantity,
                    item.Price,
                    item.Taxable
                ].join(' ').toLowerCase();

                const matchesSearch = combinedText.includes(searchTerm);
                return matchesType && matchesSearch;
            });

            currentPage = 1;
            renderItems();
            updatePagination();
        }

        function renderItems() {
            const startIndex = (currentPage - 1) * pageSize;
            const pageData = filteredData.slice(startIndex, startIndex + pageSize);
            const tbody = $('#itemList');
            tbody.empty();

            if (pageData.length === 0) {
                tbody.append('<tr><td colspan="7">No items found.</td></tr>');
                return;
            }

            pageData.forEach((item, index) => {
                const serialNumber = startIndex + index + 1;
                const typeName = itemTypes.find(t => t.Id === item.ItemTypeId)?.Name || "";
                tbody.append(`
                <tr>
                <td>${serialNumber}</td>
                <td>${item.ItemName || ''}</td>
                <td>${typeName}</td>
                <td>${item.Description || ''}</td>
                <td>${item.Sku || ''}</td>
                <td>${item.Quantity || ''}</td>
                <td>${item.Price || ''}</td>
                <td>${item.Taxable || ''}</td>
                <td>
                    <button title="Edit" onclick="editItem(event, '${item.Id}')" class="btn btn-sm edit-btn">Edit</button>
                </td>
                </tr>`
                );
            });

            const endIndex = Math.min(startIndex + pageSize, filteredData.length);
            $('#itemSummary').text(`Showing ${startIndex + 1}–${endIndex} of ${filteredData.length} items`);
        }

        function updatePagination() {
            const totalPages = Math.ceil(filteredData.length / pageSize);
            $('#pageInfo').text(`Page ${currentPage} of ${totalPages || 1}`);
            $('#prevPage').prop('disabled', currentPage <= 1);
            $('#nextPage').prop('disabled', currentPage >= totalPages);
        }

        $('#prevPage').click(function () {
            if (currentPage > 1) {
                currentPage--;
                renderItems();
                updatePagination();
            }
        });

        $('#nextPage').click(function () {
            const totalPages = Math.ceil(filteredData.length / pageSize);
            if (currentPage < totalPages) {
                currentPage++;
                renderItems();
                updatePagination();
            }
        });

        $('#searchBar').on('input', function () {
            applyFilters();
        });

        $('#categoryFilter').on('change', function () {
            applyFilters();
        });

        $('#clearSearchBtn').click(function () {
            $('#searchBar').val('');
            $('#categoryFilter').val('all');
            applyFilters();
        });

        $('#entriesPerPage').on('change', function () {
            pageSize = parseInt(entriesPerPage.value);
            currentPage = 1;
            renderItems();
            updatePagination();
        });

        function loadCategory() {
            $.ajax({
                url: 'BillableItems.aspx/GetItemTypes',
                type: "POST",
                contentType: "application/json; charset=utf-8",
                data: {},
                dataType: 'json',
                success: function (rs) {
                    itemTypes = rs.d;

                    const $dropdown = $('#categoryFilter');
                    $dropdown.empty(); // clear if anything exists

                    // Add static options
                    $dropdown.append('<option selected="selected" value="all">Select Item</option>');

                    // Add dynamic options from the server
                    itemTypes.forEach(function (item) {
                        $dropdown.append(`<option value="${item.Name}">${item.Name}</option>`);
                    });
                    loadItems();
                },
                error: function (error) { }
            })
        }

        function getItemTypeName(id) {
            const type = itemTypes.find(t => t.Id === id);
            return type ? type.Name : '';
        }

        function editItem(e, id) {
            e.preventDefault();
            if (id) {
                $.ajax({
                    url: 'BillableItems.aspx/GetItemById',
                    type: "POST",
                    contentType: "application/json; charset=utf-8",
                    data: JSON.stringify({ itemId: id }),
                    dataType: 'json',
                    success: function (rs) {
                        console.log(rs.d);
                        const data = rs.d;
                        $('#modalTitle').text("Edit Item");
                        $('#submitBtn').text("Update");
                        $('#QboId').val(data.QboId);
                        $('#itemName').val(data.ItemName);
                        $('#Id').val(data.Id);
                        $('#description').val(data.Description);
                        $('#Sku').val(data.Sku);
                        $('#quantity').val(data.Quantity);
                        $('#price').val(data.Price);
                        $('#location').val(data.Location);
                        populateItemTypes(data.ItemTypeId);
                        if (data.IsTaxable === true) {
                            $('#taxYes').prop('checked', true);
                        } else {
                            $('#taxNo').prop('checked', true);
                        }
                        itemModal.show();
                    },
                    error: function (error) { }
                })
            }
        }

        function populateItemTypes(selectedId) {
            const $dropdown = $('#itemType');
            $dropdown.empty(); // clear if anything exists
            $dropdown.append('<option value="0">Select Service</option>');
            $.each(itemTypes, function (i, item) {
                const isSelected = item.Id === selectedId;
                const option = `<option value="${item.Id}" ${isSelected ? 'selected' : ''}>${item.Name}</option>`;
                $dropdown.append(option);
            });
        }

        function updateItem(e) {
            e.preventDefault();
            if (!validateItemForm()) {
                return;
            }
            let itemId = $('#Id').val();
            if (itemId != '') {
                updateData();
            }
            else {
                saveData();
            }
        }

        function updateData() {
            const itemData = {
                Id: $('#Id').val(),
                QboId: $('#QboId').val(),
                CompanyID: $('#MainContent_companyId').val(),
                ItemName: $('#itemName').val().trim(),
                Description: $('#description').val().trim(),
                Sku: $('#Sku').val().trim(),
                Price: parseFloat($('#price').val()) || 0,
                Quantity: parseFloat($('#quantity').val()) || 0,
                IsTaxable: $('input[name="taxable"]:checked').val() === "1",
                Location: $('#location').val().trim(),
                ItemTypeId: parseInt($('#itemType').val().trim()),
            };
            console.log(itemData);
            $.ajax({
                type: "POST",
                url: "BillableItems.aspx/SaveItem",
                data: JSON.stringify({ itemData: itemData }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    console.log(response);
                    if (response.d) {
                        alert("Item updated successfully!");
                        itemModal.hide();
                        loadItems();
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

        function saveData() {
            const itemData = {
                Id: $('#Id').val(),
                QboId: $('#QboId').val(),
                CompanyID: $('#MainContent_companyId').val(),
                ItemName: $('#itemName').val().trim(),
                Description: $('#description').val().trim(),
                Sku: $('#Sku').val().trim(),
                Price: parseFloat($('#price').val()) || 0,
                Quantity: parseFloat($('#quantity').val()) || 0,
                IsTaxable: $('input[name="taxable"]:checked').val() === "1",
                Location: $('#location').val().trim(),
                ItemTypeId: parseInt($('#itemType').val().trim()),
            };
            console.log(itemData);
            $.ajax({
                type: "POST",
                url: "BillableItems.aspx/SaveItem",
                data: JSON.stringify({ itemData: itemData }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    console.log(response);
                    if (response.d) {
                        alert("Item added successfully!");
                        itemModal.hide();
                        loadItems();
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

        function validateItemForm() {
            const itemName = $('#itemName').val().trim();
            const price = parseFloat($('#price').val());

            if (!itemName) {
                alert('Item Name is required.');
                $('#itemName').focus();
                return false;
            }

            if (isNaN(price) || price <= 0) {
                alert('Price is required and must be a positive number.');
                $('#price').focus();
                return false;
            }
            return true;
        }

        //function SyncQuickBook() {
        //    var prgBar = document.getElementById("ProgressGIF");
        //    prgBar.style.display = "block";
        //    $.ajax({
        //        type: "POST",
        //        url: "BillableItems.aspx/SyncQBOItems",
        //        contentType: "application/json",
        //        dataType: "json",
        //        success: function (msg) {
        //            alert(msg.d);
        //            prgBar.style.display = "none";
        //            window.location.href = "BillableItems.aspx";
        //        }
        //    });
        //}

        function SyncQuickBook() {
            var overlay = document.getElementById("loadingOverlay");
            var timerText = document.getElementById("syncTimer");
            var seconds = 0;
            overlay.style.display = "block";

            var timer = setInterval(function () {
                seconds++;
                timerText.textContent = seconds;
            }, 1000);

            $.ajax({
                type: "POST",
                url: "BillableItems.aspx/SyncQBOItems",
                contentType: "application/json",
                dataType: "json",
                success: function (msg) {
                    clearInterval(timer);
                    overlay.style.display = "none";

                    Swal.fire({
                        icon: msg.d.includes("failed") ? 'error' : 'success',
                        title: msg.d.includes("failed") ? 'Failed' : 'Success',
                        text: msg.d,
                        confirmButtonColor: '#3085d6',
                        confirmButtonText: 'OK'
                    }).then(() => {
                        if (!msg.d.includes("failed")) {
                            window.location.href = "BillableItems.aspx";
                        }
                    });
                },
                error: function (xhr, status, error) {
                    clearInterval(timer);
                    overlay.style.display = "none";

                    Swal.fire({
                        icon: 'error',
                        title: 'Sync Error',
                        text: 'An error occurred during the QuickBooks sync.',
                        confirmButtonColor: '#d33'
                    });
                }
            });
        }




        function AddNewClicked() {
            $('#modalTitle').text("Add New Item");
            $('#submitBtn').text("Save");
            $('#Id').val('');
            $('#itemName').val('');
            $('#description').val('');
            $('#Sku').val('');
            $('#price').val(0);
            $('#quantity').val(0);
            $('#location').val('');
            $('#itemType').val(0);
            $('#QboId').val('');
            $('#taxNo').prop('checked', true);
            populateItemTypes(0)
            itemModal.show();
        }
    </script>
</asp:Content>
