// Forms Management JavaScript
let currentTemplate = null;
let formBuilder = null;
let serviceTypes = [];

// Initialize forms page
$(document).ready(function() {
    loadServiceTypes();
    loadTemplates();
    loadUsageLog();
    initializeFormBuilder();
    
    // Auto-assign checkbox toggle
    $('#isAutoAssignEnabled').change(function() {
        if ($(this).is(':checked')) {
            $('#autoAssignSection').show();
            loadServiceTypesForAssignment();
        } else {
            $('#autoAssignSection').hide();
        }
    });
});

// Load service types from appointments
function loadServiceTypes() {
    $.ajax({
        type: "POST",
        url: "Forms.aspx/GetServiceTypes",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function(response) {
            if (response.d) {
                serviceTypes = response.d;
            }
        },
        error: function(xhr, status, error) {
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
        success: function(response) {
            if (response.d) {
                populateTemplatesTable(response.d);
            }
        },
        error: function(xhr, status, error) {
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
    
    templates.forEach(function(template) {
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
                    <button class="btn btn-sm btn-outline-primary" onclick="editTemplate(${template.Id})">
                        <i class="fa fa-edit"></i>
                    </button>
                    <button class="btn btn-sm btn-outline-info" onclick="openFormBuilder(${template.Id})">
                        <i class="fa fa-cogs"></i>
                    </button>
                    <button class="btn btn-sm btn-outline-secondary" onclick="duplicateTemplate(${template.Id})">
                        <i class="fa fa-copy"></i>
                    </button>
                    ${template.IsActive ? 
                        `<button class="btn btn-sm btn-outline-warning" onclick="toggleTemplateStatus(${template.Id}, false)">
                            <i class="fa fa-pause"></i>
                        </button>` :
                        `<button class="btn btn-sm btn-outline-success" onclick="toggleTemplateStatus(${template.Id}, true)">
                            <i class="fa fa-play"></i>
                        </button>`
                    }
                </td>
            </tr>
        `;
        tbody.append(row);
    });
}

// Load usage log
function loadUsageLog() {
    $.ajax({
        type: "POST",
        url: "Forms.aspx/GetUsageLog",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function(response) {
            if (response.d) {
                populateUsageLogTable(response.d);
            }
        },
        error: function(xhr, status, error) {
            console.error('Error loading usage log:', error);
        }
    });
}

// Populate usage log table
function populateUsageLogTable(logs) {
    const tbody = $('#usageLogTableBody');
    tbody.empty();
    
    logs.slice(0, 20).forEach(function(log) { // Show only recent 20 entries
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
        success: function(response) {
            if (response.d) {
                currentTemplate = response.d;
                populateTemplateForm(response.d);
                $('#templateModalTitle').text('Edit Form Template');
                var modal = new bootstrap.Modal(document.getElementById('templateModal'));
                modal.show();
            }
        },
        error: function(xhr, status, error) {
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
    
    serviceTypes.forEach(function(serviceType) {
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
    
    // Get selected service types
    const selectedServiceTypes = [];
    $('input[name="serviceTypes"]:checked').each(function() {
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
        success: function(response) {
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
        error: function(xhr, status, error) {
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
        success: function(response) {
            if (response.d) {
                loadTemplates();
            }
        },
        error: function(xhr, status, error) {
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
        success: function(response) {
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
        error: function(xhr, status, error) {
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
    // Initialize drag and drop for form builder
    initializeDragAndDrop();
}

function initializeDragAndDrop() {
    // Field types drag start
    $(document).on('dragstart', '.field-type', function(e) {
        e.originalEvent.dataTransfer.setData('text/plain', $(this).data('type'));
    });
    
    // Form builder drop zone
    $('#formBuilder').on('dragover', function(e) {
        e.preventDefault();
        $(this).addClass('drag-over');
    });
    
    $('#formBuilder').on('dragleave', function(e) {
        $(this).removeClass('drag-over');
    });
    
    $('#formBuilder').on('drop', function(e) {
        e.preventDefault();
        $(this).removeClass('drag-over');
        
        const fieldType = e.originalEvent.dataTransfer.getData('text/plain');
        addFormField(fieldType);
    });
}

// Add more form builder functions...
function addFormField(fieldType) {
    const fieldId = 'field_' + Date.now();
    const fieldHtml = generateFieldHtml(fieldType, fieldId);
    
    // Remove drop zone if this is the first field
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
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
}

// showAlert function (fallback)
function showAlert(options) {
    if (typeof Swal !== 'undefined') {
        Swal.fire(options);
    } else {
        alert(options.text || options.title || 'Alert');
    }
}

// Export functions for appointment integration
window.FormsManager = {
    getAutoAssignedForms: function(serviceType) {
        return new Promise((resolve, reject) => {
            $.ajax({
                type: "POST",
                url: "Forms.aspx/GetAutoAssignedForms",
                data: JSON.stringify({ serviceType: serviceType }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function(response) {
                    resolve(response.d || []);
                },
                error: function(xhr, status, error) {
                    reject(error);
                }
            });
        });
    },
    
    createFormInstance: function(templateId, appointmentId, customerId) {
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
                success: function(response) {
                    resolve(response.d);
                },
                error: function(xhr, status, error) {
                    reject(error);
                }
            });
        });
    }
};