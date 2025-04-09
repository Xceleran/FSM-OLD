<%@ Page Title="Appointments" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="Appointments.aspx.cs" Inherits="FSM.Appointments" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" integrity="sha512-DTOQO9RWCH3ppGqcWaEA1BIZOC6xxalwEsw9c2QQeAIftl+Vegovlnee1c9QX4TctnWMn13TZye+giMm8e2LwA==" crossorigin="anonymous" referrerpolicy="no-referrer" />
    <!-- FullCalendar CSS -->
    <link href="https://cdn.jsdelivr.net/npm/fullcalendar@5.11.5/main.min.css" rel="stylesheet">
    <!-- Google Maps API -->
    <script async defer src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY_HERE&callback=initMap"></script>
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <!-- jQuery UI for Drag-and-Drop -->
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
    <!-- FullCalendar JS -->
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@5.11.5/main.min.js"></script>

    <style>
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            overflow-x: hidden;
        }

        .container-fluid {
            padding: 15px;
            margin-top: 60px;
            max-width: 100%;
            position: relative;
        }

        .appointments-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            background: #ffffff;
            padding: 10px 15px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }

            .appointments-header h1 {
                font-size: 24px;
                font-weight: 700;
                color: #2c3e50;
                margin: 0;
            }

        .header-actions {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .page-title {
            font-size: 24px;
            font-weight: bold;
            color: #f84700;
        }

        .btn {
            transition: all 0.3s ease;
        }

            .btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
            }

        .calendar-container {
            background: #ffffff;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            padding: 15px;
            border: 1px solid #e0e0e0;
        }

        .fc-event {
            background-color: #ff520d;
            color: wheat;
            border: none;
            border-radius: 5px;
            padding: 5px 8px;
            font-size: 12px;
            cursor: pointer;
            margin: 2px;
            white-space: normal;
            min-height: 25px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.2);
            transition: transform 0.2s ease;
        }

            .fc-event:hover {
                transform: scale(1.03);
            }

        .fc-daygrid-day {
            min-height: 100px;
            padding: 5px;
            background: #fafafa;
            border: 1px solid #e9ecef;
        }

        .fc-day-today {
            background: #fff3e0 !important;
            border: 2px solid #ff520d !important;
        }

        .fc .fc-daygrid-day-top {
            font-weight: 600;
            color: #2c3e50;
        }

        .fc .fc-toolbar {
            background: #2c3e50;
            color: white;
            padding: 8px;
            border-radius: 6px 6px 0 0;
            flex-wrap: wrap;
        }

        .fc .fc-toolbar-title {
            margin-left: 8px;
            font-size: 18px;
        }

        .fc .fc-button {
            background: #ff520d;
            border: none;
            color: wheat;
            text-transform: capitalize;
        }

            .fc .fc-button:hover {
                background: #e04a0c;
            }

        .list-view, .map-view, .resource-view {
            padding: 10px;
            background: #ffffff;
            border-radius: 6px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }

        .map-view {
            height: 400px;
            width: 100%;
        }

        .appointment-card .card-header {
            cursor: pointer;
            background: #f8f9fa;
            border-bottom: 1px solid #e0e0e0;
        }

        .appointment-card .card-body {
            display: none;
        }

        .appointment-card.expanded .card-body {
            display: block;
        }

        .status-indicator {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            display: inline-block;
            margin-right: 6px;
            border: 1px solid #ffffff;
        }

        .scheduled {
            background: #4CAF50;
        }

        .pending {
            background: #ff9800;
        }

        .completed {
            background: #2196F3;
        }

        .inRoute {
            background: #FFA500;
        }

        .arrived {
            background: #800080;
        }

        .incomplete {
            background: #FF0000;
        }

        .ui-draggable-dragging {
            z-index: 1000;
            opacity: 0.7;
        }

        .date-dropdown {
            position: absolute;
            z-index: 2000;
            background: #ffffff;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            border-radius: 6px;
            max-width: 220px;
        }

            .date-dropdown .dropdown-item {
                padding: 5px 12px;
                font-size: 13px;
                display: flex;
                align-items: center;
                gap: 6px;
                color: #2c3e50;
            }

                .date-dropdown .dropdown-item:hover {
                    background: #f8f9fa;
                }

            .date-dropdown h4 {
                margin: 6px 0;
                padding: 3px 12px;
                border-top: 1px solid #e0e0e0;
                border-bottom: 1px solid #e0e0e0;
                font-size: 13px;
                color: #2c3e50;
                text-align: center;
            }

            .date-dropdown .dropdown-header {
                padding: 6px 12px;
                font-weight: bold;
                background-color: #2c3e50;
                color: white;
                border-radius: 6px 6px 0 0;
            }

        .fc-timegrid-slot {
            height: 35px;
        }

        .fc-timegrid-col {
            min-width: 90px;
        }

        .modal-content {
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
        }

        .modal-header {
            border-radius: 10px 10px 0 0;
        }

        .modal-footer {
            border-top: 1px solid #e0e0e0;
        }

        .pagination {
            margin-top: 15px;
            justify-content: center;
        }

        .form-switch .form-check-input {
            width: 2em;
            height: 1em;
        }

        .nav-tabs .nav-link {
            color: #2c3e50;
            font-weight: 500;
            border-bottom: 2px solid transparent; /* Indicator for inactive tabs */
            background: white;
            margin-right: 7px;
        }

            .nav-tabs .nav-link.active {
                color: #ffffff;
                border-color: #ff520d;
                background: #ff520d;
            }
            .nav-tabs .nav-link:hover{
            border-bottom: 2px solid #dc1111;
            }
        .resource-view {
            display: flex;
            overflow-x: auto;
            background: #e9ecef;
            border: 1px solid #d0d0d0;
            border-radius: 5px;
        }

        .time-column {
            width: 90px;
            min-width: 80px;
            background: #f8f9fa;
            border-right: 1px solid #d0d0d0;
        }

        .time-slot {
            height: 35px;
            border-bottom: 1px solid #d0d0d0;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 11px;
            color: #2c3e50;
        }

        .resource-grid {
            flex: 1;
            display: flex;
            overflow-x: auto;
        }

        .resource-column {
            min-width: 180px;
            border-right: 1px solid #d0d0d0;
            position: relative;
        }

        .resource-header {
            height: 35px;
            background: #2c3e50;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 13px;
            border-bottom: 1px solid #d0d0d0;
        }

        .resource-slot {
            height: 35px;
            border-bottom: 1px solid #d0d0d0;
            background: #ffffff;
            position: relative;
        }

        .appointment-block {
            position: absolute;
            background: #ff520d;
            color: wheat;
            border-radius: 4px;
            padding: 3px 6px;
            font-size: 11px;
            cursor: move;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.2);
            z-index: 10;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            width: 90%;
            left: 5%;
            height: 30px;
            top: 2px;
        }

            .appointment-block:hover {
                transform: scale(1.03);
            }

        /* Media Queries for Mobile Responsiveness */
        @media (max-width: 768px) {
            .appointments-header {
                flex-direction: column;
                align-items: stretch;
                padding: 8px;
            }

                .appointments-header h1 {
                    font-size: 20px;
                    text-align: center;
                }

            .header-actions {
                justify-content: center;
                margin-top: 10px;
            }

            .calendar-container {
                padding: 8px;
            }

            .fc-daygrid-day {
                min-height: 70px;
            }

            .fc-event {
                font-size: 10px;
                padding: 3px 5px;
            }

            .fc .fc-toolbar {
                padding: 5px;
            }

            .fc .fc-toolbar-title {
                font-size: 16px;
            }

            .modal-dialog {
                margin: 0.5rem;
                max-width: 100%;
            }

            .modal-body {
                padding: 0.75rem;
            }

            .time-slot, .resource-header, .appointment-block {
                font-size: 10px;
            }

            .resource-column {
                min-width: 120px;
            }

            .tab-content > .tab-pane {
                padding: 0;
            }
        }

        @media (max-width: 576px) {
            .fc-daygrid-day {
                min-height: 60px;
            }

            .fc-event {
                font-size: 9px;
            }

            .btn {
                font-size: 12px;
                padding: 5px 10px;
            }

            .form-select, .form-control {
                font-size: 14px;
            }
        }
    </style>

    <div class="container-fluid">

        <header class="mb-4">
            <div class="row align-items-center">
                <div class="col-md-6">
                    <h1 class="page-title mb-3 mb-md-0">Dispatch Calendar</h1>
                </div>
                <div class="col-md-6 text-md-end">
                    <button class="btn btn-primary" onclick="openNewModal()">+ Create New</button>
                </div>
            </div>
        </header>

        <ul class="nav nav-tabs mb-3" id="viewTabs" role="tablist">
            <li class="nav-item" role="presentation">
                <button class="nav-link active" id="date-tab" data-bs-toggle="tab" data-bs-target="#dateView" type="button" role="tab" aria-controls="dateView" aria-selected="true">Date View</button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="resource-tab" data-bs-toggle="tab" data-bs-target="#resourceView" type="button" role="tab" aria-controls="resourceView" aria-selected="false">Resource View</button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="map-tab" data-bs-toggle="tab" data-bs-target="#mapView" type="button" role="tab" aria-controls="mapView" aria-selected="false">Map View</button>
            </li>
        </ul>

        <div class="tab-content" id="viewTabContent">
            <div class="tab-pane fade show active calendar-container" id="dateView" role="tabpanel" aria-labelledby="date-tab">
                <div class="mb-3 d-flex flex-wrap gap-2 align-items-center">
                    <select id="dateViewToggle" class="form-select" style="width: auto;" onchange="toggleDateView()">
                        <option value="month">Month</option>
                        <option value="week">Week</option>
                        <option value="day">Day</option>
                        <option value="list">List</option>
                    </select>
                    <div class="d-flex flex-wrap gap-2 align-items-center">
                        <label for="fromDate" class="form-label mb-0">From:</label>
                        <input type="date" id="fromDate" class="form-control" style="width: auto;">
                        <label for="toDate" class="form-label mb-0">To:</label>
                        <input type="date" id="toDate" class="form-control" style="width: auto;">
                        <button class="btn btn-primary" onclick="applyDateRange()">Search</button>
                    </div>
                    <button class="btn btn-warning" onclick="openUnscheduledModal()">Unscheduled Appointments</button>
                    <div class="dropdown filter-dropdown">
                        <button class="btn btn-outline-primary dropdown-toggle" type="button" id="filterButtonDate" aria-expanded="false">
                            <i class="fas fa-filter-circle-xmark"></i>Filters
                       
                        </button>
                        <div class="dropdown-menu" aria-labelledby="filterButtonDate">
                            <form id="filterFormDate" class="px-3 py-2">
                                <div class="mb-3">
                                    <label class="form-label">Types</label>
                                    <div id="typeFiltersDate">
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" id="filter-jobs-date" checked>
                                            <label class="form-check-label" for="filter-jobs-date">Jobs</label>
                                        </div>
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" id="filter-visits-date" checked>
                                            <label class="form-check-label" for="filter-visits-date">Visits</label>
                                        </div>
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" id="filter-tasks-date" checked>
                                            <label class="form-check-label" for="filter-tasks-date">Tasks</label>
                                        </div>
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Status</label>
                                    <div id="statusFiltersDate">
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" id="filter-scheduled-date" checked>
                                            <label class="form-check-label" for="filter-scheduled-date">Scheduled</label>
                                        </div>
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" id="filter-completed-date" checked>
                                            <label class="form-check-label" for="filter-completed-date">Completed</label>
                                        </div>
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" id="filter-ontheway-date" checked>
                                            <label class="form-check-label" for="filter-ontheway-date">On The Way</label>
                                        </div>
                                    </div>
                                </div>
                                <button type="button" class="btn btn-secondary btn-sm mt-2" onclick="clearFilters('date')">Clear Filters</button>
                            </form>
                        </div>
                    </div>
                    <div class="dropdown more-actions">
                        <button class="btn btn-outline-primary dropdown-toggle" type="button" id="moreActionsButton" aria-expanded="false">
                            More Actions
                       
                        </button>
                        <div class="dropdown-menu" aria-labelledby="moreActionsButton">
                            <a class="dropdown-item" href="#" onclick="exportCalendar()">Export Calendar</a>
                            <a class="dropdown-item" href="#" onclick="syncCalendar()">Sync Calendar</a>
                        </div>
                    </div>
                </div>
                <div id="calendar"></div>
                <div id="listView" class="list-view" style="display: none;"></div>
            </div>
            <div class="tab-pane fade calendar-container" id="resourceView" role="tabpanel" aria-labelledby="resource-tab">
                <div class="mb-3 d-flex flex-wrap gap-2 align-items-center">
                    <label for="resourceDatePicker" class="form-label mb-0">Select Date:</label>
                    <input type="date" id="resourceDatePicker" class="form-control" style="width: auto;" onchange="renderResourceView(this.value)">
                    <select id="dispatchGroupResource" class="form-select" style="width: auto;" onchange="renderResourceView($('#resourceDatePicker').val())">
                        <option value="all">All Dispatch Groups</option>
                        <option value="electricians">Electricians</option>
                        <option value="plumbers">Plumbers</option>
                    </select>
                    <select id="dispatchResource" class="form-select" style="width: auto;" onchange="renderResourceView($('#resourceDatePicker').val())">
                        <option value="all">All Times</option>
                        <option value="dispatchAll">Dispatch All</option>
                        <option value="morningAM">Morning/AM</option>
                        <option value="afternoonPM">Afternoon/PM</option>
                        <option value="8amEarlier">8 AM Morning and earlier</option>
                        <option value="10amEarlier">10 AM Morning and earlier</option>
                        <option value="12pmEarlier">12 PM Afternoon and earlier</option>
                        <option value="2pmEarlier">2 PM Afternoon and earlier</option>
                        <option value="4pmEarlier">4 PM Afternoon and earlier</option>
                        <option value="6pmEarlier">6 PM Afternoon and earlier</option>
                        <option value="after6pm">After 6 PM Afternoon</option>
                    </select>
                    <button class="btn btn-warning" onclick="openUnscheduledModal()">Unscheduled Appointments</button>
                    <div class="dropdown filter-dropdown">
                        <button class="btn btn-outline-primary dropdown-toggle" type="button" id="filterButtonResource" aria-expanded="false">
                            <i class="fas fa-filter-circle-xmark"></i>Filters
                       
                        </button>
                        <div class="dropdown-menu" aria-labelledby="filterButtonResource">
                            <form id="filterFormResource" class="px-3 py-2">
                                <div class="mb-3">
                                    <label class="form-label">Types</label>
                                    <div id="typeFiltersResource">
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" id="filter-jobs-resource" checked>
                                            <label class="form-check-label" for="filter-jobs-resource">Jobs</label>
                                        </div>
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" id="filter-visits-resource" checked>
                                            <label class="form-check-label" for="filter-visits-resource">Visits</label>
                                        </div>
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" id="filter-tasks-resource" checked>
                                            <label class="form-check-label" for="filter-tasks-resource">Tasks</label>
                                        </div>
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Status</label>
                                    <div id="statusFiltersResource">
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" id="filter-scheduled-resource" checked>
                                            <label class="form-check-label" for="filter-scheduled-resource">Scheduled</label>
                                        </div>
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" id="filter-completed-resource" checked>
                                            <label class="form-check-label" for="filter-completed-resource">Completed</label>
                                        </div>
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" id="filter-ontheway-resource" checked>
                                            <label class="form-check-label" for="filter-ontheway-resource">On The Way</label>
                                        </div>
                                    </div>
                                </div>
                                <button type="button" class="btn btn-secondary btn-sm mt-2" onclick="clearFilters('resource')">Clear Filters</button>
                            </form>
                        </div>
                    </div>
                </div>
                <div class="resource-view" id="resourceViewContainer">
                    <div class="time-column" id="timeColumn">
                        <div class="resource-header">Time Slot</div>
                    </div>
                    <div class="resource-grid" id="resourceGrid"></div>
                </div>
            </div>
            <div class="tab-pane fade calendar-container" id="mapView" role="tabpanel" aria-labelledby="map-tab">
                <div class="mb-3 d-flex flex-wrap gap-2 align-items-center">
                    <label for="mapDatePicker" class="form-label mb-0">Select Date:</label>
                    <input type="date" id="mapDatePicker" class="form-control" style="width: auto;" onchange="renderMapView()">
                    <select id="dispatchGroupMap" class="form-select" style="width: auto;" onchange="renderMapView()">
                        <option value="all">All Dispatch Groups</option>
                        <option value="electricians">Electricians</option>
                        <option value="plumbers">Plumbers</option>
                    </select>
                    <div class="dropdown filter-dropdown">
                        <button class="btn btn-outline-primary dropdown-toggle" type="button" id="filterButtonMap" aria-expanded="false">
                            <i class="fas fa-filter-circle-xmark"></i>Filters
                       
                        </button>
                        <div class="dropdown-menu" aria-labelledby="filterButtonMap">
                            <form id="filterFormMap" class="px-3 py-2">
                                <div class="mb-3">
                                    <label class="form-label">Work Order Status</label>
                                    <div id="statusFiltersMap">
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" id="filter-pending-map" checked>
                                            <label class="form-check-label" for="filter-pending-map">Pending</label>
                                        </div>
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" id="filter-dispatched-map" checked>
                                            <label class="form-check-label" for="filter-dispatched-map">Dispatched</label>
                                        </div>
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" id="filter-inRoute-map" checked>
                                            <label class="form-check-label" for="filter-inRoute-map">In Route</label>
                                        </div>
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" id="filter-arrived-map" checked>
                                            <label class="form-check-label" for="filter-arrived-map">Arrived</label>
                                        </div>
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" id="filter-completed-map" checked>
                                            <label class="form-check-label" for="filter-completed-map">Complete</label>
                                        </div>
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" id="filter-incomplete-map" checked>
                                            <label class="form-check-label" for="filter-incomplete-map">Incomplete</label>
                                        </div>
                                    </div>
                                </div>
                                <button type="button" class="btn btn-secondary btn-sm mt-2" onclick="clearFilters('map')">Clear Filters</button>
                            </form>
                        </div>
                    </div>
                </div>
                <div id="googleMap" class="map-view"></div>
            </div>
        </div>
    </div>

    <!-- New Appointment Modal -->
    <div class="modal fade" id="newModal" tabindex="-1" aria-labelledby="newModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="newModalLabel">Create New Appointment</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form id="newForm" onsubmit="createAppointment(event)">
                    <div class="modal-body">
                        <div class="row g-3">
                            <div class="col-md-6 col-12">
                                <label class="form-label">Customer</label>
                                <input type="text" name="customer" class="form-control" required>
                            </div>
                            <div class="col-md-6 col-12">
                                <label class="form-label">Type</label>
                                <select name="type" class="form-select" required>
                                    <option value="job">Job</option>
                                    <option value="visit">Visit</option>
                                    <option value="task">Task</option>
                                </select>
                            </div>
                            <div class="col-md-6 col-12">
                                <label class="form-label">Date</label>
                                <input type="date" name="date" class="form-control" required>
                            </div>
                            <div class="col-md-6 col-12">
                                <label class="form-label">Time Block</label>
                                <select name="timeBlock" class="form-select" required>
                                    <option value="0">12 AM Morning</option>
                                    <option value="1">1 AM Morning</option>
                                    <option value="2">2 AM Morning</option>
                                    <option value="3">3 AM Morning</option>
                                    <option value="4">4 AM Morning</option>
                                    <option value="5">5 AM Morning</option>
                                    <option value="6">6 AM Morning</option>
                                    <option value="7">7 AM Morning</option>
                                    <option value="8">8 AM Morning</option>
                                    <option value="9">9 AM Morning</option>
                                    <option value="10">10 AM Morning</option>
                                    <option value="11">11 AM Morning</option>
                                    <option value="12">12 PM Afternoon</option>
                                    <option value="13">1 PM Afternoon</option>
                                    <option value="14">2 PM Afternoon</option>
                                    <option value="15">3 PM Afternoon</option>
                                    <option value="16">4 PM Afternoon</option>
                                    <option value="17">5 PM Afternoon</option>
                                    <option value="18">6 PM Afternoon</option>
                                    <option value="19">7 PM Afternoon</option>
                                    <option value="20">8 PM Afternoon</option>
                                    <option value="21">9 PM Afternoon</option>
                                    <option value="22">10 PM Afternoon</option>
                                    <option value="23">11 PM Afternoon</option>
                                </select>
                            </div>
                            <div class="col-md-6 col-12">
                                <label class="form-label">Resource</label>
                                <select name="resource" class="form-select">
                                    <option value="Unassigned">Unassigned</option>
                                    <option value="Jim">Jim</option>
                                    <option value="Bob">Bob</option>
                                    <option value="Team1">Team 1</option>
                                </select>
                            </div>
                            <div class="col-md-6 col-12">
                                <label class="form-label">Location</label>
                                <input type="text" name="location" class="form-control" required>
                            </div>
                            <div class="col-12">
                                <label class="form-label">Notes</label>
                                <textarea name="notes" class="form-control" rows="3"></textarea>
                            </div>
                            <div class="col-12">
                                <label class="form-label">Checklist</label>
                                <textarea name="checklist" class="form-control" rows="3" placeholder="e.g., Check equipment"></textarea>
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

    <!-- Edit Appointment Modal -->
    <div class="modal fade" id="editModal" tabindex="-1" aria-labelledby="editModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="editModalLabel">Edit Appointment</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form id="editForm" onsubmit="updateAppointment(event)">
                    <div class="modal-body">
                        <input type="hidden" name="id">
                        <div class="row g-3">
                            <div class="col-md-6 col-12">
                                <label class="form-label">Customer</label>
                                <input type="text" name="customer" class="form-control" required>
                            </div>
                            <div class="col-md-6 col-12">
                                <label class="form-label">Type</label>
                                <select name="type" class="form-select" required>
                                    <option value="job">Job</option>
                                    <option value="visit">Visit</option>
                                    <option value="task">Task</option>
                                </select>
                            </div>
                            <div class="col-md-6 col-12">
                                <label class="form-label">Date</label>
                                <input type="date" name="date" class="form-control">
                            </div>
                            <div class="col-md-6 col-12">
                                <label class="form-label">Status</label>
                                <select name="status" class="form-select">
                                    <option value="pending">Pending</option>
                                    <option value="scheduled">Scheduled</option>
                                    <option value="completed">Completed</option>
                                    <option value="inRoute">In Route</option>
                                    <option value="arrived">Arrived</option>
                                    <option value="incomplete">Incomplete</option>
                                </select>
                            </div>
                            <div class="col-md-6 col-12">
                                <label class="form-label">Time Block</label>
                                <select name="timeBlock" class="form-select">
                                    <option value="0">12 AM Morning</option>
                                    <option value="1">1 AM Morning</option>
                                    <option value="2">2 AM Morning</option>
                                    <option value="3">3 AM Morning</option>
                                    <option value="4">4 AM Morning</option>
                                    <option value="5">5 AM Morning</option>
                                    <option value="6">6 AM Morning</option>
                                    <option value="7">7 AM Morning</option>
                                    <option value="8">8 AM Morning</option>
                                    <option value="9">9 AM Morning</option>
                                    <option value="10">10 AM Morning</option>
                                    <option value="11">11 AM Morning</option>
                                    <option value="12">12 PM Afternoon</option>
                                    <option value="13">1 PM Afternoon</option>
                                    <option value="14">2 PM Afternoon</option>
                                    <option value="15">3 PM Afternoon</option>
                                    <option value="16">4 PM Afternoon</option>
                                    <option value="17">5 PM Afternoon</option>
                                    <option value="18">6 PM Afternoon</option>
                                    <option value="19">7 PM Afternoon</option>
                                    <option value="20">8 PM Afternoon</option>
                                    <option value="21">9 PM Afternoon</option>
                                    <option value="22">10 PM Afternoon</option>
                                    <option value="23">11 PM Afternoon</option>
                                </select>
                            </div>
                            <div class="col-md-6 col-12">
                                <label class="form-label">Resource</label>
                                <select name="resource" class="form-select">
                                    <option value="Unassigned">Unassigned</option>
                                    <option value="Jim">Jim</option>
                                    <option value="Bob">Bob</option>
                                    <option value="Team1">Team 1</option>
                                </select>
                            </div>
                            <div class="col-md-6 col-12">
                                <label class="form-label">Location</label>
                                <input type="text" name="location" class="form-control" required>
                            </div>
                            <div class="col-12">
                                <label class="form-label">Notes</label>
                                <textarea name="notes" class="form-control" rows="3"></textarea>
                            </div>
                            <div class="col-12">
                                <label class="form-label">Checklist</label>
                                <textarea name="checklist" class="form-control" rows="3"></textarea>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" onclick="unscheduleAppointment()">Unschedule</button>
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Save</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Unscheduled Appointments Modal -->
    <div class="modal fade" id="unscheduledModal" tabindex="-1" aria-labelledby="unscheduledModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="unscheduledModalLabel">Unscheduled Appointments</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body" id="unscheduledList">
                    <!-- Unscheduled appointments will be populated here -->
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>
    <script>
        let appointments = [
            { id: 1, customer: "John Doe", type: "job", date: "2025-04-07", timeBlock: "9", resource: "Jim", status: "scheduled", location: "Main Office", notes: "Routine maintenance", checklist: "Inspect HVAC\nCheck filters", latitude: 40.7128, longitude: -74.0060 },
            { id: 2, customer: "Jane Smith", type: "visit", date: null, timeBlock: null, resource: "Unassigned", status: "pending", location: "Branch Office", notes: "Follow-up visit", checklist: "Check equipment", latitude: 34.0522, longitude: -118.2437 },
            { id: 3, customer: "Alice Johnson", type: "task", date: "2025-04-07", timeBlock: "14", resource: "Bob", status: "completed", location: "Warehouse", notes: "Urgent task", checklist: "Fix leak", latitude: 41.8781, longitude: -87.6298 },
            { id: 4, customer: "Mike Brown", type: "job", date: "2025-04-07", timeBlock: "8", resource: "Team1", status: "scheduled", location: "Downtown", notes: "Install system", checklist: "Check wiring", latitude: 42.3601, longitude: -71.0589 },
            { id: 5, customer: "Sarah Davis", type: "visit", date: "2025-04-07", timeBlock: "15", resource: "Jim", status: "inRoute", location: "Suburb", notes: "Client meeting", checklist: "Discuss updates", latitude: 39.9526, longitude: -75.1652 }
        ];
        let currentView = "date";
        let currentDateView = "month";
        let calendar;
        let currentEditId = null;
        let currentPage = 1;
        const itemsPerPage = 5;
        const resources = ["Jim", "Bob", "Team1", "Unassigned"];
        const timeSlots = [
            "12 AM Morning", "1 AM Morning", "2 AM Morning", "3 AM Morning", "4 AM Morning", "5 AM Morning",
            "6 AM Morning", "7 AM Morning", "8 AM Morning", "9 AM Morning", "10 AM Morning", "11 AM Morning",
            "12 PM Afternoon", "1 PM Afternoon", "2 PM Afternoon", "3 PM Afternoon", "4 PM Afternoon", "5 PM Afternoon",
            "6 PM Afternoon", "7 PM Afternoon", "8 PM Afternoon", "9 PM Afternoon", "10 PM Afternoon", "11 PM Afternoon"
        ];
        let map;
        let markers = [];

        const technicianGroups = {
            "electricians": ["Jim", "Bob"],
            "plumbers": ["Team1"]
        };

        document.addEventListener('DOMContentLoaded', function () {
            const today = new Date().toISOString().split('T')[0];
            $("#resourceDatePicker").val(today);
            $("#mapDatePicker").val(today);
            $("#fromDate").val(today);
            $("#toDate").val(today);

            const calendarEl = document.getElementById('calendar');
            if (!calendarEl) {
                console.error("Calendar element not found!");
                return;
            }

            calendar = new FullCalendar.Calendar(calendarEl, {
                initialView: 'dayGridMonth',
                initialDate: today,
                headerToolbar: {
                    left: 'prev,next today',
                    center: 'title',
                    right: ''
                },
                events: function (fetchInfo, successCallback) {
                    const fromDate = $("#fromDate").val();
                    const toDate = $("#toDate").val();
                    const filteredEvents = appointments
                        .filter(a => {
                            const typeFilters = getTypeFilters("date");
                            const statusFilters = getStatusFilters("date");
                            const dateInRange = !a.date || (a.date >= fromDate && a.date <= toDate);
                            return a.date && typeFilters[a.type] &&
                                (statusFilters[a.status] || (a.status === "pending" && statusFilters.ontheway)) &&
                                dateInRange;
                        })
                        .map(a => ({
                            id: a.id.toString(),
                            title: `${a.customer} (${a.type}) - ${a.resource}`,
                            start: `${a.date}T${a.timeBlock.padStart(2, '0')}:00:00`,
                            end: `${a.date}T${(parseInt(a.timeBlock) + 1).toString().padStart(2, '0')}:00:00`,
                            extendedProps: a,
                            backgroundColor: getEventColor(a.status),
                            textColor: "wheat"
                        }));
                    successCallback(filteredEvents);
                },
                eventClick: function (info) {
                    info.jsEvent.preventDefault();
                    openEditModal(parseInt(info.event.id));
                },
                dateClick: function (info) {
                    showDateDropdown(info);
                },
                eventDrop: function (info) {
                    const appointment = appointments.find(a => a.id === parseInt(info.event.id));
                    if (appointment) {
                        appointment.date = info.event.start.toISOString().split('T')[0];
                        appointment.timeBlock = info.event.start.getHours().toString();
                        appointment.status = "scheduled";
                        updateAllViews();
                    } else {
                        info.revert();
                    }
                },
                editable: true,
                droppable: true,
                dayMaxEvents: 3,
                moreLinkClick: "popover",
                slotMinTime: "00:00:00",
                slotMaxTime: "24:00:00",
                slotDuration: "01:00:00",
                slotLabelInterval: "01:00:00",
                slotLabelFormat: {
                    hour: 'numeric',
                    minute: '2-digit',
                    meridiem: 'short'
                },
                allDaySlot: false,
                height: 'auto'
            });

            calendar.render();

            $("#filterButtonDate, #filterButtonResource, #filterButtonMap").click(toggleDropdown);
            $("#moreActionsButton").click(toggleMoreActions);

            $("#filter-jobs-date, #filter-visits-date, #filter-tasks-date, #filter-scheduled-date, #filter-completed-date, #filter-ontheway-date").change(() => applyFilters("date"));
            $("#filter-jobs-resource, #filter-visits-resource, #filter-tasks-resource, #filter-scheduled-resource, #filter-completed-resource, #filter-ontheway-resource").change(() => applyFilters("resource"));
            $("#filter-pending-map, #filter-dispatched-map, #filter-inRoute-map, #filter-arrived-map, #filter-completed-map, #filter-incomplete-map").change(() => applyFilters("map"));

            $('#viewTabs a').on('shown.bs.tab', function (e) {
                currentView = e.target.id === "date-tab" ? "date" : e.target.id === "resource-tab" ? "resource" : "map";
                updateAllViews();
            });

            renderResourceView(today);
        });

        function getEventColor(status) {
            const colors = {
                "scheduled": "#ff520d",
                "completed": "#2196F3",
                "pending": "#ff9800",
                "inRoute": "#FFA500",
                "arrived": "#800080",
                "incomplete": "#FF0000"
            };
            return colors[status] || "#ff520d";
        }

        function initMap() {
            map = new google.maps.Map(document.getElementById("googleMap"), {
                center: { lat: 37.0902, lng: -95.7129 },
                zoom: 4
            });
            renderMapView();
        }

        function toggleDropdown(event) {
            event.preventDefault();
            $(event.currentTarget).siblings(".dropdown-menu").toggleClass("show");
        }

        function toggleMoreActions(event) {
            event.preventDefault();
            $("#moreActionsButton").siblings(".dropdown-menu").toggleClass("show");
        }

        function getStatusFilters(view) {
            if (view === "map") {
                return {
                    pending: $("#filter-pending-map").is(":checked"),
                    scheduled: $("#filter-dispatched-map").is(":checked"),
                    inRoute: $("#filter-inRoute-map").is(":checked"),
                    arrived: $("#filter-arrived-map").is(":checked"),
                    completed: $("#filter-completed-map").is(":checked"),
                    incomplete: $("#filter-incomplete-map").is(":checked")
                };
            }
            return {
                scheduled: $(`#filter-scheduled-${view}`).is(":checked"),
                completed: $(`#filter-completed-${view}`).is(":checked"),
                ontheway: $(`#filter-ontheway-${view}`).is(":checked")
            };
        }

        function getTypeFilters(view) {
            return {
                job: $(`#filter-jobs-${view}`).is(":checked"),
                visit: $(`#filter-visits-${view}`).is(":checked"),
                task: $(`#filter-tasks-${view}`).is(":checked")
            };
        }

        function showDateDropdown(info) {
            $(".date-dropdown").remove();
            const dateStr = info.dateStr;
            const formattedDate = new Date(dateStr).toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
            const $dropdown = $(`
                <div class="date-dropdown">
                    <div class="dropdown-header">Add to ${formattedDate}</div>
                    <div class="dropdown-item" onclick="openNewModal('job', '${dateStr}')"><i class="fas fa-wrench text-success"></i> New Job</div>
                    <div class="dropdown-item" onclick="openNewModal('visit', '${dateStr}')"><i class="fas fa-download text-warning"></i> New Visit</div>
                    <div class="dropdown-item" onclick="openNewModal('task', '${dateStr}')"><i class="fas fa-check-square text-secondary"></i> New Task</div>
                    <h4></h4>
                    <div class="dropdown-item" onclick="showDayView('${dateStr}')"><i class="fas fa-th-list"></i> Show on Day View</div>
                </div>
            `);

            $('body').append($dropdown);
            const dropdownWidth = $dropdown.outerWidth();
            const windowWidth = $(window).width();
            const clickX = info.jsEvent.pageX;
            let leftPosition = clickX + 10;
            if (clickX + dropdownWidth > windowWidth) leftPosition = clickX - dropdownWidth - 10;

            $dropdown.css({ top: info.jsEvent.pageY + 10, left: leftPosition });
            $(document).on('click', function (e) {
                if (!$(e.target).closest('.date-dropdown').length) $dropdown.remove();
            });
        }

        function showDayView(date) {
            currentDateView = "day";
            $("#dateViewToggle").val("day");
            calendar.changeView("timeGridDay", date);
            $("#calendar").show();
            $("#listView").hide();
        }

        function toggleDateView() {
            currentDateView = $("#dateViewToggle").val();
            $("#calendar").hide();
            $("#listView").hide();

            if (currentDateView === "month") {
                calendar.changeView("dayGridMonth");
                $("#calendar").show();
            } else if (currentDateView === "week") {
                calendar.changeView("timeGridWeek");
                $("#calendar").show();
            } else if (currentDateView === "day") {
                calendar.changeView("timeGridDay");
                $("#calendar").show();
            } else if (currentDateView === "list") {
                renderListView();
                $("#listView").show();
            }
            calendar.render();
        }

        function applyDateRange() {
            const fromDate = $("#fromDate").val();
            const toDate = $("#toDate").val();
            if (fromDate && toDate && new Date(fromDate) <= new Date(toDate)) {
                updateAllViews();
            } else {
                alert("Please select valid From and To dates.");
            }
        }

        function renderResourceView(date) {
            const timeColumn = $("#timeColumn");
            const resourceGrid = $("#resourceGrid");
            const selectedDispatch = $("#dispatchResource").val();
            const selectedGroup = $("#dispatchGroupResource").val();
            const typeFilters = getTypeFilters("resource");
            const statusFilters = getStatusFilters("resource");

            timeColumn.html('<div class="resource-header">Time Slot</div>' + timeSlots.map(slot => `<div class="time-slot">${slot}</div>`).join(''));

            let filteredResources = selectedGroup === "all" ? resources : (technicianGroups[selectedGroup] || []);
            resourceGrid.html(filteredResources.map(resource => `
                <div class="resource-column" data-resource="${resource}">
                    <div class="resource-header">${resource}</div>
                    ${timeSlots.map((_, i) => `<div class="resource-slot" data-hour="${i}" data-resource="${resource}"></div>`).join('')}
                </div>
            `).join(''));

            const filteredAppointments = appointments.filter(a => {
                const resourceMatch = selectedGroup === "all" || filteredResources.includes(a.resource);
                const typeMatch = typeFilters[a.type];
                const statusMatch = statusFilters[a.status] || (a.status === "pending" && statusFilters.ontheway);
                let dispatchMatch = true;
                if (selectedDispatch !== "all") {
                    const hour = parseInt(a.timeBlock);
                    dispatchMatch = selectedDispatch === "dispatchAll" ? a.resource !== "Unassigned" :
                        selectedDispatch === "morningAM" ? hour < 12 :
                            selectedDispatch === "afternoonPM" ? hour >= 12 :
                                selectedDispatch === "8amEarlier" ? hour <= 8 :
                                    selectedDispatch === "10amEarlier" ? hour <= 10 :
                                        selectedDispatch === "12pmEarlier" ? hour <= 12 :
                                            selectedDispatch === "2pmEarlier" ? hour <= 14 :
                                                selectedDispatch === "4pmEarlier" ? hour <= 16 :
                                                    selectedDispatch === "6pmEarlier" ? hour <= 18 :
                                                        selectedDispatch === "after6pm" ? hour > 18 : true;
                }
                return a.date === date && resourceMatch && typeMatch && statusMatch && dispatchMatch;
            });

            filteredAppointments.forEach(a => {
                const slot = $(`.resource-slot[data-hour="${a.timeBlock}"][data-resource="${a.resource}"]`);
                if (slot.length) {
                    slot.html(`
                        <div class="appointment-block" data-id="${a.id}" draggable="true" style="background-color: ${getEventColor(a.status)};">
                            ${a.customer} (${a.type})
                        </div>
                    `);
                }
            });

            $(".appointment-block").draggable({
                containment: "#resourceViewContainer",
                revert: "invalid",
                zIndex: 1000,
                start: function () { $(this).addClass("ui-draggable-dragging"); },
                stop: function () { $(this).removeClass("ui-draggable-dragging"); }
            });

            $(".resource-slot").droppable({
                accept: ".appointment-block",
                tolerance: "pointer",
                drop: function (event, ui) {
                    const appointmentId = ui.draggable.data("id");
                    const appointment = appointments.find(a => a.id === appointmentId);
                    if (appointment) {
                        appointment.timeBlock = $(this).data("hour").toString();
                        appointment.resource = $(this).data("resource");
                        appointment.status = "scheduled";
                        renderResourceView(date);
                        calendar.refetchEvents();
                        if (currentDateView === "list") renderListView();
                    }
                }
            });
        }

        function renderMapView() {
            const selectedDate = $("#mapDatePicker").val();
            const selectedGroup = $("#dispatchGroupMap").val();
            const statusFilters = getStatusFilters("map");
            markers.forEach(marker => marker.setMap(null));
            markers = [];

            const bounds = new google.maps.LatLngBounds();
            const filteredAppointments = appointments.filter(a =>
                a.latitude && a.longitude && a.date === selectedDate &&
                statusFilters[a.status] &&
                (selectedGroup === "all" || (technicianGroups[selectedGroup] && technicianGroups[selectedGroup].includes(a.resource)))
            );

            filteredAppointments.forEach(a => {
                const position = { lat: parseFloat(a.latitude), lng: parseFloat(a.longitude) };
                const marker = new google.maps.Marker({
                    position,
                    map,
                    title: `${a.customer} (${a.type}) - ${a.status}`,
                    icon: `http://maps.google.com/mapfiles/ms/icons/${a.status === "pending" ? "yellow" : a.status === "inRoute" ? "orange" : a.status === "arrived" ? "purple" : a.status === "completed" ? "green" : a.status === "incomplete" ? "red" : "blue"}-dot.png`
                });
                marker.addListener('click', () => openEditModal(a.id));
                markers.push(marker);
                bounds.extend(position);
            });

            if (filteredAppointments.length) map.fitBounds(bounds);
        }

        function renderListView(page = currentPage) {
            currentPage = page;
            const container = $("#listView");
            const scheduled = appointments.filter(a => a.date && a.status !== "pending");
            const startIndex = (page - 1) * itemsPerPage;
            const endIndex = startIndex + itemsPerPage;
            const paginatedItems = scheduled.slice(startIndex, endIndex);
            const totalPages = Math.ceil(scheduled.length / itemsPerPage);

            container.html(`
                ${paginatedItems.map(a => `
                    <div class="card mb-3 appointment-card" data-id="${a.id}">
                        <div class="card-header" onclick="toggleCard(${a.id})">
                            <div class="d-flex justify-content-between align-items-center">
                                <div><span class="status-indicator ${a.status}"></span><strong>${a.customer}</strong></div>
                                <span>${a.date ? new Date(a.date).toLocaleDateString() : "Unscheduled"} ${a.timeBlock ? timeSlots[parseInt(a.timeBlock)] : ""}</span>
                            </div>
                        </div>
                        <div class="card-body" id="card-body-${a.id}">
                            <p>Type: ${a.type} | Resource: ${a.resource} | Location: ${a.location} | Status: ${a.status}</p>
                            <p>Notes: ${a.notes || "None"}</p>
                            <p>Checklist: ${a.checklist ? a.checklist.replace(/\n/g, '<br>') : "None"}</p>
                            <div class="d-flex gap-2 flex-wrap">
                                <button class="btn btn-primary btn-sm" onclick="openEditModal(${a.id})">Edit</button>
                                <button class="btn btn-success btn-sm" onclick="dispatch(${a.id})">Dispatch</button>
                                <button class="btn btn-info btn-sm" onclick="complete(${a.id})">Complete</button>
                                <button class="btn btn-warning btn-sm" onclick="openResourceModal(${a.id})">Assign Resource</button>
                                <button class="btn btn-secondary btn-sm" onclick="openSiteInfoModal(${a.id})">Site Info</button>
                            </div>
                        </div>
                    </div>
                `).join("")}
                <nav aria-label="List view pagination">
                    <ul class="pagination">
                        <li class="page-item ${currentPage === 1 ? 'disabled' : ''}"><a class="page-link" href="#" onclick="renderListView(${currentPage - 1})">Previous</a></li>
                        ${Array.from({ length: totalPages }, (_, i) => `
                            <li class="page-item ${currentPage === i + 1 ? 'active' : ''}"><a class="page-link" href="#" onclick="renderListView(${i + 1})">${i + 1}</a></li>
                        `).join('')}
                        <li class="page-item ${currentPage === totalPages ? 'disabled' : ''}"><a class="page-link" href="#" onclick="renderListView(${currentPage + 1})">Next</a></li>
                    </ul>
                </nav>
            `);
        }

        function toggleCard(id) {
            $(`.appointment-card[data-id="${id}"]`).toggleClass("expanded");
        }

        function applyFilters(view) {
            updateAllViews();
        }

        function clearFilters(view) {
            if (view === "map") {
                $("#filter-pending-map, #filter-dispatched-map, #filter-inRoute-map, #filter-arrived-map, #filter-completed-map, #filter-incomplete-map").prop("checked", true);
            } else {
                $(`#filter-jobs-${view}, #filter-visits-${view}, #filter-tasks-${view}, #filter-scheduled-${view}, #filter-completed-${view}, #filter-ontheway-${view}`).prop("checked", true);
            }
            applyFilters(view);
        }

        function exportCalendar() {
            alert("Exporting calendar...");
        }

        function syncCalendar() {
            alert("Syncing calendar...");
        }

        function openNewModal(type = null, date = null) {
            const modal = new bootstrap.Modal($("#newModal")[0]);
            const form = $("#newForm")[0];
            form.reset();
            if (date) form.querySelector("[name='date']").value = date;
            if (type) form.querySelector("[name='type']").value = type;
            modal.show();
        }

        function createAppointment(e) {
            e.preventDefault();
            const form = new FormData(e.target);
            const newAppointment = {
                id: appointments.length + 1,
                customer: form.get("customer"),
                type: form.get("type"),
                date: form.get("date") || null,
                timeBlock: form.get("timeBlock") || null,
                resource: form.get("resource"),
                status: form.get("date") ? "scheduled" : "pending",
                location: form.get("location"),
                notes: form.get("notes"),
                checklist: form.get("checklist"),
                latitude: null,
                longitude: null
            };
            appointments.push(newAppointment);

            if (newAppointment.date) {
                $("#fromDate").val(newAppointment.date);
                $("#toDate").val(newAppointment.date);
                calendar.gotoDate(newAppointment.date);
            }

            if (currentView === "resource" && newAppointment.date) {
                $("#resourceDatePicker").val(newAppointment.date);
            }

            updateAllViews();
            bootstrap.Modal.getInstance($("#newModal")[0]).hide();
        }

        function openEditModal(id) {
            const a = appointments.find(x => x.id === id);
            currentEditId = id;
            const form = $("#editForm")[0];
            form.querySelector("[name='id']").value = a.id;
            form.querySelector("[name='customer']").value = a.customer;
            form.querySelector("[name='type']").value = a.type;
            form.querySelector("[name='date']").value = a.date || "";
            form.querySelector("[name='timeBlock']").value = a.timeBlock || "0";
            form.querySelector("[name='resource']").value = a.resource;
            form.querySelector("[name='location']").value = a.location;
            form.querySelector("[name='status']").value = a.status;
            form.querySelector("[name='notes']").value = a.notes || "";
            form.querySelector("[name='checklist']").value = a.checklist || "";
            new bootstrap.Modal($("#editModal")[0]).show();
        }

        function updateAppointment(e) {
            e.preventDefault();
            const form = new FormData(e.target);
            const a = appointments.find(x => x.id === parseInt(form.get("id")));
            if (a) {
                a.customer = form.get("customer");
                a.type = form.get("type");
                a.date = form.get("date") || null;
                a.timeBlock = form.get("timeBlock") || null;
                a.resource = form.get("resource");
                a.location = form.get("location");
                a.status = form.get("date") ? "scheduled" : form.get("status");
                a.notes = form.get("notes");
                a.checklist = form.get("checklist");
                a.latitude = null;
                a.longitude = null;

                if (currentView === "resource" && a.date) {
                    $("#resourceDatePicker").val(a.date);
                    $("#dispatchResource").val("all");
                }

                updateAllViews();
                bootstrap.Modal.getInstance($("#editModal")[0]).hide();
                currentEditId = null;
            }
        }

        function unscheduleAppointment() {
            const a = appointments.find(x => x.id === currentEditId);
            if (a) {
                a.date = null;
                a.timeBlock = null;
                a.status = "pending";
                updateAllViews();
                bootstrap.Modal.getInstance($("#editModal")[0]).hide();
                currentEditId = null;
            }
        }

        function openUnscheduledModal() {
            if (currentView === "map") return;
            const modal = new bootstrap.Modal($("#unscheduledModal")[0]);
            const unscheduledList = $("#unscheduledList");
            const unscheduledAppointments = appointments.filter(a => !a.date || a.status === "pending");

            unscheduledList.html(unscheduledAppointments.length === 0 ? '<p class="text-center">No unscheduled appointments found.</p>' :
                unscheduledAppointments.map(a => `
                    <div class="card mb-3">
                        <div class="card-body">
                            <h6>${a.customer} (${a.type})</h6>
                            <p>Location: ${a.location}<br>Resource: ${a.resource}<br>Notes: ${a.notes || "None"}</p>
                            <button class="btn btn-primary btn-sm" onclick="rescheduleAppointment(${a.id})">Reschedule</button>
                        </div>
                    </div>
                `).join(""));
            modal.show();
        }

        function rescheduleAppointment(id) {
            bootstrap.Modal.getInstance($("#unscheduledModal")[0]).hide();
            openEditModal(id);
        }

        function dispatch(id) {
            const a = appointments.find(x => x.id === id);
            if (a.resource === "Unassigned") {
                alert("Please assign a resource before dispatching.");
                openResourceModal(id);
            } else {
                a.status = "scheduled";
                updateAllViews();
                alert(`Appointment #${id} dispatched to ${a.resource}`);
            }
        }

        function complete(id) {
            const a = appointments.find(x => x.id === id);
            a.status = "completed";
            updateAllViews();
            alert(`Appointment #${id} marked as completed`);
        }

        function openResourceModal(id) {
            alert(`Assign resource for appointment #${id}`);
        }

        function openSiteInfoModal(id) {
            alert(`View site info for appointment #${id}`);
        }

        function updateAllViews() {
            if (currentView === "date") {
                calendar.refetchEvents();
                if (currentDateView === "list") renderListView();
            } else if (currentView === "resource") {
                renderResourceView($("#resourceDatePicker").val());
            } else if (currentView === "map") {
                renderMapView();
            }
        }
    </script>
</asp:Content>
