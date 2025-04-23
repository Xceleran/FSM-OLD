let appointments = JSON.parse(localStorage.getItem('appointments')) || [
    {
        id: 1,
        customerName: "John Doe",
        date: "2025-04-23",
        timeSlot: "morning",
        duration: 2,
        resource: "Jim",
        serviceType: "Tasks",
        status: "confirmed",
        location: { address: "123 Main St, New York, NY", lat: 40.7128, lng: -74.0060 },
        priority: "Low"
    },
    {
        id: 2,
        customerName: "Jane Smith",
        date: null,
        timeSlot: null,
        duration: 2,
        resource: "Unassigned",
        serviceType: "Visits",
        status: "pending",
        location: { address: "456 Branch Rd, Los Angeles, CA", lat: 34.0522, lng: -118.2437 },
        priority: "Medium"
    },
    {
        id: 3,
        customerName: "Alice Johnson",
        date: "2025-04-23",
        timeSlot: "morning",
        duration: 2,
        resource: "Bob",
        serviceType: "Tasks",
        status: "confirmed",
        location: { address: "789 Warehouse Ave, Chicago, IL", lat: 41.8781, lng: -87.6298 },
        priority: "High"
    }
];

let currentView = "date";
let currentDate = new Date();
let currentEditId = null;
let mapViewInstance;
const resources = ["Jim", "Bob", "Team1", "Unassigned"];
const technicianGroups = {
    "electricians": ["Jim", "Bob"],
    "plumbers": ["Team1"]
};
const timeSlots = {
    morning: { start: "08:00", end: "12:00" },
    afternoon: { start: "12:00", end: "16:00" },
    emergency: { start: "08:00", end: "16:00" }
};
const allTimeSlots = [
    { value: "08:00", label: "8:00 AM" },
    { value: "09:00", label: "9:00 AM" },
    { value: "10:00", label: "10:00 AM" },
    { value: "11:00", label: "11:00 AM" },
    { value: "12:00", label: "12:00 PM" },
    { value: "13:00", label: "1:00 PM" },
    { value: "14:00", label: "2:00 PM" },
    { value: "15:00", label: "3:00 PM" },
    { value: "16:00", label: "4:00 PM" }
];

function saveAppointments() {
    try {
        localStorage.setItem('appointments', JSON.stringify(appointments));
    } catch (e) {
        console.error("Error saving to localStorage:", e);
    }
}

function hasConflict(appointment, newTimeSlot, newResource, newDate, excludeId = null) {
    if (!newTimeSlot || !newResource || !newDate) return false;

    const slot = timeSlots[newTimeSlot];
    const startHour = parseInt(slot.start.split(':')[0]);
    const duration = appointment.duration || 1;
    const endHour = startHour + duration;

    return appointments.some(a => {
        if (a.id === excludeId || a.resource !== newResource || a.date !== newDate || !a.timeSlot) return false;

        const aSlot = timeSlots[a.timeSlot];
        const aStart = parseInt(aSlot.start.split(':')[0]);
        const aDuration = a.duration || 1;
        const aEnd = aStart + aDuration;

        return (startHour < aEnd) && (endHour > aStart);
    });
}

function getEventTimeSlotClass(appointment) {
    return appointment.timeSlot === "morning" ? "time-block-morning" :
        appointment.timeSlot === "afternoon" ? "time-block-afternoon" :
            appointment.timeSlot === "emergency" ? "time-block-emergency" : "";
}

function initMapView(date) {
    const container = document.getElementById('mapViewContainer');
    if (mapViewInstance) {
        mapViewInstance.remove();
    }
    mapViewInstance = L.map('mapViewContainer').setView([40.7128, -74.0060], 10);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(mapViewInstance);

    const filteredAppointments = appointments.filter(a => a.date === date && a.location?.lat && a.location?.lng);
    if (filteredAppointments.length > 0) {
        const bounds = L.latLngBounds(filteredAppointments.map(a => [a.location.lat, a.location.lng]));
        mapViewInstance.fitBounds(bounds);
    }

    setTimeout(() => mapViewInstance.invalidateSize(), 0);

    filteredAppointments.forEach(a => {
        L.marker([a.location.lat, a.location.lng])
            .addTo(mapViewInstance)
            .bindPopup(`<b>${a.customerName}</b><br>${a.serviceType}`);
    });
}

function renderDateNav(containerId, selectedDate) {
    const container = $(`#${containerId}`);
    const view = containerId === "dateNav" ? $("#viewSelect").val() : "day";
    let daysToShow = view === "week" ? 7 : view === "threeDay" ? 3 : 1;
    if (view === "month") daysToShow = 0;

    let html = `
        <button class="btn btn-primary" onclick="prevPeriod('${containerId}')"><i class="fas fa-chevron-left"></i></button>
    `;
    if (daysToShow > 0) {
        const startDate = new Date(selectedDate);
        if (view === "week") startDate.setDate(startDate.getDate() - startDate.getDay());
        if (view === "threeDay") startDate.setDate(startDate.getDate() - 1);
        for (let i = 0; i < daysToShow; i++) {
            const d = new Date(startDate);
            d.setDate(startDate.getDate() + i);
            const dateStr = d.toISOString().split('T')[0];
            const isActive = dateStr === selectedDate ? " active" : "";
            html += `
                <div class="date-box${isActive}" data-date="${dateStr}" onclick="selectDate('${dateStr}', '${containerId}')">
                    ${d.toLocaleDateString('en-US', { weekday: 'short', day: 'numeric' })}
                </div>
            `;
        }
    }
    html += `
        <button class="btn btn-primary" onclick="nextPeriod('${containerId}')"><i class="fas fa-chevron-right"></i></button>
        <button class="btn btn-primary ms-2" onclick="gotoToday('${containerId}')">Today</button>
    `;
    container.html(html);
}

function selectDate(date, containerId) {
    currentDate = new Date(date);
    const datePicker = containerId === "dateNav" ? "#dayDatePicker" : "#resourceDatePicker";
    $(datePicker).val(date);
    if (containerId === "dateNav") renderDateView(date);
    else renderResourceView(date);
}

function prevPeriod(containerId) {
    const view = containerId === "dateNav" ? $("#viewSelect").val() : "day";
    if (view === 'month') {
        currentDate.setMonth(currentDate.getMonth() - 1);
    } else {
        currentDate.setDate(currentDate.getDate() - (view === 'week' ? 7 : view === 'threeDay' ? 3 : 1));
    }
    const dateStr = currentDate.toISOString().split('T')[0];
    const datePicker = containerId === "dateNav" ? "#dayDatePicker" : "#resourceDatePicker";
    $(datePicker).val(dateStr);
    if (containerId === "dateNav") renderDateView(dateStr);
    else renderResourceView(dateStr);
}

function nextPeriod(containerId) {
    const view = containerId === "dateNav" ? $("#viewSelect").val() : "day";
    if (view === 'month') {
        currentDate.setMonth(currentDate.getMonth() + 1);
    } else {
        currentDate.setDate(currentDate.getDate() + (view === 'week' ? 7 : view === 'threeDay' ? 3 : 1));
    }
    const dateStr = currentDate.toISOString().split('T')[0];
    const datePicker = containerId === "dateNav" ? "#dayDatePicker" : "#resourceDatePicker";
    $(datePicker).val(dateStr);
    if (containerId === "dateNav") renderDateView(dateStr);
    else renderResourceView(dateStr);
}

function gotoToday(containerId) {
    currentDate = new Date();
    const dateStr = currentDate.toISOString().split('T')[0];
    const datePicker = containerId === "dateNav" ? "#dayDatePicker" : "#resourceDatePicker";
    $(datePicker).val(dateStr);
    if (containerId === "dateNav") renderDateView(dateStr);
    else renderResourceView(dateStr);
}

function renderDateView(date) {
    currentDate = new Date(date);
    const container = $("#dayCalendar").addClass('date-view').removeClass('resource-view');
    const view = $("#viewSelect").val();
    const filter = $("#filterSelect").val();
    const dateStr = currentDate.toISOString().split('T')[0];

    renderDateNav("dateNav", dateStr);

    let filteredAppointments = filter === 'all' ? appointments : appointments.filter(a => a.serviceType === filter);

    let html = `
        <div class="custom-calendar-header">
            <span>${view === 'month' ? currentDate.toLocaleString('default', { month: 'long', year: 'numeric' }) : currentDate.toLocaleDateString()}</span>
        </div>
    `;

    if (view === 'month') {
        const firstDay = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1);
        const lastDay = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 0);
        const startWeek = firstDay.getDay();
        const totalDays = lastDay.getDate();
        let calendarDays = [];
        for (let i = 0; i < startWeek; i++) calendarDays.push(null);
        for (let i = 1; i <= totalDays; i++) calendarDays.push(i);
        while (calendarDays.length % 7 !== 0) calendarDays.push(null);

        html += `
            <div class="calendar-grid-month">
                ${['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map(day => `
                    <div class="text-center font-weight-medium p-2 calendar-header-cell">${day}</div>
                `).join('')}
        `;
        calendarDays.forEach(day => {
            const dayDate = day ? `${currentDate.getFullYear()}-${(currentDate.getMonth() + 1).toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}` : '';
            html += `
                <div class="min-h-100px border p-1 drop-target calendar-cell ${dayDate === dateStr ? 'bg-blue-50 border-blue-200' : ''}" 
                     data-date="${dayDate}">
                    ${day ? `
                        <div class="text-right fs-7 mb-1">${day}</div>
                        <div class="space-y-1">
                            ${filteredAppointments.filter(a => a.date === dayDate).map(a => `
                                <div class="calendar-event ${getEventTimeSlotClass(a)} fs-7 p-1 cursor-move" 
                                     data-id="${a.id}" draggable="true">
                                    ${a.customerName} (${a.serviceType})
                                </div>
                            `).join('')}
                        </div>
                    ` : ''}
                </div>
            `;
        });
        html += `</div>`;
    } else if (view === 'week' || view === 'threeDay') {
        const days = view === 'week' ? 7 : 3;
        const startDate = new Date(currentDate);
        startDate.setDate(currentDate.getDate() - currentDate.getDay());
        if (view === 'threeDay') startDate.setDate(currentDate.getDate() - 1);

        const dayDates = Array.from({ length: days }, (_, i) => {
            const d = new Date(startDate);
            d.setDate(startDate.getDate() + i);
            return d.toISOString().split('T')[0];
        });

        html += `
            <div class="border rounded overflow-hidden">
                <div class="calendar-grid" style="grid-template-columns: 60px repeat(${dayDates.length}, 1fr);">
                    <div class="p-2 border-right bg-gray-50 calendar-header-cell"></div>
                    ${dayDates.map(day => `
                        <div class="p-2 text-center font-weight-medium border-right last-border-right-none bg-gray-50 calendar-header-cell">
                            <div>${new Date(day).toLocaleDateString('en-US', { weekday: 'short' })}</div>
                            <div>${new Date(day).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}</div>
                        </div>
                    `).join('')}
                </div>
                <div class="calendar-body">
        `;

        const renderedAppointments = {};
        const spannedSlots = {};
        dayDates.forEach(d => {
            renderedAppointments[d] = new Set();
            spannedSlots[d] = new Array(allTimeSlots.length).fill(false);
        });

        allTimeSlots.forEach((time, index) => {
            html += `
                <div class="calendar-grid" style="grid-template-columns: 60px repeat(${dayDates.length}, 1fr);">
                    <div class="h-80px border-bottom last-border-bottom-none p-1 fs-7 text-right pr-2 bg-gray-50 calendar-time-cell">
                        ${time.label}
                    </div>
            `;
            dayDates.forEach(dStr => {
                if (spannedSlots[dStr][index]) {
                    html += '<div class="h-80px border-bottom last-border-bottom-none border-right last-border-right-none p-1 calendar-cell"></div>';
                    return;
                }

                const events = filteredAppointments.filter(a =>
                    a.date === dStr &&
                    a.timeSlot &&
                    timeSlots[a.timeSlot].start === time.value &&
                    !renderedAppointments[dStr].has(a.id)
                );

                let cellContent = '';
                let rowspan = 1;

                if (events.length > 0) {
                    events.forEach(a => {
                        const duration = a.duration || 1;
                        rowspan = Math.min(duration, allTimeSlots.length - index);
                        renderedAppointments[dStr].add(a.id);

                        for (let i = index + 1; i < index + rowspan && i < allTimeSlots.length; i++) {
                            spannedSlots[dStr][i] = true;
                        }

                        cellContent += `
                            <div class="calendar-event ${getEventTimeSlotClass(a)} width-95 z-10 cursor-move"
                                 style="height: ${80 * rowspan - 10}px; top: ${2}px;" 
                                 data-id="${a.id}" draggable="true">
                                <div class="font-weight-medium fs-7">${a.customerName}</div>
                                <div class="fs-7 truncate">
                                    ${a.serviceType} (${a.duration}h)
                                </div>
                            </div>
                        `;
                    });
                }

                html += `
                    <div class="h-80px border-bottom last-border-bottom-none border-right last-border-right-none p-1 relative drop-target calendar-cell"
                         data-date="${dStr}" data-time="${time.value}">
                        ${cellContent}
                    </div>
                `;
            });
            html += `</div>`;
        });

        html += `</div></div>`;
    } else {
        html += `
            <div class="border rounded overflow-hidden">
                <div class="calendar-grid" style="grid-template-columns: 60px 1fr;">
                    <div class="p-2 border-right bg-gray-50 calendar-header-cell"></div>
                    <div class="p-2 text-center font-weight-medium bg-gray-50 calendar-header-cell">
                        ${currentDate.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}
                    </div>
                </div>
                <div class="calendar-body">
        `;

        const spannedSlots = new Array(allTimeSlots.length).fill(false);
        const renderedAppointments = new Set();

        allTimeSlots.forEach((time, index) => {
            html += `
                <div class="calendar-grid" style="grid-template-columns: 60px 1fr;">
                    <div class="h-80px border-bottom last-border-bottom-none p-1 fs-7 text-right pr-2 bg-gray-50 calendar-time-cell">
                        ${time.label}
                    </div>
            `;

            if (spannedSlots[index]) {
                html += `
                    <div class="h-80px border-bottom last-border-bottom-none border-right last-border-right-none p-1 relative drop-target calendar-cell"
                         data-date="${dateStr}" data-time="${time.value}">
                    </div>
                `;
            } else {
                const events = filteredAppointments.filter(a =>
                    a.date === dateStr &&
                    a.timeSlot &&
                    timeSlots[a.timeSlot].start === time.value &&
                    !renderedAppointments.has(a.id)
                );

                let cellContent = '';
                let rowspan = 1;

                if (events.length > 0) {
                    events.forEach(a => {
                        const duration = a.duration || 1;
                        rowspan = Math.min(duration, allTimeSlots.length - index);
                        renderedAppointments.add(a.id);

                        for (let i = index + 1; i < index + rowspan && i < allTimeSlots.length; i++) {
                            spannedSlots[i] = true;
                        }

                        cellContent += `
                            <div class="calendar-event ${getEventTimeSlotClass(a)} width-95 z-10 cursor-move"
                                 style="height: ${80 * rowspan - 10}px; top: ${2}px;" 
                                 data-id="${a.id}" draggable="true">
                                <div class="font-weight-medium fs-7">${a.customerName}</div>
                                <div class="fs-7 truncate">
                                    ${a.serviceType} (${a.duration}h)
                                </div>
                            </div>
                        `;
                    });
                }

                html += `
                    <div class="h-80px border-bottom last-border-bottom-none border-right last-border-right-none p-1 relative drop-target calendar-cell"
                         data-date="${dateStr}" data-time="${time.value}">
                        ${cellContent}
                    </div>
                `;
            }
            html += `</div>`;
        });

        html += `</div></div>`;
    }

    container.html(html);
    setupDragAndDrop();
    renderUnscheduledList();
}

function renderResourceView(date) {
    const container = $("#resourceViewContainer").addClass('resource-view').removeClass('date-view');
    const selectedGroup = $("#dispatchGroup").val();
    const dateStr = new Date(date).toISOString().split('T')[0];

    renderDateNav("resourceDateNav", dateStr);

    const filteredResources = selectedGroup === "all" ? resources : technicianGroups[selectedGroup] || [];

    let html = `
        <div class="border rounded overflow-hidden">
            <div class="calendar-grid" style="grid-template-columns: 120px repeat(${allTimeSlots.length}, 1fr);">
                <div class="p-2 border-right bg-gray-50 calendar-header-cell"></div>
                ${allTimeSlots.map(time => `
                    <div class="p-2 text-center font-weight-medium border-right last-border-right-none bg-gray-50 calendar-header-cell">
                        ${time.label}
                    </div>
                `).join('')}
            </div>
            <div class="calendar-body">
    `;

    filteredResources.forEach(resource => {
        html += `
            <div class="calendar-grid" style="grid-template-columns: 120px repeat(${allTimeSlots.length}, 1fr);">
                <div class="h-80px border-bottom last-border-bottom-none p-1 fs-7 text-center bg-gray-50 calendar-time-cell">
                    ${resource}
                </div>
        `;

        let currentCol = 0;
        while (currentCol < allTimeSlots.length) {
            const timeSlot = allTimeSlots[currentCol];
            const appointmentsAtSlot = appointments.filter(a =>
                a.resource === resource &&
                a.date === dateStr &&
                a.timeSlot &&
                timeSlots[a.timeSlot].start === timeSlot.value
            );

            if (appointmentsAtSlot.length > 0) {
                const appointment = appointmentsAtSlot[0];
                const duration = appointment.duration || 1;
                const endCol = Math.min(currentCol + duration, allTimeSlots.length);
                const colspan = endCol - currentCol;

                html += `
                    <div class="h-80px border-bottom last-border-bottom-none border-right last-border-right-none p-1 relative drop-target calendar-cell"
                         data-date="${dateStr}" data-time="${timeSlot.value}" data-resource="${resource}">
                        <div class="calendar-event ${getEventTimeSlotClass(appointment)} width-95 z-10 cursor-move"
                             style="width: ${95 * colspan}%; top: ${2}px;"
                             data-id="${appointment.id}" draggable="true">
                            <div class="font-weight-medium fs-7">${appointment.customerName}</div>
                            <div class="fs-7 truncate">
                                ${appointment.serviceType} (${appointment.duration}h)
                            </div>
                        </div>
                    </div>
                `;
                currentCol += colspan;
            } else {
                html += `
                    <div class="h-80px border-bottom last-border-bottom-none border-right last-border-right-none p-1 relative drop-target calendar-cell"
                         data-date="${dateStr}" data-time="${timeSlot.value}" data-resource="${resource}">
                    </div>
                `;
                currentCol++;
            }
        }

        html += `</div>`;
    });

    html += `</div></div>`;
    container.html(html);
    setupDragAndDrop();
    renderUnscheduledList('resource');
}

function renderListView() {
    const selectedDate = $("#listDatePicker").val() || new Date().toISOString().split('T')[0];
    const tbody = $("#listTableBody");
    const filteredAppointments = appointments.filter(a => a.date === selectedDate);

    tbody.html(filteredAppointments.length === 0 ? '<tr><td colspan="7" class="text-center">No appointments for this date.</td></tr>' :
        filteredAppointments.map(a => {
            const timeSlot = a.timeSlot ? a.timeSlot.charAt(0).toUpperCase() + a.timeSlot.slice(1) : 'N/A';
            const duration = a.duration || 1;
            return `
                <tr data-id="${a.id}">
                    <td>${a.customerName}</td>
                    <td>${a.serviceType}</td>
                    <td>${a.date || 'N/A'}</td>
                    <td>${timeSlot}</td>
                    <td>${duration}h</td>
                    <td>${a.resource}</td>
                    <td>${a.location?.address || 'N/A'}</td>
                </tr>
            `;
        }).join(''));

    $(document).off('click', '#listTableBody tr').on('click', '#listTableBody tr', function () {
        openEditModal($(this).data("id"));
    });
}

function renderMapView() {
    const selectedDate = $("#mapDatePicker").val();
    initMapView(selectedDate);
}

function renderUnscheduledList(view = 'date') {
    const container = view === 'date' ? $("#unscheduledList") : $("#unscheduledListResource");
    const statusFilter = view === 'date' ? $("#statusFilter").val() : $("#statusFilterResource").val();
    const serviceTypeFilter = view === 'date' ? $("#serviceTypeFilter").val() : $("#serviceTypeFilterResource").val();
    const searchFilter = view === 'date' ? $("#searchFilter").val().toLowerCase() : $("#searchFilterResource").val().toLowerCase();

    let unscheduled = appointments.filter(a => !a.date || !a.timeSlot);

    if (statusFilter !== 'all') {
        unscheduled = unscheduled.filter(a => a.status === statusFilter);
    }
    if (serviceTypeFilter !== 'all') {
        unscheduled = unscheduled.filter(a => a.serviceType === serviceTypeFilter);
    }
    if (searchFilter) {
        unscheduled = unscheduled.filter(a => a.customerName.toLowerCase().includes(searchFilter));
    }

    container.html(unscheduled.length === 0 ? '<div class="text-center py-4 text-muted">No unscheduled appointments.</div>' :
        unscheduled.map(a => `
            <div class="appointment-card card mb-3 shadow-sm" data-id="${a.id}" draggable="true">
                <div class="card-body p-3">
                    <div class="d-flex justify-content-between align-items-start">
                        <h3 class="font-weight-medium fs-6 mb-0">${a.customerName}</h3>
                        <span class="badge ${a.priority === 'High' ? 'bg-danger' : a.priority === 'Medium' ? 'bg-warning' : 'bg-success'}">${a.priority}</span>
                    </div>
                    <div class="fs-7 text-muted mt-1 line-clamp-2">${a.location.address}</div>
                    <div class="d-flex justify-content-between align-items-center mt-2">
                        <span class="fs-7">${a.serviceType}</span>
                        <button class="btn btn-outline-secondary btn-sm" onclick="openEditModal(${a.id})">Schedule</button>
                    </div>
                </div>
            </div>
        `).join(''));

    setupDragAndDrop();
}

function setupDragAndDrop() {
    $(".calendar-event, .appointment-card").draggable({
        revert: "invalid",
        zIndex: 1000,
        helper: "clone",
        opacity: 0.7,
        start: function () {
            $(this).addClass("dragging");
        },
        stop: function () {
            $(this).removeClass("dragging");
            updateAllViews();
        }
    });

    $(".drop-target").droppable({
        accept: ".appointment-card, .calendar-event",
        hoverClass: "drag-over",
        drop: function (event, ui) {
            const appointmentId = ui.draggable.data("id");
            const date = $(this).data("date");
            const time = $(this).data("time");
            const resource = $(this).data("resource") ||
                appointments.find(a => a.id === appointmentId)?.resource ||
                "Unassigned";
            const timeSlot = time ? Object.keys(timeSlots).find(slot => timeSlots[slot].start === time) : "morning";

            openConfirmModal(appointmentId, date, timeSlot, resource);
        }
    });

    $("#unscheduledList, #unscheduledListResource").droppable({
        accept: ".calendar-event",
        hoverClass: "drag-over",
        drop: function (event, ui) {
            const appointmentId = ui.draggable.data("id");
            const appointment = appointments.find(a => a.id === appointmentId);
            if (appointment) {
                appointment.date = null;
                appointment.timeSlot = null;
                appointment.duration = 1;
                saveAppointments();
                updateAllViews();
            }
        }
    });

    $(document).off('click', '.calendar-event, .appointment-card').on('click', '.calendar-event, .appointment-card', function () {
        openEditModal($(this).data("id"));
    });
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
    const newAppointment = {
        id: Math.max(...appointments.map(a => a.id), 0) + 1,
        customerName: form.get("customerName"),
        serviceType: form.get("serviceType"),
        date: form.get("date"),
        timeSlot: form.get("timeSlot"),
        duration: parseInt(form.get("duration")) || 1,
        resource: form.get("resource"),
        status: form.get("status"),
        location: {
            address: form.get("address"),
            lat: 40.7128,
            lng: -74.0060
        },
        priority: "Medium"
    };

    if (newAppointment.date && newAppointment.timeSlot && hasConflict(newAppointment, newAppointment.timeSlot, newAppointment.resource, newAppointment.date)) {
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
    if (!a) return;
    currentEditId = id;
    const form = document.getElementById("editForm");
    form.querySelector("[name='id']").value = a.id;
    form.querySelector("[name='customerName']").value = a.customerName;
    form.querySelector("[name='serviceType']").value = a.serviceType;
    form.querySelector("[name='date']").value = a.date || "";
    form.querySelector("[name='timeSlot']").value = a.timeSlot || "morning";
    form.querySelector("[name='duration']").value = a.duration || 1;
    form.querySelector("[name='resource']").value = a.resource;
    form.querySelector("[name='address']").value = a.location.address;
    form.querySelector("[name='status']").value = a.status;

    new bootstrap.Modal(document.getElementById("editModal")).show();
}

function updateAppointment(e) {
    e.preventDefault();
    const form = new FormData(e.target);
    const a = appointments.find(x => x.id === parseInt(form.get("id")));
    if (a) {
        a.customerName = form.get("customerName");
        a.serviceType = form.get("serviceType");
        a.date = form.get("date");
        a.timeSlot = form.get("timeSlot");
        a.duration = parseInt(form.get("duration")) || 1;
        a.resource = form.get("resource");
        a.location.address = form.get("address");
        a.status = form.get("status");
        if (a.date && a.timeSlot && hasConflict(a, a.timeSlot, a.resource, a.date, a.id)) {
            alert("Scheduling conflict detected!");
            return;
        }
        saveAppointments();
        updateAllViews();
        bootstrap.Modal.getInstance(document.getElementById("editModal")).hide();
        currentEditId = null;
    }
}

function openConfirmModal(id, date, timeSlot, resource) {
    const a = appointments.find(x => x.id === id);
    if (!a) {
        console.error("Appointment not found for ID:", id);
        return;
    }
    const modal = new bootstrap.Modal(document.getElementById("confirmModal"));
    const form = document.getElementById("confirmForm");
    form.querySelector("[name='id']").value = id;
    form.querySelector("[name='customerName']").value = a.customerName;
    form.querySelector("[name='date']").value = date || a.date || "";
    form.querySelector("[name='timeSlot']").value = timeSlot || a.timeSlot || "morning";
    form.querySelector("[name='duration']").value = a.duration || 1;
    form.querySelector("[name='resource']").value = resource || a.resource || "Unassigned";
    modal.show();
}

function confirmScheduling(e) {
    e.preventDefault();
    const form = new FormData(e.target);
    const id = parseInt(form.get("id"));
    const appointment = appointments.find(a => a.id === id);
    if (!appointment) {
        console.error("Appointment not found for ID:", id);
        alert("Error: Appointment not found.");
        return;
    }

    const newDate = form.get("date");
    const newTimeSlot = form.get("timeSlot");
    const newDuration = parseInt(form.get("duration")) || 1;
    const newResource = form.get("resource");

    if (!newDate || !newTimeSlot || !newResource) {
        console.warn("Missing required fields:", { newDate, newTimeSlot, newResource });
        alert("Please fill in all required fields.");
        return;
    }

    appointment.date = newDate;
    appointment.timeSlot = newTimeSlot;
    appointment.duration = newDuration;
    appointment.resource = newResource;

    if (hasConflict(appointment, newTimeSlot, newResource, newDate, id)) {
        console.warn("Scheduling conflict detected for appointment:", appointment);
        alert("Scheduling conflict detected!");
        return;
    }

    saveAppointments();
    updateAllViews();
    bootstrap.Modal.getInstance(document.getElementById("confirmModal")).hide();
}

function unscheduleAppointment() {
    const a = appointments.find(x => x.id === currentEditId);
    if (a) {
        a.date = null;
        a.timeSlot = null;
        a.duration = 1;
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
    renderDateView($("#dayDatePicker").val());
    renderResourceView($("#resourceDatePicker").val());
    renderListView();
    renderMapView();
    renderUnscheduledList('date');
    renderUnscheduledList('resource');
}

document.addEventListener('DOMContentLoaded', () => {
    const today = new Date().toISOString().split('T')[0];
    $("#dayDatePicker").val(today);
    $("#resourceDatePicker").val(today);
    $("#listDatePicker").val(today);
    $("#mapDatePicker").val(today);

    $('#viewTabs a').on('shown.bs.tab', function (e) {
        currentView = e.target.id.replace('-tab', '');
        if (currentView === "map") {
            renderMapView();
        } else {
            updateAllViews();
        }
    });

    renderDateView(today);
    renderResourceView(today);
    renderListView();
    renderMapView();
});