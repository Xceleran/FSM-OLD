<%@ Page Title="Customer Site Details" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="CustomerDetails.aspx.cs" Inherits="FSM.CustomerDetails" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style type="text/css">
        /* Unique raw CSS classes for CustomerDetails */
        .custdet-container { padding: 24px; width: 100%; box-sizing: border-box; }
        .custdet-title { font-size: 24px; font-weight: 600; color: #1f2937; margin-bottom: 24px; }
        .custdet-content { background-color: #ffffff; border-radius: 8px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); padding: 24px; }
        .custdet-section { margin-bottom: 24px; }
        .custdet-section-title { font-size: 20px; font-weight: 500; color: #374151; margin-bottom: 8px; }
        .custdet-table { width: 100%; border-collapse: collapse; border: 1px solid #e5e7eb; }
        .custdet-table th, .custdet-table td { border: 1px solid #e5e7eb; padding: 8px; text-align: left; }
        .custdet-table th { background-color: #f3f4f6; color: #374151; font-weight: 500; }
        .custdet-table td { color: #1f2937; }
        .custdet-table-label { font-weight: 500; color: #374151; }
        .custdet-link { color: #2563eb; text-decoration: none; }
        .custdet-link:hover { text-decoration: underline; }
        .custdet-gallery { display: flex; flex-wrap: wrap; gap: 8px; }
        .custdet-no-pics { color: #1f2937; }
        .custdet-message-container { display: flex; flex-direction: column; gap: 8px; }
        .custdet-message-select { border: 1px solid #d1d5db; border-radius: 8px; padding: 8px; width: 100%; box-sizing: border-box; }
        .custdet-send-btn { background-color: #e5e7eb; color: #374151; padding: 8px 16px; border-radius: 8px; border: none; cursor: pointer; }
        .custdet-send-btn:hover { background-color: #d1d5db; }
        .custdet-back-btn { background-color: #e5e7eb; color: #374151; padding: 8px 16px; border-radius: 8px; border: none; cursor: pointer; text-decoration: none; display: inline-block; }
        .custdet-back-btn:hover { background-color: #d1d5db; }
        .custdet-back-container { display: flex; justify-content: flex-end; }

        /* Responsive adjustments */
        @media (min-width: 768px) {
            .custdet-message-container { flex-direction: row; }
        }
    </style>

    <div class="custdet-container">
        <h1 class="custdet-title">Site Details: <span id="siteDetailsName">Loading...</span></h1>
        <div class="custdet-content">
            <!-- Basic Info -->
            <div class="custdet-section">
                <h2 class="custdet-section-title">Basic Information</h2>
                <table class="custdet-table">
                    <thead>
                        <tr>
                            <th>Field</th>
                            <th>Details</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td class="custdet-table-label">Contact Info</td>
                            <td id="siteContactInfo">Linked from CEC</td>
                        </tr>
                        <tr>
                            <td class="custdet-table-label">Address</td>
                            <td id="siteAddress">Loading...</td>
                        </tr>
                        <tr>
                            <td class="custdet-table-label">Status</td>
                            <td id="siteStatus">Loading...</td>
                        </tr>
                        <tr>
                            <td class="custdet-table-label">Description</td>
                            <td id="siteDescription">Loading...</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Service & Appointments -->
            <div class="custdet-section">
                <h2 class="custdet-section-title">Service & Appointments</h2>
                <table class="custdet-table">
                    <thead>
                        <tr>
                            <th>Field</th>
                            <th>Details</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td class="custdet-table-label">Service History</td>
                            <td id="siteServiceHistory">Last visit: 03/10/2025</td>
                        </tr>
                        <tr>
                            <td class="custdet-table-label">Appointments</td>
                            <td id="siteAppointments">Work Order #123 scheduled</td>
                        </tr>
                        <tr>
                            <td class="custdet-table-label">Proposals</td>
                            <td id="siteProposals">Pending approval</td>
                        </tr>
                        <tr>
                            <td class="custdet-table-label">Checklists</td>
                            <td id="siteChecklists">Maintenance completed</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Equipment -->
            <div class="custdet-section">
                <h2 class="custdet-section-title">Equipment</h2>
                <table class="custdet-table">
                    <thead>
                        <tr>
                            <th>Equipment</th>
                            <th>Serial</th>
                            <th>Warranty</th>
                        </tr>
                    </thead>
                    <tbody id="siteEquipmentList">
                        <tr>
                            <td id="equipmentName">Loading...</td>
                            <td id="equipmentSerial">Loading...</td>
                            <td id="equipmentWarranty">Loading...</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Work Order -->
            <div class="custdet-section">
                <h2 class="custdet-section-title">Work Order</h2>
                <table class="custdet-table">
                    <thead>
                        <tr>
                            <th>Field</th>
                            <th>Details</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td class="custdet-table-label">Work Order Description</td>
                            <td id="siteWorkOrderDesc">HVAC maintenance scheduled</td>
                        </tr>
                        <tr>
                            <td class="custdet-table-label">Work Order Status</td>
                            <td id="siteWorkOrderStatus">Open</td>
                        </tr>
                        <tr>
                            <td class="custdet-table-label">Resource Assignments</td>
                            <td id="siteResourceAssignments">Tech: Jane Doe</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Additional Details -->
            <div class="custdet-section">
                <h2 class="custdet-section-title">Additional Details</h2>
                <table class="custdet-table">
                    <thead>
                        <tr>
                            <th>Field</th>
                            <th>Details</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td class="custdet-table-label">Internal Notes</td>
                            <td id="siteInternalNotes">Check filter replacement</td>
                        </tr>
                        <tr>
                            <td class="custdet-table-label">Site History Link</td>
                            <td><a href="#" class="custdet-link" id="siteHistoryLink">View Full History</a></td>
                        </tr>
                        <tr>
                            <td class="custdet-table-label">Billable Items</td>
                            <td id="siteBillableItems">Loading...</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Pictures Section -->
            <div class="custdet-section">
                <h2 class="custdet-section-title">Pictures</h2>
                <div class="custdet-gallery" id="sitePictures">
                    <span class="custdet-no-pics">No pictures uploaded</span>
                </div>
            </div>

            <!-- Customer Message Section -->
            <div class="custdet-section">
                <h2 class="custdet-section-title">Customer Message</h2>
                <div class="custdet-message-container">
                    <select id="siteMessageTemplate" class="custdet-message-select">
                        <option value="">Select a template (from CEC)</option>
                        <option value="Service Scheduled">Service Scheduled</option>
                        <option value="Invoice Ready">Invoice Ready</option>
                    </select>
                    <button class="custdet-send-btn" id="sendMessageBtn">Send</button>
                </div>
            </div>

            <!-- Back Button -->
            <div class="custdet-back-container">
                <a href="Customer.aspx" class="custdet-back-btn">Back to Customers</a>
            </div>
        </div>
    </div>

    <script> 
        document.addEventListener('DOMContentLoaded', () => {
    // Get siteId from URL query parameter
    const urlParams = new URLSearchParams(window.location.search);
    const siteId = urlParams.get('siteId');

    // Mock data for demonstration (client-side only)
    const siteData = {
        1: {
            name: 'Main Residence',
            address: '123 Elm St, City, ST 12345',
            status: 'Active',
            equipment: 'HVAC Unit',
            description: 'Primary residence location',
            pictures: [],
            billableItems: 'HVAC Service - $450 (Synced to QBO)'
        },
        2: {
            name: 'Vacation Home',
            address: '456 Oak Rd, City, ST 12345',
            status: 'Active',
            equipment: 'Generator',
            description: 'Secondary vacation property',
            pictures: [],
            billableItems: 'Generator Service - $300 (Synced to QBO)'
        }
    };

    // Default to unknown site if no siteId or invalid
    const site = siteData[siteId] || {
        name: 'Unknown Site',
        address: 'N/A',
        status: 'Unknown',
        equipment: 'None',
        description: 'No description available',
        pictures: [],
        billableItems: 'N/A'
    };

    // Populate Basic Info
    document.getElementById('siteDetailsName').textContent = site.name;
    document.getElementById('siteAddress').textContent = site.address;
    document.getElementById('siteStatus').textContent = site.status;
    document.getElementById('siteDescription').textContent = site.description;

    // Populate Equipment Table
    const equipmentList = document.getElementById('siteEquipmentList');
    equipmentList.innerHTML = '';
    if (site.equipment) {
        equipmentList.innerHTML = `
            <tr>
                <td>${site.equipment}</td>
                <td>ABC${siteId || 'Unknown'}</td>
                <td>Active until 2026</td>
            </tr>
        `;
    } else {
        equipmentList.innerHTML = '<tr><td colspan="3">No equipment listed</td></tr>';
    }

    // Populate Pictures
    const imageGallery = document.getElementById('sitePictures');
    imageGallery.innerHTML = '';
    if (site.pictures && site.pictures.length > 0) {
        site.pictures.forEach(src => {
            const img = document.createElement('img');
            img.src = src;
            img.style.cssText = 'max-width: 100px; max-height: 100px; border-radius: 8px; object-fit: cover;';
            imageGallery.appendChild(img);
        });
    } else {
        imageGallery.innerHTML = '<span class="custdet-no-pics">No pictures uploaded</span>';
    }

    // Populate Billable Items
    document.getElementById('siteBillableItems').textContent = site.billableItems;

    // Send Message Button
    const sendMessageBtn = document.getElementById('sendMessageBtn');
    if (sendMessageBtn) {
        sendMessageBtn.addEventListener('click', () => {
            const template = document.getElementById('siteMessageTemplate').value;
            if (template) {
                alert(`Sending "${template}" to customer for ${site.name}...`);
            } else {
                alert('Please select a message template.');
            }
        });
    }
});

    </script>
</asp:Content>