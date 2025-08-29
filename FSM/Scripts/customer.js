document.addEventListener('DOMContentLoaded', () => {
    // Add Customer
    const addCustomerBtn = document.getElementById('addCustomerBtn');
    if (addCustomerBtn) {
        addCustomerBtn.addEventListener('click', () => {
            document.getElementById('addCustomerForm').reset();
            openModal('addCustomerModal');
        });
    }

    const closeAddCustomerBtn = document.getElementById('closeAddCustomer');
    if (closeAddCustomerBtn) {
        closeAddCustomerBtn.addEventListener('click', () => closeModal('addCustomerModal'));
    }

    // Add Site
    const addSiteBtn = document.getElementById('addSiteBtn');
    if (addSiteBtn) {
        addSiteBtn.addEventListener('click', () => {
            document.getElementById('addSiteForm').reset();
            $('.cust-modal-title').text("Add Site");
            $('.cust-modal-submit').text("Save");
            openModal('addSiteModal');
        });
    }

    const closeAddSiteBtn = document.getElementById('closeAddSite');
    if (closeAddSiteBtn) {
        closeAddSiteBtn.addEventListener('click', () => closeModal('addSiteModal'));
    }


    // Search Customers
    const customerSearch = document.getElementById('customerSearch');
    if (customerSearch) {
        customerSearch.addEventListener('input', (e) => {
            table.search(e.target.value).draw();
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
                        b.classList.remove('active');
                    }
                });
                if (!isActive) {
                    content.style.display = 'block';
                    btn.classList.add('active');
                }
            });
        });
    }
    // Edit Customer Info Table
    const editCustomerBtn = document.getElementById('editCustomerBtn');
    if (editCustomerBtn) {
        editCustomerBtn.addEventListener('click', () => {
            const customerData = table.row({ selected: true }).data();
            if (customerData) {
                // Populate the edit modal fields
                document.getElementById('editFirstName').value = customerData.FirstName || '';
                document.getElementById('editLastName').value = customerData.LastName || '';
                document.getElementById('editEmail').value = customerData.Email || '';
                document.getElementById('editPhone').value = customerData.Phone || '';
                // Store CustomerID and CustomerGuid for saving
                document.getElementById('editCustomerForm').dataset.customerId = customerData.CustomerID;
                document.getElementById('editCustomerForm').dataset.customerGuid = customerData.CustomerGuid;
                openModal('editCustomerModal');
            } else {
                alert('Please select a customer to edit.');
            }
        });
    }

    // Close Edit Customer Modal
    const closeEditCustomerBtn = document.getElementById('closeEditCustomer');
    if (closeEditCustomerBtn) {
        closeEditCustomerBtn.addEventListener('click', () => closeModal('editCustomerModal'));
    }
});

var sites = [];

//helper

var siteAppointmentsCache = {}; 
function escapeHTML(str) {
    return String(str ?? '').replace(/[&<>"']/g, s => (
        { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[s]
    ));
}

function statusToBadgeClass(status) {
    switch ((status || '').toLowerCase()) {
        case 'scheduled': return 'status-scheduled';
        case 'pending': return 'status-pending';
        case 'closed': return 'status-closed';
        default: return 'status-na';
    }
}

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

//helper for status filter:

function mapStatusValueForDisplay(val) {
    if (!val) return '';
    return val === 'InProgress' ? 'Installation In Progress' : val;
}

function applyRowFiltersOnCurrentPage() {
    if (!table) return;

    const rawStatus = ($('#statusFilter').val() || 'all').trim();
    const wanted = mapStatusValueForDisplay(rawStatus).toLowerCase();
    const hideNA = $('#hideNA').is(':checked');

    table.rows({ page: 'current' }).every(function () {
        const d = this.data();
        const statusTxt = (d && d.StatusName ? d.StatusName : '').toLowerCase();

        let visible = true;

        // status filter
        if (rawStatus !== 'all') visible = (statusTxt === wanted);

        // N/A filter
        if (visible && hideNA && statusTxt === 'n/a') visible = false;

        $(this.node()).toggle(visible);
    });
}

function selectFirstVisibleRow() {
    const api = table;
    api.rows().deselect();
    const $vis = $('#customerTable tbody tr:visible');
    if ($vis.length) {
        const rowApi = api.row($vis[0]);
        rowApi.select();
        const data = rowApi.data();
        if (data) generateCustomerDetails(data);
    }
}



// Customer DataTable
let table = null;
loadCustomers();


function loadCustomers() {
    debugger;
    table = $('#customerTable').DataTable({
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
                    sortDirection: d.order[0].dir,

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
            { "data": "FirstName", "name": "First Name", "autoWidth": true },
            { "data": "LastName", "name": "Last Name", "autoWidth": true },
            { "data": "Email", "name": "Email", "autoWidth": true },
            {
                "data": "StatusName",
                "name": "Status",
                "autoWidth": true,
                "render": function (data, type, row) {
                    let statusClass;
                    switch (data) {
                        case 'Scheduled':
                            statusClass = 'status-scheduled';
                            break;
                        case 'Pending':
                            statusClass = 'status-pending';
                            break;
                        case 'Closed':
                            statusClass = 'status-closed';
                            break;
                        case 'N/A':
                        default:
                            statusClass = 'status-na';
                            break;
                    }
                    return `<span class="badge ${statusClass}">${data}</span>`;
                }
            },
            {
                "data": null,
                "render": function (data, type, row) {
                    //let smsBtn = '<button class="cust-action-btn sms-btn" title="Send SMS" ' +
                    //    'onclick="window.open(\'CustomerChatHistory.aspx?mobile=' + encodeURIComponent(row.Phone) +
                    //    '&name=' + encodeURIComponent(row.FirstName + " " + row.LastName) +
                    //    '&customerId=' + encodeURIComponent(row.CustomerID) +
                    //    '\', \'_blank\')">' +
                    //    '<i class="fa fa-comment-dots"></i></button>';

                    let smsBtn = '<button class="cust-action-btn sms-btn" title="Send SMS" ' +
                        'onclick="OpenCustomerChatHistory(\'' + encodeURIComponent(row.Phone) + '\', \'' + encodeURIComponent(row.FirstName + " " + row.LastName) + '\', \'' + encodeURIComponent(row.CustomerID) + '\')">' +
                        '<i class="fa fa-comment-dots"></i></button>';

                    let editBtn = '<button class="cust-table-edit-btn" title="Edit Customer" data-customer-id="' + row.CustomerID + '">' +
                        '<svg viewBox="0 0 20 20" width="16" height="16" xmlns="http://www.w3.org/2000/svg" fill="none">' +
                        '<path fill="currentColor" fill-rule="evenodd" d="M15.198 3.52a1.612 1.612 0 012.223 2.336L6.346 16.421l-2.854.375 1.17-3.272L15.197 3.521zm3.725-1.322a3.612 3.612 0 00-5.102-.128L3.11 12.238a1 1 0 00-.253.388l-1.8 5.037a1 1 0 001.072 1.328l4.8-.63a1 1 0 00.56-.267L18.8 7.304a3.612 3.612 0 00.122-5.106zM12 17a1 1 0 100 2h6a1 1 0 100-2h-6z"></path>' +
                        '</svg></button>';                   

                    return '<div class="cust-action-btns">' + smsBtn + editBtn + '</div>';
                },
                "orderable": false,
                "width": "15%"
            }


        ],
        "select": {
            "style": "single"
        },
        "drawCallback": function (settings) {
            var api = this.api();
            if (api.rows().count() > 0 && !$('#customerTable tbody tr').hasClass('selected')) {
                api.row(0).select();
                var firstRowData = api.row(0).data();
                generateCustomerDetails(firstRowData);
            }

            applyNAFilter();
        }
    });
}



function loadCustomers_Backup() {
    debugger;
    table = $('#customerTable').DataTable({
        processing: true,
        serverSide: true,
        filter: true,
        ajax: {
            url: 'Customer.aspx/LoadCustomers',
            type: 'POST',
            contentType: 'application/json; charset=utf-8',
            dataType: 'json',
            data: function (d) {
                const raw = ($('#statusFilter').val() || 'all').trim();
                const statusVal =
                    raw === 'all' ? '' :
                        raw === 'InProgress' ? 'Installation In Progress' :
                            raw; // Scheduled/Pending/Closed/Cancelled pass through

                return JSON.stringify({
                    draw: d.draw,
                    start: d.start,
                    length: d.length,
                    searchValue: d.search.value,
                    sortColumn: d.columns[d.order[0].column].data,
                    sortDirection: d.order[0].dir,
                    statusFilter: statusVal               
                });
            },
            dataSrc: function (json) {
                console.log(json);
                if (json.error) {
                    alert(json.error);
                    return [];
                }
                return json.data;
            }
        },
        paging: true,
        pageLength: 10,
        columns: [
            { data: 'FirstName', name: 'First Name', autoWidth: true },
            { data: 'LastName', name: 'Last Name', autoWidth: true },
            { data: 'Email', name: 'Email', autoWidth: true },
            {
                data: 'StatusName',
                name: 'Status',
                autoWidth: true,
                render: function (data) {
                    const txt = (data || 'N/A');
                    let cls = 'status-na';
                    switch (txt.toLowerCase()) {
                        case 'scheduled': cls = 'status-scheduled'; break;
                        case 'pending': cls = 'status-pending'; break;
                        case 'closed': cls = 'status-closed'; break;
                        case 'cancelled': cls = 'status-na'; break; // adjust if we have a specific class
                        case 'inprogress':
                        case 'installation in progress': cls = 'status-scheduled'; break; // or a dedicated class if we already have one
                    }
                    return `<span class="badge ${cls}">${txt}</span>`;
                }
            },
            {
                data: null,
                render: function (_, __, row) {
                    return (
                        '<button class="cust-table-edit-btn" data-customer-id="' + row.CustomerID + '">' +
                        '<svg viewBox="0 0 20 20" width="18" height="18" xmlns="http://www.w3.org/2000/svg" fill="none">' +
                        '<g id="SVGRepo_iconCarrier">' +
                        '<path fill="currentColor" fill-rule="evenodd" d="M15.198 3.52a1.612 1.612 0 012.223 2.336L6.346 16.421l-2.854.375 1.17-3.272L15.197 3.521zm3.725-1.322a3.612 3.612 0 00-5.102-.128L3.11 12.238a1 1 0 00-.253.388l-1.8 5.037a1 1 0 001.072 1.328l4.8-.63a1 1 0 00.56-.267L18.8 7.304a3.612 3.612 0 00.122-5.106zM12 17a1 1 0 100 2h6a1 1 0 100-2h-6z"></path>' +
                        '</g></svg>' +
                        '</button>'
                    );
                },
                orderable: false,
                width: '10%'
            }
        ],
        select: { style: 'single' },

        drawCallback: function () {
            const api = this.api();
            applyRowFiltersOnCurrentPage();
            selectFirstVisibleRow();
        }


    });
}

$(document).on('change', '#statusFilter', function () {
    if (table) table.ajax.reload(null, true);
});

$(document).on('change', '#hideNA', function () {
    applyRowFiltersOnCurrentPage();
    selectFirstVisibleRow();
});






// Row click handler to load customer details
$('#customerTable tbody').on('click', 'tr', function () {
    var data = table.row(this).data();
    if (data) {
        generateCustomerDetails(data);
    }
});


function applyNAFilter() {
    const hideNA = $('#hideNA').is(':checked');
    $('#customerTable tbody tr').each(function () {
        const statusText = $(this).find('td:eq(3) .badge').text().trim(); // status column is 4th (index 3)
        if (hideNA && statusText === 'N/A') {
            $(this).hide();
        } else {
            $(this).show();
        }
    });
}

// 🟨 Listen for checkbox toggle and redraw the table
$('#hideNA').on('change', function () {
    if (table) table.draw(); // triggers drawCallback
});


function generateCustomerDetails(data) {
    console.log(data);
    if (data) {
        document.getElementById('customerName').textContent = data.FirstName + " " + data.LastName;
        document.getElementById('customerEmail').textContent = data.Email || '-';
        document.getElementById('customerPhone').textContent = data.Phone || '-';
        // Construct and display Address
        var address = [
            data.Address1,
            data.City,
            data.State,
            data.ZipCode
        ].filter(Boolean).join(', '); // Join non-empty fields with commas
        document.getElementById('customerAddress').textContent = address || '-';
        document.getElementById('customerJobTitle').textContent = data.JobTitle || '-';
        document.getElementById('CustomerID').value = data.CustomerID;
        document.getElementById('CustomerGuid').value = data.CustomerGuid;
        loadCustomerSiteData(data.CustomerID);
    }
}

function loadCustomerSiteData(customerId) {
    if (!customerId) return;

    sites = [];

    $.ajax({
        type: "POST",
        url: "Customer.aspx/GetCustomerSiteData",
        data: JSON.stringify({ customerId: customerId }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            if (!response.d) {
                alert("Something went wrong!");
                return;
            }

            sites = response.d;

            
            if (typeof siteAppointmentsCache !== 'undefined') {
                siteAppointmentsCache = {};
            }

            // Render Sites
            const sitesContainer = document.getElementById('sites');
            sitesContainer.innerHTML = '';

            sites.forEach(site => {
                const siteCard = document.createElement('div');
                siteCard.className = 'cust-site-card';
                siteCard.dataset.siteId = site.Id;

                siteCard.innerHTML = `
          <h3 class="cust-site-title">${escapeHTML(site.SiteName)}</h3>
          <p class="cust-site-info">Address: ${escapeHTML(site.Address)}</p>
          <p class="cust-site-info">Contact: ${escapeHTML(site.Contact || '-')}</p>
          <p class="cust-site-active">${site.IsActive ? "Active" : "Disabled"}</p>

          <div class="cust-site-actions">
            <button class="cust-site-edit-btn" data-site-id="${site.Id}">Edit</button>
            <a href="CustomerDetails.aspx?siteId=${site.Id}&custId=${encodeURIComponent(site.CustomerID)}" class="cust-site-view-link">View Details</a>
          </div>

          <div class="cust-site-appts-wrap">
            <button class="cust-site-appts-toggle" data-site-id="${site.Id}">Show Appointments</button>
            <div class="cust-site-appts" id="site-appts-${site.Id}" data-loaded="false" style="display:none;"></div>
          </div>
        `;

                if (!site.IsActive) {
                    siteCard.querySelector('.cust-site-view-link')?.classList.add('d-none');
                }

                sitesContainer.appendChild(siteCard);
            });

            document.querySelectorAll('.cust-site-edit-btn').forEach(btn => {
                btn.addEventListener('click', () => {
                    const siteId = btn.dataset.siteId;
                    const site = sites.find(s => String(s.Id) === String(siteId));
                    if (!site) return;

                    $('.cust-modal-title').text("Edit Site");
                    $('.cust-modal-submit').text("Update");

                    document.getElementById('SiteId').value = site.Id;
                    document.getElementById('CustomerGuid').value = site.CustomerGuid;
                    document.getElementById('CustomerID').value = site.CustomerID;

                    document.getElementById('siteName').value = site.SiteName;
                    document.getElementById('address').value = site.Address;
                    document.getElementById('siteContact').value = site.Contact || '';
                    document.getElementById('isActive').checked = !!site.IsActive;
                    document.getElementById('note').value = site.Note || '';

                    openModal('addSiteModal');
                });
            });

            const addBtn = document.createElement('button');
            addBtn.id = 'addSiteBtn';
            addBtn.type = 'button';
            addBtn.className = 'btn btn-primary mt-2';
            addBtn.textContent = '+ Add Site';

            addBtn.addEventListener('click', () => {
                
                const form = document.getElementById('addSiteForm');
                if (form) form.reset();

                $('.cust-modal-title').text('Add Site');
                $('.cust-modal-submit').text('Save');

                document.getElementById('SiteId').value = 0;
               
                const currCustomerId = document.getElementById('CustomerID')?.value || customerId;
                const currCustomerGuid = document.getElementById('CustomerGuid')?.value || '';
                document.getElementById('CustomerID').value = currCustomerId;
                document.getElementById('CustomerGuid').value = currCustomerGuid;

                document.getElementById('isActive').checked = true;

                openModal('addSiteModal');
            });

            sitesContainer.appendChild(addBtn);
            // -----------------------------------------------------------------------
        },
        error: function (xhr, status, error) {
            console.error("Error loading site data: ", error);
        }
    });
}



// Toggle + load appointments per site card
$('#sites').on('click', '.cust-site-appts-toggle', function () {
    const siteId = parseInt($(this).data('site-id'), 10);
    const apptsEl = document.getElementById(`site-appts-${siteId}`);
    if (!apptsEl) return;

    const isVisible = apptsEl.style.display === 'block';
    if (isVisible) {
        // collapse
        apptsEl.style.display = 'none';
        this.textContent = 'Show Appointments';
        return;
    }

    // expand
    this.textContent = 'Hide Appointments';
    apptsEl.style.display = 'block';

   
    if (apptsEl.getAttribute('data-loaded') === 'true') return;

    // fetch on first open
    const customerId = document.getElementById('CustomerID')?.value;
    if (!customerId) {
        apptsEl.innerHTML = '<div class="text-danger small">Missing customer id.</div>';
        return;
    }

    // show loading state
    apptsEl.innerHTML = '<div class="text-muted small">Loading appointments…</div>';

    // Use cache if present
    if (siteAppointmentsCache[siteId]) {
        renderSiteAppointments(siteId, siteAppointmentsCache[siteId], apptsEl);
        apptsEl.setAttribute('data-loaded', 'true');
        return;
    }

    $.ajax({
        type: 'POST',
        url: 'CustomerDetails.aspx/GetCustomerAppoinmets',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        data: JSON.stringify({ customerId: customerId, siteId: siteId }),
        success: function (resp) {
            const list = resp && Array.isArray(resp.d) ? resp.d : [];
            siteAppointmentsCache[siteId] = list; // cache
            renderSiteAppointments(siteId, list, apptsEl);
            apptsEl.setAttribute('data-loaded', 'true');
        },
        error: function (xhr) {
            console.error('GetCustomerAppoinmets failed:', xhr?.status, xhr?.statusText, xhr?.responseText);
            apptsEl.innerHTML = '<div class="text-danger small">Failed to load appointments.</div>';
        }
    });
});



function renderSiteAppointments(siteId, list, containerEl) {
    if (!Array.isArray(list) || list.length === 0) {
        containerEl.innerHTML = '<div class="text-muted small">No appointments for this site.</div>';
        return;
    }

 
    const getDateStr = (item) => item.AppoinmentDate || item.RequestDate || '';

    const toTs = (s) => {
        if (!s) return NaN;
        const m = String(s).trim().match(/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/);
        if (m) {
            const mm = parseInt(m[1], 10), dd = parseInt(m[2], 10), yy = parseInt(m[3], 10);
            return new Date(yy, mm - 1, dd).getTime();
        }
        const t = Date.parse(s);
        return isNaN(t) ? NaN : t;
    };

    const tsList = list.map(i => toTs(getDateStr(i)));
    const validTs = tsList.filter(t => !isNaN(t));

    let mostIdx = 0;               // default first
    let lastIdx = list.length > 1 ? list.length - 1 : -1;

    if (validTs.length > 0) {
        const maxTs = Math.max(...validTs);
        const minTs = Math.min(...validTs);
        mostIdx = tsList.findIndex(t => t === maxTs);
        lastIdx = tsList.findIndex(t => t === minTs);
        if (mostIdx === lastIdx) lastIdx = -1; // only show "Most recent" when same
    } else {
        if (list.length === 1) lastIdx = -1; // single item → only "Most recent"
    }

    const rows = list.map((item, idx) => {
        const date = escapeHTML(getDateStr(item) || '—');
        const type = escapeHTML(item.ServiceType || '—');
        const status = escapeHTML(item.AppoinmentStatus || 'N/A');

        // Map status to existing badge classes
        const statusClass = (function (s) {
            switch ((s || '').toLowerCase()) {
                case 'scheduled': return 'status-scheduled';
                case 'pending': return 'status-pending';
                case 'closed': return 'status-closed';
                case 'cancelled': return 'status-na';
                case 'inprogress':
                case 'installation in progress': return 'status-scheduled';
                default: return 'status-na';
            }
        })(status);

        // Indicator first, styled like a badge
        let indicatorHtml = '&nbsp;';
        if (idx === mostIdx) {
            indicatorHtml = '<span class="badge status-na">Most recent</span>';
        } else if (idx === lastIdx) {
            indicatorHtml = '<span class="badge status-na">Last appointment</span>';
        }

        return `
      <div class="cust-appt-row d-flex align-items-center py-1 border-bottom">
        <div class="small" style="min-width:140px">${indicatorHtml}</div>
        <div class="small" style="min-width:140px"><strong>Date:</strong> ${date}</div>
        <div class="small" style="min-width:180px"><strong>Type:</strong> ${type}</div>
        <div class="small"><strong></strong> <span class="badge ${statusClass}">${status}</span></div>
      </div>`;
    }).join('');

    containerEl.innerHTML = `<div class="cust-appt-list">${rows}</div>`;
}



function saveSite(event) {
    event.preventDefault();
    if (validateSiteForm()) {
        const site = {
            Id: parseInt($('#SiteId').val()),
            CustomerID: $('#CustomerID').val(),
            CustomerGuid: $('#CustomerGuid').val(),
            Note: $('#note').val().trim(),
            Contact: $('#siteContact').val().trim(),
            Address: $('#address').val().trim(),
            SiteName: $('#siteName').val().trim(),
            IsActive: document.getElementById("isActive").checked
        };
        console.log(site);

        let message = "saved";
        if (site.Id > 0) {
            message = "updated";
        }

        $.ajax({
            type: "POST",
            url: "Customer.aspx/SaveCustomerSiteData",
            data: JSON.stringify({ site: site }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                console.log(response);
                if (response.d) {
                    alert("Site " + message + " successfully!");
                    closeModal('addSiteModal');
                    loadCustomerSiteData(site.CustomerID);
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



}

function validateSiteForm() {
    let isValid = true;
    let errorMessage = "";

    // Required field validation
    if ($("#siteName").val().trim() === "") {
        errorMessage += "Site Name is required.\n";
        isValid = false;
    }
    if ($("#address").val().trim() === "") {
        errorMessage += "Adress is required.\n";
        isValid = false;
    }

    if (!isValid) {
        alert(errorMessage);
    }
    return isValid;

}
// Save Edited Customer Info
const editCustomerForm = document.getElementById('editCustomerForm');
if (editCustomerForm) {
    editCustomerForm.addEventListener('submit', (event) => {
        event.preventDefault();
        if (validateCustomerForm()) {
            const customer = {
                CustomerID: editCustomerForm.dataset.customerId,
                CustomerGuid: editCustomerForm.dataset.customerGuid,
                FirstName: document.getElementById('editFirstName').value.trim(),
                LastName: document.getElementById('editLastName').value.trim(),
                Email: document.getElementById('editEmail').value.trim(),
                Phone: document.getElementById('editPhone').value.trim()
            };

            $.ajax({
                type: "POST",
                url: "Customer.aspx/UpdateCustomer",
                data: JSON.stringify({ customer: customer }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d) {
                        alert("Customer updated successfully!");
                        closeModal('editCustomerModal');
                        table.ajax.reload(); // Refresh the DataTable
                        generateCustomerDetails(customer); // Update details display
                    } else {
                        alert("Failed to update customer.");
                    }
                },
                error: function (xhr, status, error) {
                    console.error("Error updating customer: ", error);
                    alert("Error updating customer.");
                }
            });
        }
    });
}

// Validate Edit Customer Form
function validateCustomerForm() {
    let isValid = true;
    let errorMessage = "";

    if ($("#editFirstName").val().trim() === "") {
        errorMessage += "First Name is required.\n";
        isValid = false;
    }
    if ($("#editLastName").val().trim() === "") {
        errorMessage += "Last Name is required.\n";
        isValid = false;
    }
    if ($("#editEmail").val().trim() === "") {
        errorMessage += "Email is required.\n";
        isValid = false;
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test($("#editEmail").val().trim())) {
        errorMessage += "Invalid email format.\n";
        isValid = false;
    }

    if (!isValid) {
        alert(errorMessage);
    }
    return isValid;
}