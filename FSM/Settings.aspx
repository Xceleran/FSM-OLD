<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Settings.aspx.cs" Inherits="FSM.Settings" MasterPageFile="~/FSM.master" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    
    <style>
        /* Custom Fields Styles */
        .card { box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15); margin-bottom: 1.5rem; }
        .list-group-item { transition: all 0.3s ease; }
        .list-group-item:hover { background-color: #f8f9fa; }
        .form-check-input:checked { background-color: #0d6efd; border-color: #0d6efd; }
        .preview-container { background-color: #f8f9fa; border-radius: 0.375rem; min-height: 150px; padding: 1rem; }
        .badge { font-size: 0.75em; }
        .option-input-group { margin-bottom: 0.5rem; }
        .modal-content { border: none; border-radius: 0.5rem; }
        .modal-header { background-color: #f8f9fa; border-bottom: 1px solid #dee2e6; border-top-left-radius: 0.5rem; border-top-right-radius: 0.5rem; }
        .list-group-placeholder { border: 2px dashed #ccc; padding: 2rem; text-align: center; color: #6c757d; }
        
        /* Tab Styles */
        .nav-tabs { border-bottom: 2px solid #dee2e6; margin-bottom: 2rem; }
        .nav-tabs .nav-link { border: none; border-radius: 0; padding: 1rem 1.5rem; font-weight: 500; color: #6c757d; transition: all 0.3s ease; }
        .nav-tabs .nav-link:hover { border-color: transparent; color: #0d6efd; background-color: #f8f9fa; }
        .nav-tabs .nav-link.active { color: #0d6efd; background-color: transparent; border-bottom: 2px solid #0d6efd; }
        
        /* SMS Settings Styles */
        .sms-section { margin-bottom: 2rem; }
        .sms-legend { font-size: 1.1rem; font-weight: 600; color: #495057; margin-bottom: 1rem; border-bottom: 1px solid #dee2e6; padding-bottom: 0.5rem; }
        .sms-checkbox-container { margin-bottom: 1rem; }
        .sms-textarea { resize: vertical; min-height: 120px; }
        .placeholder-info { background-color: #f8f9fa; border-radius: 0.375rem; padding: 1.5rem; margin-top: 2rem; }
        .placeholder-info small { display: block; margin-bottom: 0.25rem; color: #6c757d; }
    </style>

    <div class="container-fluid py-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
        
        </div>
        
        <!-- Tab Navigation -->
        <ul class="nav nav-tabs" id="settingsTabs" role="tablist">
            <li class="nav-item" role="presentation">
                <button class="nav-link active" id="custom-fields-tab" data-bs-toggle="tab" data-bs-target="#custom-fields" type="button" role="tab" aria-controls="custom-fields" aria-selected="true">
                    <i class="bi bi-ui-checks me-2"></i>Custom Fields
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="sms-settings-tab" data-bs-toggle="tab" data-bs-target="#sms-settings" type="button" role="tab" aria-controls="sms-settings" aria-selected="false">
                    <i class="bi bi-chat-text me-2"></i>SMS Settings
                </button>
            </li>
        </ul>

        <!-- Tab Content -->
        <div class="tab-content" id="settingsTabContent">
            
            <!-- Custom Fields Tab -->
            <div class="tab-pane fade show active" id="custom-fields" role="tabpanel" aria-labelledby="custom-fields-tab">
                <div class="d-flex justify-content-between align-items-center mb-4">             
                    <div>
                        <button type="button" id="btnCreateNew" class="btn btn-success">
                            <i class="bi bi-plus-circle me-1"></i> Create New Field
                        </button>
                    </div>
                </div>
                
                <div class="card">
                    <div class="card-body">
                        <ul id="customFieldsList" class="list-group">
                            <!-- Fields will be rendered here by JavaScript -->
                        </ul>
                    </div>
                </div>
            </div>

            <!-- SMS Settings Tab -->
            <div class="tab-pane fade" id="sms-settings" role="tabpanel" aria-labelledby="sms-settings-tab">
                <div class="card">
                    <div class="card-header bg-light">
                        <div class="card-title">
                            <h4 class="mb-0">Check the types of communications you want to send to your customers</h4>
                        </div>
                    </div>
                    
                    <input type="hidden" id="hdCompanyID" name="hdCompanyID" runat="server" />
                    
                    <div class="card-body">
                        <div class="row">
                            <div class="col-12 col-md-6">
                                
                                <!-- Pending Status -->
                                <div class="sms-section">
                                    <div class="sms-legend">Appointment Status: <strong>Pending</strong></div>
                                    <div class="sms-checkbox-container">
                                        <div class="form-check">
                                            <asp:CheckBox ID="PendingYN" runat="server" CssClass="form-check-input" />
                                            <label class="form-check-label" for="PendingYN">Add Yes/No Option</label>
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Message Body</label>
                                        <textarea id="txtPending" rows="5" runat="server" class="form-control sms-textarea"></textarea>
                                    </div>
                                </div>

                                <!-- Cancelled Status -->
                                <div class="sms-section">
                                    <div class="sms-legend">Appointment Status: <strong>Cancelled</strong></div>
                                    <div class="sms-checkbox-container">
                                        <div class="form-check">
                                            <asp:CheckBox ID="CancelledYN" runat="server" CssClass="form-check-input" />
                                            <label class="form-check-label" for="CancelledYN">Add Yes/No Option</label>
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Message Body</label>
                                        <textarea id="txtCancelled" rows="5" runat="server" class="form-control sms-textarea"></textarea>
                                    </div>
                                </div>

                                <!-- Installation In Progress Status -->
                                <div class="sms-section">
                                    <div class="sms-legend">Appointment Status: <strong>Installation In Progress</strong></div>
                                    <div class="sms-checkbox-container">
                                        <div class="form-check">
                                            <asp:CheckBox ID="ProgressYN" runat="server" CssClass="form-check-input" />
                                            <label class="form-check-label" for="ProgressYN">Add Yes/No Option</label>
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Message Body</label>
                                        <textarea id="txtProgress" rows="5" runat="server" class="form-control sms-textarea"></textarea>
                                    </div>
                                </div>

                            </div>

                            <div class="col-12 col-md-6">
                                
                                <!-- Scheduled Status -->
                                <div class="sms-section">
                                    <div class="sms-legend">Appointment Status: <strong>Scheduled</strong></div>
                                    <div class="sms-checkbox-container">
                                        <div class="form-check">
                                            <asp:CheckBox ID="ScheduledYN" runat="server" CssClass="form-check-input" />
                                            <label class="form-check-label" for="ScheduledYN">Add Yes/No Option</label>
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Message Body</label>
                                        <textarea id="txtScheduled" rows="5" runat="server" class="form-control sms-textarea"></textarea>
                                    </div>
                                </div>

                                <!-- Closed Status -->
                                <div class="sms-section">
                                    <div class="sms-legend">Appointment Status: <strong>Closed</strong></div>
                                    <div class="sms-checkbox-container">
                                        <div class="form-check">
                                            <asp:CheckBox ID="ClosedYN" runat="server" CssClass="form-check-input" />
                                            <label class="form-check-label" for="ClosedYN">Add Yes/No Option</label>
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Message Body</label>
                                        <textarea id="txtClosed" rows="5" runat="server" class="form-control sms-textarea"></textarea>
                                    </div>
                                </div>

                                <!-- Completed Status -->
                                <div class="sms-section">
                                    <div class="sms-legend">Appointment Status: <strong>Completed</strong></div>
                                    <div class="sms-checkbox-container">
                                        <div class="form-check">
                                            <asp:CheckBox ID="CompletedYN" runat="server" CssClass="form-check-input" />
                                            <label class="form-check-label" for="CompletedYN">Add Yes/No Option</label>
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Message Body</label>
                                        <textarea id="txtCompleted" rows="5" runat="server" class="form-control sms-textarea"></textarea>
                                    </div>
                                </div>

                            </div>
                        </div>

                        <div class="row">
                            <div class="col-12 col-md-3">
                                <asp:Button ID="SubmitData" runat="server" Text="Save SMS Settings" CssClass="btn btn-success w-100" OnClick="SubmitData_Click"/>
                            </div>
                        </div>

                        <!-- Placeholder Information -->
                        <div class="placeholder-info">
                            <h6 class="mb-3">Available Placeholders:</h6>
                            <div class="row">
                                <div class="col-md-6">
                                    <small>[First Name] = Customer First Name</small>
                                    <small>[Last Name] = Customer Last Name</small>
                                    <small>[Full Name] = Customer Full Name</small>
                                    <small>[Title] = Customer Title</small>
                                </div>
                                <div class="col-md-6">
                                    <small>[Job Title] = Customer Job Title</small>
                                    <small>[Company Name] = Company Full Name</small>
                                    <small>[Time] = Appointment Time</small>
                                    <small>[Date] = Appointment Date</small>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Custom Fields Modal -->
    <div class="modal fade" id="addCustomFieldModal" tabindex="-1" aria-labelledby="addCustomFieldModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="addCustomFieldModalLabel">Create Custom Field</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="hfFieldId" value="">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="fieldName" class="form-label">Field Name *</label>
                                <input type="text" id="fieldName" class="form-control" placeholder="e.g., Gate Code">
                            </div>
                            <div class="mb-3">
                                <label for="fieldType" class="form-label">Field Type</label>
                                <select id="fieldType" class="form-select">
                                    <option value="text">Text</option>
                                    <option value="number">Number</option>
                                    <option value="date">Date</option>
                                    <option value="dropdown">Drop-down List</option>
                                    <option value="checklist">Checklist</option>
                                </select>
                            </div>
                            <div class="mb-3" id="divOptions" style="display: none;">
                                <label class="form-label">Field Options *</label>
                                <div id="optionsContainer" class="p-3 border rounded bg-light"></div>
                                <button type="button" id="btnAddOption" class="btn btn-link text-success p-0 mt-2">
                                    <i class="bi bi-plus-circle"></i> Add New Option
                                </button>
                            </div>
                            <div class="form-check form-switch mt-3">
                                <input class="form-check-input" type="checkbox" id="isActive" checked>
                                <label class="form-check-label" for="isActive">Field is Active</label>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mt-4" id="previewSection">
                                <label class="form-label">Preview:</label>
                                <div id="fieldPreview" class="preview-container"></div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" id="btnSave" class="btn btn-primary">Save Field</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            // Initialize tabs
            const triggerTabList = document.querySelectorAll('#settingsTabs button');
            triggerTabList.forEach(triggerEl => {
                const tabTrigger = new bootstrap.Tab(triggerEl);
                triggerEl.addEventListener('click', event => {
                    event.preventDefault();
                    tabTrigger.show();
                });
            });

            // Custom Fields JavaScript
            initializeCustomFields();
        });

        function initializeCustomFields() {
            // --- Global Elements ---
            const modalEl = document.getElementById('addCustomFieldModal');
            const modalInstance = new bootstrap.Modal(modalEl);
            const customFieldsList = document.getElementById('customFieldsList');

            // --- Modal Form Elements ---
            const modalTitle = document.getElementById('addCustomFieldModalLabel');
            const hfFieldId = document.getElementById('hfFieldId');
            const fieldName = document.getElementById('fieldName');
            const fieldType = document.getElementById('fieldType');
            const isActive = document.getElementById('isActive');
            const divOptions = document.getElementById('divOptions');
            const optionsContainer = document.getElementById('optionsContainer');
            const btnAddOption = document.getElementById('btnAddOption');
            const fieldPreview = document.getElementById('fieldPreview');

            // --- Main Function to Fetch and Render Fields ---
            function refreshFieldsList() {
                customFieldsList.innerHTML = '<div class="list-group-placeholder">Loading fields...</div>';
                PageMethods.GetFields(onGetFieldsSuccess, onApiError);
            }

            function onGetFieldsSuccess(response) {
                if (response.success) {
                    renderFields(response.data);
                } else {
                    showError(response.message);
                    customFieldsList.innerHTML = '<div class="list-group-placeholder">Could not load fields.</div>';
                }
            }

            function renderFields(fields) {
                customFieldsList.innerHTML = '';
                if (fields.length === 0) {
                    customFieldsList.innerHTML = '<div class="list-group-placeholder">No custom fields found. Click "Create New Field" to get started.</div>';
                    return;
                }
                fields.forEach(field => {
                    const activeStatus = field.IsActive ? '' : "<span class='badge bg-light text-dark ms-2'>Inactive</span>";
                    const toggleButton = field.IsActive
                        ? `<button type="button" class="btn btn-sm btn-outline-warning me-2 active-btn" data-fieldid="${field.FieldId}"><i class="bi bi-eye-slash-fill me-1"></i> Deactivate</button>`
                        : `<button type="button" class="btn btn-sm btn-outline-info me-2 active-btn" data-fieldid="${field.FieldId}"><i class="bi bi-eye-fill me-1"></i> Activate</button>`;

                    const li = document.createElement('li');
                    li.className = 'list-group-item d-flex justify-content-between align-items-center';
                    li.innerHTML = `
                        <div>
                            <i class="bi bi-grip-vertical text-muted me-2"></i>
                            <strong>${escapeHtml(field.FieldName)}</strong>
                            <span class="badge bg-secondary ms-2">${escapeHtml(field.FieldType)}</span>
                            ${activeStatus}
                        </div>
                        <div>
                            <button type="button" class="btn btn-sm btn-outline-primary me-2 edit-btn" data-fieldid="${field.FieldId}">
                                <i class="bi bi-pencil-fill me-1"></i> Edit
                            </button>
                            ${toggleButton}
                            <button type="button" class="btn btn-sm btn-outline-danger delete-btn" data-fieldid="${field.FieldId}">
                                <i class="bi bi-trash-fill me-1"></i> Delete
                            </button>
                        </div>`;
                    customFieldsList.appendChild(li);
                });
            }

            // --- Event Listeners ---
            document.getElementById('btnCreateNew').addEventListener('click', () => {
                clearModalForm();
                modalTitle.textContent = 'Create Custom Field';
                modalInstance.show();
            });

            document.getElementById('btnSave').addEventListener('click', () => {
                if (validateForm()) {
                    const fieldId = parseInt(hfFieldId.value) || 0;
                    const name = fieldName.value;
                    const type = fieldType.value;
                    const options = collectOptions();
                    const active = isActive.checked;

                    PageMethods.SaveField(fieldId, name, type, options, active, onSaveSuccess, onApiError);
                }
            });

            function onSaveSuccess(response) {
                if (response.success) {
                    modalInstance.hide();
                    refreshFieldsList();
                } else {
                    showError(response.message);
                }
            }

            customFieldsList.addEventListener('click', (e) => {
                const target = e.target.closest('button');
                if (!target) return;

                const fieldId = parseInt(target.dataset.fieldid);

                if (target.classList.contains('edit-btn')) {
                    PageMethods.GetFields(function (response) {
                        if (response.success) {
                            const field = response.data.find(f => f.FieldId === fieldId);
                            if (field) loadFieldDataForEdit(field);
                        }
                    }, onApiError);
                }
                if (target.classList.contains('delete-btn')) {
                    if (confirm('Are you sure you want to delete this field? This will also remove all data entered for this field from existing appointments.')) {
                        PageMethods.DeleteField(fieldId, onModifySuccess, onApiError);
                    }
                }
                if (target.classList.contains('active-btn')) {
                    PageMethods.ToggleFieldActive(fieldId, onModifySuccess, onApiError);
                }
            });

            function onModifySuccess(response) {
                if (response.success) {
                    refreshFieldsList();
                } else {
                    showError(response.message);
                }
            }

            // --- Modal-specific Listeners and Functions ---
            fieldType.addEventListener('change', () => { updateVisibility(); buildPreview(); });
            fieldName.addEventListener('input', buildPreview);
            btnAddOption.addEventListener('click', () => {
                addOptionInput('');
                const lastInput = optionsContainer.querySelector('.option-input:last-of-type');
                if (lastInput) lastInput.focus();
            });

            function updateVisibility() {
                divOptions.style.display = (fieldType.value === 'dropdown' || fieldType.value === 'checklist') ? 'block' : 'none';
            }

            function addOptionInput(value) {
                const div = document.createElement('div');
                div.className = 'input-group option-input-group';
                div.innerHTML = `
                    <span class="input-group-text"><i class="bi bi-grip-vertical text-muted"></i></span>
                    <input type="text" class="form-control option-input" value="${escapeHtml(value)}" placeholder="Option value">
                    <button type="button" class="btn btn-outline-danger remove-option"><i class="bi bi-x-lg"></i></button>`;
                optionsContainer.appendChild(div);
                div.querySelector('.remove-option').addEventListener('click', () => {
                    div.remove();
                    buildPreview();
                });
                div.querySelector('.option-input').addEventListener('input', buildPreview);
            }

            function collectOptions() {
                if (fieldType.value !== 'dropdown' && fieldType.value !== 'checklist') return '';
                const inputs = optionsContainer.querySelectorAll('.option-input');
                const options = Array.from(inputs).map(i => i.value.trim()).filter(v => v);
                return JSON.stringify(options);
            }

            function validateForm() {
                if (!fieldName.value.trim()) {
                    showError('Field name is required.');
                    fieldName.focus();
                    return false;
                }
                if ((fieldType.value === 'dropdown' || fieldType.value === 'checklist') && collectOptions() === '[]') {
                    showError('At least one option is required for this field type.');
                    return false;
                }
                return true;
            }

            function buildPreview() {
                const name = fieldName.value.trim() || 'Field Name';
                const type = fieldType.value;
                const options = JSON.parse(collectOptions() || '[]');
                let html = `<label class="form-label mb-2"><strong>${escapeHtml(name)}</strong></label>`;
                switch (type) {
                    case 'text': html += `<input type="text" class="form-control" disabled>`; break;
                    case 'number': html += `<input type="number" class="form-control" disabled>`; break;
                    case 'date': html += `<input type="date" class="form-control" disabled>`; break;
                    case 'dropdown':
                        html += `<select class="form-select" disabled><option>-- Select --</option>`;
                        options.forEach(o => html += `<option>${escapeHtml(o)}</option>`);
                        html += `</select>`;
                        break;
                    case 'checklist':
                        if (options.length === 0) {
                            html += '<p class="text-muted small">Add options to see preview.</p>';
                        } else {
                            options.forEach(o => html += `<div class="form-check"><input type="checkbox" disabled><label class="form-check-label ms-2">${escapeHtml(o)}</label></div>`);
                        }
                        break;
                }
                fieldPreview.innerHTML = html;
            }

            function clearModalForm() {
                hfFieldId.value = '0';
                fieldName.value = '';
                fieldType.selectedIndex = 0;
                isActive.checked = true;
                optionsContainer.innerHTML = '';
                updateVisibility();
                buildPreview();
            }

            function loadFieldDataForEdit(field) {
                clearModalForm();
                modalTitle.textContent = 'Edit Custom Field';
                hfFieldId.value = field.FieldId;
                fieldName.value = field.FieldName;
                fieldType.value = field.FieldType;
                isActive.checked = field.IsActive;

                if (field.FieldType === 'dropdown' || field.FieldType === 'checklist') {
                    const options = JSON.parse(field.Options || '[]');
                    options.forEach(option => addOptionInput(option));
                }

                updateVisibility();
                buildPreview();
                modalInstance.show();
            }

            function showError(message) {
                alert('Error: ' + message);
            }

            function onApiError(error) {
                console.error('API Error:', error);
                showError('An unexpected error occurred. Please try again.');
            }

            function escapeHtml(text) {
                const map = {
                    '&': '&amp;',
                    '<': '&lt;',
                    '>': '&gt;',
                    '"': '&quot;',
                    "'": '&#039;'
                };
                return text.replace(/[&<>"']/g, function (m) { return map[m]; });
            }

            // Initialize on page load
            refreshFieldsList();
        }
    </script>

</asp:Content>

