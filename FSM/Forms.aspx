<%@ Page Title="Forms" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="Forms.aspx.cs" Inherits="FSM.Forms" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <!-- CSS Variables aligned with main site.css -->
    <style>
        :root {
            --primary-color: #007bff;
            --secondary-color: #6c757d;
            --success-color: #28a745;
            --danger-color: #dc3545;
            --warning-color: #ffc107;
            --info-color: #17a2b8;
            --text-gray-800: #343a40;
            --text-gray-700: #6c757d;
        }

        .forms-page-container {
            width: 100%;
            padding: 20px;
            margin: 0 auto;
        }

        .forms-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 15px;
            border-bottom: 2px solid var(--primary-color);
        }

        .page-title {
            color: var(--text-gray-800);
            margin: 0;
            font-weight: 600;
        }

        .forms-content {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            overflow: hidden;
        }

        .templates-section, .usage-log-section {
            padding: 20px;
        }

        .templates-section {
            border-bottom: 1px solid #eee;
        }

        .table th {
            background-color: #f8f9fa;
            font-weight: 600;
            border-top: none;
        }

        .btn-sm {
            padding: 0.25rem 0.5rem;
            font-size: 0.875rem;
            margin-right: 0.25rem;
        }

        .badge {
            font-size: 0.75em;
        }

        /* Modal Styles */
        .modal-xl {
            max-width: 1200px;
        }

        .field-types {
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 10px;
            background: #f9f9f9;
        }

        .field-type {
            padding: 8px 12px;
            margin: 5px 0;
            background: white;
            border: 1px solid #ddd;
            border-radius: 4px;
            cursor: move;
            transition: all 0.2s;
        }

        .field-type:hover {
            background: var(--primary-color);
            color: white;
            transform: translateY(-1px);
        }

        .form-builder-area {
            min-height: 400px;
            border: 2px dashed #ddd;
            border-radius: 4px;
            padding: 20px;
            background: #fafafa;
        }

        .drop-zone {
            text-align: center;
            color: #999;
            font-style: italic;
            padding: 50px;
        }

        .form-field {
            margin: 10px 0;
            padding: 15px;
            border: 1px solid #ddd;
            border-radius: 4px;
            background: white;
            position: relative;
        }

        .form-field.selected {
            border-color: var(--primary-color);
            box-shadow: 0 0 5px rgba(0,123,255,0.3);
        }

        .field-controls {
            position: absolute;
            top: 5px;
            right: 5px;
            display: none;
        }

        .form-field:hover .field-controls {
            display: block;
        }

        .field-properties {
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 15px;
            background: #f9f9f9;
            max-height: 500px;
            overflow-y: auto;
        }

        .status-badge {
            display: inline-block;
            padding: 0.25em 0.6em;
            font-size: 75%;
            font-weight: 700;
            line-height: 1;
            text-align: center;
            white-space: nowrap;
            vertical-align: baseline;
            border-radius: 0.25rem;
        }

        .status-pending { background-color: #ffc107; color: #212529; }
        .status-completed { background-color: #28a745; color: white; }
        .status-inprogress { background-color: #17a2b8; color: white; }
        .status-submitted { background-color: #6f42c1; color: white; }

        [data-theme="dark"] .forms-content {
            background: #2d3748;
            color: white;
        }

        [data-theme="dark"] .page-title {
            color: var(--text-gray-700);
        }

        [data-theme="dark"] .table {
            color: white;
        }

        [data-theme="dark"] .table th {
            background-color: #4a5568;
            color: white;
        }

        [data-theme="dark"] .form-field {
            background: #4a5568;
            border-color: #4a5568;
            color: white;
        }
    </style>

    <!-- Page Content -->
    <div class="forms-page-container">
        <div class="forms-header">
            <h2 class="page-title">Forms Management</h2>
            <button type="button" class="btn btn-primary" onclick="openNewTemplateModal()">
                <i class="fa fa-plus"></i> New Template
            </button>
        </div>

        <div class="forms-content">
            <!-- Forms Templates Grid -->
            <div class="templates-section">
                <h4>Form Templates</h4>
                <div class="table-responsive">
                    <table class="table table-striped" id="templatesTable">
                        <thead>
                            <tr>
                                <th>Template Name</th>
                                <th>Category</th>
                                <th>Auto-Assign</th>
                                <th>Signature</th>
                                <th>Status</th>
                                <th>Created</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="templatesTableBody">
                            <!-- Templates will be loaded here -->
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Usage Log Section -->
            <div class="usage-log-section mt-4">
                <h4>Recent Form Activity</h4>
                <div class="table-responsive">
                    <table class="table table-sm" id="usageLogTable">
                        <thead>
                            <tr>
                                <th>Date/Time</th>
                                <th>Template</th>
                                <th>Appointment</th>
                                <th>Action</th>
                                <th>Performed By</th>
                            </tr>
                        </thead>
                        <tbody id="usageLogTableBody">
                            <!-- Usage log will be loaded here -->
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- New/Edit Template Modal -->
    <div class="modal fade" id="templateModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="templateModalTitle">New Form Template</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal">

                    </button>
                </div>
                <div class="modal-body">
                    <form id="templateForm">
                        <input type="hidden" id="templateId" name="templateId" value="0" />
                        
                        <div class="row">
                            <div class="col-md-8">
                                <div class="form-group">
                                    <label for="templateName">Template Name *</label>
                                    <input type="text" class="form-control" id="templateName" name="templateName" required>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label for="category">Category</label>
                                    <select class="form-control" id="category" name="category">
                                        <option value="">Select Category</option>
                                        <option value="Maintenance">Maintenance</option>
                                        <option value="Installation">Installation</option>
                                        <option value="Repair">Repair</option>
                                        <option value="Inspection">Inspection</option>
                                        <option value="Other">Other</option>
                                    </select>
                                </div>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="description">Description</label>
                            <textarea class="form-control" id="description" name="description" rows="2"></textarea>
                        </div>

                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" id="requireSignature" name="requireSignature">
                                    <label class="form-check-label" for="requireSignature">
                                        Require Signature
                                    </label>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" id="requireTip" name="requireTip">
                                    <label class="form-check-label" for="requireTip">
                                        Enable Tip Capture
                                    </label>
                                </div>
                            </div>
                        </div>

                        <div class="form-group mt-3">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" id="isAutoAssignEnabled" name="isAutoAssignEnabled">
                                <label class="form-check-label" for="isAutoAssignEnabled">
                                    Auto-assign to appointment types
                                </label>
                            </div>
                        </div>

                        <div id="autoAssignSection" class="form-group" style="display: none;">
                            <label>Service Types for Auto-Assignment</label>
                            <div id="serviceTypeCheckboxes">
                                <!-- Service type checkboxes will be populated here -->
                            </div>
                        </div>

                        <div class="form-group">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" id="isActive" name="isActive" checked>
                                <label class="form-check-label" for="isActive">
                                    Active
                                </label>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" onclick="saveTemplate()">Save Template</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Form Builder Modal -->
    <div class="modal fade" id="formBuilderModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-xl" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Form Builder</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal">

                    </button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-3">
                            <h6>Field Types</h6>
                            <div class="field-types">
                                <div class="field-type" draggable="true" data-type="text">
                                    <i class="fa fa-font"></i> Text Input
                                </div>
                                <div class="field-type" draggable="true" data-type="textarea">
                                    <i class="fa fa-align-left"></i> Text Area
                                </div>
                                <div class="field-type" draggable="true" data-type="number">
                                    <i class="fa fa-hashtag"></i> Number
                                </div>
                                <div class="field-type" draggable="true" data-type="date">
                                    <i class="fa fa-calendar"></i> Date
                                </div>
                                <div class="field-type" draggable="true" data-type="dropdown">
                                    <i class="fa fa-caret-down"></i> Dropdown
                                </div>
                                <div class="field-type" draggable="true" data-type="checkbox">
                                    <i class="fa fa-check-square"></i> Checkbox
                                </div>
                                <div class="field-type" draggable="true" data-type="radio">
                                    <i class="fa fa-dot-circle"></i> Radio Button
                                </div>
                                <div class="field-type" draggable="true" data-type="signature">
                                    <i class="fa fa-pencil"></i> Signature
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <h6>Form Preview</h6>
                            <div id="formBuilder" class="form-builder-area">
                                <div class="drop-zone">Drag fields here to build your form</div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <h6>Field Properties</h6>
                            <div id="fieldProperties" class="field-properties">
                                <p>Select a field to edit its properties</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" onclick="saveFormStructure()">Save Form Structure</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Include Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    
    <!-- Include Signature Pad Library -->
    <script src="https://cdn.jsdelivr.net/npm/signature_pad@4.0.0/dist/signature_pad.umd.min.js"></script>
    <script src="Scripts/forms.js"></script>
    <script src="Scripts/signature-handler.js"></script>
    
    <script>
        // Debug function to test if everything is working
        function testNewTemplate() {
            console.log('Testing New Template functionality...');
            console.log('jQuery available:', typeof $ !== 'undefined');
            console.log('Bootstrap modal available:', typeof $.fn.modal !== 'undefined');
            console.log('Modal element exists:', $('#templateModal').length > 0);
            
            // Test opening the modal
            try {
                openNewTemplateModal();
                console.log('Modal opened successfully');
            } catch (error) {
                console.error('Error opening modal:', error);
            }
        }
        
        // Test when page loads
        $(document).ready(function() {
            console.log('Forms page loaded successfully');
            console.log('Available functions:', {
                openNewTemplateModal: typeof openNewTemplateModal,
                loadTemplates: typeof loadTemplates,
                showAlert: typeof showAlert
            });
        });
    </script>

</asp:Content>