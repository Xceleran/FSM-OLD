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
});

var sites = [];

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


// Customer DataTable
let table = null;
loadCustomers();

function loadCustomers() {
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
            { "data": "FirstName", "name": "First Name", "autoWidth": true },
            { "data": "LastName", "name": "Last Name", "autoWidth": true },
            { "data": "Email", "name": "Email", "autoWidth": true },
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
        }
    });
}

$('#customerTable tbody').on('click', 'tr', function () {
    var data = table.row(this).data();
    if (data) {
        generateCustomerDetails(data);
    }
});

function generateCustomerDetails(data) {
    console.log(data);
    if (data) {
        document.getElementById('customerName').textContent = data.FirstName + " " + data.LastName;
        document.getElementById('customerEmail').textContent = data.Email || '-';
        document.getElementById('customerPhone').textContent = data.Phone || '-';
        document.getElementById('CustomerID').value = data.CustomerID;
        document.getElementById('CustomerGuid').value = data.CustomerGuid;
        loadCustomerSiteData(data.CustomerID);
    }
}

function loadCustomerSiteData(customerId) {
    if (customerId) {
        sites = [];
        $.ajax({
            type: "POST",
            url: "Customer.aspx/GetCustomerSiteData",
            data: JSON.stringify({ customerId: customerId }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                console.log(response);
                if (response.d) {
                    sites = response.d;

                    // Render Sites
                    const sitesContainer = document.getElementById('sites');
                    const addSiteBtn = sitesContainer.querySelector('#addSiteBtn');
                    sitesContainer.innerHTML = '';
                    sites.forEach(site => {
                        const siteCard = document.createElement('div');
                        siteCard.className = 'cust-site-card';
                        siteCard.dataset.siteId = site.Id;
                        siteCard.innerHTML = `
                                <h3 class="cust-site-title">${site.SiteName}</h3>
                                <p class="cust-site-info">Address: ${site.Address}</p>
                                <p class="cust-site-info">Contact: ${site.Contact || '-'}</p>
                                <p class="cust-site-active"> ${site.IsActive ? "Active" : "Disabled"}</p>
                                <div class="cust-site-actions">
                                <button class="cust-site-edit-btn" data-site-id="${site.Id}">Edit</button>
                                <a href="CustomerDetails.aspx?siteId=${site.Id}&custId=${site.CustomerID}" class="cust-site-view-link">View Details</a>
                                </div>`;
                        sitesContainer.appendChild(siteCard);
                        if (!site.IsActive) {
                            $('.cust-site-view-link').addClass("d-none");
                        }
                    });



                    sitesContainer.appendChild(addSiteBtn);


                    // Reattach Edit Site Handlers
                    document.querySelectorAll('.cust-site-edit-btn').forEach(btn => {
                        btn.addEventListener('click', () => {
                            const siteId = btn.dataset.siteId;
                            console.log(siteId);
                            console.log(sites);
                            const site = sites.find(s => s.Id == siteId);
                            console.log(site);
                            if (site) {
                                $('.cust-modal-title').text("Edit Site");
                                $('.cust-modal-submit').text("Update");
                                document.getElementById('SiteId').value = site.Id;
                                document.getElementById('CustomerGuid').value = site.CustomerGuid;
                                document.getElementById('CustomerID').value = site.CustomerID;
                                document.getElementById('siteName').value = site.SiteName;
                                document.getElementById('address').value = site.Address;
                                document.getElementById('siteContact').value = site.Contact || '';
                                document.getElementById('isActive').checked = site.IsActive;
                                document.getElementById('note').value = site.Note || '';
                                openModal('addSiteModal');
                            }
                        });
                    });
                }
                else {
                    alert("Something went wrong!");
                }
            },
            error: function (xhr, status, error) {
                console.error("Error loading site data: ", error);
            }
        });
    }
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