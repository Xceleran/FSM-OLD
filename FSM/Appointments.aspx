<%@ Page Title="Appointments" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="Appointments.aspx.cs" Inherits="FSM.Appointments" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" integrity="sha512-DTOQO9RWCH3ppGqcWaEA1BIZOC6xxalwEsw9c2QQeAIftl+Vegovlnee1c9QX4TctnWMn13TZye+giMm8e2LwA==" crossorigin="anonymous" referrerpolicy="no-referrer" />
    <script async defer src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY_HERE&callback=initMap"></script>
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">

    <style>
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            overflow-x: hidden;
        }

        .container-fluid {
            padding: 20px;
            margin-top: 60px;
            max-width: 100%;
        }

        .page-title {
            font-size: 28px;
            font-weight: 700;
            color: #ff520d;
        }

        .main-contents {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
        }

        .calendar-container {
            background: #ffffff;
            border-radius: 10px;
            box-shadow Stuart: 0 4px 15px rgba(0, 0, 0, 0.1);
            padding: 20px;
            flex: 3;
            min-width: 300px;
        }

        .unscheduled-container {
            background: #ffffff;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            padding: 20px;
            flex: 1;
            max-width: 300px;
            min-height: 400px;
            overflow-y: auto;
        }

        .unscheduled-container h3 {
            font-size: 18px;
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 15px;
        }

        .unscheduled-item {
            background: #f8f9fa;
            border: 1px solid #e0e0e0;
            border-radius: 5px;
            padding: 10px;
            margin-bottom: 10px;
            cursor: move;
            font-size: 14px;
            color: #2c3e50;
            transition: transform 0.2s ease;
        }

        .unscheduled-item:hover {
            transform: scale(1.02);
        }

        .custom-calendar-header {
            background: #2c3e50;
            color: white;
            padding: 10px;
            border-radius: 6px 6px 0 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .custom-calendar-header button {
            background: #ff520d;
            border: none;
            color: white;
            padding: 5px 10px;
            border-radius: 4px;
            cursor: pointer;
        }

        .custom-calendar-header button:hover {
            background: #e04a0c;
        }

        .custom-day-view, .custom-resource-view {
            width: 100%;
            border-collapse: collapse;
        }

        .custom-day-view th, .custom-resource-view th {
            background: #f8f9fa;
            border: 1px solid #e0e0e0;
            padding: 5px;
            text-align: center;
            font-weight: 600;
            color: #2c3e50;
        }

        .custom-day-view td, .custom-resource-view td {
            border: 1px solid #e0e0e0;
            padding: 0;
            vertical-align: top;
        }

        .month-view {
            width: 100%;
            border-collapse: collapse;
        }
        .month-view th, .month-view td {
            border: 1px solid #e0e0e0;
            padding: 5px;
            text-align: center;
            vertical-align: top;
            height: 100px;
        }
        .month-view th {
            background: #f8f9fa;
            font-weight: 600;
            color: #2c3e50;
        }
        .month-view .appointment-block {
            position: relative;
            margin: 2px 0;
            width: 95%;
        }
        .week-view, .three-day-view {
            width: 100%;
            border-collapse: collapse;
        }
        .week-view th, .week-view td, .three-day-view th, .three-day-view td {
            border: 1px solid #e0e0e0;
            padding: 0;
            vertical-align: top;
        }
        .week-view th, .three-day-view th {
            background: #f8f9fa;
            text-align: center;
            font-weight: 600;
            color: #2c3e50;
            padding: 5px;
        }

        .time-slot {
            height: 20px;
            border-bottom: 1px solid #e0e0e0;
            position: relative;
            font-size: 10px;
            color: #2c3e50;
            display: flex;
            align-items: center;
            padding-left: 5px;
        }

        .time-slot-label {
            width: 80px;
            background: #f8f9fa;
            border-right: 1px solid #e0e0e0;
            text-align: center;
        }

        .time-slot-content {
            flex: 1;
            position: relative;
            min-height: 20px;
        }

        .resource-view {
            display: flex;
            overflow-x: auto;
            background: #e9ecef;
            border-radius: 5px;
        }

        .time-column {
            width: 80px;
            background: #f8f9fa;
            border-right: 1px solid #d0d0d0;
        }

        .resource-grid {
            flex: 1;
            display: flex;
            overflow-x: auto;
        }

        .resource-column {
            min-width: 200px;
            border-right: 1px solid #d0d0d0;
            position: relative;
        }

        .resource-header {
            height: 40px;
            background: #2c3e50;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 14px;
            border-bottom: 1px solid #d0d0d0;
        }

        .resource-slot {
            height: 20px;
            border-bottom: 1px solid #d0d0d0;
            background: #ffffff;
            position: relative;
        }

        .appointment-block {
            position: absolute;
            background: #ff520d;
            color: white;
            border-radius: 4px;
            padding: 3px 6px;
            font-size: 10px;
            cursor: move;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.2);
            z-index: 10;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            width: 90%;
            left: 5%;
            min-height: 18px;
            top: 1px;
        }

        .appointment-block.ui-resizable {
            resize: vertical;
        }

        .appointment-block:hover {
            transform: scale(1.03);
        }

        .ui-resizable-s {
            bottom: 0;
            height: 5px;
            background: rgba(0, 0, 0, 0.2);
            cursor: ns-resize;
        }

        .map-view {
            height: 500px;
            width: 100%;
            border-radius: 5px;
        }

        .nav-tabs .nav-link {
            color: #2c3e50;
            font-weight: 500;
            border-bottom: 2px solid transparent;
            background: white;
            margin-right: 5px;
        }

        .nav-tabs .nav-link.active {
            color: white;
            background: #ff520d;
            border-color: #ff520d;
        }

        .nav-tabs .nav-link:hover {
            border-bottom: 2px solid #ff520d;
        }

        .btn-primary {
            background-color: #ff520d;
            border-color: #ff520d;
        }

        .btn-primary:hover {
            background-color: #e04a0c;
            border-color: #e04a0c;
        }

        @media (max-width: 992px) {
            .main-contents {
                flex-direction: column;
            }

            .unscheduled-container {
                max-width: 100%;
            }
        }

        @media (max-width: 768px) {
            .calendar-container, .unscheduled-container {
                padding: 10px;
            }

            .appointment-block, .unscheduled-item {
                font-size: 9px;
            }

            .resource-column {
                min-width: 150px;
            }
        }
    </style>

    <div class="container-fluid">
        <header class="mb-4">
            <div class="row align-items-center">
                <div class="col-md-6">
                    <h1 class="page-title">Dispatch Calendar</h1>
                </div>
                <div class="col-md-6 text-md-end">
                    <button class="btn btn-primary" onclick="openNewModal()">+ Create Appointment</button>
                </div>
            </div>
        </header>

        <ul class="nav nav-tabs mb-3" id="viewTabs" role="tablist">
            <li class="nav-item">
                <button class="nav-link active" id="day-tab" data-bs-toggle="tab" data-bs-target="#dayView" type="button" role="tab">Day View</button>
            </li>
            <li class="nav-item">
                <button class="nav-link" id="resource-tab" data-bs-toggle="tab" data-bs-target="#resourceView" type="button" role="tab">Resource View</button>
            </li>
            <li class="nav-item">
                <button class="nav-link" id="map-tab" data-bs-toggle="tab" data-bs-target="#mapView" type="button" role="tab">Map View</button>
            </li>
        </ul>

        <div class="tab-content">
            <div class="tab-pane fade show active" id="dayView" role="tabpanel">
                <div class="main-contents">
                    <div class="calendar-container">
                        <div class="mb-3 d-flex flex-wrap gap-2 align-items-center">
                            <label for="viewSelect" class="form-label mb-0">View:</label>
                            <select id="viewSelect" class="form-select" style="width: auto;" onchange="renderDayView($('#dayDatePicker').val())">
                                <option value="day">Day</option>
                                <option value="week">Week</option>
                                <option value="threeDay">Three-Day</option>
                                <option value="month">Month</option>
                            </select>
                            <label for="filterSelect" class="form-label mb-0 ms-3">Filter:</label>
                            <select id="filterSelect" class="form-select" style="width: auto;" onchange="renderDayView($('#dayDatePicker').val())">
                                <option value="all">All</option>
                                <option value="Tasks">Tasks</option>
                                <option value="Visits">Visits</option>
                            </select>
                            <label for="dayDatePicker" class="form-label mb-0 ms-3">Date:</label>
                            <input type="date" id="dayDatePicker" class="form-control" style="width: auto;" onchange="renderDayView(this.value)">
                        </div>
                        <div id="dayCalendar"></div>
                    </div>
                    <div class="unscheduled-container">
                        <h3>Unscheduled Appointments</h3>
                        <div id="unscheduledList"></div>
                    </div>
                </div>
            </div>

            <div class="tab-pane fade calendar-container" id="resourceView" role="tabpanel">
                <div class="main-contents">
                    <div class="calendar-container">
                        <div class="mb-3 d-flex flex-wrap gap-2 align-items-center">
                            <label for="resourceDatePicker" class="form-label mb-0">Date:</label>
                            <input type="date" id="resourceDatePicker" class="form-control" style="width: auto;" onchange="renderResourceView(this.value)">
                            <select id="dispatchGroup" class="form-select" style="width: auto;" onchange="renderResourceView($('#resourceDatePicker').val())">
                                <option value="all">All Resources</option>
                                <option value="electricians">Electricians</option>
                                <option value="plumbers">Plumbers</option>
                            </select>
                        </div>
                        <div class="resource-view" id="resourceViewContainer">
                            <div class="time-column" id="timeColumn"></div>
                            <div class="resource-grid" id="resourceGrid"></div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="tab-pane fade calendar-container" id="mapView" role="tabpanel">
                <div class="mb-3 d-flex flex-wrap gap-2 align-items-center">
                    <label for="mapDatePicker" class="form-label mb-0">Date:</label>
                    <input type="date" id="mapDatePicker" class="form-control" style="width: auto;" onchange="renderMapView()">
                </div>
                <div id="googleMap" class="map-view"></div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="newModal" tabindex="-1" aria-labelledby="newModalLabel">
        <div class="modal-dialog modal-dialog-centered">
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
                                <select name="serviceType" class="form-select" required>
                                    <option value="Tasks">Tasks</option>
                                    <option value="Visits">Visits</option>
                                    <option value="Maintenance">Maintenance</option>
                                    <option value="Installation">Installation</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Date</label>
                                <input type="date" name="date" class="form-control">
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
                            <div class="col-12">
                                <label class="form-label">Time Period</label>
                                <select name="timePeriod" class="form-select" onchange="updateTimeSlots('newForm')">
                                    <option value="morning">Morning (8:00 AM - 12:00 PM)</option>
                                    <option value="afternoon">Afternoon (12:00 PM - 6:00 PM)</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Start Time</label>
                                <select name="startTime" class="form-select time-slot-select" required>
                                    <!-- Time slots populated by JavaScript -->
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Duration (hours)</label>
                                <input type="number" name="duration" class="form-control" step="0.25" min="0.25" value="1">
                            </div>
                            <div class="col-12">
                                <label class="form-label">Address</label>
                                <input type="text" name="address" class="form-control" required>
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

    <div class="modal fade" id="editModal" tabindex="-1" aria-labelledby="editModalLabel">
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
                            <div class="col-md-6">
                                <label class="form-label">Customer Name</label>
                                <input type="text" name="customerName" class="form-control" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Service Type</label>
                                <select name="serviceType" class="form-select" required>
                                    <option value="Tasks">Tasks</option>
                                    <option value="Visits">Visits</option>
                                    <option value="Maintenance">Maintenance</option>
                                    <option value="Installation">Installation</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Date</label>
                                <input type="date" name="date" class="form-control">
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
                            <div class="col-12">
                                <label class="form-label">Time Period</label>
                                <select name="timePeriod" class="form-select" onchange="updateTimeSlots('editForm')">
                                    <option value="morning">Morning (8:00 AM - 12:00 PM)</option>
                                    <option value="afternoon">Afternoon (12:00 PM - 6:00 PM)</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Start Time</label>
                                <select name="startTime" class="form-select time-slot-select" required>
                                    <!-- Time slots populated by JavaScript -->
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Duration (hours)</label>
                                <input type="number" name="duration" class="form-control" step="0.25" min="0.25">
                            </div>
                            <div class="col-12">
                                <label class="form-label">Address</label>
                                <input type="text" name="address" class="form-control" required>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-danger" onclick="deleteAppointment()">Delete</button>
                        <button type="button" class="btn btn-secondary" onclick="unscheduleAppointment()">Unschedule</button>
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Save</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>

    <script>
        let appointments = JSON.parse(localStorage.getItem('appointments')) || [
            {
                id: 1,
                customerName: "John Doe",
                date: "2025-04-17",
                startTime: "09:15",
                duration: 1.5,
                resource: "Jim",
                serviceType: "Tasks",
                location: { address: "123 Main St, New York, NY", lat: 40.7128, lng: -74.0060 }
            },
            {
                id: 2,
                customerName: "Jane Smith",
                date: null,
                startTime: null,
                duration: 1.0,
                resource: "Unassigned",
                serviceType: "Visits",
                location: { address: "456 Branch Rd, Los Angeles, CA", lat: 34.0522, lng: -118.2437 }
            },
            {
                id: 3,
                customerName: "Alice Johnson",
                date: "2025-04-17",
                startTime: "14:30",
                duration: 2.0,
                resource: "Bob",
                serviceType: "Tasks",
                location: { address: "789 Warehouse Ave, Chicago, IL", lat: 41.8781, lng: -87.6298 }
            }
        ];

        let currentView = "day";
        let currentDate = new Date();
        let currentEditId = null;
        let map, markers = [];
        const resources = ["Jim", "Bob", "Team1", "Unassigned"];
        const technicianGroups = {
            "electricians": ["Jim", "Bob"],
            "plumbers": ["Team1"]
        };

        const morningTimes = [
            "08:00", "08:15", "08:30", "08:45",
            "09:00", "09:15", "09:30", "09:45",
            "10:00", "10:15", "10:30", "10:45",
            "11:00", "11:15", "11:30", "11:45"
        ];

        const afternoonTimes = [
            "12:00", "12:15", "12:30", "12:45",
            "13:00", "13:15", "13:30", "13:45",
            "14:00", "14:15", "14:30", "14:45",
            "15:00", "15:15", "15:30", "15:45",
            "16:00", "16:15", "16:30", "16:45",
            "17:00", "17:15", "17:30", "17:45"
        ];

        function updateTimeSlots(formId) {
            const form = document.getElementById(formId);
            const timePeriod = form.querySelector("[name='timePeriod']").value;
            const timeSelect = form.querySelector("[name='startTime']");

            const times = timePeriod === "morning" ? morningTimes : afternoonTimes;

            timeSelect.innerHTML = times.map(time =>
                `<option value="${time}">${time}</option>`
            ).join('');
        }

        function saveAppointments() {
            localStorage.setItem('appointments', JSON.stringify(appointments));
        }

        function timeToMinutes(time) {
            if (!time) return 0;
            const [hours, minutes] = time.split(':').map(Number);
            return hours * 60 + minutes;
        }

        function minutesToTime(minutes) {
            const hours = Math.floor(minutes / 60).toString().padStart(2, '0');
            const mins = (minutes % 60).toString().padStart(2, '0');
            return `${hours}:${mins}`;
        }

        function hasConflict(appointment, newStartTime, newDuration, newResource, date, excludeId = null) {
            if (!newStartTime || !date) return false;
            const newStartMinutes = timeToMinutes(newStartTime);
            const newEndMinutes = newStartMinutes + newDuration * 60;

            return appointments.some(a => {
                if (a.id === excludeId || a.date !== date || a.resource !== newResource || !a.startTime) return false;
                const startMinutes = timeToMinutes(a.startTime);
                const endMinutes = startMinutes + a.duration * 60;
                return (newStartMinutes < endMinutes && newEndMinutes > startMinutes);
            });
        }

        function getEventColor(appointment, useResource = false) {
            if (useResource) {
                const colors = {
                    "Jim": "blue",
                    "Bob": "green",
                    "Team1": "orange",
                    "Unassigned": "grey"
                };
                return colors[appointment.resource] || "red";
            }
            return "#ff520d";
        }

        function renderDayView(date) {
            currentDate = new Date(date);
            const container = $("#dayCalendar");
            const view = $("#viewSelect").val();
            const filter = $("#filterSelect").val();
            const dateStr = currentDate.toISOString().split('T')[0];

            let filteredAppointments = appointments;
            if (filter !== 'all') {
                filteredAppointments = appointments.filter(a => a.serviceType === filter);
            }

            let html = `
                <div class="custom-calendar-header">
                    <button onclick="prevPeriod()">Prev</button>
                    <span>${view === 'month' ? currentDate.toLocaleString('default', { month: 'long', year: 'numeric' }) : currentDate.toLocaleDateString()}</span>
                    <button onclick="nextPeriod()">Next</button>
                    <button onclick="gotoToday()">Today</button>
                </div>
            `;

            if (view === 'month') {
                const firstDay = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1);
                const lastDay = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 0);
                const startWeek = firstDay.getDay();
                let calendarDays = [];
                for (let i = 0; i < startWeek; i++) calendarDays.push(null);
                for (let i = 1; i <= lastDay.getDate(); i++) calendarDays.push(i);

                html += `
                    <table class="month-view">
                        <thead>
                            <tr>
                                <th>Sun</th><th>Mon</th><th>Tue</th><th>Wed</th><th>Thu</th><th>Fri</th><th>Sat</th>
                            </tr>
                        </thead>
                        <tbody>
                `;
                for (let i = 0; i < calendarDays.length; i += 7) {
                    html += '<tr>';
                    for (let j = 0; j < 7; j++) {
                        const day = calendarDays[i + j];
                        const dayDate = day ? `${currentDate.getFullYear()}-${(currentDate.getMonth() + 1).toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}` : '';
                        html += `<td${day ? ` data-date="${dayDate}"` : ''}>`;
                        if (day) {
                            html += `<div>${day}</div>`;
                            filteredAppointments.filter(a => a.date === dayDate).forEach(a => {
                                html += `
                                    <div class="appointment-block" data-id="${a.id}" draggable="true">
                                        ${a.customerName} (${a.serviceType})
                                    </div>
                                `;
                            });
                        }
                        html += '</td>';
                    }
                    html += '</tr>';
                }
                html += '</tbody></table>';
            } else if (view === 'week' || view === 'threeDay') {
                const days = view === 'week' ? 7 : 3;
                const startDate = new Date(currentDate);
                startDate.setDate(currentDate.getDate() - currentDate.getDay());
                if (view === 'threeDay') startDate.setDate(currentDate.getDate() - 1);

                html += `
                    <table class="${view === 'week' ? 'week-view' : 'three-day-view'}">
                        <thead>
                            <tr>
                                <th>Time</th>
                                ${Array.from({ length: days }, (_, i) => {
                    const d = new Date(startDate);
                    d.setDate(startDate.getDate() + i);
                    return `<th>${d.toLocaleDateString()}</th>`;
                }).join('')}
                            </tr>
                        </thead>
                        <tbody>
                            ${Array.from({ length: 24 * 4 }, (_, i) => {
                    const minutes = i * 15;
                    const timeStr = minutesToTime(minutes);
                    return `
                                    <tr>
                                        <td class="time-slot-label">${timeStr}</td>
                                        ${Array.from({ length: days }, (_, j) => {
                        const d = new Date(startDate);
                        d.setDate(startDate.getDate() + j);
                        const dStr = d.toISOString().split('T')[0];
                        const events = filteredAppointments.filter(a => a.date === dStr && (!a.startTime || timeToMinutes(a.startTime) === minutes));
                        return `
                                                <td>
                                                    <div class="time-slot-content" data-date="${dStr}" data-time="${timeStr}">
                                                        ${events.map(a => `
                                                            <div class="appointment-block" data-id="${a.id}" draggable="true" style="height: ${a.duration * 60 / 15 * 20}px;">
                                                                ${a.customerName} (${a.serviceType}) - ${a.resource}${a.startTime ? '' : ' (No Time)'}
                                                            </div>
                                                        `).join('')}
                                                    </div>
                                                </td>
                                            `;
                    }).join('')}
                                    </tr>
                                `;
                }).join('')}
                        </tbody>
                    </table>
                `;
            } else {
                html += `
                    <table class="custom-day-view">
                        <thead>
                            <tr>
                                <th>Time</th>
                                <th>Appointments</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${Array.from({ length: 24 * 4 }, (_, i) => {
                    const minutes = i * 15;
                    const timeStr = minutesToTime(minutes);
                    const events = filteredAppointments.filter(a => a.date === dateStr && (!a.startTime || timeToMinutes(a.startTime) === minutes));
                    return `
                                    <tr>
                                        <td class="time-slot-label">${timeStr}</td>
                                        <td>
                                            <div class="time-slot-content" data-date="${dateStr}" data-time="${timeStr}">
                                                ${events.map(a => `
                                                    <div class="appointment-block" data-id="${a.id}" draggable="true" style="height: ${a.duration * 60 / 15 * 20}px;">
                                                        ${a.customerName} (${a.serviceType}) - ${a.resource}${a.startTime ? ` (${a.duration}h)` : ' (No Time)'}
                                                    </div>
                                                `).join('')}
                                            </div>
                                        </td>
                                    </tr>
                                `;
                }).join('')}
                        </tbody>
                    </table>
                `;
            }

            container.html(html);
            setupDragAndDrop();
            renderUnscheduledList();
        }

        function renderResourceView(date) {
            const timeColumn = $("#timeColumn");
            const resourceGrid = $("#resourceGrid");
            const selectedGroup = $("#dispatchGroup").val();

            timeColumn.html('<div class="resource-header">Time</div>' +
                Array.from({ length: 24 * 4 }, (_, i) => `<div class="time-slot">${minutesToTime(i * 15)}</div>`).join(''));

            let filteredResources = selectedGroup === "all" ? resources : technicianGroups[selectedGroup] || [];
            resourceGrid.html(filteredResources.map(resource => `
                <div class="resource-column" data-resource="${resource}">
                    <div class="resource-header">${resource}</div>
                    ${Array.from({ length: 24 * 4 }, (_, i) => `<div class="resource-slot" data-minutes="${i * 15}" data-resource="${resource}" data-date="${date}"></div>`).join('')}
                </div>
            `).join(''));

            appointments.filter(a => a.date === date).forEach(a => {
                const startMinutes = timeToMinutes(a.startTime) || 0;
                const slotIndex = Math.floor(startMinutes / 15);
                const slot = $(`.resource-slot[data-minutes="${slotIndex * 15}"][data-resource="${a.resource}"]`);
                if (slot.length) {
                    const height = a.duration * 60 / 15 * 20;
                    slot.html(`
                        <div class="appointment-block" data-id="${a.id}" draggable="true" style="height: ${height}px;">
                            ${a.customerName} (${a.serviceType}) - ${a.startTime || 'No Time'} (${a.duration}h)
                        </div>
                    `);
                }
            });

            setupDragAndDrop();
        }

        function renderMapView() {
            const selectedDate = $("#mapDatePicker").val();
            markers.forEach(marker => marker.setMap(null));
            markers = [];

            const bounds = new google.maps.LatLngBounds();
            const filteredAppointments = appointments.filter(a => a.date === selectedDate && a.location.lat && a.location.lng);

            filteredAppointments.forEach(a => {
                const position = { lat: parseFloat(a.location.lat), lng: parseFloat(a.location.lng) };
                const marker = new google.maps.Marker({
                    position,
                    map,
                    title: `${a.customerName}\n${a.serviceType}\n${a.startTime || 'No Time'} (${a.duration}h)\nResource: ${a.resource}`,
                    icon: `http://maps.google.com/mapfiles/ms/icons/${getEventColor(a, true)}-dot.png`
                });
                marker.addListener('click', () => openEditModal(a.id));
                markers.push(marker);
                bounds.extend(position);
            });

            if (filteredAppointments.length) map.fitBounds(bounds);
            else map.setCenter({ lat: 37.0902, lng: -95.7129 });
        }

        function renderUnscheduledList() {
            const container = $("#unscheduledList");
            const unscheduled = appointments.filter(a => !a.date || !a.startTime);

            container.html(unscheduled.length === 0 ? '<p>No unscheduled appointments.</p>' :
                unscheduled.map(a => `
                    <div class="unscheduled-item" data-id="${a.id}" draggable="true">
                        <strong>${a.customerName}</strong> (${a.serviceType})<br>
                        ${a.location.address}<br>
                        Resource: ${a.resource}
                    </div>
                `).join(''));

            setupDragAndDrop();
        }

        function setupDragAndDrop() {
            $(".appointment-block").each(function () {
                $(this).draggable({
                    containment: ".main-contents",
                    revert: "invalid",
                    zIndex: 1000,
                    helper: 'clone',
                    start: function () { $(this).css("opacity", 0.7); },
                    stop: function () { $(this).css("opacity", 1); }
                }).resizable({
                    handles: "s",
                    minHeight: 20,
                    stop: function (event, ui) {
                        const appointmentId = ui.element.data("id");
                        const appointment = appointments.find(a => a.id === appointmentId);
                        const newDuration = ui.size.height / 20 * 0.25;
                        if (hasConflict(appointment, appointment.startTime, newDuration, appointment.resource, appointment.date, appointment.id)) {
                            alert("Resizing causes a conflict!");
                            ui.element.css("height", (appointment.duration * 60 / 15 * 20) + "px");
                            return;
                        }
                        appointment.duration = newDuration;
                        saveAppointments();
                        updateAllViews();
                    }
                });
            });

            $(".unscheduled-item").each(function () {
                $(this).draggable({
                    containment: ".main-contents",
                    revert: "invalid",
                    zIndex: 1000,
                    helper: 'clone',
                    start: function () { $(this).css("opacity", 0.7); },
                    stop: function () { $(this).css("opacity", 1); }
                });
            });

            $(".time-slot-content, .resource-slot").each(function () {
                $(this).droppable({
                    accept: ".appointment-block, .unscheduled-item",
                    tolerance: "pointer",
                    drop: function (event, ui) {
                        const appointmentId = ui.draggable.data("id");
                        const appointment = appointments.find(a => a.id === appointmentId);
                        if (appointment) {
                            appointment.date = $(this).data("date");
                            appointment.startTime = $(this).data("time") || minutesToTime($(this).data("minutes"));
                            appointment.resource = $(this).data("resource") || appointment.resource;
                            if (hasConflict(appointment, appointment.startTime, appointment.duration, appointment.resource, appointment.date, appointment.id)) {
                                alert("Scheduling conflict detected!");
                                return;
                            }
                            saveAppointments();
                            updateAllViews();
                        }
                    }
                });
            });

            $("#unscheduledList").each(function () {
                $(this).droppable({
                    accept: ".appointment-block, .unscheduled-item",
                    tolerance: "pointer",
                    drop: function (event, ui) {
                        const appointmentId = ui.draggable.data("id");
                        const appointment = appointments.find(a => a.id === appointmentId);
                        if (appointment) {
                            appointment.date = null;
                            appointment.startTime = null;
                            saveAppointments();
                            updateAllViews();
                        }
                    }
                });
            });

            $(document).off('click', '.appointment-block, .unscheduled-item').on('click', '.appointment-block, .unscheduled-item', function () {
                openEditModal($(this).data("id"));
            });
        }

        function prevPeriod() {
            const view = $("#viewSelect").val();
            if (view === 'month') {
                currentDate.setMonth(currentDate.getMonth() - 1);
            } else {
                currentDate.setDate(currentDate.getDate() - (view === 'week' ? 7 : view === 'threeDay' ? 3 : 1));
            }
            const dateStr = currentDate.toISOString().split('T')[0];
            $("#dayDatePicker").val(dateStr);
            renderDayView(dateStr);
        }

        function nextPeriod() {
            const view = $("#viewSelect").val();
            if (view === 'month') {
                currentDate.setMonth(currentDate.getMonth() + 1);
            } else {
                currentDate.setDate(currentDate.getDate() + (view === 'week' ? 7 : view === 'threeDay' ? 3 : 1));
            }
            const dateStr = currentDate.toISOString().split('T')[0];
            $("#dayDatePicker").val(dateStr);
            renderDayView(dateStr);
        }

        function gotoToday() {
            currentDate = new Date();
            const dateStr = currentDate.toISOString().split('T')[0];
            $("#dayDatePicker").val(dateStr);
            renderDayView(dateStr);
        }

        function openNewModal(date = null) {
            const modal = new bootstrap.Modal(document.getElementById("newModal"));
            const form = document.getElementById("newForm");
            form.reset();
            if (date) form.querySelector("[name='date']").value = date;
            updateTimeSlots('newForm');
            modal.show();
        }

        function createAppointment(e) {
            e.preventDefault();
            const form = new FormData(e.target);
            const newAppointment = {
                id: Math.max(...appointments.map(a => a.id), 0) + 1,
                customerName: form.get("customerName"),
                serviceType: form.get("serviceType"),
                date: form.get("date") || null,
                startTime: form.get("startTime") || null,
                duration: parseFloat(form.get("duration")) || 1.0,
                resource: form.get("resource"),
                location: {
                    address: form.get("address"),
                    lat: null,
                    lng: null
                }
            };

            if (newAppointment.date && newAppointment.startTime && hasConflict(newAppointment, newAppointment.startTime, newAppointment.duration, newAppointment.resource, newAppointment.date)) {
                alert("Scheduling conflict detected!");
                return;
            }

            appointments.push(newAppointment);
            saveAppointments();
            updateAllViews();
            bootstrap.Modal.getInstance(document.getElementById("newModal")).hide();
        }

        function openEditModal(id) {
            const a = appointments.find(x => x.id === id);
            currentEditId = id;
            const form = document.getElementById("editForm");
            form.querySelector("[name='id']").value = a.id;
            form.querySelector("[name='customerName']").value = a.customerName;
            form.querySelector("[name='serviceType']").value = a.serviceType;
            form.querySelector("[name='date']").value = a.date || "";
            form.querySelector("[name='duration']").value = a.duration || 1.0;
            form.querySelector("[name='resource']").value = a.resource;
            form.querySelector("[name='address']").value = a.location.address;

            if (a.startTime) {
                const hour = parseInt(a.startTime.split(':')[0]);
                const timePeriod = hour < 12 ? 'morning' : 'afternoon';
                form.querySelector("[name='timePeriod']").value = timePeriod;
                updateTimeSlots('editForm');
                form.querySelector("[name='startTime']").value = a.startTime;
            } else {
                form.querySelector("[name='timePeriod']").value = 'morning';
                updateTimeSlots('editForm');
            }

            new bootstrap.Modal(document.getElementById("editModal")).show();
        }

        function updateAppointment(e) {
            e.preventDefault();
            const form = new FormData(e.target);
            const a = appointments.find(x => x.id === parseInt(form.get("id")));
            if (a) {
                a.customerName = form.get("customerName");
                a.serviceType = form.get("serviceType");
                a.date = form.get("date") || null;
                a.startTime = form.get("startTime") || null;
                a.duration = parseFloat(form.get("duration")) || 1.0;
                a.resource = form.get("resource");
                a.location.address = form.get("address");
                if (a.date && a.startTime && hasConflict(a, a.startTime, a.duration, a.resource, a.date, a.id)) {
                    alert("Scheduling conflict detected!");
                    return;
                }
                saveAppointments();
                updateAllViews();
                bootstrap.Modal.getInstance(document.getElementById("editModal")).hide();
                currentEditId = null;
            }
        }

        function unscheduleAppointment() {
            const a = appointments.find(x => x.id === currentEditId);
            if (a) {
                a.date = null;
                a.startTime = null;
                saveAppointments();
                updateAllViews();
                bootstrap.Modal.getInstance(document.getElementById("editModal")).hide();
                currentEditId = null;
            }
        }

        function deleteAppointment() {
            if (confirm("Are you sure you want to delete this appointment?")) {
                appointments = appointments.filter(x => x.id !== currentEditId);
                saveAppointments();
                updateAllViews();
                bootstrap.Modal.getInstance(document.getElementById("editModal")).hide();
                currentEditId = null;
            }
        }

        function updateAllViews() {
            renderUnscheduledList();
            if (currentView === "day") {
                renderDayView(currentDate.toISOString().split('T')[0]);
            } else if (currentView === "resource") {
                renderResourceView($("#resourceDatePicker").val() || currentDate.toISOString().split('T')[0]);
            } else if (currentView === "map") {
                renderMapView();
            }
        }

        function initMap() {
            map = new google.maps.Map(document.getElementById("googleMap"), {
                center: { lat: 37.0902, lng: -95.7129 },
                zoom: 4
            });
            renderMapView();
        }

        document.addEventListener('DOMContentLoaded', () => {
            const today = new Date().toISOString().split('T')[0];
            $("#dayDatePicker").val(today);
            $("#resourceDatePicker").val(today);
            $("#mapDatePicker").val(today);

            $('#viewTabs a').on('shown.bs.tab', function (e) {
                currentView = e.target.id === "day-tab" ? "day" :
                    e.target.id === "resource-tab" ? "resource" : "map";
                updateAllViews();
            });

            renderDayView(today);
            renderUnscheduledList();
            renderResourceView(today);
            updateTimeSlots('newForm');
            updateTimeSlots('editForm');
        });
    </script>
</asp:Content>