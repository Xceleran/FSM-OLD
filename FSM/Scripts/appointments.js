﻿// Global variables
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
var timerequired_Hour = 0;
var timerequired_Minute = 0;

// Fallback function for SweetAlert2
const showAlert = (options) => {
    if (typeof Swal !== 'undefined') {
        return Swal.fire(options);
    } else {
        console.warn(' Facade pattern not found: Swal not loaded, falling back to native alert');
        if (options.showCancelButton) {
            return Promise.resolve({ isConfirmed: confirm(options.text) });
        }
        alert(options.text);
        return Promise.resolve();
    }
};

// Calculate appointment duration in minutes
function parseDuration(durationString) {
    if (!durationString) return 60; // Default to 60 minutes if empty
    let totalMinutes = 0;
    // Normalize the string by replacing colons and multiple spaces
    const normalized = durationString.replace(/\s*:\s*/g, ' ').trim();
    const hourMatch = normalized.match(/(\d+)\s*Hr/i);
    const minuteMatch = normalized.match(/(\d+)\s*Min/i);
    if (hourMatch) totalMinutes += parseInt(hourMatch[1], 10) * 60;
    if (minuteMatch) totalMinutes += parseInt(minuteMatch[1], 10);
    return totalMinutes || 60; // Default to 60 minutes if parsing fails
}

// Parse time string (e.g., "8:00 AM" or "morning") to minutes since midnight


function parseTimeToMinutes(timeStr) {
    if (!timeStr) return 0;

    // Check if timeStr is a time slot key (e.g., "morning", "afternoon", "emergency")
    const lowerTimeStr = timeStr.toLowerCase();
    if (timeSlots[lowerTimeStr]) {
        timeStr = timeSlots[lowerTimeStr].start; // Use start time from timeSlots
    } else {
        // Check if timeStr matches a TimeBlock in allTimeSlots
        const matchingSlot = allTimeSlots.find(slot =>
            slot.TimeBlock.toLowerCase() === lowerTimeStr ||
            slot.TimeBlockSchedule.toLowerCase() === lowerTimeStr
        );
        if (matchingSlot) {
            timeStr = matchingSlot.TimeBlockSchedule.split('-')[0];
        }
    }


    const [time, period] = timeStr.trim().split(/\s+/);
    let [hours, minutes] = time.split(':').map(Number);
    if (isNaN(hours) || isNaN(minutes)) {
        console.warn(`Invalid time format: ${timeStr}`);
        return 0; // Fallback to 0 if parsing fails
    }
    if (period && period.toUpperCase() === 'PM' && hours !== 12) hours += 12;
    if (period && period.toUpperCase() === 'AM' && hours === 12) hours = 0;
    return hours * 60 + minutes;
}

// Update getAppoinments
function getAppoinments(searchValue, fromDate, toDate, today, callback) {
    searchValue = searchValue || "";
    fromDate = fromDate || "";
    toDate = toDate || "";
    today = today || "";
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
            console.log('Appointments loaded:', appointments.map(a => ({
                AppoinmentId: a.AppoinmentId,
                ServiceType: a.ServiceType
            })));
            populatePostalCodeDropdowns();
            callback(appointments);
        },
        error: function (xhr, status, error) {
            console.error('Error loading appointments:', error);
            callback([]);
        }
    });
}
// Populate Postal Code dropdowns
function populatePostalCodeDropdowns() {
    const postalCodes = [...new Set(appointments
        .map(app => app.PostalCode)
        .filter(code => code && code.trim() !== ''))].sort();

    const $postalCodeFilter = $('#PostalCodeFilter');
    const $postalCodeFilterResource = $('#PostalCodeFilterResource');

    $postalCodeFilter.empty().append('<option value="all">All Postal Codes</option>');
    $postalCodeFilterResource.empty().append('<option value="all">All Postal Codes</option>');

    postalCodes.forEach(code => {
        const option = `<option value="${code}">${code}</option>`;
        $postalCodeFilter.append(option);
        $postalCodeFilterResource.append(option);
    });
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
    const serviceType = (appointment.ServiceType || '').toLowerCase().trim();
    if (serviceType.includes('it support') || serviceType.includes('it')) {
        return 'service-type-it-support';
    } else if (serviceType.includes('1 hour') || serviceType.includes('1 hr')) {
        return 'service-type-1-hour';
    } else if (serviceType.includes('2 hour') || serviceType.includes('2 hr')) {
        return 'service-type-2-hour';
    } else {
        return 'service-type-default';
    }
}

// Initialize the Map View
function initMapView(date) {
    const container = document.getElementById('mapViewContainer');
    if (mapViewInstance) {
        mapViewInstance.remove();
    }

    mapViewInstance = L.map('mapViewContainer', {
        zoomControl: true,
        dragging: true,
        scrollWheelZoom: true
    }).setView([40.7128, -74.0060], 10);

    const mapLayer = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors'
    });
    const satelliteLayer = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
        attribution: '© Esri'
    });

    if (isMapView) {
        mapLayer.addTo(mapViewInstance);
    } else {
        satelliteLayer.addTo(mapViewInstance);
    }

    renderMapMarkers(date);

    setTimeout(() => {
        mapViewInstance.invalidateSize();
    }, 100);
}

// Render markers on the map based on filters
function renderMapMarkers(date) {
    mapViewInstance.eachLayer(layer => {
        if (layer instanceof L.Marker && !customMarkers.includes(layer)) {
            mapViewInstance.removeLayer(layer);
        }
    });

    const selectedGroup = $("#mapDispatchGroup").val();
    const selectedStatus = $("#statusFilter").val();

    let filteredAppointments = appointments.filter(a => {
        if (a.date !== date) return false;
        if (!a.location?.lat || !a.location?.lng) return false;
        if (selectedGroup !== 'all' && !technicianGroups[selectedGroup]?.includes(a.resource)) return false;
        if (selectedStatus !== 'all' && a.status.toLowerCase() !== selectedStatus.toLowerCase()) return false;
        return true;
    });

    filteredAppointments.forEach(a => {
        const markerColor = a.status.toLowerCase() === 'pending' ? '#f59e0b' :
            a.status.toLowerCase() === 'dispatched' ? '#6b7280' :
                a.status.toLowerCase() === 'inroute' ? '#3b82f6' :
                    '#22c55e';

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
        filteredAppointments = filteredAppointments.filter(a => a.status.toLowerCase() !== selectedStatus.toLowerCase());
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
        const randomAppointment = appointments[Math.floor(Math.random() * appointments.length)];
        const statuses = ['pending', 'dispatched', 'inRoute', 'arrived'];
        randomAppointment.status = statuses[Math.floor(Math.random() * statuses.length)];
        if (currentView === "map") {
            renderMapMarkers(document.getElementById('mapDatePicker').value);
        }
    }, 10000);
}

// Render date navigation
function renderDateNav(containerId, selectedDate) {
    const container = $(`#${containerId}`);
    const view = containerId === "dateNav" ? $("#viewSelect").val() : "day";
    let daysToShow = view === "week" ? 7 : view === "threeDay" ? 3 : 3;
    if (view === "month") daysToShow = 0;

    let html = `
        <button class="btn btn-primary" onclick="prevPeriod('${containerId}')"><i class="fas fa-chevron-left"></i></button>
    `;
    if (daysToShow > 0) {
        const startDate = new Date(selectedDate); // Start from today


        // Collect date info
        let dateArray = [];
        let activeBox = "";
        let otherBoxes = [];

        for (let i = 0; i < daysToShow; i++) {
            const d = new Date(startDate);
            d.setDate(startDate.getDate() + i); // Go forward from today
            const dateStr = d.toISOString().split('T')[0];
            const isActive = dateStr === selectedDate ? " active" : "";

            const boxHtml = `
        <div class="date-box${isActive}" data-date="${dateStr}" onclick="selectDate('${dateStr}', '${containerId}')">
            <div class="date-weekday">${d.toLocaleDateString('en-US', { weekday: 'short' })}</div>
            <div class="date-number">${d.getDate()}</div>
        </div>
    `;

            if (isActive) {
                activeBox = boxHtml; // Save today
            } else {
                otherBoxes.push(boxHtml); // Save others
            }
        }
        html += `<div class="date-boxes">`;
        html += activeBox;
        html += otherBoxes.join('');
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

// Create appointment details popup for calendar events
const calendarDetailsPopup = document.createElement('div');
calendarDetailsPopup.className = 'appointment-details-popup';
document.body.appendChild(calendarDetailsPopup);

// Create appointment details popup for appointment cards
const cardDetailsPopup = document.createElement('div');
cardDetailsPopup.className = 'appointment-card-details-popup';
document.body.appendChild(cardDetailsPopup);
// Function to populate and show the details popup
// Replace the existing showDetailsPopup function (around lines 900-950)
function showDetailsPopup(appointment, element, event, popup) {
    if (element.classList.contains('ui-draggable-dragging')) return; // Skip if dragging

    // Add expanded class to highlight the appointment block
    element.classList.add('expanded');

    // Populate popup content with appointment details
    popup.innerHTML = `
        <div class="details-title">${appointment.CustomerName || 'N/A'}</div>
        <div class="details-item">
            <span class="details-label">Service Type:</span>
            <span class="details-value">${appointment.ServiceType || 'N/A'}</span>
        </div>
        <div class="details-item">
            <span class="details-label">Date:</span>
            <span class="details-value">${appointment.RequestDate || 'N/A'}</span>
        </div>
        <div class="details-item">
            <span class="details-label">Time Slot:</span>
            <span class="details-value">${formatTimeRange(appointment.TimeSlot) || 'N/A'}</span>
        </div>
        <div class="details-item">
            <span class="details-label">Duration:</span>
            <span class="details-value">${appointment.Duration || 'N/A'}</span>
        </div>
        <div class="details-item">
            <span class="details-label">Resource:</span>
            <span class="details-value">${appointment.ResourceName || 'Unassigned'}</span>
        </div>
        <div class="details-item">
            <span class="details-label">Status:</span>
            <span class="details-value">${appointment.AppoinmentStatus || 'N/A'}</span>
        </div>
        <div class="details-item">
            <span class="details-label">Address:</span>
            <span class="details-value">${appointment.Address1 || 'N/A'}</span>
        </div>
    `;

    // Position popup relative to the appointment block
    const rect = element.getBoundingClientRect();
    const popupWidth = popup.offsetWidth || 200; // Fallback width
    const popupHeight = popup.offsetHeight || 100; // Fallback height
    const viewportWidth = window.innerWidth;
    const viewportHeight = window.innerHeight;
    const isResourceView = currentView === 'resource' && element.classList.contains('calendar-event-resource');
    const allDaySection = document.querySelector('.all-day-section');
    const allDayHeight = allDaySection ? allDaySection.getBoundingClientRect().height : 0;

    // Default positioning
    let left, top;
    if (isResourceView) {
        // In resource view, position below to avoid overlap with horizontal expansion
        top = rect.bottom + 10;
        // Adjust if it overlaps "All Day" or overflows the bottom
        if (top < allDayHeight + 10) top = allDayHeight + 10;
        if (top + popupHeight > viewportHeight) top = rect.top - popupHeight - 10;
        left = rect.left;
        if (left + popupWidth > viewportWidth) left = viewportWidth - popupWidth - 10;
    } else {
        // In date views or for appointment-card, position to the right
        left = rect.right + 10;
        top = rect.top;
        // Adjust if it overlaps "All Day" or overflows
        if (top < allDayHeight + 10) top = allDayHeight + 10;
        if (left + popupWidth > viewportWidth) left = rect.left - popupWidth - 10;
        if (top + popupHeight > viewportHeight) top = viewportHeight - popupHeight - 10;
    }

    // Ensure it stays within the viewport
    left = Math.max(10, left); // Prevent going off left edge
    top = Math.max(10, top); // Prevent going off top edge

    popup.style.left = `${left}px`;
    popup.style.top = `${top}px`;

    // Show popup with animation
    popup.classList.add('show');
}
// Function to hide the details popup and remove expanded state
function hideDetailsPopup(popup) {
    popup.classList.remove('show');
    // Remove expanded class from all appointment elements
    document.querySelectorAll('.calendar-event.expanded, .appointment-card.expanded').forEach(el => {
        el.classList.remove('expanded');
    });
}

// Add hover functionality to appointment elements
function setupHoverEvents() {
    document.querySelectorAll('.calendar-event, .calendar-event-resource, .appointment-card').forEach(element => {
        // Remove existing event listeners to prevent duplicates
        element.removeEventListener('mouseenter', handleMouseEnter);
        element.removeEventListener('mouseleave', handleMouseLeave);

        // Define mouseenter handler
        function handleMouseEnter(e) {
            const appointmentId = this.dataset.id;
            const appointment = appointments.find(a => a.AppoinmentId === appointmentId.toString());
            if (appointment) {
                // Choose the appropriate popup based on element class
                const isCalendarEvent = this.classList.contains('calendar-event') || this.classList.contains('calendar-event-resource');
                const popup = isCalendarEvent ? calendarDetailsPopup : cardDetailsPopup;
                showDetailsPopup(appointment, this, e, popup);
            }
        }

        // Define mouseleave handler
        function handleMouseLeave() {
            const isCalendarEvent = this.classList.contains('calendar-event') || this.classList.contains('calendar-event-resource');
            const popup = isCalendarEvent ? calendarDetailsPopup : cardDetailsPopup;
            this.classList.remove('expanded');
            hideDetailsPopup(popup);
        }

        // Add new event listeners
        element.addEventListener('mouseenter', handleMouseEnter);
        element.addEventListener('mouseleave', handleMouseLeave);
    });
}

// Render Date View with duration-based independent positioning
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
            fromDate.setDate(currentDate.getDate() - 1);
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

    const slotDurationMinutes = 30; // Enforce 30-minute intervals

    getAppoinments(filter, fromStr, toStr, today, function (appointments) {
        var filteredAppointments = filter === '' ?
            appointments :
            appointments.filter(a => a.ServiceType === filter);

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
                startDate.setDate(startDate.getDate() - currentDate.getDay());
            } else if (view === 'threeDay') {
                startDate.setDate(startDate.getDate() - 1);
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
                dayDates.forEach(d => {
                    renderedAppointments[d] = new Set();
                });

                allTimeSlots.forEach((time, index) => {
                    html += `
                    <div class="calendar-grid" style="grid-template-columns: 60px repeat(${dayDates.length}, 1fr);">
                        <div class="h-60px border-bottom last-border-bottom-none p-1 fs-7 text-right pr-2 bg-gray-50 calendar-time-cell">
                            ${formatTimeRange(time.TimeBlockSchedule)}
                        </div>
                    `;
                    dayDates.forEach(dStr => {
                        // Group appointments by time slot for this day
                        const cellAppointments = filteredAppointments
                            .filter(a => a.RequestDate === dStr && a.TimeSlot)
                            .map(a => {
                                const timeSlot = allTimeSlots.find(slot =>
                                    slot.TimeBlockSchedule === a.TimeSlot ||
                                    slot.TimeBlock.toLowerCase() === a.TimeSlot.toLowerCase()
                                );
                                if (!timeSlot) {
                                    console.warn(`No matching time slot for appointment ${a.AppoinmentId}: TimeSlot=${a.TimeSlot}`);
                                    return null;
                                }
                                const startIndex = allTimeSlots.findIndex(slot => slot.TimeBlockSchedule === timeSlot.TimeBlockSchedule);
                                if (startIndex !== -1 && !renderedAppointments[dStr].has(a.AppoinmentId)) {
                                    const durationMinutes = parseDuration(a.Duration);
                                    const startTimeMinutes = parseTimeToMinutes(timeSlot.TimeBlockSchedule.split('-')[0]);
                                    const slotStartTimeMinutes = parseTimeToMinutes(time.TimeBlockSchedule.split('-')[0]);
                                    if (isNaN(startTimeMinutes) || isNaN(slotStartTimeMinutes) || isNaN(durationMinutes) || slotDurationMinutes === 0) {
                                        console.warn(`Invalid data for appointment ${a.AppoinmentId}:`, {
                                            startTimeMinutes,
                                            slotStartTimeMinutes,
                                            durationMinutes,
                                            slotDurationMinutes,
                                            timeSlot: a.TimeSlot
                                        });
                                        return null;
                                    }
                                    const offsetMinutes = startTimeMinutes - slotStartTimeMinutes;
                                    const offsetPx = (offsetMinutes / slotDurationMinutes) * 60;
                                    const heightPx = (durationMinutes / slotDurationMinutes) * 60;
                                    return { appointment: a, offsetPx, heightPx, startIndex };
                                }
                                return null;
                            })
                            .filter(a => a && a.startIndex === index);

                        // Sort appointments by start time to ensure consistent ordering
                        cellAppointments.sort((a, b) => {
                            const aStart = parseTimeToMinutes(a.appointment.TimeSlot.split('-')[0]);
                            const bStart = parseTimeToMinutes(b.appointment.TimeSlot.split('-')[0]);
                            return aStart - bStart;
                        });

                        // Assign horizontal positions starting at 72px, incrementing by 100px
                        const appointmentsWithPosition = cellAppointments.map((appt, idx) => {
                            const leftPx = 72 + idx * 100; // Start at 72px, then 172px, 272px, etc.
                            return {
                                ...appt,
                                leftPx
                            };
                        });

                        html += `
                        <div class="h-60px border-bottom last-border-bottom-none border-right last-border-right-none p-1 relative drop-target calendar-cell"
                             style="overflow: hidden;"
                             data-date="${dStr}" data-time="${time.TimeBlockSchedule}">
                            ${appointmentsWithPosition.map(({ appointment, heightPx, offsetPx, leftPx }) => {
                            renderedAppointments[dStr].add(appointment.AppoinmentId);
                            return `
                                <div class="calendar-event ${getEventTimeSlotClass(appointment)} cursor-move fs-7 truncate"
                                     style="position: absolute; height: ${heightPx}px; width: 150px;"
                                     data-id="${appointment.AppoinmentId}" draggable="true">
                                    <div class="font-weight-medium fs-7">${appointment.CustomerName}</div>
                                    <div class="fs-7 truncate">${appointment.ServiceType} (${appointment.Duration})</div>
                                    <div class="fs-7 truncate status status-${appointment.AppoinmentStatus.toLowerCase()}">${appointment.AppoinmentStatus}</div>
                                </div>
                                `;
                        }).join('')}
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
                const renderedAppointments = new Set();

                allTimeSlots.forEach((time, index) => {
                    html += `
                    <div class="calendar-grid" style="grid-template-columns: 70px 1fr;">
                        <div class="h-60px border-bottom last-border-bottom-none p-1 fs-7 text-right pr-2 bg-gray-50 calendar-time-cell">
                            ${formatTimeRange(time.TimeBlockSchedule)}
                        </div>
                    `;

                    const cellAppointments = filteredAppointments
                        .filter(a => a.RequestDate === dateStr && a.TimeSlot)
                        .map(a => {
                            const timeSlot = allTimeSlots.find(slot =>
                                slot.TimeBlockSchedule === a.TimeSlot ||
                                slot.TimeBlock.toLowerCase() === a.TimeSlot.toLowerCase()
                            );
                            if (!timeSlot) {
                                console.warn(`No matching time slot for appointment ${a.AppoinmentId}: TimeSlot=${a.TimeSlot}`);
                                return null;
                            }
                            const startIndex = allTimeSlots.findIndex(slot => slot.TimeBlockSchedule === timeSlot.TimeBlockSchedule);
                            if (startIndex === index && !renderedAppointments.has(a.AppoinmentId)) {
                                const durationMinutes = parseDuration(a.Duration);
                                const startTimeMinutes = parseTimeToMinutes(timeSlot.TimeBlockSchedule.split('-')[0]);
                                const slotStartTimeMinutes = parseTimeToMinutes(time.TimeBlockSchedule.split('-')[0]);
                                if (isNaN(startTimeMinutes) || isNaN(slotStartTimeMinutes) || isNaN(durationMinutes) || slotDurationMinutes === 0) {
                                    console.warn(`Invalid data for appointment ${a.AppoinmentId}:`, {
                                        startTimeMinutes,
                                        slotStartTimeMinutes,
                                        durationMinutes,
                                        slotDurationMinutes,
                                        timeSlot: a.TimeSlot
                                    });
                                    return null;
                                }
                                const offsetMinutes = startTimeMinutes - slotStartTimeMinutes;
                                const offsetPx = (offsetMinutes / slotDurationMinutes) * 60;
                                const heightPx = (durationMinutes / slotDurationMinutes) * 60;
                                return { appointment: a, offsetPx, heightPx };
                            }
                            return null;
                        })
                        .filter(a => a);

                    // Sort appointments by start time
                    cellAppointments.sort((a, b) => {
                        const aStart = parseTimeToMinutes(a.appointment.TimeSlot.split('-')[0]);
                        const bStart = parseTimeToMinutes(b.appointment.TimeSlot.split('-')[0]);
                        return aStart - bStart;
                    });

                    // Assign horizontal positions starting at 72px
                    const appointmentsWithPosition = cellAppointments.map((appt, idx) => {
                        const leftPx = 72 + idx * 100; // Start at 72px, then 172px, 272px, etc.
                        return {
                            ...appt,
                            leftPx
                        };
                    });

                    html += `
                        <div class="h-60px border-bottom last-border-bottom-none border-right last-border-right-none p-1 relative drop-target calendar-cell"
                             style="overflow: hidden;"
                             data-date="${dateStr}" data-time="${time.TimeBlockSchedule}">
                            ${appointmentsWithPosition.map(({ appointment, heightPx, offsetPx, leftPx }) => {
                        renderedAppointments.add(appointment.AppoinmentId);
                        return `
                                <div class="calendar-event ${getEventTimeSlotClass(appointment)} cursor-move fs-7 truncate"
                                     style="position: absolute; height: ${heightPx}px; width: 150px;"
                                     data-id="${appointment.AppoinmentId}" draggable="true">
                                    <div class="font-weight-medium fs-7">${appointment.CustomerName}</div>
                                    <div class="fs-7 truncate">${appointment.ServiceType} (${appointment.Duration})</div>
                                    <div class="fs-7 truncate status">${appointment.AppoinmentStatus}</div>
                                </div>
                                `;
                    }).join('')}
                        </div>
                        `;
                    html += `</div>`;
                });
            }

            html += `</div></div>`;
        }

        container.html(html);
        setupDragAndDrop();
        setupHoverEvents();
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
    direction: 'asc'
};

$(document).off('click', 'th.sortable').on('click', 'th.sortable', function () {
    const key = $(this).data('key');
    if (currentSort.key === key) {
        currentSort.direction = currentSort.direction === 'asc' ? 'desc' : 'asc';
    } else {
        currentSort.key = key;
        currentSort.direction = 'asc';
    }
    $('th.sortable').removeClass('sort-asc sort-desc');
    $(this).addClass(currentSort.direction === 'asc' ? 'sort-asc' : 'sort-desc');
    renderListView();
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
    const isResourceView = view === 'resource';
    const statusFilterId = isResourceView ? '#MainContent_StatusTypeFilter_Resource' : '#MainContent_StatusTypeFilter';
    const serviceFilterId = isResourceView ? '#MainContent_ServiceTypeFilter_Resource' : '#MainContent_ServiceTypeFilter_2';
    const searchFilterId = isResourceView ? '#searchFilterResource' : '#searchFilter';
    const listContainerId = isResourceView ? '#unscheduledListResource' : '#unscheduledList';

    const $listContainer = $(listContainerId);
    const statusFilter = $(statusFilterId).val() || '';
    const serviceFilter = $(serviceFilterId).val() || '';
    const searchFilter = $(searchFilterId).val().toLowerCase().trim() || '';

    const filteredAppointments = appointments.filter(app => {
        const isUnassigned = !app.ResourceID || app.ResourceID === '0' || app.ResourceID === 0 || app.ResourceID === '' ||
            app.ResourceName === null || app.ResourceName === 'Unassigned' || app.ResourceName === 'None' || app.ResourceName === '';
        const matchesStatus = statusFilter === '' || app.AppoinmentStatus === statusFilter;
        const matchesService = serviceFilter === '' || app.ServiceType === serviceFilter;
        const matchesSearch = !searchFilter ||
            (app.CustomerName && app.CustomerName.toLowerCase().includes(searchFilter)) ||
            (app.Address1 && app.Address1.toLowerCase().includes(searchFilter));
        return isUnassigned && matchesStatus && matchesService && matchesSearch;
    });

    console.log(`Rendering unscheduled list for view: ${view}`, {
        totalAppointments: appointments.length,
        filteredAppointments: filteredAppointments,
        filters: { statusFilter, serviceFilter, searchFilter }
    });

    $listContainer.empty().css('display', 'block');

    if (filteredAppointments.length === 0) {
        $listContainer.append('<div class="text-center py-4 text-muted">No unassigned appointments found. Ensure appointments have ResourceID as null, 0, or empty, or ResourceName as null, "Unassigned", "None", or empty.</div>');
        return;
    }

    filteredAppointments.forEach(app => {
        const serviceType = app.ServiceType || 'Unknown';
        const timeSlotDisplay = app.TimeSlot || 'Not specified';
        const address = app.Address1 || 'No address';
        const state = app.State || '';
        const zipCode = app.ZipCode || '';

        const appointmentHtml = `
            <div class="appointment-card card mb-3 shadow-sm unscheduled-item" data-id="${app.AppoinmentId}" draggable="true">
                <div class="card-body p-3">
                    <div class="d-flex justify-content-between align-items-start">
                        <h3 class="font-weight-medium fs-6 mb-0">${app.CustomerName || 'Unknown Customer'}</h3>
                        <span class="fs-7 badge bg-${app.AppoinmentStatus.toLowerCase() === 'pending' ? 'warning' : 'success'}">${app.AppoinmentStatus}</span>
                    </div>
                    <div class="fs-7 text-muted mt-1 line-clamp-2">${address}${state ? ', ' + state : ''}${zipCode ? ' ' + zipCode : ''}</div>
                    <div class="fs-7 text-muted mt-1 line-clamp-2">${app.RequestDate || 'No date'}</div>
                    <div class="fs-7 text-muted mt-1 line-clamp-2">${formatTimeRange(timeSlotDisplay)}</div>
                    <div class="d-flex justify-content-between align-items-center mt-2">
                        <span class="fs-7">${serviceType} </span>
                        <button class="btn btn-outline-secondary btn-sm" onclick="openEditModal(${app.AppoinmentId})">Schedule</button>
                    </div>
                </div>
            </div>
        `;
        $listContainer.append(appointmentHtml);
    });

    setupDragAndDrop();
}

// Setup drag-and-drop functionality
function setupDragAndDrop() {
    // Initialize draggable elements
    $(".calendar-event, .calendar-event-resource, .appointment-card").draggable({
        revert: "invalid",
        revertDuration: 200,
        zIndex: 1000,
        helper: "clone",
        opacity: 0.7,
        scroll: true,
        scrollSensitivity: 100,
        start: function (event, ui) {
            $(this).addClass("dragging");
            ui.helper.addClass("shadow-sm").css({
                width: $(this).width(),
                transition: "none",
                transform: "translateZ(0)"
            });
            // Hide details popup during drag
            hideDetailsPopup(calendarDetailsPopup);
            hideDetailsPopup(cardDetailsPopup);
        },
        stop: function () {
            $(this).removeClass("dragging");
        }
    });
    $(".drop-target").droppable({
        accept: ".appointment-card, .calendar-event, .calendar-event-resource",
        hoverClass: "drag-over",
        tolerance: "pointer",
        drop: function (event, ui) {
            const appointmentId = ui.draggable.data("id").toString();
            const date = $(this).data("date");
            const time = $(this).data("time");
            const resource = $(this).data("resource") || "Unassigned";

            const appointment = appointments.find(a => a.AppoinmentId === appointmentId);
            if (!appointment) {
                console.warn(`Appointment not found for ID: ${appointmentId}`);
                return;
            }

            // Check if appointment is closed
            if (appointment.AppoinmentStatus.toLowerCase() === "closed") {
                showAlert({
                    icon: 'info',
                    title: 'Cannot Reschedule',
                    text: 'This appointment is closed and cannot be rescheduled.',
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

            // Check for conflicts
            if (hasConflict(appointment, time, resource, date, appointmentId)) {
                showAlert({
                    icon: 'error',
                    title: 'Scheduling Conflict',
                    text: 'This time slot is already taken for the selected resource and date.',
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

            // Open edit modal with pre-filled values
            openEditModal(appointmentId, date, time, resource, true);
        }
    });
    $("#unscheduledList, #unscheduledListResource").droppable({
        accept: ".calendar-event, .calendar-event-resource, .appointment-card",
        hoverClass: "drag-over",
        tolerance: "pointer",
        drop: function (event, ui) {
            const appointmentId = ui.draggable.data("id").toString();
            const appointment = appointments.find(a => a.AppoinmentId === appointmentId);
            if (!appointment) {
                console.warn(`Appointment not found for ID: ${appointmentId}`);
                return;
            }

            // Mark as unassigned
            appointment.ResourceID = 0;
            appointment.ResourceName = 'Unassigned';
            appointment.RequestDate = null;
            appointment.TimeSlot = null;
            appointment.Duration = '1 Hr';

            // Save to server
            const serverAppointment = {
                AppoinmentId: parseInt(appointment.AppoinmentId),
                CustomerID: parseInt(appointment.CustomerID) || null,
                ServiceType: appointment.ServiceType,
                RequestDate: null,
                TimeSlot: null,
                ResourceID: 0,
                Status: appointment.AppoinmentStatus,
                TicketStatus: appointment.TicketStatus || null,
                Note: appointment.Note || '',
                StartDateTime: null,
                EndDateTime: null
            };

            $.ajax({
                type: "POST",
                url: "Appointments.aspx/UpdateAppointment",
                data: JSON.stringify({ appointment: serverAppointment }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d) {
                        showAlert({
                            icon: 'success',
                            title: 'Success',
                            text: 'Appointment unscheduled successfully!',
                            confirmButtonText: 'OK',
                            timer: 2000,
                            customClass: {
                                popup: 'swal-custom-popup',
                                title: 'swal-custom-title',
                                content: 'swal-custom-content',
                                confirmButton: 'swal-custom-button'
                            }
                        });
                        saveAppointments();
                        updateAllViews();
                    } else {
                        showAlert({
                            icon: 'error',
                            title: 'Error',
                            text: 'Failed to unschedule appointment.',
                            confirmButtonText: 'OK',
                            customClass: {
                                popup: 'swal-custom-popup',
                                title: 'swal-custom-title',
                                content: 'swal-custom-content',
                                confirmButton: 'swal-custom-button'
                            }
                        });
                    }
                },
                error: function (xhr, status, error) {
                    console.error("Error unscheduling appointment:", error);
                    showAlert({
                        icon: 'error',
                        title: 'Error',
                        text: 'Failed to unschedule appointment due to a server error.',
                        confirmButtonText: 'OK',
                        customClass: {
                            popup: 'swal-custom-popup',
                            title: 'swal-custom-title',
                            content: 'swal-custom-content',
                            confirmButton: 'swal-custom-button'
                        }
                    });
                }
            });
        }
    });

    // Rebind click handlers to prevent duplicate bindings
    $(document).off('click', '.calendar-event, .calendar-event-resource, .appointment-card')
        .on('click', '.calendar-event, .calendar-event-resource, .appointment-card', function (e) {
            if (!$(this).hasClass('ui-draggable-dragging')) {
                const appointmentId = $(this).data("id").toString();
                openEditModal(appointmentId);
            }
        });
}
// Create a new appointment
function createAppointment(e) {
    e.preventDefault();
    const form = new FormData(e.target);
    const newAppointment = {
        AppoinmentId: (Math.max(...appointments.map(a => parseInt(a.AppoinmentId)), 0) + 1).toString(),
        CustomerName: form.get("customerName"),
        ServiceType: form.get("serviceType"),
        RequestDate: form.get("date"),
        TimeSlot: form.get("timeSlot"),
        Duration: form.get("duration") || "1 Hr",
        ResourceName: form.get("resource"),
        AppoinmentStatus: form.get("status"),
        location: {
            Address1: form.get("address"),
            lat: 40.7128,
            lng: -74.0060
        },
        priority: "Medium"
    };

    if (newAppointment.RequestDate && newAppointment.TimeSlot && hasConflict(newAppointment, newAppointment.TimeSlot, newAppointment.ResourceName, newAppointment.RequestDate)) {
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
    
    // Create form instances for selected forms
    if (selectedForms.length > 0 && window.FormsManager) {
        window.FormsManager.createFormInstance(selectedForms[0].id, newAppointment.AppoinmentId, newAppointment.CustomerID || '')
            .then(() => {
                console.log('Form instances created for new appointment');
            })
            .catch(error => {
                console.error('Error creating form instances:', error);
            });
    }
    
    updateAllViews();
    window.newModalInstance.hide();
    
    // Clear selected forms
    selectedForms = [];
}

// Open modal to edit an appointment
function openEditModal(id, date, time, resource, confirm) {
    const a = appointments.find(x => x.AppoinmentId === id.toString());
    if (!a) return;
    
    // Load forms for this appointment when opening edit modal
    if (!confirm) {
        loadCurrentlySelectedForms(id);
    }

    // Check if appointment is closed
   if (a.AppoinmentStatus.toLowerCase() === "closed") {
        showAlert({
            icon: 'info',
            title: 'Cannot Edit',
            text: 'This appointment is closed and cannot be edited.',
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

    // Debug: Log the appointment object to verify Phone and Mobile properties
    console.log('Appointment data:', a);

    currentEditId = id;
    const form = document.getElementById("editForm");
    if (!form) {
        console.error('Edit form not found in DOM');
        return;
    }

    form.querySelector("[name='duration']").value = a.Duration || "1 Hr";
    form.querySelector("[id='AppoinmentId']").value = parseInt(a.AppoinmentId);
    form.querySelector("[id='CustomerID']").value = parseInt(a.CustomerID) || '';
    form.querySelector("[name='customerName']").value = a.CustomerName || '';
    // Populate Phone and Mobile fields with error handling
    const phoneInput = form.querySelector("[name='phone']");
    const mobileInput = form.querySelector("[name='mobile']");
    if (phoneInput) {
        phoneInput.value = a.Phone || '';
    } else {
        console.warn('Phone input field not found in editForm');
    }
    if (mobileInput) {
        mobileInput.value = a.Mobile || '';
    } else {
        console.warn('Mobile input field not found in editForm');
    }
    form.querySelector("[name='note']").value = a.Note || '';
    form.querySelector("[id='txt_StartDate']").value = a.StartDateTime || '';
    form.querySelector("[id='txt_EndDate']").value = a.EndDateTime || '';
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
        extractHoursAndMinutes(a.Duration);
        calculateStartEndTime();
    } else {
        form.querySelector("[name='timeSlot']").value = a.TimeSlot || '';
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
            calculateDate(date);
        }
    } else {
        form.querySelector("[name='date']").value = a.RequestDate || '';
    }

    form.querySelector("[name='address']").value = a.Address1 || '';
    const status_select = form.querySelector("[id='MainContent_StatusTypeFilter_Edit']");
    getSelectedId(status_select, a.AppoinmentStatus || "");
    const ticket_status = form.querySelector("[id='MainContent_TicketStatusFilter_Edit']");
    getSelectedId(ticket_status, a.TicketStatus || "");

    const isClosed = a.AppoinmentStatus.toLowerCase() === "closed";
    service_select.disabled = isClosed;
    status_select.disabled = isClosed;
    ticket_status.disabled = isClosed;

    try {
        window.editModalInstance.show();
    } catch (error) {
        console.error('Error opening editModal:', error);
        showAlert({
            icon: 'error',
            title: 'Modal Error',
            text: 'Failed to open the edit modal. Please check the console for details.',
            confirmButtonText: 'OK',
            customClass: {
                popup: 'swal-custom-popup',
                title: 'swal-custom-title',
                content: 'swal-custom-content',
                confirmButton: 'swal-custom-button'
            }
        });
    }
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

    saveAppoinmentData(e);
}

// Open modal to confirm scheduling
function openConfirmModal(id, date, timeSlot, resource) {
    const a = appointments.find(x => x.AppoinmentId === id.toString());
    if (!a) return;
    const form = document.getElementById("confirmForm");
    form.querySelector("[name='id']").value = a.AppoinmentId;
    form.querySelector("[name='customerName']").value = a.CustomerName;
    form.querySelector("[name='date']").value = date || '';
    form.querySelector("[name='timeSlot']").value = timeSlot || 'morning';
    form.querySelector("[name='duration']").value = a.Duration || "1 Hr";
    form.querySelector("[name='resource']").value = resource || 'Unassigned';
    window.confirmModalInstance.show();
}

// Confirm scheduling from drag-and-drop
function confirmScheduling(e) {
    e.preventDefault();
    const form = new FormData(e.target);
    const id = form.get("id");
    const appointment = appointments.find(a => a.AppoinmentId === id);
    if (!appointment) return;

    const newDate = form.get("date");
    const newTimeSlot = form.get("timeSlot");
    const newResource = form.get("resource");
    const newDuration = form.get("duration") || "1 Hr";

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

    appointment.RequestDate = newDate;
    appointment.TimeSlot = newTimeSlot;
    appointment.ResourceName = newResource;
    appointment.Duration = newDuration;
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
            appointments = appointments.filter(a => a.AppoinmentId !== currentEditId.toString());
            saveAppointments();
            updateAllViews();
            window.editModalInstance.hide();
        }
    });
}

// Unschedule an appointment
function unscheduleAppointment() {
    const appointment = appointments.find(a => a.AppoinmentId === currentEditId.toString());
    if (!appointment) return;
    appointment.RequestDate = null;
    appointment.TimeSlot = null;
    appointment.Duration = "1 Hr";
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

// Render Resource View with duration-based independent positioning
function renderResourceView(date) {
    const container = $("#resourceViewContainer").addClass('resource-view').removeClass('date-view');
    const selectedGroup = $("#dispatchGroup").val();
    const dateStr = new Date(date).toISOString().split('T')[0];

    renderDateNav("resourceNav", dateStr);

    const filteredResources = resources;
    const slotDurationMinutes = 30;
    const pixelsPerSlot = 100;
    const eventHeight = 100;

    const validTimeSlots = allTimeSlots.filter(slot =>
        slot && slot.TimeBlockSchedule && !allTimeSlots.some(other => other !== slot && other.TimeBlockSchedule === slot.TimeBlockSchedule)
    );
    console.log('Valid TimeSlots length:', validTimeSlots.length);

    getAppoinments("", "", "", dateStr, function (appointments) {
        let html = `
            <div class="border rounded overflow-hidden" style="margin: 0; padding: 0; width: fit-content; max-width: 100%;">
                <div class="calendar-grid calendar-header" id="resource-header" style="grid-template-columns: 120px repeat(${validTimeSlots.length}, ${pixelsPerSlot}px); margin: 0; padding: 0; width: fit-content; max-width: 100%; overflow-x: hidden;">
                    <div class="p-2 border-right bg-gray-50 calendar-header-cell"></div>
                    ${validTimeSlots.map(time => `
                        <div class="p-2 text-center font-weight-medium border-right last-border-right-none bg-gray-50 calendar-header-cell">
                            ${formatTimeRange(time.TimeBlockSchedule)}
                        </div>
                    `).join('')}
                </div>
                <div class="calendar-body" style="margin: 0; padding: 0; width: fit-content; max-width: 100%;">
        `;

        if (!validTimeSlots.length || !resources.length) {
            html += `
            <div class="text-center py-4 text-muted">
                No resources or time slots available.
            </div>
            `;
        } else {
            filteredResources.forEach((resource, index) => {
                const rowId = `resource-row-${index}`;
                html += `
                    <div class="calendar-grid resource-row" id="${rowId}" style="grid-template-columns: 120px repeat(${validTimeSlots.length}, ${pixelsPerSlot}px); margin: 0; padding: 0; width: fit-content; max-width: 100%; overflow-x: hidden;">
                        <div class="h-120px border-bottom last-border-bottom-none p-1 fs-7 text-center bg-gray-50 calendar-time-cell">
                            ${resource.ResourceName}
                        </div>
                `;

                const placedAppointments = [];

                validTimeSlots.forEach((time, timeIndex) => {
                    const cellAppointments = appointments
                        .filter(a => a.ResourceName === resource.ResourceName &&
                            a.RequestDate === dateStr &&
                            a.TimeSlot)
                        .map(a => {
                            const timeSlot = validTimeSlots.find(slot =>
                                slot.TimeBlockSchedule === a.TimeSlot ||
                                slot.TimeBlock.toLowerCase() === a.TimeSlot.toLowerCase()
                            );
                            if (!timeSlot) {
                                console.warn(`No matching time slot for appointment ${a.AppoinmentId}: TimeSlot=${a.TimeSlot}`);
                                return null;
                            }
                            const startIndex = validTimeSlots.findIndex(slot => slot.TimeBlockSchedule === timeSlot.TimeBlockSchedule);
                            if (startIndex === timeIndex) {
                                const durationMinutes = parseDuration(a.Duration);
                                const startTimeMinutes = parseTimeToMinutes(timeSlot.TimeBlockSchedule.split('-')[0]);
                                const slotStartTimeMinutes = parseTimeToMinutes(time.TimeBlockSchedule.split('-')[0]);
                                if (isNaN(startTimeMinutes) || isNaN(slotStartTimeMinutes) || isNaN(durationMinutes) || slotDurationMinutes === 0) {
                                    console.warn(`Invalid data for appointment ${a.AppoinmentId}:`, {
                                        startTimeMinutes,
                                        slotStartTimeMinutes,
                                        durationMinutes,
                                        slotDurationMinutes,
                                        timeSlot: a.TimeSlot
                                    });
                                    return null;
                                }
                                const offsetMinutes = startTimeMinutes - slotStartTimeMinutes;
                                const offsetPx = (offsetMinutes / slotDurationMinutes) * pixelsPerSlot;
                                const widthPx = (durationMinutes / slotDurationMinutes) * pixelsPerSlot;

                                const overlappingAppointments = placedAppointments.filter(pa => pa.offsetPx === offsetPx);
                                const conflictIndex = overlappingAppointments.length;
                                const adjustedOffsetPx = offsetPx + (conflictIndex * 10);

                                placedAppointments.push({ appointment: a, offsetPx });

                                return { appointment: a, offsetPx: adjustedOffsetPx, widthPx };
                            }
                            return null;
                        })
                        .filter(a => a);

                    html += `
                    <div class="h-120px border-bottom last-border-bottom-none border-right last-border-right-none p-1 relative drop-target calendar-cell"
                         data-date="${dateStr}" 
                         data-time="${time.TimeBlockSchedule}" 
                         data-resource="${resource.ResourceName}"
                         style="position: relative; margin: 0; padding: 0; max-width: ${pixelsPerSlot}px;">
                        ${cellAppointments.map(({ appointment, offsetPx, widthPx }) => `
                            <div class="calendar-event-resource ${getEventTimeSlotClass(appointment)} cursor-move"
                                 style="position: absolute; left: ${offsetPx}px; width: ${Math.min(widthPx, pixelsPerSlot)}px; height: ${eventHeight}px;"
                                 data-id="${appointment.AppoinmentId}" 
                                 data-duration-width="${widthPx}"
                                 draggable="true"
                                 onmouseenter="this.style.width='${widthPx * 1.5}px'; this.style.zIndex='10';"
                                 onmouseleave="this.style.width='${Math.min(widthPx, pixelsPerSlot)}px'; this.style.zIndex='1';">
                                <div class="font-weight-medium fs-7">${appointment.CustomerName}</div>
                                <div class="fs-7 truncate">${appointment.ServiceType} (${appointment.Duration})</div>
                                <div class="fs-7 truncate status">${appointment.AppoinmentStatus}</div>
                            </div>
                        `).join('')}
                    </div>
                    `;
                });

                html += `</div>`;
            });
        }

        html += `</div></div>`;
        container.html(html);
        setupDragAndDrop();
        renderUnscheduledList('resource');

        // Enable drag-to-scroll for each resource row and the header
        const header = document.querySelector('#resource-header');
        const rows = document.querySelectorAll('.resource-row');
        if (header && rows.length > 0) {
            // Initialize drag-to-scroll for header
            enableDragToScroll('#resource-header');
            // Initialize drag-to-scroll for rows and sync with header
            filteredResources.forEach((_, index) => {
                const rowSelector = `#resource-row-${index}`;
                enableDragToScroll(rowSelector);
                // Sync scrolling
                const row = document.querySelector(rowSelector);
                row.addEventListener('scroll', () => {
                    header.scrollLeft = row.scrollLeft;
                    rows.forEach(otherRow => {
                        if (otherRow !== row) {
                            otherRow.scrollLeft = row.scrollLeft;
                        }
                    });
                });
                header.addEventListener('scroll', () => {
                    rows.forEach(r => {
                        r.scrollLeft = header.scrollLeft;
                    });
                });
            });
        }
    });
}
function enableDragToScroll(containerSelector) {
    const container = document.querySelector(containerSelector);
    if (!container) {
        console.warn(`Container ${containerSelector} not found for drag-to-scroll`);
        return;
    }

    let isDragging = false;
    let startX;
    let scrollLeft;

    const throttle = (func, limit) => {
        let inThrottle;
        return function (...args) {
            if (!inThrottle) {
                func.apply(this, args);
                inThrottle = true;
                setTimeout(() => (inThrottle = false), limit);
            }
        };
    };

    const startDragging = (e) => {
        if (e.target.closest('.calendar-event, .calendar-event-resource, .appointment-card')) {
            return;
        }

        isDragging = true;
        container.style.cursor = 'grabbing';
        startX = (e.pageX || (e.touches && e.touches[0].pageX)) - container.offsetLeft;
        scrollLeft = container.scrollLeft;
        container.classList.add('dragging');
    };

    const stopDragging = () => {
        isDragging = false;
        container.style.cursor = 'grab';
        container.classList.remove('dragging');
    };

    const drag = throttle((e) => {
        if (!isDragging) return;
        e.preventDefault();
        const x = (e.pageX || (e.touches && e.touches[0].pageX)) - container.offsetLeft;
        const walk = (x - startX) * 2;
        container.scrollLeft = scrollLeft - walk;
    }, 16); // ~60fps

    container.addEventListener('mousedown', startDragging);
    container.addEventListener('mousemove', drag);
    container.addEventListener('mouseup', stopDragging);
    container.addEventListener('mouseleave', stopDragging);

    container.addEventListener('touchstart', startDragging, { passive: false });
    container.addEventListener('touchmove', drag, { passive: false });
    container.addEventListener('touchend', stopDragging);
    container.addEventListener('touchcancel', stopDragging);

    container.style.cursor = 'grab';
}
var today = new Date().toISOString().split('T')[0];

// Initialize the page
document.addEventListener('DOMContentLoaded', () => {
    const newModalInstance = new bootstrap.Modal(document.getElementById("newModal"));
    const editModalInstance = new bootstrap.Modal(document.getElementById("editModal"));
    const confirmModalInstance = new bootstrap.Modal(document.getElementById("confirmModal"));

    window.newModalInstance = newModalInstance;
    window.editModalInstance = editModalInstance;
    window.confirmModalInstance = confirmModalInstance;

    $("#dayCalendar").html('<div class="text-center py-4">Loading...</div>');

    const isMobile = () => window.matchMedia('(max-width: 849px)').matches;

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
            console.error('Required elements not found for view:', view);
            return;
        }

        const isExpanded = calendarContainer.classList.toggle('expanded');
        unscheduledPanel.classList.toggle('collapsed', isExpanded);
        toggleUnscheduledBtn.style.display = isExpanded ? 'block' : 'none';
        expandCalendarBtn.innerHTML = isExpanded ? '<i class="fas fa-compress"></i>' : '<i class="fas fa-expand"></i>';

        localStorage.setItem(`${view}CalendarExpanded`, isExpanded);
        window.isCalendarExpanded = isExpanded;

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
            window.dispatchEvent(new Event('resize'));
        }, 0);
    }

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

    document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(el => {
        new bootstrap.Tooltip(el, {
            trigger: 'hover'
        });
    });

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

    Promise.all([getTimeSlots(), getResources()])
        .then(() => {
            console.log('TimeSlots:', allTimeSlots);
            console.log('Resources:', resources);
            document.getElementById('dateInput').min = today;
            $("#dayDatePicker").val(today);
            $("#resourceDatePicker").val(today);
            $("#listDatePicker").val(today);
            $("#mapDatePicker").val(today);
            renderDateView(today);

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
        })
        .catch((error) => {
            console.error("Failed to load initial data:", error);
            $("#dayCalendar").html('<div class="text-center py-4 text-muted">Failed to load data. Please try refreshing the page.</div>');
        });

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
        console.log('TimeSlots fetched:', response.d);
        allTimeSlots = response.d;
        renderTimeSlots(response.d);
        populateTimeSlotDropdown(response.d);
    }).catch(function (xhr, status, error) {
        console.error("Error fetching time slots: ", error);
        throw error;
    });
}

function renderTimeSlots(timeSlots) {
    const container = $(".time-slot-indicators");
    container.empty();
    timeSlots.forEach(slot => {
        const fullLabel = slot.TimeBlock;
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
        console.log('Resources fetched:', response.d);
        resources = response.d;
        populateResourceDropdown(response.d);
    }).catch(function (xhr, status, error) {
        console.error("Error fetching resources: ", error);
        throw error;
    });
}

function formatTimeRange(str) {
    if (!str) return 'N/A';
    return str.replace(/[()]/g, '')
        .trim()
        .replace(/\s{2,}/g, ' ')
        .trim();
}

function populateResourceDropdown(resources) {
    const $dropdown = $("#resource_list");
    $dropdown.empty();
    $dropdown.append(`<option value="0">Unassigned</option>`);
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
    if (!matched && select.options.length > 0) {
        select.selectedIndex = 0;
    }
}

function populateTimeSlotDropdown(slots) {
    const $dropdown = $("#time_slot");
    $dropdown.empty();
    $dropdown.append(`<option value="0">Select</option>`);
    slots.forEach(slot => {
        $dropdown.append(`<option value="${slot.TimeBlock}">${slot.TimeBlockSchedule}</option>`);
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
    appointment.StartDateTime = form.get("txt_StartDate");
    appointment.EndDateTime = form.get("txt_EndDate");

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
                        content: 'swal-custom--content',
                        confirmButton: 'swal-custom-button'
                    }
                });
            }
            updateAllViews();
            window.editModalInstance.hide();
        },
        error: function (xhr, status, error) {
            console.error("Error updating appointment: ", error);
            showAlert({
                icon: 'error',
                title: 'Error',
                text: 'Failed to update appointment due to a server error.',
                confirmButtonText: 'OK',
                customClass: {
                    popup: 'swal-custom-popup',
                    title: 'swal-custom-title',
                    content: 'swal-custom-content',
                    confirmButton: 'swal-custom-button'
                }
            });
        }
    });
}

function extractHoursAndMinutes(duration) {
    if (!duration) {
        timerequired_Hour = 0;
        timerequired_Minute = 0;
        return;
    }
    const hourMatch = duration.match(/(\d+)\s*Hr/i);
    const minuteMatch = duration.match(/(\d+)\s*Min/i);
    timerequired_Hour = hourMatch ? parseInt(hourMatch[1], 10) : 0;
    timerequired_Minute = minuteMatch ? parseInt(minuteMatch[1], 10) : 0;
}

function calculateStartEndTime() {
    const form = document.getElementById("editForm");
    const timeSlot = form.querySelector("[name='timeSlot']").value;
    if (!timeSlot) return;

    const startTimeStr = timeSlot.split('-')[0].trim();
    const startDateTime = new Date(`${form.querySelector("[name='date']").value} ${startTimeStr}`);
    if (isNaN(startDateTime)) {
        console.warn(`Invalid start time: ${startTimeStr}`);
        return;
    }

    const durationMinutes = (timerequired_Hour * 60) + timerequired_Minute;
    const endDateTime = new Date(startDateTime.getTime() + durationMinutes * 60000);

    const formatTime = (date) => {
        let hours = date.getHours();
        const minutes = date.getMinutes().toString().padStart(2, '0');
        const ampm = hours >= 12 ? 'PM' : 'AM';
        hours = hours % 12 || 12;
        return `${hours}:${minutes} ${ampm}`;
    };

    form.querySelector("[id='txt_StartDate']").value = `${startDateTime.toISOString().split('T')[0]} ${formatTime(startDateTime)}`;
    form.querySelector("[id='txt_EndDate']").value = `${endDateTime.toISOString().split('T')[0]} ${formatTime(endDateTime)}`;
}

function calculateDate(dateStr) {
    const form = document.getElementById("editForm");
    const date = new Date(dateStr);
    if (isNaN(date)) {
        console.warn(`Invalid date: ${dateStr}`);
        return;
    }
    form.querySelector("[name='date']").value = date.toISOString().split('T')[0];
    calculateStartEndTime();
}

// =============================================================================
// FORMS INTEGRATION FUNCTIONS
// =============================================================================

let currentFormsModal = null;
let selectedForms = [];
let currentAppointmentForms = [];
let currentFormInstance = null;

// Initialize forms integration
function initializeFormsIntegration() {
    // Auto-assign forms when service type changes
    $('select[name="serviceTypeNew"], select[name="serviceTypeEdit"]').on('change', function() {
        const serviceType = $(this).val();
        const isNewForm = $(this).attr('name') === 'serviceTypeNew';
        
        if (serviceType) {
            loadAutoAssignedForms(serviceType, isNewForm);
        }
    });
}

// Open forms selection modal
function openFormsSelectionModal(mode) {
    currentFormsModal = mode;
    selectedForms = [];
    
    $('#formsSelectionModal').modal('show');
    loadAvailableForms();
    
    // Load currently selected forms if editing
    if (mode === 'edit') {
        loadCurrentlySelectedForms();
    }
}

// Load available forms
function loadAvailableForms() {
    $.ajax({
        type: "POST",
        url: "Forms.aspx/GetAllTemplates",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function(response) {
            if (response.d) {
                populateAvailableFormsList(response.d);
            }
        },
        error: function(xhr, status, error) {
            console.error('Error loading available forms:', error);
        }
    });
}

// Populate available forms list
function populateAvailableFormsList(forms) {
    const container = $('#availableFormsList');
    container.empty();
    
    forms.filter(form => form.IsActive).forEach(form => {
        const formItem = $(`
            <div class="form-check mb-2">
                <input class="form-check-input" type="checkbox" id="form_${form.Id}" 
                       value="${form.Id}" onchange="toggleFormSelection(${form.Id}, '${form.TemplateName}', this.checked)">
                <label class="form-check-label" for="form_${form.Id}">
                    <strong>${form.TemplateName}</strong>
                    ${form.Description ? '<br><small class="text-muted">' + form.Description + '</small>' : ''}
                    ${form.RequireSignature ? '<br><small class="text-info"><i class="fa fa-pencil"></i> Signature Required</small>' : ''}
                </label>
            </div>
        `);
        container.append(formItem);
    });
}

// Toggle form selection
function toggleFormSelection(formId, formName, isSelected) {
    if (isSelected) {
        selectedForms.push({ id: formId, name: formName });
    } else {
        selectedForms = selectedForms.filter(form => form.id !== formId);
    }
    
    updateSelectedFormsList();
}

// Update selected forms list
function updateSelectedFormsList() {
    const container = $('#selectedFormsList');
    container.empty();
    
    if (selectedForms.length === 0) {
        container.append('<p class="text-muted">No forms selected</p>');
        return;
    }
    
    selectedForms.forEach(form => {
        const formItem = $(`
            <div class="selected-form-item p-2 mb-2 border rounded">
                <div class="d-flex justify-content-between align-items-center">
                    <span>${form.name}</span>
                    <button type="button" class="btn btn-sm btn-outline-danger" 
                            onclick="removeSelectedForm(${form.id})">
                        <i class="fa fa-times"></i>
                    </button>
                </div>
            </div>
        `);
        container.append(formItem);
    });
}

// Remove selected form
function removeSelectedForm(formId) {
    selectedForms = selectedForms.filter(form => form.id !== formId);
    $(`#form_${formId}`).prop('checked', false);
    updateSelectedFormsList();
}

// Load auto-assigned forms
function loadAutoAssignedForms(serviceType, isNewForm) {
    $.ajax({
        type: "POST",
        url: "Forms.aspx/GetAutoAssignedForms",
        data: JSON.stringify({ serviceType: serviceType }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function(response) {
            const containerId = isNewForm ? 'selectedFormsNew' : 'selectedFormsEdit';
            const container = $(`#${containerId}`);
            
            if (response.d && response.d.length > 0) {
                container.empty();
                response.d.forEach(form => {
                    const formBadge = $(`
                        <span class="badge badge-primary me-2 mb-2" data-form-id="${form.Id}">
                            ${form.TemplateName}
                            ${form.RequireSignature ? ' <i class="fa fa-pencil"></i>' : ''}
                        </span>
                    `);
                    container.append(formBadge);
                });
                
                // Auto-select these forms in selectedForms array
                selectedForms = response.d.map(form => ({ id: form.Id, name: form.TemplateName }));
            } else {
                container.html('<small class="text-muted">No auto-assigned forms for this service type</small>');
            }
        },
        error: function(xhr, status, error) {
            console.error('Error loading auto-assigned forms:', error);
        }
    });
}

// Apply forms selection
function applyFormsSelection() {
    const containerId = currentFormsModal === 'new' ? 'selectedFormsNew' : 'selectedFormsEdit';
    const container = $(`#${containerId}`);
    
    container.empty();
    
    if (selectedForms.length === 0) {
        container.html('<small class="text-muted">No forms selected</small>');
    } else {
        selectedForms.forEach(form => {
            const formBadge = $(`
                <span class="badge badge-success me-2 mb-2" data-form-id="${form.id}">
                    ${form.name}
                    <button type="button" class="btn btn-sm btn-link text-white p-0 ms-1" 
                            onclick="removeFormFromAppointment(${form.id})">
                        <i class="fa fa-times"></i>
                    </button>
                </span>
            `);
            container.append(formBadge);
        });
    }
    
    $('#formsSelectionModal').modal('hide');
}

// Remove form from appointment
function removeFormFromAppointment(formId) {
    selectedForms = selectedForms.filter(form => form.id !== formId);
    $(`.badge[data-form-id="${formId}"]`).remove();
    
    // Update the container if no forms left
    const container = currentFormsModal === 'new' ? $('#selectedFormsNew') : $('#selectedFormsEdit');
    if (selectedForms.length === 0) {
        container.html('<small class="text-muted">No forms selected</small>');
    }
}

// Open appointment forms modal
function openAppointmentFormsModal() {
    const appointmentId = $('#AppoinmentId').val();
    if (!appointmentId) {
        showAlert({
            icon: 'warning',
            title: 'No Appointment Selected',
            text: 'Please select an appointment first.',
            confirmButtonText: 'OK'
        });
        return;
    }
    
    $('#appointmentFormsModal').modal('show');
    loadAppointmentForms(appointmentId);
}

// Load appointment forms
function loadAppointmentForms(appointmentId) {
    $.ajax({
        type: "POST",
        url: "Forms.aspx/GetAppointmentForms",
        data: JSON.stringify({ appointmentId: appointmentId }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function(response) {
            if (response.d) {
                currentAppointmentForms = response.d;
                populateAppointmentFormsList(response.d);
            }
        },
        error: function(xhr, status, error) {
            showAlert({
                icon: 'error',
                title: 'Error',
                text: 'Failed to load appointment forms',
                confirmButtonText: 'OK'
            });
        }
    });
}

// Populate appointment forms list
function populateAppointmentFormsList(forms) {
    const container = $('#appointmentFormsList');
    container.empty();
    
    if (!forms || forms.length === 0) {
        container.append('<p class="text-muted">No forms attached to this appointment</p>');
        return;
    }
    
    forms.forEach(form => {
        const statusClass = getFormStatusClass(form.Status);
        const formItem = $(`
            <div class="form-item p-3 mb-2 border rounded cursor-pointer" 
                 onclick="openFormForFilling(${form.Id})">
                <div class="d-flex justify-content-between align-items-start">
                    <div>
                        <strong>${form.TemplateName}</strong>
                        <br><small class="text-muted">Status: <span class="${statusClass}">${form.Status}</span></small>
                        ${form.CompletedDateTime ? '<br><small class="text-muted">Completed: ' + formatDateTime(form.CompletedDateTime) + '</small>' : ''}
                    </div>
                    <div class="form-actions">
                        ${form.RequireSignature ? '<i class="fa fa-pencil text-info" title="Signature Required"></i>' : ''}
                        ${form.RequireTip ? '<i class="fa fa-dollar text-success ms-1" title="Tip Enabled"></i>' : ''}
                    </div>
                </div>
            </div>
        `);
        container.append(formItem);
    });
}

// Get form status CSS class
function getFormStatusClass(status) {
    switch (status?.toLowerCase()) {
        case 'completed': return 'text-success';
        case 'inprogress': return 'text-info';
        case 'submitted': return 'text-primary';
        default: return 'text-warning';
    }
}

// Load currently selected forms for edit mode
function loadCurrentlySelectedForms(appointmentId) {
    if (!appointmentId) {
        appointmentId = $('#AppoinmentId').val();
    }
    
    if (!appointmentId) return;
    
    $.ajax({
        type: "POST",
        url: "Forms.aspx/GetAppointmentForms",
        data: JSON.stringify({ appointmentId: appointmentId }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function(response) {
            if (response.d) {
                const container = $('#selectedFormsEdit');
                container.empty();
                
                if (response.d.length === 0) {
                    container.html('<small class="text-muted">No forms attached to this appointment</small>');
                } else {
                    response.d.forEach(form => {
                        const statusClass = getFormStatusClass(form.Status);
                        const formBadge = $(`
                            <div class="form-badge p-2 mb-2 border rounded d-flex justify-content-between align-items-center">
                                <div>
                                    <strong>${form.TemplateName}</strong>
                                    <br><small class="${statusClass}">Status: ${form.Status}</small>
                                </div>
                                <div>
                                    ${form.RequireSignature ? '<i class="fa fa-pencil text-info" title="Signature Required"></i>' : ''}
                                    ${form.RequireTip ? '<i class="fa fa-dollar text-success ms-1" title="Tip Enabled"></i>' : ''}
                                </div>
                            </div>
                        `);
                        container.append(formBadge);
                    });
                }
            }
        },
        error: function(xhr, status, error) {
            console.error('Error loading current forms:', error);
        }
    });
}

// Initialize forms integration when page loads
$(document).ready(function() {
    initializeFormsIntegration();
});