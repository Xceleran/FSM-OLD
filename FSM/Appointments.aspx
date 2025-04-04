<%@ Page Title="Appointments" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="Appointments.aspx.cs" Inherits="FSM.Appointments" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" integrity="sha512-DTOQO9RWCH3ppGqcWaEA1BIZOC6xxalwEsw9c2QQeAIftl+Vegovlnee1c9QX4TctnWMn13TZye+giMm8e2LwA==" crossorigin="anonymous" referrerpolicy="no-referrer" />

    <style>
        .appointments-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
            flex-wrap: wrap;
            gap: 16px;
        }

        .appointments-header h1 {
            font-size: 28px;
            font-weight: 700;
            color: #f84700;
        }

        .header-actions {
            display: flex;
            gap: 12px;
        }

        .container-fluid {
            padding: 20px;
            margin-top: 50px;
        }

        .main-content {
            padding: 20px;
            background: #fff;
            border-radius: 5px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

        .filter-dropdown .dropdown-menu {
            min-width: 250px;
            padding: 15px;
        }

        .filter-dropdown .form-label {
            margin-bottom: 5px;
            font-weight: bold;
        }

        .status-indicator {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            display: inline-block;
            margin-right: 8px;
        }

        .scheduled { background: #4CAF50; }
        .pending { background: #ff9800; }
        .completed { background: #2196F3; }

        .appointment-card .card-header {
            cursor: pointer;
            background: #f8f9fa;
        }

        .appointment-card .card-body {
            display: none;
            transition: all 0.3s ease;
        }

        .appointment-card.expanded .card-body {
            display: block;
        }

        .calendar-container {
            padding: 0px;
        }

        .calendar {
            background: #fff;
            border-radius: 15px;
            box-shadow: 0 4px 12px rgb(180 194 255);
            padding: 20px;
            margin-top: 20px;
        }

        .calendar-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 10px;
        }

        .calendar-header h3 {
            font-size: 24px;
            color: #005984;
            margin: 0;
        }

        .calendar-nav {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }

        .calendar-nav .btn:hover {
            color: #007bff;
        }

        .calendar-table {
            width: 100%;
            border-collapse: collapse;
        }

        .calendar-table th {
            background: #ffffff;
            color: #024668;
            padding: 10px;
            text-align: center;
            font-weight: 500;
            font-size: 16px;
        }

        .calendar-table td {
            border: 3px solid #ffffff;
            padding: 15px;
            text-align: center;
            cursor: pointer;
            transition: background 0.3s;
            border-radius: 25px;
            position: relative;
        }

        .calendar-table td:hover {
            background: #e0f7fa;
        }

        .booked-date {
            background: #dbdff1 !important;
            color: #005984;
            font-weight: bold;
        }

        .today {
            background: #e3f2fd !important;
            border: 2px solid #2196F3;
        }

        .calendar-tooltip {
            display: none;
            position: absolute;
            top: -100%;
            left: 50%;
            transform: translateX(-50%);
            background: #fff;
            border: 1px solid #ddd;
            border-radius: 5px;
            padding: 5px 10px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            z-index: 1000;
            font-size: 12px;
            color: #333;
            white-space: nowrap;
        }

        .calendar-table td:hover .calendar-tooltip {
            display: block;
        }

        .timezone-container {
            margin-top: 15px;
            background: #fff;
            border-radius: 10px;
            padding: 10px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }

        .timezone-toggle {
            width: 100%;
            background: #dbdff1;
            color: #005984;
            border: 1px solid #bbbbbb;
            padding: 8px 12px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 16px;
            transition: background 0.3s;
            border-radius: 10px;
        }

        .timezone-toggle:hover {
            background: #b6bacb;
        }

        .timezone-dropdown {
            position: absolute;
            top: 100%;
            left: 0;
            width: 100%;
            max-height: 300px;
            overflow-y: auto;
            background: #fff;
            border: 1px solid #ddd;
            border-radius: 5px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            z-index: 1000;
            padding: 10px;
            display: none;
        }

        .timezone-option {
            padding: 8px;
            cursor: pointer;
        }

        .timezone-option:hover {
            background: #e0f7fa;
        }

        .custom-date-picker {
            max-width: 150px;
        }

        .row.gap-between {
            column-gap: 20px;
        }

        @media (max-width: 767px) {
            .main-content, .calendar-container {
                margin-top: 20px;
            }

            .calendar-table td {
                padding: 8px;
                font-size: 0.8rem;
            }

            .calendar-header {
                flex-direction: column;
                align-items: flex-start;
            }

            .calendar-nav {
                width: 100%;
                justify-content: space-between;
            }

            .custom-date-picker {
                width: 100%;
                max-width: none;
            }

            .appointment-card .card-header {
                font-size: 0.9rem;
            }

            .filter-dropdown .dropdown-menu {
                min-width: 100%;
            }
        }
    </style>

    <div class="container-fluid">
        <header class="appointments-header">
            <h1>Appointments</h1>
            <div class="header-actions">
                <button class="btn btn-primary" onclick="openNewModal()">+ New</button>
            </div>
        </header>

        <div class="row gap-between">
            <!-- Sidebar with Filters -->
            <div class="col-md-5 main-content">
                <div class="d-flex flex-column gap-2">
                    <div class="dropdown filter-dropdown" id="filterDropdown">
                        <button class="btn btn-outline-secondary dropdown-toggle" type="button" id="filterButton" aria-expanded="false">Filters</button>
                        <div class="dropdown-menu" aria-labelledby="filterButton">
                            <form id="filterForm" class="px-3 py-2">
                                <div class="mb-3">
                                    <label for="searchInput" class="form-label">Search</label>
                                    <input type="text" id="searchInput" class="form-control" placeholder="Customer, type, location" onkeyup="applyFilters()">
                                </div>
                                <div class="mb-3">
                                    <label for="statusFilter" class="form-label">Status</label>
                                    <select id="statusFilter" class="form-select" onchange="applyFilters()">
                                        <option value="all">All</option>
                                        <option value="pending">Pending</option>
                                        <option value="scheduled">Scheduled</option>
                                        <option value="completed">Completed</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label for="resourceFilter" class="form-label">Resource</label>
                                    <select id="resourceFilter" class="form-select" onchange="applyFilters()">
                                        <option value="all">All</option>
                                        <option value="Jim">Jim</option>
                                        <option value="Bob">Bob</option>
                                        <option value="Team1">Team 1</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label for="serviceTypeFilter" class="form-label">Type</label>
                                    <select id="serviceTypeFilter" class="form-select" onchange="applyFilters()">
                                        <option value="all">All</option>
                                        <option value="service">Service Call</option>
                                        <option value="sales">Sales</option>
                                        <option value="emergency">Emergency</option>
                                        <option value="consultation">Consultation</option>
                                    </select>
                                </div>
                                <button type="button" class="btn btn-secondary btn-sm" onclick="resetFilters()">Reset</button>
                            </form>
                        </div>
                    </div>
                    <select id="viewToggle" class="form-select" onchange="toggleView()">
                        <option value="list">List View</option>
                        <option value="table">Table View</option>
                    </select>
                </div>
                <div id="appointmentsContainer" class="mt-3"></div>
            </div>

            <!-- Calendar -->
            <div class="col-md-6 calendar-container">
                <div class="calendar">
                    <div class="calendar-header">
                        <h3 id="calendarMonthYear"></h3>
                        <div class="calendar-nav d-flex gap-2">
                            <button type="button" class="btn" onclick="prevPeriod()"><i class="fas fa-angle-left"></i></button>
                            <button type="button" class="btn" onclick="goToToday()">Today</button>
                            <button type="button" class="btn" onclick="goToThisWeek()">This Week</button>
                            <button type="button" class="btn" onclick="goToThisMonth()">This Month</button>
                            <input type="date" id="customDate" class="form-control custom-date-picker" onchange="goToCustomDate()">
                            <button type="button" class="btn" onclick="nextPeriod()"><i class="fas fa-angle-right"></i></button>
                        </div>
                    </div>
                    <table class="calendar-table" id="calendarGrid"></table>
                    <div class="timezone-container">
                        <button id="timezoneToggle" class="timezone-toggle">
                            <span><i class="fas fa-globe"></i></span>
                            <span id="currentTimezone"></span>
                            <span id="currentTime"></span>
                            <span><i class="fas fa-chevron-down"></i></span>
                        </button>
                        <div id="timezoneDropdown" class="timezone-dropdown">
                            <div id="timezoneList"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Modals -->
    <div class="modal fade" id="newModal" tabindex="-1" aria-labelledby="newModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="newModalLabel">New Appointment</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form id="newForm" onsubmit="createAppointment(event)">
                    <div class="modal-body">
                        <div class="row g-3">
                            <div class="col-md-6"><label class="form-label">Customer</label><input type="text" name="customer" class="form-control" required></div>
                            <div class="col-md-6"><label class="form-label">Type</label><select name="type" class="form-select" required>
                                <option value="service">Service Call</option><option value="sales">Sales</option><option value="emergency">Emergency</option><option value="consultation">Consultation</option>
                            </select></div>
                            <div class="col-md-6"><label class="form-label">Date</label><input type="datetime-local" name="date" class="form-control" required></div>
                            <div class="col-md-6"><label class="form-label">Location</label><input type="text" name="location" class="form-control" value="Main Office" required></div>
                            <div class="col-12"><label class="form-label">Notes</label><textarea name="notes" class="form-control" rows="3"></textarea></div>
                            <div class="col-12"><label class="form-label">Checklist</label><textarea name="checklist" class="form-control" rows="3" placeholder="e.g., Check equipment"></textarea></div>
                            <div class="col-12"><label class="form-label">Maintenance Agreement</label><input type="file" name="maintenance" class="form-control"></div>
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
                            <div class="col-md-6"><label class="form-label">Customer</label><input type="text" name="customer" class="form-control" required></div>
                            <div class="col-md-6"><label class="form-label">Type</label><select name="type" class="form-select" required>
                                <option value="service">Service Call</option><option value="sales">Sales</option><option value="emergency">Emergency</option><option value="consultation">Consultation</option>
                            </select></div>
                            <div class="col-md-6"><label class="form-label">Date</label><input type="datetime-local" name="date" class="form-control" required></div>
                            <div class="col-md-6"><label class="form-label">Resource</label><select name="resource" class="form-select">
                                <option value="Unassigned">Unassigned</option><option value="Jim">Jim</option><option value="Bob">Bob</option><option value="Team1">Team 1</option>
                            </select></div>
                            <div class="col-md-6"><label class="form-label">Location</label><input type="text" name="location" class="form-control" required></div>
                            <div class="col-md-6"><label class="form-label">Status</label><select name="status" class="form-select">
                                <option value="pending">Pending</option><option value="scheduled">Scheduled</option><option value="completed">Completed</option>
                            </select></div>
                            <div class="col-12"><label class="form-label">Notes</label><textarea name="notes" class="form-control" rows="3"></textarea></div>
                            <div class="col-12"><label class="form-label">Checklist</label><textarea name="checklist" class="form-control" rows="3"></textarea></div>
                            <div class="col-12"><label class="form-label">Maintenance Agreement</label><input type="file" name="maintenance" class="form-control"></div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Save</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Resource and Site Info Modals remain unchanged -->

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>
    <script>
        let appointments = [
            { id: 1, customer: "John Doe", type: "Service Call", date: "2025-04-03T10:00", resource: "Jim", status: "scheduled", location: "Main Office", notes: "Routine maintenance check", checklist: "Inspect HVAC\nCheck filters", maintenance: null },
            { id: 2, customer: "Jane Smith", type: "Sales", date: "2025-04-04T14:00", resource: "Team1", status: "pending", location: "Branch Office", notes: "Follow-up on sales lead", checklist: "Present proposal\nDiscuss terms", maintenance: null },
            { id: 3, customer: "Alice Johnson", type: "Emergency", date: "2025-04-05T09:00", resource: "Bob", status: "completed", location: "Warehouse", notes: "Urgent repair", checklist: "Fix leak", maintenance: null },
            { id: 4, customer: "Bob Brown", type: "Consultation", date: "2025-04-06T15:00", resource: "Unassigned", status: "pending", location: "Main Office", notes: "Discuss upgrades", checklist: "Review systems", maintenance: null },
            { id: 5, customer: "Charlie Davis", type: "Service Call", date: "2025-04-07T11:00", resource: "Jim", status: "scheduled", location: "Branch Office", notes: "Annual check", checklist: "Test equipment", maintenance: null }
        ];
        let currentView = "list";
        let currentDate = new Date();
        let isMonthView = true;
        let selectedTimeZone = Intl.DateTimeFormat().resolvedOptions().timeZone;
        let clockInterval;

        document.addEventListener("DOMContentLoaded", () => {
            renderAppointments();
            renderCalendar();
            setupTimeZoneSelector();
            document.getElementById("filterButton").addEventListener("click", toggleDropdown);
            document.getElementById("timezoneToggle").addEventListener("click", toggleTimeZoneDropdown);
        });

        function toggleDropdown(event) {
            event.preventDefault();
            const dropdownMenu = document.querySelector("#filterDropdown .dropdown-menu");
            dropdownMenu.classList.toggle("show");
        }

        function applyFilters() {
            renderAppointments();
        }

        function resetFilters() {
            document.getElementById("filterForm").reset();
            applyFilters();
        }

        function renderAppointments() {
            const container = document.getElementById("appointmentsContainer");
            const filters = {
                search: document.getElementById("searchInput").value.toLowerCase(),
                status: document.getElementById("statusFilter").value,
                resource: document.getElementById("resourceFilter").value,
                type: document.getElementById("serviceTypeFilter").value
            };

            let filtered = appointments.filter(a =>
                (filters.status === "all" || a.status === filters.status) &&
                (filters.resource === "all" || a.resource === filters.resource) &&
                (filters.type === "all" || a.type === filters.type) &&
                (filters.search === "" || a.customer.toLowerCase().includes(filters.search) || a.type.toLowerCase().includes(filters.search) || a.location.toLowerCase().includes(filters.search))
            );

            container.innerHTML = currentView === "list" ?
                filtered.map(a => `
                    <div class="card mb-3 appointment-card" data-id="${a.id}">
                        <div class="card-header" onclick="toggleCard(${a.id})">
                            <div class="d-flex justify-content-between align-items-center">
                                <div><span class="status-indicator ${a.status}"></span><strong>${a.customer}</strong></div>
                                <span>${new Date(a.date).toLocaleString("en-US", { timeZone: selectedTimeZone })}</span>
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
                `).join("") :
                `<table class="table table-hover">
                    <thead><tr><th>Customer</th><th>Date</th><th>Type</th><th>Resource</th><th>Location</th><th>Status</th><th>Actions</th></tr></thead>
                    <tbody>${filtered.map(a => `
                        <tr>
                            <td>${a.customer}</td><td>${new Date(a.date).toLocaleString("en-US", { timeZone: selectedTimeZone })}</td><td>${a.type}</td>
                            <td>${a.resource}</td><td>${a.location}</td><td><span class="status-indicator ${a.status}"></span>${a.status}</td>
                            <td><button class="btn btn-primary btn-sm" onclick="openEditModal(${a.id})">Edit</button></td>
                        </tr>`).join("")}</tbody>
                </table>`;
        }

        function toggleCard(id) {
            document.querySelector(`.appointment-card[data-id="${id}"]`).classList.toggle("expanded");
        }

        function renderCalendar() {
            const grid = document.getElementById("calendarGrid");
            const monthYear = document.getElementById("calendarMonthYear");
            const tzDate = new Date(currentDate.toLocaleString("en-US", { timeZone: selectedTimeZone }));
            grid.innerHTML = "";

            const headerRow = document.createElement("tr");
            ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"].forEach(day => {
                const th = document.createElement("th");
                th.textContent = day;
                headerRow.appendChild(th);
            });
            grid.appendChild(headerRow);

            if (isMonthView) {
                renderMonthView(grid, monthYear, tzDate);
            } else {
                renderWeekView(grid, monthYear, tzDate);
            }
        }

        function renderMonthView(grid, monthYear, tzDate) {
            const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
            monthYear.textContent = `${months[tzDate.getMonth()]} ${tzDate.getFullYear()}`;

            const firstDay = new Date(tzDate.getFullYear(), tzDate.getMonth(), 1).getDay();
            const daysInMonth = new Date(tzDate.getFullYear(), tzDate.getMonth() + 1, 0).getDate();
            let row = document.createElement("tr");

            for (let i = 0; i < firstDay; i++) row.appendChild(document.createElement("td"));

            for (let day = 1; day <= daysInMonth; day++) {
                const date = new Date(tzDate.getFullYear(), tzDate.getMonth(), day);
                const td = createCalendarCell(date, day);
                row.appendChild(td);
                if ((firstDay + day - 1) % 7 === 6 || day === daysInMonth) {
                    grid.appendChild(row);
                    row = document.createElement("tr");
                }
            }
        }

        function renderWeekView(grid, monthYear, tzDate) {
            const startOfWeek = new Date(tzDate);
            startOfWeek.setDate(startOfWeek.getDate() - startOfWeek.getDay());
            monthYear.textContent = `Week of ${startOfWeek.toLocaleDateString("en-US", { timeZone: selectedTimeZone })}`;

            let row = document.createElement("tr");
            for (let i = 0; i < 7; i++) {
                const date = new Date(startOfWeek);
                date.setDate(startOfWeek.getDate() + i);
                row.appendChild(createCalendarCell(date, date.getDate()));
            }
            grid.appendChild(row);
        }

        function createCalendarCell(date, day) {
            const today = new Date(new Date().toLocaleString("en-US", { timeZone: selectedTimeZone }));
            const td = document.createElement("td");
            td.textContent = day;

            if (date.getDate() === today.getDate() && date.getMonth() === today.getMonth() && date.getFullYear() === today.getFullYear()) {
                td.classList.add("today");
            }

            const events = appointments.filter(a => {
                const apptDate = new Date(a.date);
                return apptDate.getDate() === date.getDate() && apptDate.getMonth() === date.getMonth() && apptDate.getFullYear() === date.getFullYear();
            });

            if (events.length > 0) {
                td.classList.add("booked-date");
                const tooltip = document.createElement("div");
                tooltip.className = "calendar-tooltip";
                tooltip.innerHTML = events.map(e => `${e.customer} - ${new Date(e.date).toLocaleTimeString("en-US", { timeZone: selectedTimeZone, hour: "2-digit", minute: "2-digit" })} (${e.type})`).join("<br>");
                td.appendChild(tooltip);
                td.onclick = () => openEditModal(events[0].id); // Restored clicking functionality
            } else {
                td.onclick = () => openNewModal(`${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(day).padStart(2, '0')}T09:00`);
            }
            return td;
        }

        function toggleView() {
            currentView = document.getElementById("viewToggle").value;
            renderAppointments();
        }

        function prevPeriod() {
            isMonthView ? currentDate.setMonth(currentDate.getMonth() - 1) : currentDate.setDate(currentDate.getDate() - 7);
            renderCalendar();
        }

        function nextPeriod() {
            isMonthView ? currentDate.setMonth(currentDate.getMonth() + 1) : currentDate.setDate(currentDate.getDate() + 7);
            renderCalendar();
        }

        function goToToday() {
            currentDate = new Date();
            isMonthView = true;
            renderCalendar();
        }

        function goToThisWeek() {
            currentDate = new Date();
            isMonthView = false;
            renderCalendar();
        }

        function goToThisMonth() {
            currentDate = new Date();
            isMonthView = true;
            renderCalendar();
        }

        function goToCustomDate() {
            const customDate = new Date(document.getElementById("customDate").value);
            if (customDate) {
                currentDate = customDate;
                isMonthView = true; // Switch to month view for custom date
                renderCalendar();
            }
        }

        function setupTimeZoneSelector() {
            document.getElementById("currentTimezone").textContent = selectedTimeZone;
            populateTimeZones();
            startClock();
        }

        function toggleTimeZoneDropdown() {
            const dropdown = document.getElementById("timezoneDropdown");
            dropdown.style.display = dropdown.style.display === "block" ? "none" : "block";
        }

        function populateTimeZones() {
            const timeZones = Intl.supportedValuesOf('timeZone');
            const list = document.getElementById("timezoneList");
            list.innerHTML = timeZones.map(tz => `
                <div class="timezone-option" onclick="selectTimeZone('${tz}')">${tz}</div>
            `).join("");
        }

        function selectTimeZone(tz) {
            selectedTimeZone = tz;
            document.getElementById("currentTimezone").textContent = tz;
            toggleTimeZoneDropdown();
            renderAppointments();
            renderCalendar();
            updateClock();
        }

        function startClock() {
            if (clockInterval) clearInterval(clockInterval);
            updateClock();
            clockInterval = setInterval(updateClock, 1000);
        }

        function updateClock() {
            const now = new Date();
            document.getElementById("currentTime").textContent = now.toLocaleTimeString("en-US", { timeZone: selectedTimeZone, hour: "2-digit", minute: "2-digit", second: "2-digit" });
        }

        function openNewModal(date = null) {
            const modal = new bootstrap.Modal(document.getElementById("newModal"));
            const form = document.getElementById("newForm");
            form.reset();
            if (date) form.querySelector("[name='date']").value = date;
            modal.show();
        }

        function createAppointment(e) {
            e.preventDefault();
            const form = new FormData(e.target);
            appointments.push({
                id: appointments.length + 1,
                customer: form.get("customer"),
                type: form.get("type"),
                date: form.get("date"),
                resource: "Unassigned",
                status: "pending",
                location: form.get("location"),
                notes: form.get("notes"),
                checklist: form.get("checklist"),
                maintenance: form.get("maintenance") ? form.get("maintenance").name : null
            });
            renderAppointments();
            renderCalendar();
            bootstrap.Modal.getInstance(document.getElementById("newModal")).hide();
        }

        function openEditModal(id) {
            const a = appointments.find(x => x.id === id);
            const form = document.getElementById("editForm");
            form.querySelector("[name='id']").value = a.id;
            form.querySelector("[name='customer']").value = a.customer;
            form.querySelector("[name='type']").value = a.type;
            form.querySelector("[name='date']").value = a.date.slice(0, 16);
            form.querySelector("[name='resource']").value = a.resource;
            form.querySelector("[name='location']").value = a.location;
            form.querySelector("[name='status']").value = a.status;
            form.querySelector("[name='notes']").value = a.notes;
            form.querySelector("[name='checklist']").value = a.checklist;
            const modal = new bootstrap.Modal(document.getElementById("editModal"));
            modal.show();
        }

        function updateAppointment(e) {
            e.preventDefault();
            const form = new FormData(e.target);
            const a = appointments.find(x => x.id === parseInt(form.get("id")));
            a.customer = form.get("customer");
            a.type = form.get("type");
            a.date = form.get("date");
            a.resource = form.get("resource");
            a.location = form.get("location");
            a.status = form.get("status");
            a.notes = form.get("notes");
            a.checklist = form.get("checklist");
            if (form.get("maintenance")) a.maintenance = form.get("maintenance").name;
            renderAppointments();
            renderCalendar();
            bootstrap.Modal.getInstance(document.getElementById("editModal")).hide();
        }

        function openResourceModal(id) {
            // Implementation remains unchanged
        }

        function assignResource(resource) {
            // Implementation remains unchanged
        }

        function openSiteInfoModal(id) {
            // Implementation remains unchanged
        }

        function dispatch(id) {
            const a = appointments.find(x => x.id === id);
            if (a.resource === "Unassigned") {
                alert("Please assign a resource before dispatching.");
                openResourceModal(id);
            } else {
                a.status = "scheduled";
                renderAppointments();
                renderCalendar();
                alert(`Appointment #${id} dispatched to ${a.resource}`);
            }
        }

        function complete(id) {
            const a = appointments.find(x => x.id === id);
            a.status = "completed";
            renderAppointments();
            renderCalendar();
            alert(`Appointment #${id} marked as completed`);
        }
    </script>
</asp:Content>