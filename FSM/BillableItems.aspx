<%@ Page Title="Billable Items" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="BillableItems.aspx.cs" Inherits="FSM.BillableItems" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- jQuery (must be loaded before DataTables ) --%>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

    <%-- DataTables CSS --%>
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/responsive/2.5.0/css/responsive.bootstrap5.min.css">

    <%-- DataTables JS and Responsive extension --%>
    <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>
    <script src="https://cdn.datatables.net/responsive/2.5.0/js/dataTables.responsive.min.js"></script>
    <script src="https://cdn.datatables.net/responsive/2.5.0/js/responsive.bootstrap5.min.js"></script>

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
            margin-top: 25px;
            padding: 0 15px;
        }

        .bill-title {
            font-size: 32px;
            font-weight: bold;
            color: var(--text-orange-700);
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
            color: var(--text-orange-700);
        }

            .bill-edit-btn:hover {
                color: var(--text-orange-500);
            }

        [data-theme="dark"] .bill-edit-btn {
            color: var(--bg-orange-200);
        }

            [data-theme="dark"] .bill-edit-btn:hover {
                color: rgb(176, 205, 235);
            }

        .bill-delete-btn {
            color: #dc2626;
        }

            .bill-delete-btn:hover {
                color: #b91c1c;
            }

        [data-theme="dark"] .bill-delete-btn {
            color: #ff4d4f;
        }

            [data-theme="dark"] .bill-delete-btn:hover {
                color: #ff7875;
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

            .edit-btn:hover {
                background-position: 100% 0 !important;
                transition: all .4s ease-in-out !important;
            }

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

        .card {
            border: none;
            border-radius: 8px;
            background: rgba(255, 255, 255, 0.12);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
        }

        [data-theme="dark"] .card {
            background: none;
            border: none;
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
        }

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

        .category-card {
            border: 2px solid #c7c7c7;
            border-radius: 8px;
            padding: 10px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s ease;
            width: 120px;
            background: #ffffff;
        }

            .category-card:hover {
                border-color: #5e7cfd;
                background-color: rgba(94, 124, 253, 0.1);
            }

            .category-card.active {
                border-color: #5e7cfd;
                background-color: rgba(94, 124, 253, 0.2);
                font-weight: bold;
            }

        .category-image {
            width: 64px;
            height: 64px;
            object-fit: cover;
            border-radius: 50%;
            margin-bottom: 8px;
        }

        .category-name {
            font-size: 14px;
        }

        .manage-types-card {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            border-style: dashed;
        }

        .type-view-section {
            margin-bottom: 20px;
        }

        .type-group {
            margin-bottom: 30px;
        }

            .type-group h3 {
                font-size: 24px;
                color: var(--text-gray-800);
                margin-bottom: 15px;
                display: flex;
                align-items: center;
                gap: 10px;
            }

        [data-theme="dark"] .type-group h3 {
            color: var(--text-gray-700);
        }

        .type-group img {
            width: 32px;
            height: 32px;
            object-fit: cover;
            border-radius: 50%;
        }

        .type-item-card {
            background: var(--bg-white);
            border: 1px solid var(--bg-gray-300);
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 15px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        [data-theme="dark"] .type-item-card {
            background: rgba(255, 255, 255, 0.12);
            border: 1px solid rgba(255, 255, 255, 0.1);
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
        }

        .type-item-details {
            flex-grow: 1;
        }

            .type-item-details h5 {
                font-size: 18px;
                color: var(--text-gray-800);
                margin-bottom: 5px;
            }

        [data-theme="dark"] .type-item-details h5 {
            color: var(--text-gray-700);
        }

        .type-item-details p {
            font-size: 14px;
            color: var(--text-gray-600);
            margin: 0;
        }

        [data-theme="dark"] .type-item-details p {
            color: var(--text-gray-700);
        }

        .type-item-actions {
            display: flex;
            gap: 10px;
        }

        .categoryContainer {
            display: flex;
            margin: 10px auto;
            justify-content: space-between;
        }

        .btn-primary.qb {
            background: #0fd46c;
            border: none;
            color: #0d333f;
            font-weight: 600;
        }

        /* --- Add these styles for the 3-dot dropdown --- */
        .actions-dropdown .dropdown-toggle::after {
            display: none;
        }

        .actions-dropdown .btn-light {
            background-color: transparent;
            border: none;
        }

        .actions-dropdown .dropdown-menu {
            border-radius: 8px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            border: 1px solid #dee2e6;
        }

        [data-theme="dark"] .actions-dropdown .dropdown-menu {
            background-color: #343a40;
            border-color: rgba(255,255,255,0.15);
        }

        [data-theme="dark"] .actions-dropdown .dropdown-item {
            color: #f8f9fa;
        }

            [data-theme="dark"] .actions-dropdown .dropdown-item:hover {
                background-color: rgba(255, 255, 255, 0.1);
            }

        .dropdown-item {
            font-size: 14px;
            padding: .5rem 1rem;
            cursor: pointer;
        }

            .dropdown-item i {
                margin-right: 10px;
                width: 16px;
                text-align: center;
            }
    </style>

    <!-- SweetAlert2 CSS & JS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <input type="hidden" id="companyId" value="" runat="server" />

    <div class="bill-container">
        <header class="mb-4">
            <div class="row align-items-center">
            </div>
        </header>
        <section class="mb-4">
            <div class="row align-items-center">
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
                    <span class="btn btn-primary qb" title="QuickBooks Online Sync" runat="server" id="SyncQuickBook" onclick="SyncQuickBook()">QuickBooks Online Sync</span>
                </div>
                <div class="col-md-6">
                    <a href="https://jobs-msschedules.myserviceforce.com/Item.aspx" target="_blank" class="btn btn-primary float-end" title="Add Item" id="spnAddNew">
                        <i class="fa fa-plus me-2"></i>Create New
                    </a>
                </div>
            </div>
        </section>
        <section class="mb-4">
            <div id="categoryImageContainer" class="categoryContainer">
                <!-- Category images will be dynamically inserted here by JavaScript -->
            </div>
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
                            <select id="viewToggle" class="form-select w-auto">
                                <option value="list" selected>Items by List</option>
                                <option value="type">Items by Type</option>
                            </select>
                        </div>

                        <input type="hidden" id="selectedCategory" value="all" />
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

        <section id="typeView" class="type-view-section" style="display: none;">
            <div id="typeViewContent">
                <!-- Items grouped by type will be rendered here -->
            </div>
        </section>

        <footer class="d-flex justify-content-center align-items-center gap-3">
            <button class="btn btn-secondary" id="prevPage">Previous</button>
            <span id="pageInfo" class="fw-medium"></span>
            <button class="btn btn-primary" id="nextPage">Next</button>
            <p id="itemSummary" class="mt-3 text-muted"></p>
        </footer>

        <div class="modal fade" id="itemModal" tabindex="-1" aria-labelledby="modalTitle" aria-hidden="true">
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
                                <input name="quantity" type="number" id="quantity" class="form-control" step="1" />
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-medium">Price</label>
                                <input name="price" type="number" id="price" class="form-control" step="0.01" required />
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-medium">Item Category</label>
                                <select id="itemType" class="form-select"></select>
                            </div>
                            <div id="newCategorySection" class="row" style="display: none;">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label fw-medium">New Category Name</label>
                                    <input type="text" id="newCategoryName" class="form-control" />
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label fw-medium">Category Image URL</label>
                                    <input type="text" id="newCategoryImageUrl" class="form-control" />
                                </div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-medium">QBO Type</label>
                                <select id="qboType" class="form-select">
                                    <option value="0">Select QBO Type</option>
                                    <option value="1">Service</option>
                                    <option value="2">Non-Inventory</option>
                                    <option value="3">Inventory</option>
                                    <option value="4">Other Charge</option>
                                    <option value="5">Payment</option>
                                    <option value="6">Discount</option>
                                    <option value="7">Sales Tax</option>
                                    <option value="8">Bundle</option>
                                </select>
                            </div>
                            <div id="groupItemsSection" class="col-12 mb-3" style="display: none;">
                                <label class="form-label fw-medium">Select Items for Group</label>
                                <div id="subItemList" class="list-group" style="max-height: 300px; overflow-y: auto;"></div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-medium">Location</label>
                                <input name="location" type="text" id="location" class="form-control" />
                            </div>
                            <div class="col-md-12 mb-3">
                                <label class="form-label fw-medium">Description</label>
                                <textarea name="description" id="description" class="form-control"></textarea>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" id="cancelBtn" data-bs-dismiss="modal">Cancel</button>
                            <button type="button" onclick="updateItem(event)" class="btn btn-primary" id="submitBtn">Add Item</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- Manage Item Types Modal -->
      <div class="modal fade show" id="manageTypesModal" tabindex="-1"
     aria-labelledby="manageTypesModalLabel"
     aria-modal="true" role="dialog">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="manageTypesModalLabel">Manage Item Categories</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                 <%--       <form id="itemTypeForm" class="mb-4 p-3 border rounded">
                            <input type="hidden" id="itemTypeId" value="0" />
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="itemTypeName" class="form-label">Category Name</label>
                                    <input type="text" class="form-control" id="itemTypeName" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="itemTypeImageUpload" class="form-label">Category Image</label>

                                    <!-- The 'onchange' event calls the preview function -->
                                    <input type="file" class="form-control" id="itemTypeImageUpload" accept="image/*" onchange="previewImageTypeImage(this);" />

                                    <div class="mt-2">
                                        <!-- The preview image tag -->
                                        <img id="itemTypeImagePreview" src="#" alt="Image Preview" class="img-thumbnail" style="max-width: 100px; max-height: 100px; display: none;" />
                                    </div>
                                </div>


                            </div>
                            <button type="submit" class="btn btn-primary" id="saveTypeBtn">Save Category</button>
                            <button type="button" class="btn btn-secondary" id="clearTypeFormBtn">Clear</button>
                        </form>--%>
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Name</th>
                                    <th>Image URL</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="itemTypesTableBody"></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- Item Assignment Modal -->
        <div class="modal fade" id="assignmentModal" tabindex="-1" aria-labelledby="assignmentModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-xl">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="assignmentModalLabel">Assign Items to Category: <span id="assignmentTypeName"></span></h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <p>Select the items you want to assign to this category. Items already assigned to this category are pre-selected.</p>
                        <input type="hidden" id="assignmentTypeId" />
                        <div id="assignmentItemList" class="list-group" style="max-height: 500px; overflow-y: auto;"></div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="button" class="btn btn-primary" id="saveAssignmentsBtn">Save Assignments</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

<script>

    document.addEventListener('DOMContentLoaded', () => {

        function setupModalFocus(modalId) {
            const modalElement = document.getElementById(modalId);
            if (!modalElement) return;

            let modalTriggerElement = null;

            modalElement.addEventListener('show.bs.modal', function (event) {
                modalTriggerElement = event.relatedTarget;
            });

            modalElement.addEventListener('hide.bs.modal', function () {
                // Blur any focused element inside the modal
                const focusedElement = document.activeElement;
                if (modalElement.contains(focusedElement)) {
                    focusedElement.blur();
                }
            });

            modalElement.addEventListener('hidden.bs.modal', function () {
                if (modalTriggerElement) {
                    modalTriggerElement.focus();
                }
            });
        }

    
        setupModalFocus('manageTypesModal');
        setupModalFocus('itemModal');
        setupModalFocus('assignmentModal');


        let currentView = 'list';
        const maxImageSize = 500;

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

        $('#itemTypesTableBody').on('click', 'tr.editable-row', function (e) {
            if ($(e.target).closest('.actions-dropdown').length > 0) {
                return;
            }
            const id = $(this).data('id');
            const name = $(this).data('name');
            const imageUrl = $(this).data('image-url');
            editItemType(id, name, imageUrl);
        });

        function initialize() {
            $('#listView').show();
            $('#typeView').hide();
            $('#categoryImageContainer').show();
        }

        $('#viewToggle').on('change', function () {
            currentView = $(this).val();
            $('#selectedCategory').val('all');
            $('#categoryImageContainer .category-card').removeClass('active');
            $('#categoryImageContainer .category-card[data-category-id="all"]').addClass('active');
            if (currentView === 'list') {
                $('#listView').show();
                $('#typeView').hide();
                $('#categoryImageContainer').show();
                $('#prevPage').show();
                $('#nextPage').show();
                $('#pageInfo').show();
                $('#itemSummary').show();
                applyFilters();
            } else {
                $('#listView').hide();
                $('#typeView').show();
                $('#categoryImageContainer').hide();
                $('#prevPage').hide();
                $('#nextPage').hide();
                $('#pageInfo').hide();
                $('#itemSummary').hide();
                renderTypeView();
            }
        });

        initialize();
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
                if ($('#viewToggle').val() === 'type') {
                    renderTypeView();
                }
            },
            error: function (error) {
                console.error("Error loading items:", error);
            }
        });
    }

    function applyFilters() {
        const searchTerm = $('#searchBar').val().trim().toLowerCase();
        const selectedType = $('#selectedCategory').val().toLowerCase();

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
            tbody.append('<tr><td colspan="9">No items found.</td></tr>');
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
               <td class="text-center">
<div class="dropdown actions-dropdown">
    <button class="btn btn-light btn-sm dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
        <i class="fa fa-ellipsis-v"></i>
    </button>
    <ul class="dropdown-menu">
        <li><a class="dropdown-item" onclick="editItem(event, '${item.Id}')"><i class="fa fa-pencil"></i> Edit</a></li>
        <li><a class="dropdown-item text-danger" onclick="deleteItem('${item.Id}')"><i class="fa fa-trash"></i> Delete</a></li>
    </ul>
</div>
</td>
            </tr>
            `);
        });

        const endIndex = Math.min(startIndex + pageSize, filteredData.length);
        $('#itemSummary').text(`Showing ${startIndex + 1}–${endIndex} of ${filteredData.length} items`);
    }

    function renderTypeView() {
        const $content = $('#typeViewContent');
        $content.empty();

        const groupedItems = {};
        itemTypes.forEach(type => {
            groupedItems[type.Id] = {
                Name: type.Name,
                ImageUrl: type.ImageUrl || '/Content/Images/default-placeholder-image.png',
                Items: itemData.filter(item => item.ItemTypeId === type.Id)
            };
        });

        groupedItems['unassigned'] = {
            Name: 'Unassigned',
            ImageUrl: '/path/to/your/default-placeholder-image.png',
            Items: itemData.filter(item => !item.ItemTypeId || item.ItemTypeId === 0)
        };

        Object.keys(groupedItems).forEach(typeId => {
            const group = groupedItems[typeId];
            if (group.Items.length > 0) {
                const $groupDiv = $(`
                    <div class="type-group">
                        <h3>
                            <img src="${group.ImageUrl}" alt="${group.Name}" class="category-image" style="width: 32px; height: 32px;" />
                            ${group.Name}
                        </h3>
                        <div class="row"></div>
                    </div>
                `);
                const $row = $groupDiv.find('.row');

                group.Items.forEach(item => {
                    $row.append(`
                        <div class="col-md-4">
                            <div class="type-item-card">
                                <div class="type-item-details">
                                    <h5>${item.ItemName || ''}</h5>
                                    <p>SKU: ${item.Sku || 'N/A'}</p>
                                    <p>Price: $${(item.Price || 0).toFixed(2)}</p>
                                    <p>Qty: ${item.Quantity || 0}</p>
                                </div>
                               <div class="type-item-actions">
<div class="dropdown actions-dropdown">
    <button class="btn btn-light btn-sm dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
        <i class="fa fa-ellipsis-v"></i>
    </button>
    <ul class="dropdown-menu">
        <li><a class="dropdown-item" onclick="editItem(event, '${item.Id}')"><i class="fa fa-pencil"></i> Edit</a></li>
        <li><a class="dropdown-item text-danger" onclick="deleteItem('${item.Id}')"><i class="fa fa-trash"></i> Delete</a></li>
    </ul>
</div>
</div>
                            </div>
                        </div>
                    `);
                });

                $content.append($groupDiv);
            }
        });

        if ($content.children().length === 0) {
            $content.append('<p>No items found.</p>');
        }
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

    $('#clearSearchBtn').click(function () {
        $('#searchBar').val('');
        $('#selectedCategory').val('all');
        $('#categoryImageContainer .category-card').removeClass('active');
        $('#categoryImageContainer .category-card[data-category-id="all"]').addClass('active');
        applyFilters();
    });

    $('#entriesPerPage').on('change', function () {
        pageSize = parseInt($(this).val());
        currentPage = 1;
        renderItems();
        updatePagination();
    });

    function loadCategory() {
        $.ajax({
            url: 'BillableItems.aspx/GetItemTypes',
            type: "POST",
            contentType: "application/json; charset=utf-8",
            dataType: 'json',
            success: function (rs) {
                itemTypes = rs.d || [];
                const $container = $('#categoryImageContainer');
                $container.empty();

                $container.append(`
            <div class="category-card active" data-category-id="all" data-category-name="all">
                <img src="/path/to/your/all-items-icon.png" alt="All Items" class="category-image"/>
                <div class="category-name">All Items</div>
            </div>
        `);

                itemTypes.forEach(function (item) {
                    const imageUrl = item.ImageUrl || '/Content/placeholder.png';
                    $container.append(`
                <div class="category-card" data-category-id="${item.Id}" data-category-name="${item.Name.toLowerCase()}">
                    <img src="${imageUrl}" alt="${item.Name}" class="category-image"/>
                    <div class="category-name">${item.Name}</div>
                </div>
            `);
                });

                $container.append(`
            <div class="category-card manage-types-card" id="manageTypesBtn">
                <i class="fa fa-pencil" style="font-size: 24px;"></i>
                <div class="category-name">Manage Categories</div>
            </div>
        `);

                loadItems();
            },
            error: function (error) {
                console.error("Error loading item types:", error);
                itemTypes = [];
                loadItems();
            }
        });
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
                    $('#qboType').val(data.QboType || 0);
                    populateItemTypes(data.ItemTypeId);
                    if (data.QboType === 8) {
                        $.ajax({
                            url: 'BillableItems.aspx/GetSubItemsForGroup',
                            type: "POST",
                            contentType: "application/json; charset=utf-8",
                            data: JSON.stringify({ groupId: data.Id }),
                            dataType: 'json',
                            success: function (subRs) {
                                const subIds = subRs.d || [];
                                populateSubItemList(subIds);
                                $('#groupItemsSection').show();
                            }
                        });
                    } else {
                        $('#groupItemsSection').hide();
                    }
                    if (data.IsTaxable === true) {
                        $('#taxYes').prop('checked', true);
                    } else {
                        $('#taxNo').prop('checked', true);
                    }
                    itemModal.show();
                },
                error: function (error) {
                    console.error("Error fetching item:", error);
                }
            });
        }
    }

    function populateItemTypes(selectedId) {
        const $dropdown = $('#itemType');
        $dropdown.empty();
        $dropdown.append('<option value="0">Select Category</option>');
        $.each(itemTypes, function (i, item) {
            const isSelected = item.Id === selectedId ? 'selected' : '';
            const option = `<option value="${item.Id}" ${isSelected}>${item.Name}</option>`;
            $dropdown.append(option);
        });
        $dropdown.append('<option value="add_new">Add New Category...</option>');
    }

    function populateSubItemList(selectedSubIds) {
        const $list = $('#subItemList');
        $list.empty();
        const currentId = $('#Id').val();
        itemData.forEach(item => {
            if (item.Id !== currentId) {
                const isChecked = selectedSubIds.includes(item.Id) ? 'checked' : '';
                $list.append(`
                    <label class="list-group-item">
                        <input class="form-check-input me-1" type="checkbox" value="${item.Id}" ${isChecked}>
                        ${item.ItemName}
                    </label>
                `);
            }
        });
    }

    async function updateItem(e) {
        e.preventDefault();
        if (!validateItemForm()) {
            return;
        }
        let itemId = $('#Id').val();
        if (itemId != '') {
            await updateData();
        } else {
            await saveData();
        }
    }

    async function getOrCreateItemTypeId() {
        let typeId = parseInt($('#itemType').val());
        if ($('#itemType').val() === 'add_new') {
            const name = $('#newCategoryName').val().trim();
            const imageUrl = $('#newCategoryImageUrl').val().trim();
            if (!name) {
                alert('Category Name required');
                return null;
            }
            const itemTypeData = {
                Id: 0,
                Name: name,
                ImageUrl: imageUrl
            };
            try {
                const response = await $.ajax({
                    type: "POST",
                    url: "BillableItems.aspx/SaveItemType",
                    data: JSON.stringify({ itemTypeData: itemTypeData }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json"
                });
                if (response.d) {
                    typeId = response.d;
                    itemTypes.push({ Id: typeId, Name: name, ImageUrl: imageUrl });
                    loadCategory();
                } else {
                    alert('Failed to save category');
                    return null;
                }
            } catch (e) {
                alert('Error saving category');
                return null;
            }
        }
        return typeId;
    }

    async function updateData() {
        const typeId = await getOrCreateItemTypeId();
        if (typeId === null) return;
        const qboTypeVal = parseInt($('#qboType').val());
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
            ItemTypeId: typeId,
            QboType: qboTypeVal
        };
        if (qboTypeVal === 8) {
            const subItemIds = [];
            $('#subItemList input:checked').each(function () {
                subItemIds.push(parseInt($(this).val()));
            });
            itemData.SubItemIds = subItemIds;
        }
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
                } else {
                    alert("Something went wrong!");
                }
            },
            error: function (xhr, status, error) {
                console.error("Error updating details: ", error);
            }
        });
    }

    async function saveData() {
        const typeId = await getOrCreateItemTypeId();
        if (typeId === null) return;
        const qboTypeVal = parseInt($('#qboType').val());
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
            ItemTypeId: typeId,
            QboType: qboTypeVal
        };
        if (qboTypeVal === 8) {
            const subItemIds = [];
            $('#subItemList input:checked').each(function () {
                subItemIds.push(parseInt($(this).val()));
            });
            itemData.SubItemIds = subItemIds;
        }
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
                } else {
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

    function deleteItem(id) {
        if (confirm('Are you sure you want to delete this item?')) {
            $.ajax({
                url: 'BillableItems.aspx/DeleteItem',
                type: "POST",
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify({ itemId: id }),
                dataType: 'json',
                success: function (rs) {
                    if (rs.d) {
                        alert('Item deleted successfully!');
                        loadItems();
                    } else {
                        alert('Failed to delete item.');
                    }
                },
                error: function (error) {
                    alert('Error deleting item.');
                }
            });
        }
    }

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
        $('#qboType').val(0);
        $('#QboId').val('');
        $('#taxNo').prop('checked', true);
        populateItemTypes(0);
        $('#newCategorySection').hide();
        $('#groupItemsSection').hide();
        itemModal.show();
    }

    $('#itemType').on('change', function () {
        if ($(this).val() === 'add_new') {
            $('#newCategorySection').show();
        } else {
            $('#newCategorySection').hide();
        }
    });

    $('#qboType').on('change', function () {
        if ($(this).val() === '8') {
            populateSubItemList([]);
            $('#groupItemsSection').show();
        } else {
            $('#groupItemsSection').hide();
        }
    });

    $('#categoryImageContainer').on('click', '.category-card', function () {
        const categoryId = $(this).data('category-id');
        const categoryName = $(this).data('category-name');

        if ($(this).is('#manageTypesBtn')) {
            populateTypesTable();
            manageTypesModal.show();
            return;
        }

        $('#categoryImageContainer .category-card').removeClass('active');
        $(this).addClass('active');
        $('#selectedCategory').val(categoryName || 'all');
        applyFilters();
    });

    const manageTypesModal = new bootstrap.Modal(document.getElementById('manageTypesModal'));

    function populateTypesTable() {
        const $tbody = $('#itemTypesTableBody');
        $tbody.empty();
        itemTypes.forEach(type => {
            const safeName = type.Name.replace(/'/g, "\\'");
            const imageUrl = type.ImageUrl || '';

            $tbody.append(`
        <tr class="editable-row" 
            data-id="${type.Id}" 
            data-name="${safeName}" 
            data-image-url="${imageUrl}"
            style="cursor: pointer;"
            title="Click to edit ${type.Name}">
            
            <td>${type.Name}</td>
            <td>${imageUrl || 'N/A'}</td>
            <td class="text-start">
                <div class="dropdown actions-dropdown">
                    <button class="btn btn-light btn-sm dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                        <i class="fa fa-ellipsis-v"></i>
                    </button>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" onclick="editItemType(${type.Id}, '${safeName}', '${imageUrl}')"><i class="fa fa-pencil"></i> Edit</a></li>
                        <li><a class="dropdown-item" onclick="openAssignmentModal(${type.Id}, '${safeName}')"><i class="fa fa-tasks"></i> Assign Items</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item text-danger" onclick="deleteItemType(${type.Id})"><i class="fa fa-trash"></i> Delete</a></li>
                    </ul>
                </div>
            </td>
        </tr>
    `);
        });
    }

    $('#saveTypeBtn').on('click', function (e) {
        e.preventDefault();
        e.stopImmediatePropagation();

        const name = $('#itemTypeName').val().trim();
        if (!name) {
            Swal.fire('Validation Error', 'Category Name is required.', 'warning');
            return false;
        }

        var formData = new FormData();
        formData.append("Id", parseInt($('#itemTypeId').val()) || 0);
        formData.append("Name", name);

        const existingImageUrl = $('#itemTypeImagePreview').attr('src');
        if (existingImageUrl && existingImageUrl !== '#') {
            formData.append("ExistingImageUrl", existingImageUrl);
        }

        var fileInput = $('#itemTypeImageUpload')[0];
        if (fileInput.files.length > 0) {
            formData.append("ImageFile", fileInput.files[0]);
        }

        $.ajax({
            type: "POST",
            url: "ItemTypeImageUpload.ashx", 
            data: formData,
            processData: false,
            contentType: false,
            dataType: "json", 
            success: function (response) {
                if (response.status === "Success") {
                    const manageTypesModal = bootstrap.Modal.getInstance(document.getElementById("manageTypesModal"));
                    manageTypesModal.hide();

                    Swal.fire("Success", "Category saved successfully!", "success");
                    resetTypeForm();
                    loadCategory(); 
                } else {
                  
                    Swal.fire("Server Message", response.error || "An unknown issue occurred.", "warning");
                }
            },
            error: function (xhr, status, error) {
                let serverMessage = "An unknown error occurred.";
 
                if (xhr.responseJSON && xhr.responseJSON.error) {
                    serverMessage = xhr.responseJSON.error;
                }
                Swal.fire('Request Failed', serverMessage, 'error');
            }
        });

        return false;
    });



    function editItemType(id, name, imageUrl) {
        $('#itemTypeId').val(id);
        $('#itemTypeName').val(name);

        const preview = $('#itemTypeImagePreview');
        if (imageUrl && imageUrl.trim() !== '' && imageUrl.trim().toLowerCase() !== 'n/a') {
            preview.attr('src', imageUrl);
            preview.show();
        } else {
            preview.attr('src', '#').hide();
        }

        $('#itemTypeImageUpload').val('');
        $('#manageTypesModal .modal-body').scrollTop(0);
    }

    function deleteItemType(id) {
        if (!confirm('Are you sure you want to delete this category?')) {
            return;
        }

        $.ajax({
            type: "POST",
            url: "BillableItems.aspx/DeleteItemType",
            data: JSON.stringify({ itemTypeId: id }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                if (response.d) {
                    alert("Category deleted successfully!");
                    loadCategory();
                    populateTypesTable();
                } else {
                    alert("Error: Could not delete the Category. It might be in use.");
                }
            }
        });
    }

    $('#clearTypeFormBtn').on('click', resetTypeForm);
    function previewImageTypeImage(input) {
        const preview = document.getElementById('itemTypeImagePreview');
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = function (e) {
                preview.src = e.target.result;
                preview.style.display = 'block';
            };
            reader.readAsDataURL(input.files[0]);
        } else {
            preview.src = '#';
            preview.style.display = 'none';
        }
    }

    function resetTypeForm() {
        $('#itemTypeId').val('0');
        $('#itemTypeForm')[0].reset();
        $('#itemTypeImagePreview').attr('src', '#').hide();
    }

    const assignmentModal = new bootstrap.Modal(document.getElementById('assignmentModal'));

    function openAssignmentModal(typeId, typeName) {
        $('#assignmentTypeName').text(typeName);
        $('#assignmentTypeId').val(typeId);

        const $itemListContainer = $('#assignmentItemList');
        $itemListContainer.empty();
        $itemListContainer.html('<div class="text-center p-5"><div class="spinner-border" role="status"><span class="visually-hidden">Loading...</span></div></div>');

        if (itemData && itemData.length > 0) {
            $itemListContainer.empty();
            itemData.forEach(item => {
                const isChecked = item.ItemTypeId == typeId ? 'checked' : '';
                $itemListContainer.append(`
                    <label class="list-group-item">
                        <input class="form-check-input me-1" type="checkbox" value="${item.Id}" ${isChecked}>
                        <strong>${item.ItemName}</strong> <small class="text-muted">(${item.Sku || 'No SKU'})</small>
                    </label>
                `);
            });
        } else {
            $itemListContainer.html('<p class="text-center">No billable items found to assign.</p>');
        }

        assignmentModal.show();
    }

        $('#saveAssignmentsBtn').on('click', function () {
        const typeId = parseInt($('#assignmentTypeId').val());
        const selectedItemIds = [];

        $('#assignmentItemList input[type="checkbox"]:checked').each(function () {
            selectedItemIds.push($(this).val());
        });

        if (selectedItemIds.length === 0) {
            if (!confirm("You have not selected any items. This will unassign all items from this category. Continue?")) {
                return;
            }
        }

        $.ajax({
            type: "POST",
        url: "BillableItems.aspx/AssignItemsToType",
        data: JSON.stringify({itemIds: selectedItemIds, itemTypeId: typeId }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
                if (response.d) {
            alert("Assignments saved successfully!");
        assignmentModal.hide();
        loadItems();
                } else {
            alert("Error: Could not save assignments.");
                }
            },
        error: function () {
            alert("A server error occurred while saving assignments.");
            }
        });
    });

</script>
</asp:Content>
