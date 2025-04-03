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
                <div class="col-md-6 text-md-end">
                    <button class="btn btn-success me-2 mb-2 mb-md-0" id="syncBtn">Sync with CEC/QBO</button>
                    <button class="btn btn-primary" id="addItemBtn">+ Add Item</button>
                </div>
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
                        <select id="viewToggle" class="form-select w-auto">
                            <option value="list" selected>List View</option>
                            <option value="image">Image View</option>
                        </select>
                        <input type="text" id="searchBar" class="form-control w-auto" placeholder="Search..." />
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
                                <th>Item Name</th>
                                <th>Description</th>
                                <th>Barcode</th>
                                <th>Price</th>
                                <th>Taxable</th>
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
        </footer>

        <div class="modal fade" id="itemModal" tabindex="-1" aria-labelledby="modalTitle" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h2 class="modal-title fs-5" id="modalTitle">Add New Item</h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form id="itemForm" class="modal-body">
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
                                        <input type="radio" name="taxable" value="YES" id="taxYes" class="form-check-input" checked />
                                        <label class="form-check-label" for="taxYes">Yes</label>
                                    </div>
                                    <div class="form-check">
                                        <input type="radio" name="taxable" value="NO" id="taxNo" class="form-check-input" />
                                        <label class="form-check-label" for="taxNo">No</label>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-medium">Category</label>
                                <select id="category" class="form-select">
                                    <option value="Charges">Charges</option>
                                    <option value="Blinds">Blinds</option>
                                    <option value="Shades">Shades</option>
                                    <option value="Valances">Valances</option>
                                    <option value="create">Create New Category</option>
                                </select>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-medium">Location</label>
                                <input type="text" id="location" class="form-control" />
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label fw-medium">Item Type</label>
                                <input type="text" id="itemType" class="form-control" />
                            </div>
                            <div class="col-12 mb-3 bill-modal-image-section" id="imageSection" style="display: none;">
                                <label class="form-label fw-medium">Item Image</label>
                                <input type="file" id="itemImage" class="form-control" accept="image/*" />
                                <img id="imagePreview" class="bill-modal-image-preview mt-2" alt="Preview" />
                                <span id="imageError" class="bill-modal-error"></span>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" id="cancelBtn" data-bs-dismiss="modal">Cancel</button>
                            <button type="submit" class="btn btn-primary" id="submitBtn">Add Item</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            // DOM Elements
            const itemList = document.getElementById('itemList');
            const imageView = document.getElementById('imageView');
            const listView = document.getElementById('listView');
            const searchBar = document.getElementById('searchBar');
            const entriesPerPage = document.getElementById('entriesPerPage');
            const prevPageBtn = document.getElementById('prevPage');
            const nextPageBtn = document.getElementById('nextPage');
            const pageInfo = document.getElementById('pageInfo');
            const addItemBtn = document.getElementById('addItemBtn');
            const itemModal = new bootstrap.Modal(document.getElementById('itemModal'));
            const itemForm = document.getElementById('itemForm');
            const cancelBtn = document.getElementById('cancelBtn');
            const categoryFilter = document.getElementById('categoryFilter');
            const viewToggle = document.getElementById('viewToggle');
            const categorySelect = document.getElementById('category');
            const imageSection = document.getElementById('imageSection');
            const itemImage = document.getElementById('itemImage');
            const imagePreview = document.getElementById('imagePreview');
            const imageError = document.getElementById('imageError');
            const modalTitle = document.getElementById('modalTitle');
            const submitBtn = document.getElementById('submitBtn');

            // Initial Data
            let items = [
                { name: "Window Blind", description: "Standard white blind", barcode: "BLD123", price: 45.99, taxable: "YES", category: "Blinds", location: "Warehouse A", itemType: "Type 1", imageUrl: null },
                { name: "Service Charge", description: "Installation fee", barcode: "CHG001", price: 25.00, taxable: "YES", category: "Charges", location: "", itemType: "Service", imageUrl: null },
                { name: "Shade Roller", description: "Blackout shade", barcode: "SHD456", price: 60.50, taxable: "NO", category: "Shades", location: "Warehouse B", itemType: "Type 2", imageUrl: null },
                { name: "Valance Trim", description: "Decorative valance", barcode: "VAL789", price: 15.75, taxable: "YES", category: "Valances", location: "Storefront", itemType: "Type 3", imageUrl: null }
            ];
            let filteredItems = [...items];
            let currentPage = 1;
            let itemsPerPage = parseInt(entriesPerPage.value);
            let currentView = 'list';
            const maxImageSize = 500;

            // Populate category filter
            function updateCategoryFilter() {
                const categories = ['all', ...new Set(items.map(item => item.category))];
                categoryFilter.innerHTML = categories.map(cat => `<option value="${cat}">${cat === 'all' ? 'All Categories' : cat}</option>`).join('');
            }

            // Filter items
            function filterItems() {
                const query = searchBar.value.toLowerCase();
                const category = categoryFilter.value;
                return items.filter(item =>
                    (item.name.toLowerCase().includes(query) || item.description.toLowerCase().includes(query) || (item.barcode && item.barcode.toLowerCase().includes(query))) &&
                    (category === 'all' || item.category === category)
                );
            }

            // Render items
            function renderItems() {
                filteredItems = filterItems();
                const start = (currentPage - 1) * itemsPerPage;
                const end = start + itemsPerPage;
                const paginatedItems = filteredItems.slice(start, end);
                const totalPages = Math.ceil(filteredItems.length / itemsPerPage);

                if (currentView === 'list') {
                    listView.style.display = 'block';
                    imageView.style.display = 'none';
                    itemList.innerHTML = paginatedItems.length === 0
                        ? `<tr><td colspan="6" class="text-center text-muted">No items found</td></tr>`
                        : paginatedItems.map(item => `
                            <tr>
                                <td>${item.name}</td>
                                <td>${item.description}</td>
                                <td>${item.barcode || 'N/A'}</td>
                                <td>$${item.price.toFixed(2)}</td>
                                <td>${item.taxable}</td>
                                <td>
                                    <button class="bill-edit-btn" data-name="${item.name}">Edit</button>
                                    <button class="bill-delete-btn" data-name="${item.name}">Delete</button>
                                </td>
                            </tr>`).join('');
                } else {
                    listView.style.display = 'none';
                    imageView.style.display = 'flex';
                    imageView.innerHTML = paginatedItems.length === 0
                        ? `<p class="col-12 text-center text-muted">No items found</p>`
                        : paginatedItems.map(item => `
                            <div class="col-12 col-sm-6 col-md-4 col-lg-3 mb-4">
                                <div class="bill-image-card card h-100">
                                    <img src="${item.imageUrl || 'https://via.placeholder.com/150'}" class="bill-image card-img-top" alt="${item.name}" />
                                    <div class="card-body">
                                        <h3 class="bill-image-title card-title">${item.name}</h3>
                                        <p class="bill-image-text card-text">${item.description || 'No description'}</p>
                                        <p class="bill-image-text card-text">$${item.price.toFixed(2)}</p>
                                        <p class="bill-image-text card-text">${item.taxable}</p>
                                        <div>
                                            <button class="bill-edit-btn" data-name="${item.name}">Edit</button>
                                            <button class="bill-delete-btn" data-name="${item.name}">Delete</button>
                                        </div>
                                    </div>
                                </div>
                            </div>`).join('');
                }

                pageInfo.textContent = `Page ${currentPage} of ${totalPages || 1}`;
                prevPageBtn.disabled = currentPage === 1;
                nextPageBtn.disabled = currentPage === totalPages;
            }

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
                updateCategoryFilter();
                currentView = viewToggle.value;
                renderItems();
                listView.style.display = 'block';
                imageView.style.display = 'none';
            }

            // Event Listeners
            searchBar.addEventListener('input', () => { currentPage = 1; renderItems(); });
            entriesPerPage.addEventListener('change', (e) => { itemsPerPage = parseInt(e.target.value); currentPage = 1; renderItems(); });
            prevPageBtn.addEventListener('click', () => { if (currentPage > 1) { currentPage--; renderItems(); } });
            nextPageBtn.addEventListener('click', () => { if (currentPage < Math.ceil(filteredItems.length / itemsPerPage)) { currentPage++; renderItems(); } });
            categoryFilter.addEventListener('change', () => { currentPage = 1; renderItems(); });
            viewToggle.addEventListener('change', (e) => { currentView = e.target.value; currentPage = 1; renderItems(); });

            addItemBtn.addEventListener('click', () => {
                modalTitle.textContent = 'Add New Item';
                submitBtn.textContent = 'Add Item';
                itemForm.reset();
                imageSection.style.display = 'none';
                imagePreview.style.display = 'none';
                imageError.style.display = 'none';
                itemModal.show();
            });

            cancelBtn.addEventListener('click', () => {
                itemModal.hide();
            });

            categorySelect.addEventListener('change', (e) => {
                imageSection.style.display = e.target.value === 'create' ? 'block' : 'none';
            });

            itemImage.addEventListener('change', (e) => {
                const file = e.target.files[0];
                if (file) {
                    validateImage(file)
                        .then(() => {
                            const reader = new FileReader();
                            reader.onload = (ev) => {
                                imagePreview.src = ev.target.result;
                                imagePreview.style.display = 'block';
                                imageError.style.display = 'none';
                            };
                            reader.readAsDataURL(file);
                        })
                        .catch(err => {
                            imageError.textContent = err;
                            imageError.style.display = 'block';
                            imagePreview.style.display = 'none';
                            itemImage.value = '';
                        });
                }
            });

            itemForm.addEventListener('submit', (e) => {
                e.preventDefault();
                const newItem = {
                    name: document.getElementById('itemName').value,
                    description: document.getElementById('description').value,
                    barcode: document.getElementById('barcode').value || '',
                    price: parseFloat(document.getElementById('price').value),
                    taxable: document.querySelector('input[name="taxable"]:checked').value,
                    category: categorySelect.value === 'create' ? prompt('New category name:') || 'Uncategorized' : categorySelect.value,
                    location: document.getElementById('location').value,
                    itemType: document.getElementById('itemType').value,
                    imageUrl: imagePreview.src && imagePreview.style.display !== 'none' ? imagePreview.src : null
                };

                const file = itemImage.files[0];
                if (file) {
                    validateImage(file)
                        .then(() => {
                            const reader = new FileReader();
                            reader.onload = (ev) => {
                                newItem.imageUrl = ev.target.result;
                                saveItem(newItem);
                            };
                            reader.readAsDataURL(file);
                        })
                        .catch(err => {
                            imageError.textContent = err;
                            imageError.style.display = 'block';
                        });
                } else {
                    saveItem(newItem);
                }
            });

            function saveItem(item) {
                const index = items.findIndex(i => i.name === item.name);
                if (index !== -1) items[index] = item;
                else items.push(item);
                updateCategoryFilter();
                itemModal.hide();
                renderItems();
            }

            function deleteItem(name) {
                if (confirm(`Are you sure you want to delete "${name}"?`)) {
                    items = items.filter(item => item.name !== name);
                    updateCategoryFilter();
                    renderItems();
                }
            }

            itemList.addEventListener('click', (e) => {
                if (e.target.classList.contains('bill-edit-btn')) handleEdit(e);
                else if (e.target.classList.contains('bill-delete-btn')) deleteItem(e.target.dataset.name);
            });

            imageView.addEventListener('click', (e) => {
                if (e.target.classList.contains('bill-edit-btn')) handleEdit(e);
                else if (e.target.classList.contains('bill-delete-btn')) deleteItem(e.target.dataset.name);
            });

            function handleEdit(e) {
                const item = items.find(i => i.name === e.target.dataset.name);
                if (item) {
                    modalTitle.textContent = 'Edit Item';
                    submitBtn.textContent = 'Save Changes';
                    document.getElementById('itemName').value = item.name;
                    document.getElementById('description').value = item.description || '';
                    document.getElementById('barcode').value = item.barcode || '';
                    document.getElementById('price').value = item.price;
                    document.getElementById('location').value = item.location || '';
                    document.getElementById('itemType').value = item.itemType || '';
                    document.querySelector(`input[name="taxable"][value="${item.taxable}"]`).checked = true;
                    categorySelect.value = item.category;
                    if (item.imageUrl) {
                        imagePreview.src = item.imageUrl;
                        imagePreview.style.display = 'block';
                        imageSection.style.display = 'block';
                    } else {
                        imagePreview.style.display = 'none';
                        imageSection.style.display = 'none';
                    }
                    imageError.style.display = 'none';
                    itemModal.show();
                }
            }

            // Start
            initialize();
        });
    </script>
</asp:Content>