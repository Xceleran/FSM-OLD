let appointments = [];

let currentView = "date";
let currentDate = new Date();
let currentEditId = null;
let mapViewInstance = null;
let routeLayer = null;
let customMarkers = [];
let isMapView = true; // true for Map, false for Satellite

const technicianGroups = {
    "electricians": ["Jim", "Bob"],
    "plumbers": ["Team1"]
};
const timeSlots = {
    morning: { start: "08:00", end: "12:00" },
    afternoon: { start: "12:00", end: "16:00" },
    emergency: { start: "18:00", end: "22:00" }
};

var allTimeSlots = [];
var resources = [];

// Fallback function for SweetAlert2
const showAlert = (options) => {
    if (typeof Swal !== 'undefined') {
        return Swal.fire(options); // Return promise for confirmation dialogs
    } else {
        console.warn('SweetAlert2 not loaded, falling back to native alert');
        if (options.showCancelButton) {
            return Promise.resolve({ isConfirmed: confirm(options.text) });
        }
        alert(options.text);
        return Promise.resolve();
    }
};

function getAppoinments(searchValue, fromDate, toDate, today, callback) {
    searchValue = searchValue;
    fromDate = fromDate;
    toDate = toDate;
    today = today;
    $.ajax({
        type: "POST",
        url: "Appointments.aspx/LoadAppoinments",
        data: JSON.stringify({
            searchValue: searchValue,
            fromDate: fromDate,
            toDate: toDate,
            today: today
        }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            appointments = response.d;
            console.log(response.d);
            callback(appointments);
        },
        error: function (xhr, status, error) {
            console.error("Error updating details: ", error);
            callback([]);
        }
    });

    return appointments;
}

// Save appointments to localStorage
function saveAppointments() {
    try {
        localStorage.setItem('appointments', JSON.stringify(appointments));
    } catch (e) {
        console.error("Error saving to localStorage:", e);
    }
}

// Check for scheduling conflicts
function hasConflict_Old(appointment, newTimeSlot, newResource, newDate, excludeId = null) {
    if (!newTimeSlot || !newResource || !newDate) return false;

    const slot = timeSlots[newTimeSlot];
    const startHour = parseInt(slot.start.split(':')[0]);
    const duration = appointment.duration || 1;
    const endHour = startHour + duration;

    return appointments.some(a => {
        if (a.AppoinmentId === excludeId || a.ResourceName !== newResource || a.RequestDate !== newDate || !a.TimeSlot) return false;

        const aSlot = timeSlots[a.timeSlot];
        const aStart = parseInt(aSlot.start.split(':')[0]);
        const aDuration = a.duration || 1;
        const aEnd = aStart + aDuration;

        return (startHour < aEnd) && (endHour > aStart);
    });
}

function hasConflict(appointment, newTimeSlot, newResource, newDate, excludeId = null) {
    if (!newTimeSlot || !newResource || !newDate) return false;

    return appointments.some(a =>
        a.AppoinmentId !== excludeId &&
        a.ResourceName === newResource &&
        a.RequestDate === newDate &&
        a.TimeSlot === newTimeSlot
    );
}

// Get CSS class for time slot
function getEventTimeSlotClass(appointment) {
    const timeSlot = (appointment.TimeSlot || '')
        .toLowerCase()
        .replace(/\s*\(.*\)/, '') // Remove "( 9:00AM - 12:00AM )"
        .trim();
    return timeSlot === "morning" ? "time-block-morning" :
        timeSlot === "afternoon" ? "time-block-afternoon" :
            timeSlot === "emergency" ? "time-block-emergency" : "";
}

// Initialize the Map View
function initMapView(date) {
    const container = document.getElementById('mapViewContainer');
    if (mapViewInstance) {
        mapViewInstance.remove();
    }

    // Initialize the map
    mapViewInstance = L.map('mapViewContainer', {
        zoomControl: true,
        dragging: true,
        scrollWheelZoom: true
    }).setView([40.7128, -74.0060], 10);

    // Add Map/Satellite tile layers
    const mapLayer = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors'
    });
    const satelliteLayer = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
        attribution: '© Esri'
    });

    // Set layer based on current view
    if (isMapView) {
        mapLayer.addTo(mapViewInstance);
    } else {
        satelliteLayer.addTo(mapViewInstance);
    }

    // Render markers
    renderMapMarkers(date);

    // Ensure map renders correctly
    setTimeout(() => {
        mapViewInstance.invalidateSize();
    }, 100);
}

// Render markers on the map based on filters
function renderMapMarkers(date) {
    // Clear existing markers (except custom ones)
    mapViewInstance.eachLayer(layer => {
        if (layer instanceof L.Marker && !customMarkers.includes(layer)) {
            mapViewInstance.removeLayer(layer);
        }
    });

    // Filter appointments based on date, group, and status
    const selectedGroup = $("#mapDispatchGroup").val();
    const selectedStatus = $("#statusFilter").val();

    let filteredAppointments = appointments.filter(a => {
        if (a.date !== date) return false;
        if (!a.location?.lat || !a.location?.lng) return false;
        if (selectedGroup !== 'all' && !technicianGroups[selectedGroup]?.includes(a.resource)) return false;
        if (selectedStatus !== 'all' && a.status.toLowerCase() !== selectedStatus.toLowerCase()) return false;
        return true;
    });

    // Add markers for filtered appointments
    filteredAppointments.forEach(a => {
        const markerColor = a.status.toLowerCase() === 'pending' ? '#f59e0b' : // Amber
            a.status.toLowerCase() === 'dispatched' ? '#6b7280' : // Gray
                a.status.toLowerCase() === 'inroute' ? '#3b82f6' : // Blue
                    '#22c55e'; // Green for Arrived

        const markerIcon = L.divIcon({
            className: 'custom-div-icon',
            html: `<div style="background-color: ${markerColor}; width: 20px; height: 20px; border-radius: 50%; border: 2px solid #fff;"></div>`,
            iconSize: [20, 20],
            iconAnchor: [10, 10]
        });

        const marker = L.marker([a.location.lat, a.location.lng], { icon: markerIcon })
            .addTo(mapViewInstance)
            .bindPopup(`<b>${a.customerName}</b><br>${a.serviceType}<br>Status: ${a.status}`);
    });

    // Adjust map bounds if there are markers
    if (filteredAppointments.length > 0) {
        const bounds = L.latLngBounds(filteredAppointments.map(a => [a.location.lat, a.location.lng]));
        mapViewInstance.fitBounds(bounds);
    }
}

// Add custom marker
function addCustomMarker() {
    const center = mapViewInstance.getCenter();
    const customMarkerIcon = L.divIcon({
        className: 'custom-marker',
        html: '<div style="background-color: #ff0000; width: 20px; height: 20px; border-radius: 50%; border: 2px solid #fff;"></div>',
        iconSize: [20, 20],
        iconAnchor: [10, 10]
    });

    const customMarker = L.marker([center.lat, center.lng], { icon: customMarkerIcon, draggable: true })
        .addTo(mapViewInstance)
        .bindPopup('Custom Marker')
        .on('dragend', () => {
            customMarker.openPopup();
        });

    customMarkers.push(customMarker);
}

// Simulate route optimization (mock implementation)
function optimizeRoute() {
    if (routeLayer) {
        mapViewInstance.removeLayer(routeLayer);
    }

    const selectedDate = $("#mapDatePicker").val();
    const selectedGroup = $("#mapDispatchGroup").val();
    const selectedStatus = $("#statusFilter").val();

    let filteredAppointments = appointments.filter(a => a.date === selectedDate && a.location?.lat && a.location?.lng);
    if (selectedGroup !== 'all') {
        filteredAppointments = filteredAppointments.filter(a => technicianGroups[selectedGroup]?.includes(a.resource));
    }
    if (selectedStatus !== 'all') {
        filteredAppointments = filteredAppointments.filter(a => a.status.toLowerCase() === selectedStatus.toLowerCase());
    }

    if (filteredAppointments.length < 2) {
        showAlert({
            icon: 'warning',
            title: 'Insufficient Appointments',
            text: 'Need at least two appointments to optimize a route.',
            confirmButtonText: 'OK',
            customClass: {
                popup: 'swal-custom-popup',
                title: 'swal-custom-title',
                content: 'swal-custom-content',
                confirmButton: 'swal-custom-button'
            }
        });
        return;
    }

    // Mock route points
    const routePoints = filteredAppointments.map(a => [a.location.lat, a.location.lng]);
    routeLayer = L.polyline(routePoints, { color: '#0000ff', weight: 4, dashArray: '5, 10' }).addTo(mapViewInstance);
    mapViewInstance.fitBounds(routePoints);
}

// Render Map View
function renderMapView() {
    const selectedDate = $("#mapDatePicker").val();
    initMapView(selectedDate);
}

// Simulate real-time updates (mock implementation)
function simulateRealTimeUpdates() {
    setInterval(() => {
        // Mock status change
        const randomAppointment = appointments[Math.floor(Math.random() * appointments.length)];
        const statuses = ['pending', 'dispatched', 'inRoute', 'arrived'];
        randomAppointment.status = statuses[Math.floor(Math.random() * statuses.length)];
        if (currentView === "map") {
            renderMapMarkers(document.getElementById('mapDatePicker').value);
        }
    }, 10000); // Update every 10 seconds
}

// Render date navigation
function renderDateNav(containerId, selectedDate) {
    const container = $(`#${containerId}`);
    const view = containerId === "dateNav" ? $("#viewSelect").val() : "day";
    let daysToShow = view === "week" ? 7 : view === "threeDay" ? 3 : 3; // Show 3 days for day view
    if (view === "month") daysToShow = 0;

    let html = `
        <button class="btn btn-primary" onclick="prevPeriod('${containerId}')"><i class="fas fa-chevron-left"></i></button>
    `;

    if (daysToShow > 0) {
        const selected = new Date(selectedDate);
        const startOffset = Math.floor(daysToShow / 2);
        const startDate = new Date(selected);
        startDate.setDate(selected.getDate() - startOffset);

        html += `<div class="date-boxes">`;
        for (let i = 0; i < daysToShow; i++) {
            const d = new Date(startDate);
            d.setDate(startDate.getDate() + i);
            const dateStr = d.toISOString().split('T')[0];
            const isActive = dateStr === selectedDate ? " active" : "";
            html += `
                <div class="date-box${isActive}" data-date="${dateStr}" onclick="selectDate('${dateStr}', '${containerId}')">
                    <div class="date-weekday">${d.toLocaleDateString('en-US', { weekday: 'short' })}</div>
                    <div class="date-number">${d.getDate()}</div>
                </div>
            `;
        }
        html += `</div>`;
    }

    html += `
        <button class="btn btn-primary" onclick="nextPeriod('${containerId}')"><i class="fas fa-chevron-right"></i></button>
        <button class="btn btn-primary ms-2" onclick="gotoToday('${containerId}')">Today</button>
    `;
    container.html(html);
}

// Select a date
function selectDate(date, containerId) {
    currentDate = new Date(date);
    const datePicker = containerId === "dateNav" ? "#dayDatePicker" : "#resourceDatePicker";
    $(datePicker).val(date);
    if (containerId === "dateNav") renderDateView(date);
    else renderResourceView(date);
}

// Navigate to previous period
function prevPeriod(containerId) {
    const view = containerId === "dateNav" ? $("#viewSelect").val() : "day";
    if (view === 'month') {
        currentDate.setMonth(currentDate.getMonth() - 1);
    } else {
        // Move one day back for day/threeDay/week view
        currentDate.setDate(currentDate.getDate() - 1);
    }
    const dateStr = currentDate.toISOString().split('T')[0];
    const datePicker = containerId === "dateNav" ? "#dayDatePicker" : "#resourceDatePicker";
    $(datePicker).val(dateStr);
    if (containerId === "dateNav") renderDateView(dateStr);
    else renderResourceView(dateStr);
}

// Navigate to next period
function nextPeriod(containerId) {
    const view = containerId === "dateNav" ? $("#viewSelect").val() : "day";
    if (view === 'month') {
        currentDate.setMonth(currentDate.getMonth() + 1);
    } else {
        // Move one day forward for day/threeDay/week view
        currentDate.setDate(currentDate.getDate() + 1);
    }
    const dateStr = currentDate.toISOString().split('T')[0];
    const datePicker = containerId === "dateNav" ? "#dayDatePicker" : "#resourceDatePicker";
    $(datePicker).val(dateStr);
    if (containerId === "dateNav") renderDateView(dateStr);
    else renderResourceView(dateStr);
}

// Go to today
function gotoToday(containerId) {
    currentDate = new Date();
    const dateStr = currentDate.toISOString().split('T')[0];
    const datePicker = containerId === "dateNav" ? "#dayDatePicker" : "#resourceDatePicker";
    $(datePicker).val(dateStr);
    if (containerId === "dateNav") renderDateView(dateStr);
    else renderResourceView(dateStr);
}

// Render Date View
function renderDateView(date) {
    currentDate = new Date(date);
    const container = $("#dayCalendar").addClass('date-view').removeClass('resource-view');
    const view = $("#viewSelect").val();
    const filter = $("#MainContent_ServiceTypeFilter").val();
    const dateStr = currentDate.toISOString().split('T')[0];
    renderDateNav("dateNav", dateStr);
    let fromDate, toDate, today;
    let fromStr, toStr;
    switch (view) {
        case 'month':
            fromDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1);
            toDate = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 1);
            fromStr = fromDate.toISOString().split('T')[0];
            toStr = toDate.toISOString().split('T')[0];
            today = "";
            break;
        case 'week':
            fromDate = new Date(currentDate);
            fromDate.setDate(currentDate.getDate() - currentDate.getDay());
            toDate = new Date(fromDate);
            toDate.setDate(fromDate.getDate() + 6);
            fromStr = fromDate.toISOString().split('T')[0];
            toStr = toDate.toISOString().split('T')[0];
            today = "";
            break;
        case 'threeDay':
            fromDate = new Date(currentDate);
            fromDate.setDate(currentDate.getDate() - 1); // Set to start from the day before
            toDate = new Date(currentDate);
            toDate.setDate(currentDate.getDate() + 1);
            fromStr = fromDate.toISOString().split('T')[0];
            toStr = toDate.toISOString().split('T')[0];
            today = "";
            break;
        default:
            fromStr = "";
            toStr = "";
            today = date;
            break;
    }
    getAppoinments(filter, fromStr, toStr, today, function (appointments) {
        var filteredAppointments = filter === ''
            ? appointments
            : appointments.filter(a => a.ServiceType === filter);

        let html = `
        <div class="custom-calendar-header d-flex justify-content-center">
            <span>${view === 'month' ? currentDate.toLocaleString('default', { month: 'long', year: 'numeric' }) : currentDate.toLocaleDateString()}</span>
        </div>`;

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
                            ${filteredAppointments.filter(a => a.RequestDate === dayDate).map(a => `
                                <div class="calendar-event ${getEventTimeSlotClass(a)} fs-7 p-1 cursor-move" 
                                     data-id="${a.AppoinmentId}" draggable="true">
                                    ${a.CustomerName} 
                                      <div class="fs-7 truncate">${a.ServiceType} (${a.Duration})</div>                                
                                    <div class="fs-7 truncate status">${a.AppoinmentStatus}</div>
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

            if (view === 'week') {
                startDate.setDate(startDate.getDate() - startDate.getDay()); // Sunday
            } else if (view === 'threeDay') {
                startDate.setDate(startDate.getDate() - 1); // Yesterday
            }

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

            if (!allTimeSlots || allTimeSlots.length === 0) {
                html += `
                <div class="text-center py-4 text-muted">
                    No time slots available. Please try refreshing the page.
                </div>
                `;
            } else {
                const renderedAppointments = {};
                const spannedSlots = {};
                dayDates.forEach(d => {
                    renderedAppointments[d] = new Set();
                    spannedSlots[d] = new Array(allTimeSlots.length).fill(false);
                });

                allTimeSlots.forEach((time, index) => {
                    html += `
                    <div class="calendar-grid" style="grid-template-columns: 60px repeat(${dayDates.length}, 1fr);">
                        <div class="h-120px border-bottom last-border-bottom-none p-1 fs-7 text-right pr-2 bg-gray-50 calendar-time-cell">
                            ${formatTimeRange(time.TimeBlockSchedule)}
                        </div>
                    `;
                    dayDates.forEach(dStr => {
                        if (spannedSlots[dStr][index]) {
                            html += '<div class="h-120px border-bottom last-border-bottom-none border-right last-border-right-none p-1 calendar-cell"></div>';
                            return;
                        }

                        const events = filteredAppointments.filter(a =>
                            a.RequestDate === dStr &&
                            a.TimeSlot === time.TimeBlockSchedule &&
                            !renderedAppointments[dStr].has(a.AppoinmentId)
                        );

                        let cellContent = '';
                        let rowspan = 1;

                        if (events.length > 0) {
                            events.forEach(a => {
                                let duration = 1;
                                if (a.TimeSlot == time.TimeBlockSchedule) {
                                    duration = time.Duration;
                                }

                                rowspan = Math.min(duration, allTimeSlots.length - index);
                                renderedAppointments[dStr].add(a.AppoinmentId);

                                for (let i = index + 1; i < index + rowspan && i < allTimeSlots.length; i++) {
                                    spannedSlots[dStr][i] = true;
                                }

                                cellContent += `
                                <div class="calendar-event ${getEventTimeSlotClass(a)} width-95 z-10 cursor-move"
                                     style="height: ${80 * rowspan - 10}px; top: ${2}px;" 
                                     data-id="${a.AppoinmentId}" draggable="true">
                                    <div class="font-weight-medium fs-7">${a.CustomerName}</div>
                                    <div class="fs-7 truncate">${a.ServiceType} (${a.Duration})</div>                                
                                    <div class="fs-7 truncate status">${a.AppoinmentStatus}</div>
                                </div>
                                `;
                            });
                        }

                        html += `
                        <div class="h-120px border-bottom last-border-bottom-none border-right last-border-right-none p-1 relative drop-target calendar-cell"
                             data-date="${dStr}" data-time="${time.TimeBlockSchedule}">
                            ${cellContent}
                        </div>
                        `;
                    });
                    html += `</div>`;
                });
            }

            html += `</div></div>`;
        } else {
            html += `
            <div class="border rounded overflow-hidden">
                <div class="calendar-grid" style="grid-template-columns: 70px 1fr;">
                    <div class="p-2 border-right bg-gray-50 calendar-header-cell"></div>
                    <div class="p-2 text-center font-weight-medium bg-gray-50 calendar-header-cell">
                        ${currentDate.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}
                    </div>
                </div>
                <div class="calendar-body">
            `;

            if (!allTimeSlots || allTimeSlots.length === 0) {
                html += `
                <div class="text-center py-4 text-muted">
                    No time slots available. Please try refreshing the page.
                </div>
                `;
            } else {
                const spannedSlots = new Array(allTimeSlots.length).fill(false);
                const renderedAppointments = new Set();

                allTimeSlots.forEach((time, index) => {
                    html += `
                    <div class="calendar-grid" style="grid-template-columns: 70px 1fr;">
                        <div class="h-120px border-bottom last-border-bottom-none p-1 fs-7 text-right pr-2 bg-gray-50 calendar-time-cell">
                            ${formatTimeRange(time.TimeBlockSchedule)}
                        </div>
                    `;

                    if (spannedSlots[index]) {
                        html += `
                        <div class="h-120px border-bottom last-border-bottom-none border-right last-border-right-none p-1 relative drop-target calendar-cell"
                             data-date="${dateStr}" data-time="${formatTimeRange(time.TimeBlockSchedule)}">
                        </div>
                        `;
                    } else {
                        const events = filteredAppointments.filter(a =>
                            a.RequestDate === dateStr &&
                            a.TimeSlot == time.TimeBlockSchedule &&
                            !renderedAppointments.has(a.AppoinmentId)
                        );

                        let cellContent = '';
                        let rowspan = 1;

                        if (events.length > 0) {
                            events.forEach(a => {
                                let duration = 1;
                                if (a.TimeSlot == time.TimeBlockSchedule) {
                                    duration = time.Duration;
                                }
                                rowspan = Math.min(duration, allTimeSlots.length - index);
                                renderedAppointments.add(a.AppoinmentId);

                                for (let i = index + 1; i < index + rowspan && i < allTimeSlots.length; i++) {
                                    spannedSlots[i] = true;
                                }

                                cellContent += `
                                <div class="calendar-event ${getEventTimeSlotClass(a)} width-95 z-10 cursor-move"
                                     style="height: ${80 * rowspan - 10}px; top: ${2}px;" 
                                     data-id="${a.AppoinmentId}" draggable="true">
                                    <div class="font-weight-medium fs-7">${a.CustomerName}</div>
                                    <div class="fs-7 truncate">${a.ServiceType} (${a.Duration})</div>
                                    <div class="fs-7 truncate status">${a.AppoinmentStatus}</div>
                                </div>
                                `;
                            });
                        }

                        html += `
                        <div class="h-120px border-bottom last-border-bottom-none border-right last-border-right-none p-1 relative drop-target calendar-cell"
                             data-date="${dateStr}" data-time="${time.TimeBlockSchedule}">
                            ${cellContent}
                        </div>
                        `;
                    }
                    html += `</div>`;
                });
            }

            html += `</div></div>`;
        }

        container.html(html);
        setupDragAndDrop();
        renderUnscheduledList();
    });
}
function searchListView(e) {
    e.preventDefault();
    const selectedDateFrom = $("#listDatePickerFrom").val();
    const selectedDateTo = $("#listDatePickerTo").val();
    if (!selectedDateFrom || !selectedDateTo) {
        showAlert({
            icon: 'warning',
            title: 'Missing Dates',
            text: 'Please select both from date and to date.',
            confirmButtonText: 'OK',
            customClass: {
                popup: 'swal-custom-popup',
                title: 'swal-custom-title',
                content: 'swal-custom-content',
                confirmButton: 'swal-custom-button'
            }
        });
        return;
    }
    renderListView();
}
function clearFilterListView(e) {
    e.preventDefault();
    const selectedDateFrom = $("#listDatePickerFrom").val();
    const selectedDateTo = $("#listDatePickerTo").val();
    const statusFilter = $("#MainContent_StatusTypeFilter_List").val();
    const typeFilter = $("#MainContent_ServiceTypeFilter_List").val();
    const searchTerm = $("#search_term").val().trim().toLowerCase();

    if (selectedDateFrom == "" && selectedDateTo == "" && statusFilter == "" && typeFilter == "" && searchTerm == "") {
        return;
    }

    $("#listDatePickerFrom").val("");
    $("#listDatePickerTo").val("");
    $("#MainContent_StatusTypeFilter_List").val("");
    $("#MainContent_ServiceTypeFilter_List").val("");
    $("#search_term").val("");
    renderListView();
}

let currentSort = {
    key: '',
    direction: 'asc' // or 'desc'
};

$(document).off('click', 'th.sortable').on('click', 'th.sortable', function () {
    const key = $(this).data('key');

    if (currentSort.key === key) {
        currentSort.direction = currentSort.direction === 'asc' ? 'desc' : 'asc';
    } else {
        currentSort.key = key;
        currentSort.direction = 'asc';
    }

    // Remove sort classes from all
    $('th.sortable').removeClass('sort-asc sort-desc');

    // Add the new sort class
    $(this).addClass(currentSort.direction === 'asc' ? 'sort-asc' : 'sort-desc');

    renderListView(); // apply sorting and rerender
});


// Render List View
function renderListView() {
    const selectedDateFrom = $("#listDatePickerFrom").val() || "";
    const selectedDateTo = $("#listDatePickerTo").val() || "";
    const statusFilter = $("#MainContent_StatusTypeFilter_List").val();
    const ticketFilter = $("#MainContent_TicketStatusFilter_List").val();
    const typeFilter = $("#MainContent_ServiceTypeFilter_List").val();
    const searchTerm = $("#search_term").val().trim().toLowerCase() || "";

    const tbody = $("#listTableBody");
    getAppoinments(searchTerm, selectedDateFrom, selectedDateTo, "", function (appointments) {
        var filteredAppointments = appointments.filter(item => {
            const matchesType = typeFilter === '' ||
                (item.ServiceType === typeFilter);

            const matchesStatus = statusFilter === '' ||
                (item.AppoinmentStatus === statusFilter);

            const matchesTicket = ticketFilter === '' ||
                (item.TicketStatus === ticketFilter);

            const combinedText = [
                item.CustomerName,
                item.BusinessName,
                item.ResourceName,
                item.Email,
                item.Mobile,
                item.Phone,
                item.Address1
            ].join(' ').toLowerCase();

            const matchesSearch = combinedText.includes(searchTerm);
            return matchesType && matchesStatus && matchesTicket && matchesSearch;
        });

        if (currentSort.key) {
            filteredAppointments.sort((a, b) => {
                const valA = a[currentSort.key] ? a[currentSort.key].toString().toLowerCase() : '';
                const valB = b[currentSort.key] ? b[currentSort.key].toString().toLowerCase() : '';

                if (valA < valB) return currentSort.direction === 'asc' ? -1 : 1;
                if (valA > valB) return currentSort.direction === 'asc' ? 1 : -1;
                return 0;
            });
        }

        tbody.html(filteredAppointments.length === 0 ? '<tr><td colspan="13" class="text-center">No appointments for this date.</td></tr>' :
            filteredAppointments.map(a => {
                const timeSlot = a.TimeSlot ? a.TimeSlot.charAt(0).toUpperCase() + a.TimeSlot.slice(1) : 'N/A';
                return `
        <tr data-id="${a.AppoinmentId}">
            <td data-label="View">
                <button class="btn btn-sm btn-outline-primary view-appointment" data-id="${a.AppoinmentId}">
                    <i class="fas fa-eye"></i>
                </button>
            </td>
            <td data-label="Customer">${a.CustomerName || 'N/A'}</td>
            <td data-label="Business Name">${a.BusinessName || 'N/A'}</td>
            <td data-label="Address">${a.Address1 || 'N/A'}</td>
            <td data-label="Request Date">${a.RequestDate || 'N/A'}</td>
            <td data-label="Time Slot">${formatTimeRange(timeSlot) || 'N/A'}</td>
            <td data-label="Service Type">${a.ServiceType || 'N/A'}</td>
            <td data-label="Email" class="custom-link">${a.Email ? `<a href="mailto:${a.Email}">${a.Email}</a>` : 'N/A'}</td>
            <td data-label="Mobile" class="custom-link">${a.Mobile ? `<a href="tel:${a.Mobile}">${a.Mobile}</a>` : 'N/A'}</td>
            <td data-label="Phone" class="custom-link">${a.Phone ? `<a href="tel:${a.Phone}">${a.Phone}</a>` : 'N/A'}</td>
            <td data-label="Appointment Status">${a.AppoinmentStatus || 'N/A'}</td>
            <td data-label="Resource">${a.ResourceName || 'N/A'}</td>
            <td data-label="Ticket Status">${a.TicketStatus || 'N/A'}</td>
        </tr>
        `;
            }).join(''));

        $(document).off('click', '.view-appointment').on('click', '.view-appointment', function () {
            const appointmentId = $(this).data("id");
            openEditModal(appointmentId);
        });
    });
}

// Render Unscheduled List
function renderUnscheduledList(view = 'date') {
    const container = view === 'date' ? $("#unscheduledList") : $("#unscheduledListResource");
    const statusFilter = view === 'date' ? $("#MainContent_StatusTypeFilter").val() : $("#MainContent_StatusTypeFilter_Resource").val();
    const serviceTypeFilter = view === 'date' ? $("#MainContent_ServiceTypeFilter_2").val() : $("#MainContent_ServiceTypeFilter_Resource").val();
    const searchFilter = view === 'date' ? $("#searchFilter").val().toLowerCase() : $("#searchFilterResource").val().toLowerCase();

    let unscheduled = appointments;

    if (statusFilter !== '') {
        unscheduled = unscheduled.filter(a => a.AppoinmentStatus === statusFilter);
    }
    if (serviceTypeFilter !== '') {
        unscheduled = unscheduled.filter(a => a.ServiceType === serviceTypeFilter);
    }
    if (searchFilter) {
        unscheduled = unscheduled.filter(a => a.CustomerName.toLowerCase().includes(searchFilter));
    }

    container.html(unscheduled.length === 0 ? '<div class="text-center py-4 text-muted">No unscheduled appointments.</div>' :
        unscheduled.map(a => `
           <div class="appointment-card card mb-3 shadow-sm ${getEventTimeSlotClass(a)}" data-id="${a.AppoinmentId}" draggable="true">
                <div class="card-body p-3">
                    <div class="d-flex justify-content-between align-items-start">
                        <h3 class="font-weight-medium fs-6 mb-0">${a.CustomerName}</h3>
                    </div>
                    <div class="fs-7 text-muted mt-1 line-clamp-2">${a.Address1}</div>
                    <div class="fs-7 text-muted mt-1 line-clamp-2">${a.RequestDate}</div>
                    <div class="fs-7 text-muted mt-1 line-clamp-2">${formatTimeRange(a.TimeSlot)}</div>
                    <div class="d-flex justify-content-between align-items-center mt-2">
                        <span class="fs-7">${a.ServiceType}</span>
                        <button class="btn btn-outline-secondary btn-sm" onclick="openEditModal(${a.AppoinmentId})">Schedule</button>
                    </div>
                </div>
            </div>
        `).join(''));

    setupDragAndDrop();
}

// Setup drag-and-drop functionality
function setupDragAndDrop() {
    $(".calendar-event, .appointment-card").draggable({
        revert: "invalid",
        revertDuration: 300,
        zIndex: 1000,
        helper: "clone",
        opacity: 0.7,
        scroll: true,
        scrollSensitivity: 100,
        start: function (event, ui) {
            $(this).addClass("dragging");
            ui.helper.css({
                width: $(this).width(),
                transition: "none",
                transform: "translateZ(0)"
            });
        },
        stop: function () {
            $(this).removeClass("dragging");
            // updateAllViews();
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
                appointments.find(a => a.id === appointmentId)?.ResourceName ||
                "Unassigned";
            //const timeSlot = time ? Object.keys(timeSlots).find(slot => timeSlots[slot].start === time) : "morning";

            openEditModal(appointmentId, date, time, resource, true);
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

// Open modal to create a new appointment
function openNewModal(date = null) {
    const form = document.getElementById("newForm");
    //form.reset();
    if (date) form.querySelector("[name='date']").value = date;
    window.newModalInstance.show();
}

// Create a new appointment
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
        showAlert({
            icon: 'error',
            title: 'Scheduling Conflict',
            text: 'A scheduling conflict was detected!',
            confirmButtonText: 'OK',
            customClass: {
                popup: 'swal-custom-popup',
                title: 'swal-custom-title',
                content: 'swal-custom-content',
                confirmButton: 'swal-custom-button'
            }
        });
        return;
    }

    appointments.push(newAppointment);
    saveAppointments();
    updateAllViews();
    window.newModalInstance.hide();
}

// Open modal to edit an appointment
function openEditModal(id, date, time, resource, confirm) {
    const a = appointments.find(x => x.AppoinmentId === id.toString());
    if (!a) return;
    currentEditId = id;
    const form = document.getElementById("editForm");
    form.querySelector("[id='AppoinmentId']").value = parseInt(a.AppoinmentId);
    form.querySelector("[id='CustomerID']").value = parseInt(a.CustomerID);
    form.querySelector("[name='customerName']").value = a.CustomerName;
    form.querySelector("[name='note']").value = a.Note;
    const service_select = form.querySelector("[id='MainContent_ServiceTypeFilter_Edit']");
    getSelectedId(service_select, a.ServiceType || "");
    const select = form.querySelector("[name='resource']");

    if (confirm) {
        $('.confirm-title').removeClass('d-none');
        $('.edit-title').addClass('d-none');
    } else {
        $('.edit-title').removeClass('d-none');
        $('.confirm-title').addClass('d-none');
    }

    if (resource) {
        getSelectedId(select, resource || "");
    } else {
        getSelectedId(select, a.ResourceName || "");
    }
    if (time) {
        form.querySelector("[name='timeSlot']").value = time;
    } else {
        form.querySelector("[name='timeSlot']").value = a.TimeSlot;
    }
    if (date) {
        if (date < today) {
            showAlert({
                icon: 'error',
                title: 'Invalid Date',
                text: 'The selected date cannot be in the past.',
                confirmButtonText: 'OK',
                customClass: {
                    popup: 'swal-custom-popup',
                    title: 'swal-custom-title',
                    content: 'swal-custom-content',
                    confirmButton: 'swal-custom-button'
                }
            });
            return;
        } else {
            form.querySelector("[name='date']").value = date;
        }
    } else {
        form.querySelector("[name='date']").value = a.RequestDate || '';
    }

    form.querySelector("[name='duration']").value = a.Duration || 0;
    form.querySelector("[name='address']").value = a.Address1 || '';
    const status_select = form.querySelector("[id='MainContent_StatusTypeFilter_Edit']");
    getSelectedId(status_select, a.AppoinmentStatus || "");


    const ticket_status = form.querySelector("[id='MainContent_TicketStatusFilter_Edit']");
    getSelectedId(ticket_status, a.TicketStatus || "");

    // Disable dropdowns if status is "Closed"
    const isClosed = a.AppoinmentStatus.toLowerCase() === "closed";
    service_select.disabled = isClosed;
    status_select.disabled = isClosed;
    ticket_status.disabled = isClosed;

    window.editModalInstance.show();
}

// Update an existing appointment
function updateAppointment(e) {
    e.preventDefault();
    const form = new FormData(e.target);
    const id = form.get("AppoinmentId");
    const appointment = appointments.find(a => a.AppoinmentId === id);
    if (!appointment) return;

    const newDate = form.get("date");
    const newTimeSlot = form.get("timeSlot");

    const formData = document.getElementById("editForm");

    const select_rs = formData.querySelector("[name='resource']");
    const newResource = select_rs.options[select_rs.selectedIndex].text;

    //if (newDate && newTimeSlot && hasConflict(appointment, newTimeSlot, newResource, newDate, id)) {
    //    showAlert({
    //        icon: 'error',
    //        title: 'Scheduling Conflict',
    //        text: 'A scheduling conflict was detected!',
    //        confirmButtonText: 'OK',
    //        customClass: {
    //            popup: 'swal-custom-popup',
    //            title: 'swal-custom-title',
    //            content: 'swal-custom-content',
    //            confirmButton: 'swal-custom-button'
    //        }
    //    });
    //    return;
    //}

    saveAppoinmentData(e);
}

// Open modal to confirm scheduling
function openConfirmModal(id, date, timeSlot, resource) {
    const a = appointments.find(x => x.AppoinmentId === id);
    if (!a) return;
    const form = document.getElementById("confirmForm");
    form.querySelector("[name='id']").value = a.id;
    form.querySelector("[name='customerName']").value = a.customerName;
    form.querySelector("[name='date']").value = date || '';
    form.querySelector("[name='timeSlot']").value = timeSlot || 'morning';
    form.querySelector("[name='duration']").value = a.duration || 1;
    form.querySelector("[name='resource']").value = resource || 'Unassigned';
    window.confirmModalInstance.show();
}

// Confirm scheduling from drag-and-drop
function confirmScheduling(e) {
    e.preventDefault();
    const form = new FormData(e.target);
    const id = parseInt(form.get("id"));
    const appointment = appointments.find(a => a.id === id);
    if (!appointment) return;

    const newDate = form.get("date");
    const newTimeSlot = form.get("timeSlot");
    const newResource = form.get("resource");
    const newDuration = parseInt(form.get("duration")) || 1;

    if (hasConflict(appointment, newTimeSlot, newResource, newDate, id)) {
        showAlert({
            icon: 'error',
            title: 'Scheduling Conflict',
            text: 'A scheduling conflict was detected!',
            confirmButtonText: 'OK',
            customClass: {
                popup: 'swal-custom-popup',
                title: 'swal-custom-title',
                content: 'swal-custom-content',
                confirmButton: 'swal-custom-button'
            }
        });
        return;
    }

    appointment.date = newDate;
    appointment.timeSlot = newTimeSlot;
    appointment.resource = newResource;
    appointment.duration = newDuration;
    saveAppointments();
    updateAllViews();
    window.confirmModalInstance.hide();
}

// Delete an appointment
function deleteAppointment() {
    showAlert({
        icon: 'warning',
        title: 'Confirm Delete',
        text: 'Are you sure you want to delete this appointment?',
        showCancelButton: true,
        confirmButtonText: 'Yes, Delete',
        cancelButtonText: 'Cancel',
        customClass: {
            popup: 'swal-custom-popup',
            title: 'swal-custom-title',
            content: 'swal-custom-content',
            confirmButton: 'swal-custom-button',
            cancelButton: 'swal-custom-cancel-button'
        }
    }).then((result) => {
        if (result.isConfirmed) {
            appointments = appointments.filter(a => a.id !== currentEditId);
            saveAppointments();
            updateAllViews();
            window.editModalInstance.hide();
        }
    });
}

// Unschedule an appointment
function unscheduleAppointment() {
    const appointment = appointments.find(a => a.id === currentEditId);
    if (!appointment) return;
    appointment.date = null;
    appointment.timeSlot = null;
    appointment.duration = 1;
    saveAppointments();
    updateAllViews();
    window.editModalInstance.hide();
}

// Update all views
function updateAllViews() {
    if (currentView === "date") {
        renderDateView($("#dayDatePicker").val());
    } else if (currentView === "resource") {
        renderResourceView($("#resourceDatePicker").val());
    } else if (currentView === "list") {
        renderListView();
    } else if (currentView === "map") {
        renderMapView();
    }
}

var today = new Date().toISOString().split('T')[0];

// Initialize the page
document.addEventListener('DOMContentLoaded', () => {
    // Initialize modal instances (from appointments.js)
    const newModalInstance = new bootstrap.Modal(document.getElementById("newModal"));
    const editModalInstance = new bootstrap.Modal(document.getElementById("editModal"));
    const confirmModalInstance = new bootstrap.Modal(document.getElementById("confirmModal"));

    window.newModalInstance = newModalInstance;
    window.editModalInstance = editModalInstance;
    window.confirmModalInstance = confirmModalInstance;

    // Show loading indicator (from appointments.js)
    $("#dayCalendar").html('<div class="text-center py-4">Loading...</div>');

    // Helper function to check if mobile (from inline script)
    const isMobile = () => window.matchMedia('(max-width: 849px)').matches;

    // Function to toggle calendar expansion (from inline script)
    function toggleCalendarExpansion(view) {
        if (!['dateView', 'resourceView'].includes(view)) {
            console.error('Invalid view parameter:', view);
            return;
        }

        const tabPane = document.getElementById(view);
        if (!tabPane || !tabPane.classList.contains('active')) {
            console.warn(`Tab ${view} is not active, skipping toggle`);
            return;
        }

        const calendarContainer = document.querySelector(`#${view} .calendar-container`);
        const unscheduledPanel = document.querySelector(`#${view} .unscheduled-panel`);
        const toggleUnscheduledBtn = document.getElementById(`toggleUnscheduledBtn${view === 'dateView' ? '' : 'Resource'}`);
        const expandCalendarBtn = document.getElementById(`expandCalendarBtn${view === 'dateView' ? '' : 'Resource'}`);
        const sidebar = document.getElementById('sidebar');
        const toggleSidebarBtn = document.getElementById('toggleSidebar');
        const sidebarTexts = document.querySelectorAll('.sidebar-text');
        const sidebarIcons = document.querySelectorAll('.sidebar-icon');

        if (!calendarContainer || !unscheduledPanel || !toggleUnscheduledBtn || !expandCalendarBtn || !sidebar || !toggleSidebarBtn) {
            console.error('Required elements not found for view:', view, {
                calendarContainer,
                unscheduledPanel,
                toggleUnscheduledBtn,
                expandCalendarBtn,
                sidebar,
                toggleSidebarBtn
            });
            return;
        }

        const isExpanded = calendarContainer.classList.toggle('expanded');
        unscheduledPanel.classList.toggle('collapsed', isExpanded);
        toggleUnscheduledBtn.style.display = isExpanded ? 'block' : 'none';
        expandCalendarBtn.innerHTML = isExpanded ? '<i class="fas fa-compress"></i>' : '<i class="fas fa-expand"></i>';

        localStorage.setItem(`${view}CalendarExpanded`, isExpanded);
        window.isCalendarExpanded = isExpanded;

        console.log('Before sidebar state update:', {
            isExpanded,
            isMobile: isMobile(),
            sidebarClasses: sidebar.classList.toString(),
            transform: sidebar.style.transform,
            isCalendarExpanded: window.isCalendarExpanded
        });

        sidebar.classList.remove('sidebar-expanded', 'sidebar-collapsed', 'sidebar-hidden', 'sidebar-mobile');

        if (isExpanded) {
            if (isMobile()) {
                sidebar.classList.add('sidebar-hidden', 'sidebar-mobile');
                sidebar.style.transform = 'translateX(-100%)';
                toggleSidebarBtn.textContent = '☰';
                toggleSidebarBtn.classList.remove('collapsed');
                sidebarTexts.forEach(text => text.style.display = 'inline');
                sidebarIcons.forEach(icon => icon.style.display = 'inline');
            } else {
                sidebar.classList.add('sidebar-collapsed');
                sidebar.style.transform = '';
                toggleSidebarBtn.textContent = '☰';
                toggleSidebarBtn.classList.add('collapsed');
                sidebarTexts.forEach(text => text.style.display = 'none');
                sidebarIcons.forEach(icon => icon.style.display = 'inline');
            }
        } else {
            if (isMobile()) {
                sidebar.classList.add('sidebar-hidden', 'sidebar-mobile');
                sidebar.style.transform = 'translateX(-100%)';
                toggleSidebarBtn.textContent = '☰';
                toggleSidebarBtn.classList.remove('collapsed');
                sidebarTexts.forEach(text => text.style.display = 'inline');
                sidebarIcons.forEach(icon => icon.style.display = 'inline');
            } else {
                sidebar.classList.add('sidebar-expanded');
                sidebar.style.transform = '';
                toggleSidebarBtn.textContent = '➤';
                toggleSidebarBtn.classList.remove('collapsed');
                sidebarTexts.forEach(text => text.style.display = 'inline');
                sidebarIcons.forEach(icon => icon.style.display = 'inline');
            }
        }

        setTimeout(() => {
            console.log('After sidebar state update (delayed) for view:', view, {
                isExpanded: calendarContainer.classList.contains('expanded'),
                isMobile: isMobile(),
                sidebarClasses: sidebar.classList.toString(),
                transform: sidebar.style.transform,
                toggleBtnText: toggleSidebarBtn.textContent,
                sidebarTextDisplay: sidebarTexts[0]?.style.display,
                sidebarIconDisplay: sidebarIcons[0]?.style.display,
                tabActive: tabPane.classList.contains('active'),
                isCalendarExpanded: window.isCalendarExpanded
            });
        }, 0);

        window.dispatchEvent(new Event('resize'));
    }

    // Function to toggle unscheduled panel (from inline script)
    function toggleUnscheduledPanel(view) {
        const calendarContainer = document.querySelector(`#${view} .calendar-container`);
        const unscheduledPanel = document.querySelector(`#${view} .unscheduled-panel`);
        const toggleUnscheduledBtn = document.getElementById(`toggleUnscheduledBtn${view === 'dateView' ? '' : 'Resource'}`);
        const expandCalendarBtn = document.getElementById(`expandCalendarBtn${view === 'dateView' ? '' : 'Resource'}`);

        if (!calendarContainer || !unscheduledPanel || !toggleUnscheduledBtn || !expandCalendarBtn) return;

        const isCollapsed = unscheduledPanel.classList.toggle('collapsed');
        toggleUnscheduledBtn.innerHTML = isCollapsed ? '<i class="fas fa-chevron-left"></i>' : '<i class="fas fa-chevron-right"></i>';
        if (!isCollapsed) {
            calendarContainer.classList.remove('expanded');
            toggleUnscheduledBtn.style.display = 'none';
            expandCalendarBtn.innerHTML = '<i class="fas fa-expand"></i>';
            localStorage.setItem(`${view}CalendarExpanded`, false);
        } else {
            toggleUnscheduledBtn.style.display = 'block';
        }
        window.dispatchEvent(new Event('resize'));
    }

    // Initialize calendar state for both views (from inline script)
    ['dateView', 'resourceView'].forEach(view => {
        const expandCalendarBtn = document.getElementById(`expandCalendarBtn${view === 'dateView' ? '' : 'Resource'}`);
        const toggleUnscheduledBtn = document.getElementById(`toggleUnscheduledBtn${view === 'dateView' ? '' : 'Resource'}`);

        if (expandCalendarBtn) {
            expandCalendarBtn.addEventListener('click', () => toggleCalendarExpansion(view));
        }
        if (toggleUnscheduledBtn) {
            toggleUnscheduledBtn.addEventListener('click', () => toggleUnscheduledPanel(view));
        }

        if (localStorage.getItem(`${view}CalendarExpanded`) === 'true') {
            toggleCalendarExpansion(view);
        }
    });

    // Initialize Bootstrap tooltips (from inline script)
    // Initialize Bootstrap tooltips with hover-only trigger
    document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(el => {
        new bootstrap.Tooltip(el, {
            trigger: 'hover' // Show only on hover, hide when mouse leaves
        });
    });

    // Reset expansion state when switching tabs (from inline script)
    const tabs = document.querySelectorAll('#viewTabs button[data-bs-toggle="tab"]');
    tabs.forEach(tab => {
        tab.addEventListener('shown.bs.tab', function (event) {
            ['dateView', 'resourceView'].forEach(view => {
                if (event.target.id !== (view === 'dateView' ? 'date-tab' : 'resource-tab')) {
                    const calendarContainer = document.querySelector(`#${view} .calendar-container`);
                    const unscheduledPanel = document.querySelector(`#${view} .unscheduled-panel`);
                    const toggleUnscheduledBtn = document.getElementById(`toggleUnscheduledBtn${view === 'dateView' ? '' : 'Resource'}`);
                    const expandCalendarBtn = document.getElementById(`expandCalendarBtn${view === 'dateView' ? '' : 'Resource'}`);
                    if (calendarContainer && unscheduledPanel && toggleUnscheduledBtn && expandCalendarBtn) {
                        calendarContainer.classList.remove('expanded');
                        unscheduledPanel.classList.remove('collapsed');
                        toggleUnscheduledBtn.style.display = 'none';
                        expandCalendarBtn.innerHTML = '<i class="fas fa-expand"></i>';
                        localStorage.setItem(`${view}CalendarExpanded`, false);
                        window.dispatchEvent(new Event('resize'));
                    }
                }
            });
        });
    });

    // Wait for time slots and resources to load (from appointments.js)
    Promise.all([getTimeSlots(), getResources()])
        .then(() => {
            document.getElementById('dateInput').min = today;
            $("#dayDatePicker").val(today);
            $("#resourceDatePicker").val(today);
            $("#listDatePicker").val(today);
            $("#mapDatePicker").val(today);
            renderDateView(today);

            // Set up tab event listeners (from appointments.js)
            const tabs = document.querySelectorAll('#viewTabs button[data-bs-toggle="tab"]');
            tabs.forEach(tab => {
                tab.addEventListener('shown.bs.tab', function (event) {
                    switch (event.target.id) {
                        case 'date-tab':
                            currentView = "date";
                            renderDateView(today);
                            break;
                        case 'resource-tab':
                            currentView = "resource";
                            renderResourceView(today);
                            break;
                        case 'list-tab':
                            currentView = "list";
                            renderListView();
                            break;
                        case 'map-tab':
                            currentView = "map";
                            renderMapView();
                            setTimeout(() => {
                                if (typeof mapViewInstance !== 'undefined') {
                                    mapViewInstance.invalidateSize();
                                }
                            }, 100);
                            break;
                    }
                });
            });

            // Map View event listeners (from appointments.js)
            document.getElementById('mapDatePicker').addEventListener('change', (e) => {
                renderMapMarkers(e.target.value);
            });

            document.getElementById('statusFilter').addEventListener('change', () => {
                renderMapMarkers(document.getElementById('mapDatePicker').value);
            });

            document.getElementById('mapReloadBtn').addEventListener('click', () => {
                renderMapMarkers(document.getElementById('mapDatePicker').value);
            });

            document.getElementById('mapOptimizeRouteBtn').addEventListener('click', optimizeRoute);
            document.getElementById('mapAddCustomMarkerBtn').addEventListener('click', addCustomMarker);

            document.getElementById('map-layer-tab').addEventListener('click', () => {
                isMapView = true;
                renderMapView();
            });

            document.getElementById('satellite-layer-tab').addEventListener('click', () => {
                isMapView = false;
                renderMapView();
            });

            simulateRealTimeUpdates();
        })
        .catch((error) => {
            console.error("Failed to load initial data:", error);
            $("#dayCalendar").html('<div class="text-center py-4 text-muted">Failed to load data. Please try refreshing the page.</div>');
        });

    // Handle modal dismissals (from appointments.js)
    document.querySelectorAll('[data-bs-dismiss="modal"]').forEach(button => {
        button.addEventListener('click', function () {
            const modal = bootstrap.Modal.getInstance(this.closest('.modal'));
            modal.hide();
        });
    });
});

function calculateDurationInMinutes(startTime, endTime) {
    const parseTime = timeStr => {
        const [time, modifier] = timeStr.split(' ');
        let [hours, minutes] = time.split(':').map(Number);
        if (modifier === 'PM' && hours !== 12) hours += 12;
        if (modifier === 'AM' && hours === 12) hours = 0;
        return hours * 60 + minutes;
    };

    const startMinutes = parseTime(startTime);
    const endMinutes = parseTime(endTime);
    return endMinutes - startMinutes;
}

function getTimeSlots() {
    return $.ajax({
        type: "POST",
        url: "Appointments.aspx/GetTimeSlots",
        data: {},
        contentType: "application/json; charset=utf-8",
        dataType: "json"
    }).then(function (response) {
        console.log(response.d);
        allTimeSlots = response.d;
        renderTimeSlots(response.d);
        populateTimeSlotDropdown(response.d);
    }).catch(function (xhr, status, error) {
        console.error("Error updating details: ", error);
        throw error;
    });
}

function renderTimeSlots(timeSlots) {
    const container = $(".time-slot-indicators");
    container.empty();
    timeSlots.forEach(slot => {
        const fullLabel = slot.TimeBlock; // e.g., "Morning ( 9:00AM )"

        // Extract the first word before "(" for the class
        const match = fullLabel.match(/^(\w+)/);
        const timeBlockClass = match ? match[1].toLowerCase() : "default";

        const className = `time-block-${timeBlockClass}`;
        const html = `<span class="time-block-indicator ${className}"></span>${slot.TimeBlockSchedule} `;

        container.append(html);
    });
}

function getResources() {
    return $.ajax({
        type: "POST",
        url: "Appointments.aspx/GetResourcess",
        data: {},
        contentType: "application/json; charset=utf-8",
        dataType: "json"
    }).then(function (response) {
        console.log(response.d);
        resources = response.d;
        populateResourceDropdown(response.d);
    }).catch(function (xhr, status, error) {
        console.error("Error updating details: ", error);
        throw error;
    });
}

// Render Resource View
function renderResourceView(date) {
    const container = $("#resourceViewContainer").addClass('resource-view').removeClass('date-view');
    const selectedGroup = $("#dispatchGroup").val();
    const dateStr = new Date(date).toISOString().split('T')[0];

    renderDateNav("resourceDateNav", dateStr);

    const filteredResources = resources;

    // Call getAppoinments and pass a callback
    getAppoinments("", "", "", dateStr, function (appointments) {
        let html = `
            <div class="border rounded overflow-hidden">
                <div class="calendar-grid" style="grid-template-columns: 120px repeat(${allTimeSlots.length}, 1fr);">
                    <div class="p-2 border-right bg-gray-50 calendar-header-cell"></div>
                    ${allTimeSlots.map(time => `
                        <div class="p-2 text-center font-weight-medium border-right last-border-right-none bg-gray-50 calendar-header-cell">
                            ${formatTimeRange(time.TimeBlockSchedule)}
                        </div>
                    `).join('')}
                </div>
                <div class="calendar-body">
        `;

        if (!allTimeSlots || allTimeSlots.length === 0 || !resources || resources.length === 0) {
            html += `
            <div class="text-center py-4 text-muted">
                No resources or time slots available. Please try refreshing the page.
            </div>
            `;
        } else {
            filteredResources.forEach(resource => {
                html += `
                    <div class="calendar-grid" style="grid-template-columns: 120px repeat(${allTimeSlots.length}, 1fr);">
                        <div class="h-120px border-bottom last-border-bottom-none p-1 fs-7 text-center bg-gray-50 calendar-time-cell">
                            ${resource.ResourceName}
                        </div>
                `;

                const occupiedSlots = new Array(allTimeSlots.length).fill(false);

                appointments
                    .filter(a => a.ResourceName === resource.ResourceName && a.RequestDate === dateStr && a.TimeSlot)
                    .forEach(a => {
                        const startIndex = allTimeSlots.findIndex(slot => slot.TimeBlockSchedule === a.TimeSlot);
                        if (startIndex !== -1) {
                            occupiedSlots[startIndex] = { appointment: a };
                        }
                    });

                let index = 0;
                while (index < allTimeSlots.length) {
                    if (occupiedSlots[index] && occupiedSlots[index].appointment) {
                        const appointment = occupiedSlots[index].appointment;
                        const duration = appointment.Duration || 1;
                        const colspan = 1;

                        html += `
                            <div class="h-120px border-bottom last-border-bottom-none border-right last-border-right-none p-1 relative drop-target calendar-cell"
                                 style="grid-column: span ${colspan};"
                                 data-date="${dateStr}" data-time="${allTimeSlots[index].TimeBlockSchedule}" data-resource="${resource.ResourceName}">
                                <div class="calendar-event ${getEventTimeSlotClass(appointment)} width-95 z-10 cursor-move"
                                     data-id="${appointment.AppoinmentId}" draggable="true">
                                    <div class="font-weight-medium fs-7">${appointment.CustomerName}</div>
                                    <div class="fs-7 truncate">${appointment.ServiceType} (${appointment.Duration})</div>
                                    <div class="fs-7 truncate">${formatTimeRange(appointment.TimeSlot)}</div>
                                    <div class="fs-7 truncate status">${appointment.AppoinmentStatus}</div>
                                </div>
                            </div>
                        `;
                        index += colspan;
                    } else {
                        html += `
                            <div class="h-120px border-bottom last-border-bottom-none border-right last-border-right-none p-1 relative drop-target calendar-cell"
                                 data-date="${dateStr}" data-time="${allTimeSlots[index].TimeBlockSchedule}" data-resource="${resource.ResourceName}">
                            </div>
                        `;
                        index += 1;
                    }
                }

                html += `</div>`;
            });
        }

        html += `</div></div>`;
        container.html(html);
        setupDragAndDrop();
        renderUnscheduledList('resource');
    });
}

function formatTimeRange(str) {
    return str.replace(/[()]/g, '')
        .trim()
        .replace(/\s{2,}/g, ' ')
        .trim();
}

function populateResourceDropdown(resources) {
    const $dropdown = $("#resource_list");
    $dropdown.empty(); // clear existing options

    // Add default option (like Unassigned)
    $dropdown.append(`<option value="0">Unassigned</option>`);

    // Add options from resources
    resources.forEach(resource => {
        $dropdown.append(`<option value="${resource.Id}">${resource.ResourceName}</option>`);
    });
}

function getSelectedId(select, targetName) {
    let matched = false;

    for (const option of select.options) {
        if (option.text.trim() === targetName.trim()) {
            select.value = option.value;
            matched = true;
            break;
        }
    }

    // If no match, select the first option
    if (!matched && select.options.length > 0) {
        select.selectedIndex = 0;
    }
}

function populateTimeSlotDropdown(slots) {
    const $dropdown = $("#time_slot");
    $dropdown.empty(); // clear existing options

    // Add default option (like Unassigned)
    $dropdown.append(`<option value="0">Select</option>`);

    // Add options from resources
    slots.forEach(slot => {
        $dropdown.append(`<option value="${slot.TimeBlockSchedule}">${slot.TimeBlockSchedule}</option>`);
    });
}

function saveAppoinmentData(e) {
    e.preventDefault();
    const form = new FormData(e.target);
    const id = form.get("AppoinmentId");
    const appointment = {};
    appointment.AppoinmentId = parseInt(id);
    appointment.CustomerID = parseInt(form.get("CustomerID"));
    appointment.ServiceType = form.get("ctl00$MainContent$ServiceTypeFilter_Edit");
    appointment.RequestDate = form.get("date");
    appointment.TimeSlot = form.get("timeSlot");
    appointment.ResourceID = parseInt(form.get("resource"));
    appointment.Status = form.get("ctl00$MainContent$StatusTypeFilter_Edit");
    appointment.TicketStatus = form.get("ctl00$MainContent$TicketStatusFilter_Edit");
    appointment.Note = form.get("note");

    $.ajax({
        type: "POST",
        url: "Appointments.aspx/UpdateAppointment",
        data: JSON.stringify({ appointment: appointment }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            if (response.d) {
                showAlert({
                    icon: 'success',
                    title: 'Success',
                    text: 'Appointment updated successfully!',
                    confirmButtonText: 'OK',
                    timer: 3000,
                    customClass: {
                        popup: 'swal-custom-popup',
                        title: 'swal-custom-title',
                        content: 'swal-custom-content',
                        confirmButton: 'swal-custom-button'
                    }
                });
            } else {
                showAlert({
                    icon: 'error',
                    title: 'Error',
                    text: 'Something went wrong while updating the appointment.',
                    confirmButtonText: 'OK',
                    customClass: {
                        popup: 'swal-custom-popup',
                        title: 'swal-custom-title',
                        content: 'swal-custom-content',
                        confirmButton: 'swal-custom-button'
                    }
                });
            }

            updateAllViews();
            window.editModalInstance.hide();
        },
        error: function (xhr, status, error) {
            console.error("Error updating details: ", error);
            window.editModalInstance.hide();
        }
    });
}

function calculateTimeRequired(e) {
    e.preventDefault();
    const selectedValue = e.target.value;
    if (selectedValue) {
        $.ajax({
            type: "POST",
            url: "Appointments.aspx/GetDuration",
            data: JSON.stringify({ serviceTypeID: selectedValue }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                console.log(response.d);
                const form = document.getElementById("editForm");
                form.querySelector("[name='duration']").value = response.d || 0;
            },
            error: function (xhr, status, error) {
                console.error("Error updating details: ", error);
            }
        });
    }
}