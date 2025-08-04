let currentTemplate = null;
let formBuilder = null;
let serviceTypes = [];
let templateData = [];
let usageLogData = [];
let templateCurrentPage = 1;
let usageLogCurrentPage = 1;
let templatePageSize = 10;
let usageLogPageSize = 10;

// Initialize forms page
$(document).ready(function () {
    loadServiceTypes();
    loadTemplates();
    loadUsageLog();
    initializeTabs();
    initializeFormBuilder();

    $('#isAutoAssignEnabled').change(function () {
        if ($(this).is(':checked')) {
            $('#autoAssignSection').show();
            loadServiceTypesForAssignment();
        } else {
            $('#autoAssignSection').hide();
        }
    });
    $('[data-bs-toggle="tooltip"]').tooltip();
});

// Load service types from appointments
function loadServiceTypes() {
    $.ajax({
        type: "POST",
        url: "Forms.aspx/GetServiceTypes",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            if (response.d) {
                serviceTypes = response.d;
            }
        },
        error: function (xhr, status, error) {
            console.error('Error loading service types:', error);
        }
    });
}

// Load templates grid
function loadTemplates() {
    $.ajax({
        type: "POST",
        url: "Forms.aspx/GetAllTemplates",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            if (response.d) {
                templateData = response.d;
                populateTemplatesTable(templateData);

                // Set default page size
                $('#templatePageSize').val('10').trigger('change');
            }
        },
        error: function (xhr, status, error) {
            showAlert({
                icon: 'error',
                title: 'Error',
                text: 'Failed to load form templates',
                confirmButtonText: 'OK'
            });
        }
    });
}

// Populate templates table
function populateTemplatesTable(templates) {
    const tbody = $('#templatesTableBody');
    tbody.empty();

    const startIndex = (templateCurrentPage - 1) * templatePageSize;
    const endIndex = startIndex + templatePageSize;
    const paginatedTemplates = templates.slice(startIndex, endIndex);

    console.log(`Displaying templates ${startIndex + 1}-${endIndex} of ${templates.length}`);

    paginatedTemplates.forEach(function (template) {
        const row = `
            <tr>
                <td>
                    <strong>${template.TemplateName}</strong>
                    ${template.Description ? '<br><small class="text-muted">' + template.Description + '</small>' : ''}
                </td>
                <td>${template.Category || 'N/A'}</td>
                <td>
                    ${template.IsAutoAssignEnabled ?
                '<span class="badge badge-success">Yes</span>' :
                '<span class="badge badge-secondary">No</span>'}
                </td>
                <td>
                    ${template.RequireSignature ?
                '<i class="fa fa-check text-success"></i>' :
                '<i class="fa fa-times text-muted"></i>'}
                </td>
                <td>
                    ${template.IsActive ?
                '<span class="status-badge status-completed">Active</span>' :
                '<span class="status-badge status-pending">Inactive</span>'}
                </td>
                <td>${formatDate(template.CreatedDateTime)}</td>
                <td>
                    <button type="button" class="btn btn-sm btn-outline-primary" 
                            onclick="editTemplate(${template.Id})" 
                            data-bs-toggle="tooltip" 
                            data-bs-placement="top" 
                            title="Edit Template">
                        <i class="fa fa-edit"></i>
                    </button>
                    <button type="button" class="btn btn-sm btn-outline-info" 
                            onclick="openFormBuilder(${template.Id})" 
                            data-bs-toggle="tooltip" 
                            data-bs-placement="top" 
                            title="Open Form Builder">
                        <i class="fa fa-cogs"></i>
                    </button>
                    <button type="button" class="btn btn-sm btn-outline-secondary" 
                            onclick="duplicateTemplate(${template.Id})" 
                            data-bs-toggle="tooltip" 
                            data-bs-placement="top" 
                            title="Duplicate Template">
                        <i class="fa fa-copy"></i>
                    </button>
                    ${template.IsActive ?
                `<button type="button" class="btn btn-sm btn-outline-warning"
                                onclick="toggleTemplateStatus(${template.Id}, false)" 
                                data-bs-toggle="tooltip" 
                                data-bs-placement="top" 
                                title="Deactivate Template">
                            <i class="fa fa-pause"></i>
                        </button>` :
                `<button type="button" class="btn btn-sm btn-outline-success"
                                onclick="toggleTemplateStatus(${template.Id}, true)" 
                                data-bs-toggle="tooltip" 
                                data-bs-placement="top" 
                                title="Activate Template">
                            <i class="fa fa-play"></i>
                        </button>`
            }
                </td>
            </tr>
        `;
        tbody.append(row);
    });

    // Update pagination info
    updateTemplatePaginationInfo(templates.length);
    $('[data-bs-toggle="tooltip"]').tooltip();
}

// Add this new function to update pagination info
function updateTemplatePaginationInfo(totalItems) {
    const startItem = (templateCurrentPage - 1) * templatePageSize + 1;
    const endItem = Math.min(templateCurrentPage * templatePageSize, totalItems);

    $('#templatePageInfo').text(`Showing ${startItem}-${endItem} of ${totalItems}`);
    $('#templateRowCount').text(`${totalItems} templates`);

    // Update button states
    $('#templatePrevPage').toggleClass('disabled', templateCurrentPage === 1);
    $('#templateNextPage').toggleClass('disabled', endItem >= totalItems);

    console.log(`Pagination: Page ${templateCurrentPage}, Showing ${startItem}-${endItem} of ${totalItems}`);
}

// Setup template pagination
function setupTemplatePagination() {
    const totalPages = Math.ceil(templateData.length / templatePageSize);
    const pagination = $('#templatePagination');
    pagination.empty();

    if (totalPages <= 1) return;

    // Previous button
    pagination.append(`
        <li class="page-item ${templateCurrentPage === 1 ? 'disabled' : ''}">
            <a class="page-link" href="#" onclick="goToTemplatePage(${templateCurrentPage - 1})">Previous</a>
        </li>
    `);

    // Page numbers
    for (let i = 1; i <= totalPages; i++) {
        pagination.append(`
            <li class="page-item ${i === templateCurrentPage ? 'active' : ''}">
                <a class="page-link" href="#" onclick="goToTemplatePage(${i})">${i}</a>
            </li>
        `);
    }

    // Next button
    pagination.append(`
        <li class="page-item ${templateCurrentPage === totalPages ? 'disabled' : ''}">
            <a class="page-link" href="#" onclick="goToTemplatePage(${templateCurrentPage + 1})">Next</a>
        </li>
    `);
}

// Go to template page
function goToTemplatePage(page) {
    const totalPages = Math.ceil(templateData.length / templatePageSize);
    if (page < 1 || page > totalPages) return;

    templateCurrentPage = page;
    const filteredData = searchTemplates(true);
    populateTemplatesTable(filteredData);
}

function changeTemplatePageSize() {
    templatePageSize = parseInt($('#templatePageSize').val());
    templateCurrentPage = 1;
    const filteredData = searchTemplates(true);
    populateTemplatesTable(filteredData);
}

function searchTemplates(returnFiltered = false) {
    const searchTerm = $('#templateSearch').val().toLowerCase();
    const filteredTemplates = templateData.filter(template =>
        template.TemplateName.toLowerCase().includes(searchTerm) ||
        (template.Description && template.Description.toLowerCase().includes(searchTerm)) ||
        (template.Category && template.Category.toLowerCase().includes(searchTerm))
    );

    if (returnFiltered) return filteredTemplates;

    templateCurrentPage = 1;
    populateTemplatesTable(filteredTemplates);
}

// Change template page size
function changeTemplatePageSize() {
    templatePageSize = parseInt($('#templatePageSize').val());
    templateCurrentPage = 1;
    const filteredData = searchTemplates(true);
    populateTemplatesTable(filteredData);
    setupTemplatePagination();
}

// Search templates
function searchTemplates(returnFiltered = false) {
    const searchTerm = $('#templateSearch').val().toLowerCase();
    const filteredTemplates = templateData.filter(template =>
        template.TemplateName.toLowerCase().includes(searchTerm) ||
        (template.Description && template.Description.toLowerCase().includes(searchTerm)) ||
        (template.Category && template.Category.toLowerCase().includes(searchTerm))
    );

    if (returnFiltered) return filteredTemplates;

    templateCurrentPage = 1;
    populateTemplatesTable(filteredTemplates);
    setupTemplatePagination();
}

// Load usage log
function loadUsageLog() {
    $.ajax({
        type: "POST",
        url: "Forms.aspx/GetUsageLog",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            if (response.d) {
                usageLogData = response.d;
                populateUsageLogTable(usageLogData);
                setupUsageLogPagination();
            }
        },
        error: function (xhr, status, error) {
            console.error('Error loading usage log:', error);
        }
    });
}

// Populate usage log table
function populateUsageLogTable(logs) {
    const tbody = $('#usageLogTableBody');
    tbody.empty();

    const startIndex = (usageLogCurrentPage - 1) * usageLogPageSize;
    const endIndex = startIndex + usageLogPageSize;
    const paginatedLogs = logs.slice(startIndex, endIndex);

    paginatedLogs.forEach(function (log) {
        const row = `
            <tr>
                <td>${formatDateTime(log.ActionDateTime)}</td>
                <td>${log.TemplateName || 'N/A'}</td>
                <td>${log.AppointmentId || 'N/A'}</td>
                <td>
                    <span class="status-badge status-${log.Action.toLowerCase()}">${log.Action}</span>
                </td>
                <td>${log.PerformedBy || 'System'}</td>
            </tr>
        `;
        tbody.append(row);
    });
}

// Setup usage log pagination
function setupUsageLogPagination() {
    const totalPages = Math.ceil(usageLogData.length / usageLogPageSize);
    const pagination = $('#usageLogPagination');
    pagination.empty();

    if (totalPages <= 1) return;

    // Previous button
    pagination.append(`
        <li class="page-item ${usageLogCurrentPage === 1 ? 'disabled' : ''}">
            <a class="page-link" href="#" onclick="goToUsageLogPage(${usageLogCurrentPage - 1})">Previous</a>
        </li>
    `);

    // Page numbers
    for (let i = 1; i <= totalPages; i++) {
        pagination.append(`
            <li class="page-item ${i === usageLogCurrentPage ? 'active' : ''}">
                <a class="page-link" href="#" onclick="goToUsageLogPage(${i})">${i}</a>
            </li>
        `);
    }

    // Next button
    pagination.append(`
        <li class="page-item ${usageLogCurrentPage === totalPages ? 'disabled' : ''}">
            <a class="page-link" href="#" onclick="goToUsageLogPage(${usageLogCurrentPage + 1})">Next</a>
        </li>
    `);
}

// Go to usage log page
function goToUsageLogPage(page) {
    if (page < 1 || page > Math.ceil(usageLogData.length / usageLogPageSize)) return;
    usageLogCurrentPage = page;
    const filteredData = searchUsageLog(true);
    populateUsageLogTable(filteredData);
    setupUsageLogPagination();
}

// Change usage log page size
function changeUsageLogPageSize() {
    usageLogPageSize = parseInt($('#usageLogPageSize').val());
    usageLogCurrentPage = 1;
    const filteredData = searchUsageLog(true);
    populateUsageLogTable(filteredData);
    setupUsageLogPagination();
}

// Search usage log
function searchUsageLog(returnFiltered = false) {
    const searchTerm = $('#usageLogSearch').val().toLowerCase();
    const filteredLogs = usageLogData.filter(log =>
        (log.TemplateName && log.TemplateName.toLowerCase().includes(searchTerm)) ||
        (log.AppointmentId && log.AppointmentId.toString().includes(searchTerm)) ||
        (log.Action && log.Action.toLowerCase().includes(searchTerm)) ||
        (log.PerformedBy && log.PerformedBy.toLowerCase().includes(searchTerm))
    );

    if (returnFiltered) return filteredLogs;

    usageLogCurrentPage = 1;
    populateUsageLogTable(filteredLogs);
    setupUsageLogPagination();
}

// Open new template modal
function openNewTemplateModal() {
    currentTemplate = null;
    $('#templateModalTitle').text('New Form Template');
    $('#templateForm')[0].reset();
    $('#templateId').val('0');
    $('#isActive').prop('checked', true);
    $('#autoAssignSection').hide();
    var modal = new bootstrap.Modal(document.getElementById('templateModal'));
    modal.show();
}

// Edit template
function editTemplate(templateId) {
    $.ajax({
        type: "POST",
        url: "Forms.aspx/GetTemplate",
        data: JSON.stringify({ templateId: templateId }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            if (response.d) {
                currentTemplate = response.d;
                populateTemplateForm(response.d);
                $('#templateModalTitle').text('Edit Form Template');
                var modal = new bootstrap.Modal(document.getElementById('templateModal'));
                modal.show();
            }
        },
        error: function (xhr, status, error) {
            showAlert({
                icon: 'error',
                title: 'Error',
                text: 'Failed to load template details',
                confirmButtonText: 'OK'
            });
        }
    });
}

// Populate template form
function populateTemplateForm(template) {
    $('#templateId').val(template.Id);
    $('#templateName').val(template.TemplateName);
    $('#description').val(template.Description);
    $('#category').val(template.Category);
    $('#requireSignature').prop('checked', template.RequireSignature);
    $('#requireTip').prop('checked', template.RequireTip);
    $('#isActive').prop('checked', template.IsActive);
    $('#isAutoAssignEnabled').prop('checked', template.IsAutoAssignEnabled);

    if (template.IsAutoAssignEnabled) {
        $('#autoAssignSection').show();
        loadServiceTypesForAssignment(template.AutoAssignServiceTypes);
    }
}

// Load service types for assignment
function loadServiceTypesForAssignment(selectedTypes) {
    const container = $('#serviceTypeCheckboxes');
    container.empty();

    let selected = [];
    if (selectedTypes) {
        try {
            selected = JSON.parse(selectedTypes);
        } catch (e) {
            selected = [];
        }
    }

    serviceTypes.forEach(function (serviceType) {
        const isChecked = selected.includes(serviceType);
        const checkbox = `
            <div class="form-check">
                <input class="form-check-input" type="checkbox" 
                       id="serviceType_${serviceType}" 
                       name="serviceTypes" 
                       value="${serviceType}" 
                       ${isChecked ? 'checked' : ''}>
                <label class="form-check-label" for="serviceType_${serviceType}">
                    ${serviceType}
                </label>
            </div>
        `;
        container.append(checkbox);
    });
}

// Save template
function saveTemplate() {
    const form = $('#templateForm')[0];
    if (!form.checkValidity()) {
        form.reportValidity();
        return;
    }

    const selectedServiceTypes = [];
    $('input[name="serviceTypes"]:checked').each(function () {
        selectedServiceTypes.push($(this).val());
    });

    const templateData = {
        Id: parseInt($('#templateId').val()) || 0,
        TemplateName: $('#templateName').val(),
        Description: $('#description').val(),
        Category: $('#category').val(),
        RequireSignature: $('#requireSignature').is(':checked'),
        RequireTip: $('#requireTip').is(':checked'),
        IsActive: $('#isActive').is(':checked'),
        IsAutoAssignEnabled: $('#isAutoAssignEnabled').is(':checked'),
        AutoAssignServiceTypes: JSON.stringify(selectedServiceTypes)
    };

    $.ajax({
        type: "POST",
        url: "Forms.aspx/SaveTemplate",
        data: JSON.stringify({ template: templateData }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            if (response.d && response.d > 0) {
                showAlert({
                    icon: 'success',
                    title: 'Success',
                    text: 'Template saved successfully!',
                    timer: 2000
                });
                bootstrap.Modal.getInstance(document.getElementById('templateModal')).hide();
                loadTemplates();
            } else {
                showAlert({
                    icon: 'error',
                    title: 'Error',
                    text: 'Failed to save template',
                    confirmButtonText: 'OK'
                });
            }
        },
        error: function (xhr, status, error) {
            showAlert({
                icon: 'error',
                title: 'Error',
                text: 'Failed to save template: ' + error,
                confirmButtonText: 'OK'
            });
        }
    });
}

// Toggle template status
function toggleTemplateStatus(templateId, isActive) {
    $.ajax({
        type: "POST",
        url: "Forms.aspx/ToggleTemplateStatus",
        data: JSON.stringify({ templateId: templateId, isActive: isActive }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            if (response.d) {
                loadTemplates();
            }
        },
        error: function (xhr, status, error) {
            showAlert({
                icon: 'error',
                title: 'Error',
                text: 'Failed to update template status',
                confirmButtonText: 'OK'
            });
        }
    });
}

// Duplicate template
function duplicateTemplate(templateId) {
    $.ajax({
        type: "POST",
        url: "Forms.aspx/DuplicateTemplate",
        data: JSON.stringify({ templateId: templateId }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            if (response.d > 0) {
                showAlert({
                    icon: 'success',
                    title: 'Success',
                    text: 'Template duplicated successfully!',
                    timer: 2000
                });
                loadTemplates();
            }
        },
        error: function (xhr, status, error) {
            showAlert({
                icon: 'error',
                title: 'Error',
                text: 'Failed to duplicate template',
                confirmButtonText: 'OK'
            });
        }
    });
}

// Form Builder Functions
function openFormBuilder(templateId) {
    currentTemplate = { Id: templateId };
    $('#formBuilderModal').modal('show');
    loadFormStructure(templateId);
}

function initializeFormBuilder() {
    initializeDragAndDrop();
}

function initializeDragAndDrop() {
    $(document).on('dragstart', '.field-type', function (e) {
        e.originalEvent.dataTransfer.setData('text/plain', $(this).data('type'));
    });

    $('#formBuilder').on('dragover', function (e) {
        e.preventDefault();
        $(this).addClass('drag-over');
    });

    $('#formBuilder').on('dragleave', function (e) {
        $(this).removeClass('drag-over');
    });

    $('#formBuilder').on('drop', function (e) {
        e.preventDefault();
        $(this).removeClass('drag-over');

        const fieldType = e.originalEvent.dataTransfer.getData('text/plain');
        addFormField(fieldType);
    });
}

function addFormField(fieldType) {
    const fieldId = 'field_' + Date.now();
    const fieldHtml = generateFieldHtml(fieldType, fieldId);

    if ($('#formBuilder .drop-zone').length > 0) {
        $('#formBuilder').empty();
    }

    $('#formBuilder').append(fieldHtml);
}

function generateFieldHtml(type, fieldId) {
    const fieldConfig = {
        text: { label: 'Text Input', icon: 'fa-font', input: '<input type="text" class="form-control" placeholder="Enter text">' },
        textarea: { label: 'Text Area', icon: 'fa-align-left', input: '<textarea class="form-control" rows="3" placeholder="Enter text"></textarea>' },
        number: { label: 'Number', icon: 'fa-hashtag', input: '<input type="number" class="form-control" placeholder="Enter number">' },
        date: { label: 'Date', icon: 'fa-calendar', input: '<input type="date" class="form-control">' },
        dropdown: { label: 'Dropdown', icon: 'fa-caret-down', input: '<select class="form-control"><option>Option 1</option><option>Option 2</option></select>' },
        checkbox: { label: 'Checkbox', icon: 'fa-check-square', input: '<div class="form-check"><input type="checkbox" class="form-check-input"><label class="form-check-label">Check this option</label></div>' },
        radio: { label: 'Radio Button', icon: 'fa-dot-circle', input: '<div class="form-check"><input type="radio" class="form-check-input" name="radio_' + fieldId + '"><label class="form-check-label">Option 1</label></div>' },
        signature: { label: 'Signature', icon: 'fa-pencil', input: '<div class="signature-pad" style="border: 1px solid #ddd; height: 150px; display: flex; align-items: center; justify-content: center;">Signature Area</div>' }
    };

    const config = fieldConfig[type];
    if (!config) return '';

    return `
        <div class="form-field" data-field-id="${fieldId}" data-field-type="${type}" onclick="selectField('${fieldId}')">
            <div class="field-controls">
                <button type="button" class="btn btn-sm btn-outline-primary" onclick="editField('${fieldId}')">
                    <i class="fa fa-edit"></i>
                </button>
                <button type="button" class="btn btn-sm btn-outline-danger" onclick="removeField('${fieldId}')">
                    <i class="fa fa-trash"></i>
                </button>
            </div>
            <div class="form-group">
                <label><i class="fa ${config.icon}"></i> ${config.label}</label>
                ${config.input}
            </div>
        </div>
    `;
}

// Utility functions
function formatDate(dateString) {
    if (!dateString) return 'N/A';
    const date = new Date(dateString);
    return date.toLocaleDateString();
}

function formatDateTime(dateString) {
    if (!dateString) return 'N/A';
    const date = new Date(dateString);
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
}

function showAlert(options) {
    if (typeof Swal !== 'undefined') {
        Swal.fire(options);
    } else {
        alert(options.text || options.title || 'Alert');
    }
}

window.FormsManager = {
    getAutoAssignedForms: function (serviceType) {
        return new Promise((resolve, reject) => {
            $.ajax({
                type: "POST",
                url: "Forms.aspx/GetAutoAssignedForms",
                data: JSON.stringify({ serviceType: serviceType }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    resolve(response.d || []);
                },
                error: function (xhr, status, error) {
                    reject(error);
                }
            });
        });
    },

    createFormInstance: function (templateId, appointmentId, customerId) {
        return new Promise((resolve, reject) => {
            $.ajax({
                type: "POST",
                url: "Forms.aspx/CreateFormInstance",
                data: JSON.stringify({
                    templateId: templateId,
                    appointmentId: appointmentId,
                    customerId: customerId
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    resolve(response.d);
                },
                error: function (xhr, status, error) {
                    reject(error);
                }
            });
        });
    }
};
// Tab System
function initializeTabs() {
    // Set up tab click handlers
    document.querySelectorAll('.tabs-nav__btn').forEach(button => {
        button.addEventListener('click', function () {
            const tabId = this.getAttribute('data-tab-target');
            switchTab(tabId);
        });
    });

    // Activate first tab by default
    switchTab('templates-section');
}

function switchTab(tabId) {
    // Update tab buttons
    document.querySelectorAll('.tabs-nav__btn').forEach(btn => {
        if (btn.getAttribute('data-tab-target') === tabId) {
            btn.classList.add('is-active');
            btn.setAttribute('aria-selected', 'true');
        } else {
            btn.classList.remove('is-active');
            btn.setAttribute('aria-selected', 'false');
        }
    });

    // Update tab content
    document.querySelectorAll('.tabs-content').forEach(content => {
        if (content.id === tabId) {
            content.classList.add('is-active');
            content.hidden = false;
        } else {
            content.classList.remove('is-active');
            content.hidden = true;
        }
    });

    // Load data if needed
    if (tabId === 'templates-section' && templateData.length === 0) {
        loadTemplates();
    } else if (tabId === 'usage-log-section' && usageLogData.length === 0) {
        loadUsageLog();
    }
}