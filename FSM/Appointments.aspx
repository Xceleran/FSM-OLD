<%@ Page Title="Appointments" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="Appointments.aspx.cs" Inherits="FSM.Appointments" %>

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

    <!-- Local Styles and Scripts -->
    <link rel="stylesheet" href="Content/appointments.css">


    <!-- Page Content -->
    <div class="container-fluid">
        <header class="mb-4">
            <div class="row align-items-center">
                <div class="col-md-6 col-12">
                    <h1 class="page-title">Dispatch Calendar</h1>
                </div>
                <%--<div class="col-md-6 col-12 text-md-end text-center mt-2 mt-md-0">
                    <button class="btn btn-primary" onclick="openNewModal()">+ Create Appointment</button>
                </div>--%>
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
                         
                            <div class="d-flex flex-wrap gap-2 align-items-center">
                                <label for="viewSelect" class="form-label mb-0">View:</label>
                                <select id="viewSelect" class="form-select w-120px" onchange="renderDateView($('#dayDatePicker').val())">
                                    <option value="day">Day</option>
                                    <option value="week">Week</option>
                                    <option value="threeDay">Three-Day</option>
                                    <option value="month">Month</option>
                                </select>
                                <label for="ServiceTypeFilter" class="form-label mb-0 ms-3">Filter:</label>
                                <select name="ServiceTypeFilter" id="ServiceTypeFilter" class="form-select  w-120px" runat="server" onchange="renderDateView($('#dayDatePicker').val())">
                                    <option value="select">Select</option>
                                    <option value="0">Company Use</option>
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
                            <div class="time-slot-indicators">
                                <span class="time-block-indicator time-block-morning"></span>Morning (8AM-12PM)
                                <span class="time-block-indicator time-block-afternoon"></span>Afternoon (12PM-4PM)
                                <span class="time-block-indicator time-block-emergency"></span>Emergency (6PM-10PM)
                            </div>
                        </div>
                        <div class="card-body">
                               <div class="datepicker"><div class="date-nav" id="dateNav"></div></div>
                            <div id="dayCalendar"></div>
                        </div>
                    </div>
                    <div class="card unscheduled-panel">
                        <div class="card-header">
                            <h3 class="card-title">Unassigned Appointments</h3>
                        </div>
                        <div class="card-body">

                            <div class="unscheduled-filters">
                                <select runat="server" id="StatusTypeFilter" class="form-select mb-3" onchange="renderUnscheduledList()">
                                    <option value="all">All Statuses</option>
                                </select>
                                <select runat="server" id="ServiceTypeFilter_2" class="form-select mb-3" onchange="renderUnscheduledList()">
                                    <option value="all">All Service Types</option>
                                </select>
                                <input type="text" id="searchFilter" class="form-control mb-3" placeholder="Search by customer..." oninput="renderUnscheduledList()">
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
                            
                            <div class="d-flex flex-wrap gap-2 align-items-center">
                                <label for="resourceDatePicker" class="form-label mb-0">Date:</label>
                                <input type="date" id="resourceDatePicker" class="form-control w-200px" onchange="renderResourceView(this.value)">
                               <%-- <label for="dispatchGroup" class="form-label mb-0 ms-3">Group:</label>
                                <select id="dispatchGroup" class="form-select w-120px" onchange="renderResourceView($('#resourceDatePicker').val())">
                                    <option value="all">All Resources</option>
                                    <option value="electricians">Electricians</option>
                                    <option value="plumbers">Plumbers</option>
                                </select>--%>
                            </div>
                            <div class="time-slot-indicators">
                                <span class="time-block-indicator time-block-morning"></span>Morning (8AM-12PM)
                                <span class="time-block-indicator time-block-afternoon"></span>Afternoon (12PM-4PM)
                                <span class="time-block-indicator time-block-emergency"></span>Emergency (6PM-10PM)
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="datepicker"><div class="date-nav" id="resourceDateNav"></div></div>
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
                                    <option value="all">All Service Types</option>
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
     <label for="ServiceTypeFilter_List" class="form-label mb-0 ms-3">Service type:</label>
     <select name="ServiceTypeFilter_List" id="ServiceTypeFilter_List" class="form-select" runat="server" onchange="renderListView()">
         <option value="select">Select</option>
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
                                <label for="StatusTypeFilter_List" class="form-label mb-0 ms-3">Status:</label>
                                <select runat="server" id="StatusTypeFilter_List" class="form-select" onchange="renderListView()">
                                    <option value="all">Select</option>
                                </select>
                            </div>
                            <div>
                                <button type="button" class="btn btn-secondary ms-2" onclick="clearFilterListView(event)">Clear</button>
                            </div>
                        </div>


                    </div>
                    <div class="card-body">
                        <table class="table list-view-table" id="listTable">
                            <thead>
                                <tr>
                                    <th>Customer</th>
                                    <th>Business Name</th>
                                    <th>Address</th>
                                    <th>Request Date</th>
                                    <th>Time Slot</th>
                                    <th>Service Type</th>
                                    <th>Mobile</th>
                                    <th>Phone</th>
                                    <th>Status</th>
                                    <th>Resource</th>
                                    <th>Ticket Status</th>
                                </tr>
                            </thead>
                            <tbody id="listTableBody"></tbody>
                        </table>
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
                                <label for="mapDispatchGroup" class="form-label mb-0 ms-3">Group:</label>
                                <select id="mapDispatchGroup" class="form-select w-120px">
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
                        <div class="map-controls mt-2">
                            <button id="mapOptimizeRouteBtn" class="btn btn-primary">Optimize Route</button>
                            <button id="mapAddCustomMarkerBtn" class="btn btn-primary ms-2">Add Custom Marker</button>
                        </div>
                        <div class="map-status-legend mt-2">
                            <span class="status-indicator pending"></span>Pending
                            <span class="status-indicator dispatched"></span>Dispatched
                            <span class="status-indicator in-route"></span>In Route
                            <span class="status-indicator arrived"></span>Arrived
                        </div>
                        <div class="map-work-order-status mt-2">
                            <h5>Work Order Status</h5>
                            <select id="statusFilter" class="form-select w-200px" aria-label="Filter by work order status">
                                <option value="all">All Statuses</option>
                                <option value="pending">Pending</option>
                                <option value="dispatched">Dispatched</option>
                                <option value="inRoute">In Route</option>
                                <option value="arrived">Arrived</option>
                            </select>
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
                                    <option value="Tasks">Tasks</option>
                                    <option value="Visits">Visits</option>
                                    <option value="Maintenance">Maintenance</option>
                                    <option value="Installation">Installation</option>
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
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label">Customer Name</label>
                                <input type="text" name="customerName" class="form-control" readonly="readonly">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Service Type</label>
                                <select runat="server" id="ServiceTypeFilter_Edit" name="serviceTypeEdit" class="form-select" onchange="calculateTimeRequired(event)" required>
                                    <option value="all">All Service Types</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Date</label>
                                <input type="date" name="date" class="form-control" id="dateInput" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Resource</label>
                                <select id="resource_list" name="resource" class="form-select">
                                    <option value="0">Unassigned</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Time Slot</label>
                                <select id="time_slot" name="timeSlot" class="form-select" required>
                                    <option value="morning">Morning</option>
                                    <option value="afternoon">Afternoon</option>
                                    <option value="emergency">Emergency</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Duration (hours)</label>
                                <input type="text" name="duration" class="form-control" readonly="readonly"/>
                               <%-- <select name="duration" class="form-select" required>
                                    <option value="1">1 Hour Package</option>
                                    <option value="2">2 Hour Package</option>
                                    <option value="3">3 Hour Package</option>
                                    <option value="4">4 Hour Package</option>
                                    <option value="5">5 Hour Package</option>
                                    <option value="6">6 Hour Package</option>
                                    <option value="7">7 Hour Package</option>
                                    <option value="8">8 Hour Package</option>
                                </select>--%>
                            </div>
                            <div class="col-12">
                                <label class="form-label">Address</label>
                                <input type="text" name="address" class="form-control" readonly="readonly">
                            </div>
                            <div class="col-12">
                                <label class="form-label">Status</label>
                                <select runat="server" id="StatusTypeFilter_Edit" name="status" class="form-select" required>
                                   <option value="all">Select</option>
                                </select>
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

        <script src="Scripts/appointments.js" defer></script>
</asp:Content>
