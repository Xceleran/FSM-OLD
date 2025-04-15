<%@ Page Title="Billable Items" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="BillableItems.aspx.cs" Inherits="FSM.BillableItems" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style type="text/css">
        .bill-container { width: 100%; margin-top: 75px; padding: 0 15px; }
        .bill-title { font-size: 24px; font-weight: bold; color: #f84700; }
        .bill-table { width: 100%; }
        .bill-table th, .bill-table td { padding: 12px; text-align: left; }
        .bill-table th { font-size: 12px; text-transform: uppercase; }
        .bill-edit-btn, .bill-delete-btn { font-weight: 600; background: none; border: none; cursor: pointer; padding: 0 8px; }
        .bill-edit-btn { color: #2563eb; }
        .bill-edit-btn:hover { color: #1d4ed8; }
        .bill-delete-btn { color: #dc2626; }
        .bill-delete-btn:hover { color: #b91c1c; }
        .bill-image-view { display: none; }
        .bill-image-card { text-align: center; }
        .bill-image { width: 128px; height: 128px; object-fit: cover; border-radius: 8px; margin-bottom: 8px; }
        .bill-image-title { font-size: 18px; font-weight: 600; }
        .bill-image-text { font-size: 14px; }
        .bill-modal-image-preview { max-width: 100%; height: auto; border-radius: 8px; display: none; }
        .bill-modal-error { color: #dc2626; font-size: 14px; margin-top: 4px; display: none; }

        @media (max-width: 576px) {
            .bill-table { font-size: 14px; }
            .bill-table th, .bill-table td { padding: 8px; }
            .bill-image { width: 100px; height: 100px; }
        }
    </style>

    <input type="hidden" id="companyId" value="7369" />

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
                <div class="col-md-6 mb-3 mb-md-0">
                    <div class="d-flex align-items-center gap-2">
                        <span>Show</span>
                        <select id="entriesPerPage" class="form-select w-auto">
                            <option value="10">10</option>
                            <option value="25">25</option>
                            <option value="50">50</option>
                            <option value="100">100</option>
                        </select>
                        <span>entries</span>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="d-flex justify-content-md-end gap-2 flex-wrap">
                        <select id="categoryFilter" class="form-select w-auto"></select>
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
                                <th>Item Type</th>
                                <th>Description</th>
                                <th>Barcode</th>
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
            <button class="btn btn-secondary" id="nextPage">Next</button>
            <p id="itemSummary" class="mt-2 text-muted"></p>
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
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-medium">Item Name</label>
                                <input type="text" id="itemName" class="form-control" required />
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-medium">Description</label>
                                <input type="text" id="description" class="form-control" />
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-medium">Barcode</label>
                                <input type="text" id="barcode" class="form-control" />
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-medium">Price</label>
                                <input type="number" id="price" class="form-control" step="0.01" required />
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-medium">Taxable</label>
                                <div class="d-flex gap-3">
                                    <div class="form-check">
                                        <input type="radio" name="taxable" value="1" id="taxYes" class="form-check-input" checked />
                                        <label class="form-check-label" for="taxYes">Yes</label>
                                    </div>
                                    <div class="form-check">
                                        <input type="radio" name="taxable" value="0" id="taxNo" class="form-check-input" />
                                        <label class="form-check-label" for="taxNo">No</label>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-medium">Item Type</label>
                                <select id="itemType" class="form-select"></select>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-medium">Location</label>
                                <input type="text" id="location" class="form-control" />
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
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            // DOM Elements
            //const itemList = document.getElementById('itemList');
            //const imageView = document.getElementById('imageView');
            //const listView = document.getElementById('listView');
            //const searchBar = document.getElementById('searchBar');
            //const entriesPerPage = document.getElementById('entriesPerPage');
            //const prevPageBtn = document.getElementById('prevPage');
            //const nextPageBtn = document.getElementById('nextPage');
            //const pageInfo = document.getElementById('pageInfo');
            //const addItemBtn = document.getElementById('addItemBtn');
            //const itemModal = new bootstrap.Modal(document.getElementById('itemModal'));
            //const itemForm = document.getElementById('itemForm');
            //const cancelBtn = document.getElementById('cancelBtn');
            //const categoryFilter = document.getElementById('categoryFilter');
            //const viewToggle = document.getElementById('viewToggle');
            //const categorySelect = document.getElementById('category');
            //const imageSection = document.getElementById('imageSection');
            //const itemImage = document.getElementById('itemImage');
            //const imagePreview = document.getElementById('imagePreview');
            //const imageError = document.getElementById('imageError');
            

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
            // Start
            //initialize();
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
            console.log($('#categoryFilter').val());
            const selectedType = $('#categoryFilter').val().toLowerCase();

            filteredData = itemData.filter(item => {
                const typeName = (itemTypes.find(t => t.Id === item.ItemTypeId)?.Name || "").toLowerCase();
                const matchesType = selectedType === 'all' || selectedType === "" || typeName === selectedType;
                const combinedText = [
                    item.ItemName,
                    item.typeName,
                    item.Description,
                    item.Barcode,
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
                <td>${item.Barcode || ''}</td>
                <td>${item.Price || ''}</td>
                <td>${item.Taxable || ''}</td>
                <td>
                    <button onclick="editItem('${item.Id}')" class="btn btn-sm btn-primary edit-btn">Edit</button>
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

        function editItem(id) {
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
                        $('#itemName').val(data.ItemName);
                        $('#Id').val(data.Id);
                        $('#description').val(data.Description);
                        $('#barcode').val(data.Barcode);
                        $('#price').val(data.Price);
                        $('#location').val(data.Location);
                        populateItemTypes(data.ItemTypeId);
                        if (data.IsTaxable === "YES") {
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

            $.each(itemTypes, function (i, item) {
                const isSelected = item.Id === selectedId;
                const option = `<option value="${item.Id}" ${isSelected ? 'selected' : ''}>${item.Name}</option>`;
                $dropdown.append(option);
            });
        }

        function updateItem(e) {
            e.preventDefault();
            const itemData = {
                Id: $('#Id').val(),
                CompanyID: $('#companyId').val(),
                ItemName: $('#itemName').val().trim(),
                Description: $('#description').val().trim(),
                Barcode: $('#barcode').val().trim(),
                Price: parseFloat($('#price').val()) || 0,
                IsTaxable: $('input[name="taxable"]:checked').val() === "1",
                Location: $('#location').val().trim(),
                ItemTypeId: parseInt($('#itemType').val().trim()),
            };

            console.log(itemData);

            $.ajax({
                type: "POST",
                url: "BillableItems.aspx/SaveItemData",
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
    </script>
</asp:Content>