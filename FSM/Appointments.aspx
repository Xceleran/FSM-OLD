<%@ Page Title="Appointments" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="Appointments.aspx.cs" Inherits="FSM.Appointments" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" integrity="sha512-DTOQO9RWCH3ppGqcWaEA1BIZOC6xxalwEsw9c2QQeAIftl+Vegovlnee1c9QX4TctnWMn13TZye+giMm8e2LwA==" crossorigin="anonymous" referrerpolicy="no-referrer" />
    <!-- FullCalendar CSS -->
    <link href="https://cdn.jsdelivr.net/npm/fullcalendar@5.11.5/main.min.css" rel="stylesheet">
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
        }

        .container-fluid {
            padding: 20px;
            margin-top: 50px;
            max-width: 100%;
            position: relative;
            overflow: visible;
        }

        .appointments-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
            background: #ffffff;
            padding: 15px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

            .appointments-header h1 {
                font-size: 28px;
                font-weight: 700;
                color: #2c3e50;
                margin: 0;
            }

        .header-actions {
            display: flex;
            gap: 12px;
            align-items: center;
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
            border-radius: 12px;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
            padding: 20px;
            position: relative;
            border: 1px solid #e0e0e0;
            overflow: visible;
        }

        .fc-event {
            background-color: #ff520d;
            color: wheat;
            border: none;
            border-radius: 6px;
            padding: 6px 10px;
            font-size: 13px;
            cursor: pointer;
            margin: 3px;
            white-space: normal;
            min-height: 28px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
            transition: transform 0.2s ease;
        }

            .fc-event:hover {
                transform: scale(1.02);
            }

        .fc-daygrid-day {
            min-height: 120px;
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
            padding: 10px;
            border-radius: 8px 8px 0 0;
        }

        .fc .fc-toolbar-title {
            margin-left: 10px;
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

        .list-view, .map-view {
            padding: 15px;
            background: #ffffff;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        .map-view {
            height: 500px;
            background: #e9ecef;
            display: flex;
            align-items: center;
            justify-content: center;
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
            width: 12px;
            height: 12px;
            border-radius: 50%;
            display: inline-block;
            margin-right: 8px;
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

        .ui-draggable-dragging {
            z-index: 1000;
            opacity: 0.9;
        }

        .date-dropdown {
            position: absolute;
            z-index: 2000; /* Increased z-index to ensure it stays above other elements */
            background: #ffffff;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            border-radius: 6px;
            max-width: 250px; /* Limit width to prevent excessive stretching */
        }

            .date-dropdown .dropdown-item {
                padding: 6px 15px;
                font-size: 14px;
                display: flex;
                align-items: center;
                gap: 8px;
                color: #2c3e50;
            }

            .date-dropdown .dropdown-item:hover {
                background: #f8f9fa;
            }

            .date-dropdown h4 {
                margin: 8px 0;
                padding: 4px 15px;
                border-top: 1px solid #e0e0e0;
                border-bottom: 1px solid #e0e0e0;
                font-size: 14px;
                color: #2c3e50;
                text-align: center;
            }

            .date-dropdown .dropdown-header {
                padding: 8px 15px;
                font-weight: bold;
                background-color: #2c3e50;
                color: white;
                border-radius: 6px 6px 0 0;
            }

        .fc-timegrid-slot {
            height: 40px;
        }

        .fc-timegrid-col {
            min-width: 100px;
        }

        .modal-content {
            border-radius: 12px;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.2);
        }

        .modal-header {
         
            border-radius: 12px 12px 0 0;
        }

        .modal-footer {
            border-top: 1px solid #e0e0e0;
        }

        .pagination {
            margin-top: 20px;
            justify-content: center;
        }

        .form-switch .form-check-input {
            width: 2em;
            height: 1em;
        }

        @media (max-width: 767px) {
            .appointments-header {
                flex-direction: column;
                align-items: flex-start;
                padding: 10px;
            }

            .header-actions {
                width: 100%;
                flex-wrap: wrap;
                justify-content: center;
            }

            .calendar-container {
                padding: 10px;
            }

            .fc-daygrid-day {
                min-height: 80px;
            }

            .fc-event {
                font-size: 10px;
                padding: 4px 6px;
            }

            .modal-dialog {
                margin: 0.5rem;
            }

            .modal-body {
                padding: 1rem;
            }
        }
    </style>

    <div class="container-fluid">
        <header class="appointments-header">
            <h1>Dispatch Calendar</h1>
            <div class="header-actions">
                <select id="viewToggle" class="form-select view-toggle" onchange="toggleView()" style="width: auto;">
                    <option value="month">Month</option>
                    <option value="week">Week</option>
                    <option value="day">Day</option>
                    <option value="list">List</option>
                    <option value="map">Map</option>
                </select>
                <div class="dropdown filter-dropdown">
                    <button class="btn btn-outline-primary dropdown-toggle" type="button" id="filterButton" aria-expanded="false">
                        <i class="fas fa-filter-circle-xmark"></i> Filters
                    </button>
                    <div class="dropdown-menu" aria-labelledby="filterButton">
                        <form id="filterForm" class="px-3 py-2">
                            <div class="mb-3">
                                <label class="form-label">Types</label>
                                <div id="typeFilters">
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" id="filter-jobs" checked>
                                        <label class="form-check-label" for="filter-jobs">Jobs</label>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" id="filter-visits" checked>
                                        <label class="form-check-label" for="filter-visits">Visits</label>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" id="filter-tasks" checked>
                                        <label class="form-check-label" for="filter-tasks">Tasks</label>
                                    </div>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Status</label>
                                <div id="statusFilters">
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" id="filter-scheduled" checked>
                                        <label class="form-check-label" for="filter-scheduled">Scheduled</label>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" id="filter-completed" checked>
                                        <label class="form-check-label" for="filter-completed">Completed</label>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" id="filter-ontheway" checked>
                                        <label class="form-check-label" for="filter-ontheway">On The Way</label>
                                    </div>
                                </div>
                            </div>
                            <button type="button" class="btn btn-secondary btn-sm mt-2" onclick="clearFilters()">Clear Filters</button>
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
                <button class="btn btn-warning" onclick="openUnscheduledModal()">Unscheduled Appointments</button>
                <button class="btn btn-primary" onclick="openNewModal()">+ Create New</button>
            </div>
        </header>

        <div class="row">
            <div class="col-12 calendar-container">
                <div id="calendar"></div>
                <div id="listView" class="list-view" style="display: none;"></div>
                <div id="mapView" class="map-view" style="display: none;">Map View Placeholder (Integrate with Google Maps API)</div>
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
                            <div class="col-12 col-md-6">
                                <label class="form-label">Customer</label>
                                <input type="text" name="customer" class="form-control" required>
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label">Type</label>
                                <select name="type" class="form-select" required>
                                    <option value="job">Job</option>
                                    <option value="visit">Visit</option>
                                    <option value="task">Task</option>
                                </select>
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label">Date</label>
                                <input type="date" name="date" class="form-control" required>
                            </div>
                            <div class="col-12 col-md-12">
                                <label class="form-label">Time Block</label>
                                <select name="timeBlock" class="form-select" required>
                                    <option value="morning">Morning (8:00 AM - 11:59 AM)</option>
                                    <option value="afternoon">Afternoon (12:00 PM - 4:00 PM)</option>
                                </select>
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label">Resource</label>
                                <select name="resource" class="form-select">
                                    <option value="Unassigned">Unassigned</option>
                                    <option value="Jim">Jim</option>
                                    <option value="Bob">Bob</option>
                                    <option value="Team1">Team 1</option>
                                </select>
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label">Location</label>
                                <input type="text" name="location" class="form-control" value="Main Office" required>
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
                            <div class="col-12 col-md-6">
                                <label class="form-label">Customer</label>
                                <input type="text" name="customer" class="form-control" required>
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label">Type</label>
                                <select name="type" class="form-select" required>
                                    <option value="job">Job</option>
                                    <option value="visit">Visit</option>
                                    <option value="task">Task</option>
                                </select>
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label">Date</label>
                                <input type="date" name="date" class="form-control">
                            </div>

                            <div class="col-12 col-md-6">
                                <label class="form-label">Status</label>
                                <select name="status" class="form-select">
                                    <option value="pending">Pending</option>
                                    <option value="scheduled">Scheduled</option>
                                    <option value="completed">Completed</option>
                                </select>
                            </div>
                            <div class="col-12 col-md-12">
                                <label class="form-label">Time Block</label>
                                <select name="timeBlock" class="form-select">
                                    <option value="morning">Morning (8:00 AM - 11:59 AM)</option>
                                    <option value="afternoon">Afternoon (12:00 PM - 4:00 PM)</option>
                                </select>
                            </div>
                            <div class="col-12 col-md-6">
                                <label class="form-label">Resource</label>
                                <select name="resource" class="form-select">
                                    <option value="Unassigned">Unassigned</option>
                                    <option value="Jim">Jim</option>
                                    <option value="Bob">Bob</option>
                                    <option value="Team1">Team 1</option>
                                </select>
                            </div>
                            <div class="col-12 col-md-6">
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
            { id: 1, customer: "John Doe", type: "job", date: "2025-04-03", timeBlock: "morning", resource: "Jim", status: "scheduled", location: "Main Office", notes: "Routine maintenance check", checklist: "Inspect HVAC\nCheck filters" },
            { id: 2, customer: "Jane Smith", type: "visit", date: null, timeBlock: null, resource: "Unassigned", status: "pending", location: "Branch Office", notes: "Follow-up visit", checklist: "Check equipment" },
            { id: 3, customer: "Alice Johnson", type: "task", date: "2025-04-05", timeBlock: "afternoon", resource: "Bob", status: "scheduled", location: "Warehouse", notes: "Urgent task", checklist: "Fix leak" }
        ];
        let currentView = "month";
        let showWeekends = true;
        let calendar;
        let currentEditId = null;
        let currentPage = 1;
        const itemsPerPage = 5;

        document.addEventListener('DOMContentLoaded', function () {
            const calendarEl = document.getElementById('calendar');
            if (!calendarEl) {
                console.error("Calendar element not found!");
                return;
            }

            calendar = new FullCalendar.Calendar(calendarEl, {
                initialView: 'dayGridMonth',
                initialDate: '2025-04-04',
                headerToolbar: {
                    left: 'prev,next today',
                    center: 'title',
                    right: ''
                },
                events: function (fetchInfo, successCallback, failureCallback) {
                    const filteredEvents = appointments
                        .filter(a => {
                            const typeFilters = {
                                job: $("#filter-jobs").is(":checked"),
                                visit: $("#filter-visits").is(":checked"),
                                task: $("#filter-tasks").is(":checked")
                            };
                            const statusFilters = {
                                scheduled: $("#filter-scheduled").is(":checked"),
                                completed: $("#filter-completed").is(":checked"),
                                ontheway: $("#filter-ontheway").is(":checked")
                            };
                            return a.date && typeFilters[a.type] &&
                                (statusFilters[a.status] || (a.status === "pending" && statusFilters.ontheway));
                        })
                        .map(a => {
                            const startTime = a.timeBlock === "morning" ? "08:00" : "12:00";
                            const endTime = a.timeBlock === "morning" ? "11:59" : "16:00";
                            return {
                                id: a.id.toString(),
                                title: `${a.customer} (${a.type}) - ${a.resource}`,
                                start: `${a.date}T${startTime}`,
                                end: `${a.date}T${endTime}`,
                                extendedProps: a,
                                backgroundColor: a.status === "scheduled" ? "#ff520d" : a.status === "completed" ? "#2196F3" : "#ff9800",
                                textColor: "wheat"
                            };
                        });
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
                        const newDate = info.event.start.toISOString().split('T')[0];
                        const newTime = info.event.start.getHours() < 12 ? "morning" : "afternoon";
                        appointment.date = newDate;
                        appointment.timeBlock = newTime;
                        appointment.status = "scheduled";
                        calendar.refetchEvents();
                        if (currentView === "list") renderListView();
                    } else {
                        console.error("Appointment not found:", info.event.id);
                        info.revert();
                    }
                },
                editable: true,
                dayMaxEvents: 3,
                moreLinkClick: "popover",
                dayCellDidMount: function (info) {
                    if (!showWeekends && (info.date.getDay() === 0 || info.date.getDay() === 6)) {
                        info.el.style.display = 'none';
                    }
                },
                slotMinTime: "08:00:00",
                slotMaxTime: "16:00:00",
                slotDuration: "01:00:00",
                slotLabelInterval: "04:00:00",
                slotLabelFormat: {
                    hour: 'numeric',
                    minute: '2-digit',
                    omitZeroMinute: true,
                    meridiem: 'short'
                },
                allDaySlot: false,
                height: 'auto'
            });

            try {
                calendar.render();
            } catch (error) {
                console.error("Error rendering calendar:", error);
            }

            $("#filterButton").click(toggleDropdown);
            $("#moreActionsButton").click(toggleMoreActions);
            $("#filter-jobs, #filter-visits, #filter-tasks, #filter-scheduled, #filter-completed, #filter-ontheway").change(applyFilters);
        });

        function toggleDropdown(event) {
            event.preventDefault();
            const dropdownMenu = $("#filterButton").siblings(".dropdown-menu");
            dropdownMenu.toggleClass("show");
        }

        function toggleMoreActions(event) {
            event.preventDefault();
            const dropdownMenu = $("#moreActionsButton").siblings(".dropdown-menu");
            dropdownMenu.toggleClass("show");
        }

        function showDateDropdown(info) {
            $(".date-dropdown").remove();

            const dateStr = info.dateStr;
            const formattedDate = new Date(dateStr).toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
            const $dropdown = $(`
                <div class="date-dropdown">
                    <div class="dropdown-header">Add to ${formattedDate}</div>
                    <div class="dropdown-item" onclick="openNewModal('job', '${dateStr}')">
                        <i class="fas fa-wrench text-success"></i> New Job
                    </div>
                    <div class="dropdown-item" onclick="openNewModal('request', '${dateStr}')">
                        <i class="fas fa-download text-warning"></i> New Request
                    </div>
                    <div class="dropdown-item" onclick="openNewModal('task', '${dateStr}')">
                        <i class="fas fa-check-square text-secondary"></i> New Task
                    </div>
                    <div class="dropdown-item" onclick="openNewModal('event', '${dateStr}')">
                        <i class="fas fa-calendar-alt text-primary"></i> New Calendar Event
                    </div>
                    <h4></h4>
                    <div class="dropdown-item" onclick="showDayView('${dateStr}')">
                        <i class="fas fa-th-list"></i> Show on Day View
                    </div>
                    <div class="dropdown-item" onclick="showMapView('${dateStr}')">
                        <i class="fas fa-map-marker-alt"></i> Show on Map View
                    </div>
                </div>
            `);

            // Append to body to avoid being clipped by container
            $('body').append($dropdown);

            // Dynamic positioning
            const dropdownWidth = $dropdown.outerWidth();
            const windowWidth = $(window).width();
            const clickX = info.jsEvent.pageX;
            let leftPosition = clickX + 10;

            // Adjust position if dropdown would extend beyond right edge
            if (clickX + dropdownWidth > windowWidth) {
                leftPosition = clickX - dropdownWidth - 10;
            }

            $dropdown.css({
                top: info.jsEvent.pageY + 10,
                left: leftPosition
            });

            $(document).on('click', function (e) {
                if (!$(e.target).closest('.date-dropdown').length) {
                    $dropdown.remove();
                }
            });
        }

        function showDayView(date) {
            currentView = "day";
            $("#viewToggle").val("day");
            calendar.changeView("timeGridDay", date);
            $("#calendar").show();
            $("#listView").hide();
            $("#mapView").hide();
        }

        function showMapView(date) {
            currentView = "map";
            $("#viewToggle").val("map");
            $("#calendar").hide();
            $("#listView").hide();
            $("#mapView").show();
        }

        function toggleView() {
            currentView = $("#viewToggle").val();
            const calendarView = $("#calendar");
            const listView = $("#listView");
            const mapView = $("#mapView");

            calendarView.hide();
            listView.hide();
            mapView.hide();

            if (currentView === "month") {
                calendar.changeView("dayGridMonth");
                calendarView.show();
            } else if (currentView === "week") {
                calendar.changeView("timeGridWeek");
                calendarView.show();
            } else if (currentView === "day") {
                calendar.changeView("timeGridDay");
                calendarView.show();
            } else if (currentView === "list") {
                renderListView();
                listView.show();
            } else if (currentView === "map") {
                mapView.show();
            }
            calendar.render();
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
                                <span>${a.date ? new Date(a.date).toLocaleDateString() : "Unscheduled"} ${a.timeBlock ? a.timeBlock : ""}</span>
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
                        <li class="page-item ${currentPage === 1 ? 'disabled' : ''}">
                            <a class="page-link" href="#" onclick="renderListView(${currentPage - 1})">Previous</a>
                        </li>
                        ${Array.from({ length: totalPages }, (_, i) => `
                            <li class="page-item ${currentPage === i + 1 ? 'active' : ''}">
                                <a class="page-link" href="#" onclick="renderListView(${i + 1})">${i + 1}</a>
                            </li>
                        `).join('')}
                        <li class="page-item ${currentPage === totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="#" onclick="renderListView(${currentPage + 1})">Next</a>
                        </li>
                    </ul>
                </nav>
            `);
        }

        function toggleCard(id) {
            $(`.appointment-card[data-id="${id}"]`).toggleClass("expanded");
        }

        function applyFilters() {
            calendar.refetchEvents();
            if (currentView === "list") renderListView();
        }

        function clearFilters() {
            $("#filter-jobs, #filter-visits, #filter-tasks, #filter-scheduled, #filter-completed, #filter-ontheway").prop("checked", true);
            applyFilters();
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
            if (type) form.querySelector("[name='type']").value = type === "event" ? "task" : type;
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
                checklist: form.get("checklist")
            };
            appointments.push(newAppointment);
            calendar.refetchEvents();
            if (currentView === "list") renderListView();
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
            form.querySelector("[name='timeBlock']").value = a.timeBlock || "morning";
            form.querySelector("[name='resource']").value = a.resource;
            form.querySelector("[name='location']").value = a.location;
            form.querySelector("[name='status']").value = a.status;
            form.querySelector("[name='notes']").value = a.notes || "";
            form.querySelector("[name='checklist']").value = a.checklist || "";
            const modal = new bootstrap.Modal($("#editModal")[0]);
            modal.show();
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
                calendar.refetchEvents();
                if (currentView === "list") renderListView();
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
                calendar.refetchEvents();
                if (currentView === "list") renderListView();
                bootstrap.Modal.getInstance($("#editModal")[0]).hide();
                currentEditId = null;
            }
        }

        function openUnscheduledModal() {
            const modal = new bootstrap.Modal($("#unscheduledModal")[0]);
            const unscheduledList = $("#unscheduledList");
            const unscheduledAppointments = appointments.filter(a => !a.date || a.status === "pending");

            if (unscheduledAppointments.length === 0) {
                unscheduledList.html('<p class="text-center">No unscheduled appointments found.</p>');
            } else {
                unscheduledList.html(unscheduledAppointments.map(a => `
                    <div class="card mb-3">
                        <div class="card-body">
                            <h6>${a.customer} (${a.type})</h6>
                            <p>Location: ${a.location}<br>Resource: ${a.resource}<br>Notes: ${a.notes || "None"}</p>
                            <button class="btn btn-primary btn-sm" onclick="rescheduleAppointment(${a.id})">Reschedule</button>
                        </div>
                    </div>
                `).join(""));
            }
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
                calendar.refetchEvents();
                if (currentView === "list") renderListView();
                alert(`Appointment #${id} dispatched to ${a.resource}`);
            }
        }

        function complete(id) {
            const a = appointments.find(x => x.id === id);
            a.status = "completed";
            calendar.refetchEvents();
            if (currentView === "list") renderListView();
            alert(`Appointment #${id} marked as completed`);
        }

        function openResourceModal(id) {
            alert(`Assign resource for appointment #${id}`);
        }

        function openSiteInfoModal(id) {
            alert(`View site info for appointment #${id}`);
        }
    </script>
</asp:Content>