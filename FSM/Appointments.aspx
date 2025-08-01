﻿<%@ Page Title="Appointments" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="Appointments.aspx.cs" Inherits="FSM.Appointments" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <!-- External Libraries -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="https://cdn.datatables.net/responsive/3.0.2/js/dataTables.responsive.min.js"></script>
    <link rel="stylesheet" href="https://cdn.datatables.net/responsive/3.0.2/css/responsive.dataTables.min.css">
    <script src="Scripts/moment.js"></script>
    <!-- Local Styles and Scripts -->
    <link rel="stylesheet" href="Content/appointments.css">

    <!-- Inline CSS for Expand/Collapse -->
    <style>


        .workorder-filters-row {
            display: flex;
            flex-direction: row;
            gap: 18px; /* space between the filters */
            align-items: flex-end;
        }

        /* Optional: Make them stack on mobile */
        @media (max-width: 600px) {
            .workorder-filters-row {
                flex-direction: column;
                gap: 10px;
            }
        }
    </style>



    <!-- Page Content -->
    <div class="container-fluid">
        <header class="mb-4">
            <div class="row align-items-center">
                <div class="col-12">
                    <div class="cec-btn">
                        <h1 class="page-title">Dispatch Calendar</h1>
                        <a href="https://testsite.myserviceforce.com/cec/calendar.aspx?m=3" class="custom-launch-btn" role="button" target="_blank">
                            <span>
                                <span>CEC Appointments</span>
                                <span aria-hidden="true">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M4.5 19.5l15-15m0 0H8.25m11.25 0v11.25" />
                                    </svg>
                                </span>
                            </span>
                        </a>
                    </div>
                </div>
            </div>

        </header>

        <ul class="nav nav-tabs mb-4 gap-1" id="viewTabs" role="tablist">
            <li class="nav-item">
                <button class="nav-link active" id="date-tab" data-bs-toggle="tab" data-bs-target="#dateView" type="button" role="tab">Date View</button>
            </li>
            <li class="nav-item">
                <button class="nav-link" id="resource-tab" data-bs-toggle="tab" data-bs-target="#resourceView" type="button" role="tab">Resource View</button>
            </li>
            <li class="nav-item">
                <button class="nav-link" id="list-tab" data-bs-toggle="tab" data-bs-target="#listView" type="button" role="tab">List View</button>
            </li>
            <li class="nav-item">
                <button class="nav-link" id="map-tab" data-bs-toggle="tab" data-bs-target="#mapView" type="button" role="tab">Map View</button>
            </li>
        </ul>

        <div class="tab-content">
            <div class="tab-pane fade show active" id="dateView" role="tabpanel">
                <div class="date-view-container">
                    <div class="card calendar-container date-view">
                        <div class="card-header">
                            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                <div class="d-flex flex-wrap gap-2 align-items-center">
                                    <button id="expandCalendarBtn" class="btn btn-outline-secondary me-2" data-bs-toggle="tooltip" title="Expand/Collapse Calendar">
                                        <i class="fas fa-expand"></i>
                                    </button>
                                    <label for="viewSelect" class="form-label mb-0">View:</label>
                                    <select id="viewSelect" class="form-select w-120px" onchange="renderDateView($('#dayDatePicker').val())">
                                        <option value="day">Day</option>
                                        <option value="week">Week</option>
                                        <option value="threeDay">Three-Day</option>
                                        <option value="month">Month</option>
                                    </select>
                                    <label for="ServiceTypeFilter" class="form-label mb-0">Filter:</label>
                                    <select name="ServiceTypeFilter" id="ServiceTypeFilter" class="form-select w-120px" runat="server" onchange="renderDateView($('#dayDatePicker').val())">
                                        <option value="all">All Types</option>
                                        <option value="IT Support">IT Support</option>
                                        <option value="1 Hour">1 Hour</option>
                                        <option value="2 Hour">2 Hour</option>
                                    </select>
                                    <%--<select id="filterSelect" class="form-select w-120px" onchange="renderDateView($('#dayDatePicker').val())">
                                        <option value="all">All</option>
                                        <option value="Tasks">Tasks</option>
                                        <option value="Visits">Visits</option>
                                        <option value="Maintenance">Maintenance</option>
                                        <option value="Installation">Installation</option>
                                    </select>--%>
                                    <label for="dayDatePicker" class="form-label mb-0 ms-3">Date:</label>
                                    <input type="date" id="dayDatePicker" class="form-control w-200px" onchange="renderDateView(this.value)">
                                </div>
                                <button id="toggleUnscheduledBtn" class="btn btn-sm"><i class="fas fa-chevron-right"></i></button>
                            </div>
                            <div class="appt-type-indicators">
                                <span class="appt-type-indicator appt-type-it-support"></span>IT Support
                                <span class="appt-type-indicator appt-type-1-hour"></span>1 Hour
                                <span class="appt-type-indicator appt-type-2-hour"></span>2 Hour
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="datepicker">
                                <div class="date-nav" id="dateNav"></div>
                            </div>
                            <div id="dayCalendar"></div>
                        </div>
                    </div>
                    <div class="card unscheduled-panel">
                        <div class="card-header">
                            <h3 class="card-title">Unassigned Appointments</h3>
                        </div>
                        <div class="card-body">

                            <!--Dropdowns Under One Filter-->
                            <div class="dropdown unscheduled-filters mb-3">
                                <button class="btn btn-primary dropdown-toggle w-100" type="button" id="unscheduledFilterBtn" data-bs-toggle="dropdown" aria-expanded="false">
                                    <i class="fas fa-filter"></i>Filter
                                </button>
                                <div class="dropdown-menu p-3 w-100" aria-labelledby="unscheduledFilterBtn" style="min-width: 320px;">
                                    <select runat="server" id="StatusTypeFilter" class="form-select mb-3" onchange="renderUnscheduledList()">
                                        <option value="all">All Statuses</option>
                                    </select>
                                    <select runat="server" id="ServiceTypeFilter_2" class="form-select mb-3" onchange="renderUnscheduledList()">
                                        <option value="all">All Types</option>
                                        <option value="IT Support">IT Support</option>
                                        <option value="1 Hour">1 Hour</option>
                                        <option value="2 Hour">2 Hour</option>
                                    </select>
                                    <select id="ProvinceFilter" class="form-select mb-3" onchange="renderUnscheduledList()">
                                        <option value="all">All Provinces/Territories</option>
                                        <option value="AB">Alberta</option>
                                        <option value="BC">British Columbia</option>
                                        <option value="MB">Manitoba</option>
                                        <option value="NB">New Brunswick</option>
                                        <option value="NL">Newfoundland and Labrador</option>
                                        <option value="NS">Nova Scotia</option>
                                        <option value="NT">Northwest Territories</option>
                                        <option value="NU">Nunavut</option>
                                        <option value="ON">Ontario</option>
                                        <option value="PE">Prince Edward Island</option>
                                        <option value="QC">Quebec</option>
                                        <option value="SK">Saskatchewan</option>
                                        <option value="YT">Yukon</option>
                                    </select>
                                    <select id="PostalCodeFilter" class="form-select mb-3" onchange="renderUnscheduledList()">
                                        <option value="all">All Postal Codes</option>
                                        <!-- Populated dynamically via JavaScript -->
                                    </select>

                                </div>
                                <input type="text" id="searchFilter" class="form-control mb-3" placeholder="Search by customer..." oninput="renderUnscheduledList()" style="margin-top: 10px">
                            </div>
                            <div id="unscheduledList" class="unscheduled-list"></div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="tab-pane fade" id="resourceView" role="tabpanel">
                <div class="date-view-container">
                    <div class="card calendar-container resource-view">
                        <div class="card-header">
                            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                <div class="d-flex flex-wrap gap-2 align-items-center">
                                    <button id="expandCalendarBtnResource" class="btn btn-outline-secondary me-2" data-bs-toggle="tooltip" title="Expand/Collapse Calendar">
                                        <i class="fas fa-expand"></i>
                                    </button>
                                    <label for="resourceDatePicker" class="form-label mb-0">Date:</label>
                                    <input type="date" id="resourceDatePicker" class="form-control w-200px" onchange="renderResourceView(this.value)">
                                    <%--<label for="dispatchGroup" class="form-label mb-0 ms-3">Group:</label>
                                    <select id="dispatchGroup" class="form-select w-120px" onchange="renderResourceView($('#resourceDatePicker').val())">
                                        <option value="all">All Resources</option>
                                        <option value="electricians">Electricians</option>
                                        <option value="plumbers">Plumbers</option>
                                    </select>--%>
                                </div>
                                <button id="toggleUnscheduledBtnResource" class="btn btn-sm" style="display: block;"><i class="fas fa-chevron-right"></i></button>
                            </div>
                            <div class="appt-type-indicators">
                                <span class="appt-type-indicator appt-type-it-support"></span>IT Support
                                <span class="appt-type-indicator appt-type-1-hour"></span>1 Hour
                                <span class="appt-type-indicator appt-type-2-hour"></span>2 Hour
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="datepicker">
                                <div class="date-nav" id="resourceDateNav"></div>
                            </div>
                            <div id="resourceViewContainer"></div>
                        </div>
                    </div>
                    <div class="card unscheduled-panel">
                        <div class="card-header">
                            <h3 class="card-title">Unassigned Appointments</h3>
                        </div>
                        <div class="card-body">
                            <div class="unscheduled-filters">
                                <select runat="server" id="StatusTypeFilter_Resource" class="form-select mb-3" onchange="renderUnscheduledList('resource')">
                                    <option value="all">All Statuses</option>
                                </select>
                                <select runat="server" id="ServiceTypeFilter_Resource" class="form-select mb-3" onchange="renderUnscheduledList('resource')">
                                    <option value="IT Support">IT Support</option>
                                    <option value="1 Hour">1 Hour</option>
                                    <option value="2 Hour">2 Hour</option>
                                </select>

                                <select id="ProvinceFilterResource" class="form-select mb-3" onchange="renderUnscheduledList('resource')">
                                    <option value="all">All Provinces/Territories</option>
                                    <option value="AB">Alberta</option>
                                    <option value="BC">British Columbia</option>
                                    <option value="MB">Manitoba</option>
                                    <option value="NB">New Brunswick</option>
                                    <option value="NL">Newfoundland and Labrador</option>
                                    <option value="NS">Nova Scotia</option>
                                    <option value="NT">Northwest Territories</option>
                                    <option value="NU">Nunavut</option>
                                    <option value="ON">Ontario</option>
                                    <option value="PE">Prince Edward Island</option>
                                    <option value="QC">Quebec</option>
                                    <option value="SK">Saskatchewan</option>
                                    <option value="YT">Yukon</option>
                                </select>
                                <select id="PostalCodeFilterResource" class="form-select mb-3" onchange="renderUnscheduledList('resource')">
                                    <option value="all">All Postal Codes</option>
                                    <!-- Populated dynamically via JavaScript -->
                                </select>
                                <input type="text" id="searchFilterResource" class="form-control mb-3" placeholder="Search by customer..." oninput="renderUnscheduledList('resource')">
                            </div>
                            <div id="unscheduledListResource" class="unscheduled-list"></div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="tab-pane fade" id="listView" role="tabpanel">
                <div class="card calendar-container">
                    <div class="card-header">
                        <div class="d-flex flex-wrap gap-2 align-items-end">
                            <div>
                                <label for="search_term" class="form-label mb-0">Search</label>
                                <input placeholder="Search anything" type="text" id="search_term" class="form-control w-200px" oninput="renderListView()">
                            </div>
                            <div>
                                <label for="ServiceTypeFilter_List" class="form-label mb-0">Service type:</label>
                                <select name="ServiceTypeFilter_List" id="ServiceTypeFilter_List" class="form-select" runat="server" onchange="renderListView()">
                                    <option value="all">All Types</option>
                                    <option value="IT Support">IT Support</option>
                                    <option value="1 Hour">1 Hour</option>
                                    <option value="2 Hour">2 Hour</option>
                                </select>
                            </div>
                            <div>
                                <label for="StatusTypeFilter_List" class="form-label mb-0">Appointment Status:</label>
                                <select runat="server" id="StatusTypeFilter_List" class="form-select" onchange="renderListView()">
                                    <option value="all">Select</option>
                                </select>
                            </div>
                            <div>
                                <label for="TicketStatusFilter_List" class="form-label mb-0">Ticket Status:</label>
                                <select runat="server" id="TicketStatusFilter_List" class="form-select" onchange="renderListView()">
                                    <option value="all">Select</option>
                                </select>
                            </div>
                            <div>
                                <label for="listDatePickerFrom" class="form-label mb-0">From Date:</label>
                                <input type="date" id="listDatePickerFrom" class="form-control w-200px">
                            </div>
                            <div>
                                <label for="listDatePickerTo" class="form-label mb-0">To Date:</label>
                                <input type="date" id="listDatePickerTo" class="form-control w-200px">
                            </div>
                            <div>
                                <label></label>
                                <button type="button" class="btn btn-primary ms-2" onclick="searchListView(event)">Search By Date</button>
                            </div>

                            <div>
                                <button type="button" class="btn btn-secondary ms-2" onclick="clearFilterListView(event)">Clear</button>
                            </div>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="list-view-table-container">
                            <table class="table list-view-table">
                                <thead>
                                    <tr>
                                        <th>View</th>
                                        <th data-key="CustomerName" class="sortable">Customer</th>
                                        <th data-key="BusinessName" class="sortable">Business Name</th>
                                        <th data-key="Address1" class="sortable">Address</th>
                                        <th data-key="RequestDate" class="sortable">Request Date</th>
                                        <th data-key="TimeSlot" class="sortable">Time Slot</th>
                                        <th data-key="ServiceType" class="sortable">Service Type</th>
                                        <th data-key="Email" class="sortable">Email</th>
                                        <th data-key="Mobile" class="sortable">Mobile</th>
                                        <th data-key="Phone" class="sortable">Phone</th>
                                        <th data-key="AppoinmentStatus" class="sortable">Appointment Status</th>
                                        <th data-key="ResourceName" class="sortable">Resource</th>
                                        <th data-key="TicketStatus" class="sortable">Ticket Status</th>
                                    </tr>
                                </thead>
                                <tbody id="listTableBody">
                                    <!-- Populated by renderListView -->
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Enhanced Map View Tab -->
            <div class="tab-pane fade" id="mapView" role="tabpanel">
                <div class="card calendar-container map-view-container">
                    <div class="card-header">
                        <div class="d-flex flex-wrap gap-2 align-items-center justify-content-between">
                            <div class="d-flex flex-wrap gap-2 align-items-center">
                                <label for="mapDatePicker" class="form-label mb-0">Date:</label>
                                <input type="date" id="mapDatePicker" class="form-control w-200px">
                                <label for="mapDispatchGroup" class="form-label mb-0 d-none">Group:</label>
                                <select id="mapDispatchGroup" class="form-select w-120px d-none">
                                    <option value="all">All Technicians</option>
                                    <option value="electricians">Electricians</option>
                                    <option value="plumbers">Plumbers</option>
                                </select>
                                <button id="mapReloadBtn" class="btn btn-outline-secondary ms-2">Reload</button>
                            </div>
                            <ul class="nav nav-tabs map-view-tabs" id="mapViewTabs" role="tablist">
                                <li class="nav-item">
                                    <button class="nav-link active" id="map-layer-tab" data-bs-toggle="tab" data-bs-target="#mapLayerView" type="button" role="tab">Map</button>
                                </li>
                                <li class="nav-item">
                                    <button class="nav-link" id="satellite-layer-tab" data-bs-toggle="tab" data-bs-target="#mapLayerView" type="button" role="tab">Satellite</button>
                                </li>
                            </ul>
                        </div>
                        <div class="map-controls mt-2 ">
                            <button id="mapOptimizeRouteBtn" class="btn btn-primary mb-3">Optimize Route</button>
                            <button id="mapAddCustomMarkerBtn" class="btn btn-primary mb-3">Add Custom Marker</button>
                        </div>
                        <div class="map-status-legend mt-2">
                            <span class="status-indicator pending"></span>Pending
                            <span class="status-indicator dispatched"></span>Dispatched
                            <span class="status-indicator in-route"></span>In Route
                            <span class="status-indicator arrived"></span>Arrived
                        </div>


                        <div class="workorder-filters-row" style="margin-top: 12px;">
                            <div class="map-work-order-status">
                                <h6>Work Order Status</h6>
                                <select id="statusFilter" class="form-select w-200px" aria-label="Filter by work order status">
                                    <option value="all">All Statuses</option>
                                    <option value="pending">Pending</option>
                                    <option value="dispatched">Dispatched</option>
                                    <option value="inRoute">In Route</option>
                                    <option value="arrived">Arrived</option>
                                </select>
                            </div>
<!---------------------------------------------------Added New Resource Filter------------------------------------------->
                            <div>
                                <label for="ServiceTypeFilter_List" class="form-label mb-0">
                                    <h6>Service type</h6>
                                </label>
                                <select name="ServiceTypeFilter_List" id="Select1" class="form-select w-200px" runat="server" onchange="renderListView()">
                                    <option value="all">All Types</option>
                                    <option value="IT Support">IT Support</option>
                                    <option value="1 Hour">1 Hour</option>
                                    <option value="2 Hour">2 Hour</option>
                                </select>
                            </div>
<!--xxx------------------------------------------->
                        </div>



                    </div>

                    <div class="card-body">
                        <div class="tab-content">
                            <div class="tab-pane fade show active" id="mapLayerView" role="tabpanel">
                                <div id="mapViewContainer" style="height: 500px; width: 100%;"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Modals -->
    <div class="modal fade" id="newModal" tabindex="-1" aria-labelledby="newModalLabel">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="newModalLabel">Create Appointment</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form id="newForm" onsubmit="createAppointment(event)">
                    <div class="modal-body">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label">Customer Name</label>
                                <input type="text" name="customerName" class="form-control" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Service Type</label>
                                <select name="serviceTypeNew" class="form-select" required>
                                    <option value="IT Support">IT Support</option>
                                    <option value="1 Hour">1 Hour</option>
                                    <option value="2 Hour">2 Hour</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Date</label>
                                <input type="date" name="date" class="form-control" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Resource</label>
                                <select name="resource" class="form-select">
                                    <option value="Unassigned">Unassigned</option>
                                    <option value="Jim">Jim</option>
                                    <option value="Bob">Bob</option>
                                    <option value="Team1">Team 1</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Time Slot</label>
                                <select name="timeSlot" class="form-select" required>
                                    <option value="morning">Morning</option>
                                    <option value="afternoon">Afternoon</option>
                                    <option value="emergency">Emergency</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Duration (hours)</label>
                                <select name="duration" class="form-select" required>
                                    <option value="1">1 Hour Package</option>
                                    <option value="2">2 Hour Package</option>
                                    <option value="3">3 Hour Package</option>
                                    <option value="4">4 Hour Package</option>
                                    <option value="5">5 Hour Package</option>
                                    <option value="6">6 Hour Package</option>
                                    <option value="7">7 Hour Package</option>
                                    <option value="8">8 Hour Package</option>
                                </select>
                            </div>
                            <div class="col-12">
                                <label class="form-label">Address</label>
                                <input type="text" name="address" class="form-control" required>
                            </div>
                            <div class="col-12">
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <label class="form-label mb-0">Forms</label>
                                    <button type="button" class="btn btn-sm btn-outline-primary" onclick="openFormsSelectionModal('new')">
                                        <i class="fa fa-plus"></i> Select Forms
                                    </button>
                                </div>
                                <div id="selectedFormsNew" class="selected-forms-container" style="min-height: 40px; border: 1px solid #dee2e6; border-radius: 0.375rem; padding: 8px;">
                                    <small class="text-muted">Auto-assigned forms will appear here based on service type</small>
                                </div>
                            </div>
                            <div class="col-12">
                                <label class="form-label">Status</label>
                                <select name="status" class="form-select" required>
                                    <option value="pending">Pending</option>
                                    <option value="confirmed">Confirmed</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Create</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="modal fade" id="editModal" tabindex="-1" aria-labelledby="editModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title edit-title" id="editModalLabel">Edit Appointment</h5>
                    <h5 class="modal-title confirm-title d-none" id="confirmlLabel">Confirm Appointment Scheduling</h5>
                    <button type="button" class="btn-close edit_close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form id="editForm" onsubmit="updateAppointment(event)">
                    <div class="modal-body">
                        <input type="hidden" id="AppoinmentId" name="AppoinmentId">
                        <input type="hidden" id="CustomerID" name="CustomerID">
                        <input type="hidden" id="timerequired_Hour" name="timerequired_Hour">
                        <input type="hidden" id="timerequired_Minute" name="timerequired_Minute">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label">Customer Name</label>
                                <input type="text" name="customerName" class="form-control" readonly="readonly">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Service Type</label>
                                <select runat="server" id="ServiceTypeFilter_Edit" name="serviceTypeEdit" class="form-select" onchange="calculateTimeRequired(event)" required>
                                    <option value="IT Support">IT Support</option>
                                    <option value="1 Hour">1 Hour</option>
                                    <option value="2 Hour">2 Hour</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Phone</label>
                                <input type="text" name="phone" class="form-control" readonly="readonly">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Mobile</label>
                                <input type="text" name="mobile" class="form-control" readonly="readonly">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Date</label>
                                <input type="date" name="date" class="form-control" id="dateInput" required onchange="updateDate(event)">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Resource</label>
                                <select id="resource_list" name="resource" class="form-select">
                                    <option value="0">Unassigned</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Time Slot</label>
                                <select id="time_slot" name="timeSlot" class="form-select" required onchange="calculateTimeRequired(event)">
                                    <option value="morning">Morning</option>
                                    <option value="afternoon">Afternoon</option>
                                    <option value="emergency">Emergency</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Time Required</label>
                                <input type="text" id="duration" name="duration" class="form-control" readonly="readonly" />
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Appointment Start Date</label>
                                <input type="text" name="txt_StartDate" class="form-control" id="txt_StartDate" readonly="readonly">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Appointment End Date</label>
                                <input type="text" name="txt_EndDate" class="form-control" id="txt_EndDate" readonly="readonly">
                                <small id="customer_EndDate" style="display: none;" class="mb-3 text-warning">End date time cant be smaller than start date time.</small>
                            </div>
                            <div class="col-12">
                                <label class="form-label">Address</label>
                                <input type="text" name="address" class="form-control" readonly="readonly">
                            </div>
                            <div class="col-12">
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <label class="form-label mb-0">Forms</label>
                                    <div>
                                        <button type="button" class="btn btn-sm btn-outline-primary" onclick="openFormsSelectionModal('edit')">
                                            <i class="fa fa-plus"></i> Add Forms
                                        </button>
                                        <button type="button" class="btn btn-sm btn-outline-info" onclick="openAppointmentFormsModal()">
                                            <i class="fa fa-list"></i> View Forms
                                        </button>
                                    </div>
                                </div>
                                <div id="selectedFormsEdit" class="selected-forms-container" style="min-height: 60px; border: 1px solid #dee2e6; border-radius: 0.375rem; padding: 8px;">
                                    <!-- Forms will be loaded here -->
                                </div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Appointment Status</label>
                                <select runat="server" id="StatusTypeFilter_Edit" name="status" class="form-select" required>
                                    <option value="all">Select</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Ticket Status</label>
                                <select runat="server" id="TicketStatusFilter_Edit" name="status" class="form-select" required>
                                    <option value="all">Select</option>
                                </select>
                            </div>
                            <div class="col-12">
                                <label class="form-label">Any details</label>
                                <textarea type="text" name="note" class="form-control"></textarea>

                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-danger d-none" onclick="deleteAppointment()">Delete</button>
                        <button type="button" class="btn btn-secondary d-none" onclick="unscheduleAppointment()">openEditModalUnschedule</button>
                        <button type="button" class="btn btn-secondary edit_close" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Update</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="modal fade" id="confirmModal" tabindex="-1" aria-labelledby="confirmModalLabel">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="confirmModalLabel">Confirm Appointment Scheduling</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form id="confirmForm" onsubmit="confirmScheduling(event)">
                    <div class="modal-body">
                        <input type="hidden" name="id">
                        <div class="row g-3">
                            <div class="col-12">
                                <label class="form-label">Customer Name</label>
                                <input type="text" name="customerName" class="form-control" readonly>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Date</label>
                                <input type="date" name="date" class="form-control" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Phone</label>
                                <input type="text" name="phone" class="form-control" readonly>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Mobile</label>
                                <input type="text" name="mobile" class="form-control" readonly>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Time Slot</label>
                                <select name="timeSlot" class="form-select" required>
                                    <option value="morning">Morning</option>
                                    <option value="afternoon">Afternoon</option>
                                    <option value="emergency">Emergency</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Duration (hours)</label>
                                <select name="duration" class="form-select" required>
                                    <option value="1">1 Hour Package</option>
                                    <option value="2">2 Hour Package</option>
                                    <option value="3">3 Hour Package</option>
                                    <option value="4">4 Hour Package</option>
                                    <option value="5">5 Hour Package</option>
                                    <option value="6">6 Hour Package</option>
                                    <option value="7">7 Hour Package</option>
                                    <option value="8">8 Hour Package</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Resource</label>
                                <select name="resource" class="form-select" required>
                                    <option value="Unassigned">Unassigned</option>
                                    <option value="Jim">Jim</option>
                                    <option value="Bob">Bob</option>
                                    <option value="Team1">Team 1</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Confirm</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Inline JavaScript for Expand/Collapse -->


    <script>
        document.addEventListener("DOMContentLoaded", function () {

            const cecBtn = document.querySelector(".cec-btn");

            // Listen to Bootstrap's tab show event
            const viewTabs = document.querySelectorAll('#viewTabs .nav-link');

            viewTabs.forEach(tab => {
                tab.addEventListener('shown.bs.tab', function (event) {
                    const activatedTabId = event.target.id;

                    if (activatedTabId === "map-tab") {
                        cecBtn.style.display = "none";
                    } else {
                        cecBtn.style.display = "flex";
                    }
                });
            });
        });
    </script>

    <script>


  
    </script>

    <script src="Scripts/appointments.js" defer></script>
    <script src="Scripts/signature-handler.js" defer></script>

    

    <!-- Forms Selection Modal -->
    <div class="modal fade" id="formsSelectionModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Select Forms for Appointment</h5>
                    <button type="button" class="close" data-dismiss="modal">
                        <span>&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6">
                            <h6>Available Forms</h6>
                            <div class="form-check">
                                <input type="checkbox" class="form-check-input" id="autoAssignForms" checked>
                                <label class="form-check-label" for="autoAssignForms">
                                    Auto-assign forms based on service type
                                </label>
                            </div>
                            <hr>
                            <div id="availableFormsList" class="available-forms-list">
                                <!-- Available forms will be loaded here -->
                            </div>
                        </div>
                        <div class="col-md-6">
                            <h6>Selected Forms</h6>
                            <div id="selectedFormsList" class="selected-forms-list">
                                <!-- Selected forms will appear here -->
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" onclick="applyFormsSelection()">Apply Selection</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Appointment Forms Management Modal -->
    <div class="modal fade" id="appointmentFormsModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-xl" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Appointment Forms</h5>
                    <button type="button" class="close" data-dismiss="modal">
                        <span>&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-4">
                            <h6>Forms List</h6>
                            <div id="appointmentFormsList" class="appointment-forms-list">
                                <!-- Appointment forms will be loaded here -->
                            </div>
                        </div>
                        <div class="col-md-8">
                            <div id="formViewerContainer">
                                <div class="form-viewer-placeholder text-center p-5">
                                    <i class="fa fa-file-text-o fa-3x text-muted mb-3"></i>
                                    <p class="text-muted">Select a form to view or fill</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-success d-none" id="saveFormBtn" onclick="saveCurrentForm()">Save Form</button>
                    <button type="button" class="btn btn-primary d-none" id="submitFormBtn" onclick="submitCurrentForm()">Submit Form</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Signature Capture Modal -->
    <div class="modal fade" id="signatureModal" tabindex="-1" role="dialog">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Capture Signature</h5>
                    <button type="button" class="close" data-dismiss="modal">
                        <span>&times;</span>
                    </button>
                </div>
                <div class="modal-body text-center">
                    <p id="signaturePrompt">Please sign below:</p>
                    <canvas id="signaturePad" width="400" height="200" style="border: 1px solid #ccc;"></canvas>
                    <div class="mt-3">
                        <button type="button" class="btn btn-sm btn-outline-secondary" onclick="clearSignature()">Clear</button>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" onclick="saveSignature()">Save Signature</button>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
