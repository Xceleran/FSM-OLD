<%@ Page Title="Customers" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="Customer.aspx.cs" Inherits="FSM.Customer" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <link rel="stylesheet" href="https://cdn.datatables.net/2.2.2/css/dataTables.dataTables.min.css">
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/select/3.0.0/css/select.dataTables.min.css">

    <!-- Local Styles and Scripts -->
    <link rel="stylesheet" href="Content/customer.css">

    <style>
   
    </style>

    <div class="cust-page-container">
        <!-- Page Header -->
        <header class="cust-header mt-3">
            <h1 class="cust-title">Customers</h1>
        </header>

        <!-- Customer Section -->
        <section class="cust-section">
            <!-- Customer List -->
            <div class="cust-list-container">
                <table id="customerTable" class="display" style="width: 100%">
                    <thead>
                        <tr>
                            <th>First Name</th>
                            <th>Last Name</th>
                            <th>Email</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                </table>
            </div>

            <!-- Customer Details -->
            <div class="cust-details-container">
                <div class="cust-details-header">
                    <h2 class="cust-details-title" id="customerName">Select a Customer</h2>
                    <button class="btn btn-primary" id="editCustomerBtn">Edit Customer</button>
                </div>
                <div class="cust-details-content">
                    <!-- Contact Info -->
                    <div class="cust-section-block">
                        <button class="cust-section-toggle" data-section="contact" id="contactBtn">Contact Info</button>
                        <div class="cust-section-content" id="contact">
                            <p class="cust-info-text"><span class="cust-info-label">Email:</span> <span class="cust-info-value" id="customerEmail">-</span></p>
                            <p class="cust-info-text"><span class="cust-info-label">Phone:</span> <span class="cust-info-value" id="customerPhone">-</span></p>
                            <p class="cust-info-text"><span class="cust-info-label">Address:</span> <span class="cust-info-value" id="customerAddress">-</span></p>
                            <p class="cust-info-text"><span class="cust-info-label">Job Title:</span> <span class="cust-info-value" id="customerJobTitle">-</span></p>
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
                            <div class="d-flex justify-content-end mb-3">
                                <button class="btn btn-primary" id="addSiteBtn">+ Add Site</button>
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
            <button class="cust-modal-close" id="closeAddCustomerIcon">×</button>
            <h2 class="cust-modal-title">Add New Customer</h2>
            <form id="addCustomerForm" class="cust-modal-form">
                <div class="cust-modal-field">
                    <label class="cust-modal-label">First Name</label>
                    <input type="text" name="firstName" class="cust-modal-input" required />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Last Name</label>
                    <input type="text" name="lastName" class="cust-modal-input" required />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Email</label>
                    <input type="email" name="email" class="cust-modal-input" required />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Phone</label>
                    <input type="text" name="phone" class="cust-modal-input" />
                </div>
                <div class="cust-modal-btns">
                    <button type="button" class="cust-modal-cancel" id="closeAddCustomer">Cancel</button>
                    <button type="submit" class="cust-modal-submit">Add Customer</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Edit Customer Modal -->
    <div class="cust-modal" id="editCustomerModal">
        <div class="cust-modal-content">
            <button class="cust-modal-close" id="closeEditCustomerIcon">×</button>
            <h2 class="cust-modal-title">Edit Customer</h2>
            <form id="editCustomerForm" class="cust-modal-form">
                <div class="cust-modal-field">
                    <label class="cust-modal-label">First Name</label>
                    <input type="text" name="firstName" id="editFirstName" class="cust-modal-input" required />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Last Name</label>
                    <input type="text" name="lastName" id="editLastName" class="cust-modal-input" required />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Email</label>
                    <input type="email" name="email" id="editEmail" class="cust-modal-input" required />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Phone</label>
                    <input type="text" name="phone" id="editPhone" class="cust-modal-input" />
                </div>
                <div class="cust-modal-btns">
                    <button type="button" class="cust-modal-cancel" id="closeEditCustomer">Cancel</button>
                    <button type="submit" class="cust-modal-submit">Save Changes</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Add Site Modal -->
    <div class="cust-modal" id="addSiteModal">
        <div class="cust-modal-content">
            <button class="cust-modal-close" id="closeAddSiteIcon">×</button>
            <h2 class="cust-modal-title">Add New Site</h2>
            <input type="number" id="SiteId" value="0" hidden="hidden" />
            <input type="text" id="CustomerID" hidden="hidden" />
            <input type="text" id="CustomerGuid" hidden="hidden" />
            <form id="addSiteForm" class="cust-modal-form">
                <div class="cust-modal-field">
                    <label for="siteName" class="cust-modal-label">Site Name</label>
                    <input type="text" id="siteName" name="siteName" class="cust-modal-input" required />
                </div>
                <div class="cust-modal-field">
                    <label for="address" class="cust-modal-label">Address</label>
                    <input type="text" id="address" name="address" class="cust-modal-input" required />
                </div>
                <div class="cust-modal-field">
                    <label for="siteContact" class="cust-modal-label">Site Contact</label>
                    <input type="text" id="siteContact" name="contact" class="cust-modal-input" />
                </div>
                <div class="cust-modal-field">
                    <label for="note" class="cust-modal-label">Note</label>
                    <input id="note" type="text" name="note" class="cust-modal-input" />
                </div>
                <div class="cust-modal-field cust-toggle-switch">
                    <label for="isActive">Active</label>
                    <input type="checkbox" id="isActive" name="isActive" checked />
                </div>
                <div class="cust-modal-btns">
                    <button type="button" class="cust-modal-cancel" id="closeAddSite">Cancel</button>
                    <button type="button" onclick="saveSite(event)" class="cust-modal-submit">Add Site</button>
                </div>
            </form>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.datatables.net/2.2.2/js/dataTables.min.js"></script>
    <script type="text/javascript" src="https://cdn.datatables.net/select/3.0.0/js/dataTables.select.min.js"></script>
    <script src="Scripts/customer.js"></script>
    <script>
        // JavaScript to handle close icon functionality
        $(document).ready(function () {
            $('#closeAddCustomerIcon').on('click', function () {
                $('#addCustomerModal').hide();
            });
            $('#closeEditCustomerIcon').on('click', function () {
                $('#editCustomerModal').hide();
            });
            $('#closeAddSiteIcon').on('click', function () {
                $('#addSiteModal').hide();
            });
        });

    </script>
    <script>
        $('#customerTable tbody').on('click', '.cust-table-edit-btn', function () {
            const customerId = $(this).data('customer-id');
            const customerData = table.row($(this).closest('tr')).data();
            if (customerData) {
                document.getElementById('editFirstName').value = customerData.FirstName || '';
                document.getElementById('editLastName').value = customerData.LastName || '';
                document.getElementById('editEmail').value = customerData.Email || '';
                document.getElementById('editPhone').value = customerData.Phone || '';
                document.getElementById('editCustomerForm').dataset.customerId = customerData.CustomerID;
                document.getElementById('editCustomerForm').dataset.customerGuid = customerData.CustomerGuid;
                openModal('editCustomerModal');
            }
        });
    </script>
</asp:Content>
