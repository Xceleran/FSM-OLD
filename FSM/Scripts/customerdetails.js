document.addEventListener('DOMContentLoaded', () => {


    let appointmentData = [];
    let invoiceData = [];
    let equipmentData = [];
    let site = { serviceAgreements: [] };
    let siteFiles = [];
    let invSortColumn = 'InvoiceDate';
    let invSortDirection = 'desc';
    let currentPageAppt = 1, pageSizeAppt = 10;
    let currentPageInv = 1, pageSizeInv = 10;
    let currentPageEqp = 1, pageSizeEqp = 10;
    let invStartDate = null;
    let invEndDate = null;

    const customerId = document.getElementById('MainContent_lblCustomerId')?.innerText || '';
    const siteId = parseInt(document.getElementById('MainContent_lblSiteId')?.innerText || '0');
    const customerGuid = document.getElementById('MainContent_lblCustomerGuid')?.innerText || '';

    initializeEventListeners();
    loadAllData();
    initializeTabFromURL();
    updateDateFilterUI();

    function initializeEventListeners() {
        $('#createInvoiceBtn').on('click', () => window.open(`https://testsite.myserviceforce.com/cec/Invoice.aspx?InType=Invoice&cId=${customerGuid}`));
        $('#createEstimateBtn').on('click', () => window.open(`https://testsite.myserviceforce.com/cec/Invoice.aspx?InType=Proposal&cId=${customerGuid}`));
        $('#apptSearch, #MainContent_apptFilter, #MainContent_ticketStatus').on('input change', applyFiltersAppt);
        $('#apptPrev').on('click', () => { if (currentPageAppt > 1) { currentPageAppt--; renderAppointments(); } });
        $('#apptNext').on('click', () => {
            const totalPages = Math.ceil(getFilteredAppointments().length / pageSizeAppt);
            if (currentPageAppt < totalPages) { currentPageAppt++; renderAppointments(); }
        });
        $('#invSearch, #invFilter, #invFilterType, #invOn, #invFrom, #invTo').on('input change', applyFiltersInv);
        $('#invDateMode').on('change', () => { updateDateFilterUI(); applyFiltersInv(); });
        $('#invClearDate').on('click', clearDateFilter);
        $('#invPrev').on('click', () => { if (currentPageInv > 1) { currentPageInv--; renderInvoices(); } });
        $('#invNext').on('click', () => {
            const totalPages = Math.ceil(getFilteredInvoices().length / pageSizeInv);
            if (currentPageInv < totalPages) { currentPageInv++; renderInvoices(); }
        });
        $(document).on('click', '.invoice-link', function (e) {
            e.preventDefault();
            redirectToInvoiceModify($(this).data('id'), $(this).data('type'), $(this).data('appid'));
        });


        $('#equipSearch').on('input', applyFiltersEqp);
        $('#equipAdd').on('click', openAddEquipmentModal);
        $('#equipSave').on('click', equipmentSave);
        $('#eqpPrev').on('click', () => { if (currentPageEqp > 1) { currentPageEqp--; renderEquipments(); } });
        $('#eqpNext').on('click', () => {
            const totalPages = Math.ceil(getFilteredEquipment().length / pageSizeEqp);
            if (currentPageEqp < totalPages) { currentPageEqp++; renderEquipments(); }
        });
        $('#invDateRangePicker').daterangepicker({
            startDate: moment(),
            endDate: moment(),
            autoUpdateInput: false,
            locale: {
                cancelLabel: 'Clear',
                format: 'MM/DD/YYYY'
            }
        });

        $('#invDateRangePicker').on('apply.daterangepicker', function (ev, picker) {
            invStartDate = picker.startDate;
            invEndDate = picker.endDate;

            let buttonText;
            if (picker.startDate.isSame(picker.endDate, 'day')) {
                buttonText = 'On: ' + picker.startDate.format('MM/DD/YYYY');
            } else {
                buttonText = picker.startDate.format('MM/DD/YYYY') + ' - ' + picker.endDate.format('MM/DD/YYYY');
            }

            $(this).find('span').html(buttonText);
            applyFiltersInv();
        });

        $('#invDateRangePicker').on('cancel.daterangepicker', function (ev, picker) {
            invStartDate = null;
            invEndDate = null;

            $(this).find('span').html('Date Range');
            applyFiltersInv();
        });

        $('#invoices .sortable-header').on('click', function () {
            const newSortColumn = $(this).data('sort');
            if (invSortColumn === newSortColumn) {

                invSortDirection = invSortDirection === 'asc' ? 'desc' : 'asc';
            } else {

                invSortColumn = newSortColumn;
                invSortDirection = 'asc';
            }
            renderInvoices();
        });
        $('#uploadFileBtn').on('click', () => {

            $('#fileUploadInput').click();
        });

        $('#fileUploadInput').on('change', handleFileUpload);
    }


    function loadAllData() {
        if (customerId && siteId > 0) {
            loadAppointments();
            loadInvoices();
            loadEquipment();
        } else {
            showToast("Error: Customer or Site ID is missing. Cannot load data.");
            console.error("Customer ID or Site ID is missing from the page.");
        }
    }

    function initializeTabFromURL() {
        const params = new URLSearchParams(location.search);
        const tab = params.get('tab');
        if (tab) {
            const btn = document.querySelector(`#custdetTabs .nav-link[data-bs-target="#${tab}"]`);
            if (btn && window.bootstrap && bootstrap.Tab) {
                new bootstrap.Tab(btn).show();
            }
        }
    }


    function loadAppointments() {
        $.ajax({
            url: 'CustomerDetails.aspx/GetCustomerAppoinmets',
            type: "POST",
            contentType: "application/json; charset=utf-8",
            data: JSON.stringify({ customerId: customerId, siteId: siteId }),
            dataType: 'json',
            success: (rs) => { appointmentData = rs.d || []; applyFiltersAppt(); },
            error: () => showToast("Failed to load appointments.")
        });
    }

    function loadInvoices() {
        $.ajax({
            url: 'CustomerDetails.aspx/GetCustomerInvoices',
            type: "POST",
            contentType: "application/json; charset=utf-8",
            data: JSON.stringify({ customerId: customerId }),
            dataType: 'json',
            success: (rs) => { invoiceData = rs.d || []; applyFiltersInv(); },
            error: () => showToast("Failed to load invoices.")
        });
    }

    function loadEquipment() {
        $.ajax({
            url: 'CustomerDetails.aspx/GetSiteEquipmentData',
            type: "POST",
            contentType: "application/json; charset=utf-8",
            data: JSON.stringify({ siteId: siteId, customerGuid: customerGuid }),
            dataType: 'json',
            success: (rs) => { equipmentData = rs.d || []; applyFiltersEqp(); },
            error: () => showToast("Failed to load equipment.")
        });
    }

    function getFilteredAppointments() {
        const searchTerm = ($('#apptSearch').val() || '').toLowerCase();
        const statusFilter = $('#MainContent_apptFilter').val();
        const ticketFilter = $('#MainContent_ticketStatus').val();
        return appointmentData.filter(item =>
            (statusFilter === '' || item.AppoinmentStatus === statusFilter) &&
            (ticketFilter === '' || item.TicketStatus === ticketFilter) &&
            (Object.values(item).join(' ').toLowerCase().includes(searchTerm))
        );
    }

    function applyFiltersAppt() { currentPageAppt = 1; renderAppointments(); }

    function renderAppointments() {
        const filtered = getFilteredAppointments();
        const tbody = $('#apptTableBody').empty();
        updatePagination('appt', currentPageAppt, filtered.length, pageSizeAppt);

        if (filtered.length === 0) {
            tbody.append('<tr><td colspan="7">No appointments found.</td></tr>');
            return;
        }

        const pageData = filtered.slice((currentPageAppt - 1) * pageSizeAppt, currentPageAppt * pageSizeAppt);
        pageData.forEach(item => {
            tbody.append(`
                <tr>
                    <td><div class="dropdown position-static">...</div></td>
                    <td>${item.RequestDate || ''}</td>
                    <td>${item.TimeSlot || ''}</td>
                    <td>${item.ServiceType || ''}</td>
                    <td>${item.AppoinmentStatus || ''}</td>
                    <td>${item.ResourceName || ''}</td>
                    <td>${item.TicketStatus || ''}</td>
                </tr>`);
        });
    }


    function getFilteredInvoices() {
        const searchTerm = ($('#invSearch').val() || '').toLowerCase();
        const statusFilter = $('#invFilter').val();
        const typeFilter = $('#invFilterType').val();

        return invoiceData.filter(item => {
            const itemType = (item.InvoiceType === 'Proposal') ? 'estimate' : 'invoice';
            const matchesSearch = Object.values(item).join(' ').toLowerCase().includes(searchTerm);
            const matchesStatus = statusFilter === 'all' || (item.InvoiceStatus && item.InvoiceStatus.toLowerCase() === statusFilter);
            const matchesType = typeFilter === 'all' || itemType === typeFilter;

            let matchesDate = true;
            if (invStartDate && invEndDate) {
                const invDateObj = parseMDY(item.InvoiceDate);
                if (invDateObj) {
                    matchesDate = invDateObj >= invStartDate.startOf('day') && invDateObj <= invEndDate.endOf('day');
                } else {
                    matchesDate = false;
                }
            }

            return matchesSearch && matchesStatus && matchesType && matchesDate;
        });
    }

    function applyFiltersInv() { currentPageInv = 1; renderInvoices(); }

    function renderInvoices() {
        let filtered = getFilteredInvoices();

        filtered.sort((a, b) => {
            let valA = a[invSortColumn];
            let valB = b[invSortColumn];

            const isNumeric = ['Subtotal', 'Discount', 'Tax', 'Total', 'Due', 'DepositAmount'].includes(invSortColumn);
            const isDate = invSortColumn === 'InvoiceDate';

            if (isNumeric) {
                valA = parseFloat(valA) || 0;
                valB = parseFloat(valB) || 0;
            } else if (isDate) {
                valA = parseMDY(valA);
                valB = parseMDY(valB);
            } else {
                valA = (valA || '').toLowerCase();
                valB = (valB || '').toLowerCase();
            }

            if (valA < valB) return invSortDirection === 'asc' ? -1 : 1;
            if (valA > valB) return invSortDirection === 'asc' ? 1 : -1;
            return 0;
        });

        $('#invoices .sortable-header').each(function () {
            const headerSortKey = $(this).data('sort');
            const icon = $(this).find('i');

            icon.removeClass('fa-sort fa-sort-up fa-sort-down');

            if (headerSortKey === invSortColumn) {
                icon.addClass(invSortDirection === 'asc' ? 'fa-sort-up' : 'fa-sort-down');
            } else {
                icon.addClass('fa-sort');
            }
        });

        const tbody = $('#invTableBody').empty();
        updatePagination('inv', currentPageInv, filtered.length, pageSizeInv);

        if (filtered.length === 0) {
            tbody.append('<tr><td colspan="11">No invoices found matching your criteria.</td></tr>');
            return;
        }

        const pageData = filtered.slice((currentPageInv - 1) * pageSizeInv, currentPageInv * pageSizeInv);
        pageData.forEach(item => {
            const cecButton = item.ExternalLink ? `<a href="${item.ExternalLink}" target="_blank" class="btn btn-sm btn-outline-primary">View in CEC</a>` : '';
            tbody.append(`
            <tr>
                <td><a href="#" class="invoice-link" data-id="${item.ID}" data-type="${item.InvoiceType}" data-appid="${item.AppointmentId}">${item.InvoiceNumber || ''}</a></td>
                <td>${item.InvoiceType || ''}</td>
                <td>${item.InvoiceDate || ''}</td>
                <td>${item.Subtotal || '0.00'}</td>
                <td>${item.Discount || '0.00'}</td>
                <td>${item.Tax || '0.00'}</td>
                <td>${item.Total || '0.00'}</td>
                <td>${item.Due || '0.00'}</td>
                <td>${item.DepositAmount || '0.00'}</td>
                <td>${item.InvoiceStatus || ''}</td>
                <td>${cecButton}</td>
            </tr>`);
        });
    }


    function getFilteredEquipment() {
        const searchTerm = ($('#equipSearch').val() || '').toLowerCase();
        return equipmentData.filter(item => Object.values(item).join(' ').toLowerCase().includes(searchTerm));
    }

    function applyFiltersEqp() { currentPageEqp = 1; renderEquipments(); }

    function renderEquipments() {
        const filtered = getFilteredEquipment();
        const tbody = $('#equipTableBody').empty();
        updatePagination('eqp', currentPageEqp, filtered.length, pageSizeEqp);

        if (filtered.length === 0) {
            tbody.append('<tr><td colspan="12">No equipment found.</td></tr>');
            return;
        }

        const pageData = filtered.slice((currentPageEqp - 1) * pageSizeEqp, currentPageEqp * pageSizeEqp);
        pageData.forEach(item => {
            tbody.append(`
                <tr>
                    <td>${item.EquipmentType || ''}</td>
                    <td>${item.SerialNumber || ''}</td>
                    <td>${item.Make || ''}</td>
                    <td>${item.Model || ''}</td>
                    <td>${item.WarrantyStart || ''}</td>
                    <td>${item.WarrantyEnd || ''}</td>
                    <td>${item.LaborWarrantyStart || ''}</td>
                    <td>${item.LaborWarrantyEnd || ''}</td>
                    <td>${item.Barcode || ''}</td>
                    <td>${item.InstallDate || ''}</td>
                    <td>${item.Notes || ''}</td>
                    <td>
                        <button type="button" class="btn btn-sm btn-primary" onclick="window.editEquipmentFromGlobalScope(${item.Id})">Edit</button>
                        <button type="button" class="btn btn-sm btn-danger" onclick="window.deleteEquipmentFromGlobalScope(${item.Id})">Delete</button>
                    </td>
                </tr>`);
        });
    }


    function openAddEquipmentModal() {
        $('#equipModalLabel').text('Add Equipment');
        $('#equipForm')[0].reset();
        $('#equipId').val('0');
        new bootstrap.Modal(document.getElementById('equipModal')).show();
    }

    window.editEquipmentFromGlobalScope = (id) => {
        const equip = equipmentData.find(e => e.Id === id);
        if (equip) {
            $('#equipModalLabel').text('Edit Equipment');
            $('#equipId').val(equip.Id);
            $('#SerialNumber').val(equip.SerialNumber);
            $('#equipType').val(equip.EquipmentType);
            $('#Make').val(equip.Make);
            $('#Model').val(equip.Model);
            $('#Barcode').val(equip.Barcode);
            $('#WarrantyStart').val(equip.WarrantyStart);
            $('#WarrantyEnd').val(equip.WarrantyEnd);
            $('#LaborWarrantyStart').val(equip.LaborWarrantyStart);
            $('#LaborWarrantyEnd').val(equip.LaborWarrantyEnd);
            $('#equipInstallDate').val(equip.InstallDate);
            $('#instruction').val(equip.Notes);
            new bootstrap.Modal(document.getElementById('equipModal')).show();
        }
    };

    window.deleteEquipmentFromGlobalScope = (id) => {
        if (confirm('Are you sure you want to delete this equipment?')) {
            $.ajax({
                url: 'CustomerDetails.aspx/DeleteEquipment',
                type: "POST",
                contentType: 'application/json',
                data: JSON.stringify({ equipmentId: id }),
                success: (rs) => {
                    if (rs.d) {
                        showToast('Equipment deleted successfully.');
                        loadEquipment();
                    } else {
                        showToast('Error deleting equipment.');
                    }
                },
                error: () => showToast('A server error occurred while deleting.')
            });
        }
    };

    function equipmentSave(event) {
        event.preventDefault();
        if ($("#SerialNumber").val().trim() === "" || $("#equipType").val().trim() === "") {
            showToast("Serial Number and Equipment Type are required.");
            return;
        }

        const equipment = {
            Id: parseInt($('#equipId').val()) || 0,
            SiteId: siteId,
            CustomerID: customerId,
            CustomerGuid: customerGuid,
            Notes: $('#instruction').val().trim(),
            WarrantyStart: $('#WarrantyStart').val().trim(),
            WarrantyEnd: $('#WarrantyEnd').val().trim(),
            LaborWarrantyStart: $('#LaborWarrantyStart').val().trim(),
            LaborWarrantyEnd: $('#LaborWarrantyEnd').val().trim(),
            InstallDate: $('#equipInstallDate').val().trim(),
            SerialNumber: $('#SerialNumber').val().trim(),
            EquipmentType: $('#equipType').val().trim(),
            Barcode: $('#Barcode').val().trim(),
            Model: $('#Model').val().trim(),
            Make: $('#Make').val().trim(),
        };

        $.ajax({
            type: "POST",
            url: "CustomerDetails.aspx/SaveEquipmentData",
            data: JSON.stringify({ equipment: equipment }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: (response) => {
                if (response.d) {
                    bootstrap.Modal.getInstance(document.getElementById('equipModal')).hide();
                    showToast(`Equipment ${equipment.Id > 0 ? 'updated' : 'saved'} successfully!`);
                    loadEquipment();
                } else {
                    showToast("Something went wrong!");
                }
            },
            error: () => showToast("Error saving equipment details.")
        });
    }


    function showToast(message) {
        const toastEl = document.getElementById('toast');
        if (toastEl) {
            toastEl.querySelector('.toast-body').textContent = message;
            new bootstrap.Toast(toastEl).show();
        }
    }

    function updatePagination(prefix, currentPage, totalItems, pageSize) {
        const totalPages = Math.ceil(totalItems / pageSize);
        $(`#${prefix}PageInfo`).text(`Page ${currentPage} of ${totalPages || 1}`);
        $(`#${prefix}Prev`).prop('disabled', currentPage <= 1);
        $(`#${prefix}Next`).prop('disabled', currentPage >= totalPages);
    }

    function parseMDY(str) {
        if (!str) return null;
        const [m, d, y] = str.split('/');
        return y && m && d ? new Date(y, m - 1, d) : null;
    }

    function parseYMD(str) {
        return str ? new Date(str) : null;
    }

    function sameDay(a, b) {
        return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
    }

    function updateDateFilterUI() {
        const mode = $('#invDateMode').val();
        $('#lblInvOn, #invOn').toggleClass('d-none', mode !== 'on');
        $('#lblInvFrom, #invFrom, #lblInvTo, #invTo').toggleClass('d-none', mode !== 'range');
    }

    function clearDateFilter() {
        $('#invDateMode').val('all');
        $('#invOn, #invFrom, #invTo').val('');
        updateDateFilterUI();
        applyFiltersInv();
    }

    function redirectToInvoiceModify(invNum, type, apptID) {
        const customerGuid = document.getElementById('MainContent_lblCustomerGuid')?.innerText;
        const siteId = document.getElementById('MainContent_lblSiteId')?.innerText;
        const customerIdInt = document.getElementById('MainContent_lblCustomerId')?.innerText;

        if (!customerGuid || !siteId || !customerIdInt) {
            alert('CRITICAL ERROR: Cannot open invoice. ID is missing from CustomerDetails page.');
            return;
        }

        const url = `InvoiceCreate.aspx?InvNum=${invNum}&cId=${customerGuid}&siteId=${siteId}&custId_int=${customerIdInt}&InType=${type}&AppID=${apptID}&FromCustomer=1`;

        window.location.href = url;
    }
});

function handleFileUpload(e) {
    const files = e.target.files;
    if (!files.length) {
        return;
    }

    for (let i = 0; i < files.length; i++) {
        const file = files[i];
        const fileObject = {
            id: Date.now() + i,
            name: file.name,
            type: file.type || 'Unknown',
            uploadDate: new Date(),
            url: URL.createObjectURL(file)
        };
        siteFiles.push(fileObject);
    }

    renderFilesTable();

    e.target.value = '';
}

function renderFilesTable() {
    const tbody = $('#filesTableBody').empty();

    if (siteFiles.length === 0) {
        tbody.append('<tr><td colspan="4">No files have been uploaded.</td></tr>');
        return;
    }

    const sortedFiles = [...siteFiles].sort((a, b) => b.uploadDate - a.uploadDate);

    sortedFiles.forEach(file => {
        const fileTypeIcon = getFileTypeIcon(file.type);
        const formattedDate = file.uploadDate.toLocaleDateString();

        tbody.append(`
                <tr>
                    <td><i class="${fileTypeIcon} me-2"></i>${file.name}</td>
                    <td>${file.type}</td>
                    <td>${formattedDate}</td>
                    <td>
                        <a href="${file.url}" target="_blank" class="btn btn-sm btn-outline-secondary" title="View File">
                            <i class="fas fa-eye"></i>
                        </a>
                        <button class="btn btn-sm btn-outline-primary" onclick="window.editFileName(${file.id})" title="Edit Name">
                            <i class="fas fa-pencil-alt"></i>
                        </button>
                        <button class="btn btn-sm btn-outline-danger" onclick="window.deleteFile(${file.id})" title="Delete File">
                            <i class="fas fa-trash"></i>
                        </button>
                    </td>
                </tr>
            `);
    });
}

function getFileTypeIcon(mimeType) {
    if (mimeType.startsWith('image/')) return 'fas fa-file-image';
    if (mimeType === 'application/pdf') return 'fas fa-file-pdf';
    if (mimeType === 'application/msword' || mimeType.includes('wordprocessingml')) return 'fas fa-file-word';
    if (mimeType === 'application/vnd.ms-excel' || mimeType.includes('spreadsheetml')) return 'fas fa-file-excel';
    return 'fas fa-file';
}

window.editFileName = (fileId) => {
    const file = siteFiles.find(f => f.id === fileId);
    if (!file) return;

    const newName = prompt("Enter the new file name:", file.name);
    if (newName && newName.trim() !== "") {
        file.name = newName.trim();
        renderFilesTable();
        showToast("File name updated.");
    }
};

window.deleteFile = (fileId) => {
    if (confirm("Are you sure you want to delete this file?")) {
        siteFiles = siteFiles.filter(f => f.id !== fileId);
        renderFilesTable();
        showToast("File deleted.");
    }
};
