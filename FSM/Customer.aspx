<%@ Page Title="Customers" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="Customer.aspx.cs" Inherits="FSM.Customer" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <link rel="stylesheet" href="https://cdn.datatables.net/2.2.2/css/dataTables.dataTables.min.css">
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/select/3.0.0/css/select.dataTables.min.css">

    <!-- Local Styles and Scripts -->
    <link rel="stylesheet" href="Content/customer.css">


    <div class="cust-page-container">
        <!-- Page Header -->
        <header class="cust-header mt-3">
            <h1 class="cust-title">Customers</h1>
            <%-- <div class="cust-search-container">
                <input type="text" placeholder="Search customers..." class="cust-search-input" id="customerSearch" />
                <button class="cust-add-btn" id="addCustomerBtn">+ Add Customer</button>
            </div>--%>
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
                        </tr>
                    </thead>
                </table>
            </div>

            <!-- Customer Details -->
            <div class="cust-details-container">
                <div class="cust-details-header">
                    <h2 class="cust-details-title" id="customerName">Select a Customer</h2>
                    <%--<div class="cust-details-btns">
                        <button class="cust-edit-btn" id="editCustomerBtn" disabled>Edit</button>
                        <button class="cust-message-btn" id="messageCustomerBtn" disabled>Message</button>
                    </div>--%>
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
                            <button class="cust-site-add-btn" id="addSiteBtn">+ Add Site</button>
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
                    <label for="contact" class="cust-modal-label">Site Contact</label>
                    <input type="text" id="siteContact" name="contact" class="cust-modal-input" />
                </div>
                <%--<div class="cust-modal-field">
                    <label class="cust-modal-label">Equipment Name</label>
                    <input type="text" name="equipName" class="cust-modal-input" />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Equipment Type</label>
                    <select name="equipType" class="cust-modal-input">
                        <option value="">Select Type</option>
                        <option value="hvac">HVAC</option>
                        <option value="generator">Generator</option>
                        <option value="plumbing">Plumbing</option>
                    </select>
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Install Date</label>
                    <input type="date" name="equipInstallDate" class="cust-modal-input" />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Warranty Expiry</label>
                    <input type="date" name="equipWarrantyExpiry" class="cust-modal-input" />
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Service Agreement</label>
                    <input type="file" name="serviceAgreement" accept=".pdf" class="cust-modal-input" />
                    <div id="addSiteAgreementPreview" class="cust-pdf-preview"></div>
                </div>
                <div class="cust-modal-field">
                    <label class="cust-modal-label">Alarms</label>
                    <input type="text" name="alarms" class="cust-modal-input" />
                </div>--%>
                <div class="cust-modal-field">
                    <label for="note" class="cust-modal-label">Note</label>
                    <input id="note" type="text" name="note" class="cust-modal-input" />
                </div>
                <div class="cust-modal-field">
                    <label>
                        <input type="checkbox" id="isActive" checked />
                        Active
                    </label>
                </div>
                <div class="cust-modal-btns">
                    <button type="button" onclick="saveSite(event)" class="cust-modal-submit">Add Site</button>
                    <button type="button" class="cust-modal-cancel" id="closeAddSite">Cancel</button>
                </div>
            </form>
        </div>
    </div>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.datatables.net/2.2.2/js/dataTables.min.js"></script>
    <script type="text/javascript" src="https://cdn.datatables.net/select/3.0.0/js/dataTables.select.min.js"></script>
    <script src="Scripts/customer.js"></script>
    <script>

</script>
</asp:Content>
