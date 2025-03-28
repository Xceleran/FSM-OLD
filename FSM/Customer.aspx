<%@ Page Title="Customers" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="Customer.aspx.cs" Inherits="FSM.Customer" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <link rel="stylesheet" href="https://cdn.datatables.net/2.2.2/css/dataTables.dataTables.min.css">
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/select/3.0.0/css/select.dataTables.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.datatables.net/2.2.2/js/dataTables.min.js"></script>
    <script type="text/javascript" src="https://cdn.datatables.net/select/3.0.0/js/dataTables.select.min.js"></script>

    <style type="text/css">
        /* Unique raw CSS classes */
        .cust-page-container {
            width: 100%;
            padding: 0;
            margin: 0 auto;
            margin-top: 50px;
            padding: 0 25px;
        }

        .cust-header {
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            margin-bottom: 20px;
        }

        .cust-title {
            font-size: 24px;
            font-weight: bold;
            color: #f97316;
        }

        .cust-search-container {
            display: flex;
            flex-direction: column;
            gap: 10px;
            width: 100%;
        }

        .cust-search-input {
            border: 1px solid #d1d5db;
            border-radius: 8px;
            padding: 8px;
            width: 100%;
            box-sizing: border-box;
        }

        .cust-add-btn {
            background-color: #2563eb;
            color: #ffffff;
            padding: 8px 16px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
        }

            .cust-add-btn:hover {
                background-color: #1d4ed8;
            }

        .cust-section {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .cust-list-container {
            width: 100%;
            background-color: #ffffff;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }

        .cust-list-header {
            display: none;
            grid-template-columns: repeat(4, 1fr);
            padding: 10px;
            background-color: #f3f4f6;
            color: #6b7280;
            font-weight: 500;
            font-size: 14px;
            position: sticky;
            top: 0;
            z-index: 10;
        }

            .cust-list-header span {
                overflow: hidden;
                text-overflow: ellipsis;
                white-space: nowrap;
            }

        .cust-list {
            max-height: calc(100vh - 192px);
            overflow-y: auto;
            padding: 8px;
        }

        .cust-item {
            padding: 12px;
            border-bottom: 1px solid #e5e7eb;
            cursor: pointer;
        }

            .cust-item:hover {
                background-color: #f9fafb;
            }

        .cust-item-active {
            background-color: #ccfbf1;
        }

        .cust-item-field {
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .cust-item-label {
            font-weight: 500;
            color: #374151;
            display: inline;
        }

        .cust-status-badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 9999px;
            font-size: 12px;
            margin-left: 8px;
        }

        .cust-status-active {
            background-color: #16a34a;
            color: #ffffff;
        }

        .cust-status-inactive {
            background-color: #dc2626;
            color: #ffffff;
        }

        .cust-details-container {
            width: 100%;
            background-color: #ffffff;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            padding: 16px;
            overflow: hidden;
        }

        .cust-details-header {
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            margin-bottom: 20px;
            gap: 10px;
        }

        .cust-details-title {
            font-size: 20px;
            font-weight: 600;
            color: #1f2937;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .cust-details-btns {
            display: flex;
            flex-direction: column;
            gap: 8px;
            width: 100%;
        }

        .cust-edit-btn, .cust-message-btn {
            background-color: #e5e7eb;
            color: #374151;
            padding: 4px 12px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
        }

            .cust-edit-btn:hover, .cust-message-btn:hover {
                background-color: #d1d5db;
            }

        .cust-details-content {
            max-height: calc(100vh - 192px);
            overflow-y: auto;
        }

        .cust-section-block {
            border-bottom: 1px solid #e5e7eb;
        }

        .cust-section-toggle {
            width: 100%;
            padding: 16px;
            background-color: #f9fafb;
            text-align: left;
            font-weight: 500;
            color: #374151;
            border: none;
            cursor: pointer;
        }

            .cust-section-toggle:hover {
                background-color: #f3f4f6;
            }

        .cust-section-content {
            padding: 16px;
            display: none;
        }

        .cust-info-text {
            margin-bottom: 8px;
        }

        .cust-info-label {
            color: #4b5563;
            font-weight: 500;
        }

        .cust-info-value {
            color: #1f2937;
            word-wrap: break-word;
        }

        .cust-site-card {
            padding: 16px;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            margin-bottom: 16px;
        }

        .cust-site-title {
            font-size: 18px;
            font-weight: 500;
            color: #1f2937;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .cust-site-info {
            color: #4b5563;
            margin: 4px 0;
        }

        .cust-site-actions {
            margin-top: 8px;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .cust-site-edit-btn {
            background-color: #e5e7eb;
            color: #374151;
            padding: 4px 8px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
        }

            .cust-site-edit-btn:hover {
                background-color: #d1d5db;
            }

        .cust-site-view-link {
            background-color: #2563eb;
            color: #ffffff;
            padding: 4px 8px;
            border-radius: 8px;
            text-decoration: none;
            display: inline-block;
        }

            .cust-site-view-link:hover {
                background-color: #1d4ed8;
            }

        .cust-site-add-btn {
            background-color: #e5e7eb;
            color: #374151;
            padding: 8px 16px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
        }

            .cust-site-add-btn:hover {
                background-color: #d1d5db;
            }

        .cust-status-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
        }

        .cust-status-tag {
            display: inline-flex;
            align-items: center;
            padding: 4px 12px;
            border-radius: 9999px;
            background-color: #e5e7eb;
            cursor: pointer;
        }

            .cust-status-tag:hover {
                opacity: 0.8;
            }

        .cust-tag-delete {
            margin-left: 8px;
            font-size: 14px;
            color: #6b7280;
            border: none;
            background: none;
            cursor: pointer;
        }

            .cust-tag-delete:hover {
                color: #dc2626;
            }

        .cust-tag-input-container {
            display: flex;
            flex-direction: column;
            gap: 8px;
            margin-top: 8px;
        }

        .cust-tag-input {
            border: 1px solid #d1d5db;
            border-radius: 8px;
            padding: 8px;
            width: 100%;
            box-sizing: border-box;
        }

        .cust-tag-add-btn {
            background-color: #e5e7eb;
            color: #374151;
            padding: 8px 16px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
        }

            .cust-tag-add-btn:hover {
                background-color: #d1d5db;
            }

        .cust-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            justify-content: center;
            align-items: center;
            z-index: 1000;
        }

        .cust-modal-content {
            background-color: #ffffff;
            padding: 16px;
            border-radius: 8px;
            width: 90%;
            max-width: 500px;
        }

        .cust-modal-title {
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 16px;
        }

        .cust-modal-form {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .cust-modal-field {
            display: flex;
            flex-direction: column;
        }

        .cust-modal-label {
            margin-bottom: 4px;
        }

        .cust-modal-input {
            width: 100%;
            padding: 8px;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            box-sizing: border-box;
        }

        .cust-modal-btns {
            display: flex;
            gap: 8px;
        }

        .cust-modal-submit {
            background-color: #2563eb;
            color: #ffffff;
            padding: 8px 16px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
        }

            .cust-modal-submit:hover {
                background-color: #1d4ed8;
            }

        .cust-modal-cancel {
            background-color: #e5e7eb;
            color: #374151;
            padding: 8px 16px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
        }

            .cust-modal-cancel:hover {
                background-color: #d1d5db;
            }

        .cust-dashboard {
            display: flex;
            flex-wrap: wrap;
            gap: 16px;
            margin-bottom: 20px;
        }

        .cust-dashboard-item {
            flex: 1 1 100%;
            background-color: #3b82f6;
            color: white;
            padding: 16px;
            border-radius: 8px;
            text-align: center;
        }

            .cust-dashboard-item h3 {
                font-size: 16px;
                margin-bottom: 8px;
            }

            .cust-dashboard-item p {
                font-size: 24px;
                font-weight: bold;
            }

            .cust-dashboard-item.invoice {
                background-color: #16a34a;
            }

        /* Responsive adjustments */
        @media (min-width: 768px) {
            .cust-header {
                flex-direction: row;
                align-items: center;
            }

            .cust-search-container {
                flex-direction: row;
                width: auto;
            }

            .cust-search-input {
                width: 256px;
            }

            .cust-section {
                flex-direction: row;
            }

            .cust-list-container, .cust-details-container {
                width: 66.66%;
            }

            .cust-details-header {
                flex-direction: row;
                align-items: center;
            }

            .cust-details-btns {
                flex-direction: row;
                width: auto;
            }

            .cust-site-actions {
                flex-direction: row;
            }

            .cust-tag-input-container {
                flex-direction: row;
            }

            .cust-dashboard-item {
                flex: 1 1 45%;
            }
        }

        @media (min-width: 1280px) {
            .cust-list-header {
                display: grid;
            }

            .cust-item {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
            }

            .cust-item-label {
                display: none;
            }

            .cust-dashboard-item {
                flex: 1 1 22%;
            }
        }

        .dataTable tr {
            cursor: pointer;
        }
    </style>

    <div class="cust-page-container">
        <!-- Page Header -->
        <header class="cust-header">
            <h1 class="cust-title">Customers</h1>
            <div class="cust-search-container">
                <input type="text" placeholder="Search customers..." class="cust-search-input" id="customerSearch" />
                <button class="cust-add-btn" id="addCustomerBtn">+ Add Customer</button>
            </div>
        </header>

        <!-- Customer Section -->
        <section class="cust-section">
            <!-- Customer List -->
            <div class="cust-list-container">
                <div class="cust-list-header">
                    <span>Name</span>
                    <span>Email</span>
                    <span>Status</span>
                    <span>Sites</span>
                </div>
                <div class="cust-list" id="customerList">
                    <div class="cust-item cust-item-active" data-id="1">
                        <div class="cust-item-field"><span class="cust-item-label">Name: </span>John Doe</div>
                        <div class="cust-item-field"><span class="cust-item-label">Email: </span>john.doe@email.com</div>
                        <div class="cust-item-field"><span class="cust-item-label">Status: </span><span class="cust-status-badge cust-status-active">Active</span></div>
                        <div class="cust-item-field"><span class="cust-item-label">Sites: </span>2</div>
                    </div>
                    <div class="cust-item" data-id="2">
                        <div class="cust-item-field"><span class="cust-item-label">Name: </span>ABC Property Mgmt</div>
                        <div class="cust-item-field"><span class="cust-item-label">Email: </span>abc@propertymgmt.com</div>
                        <div class="cust-item-field"><span class="cust-item-label">Status: </span><span class="cust-status-badge cust-status-inactive">Inactive</span></div>
                        <div class="cust-item-field"><span class="cust-item-label">Sites: </span>3</div>
                    </div>
                </div>

                <table id="customerTable" class="display" style="width: 100%">
                    <thead>
                        <tr>
                            <th>First Name</th>
                            <th>Last Name</th>
                            <th>Email</th>
                        </tr>
                    </thead>
                </table>
            </div>

            <!-- Customer Details -->
            <div class="cust-details-container">
                <div class="cust-details-header">
                    <h2 class="cust-details-title" id="customerName">John Doe</h2>
                    <div class="cust-details-btns">
                        <button class="cust-edit-btn" id="editCustomerBtn">Edit</button>
                        <button class="cust-message-btn" id="messageCustomerBtn">Message</button>
                    </div>
                </div>
                <div class="cust-details-content">
                    <!-- Dashboard for Appointments and Invoices -->


                    <!-- Contact Info -->
                    <div class="cust-section-block">
                        <button class="cust-section-toggle" data-section="contact" id="contactBtn">Contact Info</button>
                        <div class="cust-section-content" id="contact">
                            <p class="cust-info-text"><span class="cust-info-label">Email:</span> <span class="cust-info-value" id="customerEmail">john.doe@email.com</span></p>
                            <p class="cust-info-text"><span class="cust-info-label">Phone:</span> <span class="cust-info-value" id="customerPhone">(555) 123-4567</span></p>
                        </div>
                    </div>

                    <!-- Sites & Locations -->
                    <div class="cust-section-block">
                        <button class="cust-section-toggle" data-section="sites" id="sitesBtn">Sites & Locations</button>
                        <div class="cust-section-content" id="sites">
                            <div class="cust-site-card" data-site-id="1">
                                <h3 class="cust-site-title">Main Residence</h3>
                                <p class="cust-site-info" id="address-1">Address: 123 Elm St, City, ST 12345</p>
                                <p class="cust-site-info">Contact: Jane Smith (555-987-6543)</p>
                                <div class="cust-site-actions">
                                    <button class="cust-site-edit-btn" data-site-id="1">Edit</button>
                                    <a href="CustomerDetails.aspx?siteId=1" class="cust-site-view-link">View Details</a>
                                </div>
                            </div>
                            <div class="cust-site-card" data-site-id="2">
                                <h3 class="cust-site-title">Vacation Home</h3>
                                <p class="cust-site-info" id="address-2">Address: 456 Oak Rd, City, ST 12345</p>
                                <p class="cust-site-info">Contact: Bob Johnson (555-456-7890)</p>
                                <div class="cust-site-actions">
                                    <button class="cust-site-edit-btn" data-site-id="2">Edit</button>
                                    <a href="CustomerDetails.aspx?siteId=2" class="cust-site-view-link">View Details</a>
                                </div>
                            </div>
                            <button class="cust-site-add-btn" id="addSiteBtn">+ Add Site</button>
                        </div>
                    </div>

                    <!-- Status Tags -->
                    <div class="cust-section-block">
                        <button class="cust-section-toggle" data-section="status" id="statusBtn">Status Tags</button>
                        <div class="cust-section-content" id="status">
                            <div class="cust-status-tags" id="statusTags">
                                <span class="cust-status-tag" data-tag="active">Active
                                    <button class="cust-tag-delete">×</button></span>
                                <span class="cust-status-tag" data-tag="pending">Pending
                                    <button class="cust-tag-delete">×</button></span>
                            </div>
                            <div class="cust-tag-input-container">
                                <input type="text" placeholder="Add new tag..." class="cust-tag-input" id="newTagInput" />
                                <button class="cust-tag-add-btn" id="addTagBtn">Add Tag</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </div>

    <!-- Add Customer Modal -->
    <div class="cust-modal" id="addCustomerModal">
        <div class="cust-modal-content">
            <h2 class="cust-modal-title">Add New Customer</h2>
            <form id="addCustomerForm" class="cust-modal-form">
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Name</label>
                    <input type="text" name="name" class="cust-modal-input" required />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Email</label>
                    <input type="email" name="email" class="cust-modal-input" required />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Phone</label>
                    <input type="text" name="phone" class="cust-modal-input" />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Status</label>
                    <select name="status" class="cust-modal-input">
                        <option value="Active">Active</option>
                        <option value="Inactive">Inactive</option>
                    </select>
                </div>
                <div class="cust-modal-btns">
                    <button type="submit" class="cust-modal-submit">Add Customer</button>
                    <button type="button" class="cust-modal-cancel" id="closeAddCustomer">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Edit Customer Modal -->
    <div class="cust-modal" id="editCustomerModal">
        <div class="cust-modal-content">
            <h2 class="cust-modal-title">Edit Customer</h2>
            <form id="editCustomerForm" class="cust-modal-form">
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Name</label>
                    <input type="text" name="name" id="editName" class="cust-modal-input" required />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Email</label>
                    <input type="email" name="email" id="editEmail" class="cust-modal-input" required />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Phone</label>
                    <input type="text" name="phone" id="editPhone" class="cust-modal-input" />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Status</label>
                    <select name="status" id="editStatus" class="cust-modal-input">
                        <option value="Active">Active</option>
                        <option value="Inactive">Inactive</option>
                    </select>
                </div>
                <div class="cust-modal-btns">
                    <button type="submit" class="cust-modal-submit">Save Changes</button>
                    <button type="button" class="cust-modal-cancel" id="closeEditCustomer">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Add Site Modal -->
    <div class="cust-modal" id="addSiteModal">
        <div class="cust-modal-content">
            <h2 class="cust-modal-title">Add New Site</h2>
            <form id="addSiteForm" class="cust-modal-form">
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Site Name</label>
                    <input type="text" name="siteName" class="cust-modal-input" required />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Address</label>
                    <input type="text" name="address" class="cust-modal-input" required />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Site Contact</label>
                    <input type="text" name="contact" class="cust-modal-input" />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Equipment</label>
                    <input type="text" name="equipment" class="cust-modal-input" />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Warranty</label>
                    <input type="text" name="warranty" class="cust-modal-input" />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Service History</label>
                    <input type="text" name="serviceHistory" class="cust-modal-input" />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Photos</label>
                    <input type="file" name="pictures" class="cust-modal-input" multiple accept="image/*" />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Service Agreement</label>
                    <input type="text" name="serviceAgreement" class="cust-modal-input" />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Alarms</label>
                    <input type="text" name="alarms" class="cust-modal-input" />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Special Instructions</label>
                    <input type="text" name="specialInstructions" class="cust-modal-input" />
                </div>
                <div class="cust-modal-btns">
                    <button type="submit" class="cust-modal-submit">Add Site</button>
                    <button type="button" class="cust-modal-cancel" id="closeAddSite">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Edit Site Modal -->
    <div class="cust-modal" id="editSiteModal">
        <div class="cust-modal-content">
            <h2 class="cust-modal-title">Edit Site</h2>
            <form id="editSiteForm" class="cust-modal-form">
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Site Name</label>
                    <input type="text" name="siteName" id="editSiteName" class="cust-modal-input" required />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Address</label>
                    <input type="text" name="address" id="editSiteAddress" class="cust-modal-input" required />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Site Contact</label>
                    <input type="text" name="contact" id="editSiteContact" class="cust-modal-input" />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Equipment</label>
                    <input type="text" name="equipment" id="editSiteEquipment" class="cust-modal-input" />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Warranty</label>
                    <input type="text" name="warranty" id="editSiteWarranty" class="cust-modal-input" />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Service History</label>
                    <input type="text" name="serviceHistory" id="editSiteServiceHistory" class="cust-modal-input" />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Photos</label>
                    <input type="file" name="pictures" id="editSitePictures" class="cust-modal-input" multiple accept="image/*" />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Service Agreement</label>
                    <input type="text" name="serviceAgreement" id="editSiteServiceAgreement" class="cust-modal-input" />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Alarms</label>
                    <input type="text" name="alarms" id="editSiteAlarms" class="cust-modal-input" />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Special Instructions</label>
                    <input type="text" name="specialInstructions" id="editSiteSpecialInstructions" class="cust-modal-input" />
                </div>
                <div class="cust-modal-btns">
                    <button type="submit" class="cust-modal-submit">Save Changes</button>
                    <button type="button" class="cust-modal-cancel" id="closeEditSite">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            // Mock data for customers and sites
            const customerData = {
                1: {
                    name: 'John Doe',
                    email: 'john.doe@email.com',
                    phone: '(555) 123-4567',
                    status: 'Active',
                    appointments: { pending: 1, scheduled: 1, completed: 6, custom: 3 },
                    invoices: { estimates: 1, open: 1, unpaid: 6, paid: 3 },
                    sites: [
                        {
                            id: 1,
                            name: 'Main Residence',
                            address: '123 Elm St, City, ST 12345',
                            contact: 'Jane Smith (555-987-6543)',
                            equipment: 'HVAC Unit',
                            warranty: 'Active until 2026',
                            serviceHistory: 'Last visit on 03/10/2025',
                            pictures: ['mock-image1.jpg', 'mock-image2.jpg'],
                            serviceAgreement: 'Annual Maintenance (Signed)',
                            alarms: 'Next service due 03/10/2026',
                            specialInstructions: 'Check filter replacement'
                        },
                        {
                            id: 2,
                            name: 'Vacation Home',
                            address: '456 Oak Rd, City, ST 12345',
                            contact: 'Bob Johnson (555-456-7890)',
                            equipment: 'Generator',
                            warranty: 'Active until 2027',
                            serviceHistory: 'Last visit on 01/15/2025',
                            pictures: ['mock-image3.jpg'],
                            serviceAgreement: 'None',
                            alarms: 'None',
                            specialInstructions: 'Ensure generator fuel level'
                        }
                    ]
                },
                2: {
                    name: 'ABC Property Mgmt',
                    email: 'abc@propertymgmt.com',
                    phone: '(555) 987-6543',
                    status: 'Inactive',
                    appointments: { pending: 0, scheduled: 2, completed: 3, custom: 1 },
                    invoices: { estimates: 2, open: 0, unpaid: 4, paid: 5 },
                    sites: [
                        {
                            id: 3,
                            name: 'Office Building',
                            address: '789 Pine St, City, ST 12345',
                            contact: 'Sarah Lee (555-321-6547)',
                            equipment: 'Elevator',
                            warranty: 'Active until 2025',
                            serviceHistory: 'Last visit on 02/20/2025',
                            pictures: [],
                            serviceAgreement: 'Monthly Maintenance (Signed)',
                            alarms: 'Next service due 03/20/2025',
                            specialInstructions: 'Check safety systems'
                        }
                    ]
                }
            };

            // Modal Handlers
            function openModal(modalId) {
                const modal = document.getElementById(modalId);
                if (modal) {
                    modal.style.display = 'flex';
                }
            }

            function closeModal(modalId) {
                const modal = document.getElementById(modalId);
                if (modal) {
                    modal.style.display = 'none';
                }
            }

            // Add Customer
            const addCustomerBtn = document.getElementById('addCustomerBtn');
            if (addCustomerBtn) {
                addCustomerBtn.addEventListener('click', () => openModal('addCustomerModal'));
            }

            const closeAddCustomerBtn = document.getElementById('closeAddCustomer');
            if (closeAddCustomerBtn) {
                closeAddCustomerBtn.addEventListener('click', () => closeModal('addCustomerModal'));
            }

            const addCustomerForm = document.getElementById('addCustomerForm');
            if (addCustomerForm) {
                addCustomerForm.addEventListener('submit', (e) => {
                    e.preventDefault();
                    const formData = new FormData(e.target);
                    const customer = {
                        name: formData.get('name'),
                        email: formData.get('email'),
                        phone: formData.get('phone'),
                        status: formData.get('status'),
                        appointments: { pending: 0, scheduled: 0, completed: 0, custom: 0 },
                        invoices: { estimates: 0, open: 0, unpaid: 0, paid: 0 },
                        sites: []
                    };
                    const id = Date.now();
                    customerData[id] = customer;
                    addCustomerToList(customer, id);
                    closeModal('addCustomerModal');
                    e.target.reset();
                });
            }

            function addCustomerToList(customer, id) {
                const list = document.getElementById('customerList');
                if (list) {
                    const item = document.createElement('div');
                    item.className = 'cust-item';
                    item.dataset.id = id;
                    item.innerHTML = `
                        <div class="cust-item-field"><span class="cust-item-label">Name: </span>${customer.name}</div>
                        <div class="cust-item-field"><span class="cust-item-label">Email: </span>${customer.email}</div>
                        <div class="cust-item-field"><span class="cust-item-label">Status: </span><span class="cust-status-badge cust-status-${customer.status.toLowerCase()}">${customer.status}</span></div>
                        <div class="cust-item-field"><span class="cust-item-label">Sites: </span>${customer.sites.length}</div>
                    `;
                    list.appendChild(item);
                    item.addEventListener('click', () => selectCustomer(item, id));
                }
            }

            // Edit Customer
            const editCustomerBtn = document.getElementById('editCustomerBtn');
            if (editCustomerBtn) {
                editCustomerBtn.addEventListener('click', () => {
                    const name = document.getElementById('customerName').textContent;
                    const email = document.getElementById('customerEmail').textContent;
                    const phone = document.getElementById('customerPhone').textContent;
                    const activeItem = document.querySelector('.cust-item-active');
                    const id = activeItem.dataset.id;
                    const status = customerData[id].status;
                    document.getElementById('editName').value = name;
                    document.getElementById('editEmail').value = email;
                    document.getElementById('editPhone').value = phone;
                    document.getElementById('editStatus').value = status;
                    openModal('editCustomerModal');
                });
            }

            const closeEditCustomerBtn = document.getElementById('closeEditCustomer');
            if (closeEditCustomerBtn) {
                closeEditCustomerBtn.addEventListener('click', () => closeModal('editCustomerModal'));
            }

            const editCustomerForm = document.getElementById('editCustomerForm');
            if (editCustomerForm) {
                editCustomerForm.addEventListener('submit', (e) => {
                    e.preventDefault();
                    const formData = new FormData(e.target);
                    const activeItem = document.querySelector('.cust-item-active');
                    const id = activeItem.dataset.id;
                    customerData[id].name = formData.get('name');
                    customerData[id].email = formData.get('email');
                    customerData[id].phone = formData.get('phone');
                    customerData[id].status = formData.get('status');
                    document.getElementById('customerName').textContent = customerData[id].name;
                    document.getElementById('customerEmail').textContent = customerData[id].email;
                    document.getElementById('customerPhone').textContent = customerData[id].phone;
                    if (activeItem) {
                        activeItem.children[0].innerHTML = `<span class="cust-item-label">Name: </span>${customerData[id].name}`;
                        activeItem.children[1].innerHTML = `<span class="cust-item-label">Email: </span>${customerData[id].email}`;
                        activeItem.children[2].innerHTML = `<span class="cust-item-label">Status: </span><span class="cust-status-badge cust-status-${customerData[id].status.toLowerCase()}">${customerData[id].status}</span>`;
                    }
                    closeModal('editCustomerModal');
                });
            }

            // Add Site
            const addSiteBtn = document.getElementById('addSiteBtn');
            if (addSiteBtn) {
                addSiteBtn.addEventListener('click', () => openModal('addSiteModal'));
            }

            const closeAddSiteBtn = document.getElementById('closeAddSite');
            if (closeAddSiteBtn) {
                closeAddSiteBtn.addEventListener('click', () => closeModal('addSiteModal'));
            }

            const addSiteForm = document.getElementById('addSiteForm');
            if (addSiteForm) {
                addSiteForm.addEventListener('submit', (e) => {
                    e.preventDefault();
                    const formData = new FormData(e.target);
                    const site = {
                        id: Date.now(),
                        name: formData.get('siteName'),
                        address: formData.get('address'),
                        contact: formData.get('contact') || 'N/A',
                        equipment: formData.get('equipment') || 'None',
                        warranty: formData.get('warranty') || 'N/A',
                        serviceHistory: formData.get('serviceHistory') || 'None',
                        pictures: Array.from(formData.getAll('pictures')).map(file => URL.createObjectURL(file)),
                        serviceAgreement: formData.get('serviceAgreement') || 'None',
                        alarms: formData.get('alarms') || 'None',
                        specialInstructions: formData.get('specialInstructions') || 'None'
                    };
                    const activeItem = document.querySelector('.cust-item-active');
                    const customerId = activeItem.dataset.id;
                    customerData[customerId].sites.push(site);
                    addSiteToList(site);
                    closeModal('addSiteModal');
                    e.target.reset();
                });
            }

            function addSiteToList(site) {
                const list = document.getElementById('sites');
                if (list) {
                    const card = document.createElement('div');
                    card.className = 'cust-site-card';
                    card.dataset.siteId = site.id;
                    card.innerHTML = `
                        <h3 class="cust-site-title">${site.name}</h3>
                        <p class="cust-site-info">Address: ${site.address}</p>
                        <p class="cust-site-info">Contact: ${site.contact}</p>
                        <p class="cust-site-info">Equipment: ${site.equipment}</p>
                        <p class="cust-site-info">Warranty: ${site.warranty}</p>
                        <p class="cust-site-info">Service History: ${site.serviceHistory}</p>
                        <p class="cust-site-info">Photos: ${site.pictures.length} uploaded</p>
                        <p class="cust-site-info">Service Agreement: ${site.serviceAgreement}</p>
                        <p class="cust-site-info">Alarms: ${site.alarms}</p>
                        <p class="cust-site-info">Special Instructions: ${site.specialInstructions}</p>
                        <div class="cust-site-actions">
                            <button class="cust-site-edit-btn" data-site-id="${site.id}">Edit</button>
                            <a href="CustomerDetails.aspx?siteId=${site.id}" class="cust-site-view-link">View Details</a>
                        </div>
                    `;
                    list.insertBefore(card, document.getElementById('addSiteBtn'));
                    card.querySelector('.cust-site-edit-btn').addEventListener('click', () => editSite(site.id, site));
                    updateSiteCount();
                }
            }

            // Edit Site
            function editSite(siteId, siteData) {
                document.getElementById('editSiteName').value = siteData.name;
                document.getElementById('editSiteAddress').value = siteData.address;
                document.getElementById('editSiteContact').value = siteData.contact;
                document.getElementById('editSiteEquipment').value = siteData.equipment;
                document.getElementById('editSiteWarranty').value = siteData.warranty;
                document.getElementById('editSiteServiceHistory').value = siteData.serviceHistory;
                document.getElementById('editSiteServiceAgreement').value = siteData.serviceAgreement;
                document.getElementById('editSiteAlarms').value = siteData.alarms;
                document.getElementById('editSiteSpecialInstructions').value = siteData.specialInstructions;
                openModal('editSiteModal');
                const editSiteForm = document.getElementById('editSiteForm');
                if (editSiteForm) {
                    editSiteForm.onsubmit = (e) => {
                        e.preventDefault();
                        const formData = new FormData(e.target);
                        const activeItem = document.querySelector('.cust-item-active');
                        const customerId = activeItem.dataset.id;
                        const siteIndex = customerData[customerId].sites.findIndex(s => s.id == siteId);
                        customerData[customerId].sites[siteIndex] = {
                            id: siteId,
                            name: formData.get('siteName'),
                            address: formData.get('address'),
                            contact: formData.get('contact') || 'N/A',
                            equipment: formData.get('equipment') || 'None',
                            warranty: formData.get('warranty') || 'N/A',
                            serviceHistory: formData.get('serviceHistory') || 'None',
                            pictures: formData.getAll('pictures').length
                                ? Array.from(formData.getAll('pictures')).map(file => URL.createObjectURL(file))
                                : customerData[customerId].sites[siteIndex].pictures,
                            serviceAgreement: formData.get('serviceAgreement') || 'None',
                            alarms: formData.get('alarms') || 'None',
                            specialInstructions: formData.get('specialInstructions') || 'None'
                        };
                        const card = document.querySelector(`.cust-site-card[data-site-id="${siteId}"]`);
                        if (card) {
                            card.children[0].textContent = customerData[customerId].sites[siteIndex].name;
                            card.children[1].textContent = `Address: ${customerData[customerId].sites[siteIndex].address}`;
                            card.children[2].textContent = `Contact: ${customerData[customerId].sites[siteIndex].contact}`;
                            card.children[3].textContent = `Equipment: ${customerData[customerId].sites[siteIndex].equipment}`;
                            card.children[4].textContent = `Warranty: ${customerData[customerId].sites[siteIndex].warranty}`;
                            card.children[5].textContent = `Service History: ${customerData[customerId].sites[siteIndex].serviceHistory}`;
                            card.children[6].textContent = `Photos: ${customerData[customerId].sites[siteIndex].pictures.length} uploaded`;
                            card.children[7].textContent = `Service Agreement: ${customerData[customerId].sites[siteIndex].serviceAgreement}`;
                            card.children[8].textContent = `Alarms: ${customerData[customerId].sites[siteIndex].alarms}`;
                            card.children[9].textContent = `Special Instructions: ${customerData[customerId].sites[siteIndex].specialInstructions}`;
                            closeModal('editSiteModal');
                            updateSiteCount();
                        }
                    };
                }
            }

            const closeEditSiteBtn = document.getElementById('closeEditSite');
            if (closeEditSiteBtn) {
                closeEditSiteBtn.addEventListener('click', () => closeModal('editSiteModal'));
            }

            // Search Customers
            const customerSearch = document.getElementById('customerSearch');
            if (customerSearch) {
                customerSearch.addEventListener('input', (e) => {
                    const query = e.target.value.toLowerCase();
                    const items = document.querySelectorAll('.cust-item');
                    items.forEach(item => {
                        const name = item.children[0].textContent.replace('Name: ', '').toLowerCase();
                        const email = item.children[1].textContent.replace('Email: ', '').toLowerCase();
                        item.style.display = name.includes(query) || email.includes(query) ? '' : 'none';
                    });
                });
            }

            // Select Customer
            const customerItems = document.querySelectorAll('.cust-item');
            if (customerItems) {
                customerItems.forEach(item => {
                    item.addEventListener('click', () => selectCustomer(item, item.dataset.id));
                });
            }

            function selectCustomer(item, id) {
                customerItems.forEach(i => i.classList.remove('cust-item-active'));
                item.classList.add('cust-item-active');
                const customer = customerData[id];
                document.getElementById('customerName').textContent = customer.name;
                document.getElementById('customerEmail').textContent = customer.email;
                document.getElementById('customerPhone').textContent = customer.phone || 'N/A';

                // Update dashboard counts
                document.getElementById('pendingAppointments').textContent = customer.appointments.pending;
                document.getElementById('scheduledAppointments').textContent = customer.appointments.scheduled;
                document.getElementById('completedAppointments').textContent = customer.appointments.completed;
                document.getElementById('customTabs').textContent = customer.appointments.custom;
                document.getElementById('estimates').textContent = customer.invoices.estimates;
                document.getElementById('openInvoices').textContent = customer.invoices.open;
                document.getElementById('unpaidInvoices').textContent = customer.invoices.unpaid;
                document.getElementById('paidInvoices').textContent = customer.invoices.paid;

                // Update sites
                const sitesContainer = document.getElementById('sites');
                sitesContainer.innerHTML = '';
                customer.sites.forEach(site => addSiteToList(site));
                const addSiteBtn = document.createElement('button');
                addSiteBtn.className = 'cust-site-add-btn';
                addSiteBtn.id = 'addSiteBtn';
                addSiteBtn.textContent = '+ Add Site';
                addSiteBtn.addEventListener('click', () => openModal('addSiteModal'));
                sitesContainer.appendChild(addSiteBtn);
            }

            // Accordion Functionality
            const accordionButtons = document.querySelectorAll('.cust-section-toggle');
            if (accordionButtons) {
                accordionButtons.forEach(btn => {
                    btn.addEventListener('click', () => {
                        const sectionId = btn.dataset.section;
                        const content = document.getElementById(sectionId);
                        const isActive = content.style.display === 'block';
                        accordionButtons.forEach(b => {
                            const sectionContent = document.getElementById(b.dataset.section);
                            if (sectionContent) {
                                sectionContent.style.display = 'none';
                            }
                        });
                        if (!isActive) {
                            content.style.display = 'block';
                        }
                    });
                });
            }

            // Message Customer
            const messageCustomerBtn = document.getElementById('messageCustomerBtn');
            if (messageCustomerBtn) {
                messageCustomerBtn.addEventListener('click', () => {
                    const email = document.getElementById('customerEmail').textContent;
                    alert(`Sending message to ${email}...`);
                });
            }

            // Custom Status Tags
            const statusTags = document.getElementById('statusTags');
            if (statusTags) {
                const savedTags = JSON.parse(localStorage.getItem('statusTags')) || [
                    { name: 'Active', color: '#e5e7eb' },
                    { name: 'Pending', color: '#e5e7eb' }
                ];

                function saveTags() {
                    const tags = Array.from(document.querySelectorAll('.cust-status-tag')).map(tag => ({
                        name: tag.dataset.tag,
                        color: tag.style.backgroundColor || '#e5e7eb'
                    }));
                    localStorage.setItem('statusTags', JSON.stringify(tags));
                }

                const colorPickerModal = document.createElement('div');
                colorPickerModal.id = 'colorPickerModal';
                colorPickerModal.style.cssText = 'display: none; position: absolute; background-color: #ffffff; border: 1px solid #d1d5db; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); border-radius: 8px; padding: 8px; z-index: 50;';
                colorPickerModal.innerHTML = `
                    <input type="color" id="colorPickerInput" style="width: 100%; height: 40px;">
                    <button id="closeColorPicker" style="margin-top: 8px; width: 100%; background-color: #e5e7eb; color: #374151; padding: 4px 8px; border-radius: 4px; border: none; cursor: pointer;">Close</button>
                `;
                document.body.appendChild(colorPickerModal);

                const colorPickerInput = document.getElementById('colorPickerInput');
                const closeColorPickerBtn = document.getElementById('closeColorPicker');

                function createTag(tagName, color = '#e5e7eb') {
                    const tag = document.createElement('span');
                    tag.className = 'cust-status-tag';
                    tag.dataset.tag = tagName.toLowerCase();
                    tag.style.backgroundColor = color;
                    tag.style.color = getContrastColor(color);
                    tag.innerHTML = `${tagName}<button class="cust-tag-delete">×</button>`;

                    tag.addEventListener('click', (e) => {
                        if (e.target.classList.contains('cust-tag-delete')) return;
                        tag.classList.toggle('active');
                        const isActive = tag.classList.contains('active');
                        tag.style.backgroundColor = isActive ? darkenColor(color) : color;
                        tag.style.color = getContrastColor(tag.style.backgroundColor);

                        if (!isActive) {
                            showColorPicker(tag, color);
                        } else {
                            colorPickerModal.style.display = 'none';
                        }
                    });

                    const deleteBtn = tag.querySelector('.cust-tag-delete');
                    deleteBtn.addEventListener('click', () => {
                        tag.remove();
                        saveTags();
                    });

                    return tag;
                }

                function showColorPicker(tag, currentColor) {
                    colorPickerInput.value = rgbToHex(currentColor);
                    colorPickerModal.style.display = 'block';

                    const rect = tag.getBoundingClientRect();
                    const scrollTop = window.scrollY || document.documentElement.scrollTop;
                    const scrollLeft = window.scrollX || document.documentElement.scrollLeft;

                    colorPickerModal.style.top = `${rect.bottom + scrollTop + 5}px`;
                    colorPickerModal.style.left = `${rect.left + scrollLeft}px`;

                    const modalRect = colorPickerModal.getBoundingClientRect();
                    if (modalRect.right > window.innerWidth) {
                        colorPickerModal.style.left = `${window.innerWidth - modalRect.width + scrollLeft}px`;
                    }
                    if (modalRect.bottom > window.innerHeight) {
                        colorPickerModal.style.top = `${rect.top + scrollTop - modalRect.height - 5}px`;
                    }

                    colorPickerInput.oninput = () => {
                        const newColor = colorPickerInput.value;
                        tag.style.backgroundColor = newColor;
                        tag.style.color = getContrastColor(newColor);
                        saveTags();
                    };
                }

                closeColorPickerBtn.addEventListener('click', () => {
                    colorPickerModal.style.display = 'none';
                });

                document.addEventListener('click', (e) => {
                    if (!colorPickerModal.contains(e.target) && !e.target.closest('.cust-status-tag')) {
                        colorPickerModal.style.display = 'none';
                    }
                });

                function getContrastColor(hexColor) {
                    const rgb = hexToRgb(hexColor);
                    const luminance = (0.299 * rgb.r + 0.587 * rgb.g + 0.114 * rgb.b) / 255;
                    return luminance > 0.5 ? '#000000' : '#ffffff';
                }

                function hexToRgb(hex) {
                    const bigint = parseInt(hex.replace('#', ''), 16);
                    return {
                        r: (bigint >> 16) & 255,
                        g: (bigint >> 8) & 255,
                        b: bigint & 255
                    };
                }

                function rgbToHex(rgb) {
                    if (rgb.startsWith('#')) return rgb;
                    const [r, g, b] = rgb.match(/\d+/g).map(Number);
                    return `#${((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1)}`;
                }

                function darkenColor(hex) {
                    const rgb = hexToRgb(hex);
                    const factor = 0.8;
                    return `rgb(${Math.round(rgb.r * factor)}, ${Math.round(rgb.g * factor)}, ${Math.round(rgb.b * factor)})`;
                }

                savedTags.forEach(tag => statusTags.appendChild(createTag(tag.name, tag.color)));

                const addTagBtn = document.getElementById('addTagBtn');
                if (addTagBtn) {
                    addTagBtn.addEventListener('click', () => {
                        const input = document.getElementById('newTagInput');
                        const tagName = input.value.trim();
                        if (tagName && !Array.from(statusTags.children).some(tag => tag.dataset.tag === tagName.toLowerCase())) {
                            const tag = createTag(tagName);
                            statusTags.appendChild(tag);
                            saveTags();
                            input.value = '';
                        }
                    });
                }
            }

            // Helper: Update Site Count
            function updateSiteCount() {
                const activeItem = document.querySelector('.cust-item-active');
                const customerId = activeItem.dataset.id;
                const siteCount = customerData[customerId].sites.length;
                if (activeItem) {
                    activeItem.children[3].innerHTML = `<span class="cust-item-label">Sites: </span>${siteCount}`;
                }
            }

            // Initial Event Listeners for Existing Sites
            document.querySelectorAll('.cust-site-edit-btn').forEach(btn => {
                btn.addEventListener('click', () => {
                    const siteId = btn.dataset.siteId;
                    const activeItem = document.querySelector('.cust-item-active');
                    const customerId = activeItem.dataset.id;
                    const site = customerData[customerId].sites.find(s => s.id == siteId);
                    if (site) {
                        editSite(siteId, site);
                    }
                });
            });

            // Open the dashboard section by default
            // document.getElementById('dashboard').style.display = 'block';
        });

        loadCustomers();

        function loadCustomers() {
            var table = $('#customerTable').DataTable({
                "processing": true,
                "serverSide": true,
                "filter": true,
                "ajax": {
                    "url": "Customer.aspx/LoadCustomers",
                    "type": "POST",
                    "contentType": "application/json; charset=utf-8",
                    "dataType": "json",
                    "data": function (d) {
                        return JSON.stringify({
                            draw: d.draw,
                            start: d.start,
                            length: d.length,
                            searchValue: d.search.value,
                            sortColumn: d.columns[d.order[0].column].data,
                            sortDirection: d.order[0].dir
                        });
                    },
                    "dataSrc": function (json) {
                        console.log(json);
                        if (json.error) {
                            alert(json.error);
                            return [];
                        }
                        return json.data;
                    }
                },
                "paging": true,
                "pageLength": 10,
                "columns": [
                    { "data": "FirstName", "name": "First Name", "autoWidth": true},
                    { "data": "LastName", "name": "Last Name", "autoWidth": true },
                    { "data": "Email", "name": "Email", "autoWidth": true },
                ],
                "select": {
                    "style": "single" // Enables single row selection
                },

                "drawCallback": function (settings) {
                    var api = this.api();
                    if (api.rows().count() > 0) {
                        api.row(0).select();
                        var firstRowData = api.row(0).data();
                        generateCustomerDetails(firstRowData);
                    }
                }
            });
        }



        $('#customerTable tbody').on('click', 'tr', function () {
            var data = $('#customerTable').DataTable().row(this).data();  // Get data for the clicked row
            if (data) {
                generateCustomerDetails(data);
            }
        });

        function generateCustomerDetails(data) {
            if (data) {
                document.getElementById('customerName').textContent = data.FirstName +" "+ data.LastName;
                document.getElementById('customerEmail').textContent = data.Email;
                document.getElementById('customerPhone').textContent = data.Phone;
                document.getElementById('address-1').textContent = data.Address1;
                document.getElementById('address-2').textContent = data.Address2;
                $(".cust-site-view-link").attr("href", "CustomerDetails.aspx?custId=" + data.CustomerID + "&custGuid=" + data.CustomerGuid);
            }

        }

    </script>
</asp:Content>
