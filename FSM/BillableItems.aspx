<%@ Page Title="Billable Items" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="BillableItems.aspx.cs" Inherits="FSM.BillableItems" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style type="text/css">
        .bill-container { width: 100%; margin-top: 50px; padding: 0 25px; box-sizing: border-box; }
        .bill-header { display: flex; flex-direction: column; gap: 16px; margin-bottom: 24px; }
        .bill-title { font-size: 24px; font-weight: bold; color: #f97316; }
        .bill-btn-container { display: flex; flex-direction: column; gap: 16px; }
        .bill-btn { padding: 8px 16px; border-radius: 8px; border: none; cursor: pointer; color: #ffffff; }
        .bill-sync-btn { background-color: #16a34a; }
        .bill-sync-btn:hover { background-color: #15803d; }
        .bill-add-btn { background-color: #2563eb; }
        .bill-add-btn:hover { background-color: #1d4ed8; }
        .bill-filter-section { display: flex; flex-direction: column; gap: 16px; margin-bottom: 24px; }
        .bill-entries { display: flex; align-items: center; gap: 8px; font-size: 14px; }
        .bill-select { border: 1px solid #d1d5db; border-radius: 8px; padding: 4px 12px; background-color: #ffffff; }
        .bill-search { border: 1px solid #d1d5db; border-radius: 8px; padding: 8px 16px; width: 100%; max-width: 256px; box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1); }
        .bill-list-view { background-color: #ffffff; border-radius: 8px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); overflow-x: auto; }
        .bill-table { width: 100%; border-collapse: collapse; }
        .bill-table th, .bill-table td { border: 1px solid #e5e7eb; padding: 12px; text-align: left; }
        .bill-table th { background-color: #f3f4f6; color: #4b5563; font-weight: 600; font-size: 12px; text-transform: uppercase; }
        .bill-table td { color: #1f2937; }
        .bill-edit-btn, .bill-delete-btn { font-weight: 600; background: none; border: none; cursor: pointer; padding: 0 8px; }
        .bill-edit-btn { color: #2563eb; }
        .bill-edit-btn:hover { color: #1d4ed8; }
        .bill-delete-btn { color: #dc2626; }
        .bill-delete-btn:hover { color: #b91c1c; }
        .bill-image-view { display: none; grid-template-columns: repeat(1, 1fr); gap: 24px; }
        .bill-image-card { background-color: #ffffff; border-radius: 8px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); padding: 16px; text-align: center; }
        .bill-image { width: 128px; height: 128px; object-fit: cover; border-radius: 8px; margin-bottom: 8px; }
        .bill-image-title { font-size: 18px; font-weight: 600; color: #1f2937; }
        .bill-image-text { font-size: 14px; color: #4b5563; }
        .bill-pagination { display: flex; justify-content: center; align-items: center; gap: 16px; margin-top: 24px; }
        .bill-page-btn { background-color: #e5e7eb; color: #374151; padding: 8px 16px; border-radius: 8px; border: none; cursor: pointer; }
        .bill-page-btn:hover:not(:disabled) { background-color: #d1d5db; }
        .bill-page-btn:disabled { background-color: #f3f4f6; color: #6b7280; cursor: not-allowed; }
        .bill-page-info { font-size: 14px; font-weight: 500; color: #374151; }
        .bill-modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0.5); justify-content: center; align-items: center; z-index: 1000; }
        .bill-modal-content { background-color: #ffffff; padding: 24px; border-radius: 8px; width: 90%; max-width: 500px; }
        .bill-modal-title { font-size: 20px; font-weight: 600; margin-bottom: 24px; }
        .bill-modal-form { display: flex; flex-direction: column; gap: 24px; }
        .bill-modal-field { display: flex; flex-direction: column; gap: 8px; }
        .bill-modal-label { font-weight: 500; color: #374151; }
        .bill-modal-input { padding: 8px; border: 1px solid #d1d5db; border-radius: 8px; width: 100%; box-sizing: border-box; }
        .bill-modal-radio-group { display: flex; gap: 16px; }
        .bill-modal-radio { display: flex; align-items: center; gap: 4px; }
        .bill-modal-image-section { display: none; margin-top: 8px; }
        .bill-modal-image-preview { max-width: 100%; height: auto; border-radius: 8px; display: none; }
        .bill-modal-error { color: #dc2626; font-size: 14px; margin-top: 4px; display: none; }
        .bill-modal-btns { display: flex; gap: 8px; }
        .bill-modal-submit { background-color: #2563eb; color: #ffffff; padding: 8px 16px; border-radius: 8px; border: none; cursor: pointer; }
        .bill-modal-submit:hover { background-color: #1d4ed8; }
        .bill-modal-cancel { background-color: #e5e7eb; color: #374151; padding: 8px 16px; border-radius: 8px; border: none; cursor: pointer; }
        .bill-modal-cancel:hover { background-color: #d1d5db; }

        @media (min-width: 640px) {
            .bill-header { flex-direction: row; justify-content: space-between; align-items: center; }
            .bill-btn-container { flex-direction: row; }
            .bill-filter-section { flex-direction: row; justify-content: space-between; align-items: center; }
        }
        @media (min-width: 768px) {
            .bill-title { font-size: 30px; }
            .bill-image-view { grid-template-columns: repeat(3, 1fr); }
        }
        @media (min-width: 1024px) {
            .bill-image-view { grid-template-columns: repeat(5, 1fr); }
        }
    </style>

    <input type="hidden" id="companyId" value="7369" />

    <div class="bill-container">
        <header class="bill-header">
            <h1 class="bill-title">Billable Items</h1>
            <div class="bill-btn-container">
                <button class="bill-btn bill-sync-btn" id="syncBtn">Sync with CEC/QBO</button>
                <button class="bill-btn bill-add-btn" id="addItemBtn">+ Add Item</button>
            </div>
        </header>

        <section class="bill-filter-section">
            <div class="bill-entries">
                <span>Show</span>
                <select id="entriesPerPage" class="bill-select">
                    <option value="10">10</option>
                    <option value="25">25</option>
                    <option value="50">50</option>
                    <option value="100">100</option>
                </select>
                <span>entries</span>
            </div>
            <div class="bill-btn-container">
                <select id="categoryFilter" class="bill-select">
                    <option value="all">All Categories</option>
                </select>
                <select id="viewToggle" class="bill-select">
                    <option value="list" selected>List View</option> <!-- Default to List View -->
                    <option value="image">Image View</option>
                </select>
                <input type="text" id="searchBar" class="bill-search" placeholder="Search..." />
            </div>
        </section>

        <section id="listView" class="bill-list-view">
            <table class="bill-table">
                <thead>
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
        </section>

        <section id="imageView" class="bill-image-view"></section>

        <footer class="bill-pagination">
            <button class="bill-page-btn" id="prevPage">Previous</button>
            <span class="bill-page-info" id="pageInfo"></span>
            <button class="bill-page-btn" id="nextPage">Next</button>
        </footer>

        <div class="bill-modal" id="itemModal">
            <div class="bill-modal-content">
                <h2 class="bill-modal-title" id="modalTitle">Add New Item</h2>
                <form id="itemForm" class="bill-modal-form">
                    <div class="bill-modal-field">
                        <label class="bill-modal-label">Item Name</label>
                        <input type="text" id="itemName" class="bill-modal-input" required />
                    </div>
                    <div class="bill-modal-field">
                        <label class="bill-modal-label">Description</label>
                        <input type="text" id="description" class="bill-modal-input" />
                    </div>
                    <div class="bill-modal-field">
                        <label class="bill-modal-label">Barcode</label>
                        <input type="text" id="barcode" class="bill-modal-input" />
                    </div>
                    <div class="bill-modal-field">
                        <label class="bill-modal-label">Price</label>
                        <input type="number" id="price" class="bill-modal-input" step="0.01" required />
                    </div>
                    <div class="bill-modal-field">
                        <label class="bill-modal-label">Taxable</label>
                        <div class="bill-modal-radio-group">
                            <label class="bill-modal-radio"><input type="radio" name="taxable" value="YES" checked /> Yes</label>
                            <label class="bill-modal-radio"><input type="radio" name="taxable" value="NO" /> No</label>
                        </div>
                    </div>
                    <div class="bill-modal-field">
                        <label class="bill-modal-label">Category</label>
                        <select id="category" class="bill-modal-input">
                            <option value="Charges">Charges</option>
                            <option value="Blinds">Blinds</option>
                            <option value="Shades">Shades</option>
                            <option value="Valances">Valances</option>
                            <option value="create">Create New Category</option>
                        </select>
                    </div>
                    <div class="bill-modal-field">
                        <label class="bill-modal-label">Location</label>
                        <input type="text" id="location" class="bill-modal-input" />
                    </div>
                    <div class="bill-modal-field">
                        <label class="bill-modal-label">Item Type</label>
                        <input type="text" id="itemType" class="bill-modal-input" />
                    </div>
                    <div class="bill-modal-image-section" id="imageSection">
                        <label class="bill-modal-label">Item Image</label>
                        <input type="file" id="itemImage" class="bill-modal-input" accept="image/*" />
                        <img id="imagePreview" class="bill-modal-image-preview" alt="Preview" />
                        <span id="imageError" class="bill-modal-error"></span>
                    </div>
                    <div class="bill-modal-btns">
                        <button type="submit" class="bill-modal-submit" id="submitBtn">Add Item</button>
                        <button type="button" class="bill-modal-cancel" id="cancelBtn">Cancel</button>
                    </div>
                </form>
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
            const itemModal = document.getElementById('itemModal');
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
            let currentView = 'list'; // Explicitly set to list for initial load
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
                        ? `<tr><td colspan="6" style="text-align: center; color: #6b7280;">No items found</td></tr>`
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
                    imageView.style.display = 'grid';
                    imageView.innerHTML = paginatedItems.length === 0
                        ? `<p style="grid-column: span 5; text-align: center; color: #6b7280;">No items found</p>`
                        : paginatedItems.map(item => `
                            <div class="bill-image-card">
                                <img src="${item.imageUrl || 'https://via.placeholder.com/150'}" class="bill-image" alt="${item.name}" />
                                <h3 class="bill-image-title">${item.name}</h3>
                                <p class="bill-image-text">${item.description || 'No description'}</p>
                                <p class="bill-image-text">$${item.price.toFixed(2)}</p>
                                <p class="bill-image-text">${item.taxable}</p>
                                <div>
                                    <button class="bill-edit-btn" data-name="${item.name}">Edit</button>
                                    <button class="bill-delete-btn" data-name="${item.name}">Delete</button>
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
                currentView = viewToggle.value; // Sync with dropdown
                renderItems(); // Render immediately
                listView.style.display = 'block'; // Ensure list view is visible on load
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
                itemModal.style.display = 'flex';
            });

            cancelBtn.addEventListener('click', () => {
                itemModal.style.display = 'none';
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
                if (index !== -1) items[index] = item; // Update existing item
                else items.push(item); // Add new item
                updateCategoryFilter();
                itemModal.style.display = 'none';
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
                    itemModal.style.display = 'flex';
                }
            }

            // Start
            initialize();
        });
    </script>
</asp:Content>