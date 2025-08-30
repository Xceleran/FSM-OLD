// Global variables
let appointments = [];
let currentView = "date";
let currentDate = new Date();
let currentEditId = null;
let mapViewInstance = null;
let routeLayer = null;
let customMarkers = [];
let isMapView = true;
let customSortDirection = 'asc';

let isDateSyncing = false;
let unscheduledSortOrder = 'asc';

let listViewCurrentPage = 1;
let listViewPageSize = 5;
let listViewTotalPages = 1;
let listViewFilteredAppointments = [];


let resourceViewCurrentPage = 1;
let resourceViewPageSize = 5;
let resourceViewTotalPages = 1;
let resourceViewFilteredAppointments = [];
var GlobalTemplateId = 0;
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
let customDateRange = { from: null, to: null };
let resourceCustomDateRange = { from: null, to: null };

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


function parseTimeToMinutes(timeStr) {
    if (!timeStr || typeof timeStr !== 'string') return 0;

    // Handle named slots like "Morning"
    const lowerTimeStr = timeStr.toLowerCase();
    if (timeSlots[lowerTimeStr]) {
        timeStr = timeSlots[lowerTimeStr].start;
    } else {
        // Handle full schedule strings like "09:00 AM - 10:00 AM"
        const matchingSlot = allTimeSlots.find(slot =>
            slot.TimeBlock.toLowerCase() === lowerTimeStr ||
            slot.TimeBlockSchedule.toLowerCase() === lowerTimeStr
        );
        if (matchingSlot) {
            timeStr = matchingSlot.TimeBlockSchedule.split('-')[0].trim();
        }
    }

    // Standardize the time string for parsing
    let time = timeStr.toUpperCase();
    let hours = 0;
    let minutes = 0;

    // Use a regular expression to extract hours and minutes
    const match = time.match(/(\d{1,2}):(\d{2})/);
    if (match) {
        hours = parseInt(match[1], 10);
        minutes = parseInt(match[2], 10);
    } else {
        // Fallback for times without minutes like "9 AM"
        const singleHourMatch = time.match(/(\d{1,2})/);
        if (singleHourMatch) {
            hours = parseInt(singleHourMatch[1], 10);
        }
    }

    // Adjust for PM
    if (time.includes('PM') && hours < 12) {
        hours += 12;
    }
    // Adjust for 12 AM (midnight)
    if (time.includes('AM') && hours === 12) {
        hours = 0;
    }

    if (isNaN(hours) || isNaN(minutes)) {
        console.warn(`Could not parse time: ${timeStr}`);
        return 0;
    }

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

// Function to get CSS class for time slot based on service type
function getEventTimeSlotClass(appointment) {
    return 'service-type-custom'; // Generic class for all service types
}
// Utility: decide text color based on background brightness
function getContrastColor(hex) {
    if (!hex) return "#000"; // default black if no color

    hex = hex.replace("#", "");

    // Handle shorthand hex (#fff → #ffffff)
    if (hex.length === 3) {
        hex = hex.split("").map(c => c + c).join("");
    }

    let r = parseInt(hex.substr(0, 2), 16);
    let g = parseInt(hex.substr(2, 2), 16);
    let b = parseInt(hex.substr(4, 2), 16);

    // luminance formula
    let luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;

    return luminance > 0.5 ? "#000000" : "#FFFFFF";
}

// Function to update calendar event colors based on service type
function updateCalendarEventColors() {
    document.querySelectorAll('.calendar-event, .calendar-event-resource').forEach(element => {
        const appointmentId = element.dataset.id;
        const appointment = appointments.find(a => a.AppoinmentId === appointmentId);

        if (appointment && appointment.ServiceColor) {
            let bgColor = appointment.ServiceColor;
            let textColor = getContrastColor(bgColor);

            element.style.backgroundColor = bgColor;
            element.style.color = textColor;
        }
    });
}

// Function to load service type indicators
function loadServiceTypeIndicators() {
    $.ajax({
        type: "POST",
        url: "Appointments.aspx/GetServiceTypesWithColors",
        data: "{}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            const serviceTypes = response.d;
            const container = $(".appt-type-indicators");
            container.empty();

            serviceTypes.forEach(service => {
                const indicatorHtml = `
                    <span class="appt-type-indicator" style="background-color: ${service.CalendarColor}"></span>
                    ${service.ServiceName}
                `;
                container.append(indicatorHtml);
            });
        },
        error: function (xhr, status, error) {
            console.error("Error loading service types:", error);
        }
    });
}

// Initialize the Map View
function initMapView(date) {
    const container = document.getElementById('mapViewContainer');


    if (mapViewInstance) {
        mapViewInstance.remove();
    }

    // Ensure container has proper dimensions
    container.style.height = '400px';
    container.style.width = '100%';

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

function renderDateNav(containerId, selectedDate) {
    const container = $(`#${containerId}`);
    const isDateView = containerId === "dateNav";
    const view = isDateView ? $("#viewSelect").val() : $("#resourceViewSelect").val();

    const parts = selectedDate.split('-').map(part => parseInt(part, 10));

    const mainSelectedDate = new Date(parts[0], parts[1] - 1, parts[2]);


    if (isNaN(mainSelectedDate.getTime())) {
        console.error("Invalid date provided to renderDateNav:", selectedDate);
        return;
    }
    const mainSelectedDateStr = selectedDate;

    let html = `
        <button class="btn btn-primary" onclick="prevPeriod('${containerId}')"><i class="fas fa-chevron-left"></i></button>
    `;

    if (view !== 'month') {
        let daysToShow;

        const startDate = new Date(mainSelectedDate);

        if (view === 'custom' && !isDateView && resourceCustomDateRange.from && resourceCustomDateRange.to) {
            const fromParts = resourceCustomDateRange.from.split('-').map(p => parseInt(p, 10));
            const toParts = resourceCustomDateRange.to.split('-').map(p => parseInt(p, 10));
            const fromDate = new Date(fromParts[0], fromParts[1] - 1, fromParts[2]);
            const toDate = new Date(toParts[0], toParts[1] - 1, toParts[2]);
            daysToShow = Math.ceil((toDate - fromDate) / (1000 * 60 * 60 * 24)) + 1;

            startDate.setTime(fromDate.getTime());
        } else {
            daysToShow = view === 'week' ? 7 : view === 'threeDay' ? 3 : 1;
        }


        html += `<div class="date-boxes">`;
        for (let i = 0; i < daysToShow; i++) {
            const currentDateInLoop = new Date(startDate);
            currentDateInLoop.setDate(startDate.getDate() + i);


            const year = currentDateInLoop.getFullYear();
            const month = String(currentDateInLoop.getMonth() + 1).padStart(2, '0');
            const day = String(currentDateInLoop.getDate()).padStart(2, '0');
            const currentDateStr = `${year}-${month}-${day}`;


            const isActive = currentDateStr === mainSelectedDateStr;

            html += `
                <div class="date-box${isActive ? ' active' : ''}" 
                     data-date="${currentDateStr}" 
                     onclick="selectDate('${currentDateStr}', '${containerId}')">
                    <div class="date-weekday">${currentDateInLoop.toLocaleDateString('en-US', { weekday: 'short' })}</div>
                    <div class="date-number">${currentDateInLoop.getDate()}</div>
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

    const pickerId = isDateView ? "#dayDatePicker" : "#resourceDatePicker";
    $(pickerId).val(mainSelectedDateStr);
}



function prevPeriod(containerId) {
    const isDateView = containerId === "dateNav";
    const view = isDateView ? $("#viewSelect").val() : $("#resourceViewSelect").val();
    const pickerId = isDateView ? "#dayDatePicker" : "#resourceDatePicker";
    const currentDate = new Date($(pickerId).val());

    if (view === 'month') {
        currentDate.setMonth(currentDate.getMonth() - 1);
    } else {
        const daysToMove = view === 'week' ? 7 : view === 'threeDay' ? 3 : 1;
        currentDate.setDate(currentDate.getDate() - daysToMove);
    }
    syncDatePickers(pickerId, currentDate.toISOString().split('T')[0]);
}

function nextPeriod(containerId) {
    const isDateView = containerId === "dateNav";
    const view = isDateView ? $("#viewSelect").val() : $("#resourceViewSelect").val();
    const pickerId = isDateView ? "#dayDatePicker" : "#resourceDatePicker";
    const currentDate = new Date($(pickerId).val());

    if (view === 'month') {
        currentDate.setMonth(currentDate.getMonth() + 1);
    } else {
        const daysToMove = view === 'week' ? 7 : view === 'threeDay' ? 3 : 1;
        currentDate.setDate(currentDate.getDate() + daysToMove);
    }
    syncDatePickers(pickerId, currentDate.toISOString().split('T')[0]);
}

function selectDate(dateStr, containerId) {
    const isDateView = containerId === "dateNav";
    const pickerId = isDateView ? "#dayDatePicker" : "#resourceDatePicker";
    syncDatePickers(pickerId, dateStr);
}

function gotoToday(containerId) {
    const isDateView = containerId === "dateNav";
    const pickerId = isDateView ? "#dayDatePicker" : "#resourceDatePicker";
    const todayStr = new Date().toISOString().split('T')[0];
    syncDatePickers(pickerId, todayStr);
}


// Create appointment details popup for calendar events
const calendarDetailsPopup = document.createElement('div');
calendarDetailsPopup.className = 'appointment-details-popup';
document.body.appendChild(calendarDetailsPopup);

// Create appointment details popup for appointment cards
const cardDetailsPopup = document.createElement('div');
cardDetailsPopup.className = 'appointment-card-details-popup';
document.body.appendChild(cardDetailsPopup);

function showDetailsPopup(appointment, element, event, popup) {
    if (element.classList.contains('ui-draggable-dragging')) return;


    if (!element.classList.contains('calendar-event-resource')) {
        element.classList.add('expanded');
    }

    popup.innerHTML = `
        <div class="details-title">${appointment.CustomerName || 'N/A'}</div>
        <div class="details-item">
            <span class="details-label">Service Type:</span>
            <span class="details-value">${appointment.ServiceType || 'N/A'}</span>
        </div>
        <div class="details-item">
            <span class="details-label">Date:</span>
         <span class="details-value">${formatToUSDate(appointment.RequestDate)}</span>
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
            <span class="details-value">${appointment.SiteAddress || appointment.Address1 || 'N/A'}</span>
        </div>
    `;

    const rect = element.getBoundingClientRect();
    const popupWidth = popup.offsetWidth || 200;
    const popupHeight = popup.offsetHeight || 100;
    const viewportWidth = window.innerWidth;
    const viewportHeight = window.innerHeight;
    const isResourceView = currentView === 'resource' && element.classList.contains('calendar-event-resource');
    const allDaySection = document.querySelector('.all-day-section');
    const allDayHeight = allDaySection ? allDaySection.getBoundingClientRect().height : 0;

    let left, top;
    if (isResourceView) {
        top = rect.bottom + 10;
        if (top < allDayHeight + 10) top = allDayHeight + 10;
        if (top + popupHeight > viewportHeight) top = rect.top - popupHeight - 10;
        left = rect.left;
        if (left + popupWidth > viewportWidth) left = viewportWidth - popupWidth - 10;
    } else {
        left = rect.right + 10;
        top = rect.top;
        if (top < allDayHeight + 10) top = allDayHeight + 10;
        if (left + popupWidth > viewportWidth) left = rect.left - popupWidth - 10;
        if (top + popupHeight > viewportHeight) top = viewportHeight - popupHeight - 10;
    }

    left = Math.max(10, left);
    top = Math.max(10, top);

    popup.style.left = `${left}px`;
    popup.style.top = `${top}px`;

    popup.classList.add('show');
}

function hideDetailsPopup(popup) {
    popup.classList.remove('show');
    // Only remove 'expanded' from calendar-event and appointment-card
    document.querySelectorAll('.calendar-event.expanded, .appointment-card.expanded').forEach(el => {
        el.classList.remove('expanded');
    });
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
    document.querySelectorAll('.calendar-event, .calendar-event-resource').forEach(element => {
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

function renderDateView(date) {
    currentDate = new Date(date);
    const container = $("#dayCalendar").addClass('date-view').removeClass('resource-view');
    const view = $("#viewSelect").val();


    const $svc = $("[id$='ServiceTypeFilter']");
    const selectedValue = String($svc.val() ?? '').trim();
    const selectedText = String($svc.find('option:selected').text() ?? '').trim();


    const isAll = selectedValue === '' ||
        /^all(\s+(types|services))?$/i.test(selectedValue) ||
        /^all(\s+(types|services))?$/i.test(selectedText);


    const selectedId = (!isAll && /^\d+$/.test(selectedValue)) ? selectedValue : null;


    const selectedTextNorm = isAll ? '' : selectedText.toLowerCase();
    ;

    const dateStr = currentDate.toISOString().split('T')[0];
    renderDateNav("dateNav", dateStr);
    let fromDate, toDate, todayParam;
    let fromStr, toStr;

    switch (view) {
        case 'month':
            fromDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1);
            toDate = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 0); // Use last day of month
            fromStr = fromDate.toISOString().split('T')[0];
            toStr = toDate.toISOString().split('T')[0];
            todayParam = "";
            break;
        case 'week':
            fromDate = new Date(currentDate);
            toDate = new Date(currentDate);
            toDate.setDate(currentDate.getDate() + 6);
            fromStr = fromDate.toISOString().split('T')[0];
            toStr = toDate.toISOString().split('T')[0];
            todayParam = "";
            break;
        case 'threeDay':
            fromDate = new Date(currentDate);
            toDate = new Date(currentDate);
            toDate.setDate(currentDate.getDate() + 2);
            fromStr = fromDate.toISOString().split('T')[0];
            toStr = toDate.toISOString().split('T')[0];
            todayParam = "";
            break;
        default: // 'day' view
            fromStr = date;
            toStr = date;
            todayParam = date;
            break;
    }

    const slotDurationMinutes = 30;

    getAppoinments('', fromStr, toStr, todayParam, function (fetchedAppointments) {
        const norm = s => String(s ?? '').trim().toLowerCase();

        const filteredAppointments = isAll ? fetchedAppointments : fetchedAppointments.filter(a => {

            const aId = a.ServiceTypeID ?? a.ServiceTypeId ?? a.serviceTypeId ?? null;
            if (selectedId != null && aId != null && String(aId) === selectedId) return true;


            const s = norm(a.ServiceType);
            const f = selectedTextNorm;
            if (!s) return false;
            if (s === f || s.includes(f) || f.includes(s)) return true;
            if (/^it\s*support$/.test(f) && /it\s*support/.test(s)) return true;
            if (/1\s*hour/.test(f) && /1\s*hour/.test(s)) return true;
            if (/2\s*hour/.test(f) && /2\s*hour/.test(s)) return true;
            if (/3\s*hour/.test(f) && /3\s*hour/.test(s)) return true;
            if (/4\s*hour/.test(f) && /4\s*hour/.test(s)) return true;
            return false;
        });

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

                                    ${getAppointmentStatusIcon(a.AppoinmentStatus)}
                                    ${getTicketStatusIcon(a.TicketStatus)} 
                                    ${a.CustomerName} 

                                    <div class="fs-7 truncate">${a.ServiceType} (${a.Duration})</div>                                
                                   <div class="fs-7 truncate status status-${a.AppoinmentStatus.toLowerCase().replace(/\s+/g, '-')}">${a.AppoinmentStatus}</div>
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


            const dayDates = Array.from({ length: days }, (_, i) => {
                const d = new Date(startDate);
                d.setDate(startDate.getDate() + i);
                return d.toISOString().split('T')[0];
            });

            html += `
            <div class="border rounded overflow-hidden">
               <div class="calendar-grid" style="grid-template-columns: 80px repeat(${dayDates.length}, 1fr);">
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
                     <div class="calendar-grid" style="grid-template-columns: 80px repeat(${dayDates.length}, 1fr);">
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
                                    console.warn(`No matching time slot for appointment ${a.AppoinmentId}:`, {
                                        appointmentTimeSlot: a.TimeSlot,
                                        availableTimeSlots: allTimeSlots.map(s => s.TimeBlockSchedule)
                                    });
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
                                    const offsetPx = (offsetMinutes / slotDurationMinutes) * 40;
                                    const heightPx = (durationMinutes / slotDurationMinutes) * 40;
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

                        const numAppointments = cellAppointments.length;

                        html += `
                        <div class="h-60px border-bottom last-border-bottom-none border-right last-border-right-none p-1 relative drop-target calendar-cell"
                                                       style="overflow: visible;"
                             data-date="${dStr}" data-time="${time.TimeBlockSchedule}">
                            ${cellAppointments.map((appt, idx) => {
                            renderedAppointments[dStr].add(appt.appointment.AppoinmentId);
                            return `
                                <div class="calendar-event ${getEventTimeSlotClass(appt.appointment)} cursor-move fs-7 truncate"
                                     style="position: absolute; top: ${appt.offsetPx}px; left: calc(${idx} * 100% / ${numAppointments}); height: ${appt.heightPx}px; width: calc(100% / ${numAppointments});"
                                     data-id="${appt.appointment.AppoinmentId}" draggable="true">

                                    <div class="font-weight-medium fs-7">
                                    ${getAppointmentStatusIcon(appt.appointment.AppoinmentStatus)}
                                    ${getTicketStatusIcon(appt.appointment.TicketStatus)}
                                    ${appt.appointment.CustomerName}
                                    </div>

                                    <div class="fs-7 truncate">${appt.appointment.ServiceType} (${appt.appointment.Duration})</div>
             
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
                <div class="calendar-grid" style="grid-template-columns: 80px 1fr;">
                    <div class="p-2 border-right bg-gray-50 calendar-header-cell"></div>
                    <div class="p-2 text-center font-weight-medium bg-gray-50 calendar-header-cell">
                       ${currentDate.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
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
                    <div class="calendar-grid" style="grid-template-columns: 80px 1fr;">
                        <div class="h-60px border-bottom last-border-bottom-none p-1 fs-7 text-left pr-2 bg-gray-50 calendar-time-cell">
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
                                const offsetPx = (offsetMinutes / slotDurationMinutes) * 25;
                                const heightPx = (durationMinutes / slotDurationMinutes) * 25;
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

                    // Calculate the width of each appointment and ensure no overlap
                    const appointmentWidth = 150; // Fixed width for each appointment
                    const maxAppointments = cellAppointments.length;
                    const totalWidth = maxAppointments * appointmentWidth; // Total width needed for all appointments


                    html += `
                                      <div class="h-60px border-bottom last-border-bottom-none border-right last-border-right-none p-1 relative drop-target calendar-cell"
                     style="min-width: ${totalWidth}px; overflow: visible;"
                     data-date="${dateStr}" data-time="${time.TimeBlockSchedule}">
                    ${cellAppointments.map((appt, idx) => {
                        const leftPx = idx * appointmentWidth;
                        renderedAppointments.add(appt.appointment.AppoinmentId);
                        return `
                            <div class="calendar-event ${getEventTimeSlotClass(appt.appointment)} cursor-move fs-7 truncate"
                                 style="position: absolute; top: ${appt.offsetPx}px; left: ${leftPx}px; height: ${appt.heightPx}px; width: ${appointmentWidth}px;"
                                 data-id="${appt.appointment.AppoinmentId}" draggable="true">
                                <div class="font-weight-medium fs-7">
                                    ${getAppointmentStatusIcon(appt.appointment.AppoinmentStatus)} 
                                    ${getTicketStatusIcon(appt.appointment.TicketStatus)} 
                                    ${appt.appointment.CustomerName}
                                </div>
                                <div class="truncate">${appt.appointment.ServiceType} (${appt.appointment.Duration})</div>
                           <div class="fs-7 status status-${appt.appointment.AppoinmentStatus.toLowerCase().replace(/\s+/g, '-')}">${appt.appointment.AppoinmentStatus}</div>
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
        updateCalendarEventColors();

        renderUnscheduledList('date', { from: fromStr, to: toStr });
    });
}

$(document).off('change.servicetype', "[id$='ServiceTypeFilter']")
    .on('change.servicetype', "[id$='ServiceTypeFilter']", function () {
        const d = $('#dayDatePicker').val() || new Date().toISOString().slice(0, 10);
        renderDateView(d);
    });

function searchListView(e) {
    e.preventDefault();
    const selectedDateFrom = $("#listDatePickerFrom").val();
    const selectedDateTo = $("#listDatePickerTo").val();

    if (!selectedDateFrom || !selectedDateTo) {
        showAlert({
            icon: 'warning',
            title: 'Missing Dates',
            text: 'Please select both from and to dates for a custom range search.',
        });
        return;
    }

    if (new Date(selectedDateTo) < new Date(selectedDateFrom)) {
        showAlert({
            icon: 'error',
            title: 'Invalid Date Range',
            text: 'To date must be after or equal to from date.',
        });
        return;
    }


    $("#listDatePicker").val("");

    listViewCurrentPage = 1;
    renderListView();
}


function clearFilterListView(e) {
    e.preventDefault();

    const todayStr = new Date().toISOString().split('T')[0];


    $("#listDatePicker").val(todayStr);
    $("#listDatePickerFrom").val("");
    $("#listDatePickerTo").val("");
    $("#MainContent_StatusTypeFilter_List").val("");
    $("#MainContent_ServiceTypeFilter_List").val("");
    $("#search_term").val("");

    // Reset pagination and sorting
    listViewCurrentPage = 1;
    currentSort = { key: '', direction: 'asc' };
    $('th.sortable').removeClass('sort-asc sort-desc');


    renderListView();


    $("#resourceDatePicker").val(todayStr);
    if (currentView === 'resource') {
        renderResourceView(todayStr);
    }
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

    listViewFilteredAppointments.sort((a, b) => {
        // Primary sort: by date
        const dateA = new Date(a.RequestDate);
        const dateB = new Date(b.RequestDate);
        if (dateA < dateB) return -1;
        if (dateA > dateB) return 1;

        // Secondary sort: by time slot
        const timeA = parseTimeToMinutes(a.TimeSlot);
        const timeB = parseTimeToMinutes(b.TimeSlot);
        return timeA - timeB;
    });

    // If a user has clicked a header, apply that sort on top of the default
    if (currentSort.key) {
        listViewFilteredAppointments.sort((a, b) => {
            const valA = a[currentSort.key] ? a[currentSort.key].toString().toLowerCase() : '';
            const valB = b[currentSort.key] ? b[currentSort.key].toString().toLowerCase() : '';

            // Ensure consistent sorting direction
            if (valA < valB) return currentSort.direction === 'asc' ? -1 : 1;
            if (valA > valB) return currentSort.direction === 'asc' ? 1 : -1;
            return 0;
        });
    }

    // Reset to first page when sorting
    listViewCurrentPage = 1;
    renderListViewTable();
    updateListViewPagination();
});


function renderListView() {
    const selectedDate = $("#listDatePicker").val() || "";
    const selectedDateFrom = $("#listDatePickerFrom").val() || "";
    const selectedDateTo = $("#listDatePickerTo").val() || "";
    const searchTerm = ($("#search_term").val() || "").trim().toLowerCase();

    const $type = $("[id$='ServiceTypeFilter_List']");
    const $status = $("[id$='StatusTypeFilter_List']");
    const $ticket = $("[id$='TicketStatusFilter_List']");

    const typeVal = String($type.val() ?? "").trim();
    const typeText = String($type.find("option:selected").text() ?? "").trim();
    const statusVal = String($status.val() ?? "").trim();
    const statusText = String($status.find("option:selected").text() ?? "").trim();
    const ticketVal = String($ticket.val() ?? "").trim();
    const ticketText = String($ticket.find("option:selected").text() ?? "").trim();

    const isAll = v => v === "" || /^all/i.test(v);
    const typeIsAll = isAll(typeVal) || isAll(typeText);
    const statusIsAll = isAll(statusVal) || isAll(statusText);
    const ticketIsAll = isAll(ticketVal) || isAll(ticketText);

    //  ID filters 
    const typeIdSel = (!typeIsAll && /^\d+$/.test(typeVal)) ? typeVal : null;
    const statusIdSel = (!statusIsAll && /^\d+$/.test(statusVal)) ? statusVal : null;
    const ticketIdSel = (!ticketIsAll && /^\d+$/.test(ticketVal)) ? ticketVal : null;

    const typeTextSel = typeIsAll ? "" : typeText.toLowerCase();
    const statusTextSel = statusIsAll ? "" : statusText.toLowerCase();
    const ticketTextSel = ticketIsAll ? "" : ticketText.toLowerCase();

    let fromDate = selectedDateFrom, toDate = selectedDateTo;
    if (!selectedDateFrom || !selectedDateTo) { fromDate = selectedDate; toDate = selectedDate; }

    if (fromDate && toDate && new Date(toDate) < new Date(fromDate)) {
        showAlert({ icon: "error", title: "Invalid Date Range", text: "To date must be after or equal to from date." });
        return;
    }

    $("#listViewLoading").show();

    getAppoinments(searchTerm, fromDate, toDate, "", function (appointments) {
        const norm = s => String(s ?? "").trim().toLowerCase();

        // --- Filtering ---
        listViewFilteredAppointments = (appointments || []).filter(item => {

            let okType = true;
            if (!typeIsAll) {
                const aTypeId = item.ServiceTypeID ?? item.ServiceTypeId ?? item.serviceTypeId ?? null;
                if (typeIdSel != null && aTypeId != null) {
                    okType = String(aTypeId) === typeIdSel;
                } else {
                    const s = norm(item.ServiceType), f = typeTextSel;
                    okType = !!s && (s === f || s.includes(f) || f.includes(s) ||
                        (/^it\s*support$/.test(f) && /it\s*support/.test(s)) ||
                        (/1\s*hour/.test(f) && /1\s*hour/.test(s)) ||
                        (/2\s*hour/.test(f) && /2\s*hour/.test(s)) ||
                        (/3\s*hour/.test(f) && /3\s*hour/.test(s)) ||
                        (/4\s*hour/.test(f) && /4\s*hour/.test(s)));
                }
            }

            let okStatus = true;
            if (!statusIsAll) {
                const aStatusId = item.StatusID ?? item.AppoinmentStatusID ?? item.AppointmentStatusID ?? null;
                if (statusIdSel != null && aStatusId != null) {
                    okStatus = String(aStatusId) === statusIdSel;
                } else {
                    const s = norm(item.AppoinmentStatus), f = statusTextSel;
                    okStatus = !!s && (s === f || s.includes(f));
                }
            }

            let okTicket = true;
            if (!ticketIsAll) {
                const aTicketId = item.TicketStatusID ?? item.TicketStatusId ?? item.ticketStatusId ?? null;
                if (ticketIdSel != null && aTicketId != null) {
                    okTicket = String(aTicketId) === ticketIdSel;
                } else {
                    const s = norm(item.TicketStatus), f = ticketTextSel;
                    okTicket = !!s && (s === f || s.includes(f));
                }
            }

            const combinedText = [
                item.CustomerName, item.BusinessName, item.ResourceName,
                item.Email, item.Mobile, item.Phone, item.Address1
            ].map(norm).join(" ");
            const okSearch = !searchTerm || combinedText.includes(searchTerm);

            return okType && okStatus && okTicket && okSearch;
        });

        const toMin = (typeof parseTimeToMinutes === "function")
            ? parseTimeToMinutes
            : (s => {
                const m = String(s || "").match(/(\d{1,2}):(\d{2})/);
                if (!m) return Number.POSITIVE_INFINITY;
                const h = +m[1], mm = +m[2];
                return h * 60 + mm;
            });

        // default chronological
        listViewFilteredAppointments.sort((a, b) => {
            const dA = new Date(a.RequestDate).getTime() || 0;
            const dB = new Date(b.RequestDate).getTime() || 0;
            if (dA !== dB) return dA - dB;
            const tA = toMin(a.TimeSlot), tB = toMin(b.TimeSlot);
            if (tA !== tB) return tA - tB;
            return (a.CustomerName || "").localeCompare(b.CustomerName || "");
        });

        if (window.currentSort && currentSort.key) {
            const key = currentSort.key;
            const dir = currentSort.direction === "asc" ? 1 : -1;
            listViewFilteredAppointments.sort((a, b) => {
                if (key === "TimeSlot") {
                    const A = toMin(a.TimeSlot), B = toMin(b.TimeSlot);
                    if (A !== B) return (A < B ? -1 : 1) * dir;
                } else {
                    const A = (a?.[key] ?? "").toString().toLowerCase();
                    const B = (b?.[key] ?? "").toString().toLowerCase();
                    if (A !== B) return (A < B ? -1 : 1) * dir;
                }
                const dA = new Date(a.RequestDate).getTime() || 0;
                const dB = new Date(b.RequestDate).getTime() || 0;
                if (dA !== dB) return dA - dB;
                const tA = toMin(a.TimeSlot), tB = toMin(b.TimeSlot);
                return tA - tB;
            });
        }

        window.listViewCurrentPage = 1;
        renderListViewTable();
        updateListViewPagination();
        $("#listViewLoading").hide();
    });
}

function renderUnscheduledList(view = 'date') {
    const isResourceView = view === 'resource';

    const resourceFilterId = isResourceView ? '#ResourceTypeFilter_Resource' : '#ResourceTypeFilter_2';
    const statusFilterId = isResourceView ? '#MainContent_StatusTypeFilter_Resource' : '#MainContent_StatusTypeFilter';
    const serviceFilterId = isResourceView ? '#MainContent_ServiceTypeFilter_Resource' : '#MainContent_ServiceTypeFilter_2';
    const searchFilterId = isResourceView ? '#searchFilterResource' : '#searchFilter';
    const listContainerId = isResourceView ? '#unscheduledListResource' : '#unscheduledList';
    const sortBtnId = isResourceView ? '#sortUnscheduledBtnResource' : '#sortUnscheduledBtn';

    const resourceFilterValue = $(resourceFilterId).val() || 'all';
    const statusFilterValue = $(statusFilterId).val() || '';
    const serviceFilterValue = $(serviceFilterId).val() || '';
    const searchFilter = ($(searchFilterId).val() || '').toLowerCase().trim();

    const statusFilterText = statusFilterValue === '' ? '' : $(`${statusFilterId} option:selected`).text();
    const serviceFilterText = serviceFilterValue === '' ? '' : $(`${serviceFilterId} option:selected`).text();

    const filteredAppointments = appointments.filter(app => {
        const isUnassigned = !(app.ResourceName && app.ResourceName.trim() !== '' && app.ResourceName !== 'Unassigned' && app.ResourceName !== 'none');
        let matchesResource = true;
        if (resourceFilterValue === 'unassigned') {
            matchesResource = isUnassigned;
        } else if (resourceFilterValue === 'assigned') {
            matchesResource = !isUnassigned;
        }
        const matchesStatus = (statusFilterValue === '') || (app.AppoinmentStatus === statusFilterText);
        const matchesService = (serviceFilterValue === '') || (app.ServiceType === serviceFilterText);
        const matchesSearch = !searchFilter ||
            (app.CustomerName && app.CustomerName.toLowerCase().includes(searchFilter)) ||
            (app.Address1 && app.Address1.toLowerCase().includes(searchFilter));
        return matchesResource && matchesStatus && matchesService && matchesSearch;
    });


    const sortedAppointments = filteredAppointments.slice().sort((a, b) => {

        const getDate = (dateStr) => {
            const date = new Date(dateStr);

            return isNaN(date) ? new Date('9999-12-31') : date;
        };

        const dateA = getDate(a.RequestDate);
        const dateB = getDate(b.RequestDate);
        const timeA = parseTimeToMinutes(a.TimeSlot);
        const timeB = parseTimeToMinutes(b.TimeSlot);


        if (unscheduledSortOrder === 'asc') {

            if (dateA < dateB) return -1;
            if (dateA > dateB) return 1;
            if (timeA < timeB) return -1;
            if (timeA > timeB) return 1;
            return (a.CustomerName || '').localeCompare(b.CustomerName || '');
        } else {

            if (dateA > dateB) return -1;
            if (dateA < dateB) return 1;
            if (timeA > timeB) return -1;
            if (timeA < timeB) return 1;
            return (b.CustomerName || '').localeCompare(a.CustomerName || '');
        }
    });


    const icon = $(`${sortBtnId} i`);
    if (icon.length) {
        icon.removeClass('fa-sort-amount-up fa-sort-amount-down');
        icon.addClass(unscheduledSortOrder === 'asc' ? 'fa-sort-amount-up' : 'fa-sort-amount-down');
    }


    const $listContainer = $(listContainerId);
    $listContainer.empty();

    if (sortedAppointments.length === 0) {
        $listContainer.append('<div class="text-center py-4 text-muted">No appointments match the filters.</div>');
        return;
    }

    sortedAppointments.forEach(app => {
        const card = `
          <div class="appointment-card card mb-3 shadow-sm unscheduled-item" data-id="${app.AppoinmentId}" draggable="true">
            <div class="card-body p-3">
              <div class="d-flex justify-content-between align-items-start">
                <h3 class="font-weight-medium fs-6 mb-0">${app.CustomerName || 'Unknown Customer'}</h3>
                <span class="fs-7 text-muted"><i class="fa fa-user me-1"></i>${app.ResourceName || 'Unassigned'}</span>
              </div>
               <div class="fs-7 text-muted mt-1 line-clamp-2">${app.SiteAddress || app.Address1 || 'No address'}</div>
              <div class="fs-7 text-muted mt-1">
              <i class="fa fa-calendar me-1"></i>${formatToUSDate(app.RequestDate)}
                &nbsp;&nbsp; 
                <i class="fa fa-clock me-1"></i>${formatTimeRange(app.TimeSlot)}
              </div>
              <div class="d-flex justify-content-between align-items-center mt-2">
                <span class="fs-7">${app.ServiceType || 'Unknown'}</span>
                <span class="fs-7 truncate status status-${app.AppoinmentStatus.toLowerCase().replace(/\s+/g, '-')}">${app.AppoinmentStatus || 'N/A'}</span>

              </div>
            </div>
          </div>`;
        $listContainer.append(card);
    });

    setupDragAndDrop();
}
function formatToUSDate(dateString) {

    if (!dateString) {
        return 'No date';
    }
    const parts = dateString.split('-');
    if (parts.length !== 3) {
        return dateString;
    }
    const date = new Date(parts[0], parts[1] - 1, parts[2]);

    if (isNaN(date.getTime())) {
        return dateString;
    }

    // Get month, day, and year
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const year = date.getFullYear();

    return `${month}/${day}/${year}`;
}


//Custom Sorting for Appointment List
function performSort(view) {
    // This function ONLY toggles the sort direction and re-renders.
    unscheduledSortOrder = unscheduledSortOrder === 'asc' ? 'desc' : 'asc';
    renderUnscheduledList(view);
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
            const newDate = $(this).data("date");
            const newTime = $(this).data("time");
            const newResourceName = $(this).data("resource") || "Unassigned";

            const appointment = appointments.find(a => a.AppoinmentId === appointmentId);
            if (!appointment) {
                console.warn(`Appointment not found for ID: ${appointmentId}`);
                return;
            }

            if (appointment.AppoinmentStatus.toLowerCase() === "closed") {
                showAlert({
                    icon: 'info',
                    title: 'Cannot Reschedule',
                    text: 'This appointment is closed and cannot be rescheduled.',
                    confirmButtonText: 'OK'
                });
                return;
            }

            if (hasConflict(appointment, newTime || appointment.TimeSlot, newResourceName, newDate, appointmentId)) {
                showAlert({
                    icon: 'error',
                    title: 'Scheduling Conflict',
                    text: 'This time slot is already taken for the selected resource and date.',
                    confirmButtonText: 'OK'
                });
                return;
            }

            const resourceObj = resources.find(r => r.ResourceName === newResourceName);
            const newResourceId = resourceObj ? resourceObj.Id : 0;

            const serverAppointment = {
                AppoinmentId: parseInt(appointment.AppoinmentId),
                CustomerID: parseInt(appointment.CustomerID) || null,
                ServiceType: appointment.ServiceTypeID,
                RequestDate: newDate,
                TimeSlot: newTime || appointment.TimeSlot,
                ResourceID: newResourceId,
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
                            title: 'Rescheduled!',
                            text: 'The appointment has been moved.',
                            timer: 1500,
                            showConfirmButton: false,
                            customClass: { popup: 'swal-custom-popup' }
                        });


                        appointment.RequestDate = newDate;
                        appointment.TimeSlot = newTime || appointment.TimeSlot;
                        appointment.ResourceName = newResourceName;
                        appointment.ResourceID = newResourceId;

                        saveAppointments();
                        updateAllViews();
                    } else {
                        showAlert({
                            icon: 'error',
                            title: 'Update Failed',
                            text: 'The server failed to update the appointment. The change has been reverted.'
                        });
                    }
                },
                error: function (xhr, status, error) {
                    console.error("Error updating appointment on drop:", error);
                    showAlert({
                        icon: 'error',
                        title: 'Server Error',
                        text: 'A server error occurred while rescheduling. The change has been reverted.'
                    });
                }
            });
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


            appointment.ResourceID = 0;
            appointment.ResourceName = 'Unassigned';
            appointment.RequestDate = null;
            appointment.TimeSlot = null;
            appointment.Duration = '1 Hr';


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

function openEditModal(id, date, time, resource, confirm) {
    const a = appointments.find(x => x.AppoinmentId === id.toString());
    if (!a) {
        console.error(`Appointment with ID ${id} not found.`);
        return;
    }

    const viewDetailsBtn = document.getElementById('viewCustomerDetailsBtn');
    if (viewDetailsBtn) {
        if (a.CustomerID && a.SiteId) {
            viewDetailsBtn.href = `CustomerDetails.aspx?custId=${encodeURIComponent(a.CustomerID)}&siteId=${a.SiteId}`;
            viewDetailsBtn.style.display = 'inline-block';
        } else {
            viewDetailsBtn.style.display = 'none';
        }
    }

    if (!confirm) {
        loadCurrentlySelectedForms(id);
        loadCustomerDataForModal(id);
    }

    if (a.AppoinmentStatus.toLowerCase() === "closed") {
        showAlert({
            icon: 'info',
            title: 'Cannot Edit',
            text: 'This appointment is closed and cannot be edited.'
        });
        return;
    }

    currentEditId = id;
    const form = document.getElementById("editForm");
    if (!form) {
        console.error('Edit form not found in DOM');
        return;
    }


    loadCustomFields(form, a); // Load and render the custom fields

    form.querySelector("[id='AppoinmentId']").value = parseInt(a.AppoinmentId);
    form.querySelector("[id='CustomerID']").value = parseInt(a.CustomerID) || '';
    form.querySelector("[name='customerName']").value = a.CustomerName || '';
    form.querySelector("[name='phone']").value = a.Phone || '';
    form.querySelector("[name='mobile']").value = a.Mobile || '';
    form.querySelector("[name='address']").value = a.SiteAddress || a.Address1 || '';
    form.querySelector("[name='note']").value = a.Note || '';
    form.querySelector("[name='duration']").value = a.Duration || "1 Hr";

    const service_select = form.querySelector("[id='MainContent_ServiceTypeFilter_Edit']");
    getSelectedId(service_select, a.ServiceType || "");

    const status_select = form.querySelector("[id='MainContent_StatusTypeFilter_Edit']");
    getSelectedId(status_select, a.AppoinmentStatus || "");

    const ticket_status = form.querySelector("[id='MainContent_TicketStatusFilter_Edit']");
    getSelectedId(ticket_status, a.TicketStatus || "");

    const resource_select = form.querySelector("[name='resource']");
    getSelectedId(resource_select, resource || a.ResourceName || "");

    form.querySelector("[name='date']").value = date || a.RequestDate || '';

    const timeSlotValue = time || a.TimeSlot || '';
    const matchingSlot = allTimeSlots.find(slot => slot.TimeBlockSchedule === timeSlotValue || slot.TimeBlock === timeSlotValue);
    form.querySelector("[name='timeSlot']").value = matchingSlot ? matchingSlot.TimeBlock : a.TimeSlot || '';

    extractHoursAndMinutes(a.Duration);
    calculateStartEndTime();

    if (confirm) {
        $('.confirm-title').removeClass('d-none');
        $('.edit-title').addClass('d-none');
    } else {
        $('.edit-title').removeClass('d-none');
        $('.confirm-title').addClass('d-none');
    }

    const isClosed = a.AppoinmentStatus.toLowerCase() === "closed";
    service_select.disabled = isClosed;
    status_select.disabled = isClosed;
    ticket_status.disabled = isClosed;

    try {
        window.editModalInstance.show();
    } catch (error) {
        console.error('Error opening editModal:', error);
    }
}

// ADD ALL OF THESE NEW FUNCTIONS

function loadCustomFields(form, appointment) {
    const container = document.getElementById("customFieldsContainer");
    if (!container) {
        console.error("Custom fields container not found");
        return;
    }
    container.innerHTML = '<div class="loading-spinner">Loading custom fields...</div>';

    $.ajax({
        type: "POST",
        url: "Appointments.aspx/GetActiveCustomFields",
        contentType: "application/json; charset=utf-8",
        data: JSON.stringify({ apptId: currentEditId }),
        dataType: "json",
        success: function (response) {
            container.innerHTML = ''; // Clear loading spinner
            if (response.d && response.d.length > 0) {
                renderCustomFields(response.d, container, appointment);
            } else {
                container.innerHTML = '<div class="alert alert-info">No active custom fields found.</div>';
            }
        },
        error: function (xhr, status, error) {
            container.innerHTML = '<div class="alert alert-danger">Failed to load custom fields.</div>';
            console.error("Error loading custom fields:", error);
        }
    });
}

function renderCustomFields(fields, container, appointment) {
    const existingValues = appointment.CustomFieldsJson ? JSON.parse(appointment.CustomFieldsJson) : {};

    fields.forEach(field => {
        const fieldGroup = document.createElement('div');
        fieldGroup.className = 'form-group mb-3 col-md-6';

        const label = document.createElement('label');
        label.className = 'form-label';
        label.htmlFor = `custom_${field.FieldId}`;
        label.textContent = field.FieldName;

        if (field.FieldType !== 'checklist') {
            const reqSpan = document.createElement('span');
            reqSpan.className = 'text-danger ms-1';
            reqSpan.title = 'Required field';
            reqSpan.textContent = '*';
            label.appendChild(reqSpan);
        }
        fieldGroup.appendChild(label);

        let input;
        const value = existingValues[field.FieldId] || '';
        const options = field.Options ? JSON.parse(field.Options) : [];

        switch (field.FieldType) {
            case 'text':
            case 'number':
            case 'date':
                input = document.createElement('input');
                input.type = field.FieldType;
                input.id = `custom_${field.FieldId}`;
                input.name = `custom_${field.FieldId}`;
                input.className = 'form-control';
                input.value = value;
                if (field.FieldType !== 'checklist') input.required = true;
                break;
            case 'dropdown':
                input = document.createElement('select');
                input.id = `custom_${field.FieldId}`;
                input.name = `custom_${field.FieldId}`;
                input.className = 'form-select';
                input.required = true;
                const defaultOpt = document.createElement('option');
                defaultOpt.value = '';
                defaultOpt.textContent = 'Select an option';
                input.appendChild(defaultOpt);
                options.forEach(opt => {
                    const option = document.createElement('option');
                    option.value = opt;
                    option.textContent = opt;
                    option.selected = opt === value;
                    input.appendChild(option);
                });
                break;
            case 'checklist':
                input = document.createElement('div');
                const values = Array.isArray(value) ? value : [];
                options.forEach(opt => {
                    const checkDiv = document.createElement('div');
                    checkDiv.className = 'form-check';
                    const chkInput = document.createElement('input');
                    chkInput.type = 'checkbox';
                    chkInput.className = 'form-check-input';
                    chkInput.name = `custom_${field.FieldId}`;
                    chkInput.value = opt;
                    chkInput.checked = values.includes(opt);
                    chkInput.id = `custom_${field.FieldId}_${opt.replace(/\s+/g, '_')}`;
                    const chkLabel = document.createElement('label');
                    chkLabel.className = 'form-check-label';
                    chkLabel.htmlFor = chkInput.id;
                    chkLabel.textContent = opt;
                    checkDiv.appendChild(chkInput);
                    checkDiv.appendChild(chkLabel);
                    input.appendChild(checkDiv);
                });
                break;
            default:
                return;
        }

        fieldGroup.appendChild(input);
        container.appendChild(fieldGroup);
    });
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

const getAppointmentStatusIcon = (status) => {
    if (!status) return '<i class="fas fa-question-circle"></i>';

    const lowerStatus = status.toLowerCase();
    switch (lowerStatus) {
        case 'pending':
            return '<i class="fas fa-hourglass-start" title= "pending"></i>'; // Pending icon
        case 'scheduled':
            return '<i class="fas fa-calendar-check" title= "scheduled"></i>'; // Scheduled icon
        case 'cancelled':
            return '<i class="fas fa-ban" title= "cancelled"></i>'; // Cancelled icon
        case 'closed':
            return '<i class="fas fa-lock" title= "closed"></i>'; // Closed icon
        case 'installation in progress':
            return '<i class="fas fa-cogs" title= "installation in process"></i>'; // Installation in progress icon
        case 'completed':
            return '<i class="fas fa-check-circle" title= "completed"></i>'; // Completed icon
        default:
            return '<i class="fas fa-question-circle title= "undefined appointment status""></i>'; // Default icon
    }
};

const getTicketStatusIcon = (ticketStatus) => {
    if (ticketStatus == null) return '<i class="fas fa-info-circle" title="Unknown Ticket Status"></i>';
    const v = String(ticketStatus).trim().toLowerCase();

    switch (v) {
        case '1':
        case 'on hold':
            return '<i class="fas fa-pause-circle" title="On Hold"></i>';
        case '2':
        case 'parts on order':
            return '<i class="fas fa-box-open" title="Parts on Order"></i>';
        case '3':
        case 'installation in progress':
            return '<i class="fas fa-tools" title="Installation in Progress"></i>';
        case '4':
        case 'completed':
            return '<i class="fas fa-clipboard-check" title="Completed"></i>';
        case 'pending':
            return '<i class="fas fa-clock" title="Pending"></i>';
        default:
            return '<i class="fas fa-info-circle" title="Unknown Ticket Status"></i>';
    }
};

// Render Resource View with duration-based independent positioning
function renderResourceView(date) {
    $('#resourceLoading').show();
    $("#resourceViewContainer").css('display', 'block');
    $("#resourceViewContainer").html('<div id="resourceLoading" class="loading-overlay"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Loading...</span></div></div>');

    const container = $("#resourceViewContainer");
    const dateStr = new Date(date).toISOString().split('T')[0];

    // Render date navigation FIRST
    renderDateNav("resourceNav", dateStr);

    const selectedGroup = $("#dispatchGroup").val();
    const view = $("#resourceViewSelect").val();
    const filteredResources = resources;
    const slotDurationMinutes = 30;
    const pixelsPerSlot = 100;
    const eventHeight = 35;

    // Always show pagination controls
    const paginationControls = document.querySelector('#resourceView .pagination-controls');
    if (paginationControls) {
        paginationControls.style.display = 'flex';
    }

    // Determine date range based on view
    let dates = [dateStr];
    let fromDate, toDate;
    if (view === 'week') {
        const startDate = new Date(date);
        fromDate = startDate.toISOString().split('T')[0];
        toDate = new Date(startDate);
        toDate.setDate(startDate.getDate() + 6);
        toDate = toDate.toISOString().split('T')[0];
        dates = Array.from({ length: 7 }, (_, i) => {
            const d = new Date(startDate);
            d.setDate(startDate.getDate() + i);
            return d.toISOString().split('T')[0];
        });
    } else if (view === 'threeDay') {
        const startDate = new Date(date);
        fromDate = startDate.toISOString().split('T')[0];
        toDate = new Date(startDate);
        toDate.setDate(startDate.getDate() + 2);
        toDate = toDate.toISOString().split('T')[0];
        dates = Array.from({ length: 3 }, (_, i) => {
            const d = new Date(startDate);
            d.setDate(startDate.getDate() + i);
            return d.toISOString().split('T')[0];
        });
    } else if (view === 'custom' && resourceCustomDateRange.from && resourceCustomDateRange.to) {
        fromDate = resourceCustomDateRange.from;
        toDate = resourceCustomDateRange.to;
        const startDate = new Date(fromDate);
        const endDate = new Date(toDate);
        if (startDate <= endDate) {
            dates = [];
            for (let d = new Date(startDate); d <= endDate; d.setDate(d.getDate() + 1)) {
                dates.push(new Date(d).toISOString().split('T')[0]);
            }
        }
    } else {
        fromDate = dateStr;
        toDate = dateStr;
    }

    const validTimeSlots = allTimeSlots.filter(slot =>
        slot && slot.TimeBlockSchedule && !allTimeSlots.some(other => other !== slot && other.TimeBlockSchedule === slot.TimeBlockSchedule)
    );

    // Fetch appointments for the entire date range
    getAppoinments("", fromDate, toDate, view === 'day' ? dateStr : "", function (appointments) {
        $('#resourceLoading').hide();

        // Re-render date navigation after data load to ensure consistency
        renderDateNav("resourceNav", dateStr);

        let html = `
            <div class="border rounded overflow-hidden resizable-container" style="margin: 0; padding: 0; max-width: 100%;">
        `;

        // Render header based on view
        if (view === 'day') {
            html += `
                <div class="calendar-grid calendar-header" id="resource-header" style="grid-template-columns: 120px repeat(${validTimeSlots.length}, ${pixelsPerSlot}px);">
                    <div class="p-2 border-right bg-gray-50 calendar-header-cell"></div>
                    ${validTimeSlots.map(time => `
                        <div class="p-2 text-center font-weight-medium border-right last-border-right-none bg-gray-50 calendar-header-cell">
                            ${formatTimeRange(time.TimeBlockSchedule)}
                        </div>
                    `).join('')}
                </div>
            `;
        } else {
            html += `
                <div class="calendar-grid calendar-header" id="resource-header" style="grid-template-columns: 120px repeat(${dates.length}, minmax(150px, 1fr));">
                    <div class="p-2 border-right bg-gray-50 calendar-header-cell"></div>
                    ${dates.map(day => `
                        <div class="p-2 text-center font-weight-medium border-right last-border-right-none bg-gray-50 calendar-header-cell">
                            <div>${new Date(day).toLocaleDateString('en-US', { weekday: 'short' })}</div>
                            <div>${new Date(day).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}</div>
                        </div>
                    `).join('')}
                </div>
            `;
        }

        html += `
            <div class="calendar-body" style="margin: 0; padding: 0; max-width: 100%;">
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
                const resourceIcon = '<i class="fas fa-user"></i>';

                if (view === 'day') {
                    html += `
                        <div class="calendar-grid resource-row" id="${rowId}" style="grid-template-columns: 120px repeat(${validTimeSlots.length}, ${pixelsPerSlot}px); margin: 0; padding: 0; max-width: 100%; overflow: hidden; position: relative;">
                            <div class="h-${eventHeight}px border-bottom last-border-bottom-none p-1 fs-7 text-left bg-gray-50 calendar-time-cell resource-name" style="position: sticky; left: 0; z-index: 1; padding: 7px 10px !important;">
                                ${resourceIcon} ${resource.ResourceName}
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
                                    const totalHours = durationMinutes / 60;
                                    const startTimeMinutes = parseTimeToMinutes(timeSlot.TimeBlockSchedule.split('-')[0]);
                                    const slotStartTimeMinutes = parseTimeToMinutes(time.TimeBlockSchedule.split('-')[0]);
                                    const offsetMinutes = startTimeMinutes - slotStartTimeMinutes;
                                    const offsetPx = (offsetMinutes / slotDurationMinutes) * pixelsPerSlot;
                                    const widthPx = (totalHours * (pixelsPerSlot * 2));

                                    const overlappingAppointments = placedAppointments.filter(pa =>
                                        pa.offsetPx === offsetPx &&
                                        Math.abs(pa.widthPx - widthPx) < 10
                                    );
                                    const conflictIndex = overlappingAppointments.length;
                                    const adjustedOffsetPx = offsetPx + (conflictIndex * 10);

                                    placedAppointments.push({ appointment: a, offsetPx: adjustedOffsetPx, widthPx });

                                    return { appointment: a, offsetPx: adjustedOffsetPx, widthPx };
                                }
                                return null;
                            })
                            .filter(a => a);

                        html += `
                            <div class="h-${eventHeight}px border-bottom last-border-bottom-none border-right last-border-right-none p-1 relative drop-target calendar-cell"
                                 data-date="${dateStr}" 
                                 data-time="${time.TimeBlockSchedule}" 
                                 data-resource="${resource.ResourceName}"
                                 style="position: relative; margin: 0; padding: 0; max-width: ${pixelsPerSlot}px;">
                                ${cellAppointments.map(({ appointment, offsetPx, widthPx }) => {
                            const statusIcon = getAppointmentStatusIcon(appointment.AppoinmentStatus);
                            const ticketStatusIcon = getTicketStatusIcon(appointment.TicketStatus);
                            return `
                                        <div class="calendar-event-resource ${getEventTimeSlotClass(appointment)}"
                                             style="left:0px; 
                                                    width: ${Math.min(widthPx, pixelsPerSlot * validTimeSlots.length - offsetPx)}px; 
                                                    height: ${eventHeight}px; 
                                                    position: absolute;"
                                             data-id="${appointment.AppoinmentId}" 
                                             draggable="true">
                                            <div class="event-content" style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                                                ${statusIcon} ${ticketStatusIcon} ${appointment.CustomerName} (${appointment.ServiceType})
                                            </div>
                                        </div>
                                    `;
                        }).join('')}
                            </div>
                        `;
                    });
                    html += `</div>`;
                } else {
                    html += `
                        <div class="calendar-grid resource-row" id="${rowId}" style="grid-template-columns: 120px repeat(${dates.length}, minmax(150px, 1fr)); margin: 0; padding: 0; max-width: 100%; overflow: hidden; position: relative;">
                            <div class="h-${eventHeight}px border-bottom last-border-bottom-none p-1 fs-7 text-left bg-gray-50 calendar-time-cell resource-name" style="position: sticky; left: 0; z-index: 1; padding: 7px 10px !important;">
                                ${resourceIcon} ${resource.ResourceName}
                            </div>
                    `;

                    dates.forEach((day, dayIndex) => {
                        const cellAppointments = appointments
                            .filter(a => a.ResourceName === resource.ResourceName &&
                                a.RequestDate === day &&
                                a.TimeSlot)
                            .sort((a, b) => {
                                const aTime = parseTimeToMinutes(a.TimeSlot.split('-')[0]);
                                const bTime = parseTimeToMinutes(b.TimeSlot.split('-')[0]);
                                return aTime - bTime;
                            })
                            .map((a, idx) => {
                                const timeSlot = validTimeSlots.find(slot =>
                                    slot.TimeBlockSchedule === a.TimeSlot ||
                                    slot.TimeBlock.toLowerCase() === a.TimeSlot.toLowerCase()
                                );
                                if (!timeSlot) {
                                    console.warn(`No matching time slot for appointment ${a.AppoinmentId}: TimeSlot=${a.TimeSlot}`);
                                    return null;
                                }
                                const durationMinutes = parseDuration(a.Duration);
                                const totalHours = durationMinutes / 60;
                                const widthPx = (totalHours * (pixelsPerSlot * 2));
                                const offsetPx = idx * eventHeight;
                                return { appointment: a, offsetPx, widthPx };
                            })
                            .filter(a => a);

                        html += `
                            <div class="border-bottom last-border-bottom-none border-right last-border-right-none p-1 relative drop-target calendar-cell"
                                 data-date="${day}" 
                                 data-resource="${resource.ResourceName}"
                                 style="position: relative; margin: 0; padding: 0; min-height: ${cellAppointments.length * eventHeight}px;">
                                ${cellAppointments.map(({ appointment, offsetPx, widthPx }) => {
                            const statusIcon = getAppointmentStatusIcon(appointment.AppoinmentStatus);
                            const ticketStatusIcon = getTicketStatusIcon(appointment.TicketStatus);
                            return `
                                        <div class="calendar-event-resource ${getEventTimeSlotClass(appointment)}"
                                             style="top: ${offsetPx}px; 
                                                    left: 0px; 
                                                    width: ${Math.min(widthPx, 150)}px; 
                                                    height: ${eventHeight}px; 
                                                    position: absolute;"
                                             data-id="${appointment.AppoinmentId}" 
                                             draggable="true">
                                            <div class="event-content" style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                                                ${statusIcon} ${ticketStatusIcon} ${appointment.CustomerName} (${appointment.ServiceType})
                                            </div>
                                        </div>
                                    `;
                        }).join('')}
                            </div>
                        `;
                    });
                    html += `</div>`;
                }
            });
        }

        html += `</div></div>`;
        container.html(html);

        // Setup resizable resource panel
        const resizableContainer = container.find('.resizable-container')[0];
        let isResizing = false;
        let startX, startWidth;

        resizableContainer.addEventListener('mousedown', (e) => {
            if (e.offsetX > resizableContainer.offsetWidth - 10) {
                isResizing = true;
                startX = e.pageX;
                startWidth = resizableContainer.offsetWidth;
                resizableContainer.style.cursor = 'ew-resize';
            }
        });

        document.addEventListener('mousemove', (e) => {
            if (isResizing) {
                const width = startWidth + (e.pageX - startX);
                resizableContainer.style.width = `${Math.max(300, width)}px`;
            }
        });

        document.addEventListener('mouseup', () => {
            if (isResizing) {
                isResizing = false;
                resizableContainer.style.cursor = 'default';
            }
        });

        $('#resourceLoading').hide();
        setupHoverEvents();
        setupDragAndDrop();
        updateCalendarEventColors();
        renderUnscheduledList('resource');

        resourceViewFilteredAppointments = filteredResources;
        resourceViewCurrentPage = 1;
        updateResourceViewPagination();

        const header = document.querySelector('#resource-header');
        const rows = document.querySelectorAll('.resource-row');
        if (header && rows.length > 0) {
            enableDragToScroll('#resource-header');
            filteredResources.forEach((_, index) => {
                const rowSelector = `#resource-row-${index}`;
                enableDragToScroll(rowSelector);
                const row = document.querySelector(rowSelector);
                row.addEventListener('scroll', () => {
                    header.scrollLeft = row.scrollLeft;
                    rows.forEach(otherRow => {
                        if (otherRow !== row) otherRow.scrollLeft = row.scrollLeft;
                    });
                });
                header.addEventListener('scroll', () => {
                    rows.forEach(r => r.scrollLeft = header.scrollLeft);
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
    document.getElementById('sortUnscheduledBtn')?.addEventListener('click', () => {
        toggleUnscheduledSort('date');
    });
    document.getElementById('sortUnscheduledBtnResource')?.addEventListener('click', () => {
        toggleUnscheduledSort('resource');
    });

    $('#ResourceTypeFilter_2').on('change', () => renderUnscheduledList('date'));
    $('#ResourceTypeFilter_Resource').on('change', () => renderUnscheduledList('resource'));
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

            // Initialize all date-related elements
            const today = new Date().toISOString().split('T')[0];
            document.getElementById('dateInput').min = today;

            // Set initial dates on pickers, respecting custom range
            ['#dayDatePicker', '#resourceDatePicker', '#mapDatePicker'].forEach(picker => {
                $(picker).val(today).trigger('change');
            });
            // Only set #listDatePicker if no custom range is set
            if (!$("#listDatePickerFrom").val() && !$("#listDatePickerTo").val()) {
                $("#listDatePicker").val(today).trigger('change');
            }
            loadServiceTypeIndicators();

            currentView = "date";
            renderDateView(today);
            renderDateNav('dateNav', today);
            renderDateNav('resourceNav', today);

            // Tab switching logic
            document.querySelectorAll('#viewTabs button[data-bs-toggle="tab"]').forEach(tab => {
                tab.addEventListener('shown.bs.tab', function (event) {
                    // Get the current date from the appropriate picker based on which tab is active
                    const currentDate = event.target.id === 'resource-tab'
                        ? $('#resourceDatePicker').val()
                        : $('#dayDatePicker').val();

                    switch (event.target.id) {
                        case 'date-tab':
                            currentView = "date";
                            renderDateView(currentDate);
                            renderDateNav('dateNav', currentDate); // Ensure date nav is rendered
                            break;
                        case 'resource-tab':
                            currentView = "resource";
                            const resourceDate = $('#resourceDatePicker').val() || new Date().toISOString().split('T')[0];
                            renderResourceView(resourceDate);
                            break;
                        case 'list-tab':
                            currentView = "list";
                            renderListView();
                            break;
                        case 'map-tab':
                            currentView = "map";
                            renderMapView();
                            setTimeout(() => {
                                mapViewInstance?.invalidateSize();
                            }, 100);
                            break;
                    }
                });

            });
            const setupDatePickerSync = (pickerId) => {
                const pickerElement = document.getElementById(pickerId.replace('#', ''));
                if (pickerElement) {
                    pickerElement.addEventListener('change', (e) => {

                        if (pickerId === '#listDatePicker' && e.target.value) {
                            $("#listDatePickerFrom").val("");
                            $("#listDatePickerTo").val("");
                        }
                        syncDatePickers(pickerId, e.target.value);
                    });
                }
            };

            ['#dayDatePicker', '#resourceDatePicker', '#mapDatePicker', '#listDatePicker'].forEach(setupDatePickerSync);


            // View select handlers
            document.getElementById('viewSelect').addEventListener('change', (e) => {
                renderDateView($('#dayDatePicker').val());
            });

            document.getElementById('resourceViewSelect').addEventListener('change', (e) => {
                const currentDate = $('#resourceDatePicker').val();
                if (e.target.value === 'custom') {
                    showResourceCustomDateRangeContainer();
                } else {
                    hideResourceCustomDateRangeContainer();
                    resourceCustomDateRange.from = null;
                    resourceCustomDateRange.to = null;


                    renderResourceView(currentDate);
                    renderDateNav('resourceNav', currentDate); // Explicitly update the date boxes
                }
            });

            // Add search button handler
            document.getElementById('resourceCustomDateSearch').addEventListener('click', searchResourceCustomDateRange);

            // Custom date range handlers
            const handleCustomRangeToggle = (selectId, showFn, hideFn) => {
                document.getElementById(selectId).addEventListener('change', (e) => {
                    if (e.target.value === 'custom') {
                        showFn();
                    } else {
                        hideFn();
                    }
                });
            };

            handleCustomRangeToggle(
                'viewSelect',
                showCustomDateRangeContainer,
                () => {
                    hideCustomDateRangeContainer();
                    customDateRange.from = null;
                    customDateRange.to = null;
                }
            );

            handleCustomRangeToggle(
                'resourceViewSelect',
                showResourceCustomDateRangeContainer,
                () => {
                    hideResourceCustomDateRangeContainer();
                    resourceCustomDateRange.from = null;
                    resourceCustomDateRange.to = null;
                }
            );
            function showResourceCustomDateRangeContainer() {
                $("#resourceCustomDateRangeContainer").removeClass('d-none');
            }

            function hideResourceCustomDateRangeContainer() {
                $("#resourceCustomDateRangeContainer").addClass('d-none');
            }

            function searchResourceCustomDateRange() {
                const fromDate = $("#resourceDatePickerFrom").val();
                const toDate = $("#resourceDatePickerTo").val();

                if (!fromDate || !toDate) {
                    showAlert({
                        icon: 'warning',
                        title: 'Missing Dates',
                        text: 'Please select both from and to dates.',
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

                if (new Date(toDate) < new Date(fromDate)) {
                    showAlert({
                        icon: 'error',
                        title: 'Invalid Date Range',
                        text: 'To date must be after or equal to from date.',
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

                resourceCustomDateRange.from = fromDate;
                resourceCustomDateRange.to = toDate;
                renderResourceView(fromDate);
            }
            // Filter handlers
            document.getElementById('ServiceTypeFilter').addEventListener('change', (e) => {
                renderDateView($('#dayDatePicker').val());
            });

            // Map controls
            document.getElementById('statusFilter').addEventListener('change', () => {
                renderMapMarkers($('#mapDatePicker').val());
            });

            document.getElementById('mapReloadBtn').addEventListener('click', () => {
                renderMapMarkers($('#mapDatePicker').val());
            });

            document.getElementById('mapOptimizeRouteBtn').addEventListener('click', optimizeRoute);
            document.getElementById('mapAddCustomMarkerBtn').addEventListener('click', addCustomMarker);

            // Map layer toggles
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

    // Modal dismiss handlers
    document.querySelectorAll('[data-bs-dismiss="modal"]').forEach(button => {
        button.addEventListener('click', function () {
            const modal = bootstrap.Modal.getInstance(this.closest('.modal'));
            modal?.hide();
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
        .replace(/\s*(AM|PM)\s*/gi, '') // Remove AM/PM
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
function populateStatusDropdown() {
    const statusOptions = [
        { value: 'Pending', text: 'Pending' },
        { value: 'Scheduled', text: 'Scheduled' },
        { value: 'Cancelled', text: 'Cancelled' },
        { value: 'Closed', text: 'Closed' },
        { value: 'Installation In Progress', text: 'Installation In Progress' },
        { value: 'Completed', text: 'Completed' }
    ];
    const dropdowns = ['#MainContent_StatusTypeFilter_List', '#MainContent_StatusTypeFilter_Edit'];
    dropdowns.forEach(selector => {
        const $dropdown = $(selector);
        $dropdown.empty().append('<option value="">All Statuses</option>');
        statusOptions.forEach(opt => {
            $dropdown.append(`<option value="${opt.value}">${opt.text}</option>`);
        });
    });
}

function populateTicketStatusDropdown() {
    const ticketStatusOptions = [
        { value: '1', text: 'On Hold' },
        { value: '2', text: 'Parts on Order' },
        { value: '3', text: 'Installation in Progress' },
        { value: '4', text: 'Completed' },
        { value: 'Pending', text: 'Pending' }
    ];
    const dropdowns = ['#MainContent_TicketStatusFilter_List', '#MainContent_TicketStatusFilter_Edit'];
    dropdowns.forEach(selector => {
        const $dropdown = $(selector);
        $dropdown.empty().append('<option value="">All Ticket Statuses</option>');
        ticketStatusOptions.forEach(opt => {
            $dropdown.append(`<option value="${opt.value}">${opt.text}</option>`);
        });
    });
}
function saveAppoinmentData(e) {
    e.preventDefault();
    const form = new FormData(e.target);
    const id = form.get("AppoinmentId");


    let isValid = true;
    document.querySelectorAll('#customFieldsContainer [name^="custom_"][required]').forEach(input => {
        if (!input.value) {
            isValid = false;
            input.classList.add('is-invalid');
            if (!input.parentNode.querySelector('.invalid-feedback')) {
                const errorMsg = document.createElement('div');
                errorMsg.className = 'invalid-feedback';
                errorMsg.textContent = 'This field is required.';
                input.parentNode.appendChild(errorMsg);
            }
        } else {
            input.classList.remove('is-invalid');
            const existingError = input.parentNode.querySelector('.invalid-feedback');
            if (existingError) existingError.remove();
        }
    });

    if (!isValid) {
        showAlert({
            icon: 'error',
            title: 'Validation Error',
            text: 'Please fill in all required custom fields.',
        });
        return;
    }


    const customValues = {};
    document.querySelectorAll('#customFieldsContainer [name^="custom_"]').forEach(input => {
        const fieldId = input.name.replace('custom_', '');
        if (input.type === 'checkbox') {
            if (input.checked) {
                if (!customValues[fieldId]) customValues[fieldId] = [];
                customValues[fieldId].push(input.value);
            }
        } else {
            customValues[fieldId] = input.value;
        }
    });


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
    appointment.AttachedForms = selectedForms.map(form => form.id);


    appointment.CustomFieldsJson = JSON.stringify(customValues);


    $.ajax({
        type: "POST",
        url: "Appointments.aspx/UpdateAppointment",
        data: JSON.stringify({ appointment: appointment }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            if (response.d) {
                const updatedAppointment = appointments.find(a => a.AppoinmentId === id);
                if (updatedAppointment) {

                    updatedAppointment.CustomFieldsJson = appointment.CustomFieldsJson;
                    updatedAppointment.AttachedForms = selectedForms.map(form => form.id);
                }
                showAlert({
                    icon: 'success',
                    title: 'Success',
                    text: 'Appointment updated successfully!',
                    timer: 2000
                });
                updateAllViews();
                window.editModalInstance.hide();
            } else {
                showAlert({
                    icon: 'error',
                    title: 'Error',
                    text: 'Something went wrong while updating the appointment.'
                });
            }
        },
        error: function (xhr, status, error) {
            console.error("Error updating appointment: ", error);
            showAlert({
                icon: 'error',
                title: 'Error',
                text: 'Failed to update appointment due to a server error.'
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
    const dateValue = form.querySelector("[name='date']").value;

    if (!timeSlot || !dateValue) {
        // Clear fields if data is missing
        form.querySelector("[id='txt_StartDate']").value = '';
        form.querySelector("[id='txt_EndDate']").value = '';
        return;
    }

    // The date is YYYY-MM-DD, which is safe to parse
    const dateParts = dateValue.split('-');
    const year = parseInt(dateParts[0], 10);
    const month = parseInt(dateParts[1], 10) - 1; // JS months are 0-indexed
    const day = parseInt(dateParts[2], 10);

    // Extract start time from the time slot, e.g., "08:00 AM" from "Morning (08:00 AM - 12:00 PM)"
    const timeMatch = timeSlot.match(/(\d{1,2}:\d{2}\s*[AP]M)/);
    if (!timeMatch) {
        console.warn(`Could not extract start time from timeSlot: ${timeSlot}`);
        return;
    }
    const startTimeStr = timeMatch[0];

    // Parse the start time
    const timeParts = startTimeStr.match(/(\d+):(\d+)\s*([AP]M)/);
    let hours = parseInt(timeParts[1], 10);
    const minutes = parseInt(timeParts[2], 10);
    const modifier = timeParts[3];

    if (modifier === 'PM' && hours < 12) {
        hours += 12;
    }
    if (modifier === 'AM' && hours === 12) {
        hours = 0; // Midnight case
    }

    // Create the start date object
    const startDateTime = new Date(year, month, day, hours, minutes);

    if (isNaN(startDateTime.getTime())) {
        console.warn(`Invalid start date created for: ${dateValue} ${startTimeStr}`);
        return;
    }

    // Calculate end date
    const durationMinutes = (timerequired_Hour * 60) + timerequired_Minute;
    const endDateTime = new Date(startDateTime.getTime() + durationMinutes * 60000);

    // Reusable US date/time formatting function
    const formatToUSDateTime = (dt) => {
        if (isNaN(dt.getTime())) return '';
        const mo = (dt.getMonth() + 1).toString().padStart(2, '0');
        const d = dt.getDate().toString().padStart(2, '0');
        const y = dt.getFullYear();

        let h = dt.getHours();
        const m = dt.getMinutes().toString().padStart(2, '0');
        const ampm = h >= 12 ? 'PM' : 'AM';
        h = h % 12;
        h = h ? h : 12; // the hour '0' should be '12'

        return `${mo}/${d}/${y} ${h}:${m} ${ampm}`;
    };

    // Set the formatted values
    form.querySelector("[id='txt_StartDate']").value = formatToUSDateTime(startDateTime);
    form.querySelector("[id='txt_EndDate']").value = formatToUSDateTime(endDateTime);
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
    $('select[name="serviceTypeNew"], select[name="serviceTypeEdit"]').on('change', function () {
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
    
    // Only reset selectedForms for new appointments, not for editing
    if (mode === 'new') {
        selectedForms = [];
    }

    $('#formsSelectionModal').modal('show');
    loadAvailableForms();

    // Load currently selected forms if editing
    if (mode === 'edit') {
        // Add a small delay to ensure the modal is fully shown and forms are loaded
        setTimeout(() => {
            loadCurrentlySelectedForms();
        }, 200);
    }
}

// Load available forms
function loadAvailableForms() {
    $.ajax({
        type: "POST",
        url: "Forms.aspx/GetAllTemplates",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            if (response.d) {
                populateAvailableFormsList(response.d);
            }
        },
        error: function (xhr, status, error) {
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

// Update selected forms from form IDs array
function updateSelectedFormsFromIds(formIds) {
    console.log('updateSelectedFormsFromIds called with:', formIds);
    
    if (!formIds || !Array.isArray(formIds) || formIds.length === 0) {
        console.log('No form IDs provided, clearing selection');
        selectedForms = [];
        updateSelectedFormsList();
        return;
    }

    // Clear current selection
    selectedForms = [];
    
    // Uncheck all checkboxes first
    $('.form-check-input[type="checkbox"]').prop('checked', false);
    
    // Load available forms to get form names
    $.ajax({
        type: "POST",
        url: "Forms.aspx/GetAllTemplates",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            if (response.d) {
                const availableForms = response.d;
                
                // Match form IDs with available forms and update selectedForms array
                formIds.forEach(formId => {
                    const form = availableForms.find(f => f.Id === formId);
                    if (form) {
                        selectedForms.push({ id: form.Id, name: form.TemplateName });
                        // Check the corresponding checkbox - use setTimeout to ensure DOM is ready
                        setTimeout(() => {
                            $(`#form_${form.Id}`).prop('checked', true);
                        }, 100);
                    }
                });
                
                updateSelectedFormsList();
            }
        },
        error: function (xhr, status, error) {
            console.error('Error loading available forms for updateSelectedFormsFromIds:', error);
            // Fallback: just update the selectedForms array with IDs
            formIds.forEach(formId => {
                selectedForms.push({ id: formId, name: `Form ${formId}` });
            });
            updateSelectedFormsList();
        }
    });
}

// Load auto-assigned forms
function loadAutoAssignedForms(serviceType, isNewForm) {
    $.ajax({
        type: "POST",
        url: "Forms.aspx/GetAutoAssignedForms",
        data: JSON.stringify({ serviceType: serviceType }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
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
        error: function (xhr, status, error) {
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
                    <button type="button" class="btn btn-sm btn-link text-dark p-0 ms-1" 
                            onclick="removeFormFromAppointment(${form.id})">
                        <i class="fa fa-times"></i>
                    </button>
                </span>
            `);
            container.append(formBadge);
        });
        // Show form actions if we're in edit mode and have forms
        if (currentFormsModal === 'edit') {
            $('#formActionsContainer').show();
        }
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
        // Hide form actions if we're in edit mode and no forms left
        if (currentFormsModal === 'edit') {
            $('#formActionsContainer').hide();
        }
    }
}

// Open appointment forms modal
function openAppointmentFormsModal() {
    $('#formName').empty();
    $('#formViewerContainer').empty();
    $('#editModal').modal('hide');

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
    $("#loader").show();
    $.ajax({
        type: "POST",
        url: "Forms.aspx/GetAppointmentForms",
        data: JSON.stringify({ appointmentId: appointmentId }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            if (response.d) {
                $("#loader").hide();
                currentAppointmentForms = response.d;
                populateAppointmentFormsList(response.d);
            }
        },
        error: function (xhr, status, error) {
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
                 onclick="openFormForFilling(${form.TemplateId})">
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
function openFormForFilling(templateId) {
    GlobalTemplateId = templateId;
    $("#loader").show();
    $.ajax({
        type: "POST",
        url: "Appointments.aspx/GetFormStructure",
        data: JSON.stringify({ templateId: templateId }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            try {

                let formStructure = {};
                if (response && response.d !== undefined && response.d !== null) {
                    if (typeof response.d === "string") {
                        // try to parse string
                        try {
                            formStructure = JSON.parse(response.d);
                        } catch (parseErr) {
                            console.error("Failed to JSON.parse(response.d):", parseErr, "response.d:", response.d);
                            $('#formViewerContainer').html('<div class="drop-zone">Invalid form structure received from server</div>');
                            return;
                        }
                    } else {
                        $("#loader").hide();
                        // already an object
                        formStructure = response.d;
                    }
                } else {
                    console.warn("Empty response.d:", response);
                }

                console.log("Parsed formStructure:", formStructure);


                var formTemplateData = formStructure.FormStructure;


                if (typeof formTemplateData === "string") {
                    try {
                        formTemplateData = JSON.parse(formTemplateData);
                    } catch (e) {
                        console.error("Failed to parse FormStructure:", e);
                        formTemplateData = {};
                    }
                }
                $('#formViewerContainer').empty();
                $("#formName").text(formStructure.TemplateName);
                if (formTemplateData.fields && formTemplateData.fields.length > 0) {

                    // Load existing fields
                    formTemplateData.fields.forEach(function (field) {

                        const fieldHtml = generateFieldFromStructure(field);
                        $('#formViewerContainer').append(fieldHtml);
                    });
                } else {
                    // Show empty state
                    $('#formViewerContainer').html('<div class="drop-zone">Drag fields here to build your form</div>');
                }
            } catch (error) {
                console.error('Error parsing form structure:', error);
                $('#formViewerContainer').html('<div class="drop-zone">Drag fields here to build your form</div>');
            }
        },
        error: function (xhr, status, error) {
            console.error('Error loading form structure:', error);
            showAlert({
                icon: 'error',
                title: 'Error',
                text: 'Failed to load form structure',
                confirmButtonText: 'OK'
            });
            $('#formViewerContainer').html('<div class="drop-zone">Drag fields here to build your form</div>');
        }
    });
}
// Generate dropdown HTML from options
function generateDropdownHtml(options) {
    if (!options || options.length === 0) {
        return '<select class="form-control"><option>Option 1</option><option>Option 2</option></select>';
    }

    let html = '<select class="form-control">';
    options.forEach(option => {
        html += `<option value="${option.value || option}">${option.label || option}</option>`;
    });
    html += '</select>';
    return html;
}

// Generate radio button HTML from options
function generateRadioHtml(options, fieldId) {
    if (!options || options.length === 0) {
        return `<div class="form-check"><input type="radio" class="form-check-input" name="radio_${fieldId}"><label class="form-check-label">Option 1</label></div>`;
    }

    let html = '';
    options.forEach((option, index) => {
        html += `<div class="form-check">
            <input type="radio" class="form-check-input" name="radio_${fieldId}" value="${option.value || option}">
            <label class="form-check-label">${option.label || option}</label>
        </div>`;
    });
    return html;
}

function generateFieldFromStructure(field) {
    const fieldId = field.id || 'field_' + Date.now();
    const fieldType = field.type || 'text';
    const fieldLabel = field.label || 'Untitled Field';
    const isRequired = field.required || false;

    const fieldConfig = {
        text: { icon: 'fa-font', input: `<input type="text" class="form-control" placeholder="${field.placeholder || 'Enter text'}" ${field.defaultValue ? 'value="' + field.defaultValue + '"' : ''}>` },
        textarea: { icon: 'fa-align-left', input: `<textarea class="form-control" rows="3" placeholder="${field.placeholder || 'Enter text'}">${field.defaultValue || ''}</textarea>` },
        number: { icon: 'fa-hashtag', input: `<input type="number" class="form-control" placeholder="${field.placeholder || 'Enter number'}" ${field.defaultValue ? 'value="' + field.defaultValue + '"' : ''}>` },
        date: { icon: 'fa-calendar', input: `<input type="date" class="form-control" ${field.defaultValue ? 'value="' + field.defaultValue + '"' : ''}>` },
        dropdown: { icon: 'fa-caret-down', input: generateDropdownHtml(field.options) },
        checkbox: { icon: 'fa-check-square', input: `<div class="form-check"><input type="checkbox" class="form-check-input" ${field.defaultValue ? 'checked' : ''}><label class="form-check-label">${field.checkboxLabel || 'Check this option'}</label></div>` },
        radio: { icon: 'fa-dot-circle', input: generateRadioHtml(field.options, fieldId) },
        signature: { icon: 'fa-pencil', input: '<div class="signature-pad" style="border: 1px solid #ddd; height: 150px; display: flex; align-items: center; justify-content: center;">Signature Area</div>' }
    };

    const config = fieldConfig[fieldType] || fieldConfig.text;

    return `
        <div class="form-field" data-field-id="${fieldId}" data-field-type="${fieldType}" onclick="selectField('${fieldId}')">
            <div class="form-group">
                <label><i class="fa ${config.icon}"></i> ${fieldLabel}${isRequired ? ' *' : ''}</label>
                ${config.input}
            </div>
        </div>
    `;
}

function toggleUnscheduledSort(view) {

    unscheduledSortOrder = unscheduledSortOrder === 'asc' ? 'desc' : 'asc';


    const sortBtnId = view === 'resource' ? '#sortUnscheduledBtnResource' : '#sortUnscheduledBtn';
    const $sortBtn = $(sortBtnId);


    if ($sortBtn.length) {
        const $icon = $sortBtn.find('i');

        $icon.removeClass('fa-sort-amount-up fa-sort-amount-down');


        if (unscheduledSortOrder === 'asc') {
            $icon.addClass('fa-sort-amount-up');
        } else {
            $icon.addClass('fa-sort-amount-down');
        }
    }


    renderUnscheduledList(view);
}



// Load currently selected forms for edit mode
function loadCurrentlySelectedForms(appointmentId) {
    if (!appointmentId) {
        appointmentId = $('#AppoinmentId').val();
    }

    if (!appointmentId) {
        console.log('No appointment ID found for loadCurrentlySelectedForms');
        return;
    }
    
    console.log('Loading currently selected forms for appointment:', appointmentId);
    
    // First check if we have the appointment data locally
    const appointment = appointments.find(a => a.AppoinmentId == appointmentId);
    if (appointment && appointment.AttachedForms) {
        console.log('Found attached forms in local data:', appointment.AttachedForms);
        // If we have form IDs in the appointment data, use those
        updateSelectedFormsFromIds(appointment.AttachedForms);
        return;
    }
    $.ajax({
        type: "POST",
        url: "Forms.aspx/GetAppointmentForms",
        data: JSON.stringify({ appointmentId: appointmentId }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            if (response.d) {
                const container = $('#selectedFormsEdit');
                container.empty();

                if (response.d.length === 0) {
                    container.html('<small class="text-muted">No forms attached to this appointment</small>');
                } else {
                    // Update the selectedForms array
                    selectedForms = response.d.map(form => ({
                        id: form.Id,
                        name: form.TemplateName
                    }));
                    
                    // Check the corresponding checkboxes in the forms selection modal
                    response.d.forEach(form => {
                        $(`#form_${form.Id}`).prop('checked', true);
                    });
                    
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
                    // Show form actions if forms are attached
                    if (response.d.length > 0) {
                        $('#formActionsContainer').show();
                    }
                }
            }
        },
        error: function (xhr, status, error) {
            console.error('Error loading current forms:', error);
        }
    });
}

// Update attached forms for appointment
function updateAttachedForms() {
    const appointmentId = $('#AppoinmentId').val();
    var customerId = $('#CustomerID').val();

    if (!appointmentId) {
        showAlert({
            icon: 'error',
            title: 'Error',
            text: 'No appointment selected',
            confirmButtonText: 'OK'
        });
        return;
    }
    if (!customerId) {
        showAlert({
            icon: 'error',
            title: 'Error',
            text: 'No customer selected',
            confirmButtonText: 'OK'
        });
        return;
    }
    //if (selectedForms.length === 0) {
    //    showAlert({
    //        icon: 'warning',
    //        title: 'Warning',
    //        text: 'No forms selected to attach',
    //        confirmButtonText: 'OK'
    //    });
    //    return;
    //}
    const formIds = selectedForms.map(form => form.id);
    $.ajax({
        type: "POST",
        url: "Appointments.aspx/UpdateAttachedForms",
        data: JSON.stringify({
            appointmentId: appointmentId,
            customerId: customerId,
            formIds: formIds
        }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            if (response.d === true) {
                showAlert({
                    icon: 'success',
                    title: 'Success',
                    text: 'Forms have been attached to the appointment successfully!',
                    timer: 2000
                });
                // Update the appointment data locally
                const appointment = appointments.find(a => a.AppoinmentId == appointmentId);
                if (appointment) {
                    appointment.AttachedForms = formIds;
                }
            } else {
                showAlert({
                    icon: 'error',
                    title: 'Error',
                    text: 'Failed to update attached forms',
                    confirmButtonText: 'OK'
                });
            }
        },
        error: function (xhr, status, error) {
            showAlert({
                icon: 'error',
                title: 'Error',
                text: 'Failed to update attached forms: ' + error,
                confirmButtonText: 'OK'
            });
        }
    });
}

// Send forms via email
function sendFormsViaEmail() {
    const appointmentId = $('#AppoinmentId').val();
    if (!appointmentId) {
        showAlert({
            icon: 'error',
            title: 'Error',
            text: 'No appointment selected',
            confirmButtonText: 'OK'
        });
        return;
    }

    if (selectedForms.length === 0) {
        showAlert({
            icon: 'warning',
            title: 'Warning',
            text: 'No forms attached to send',
            confirmButtonText: 'OK'
        });
        return;
    }
    // Get customer email from the appointment
    const appointment = appointments.find(a => a.AppoinmentId == appointmentId);
    let customerEmail = appointment?.Email || '';
    // Prompt for email if not available
    if (!customerEmail) {
        customerEmail = prompt('Enter customer email address:');
        if (!customerEmail) return;
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(customerEmail)) {
        showAlert({
            icon: 'error',
            title: 'Invalid Email',
            text: 'Please enter a valid email address',
            confirmButtonText: 'OK'
        });
        return;
    }
    $.ajax({
        type: "POST",
        url: "Appointments.aspx/SendFormsViaEmail",
        data: JSON.stringify({
            appointmentId: appointmentId,
            customerEmail: customerEmail
        }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            if (response.d === true) {
                showAlert({
                    icon: 'success',
                    title: 'Email Sent',
                    text: `Forms have been sent to ${customerEmail} successfully!`,
                    timer: 3000
                });
            } else {
                showAlert({
                    icon: 'error',
                    title: 'Error',
                    text: 'Failed to send email',
                    confirmButtonText: 'OK'
                });
            }
        },
        error: function (xhr, status, error) {
            showAlert({
                icon: 'error',
                title: 'Error',
                text: 'Failed to send email: ' + error,
                confirmButtonText: 'OK'
            });
        }
    });
}

// Send forms via SMS
function sendFormsViaSMS() {
    const appointmentId = $('#AppoinmentId').val();
    if (!appointmentId) {
        showAlert({
            icon: 'error',
            title: 'Error',
            text: 'No appointment selected',
            confirmButtonText: 'OK'
        });
        return;
    }
    if (selectedForms.length === 0) {
        showAlert({
            icon: 'warning',
            title: 'Warning',
            text: 'No forms attached to send',
            confirmButtonText: 'OK'
        });
        return;
    }
    // Get customer phone from the appointment
    const appointment = appointments.find(a => a.AppoinmentId == appointmentId);
    let customerPhone = appointment?.CustomerPhone || appointment?.Mobile || '';
    // Prompt for phone if not available
    if (!customerPhone) {
        customerPhone = prompt('Enter customer phone number:');
        if (!customerPhone) return;
    }
    // Basic phone validation
    const phoneRegex = /^[\+]?[1-9][\d]{3,14}$/;
    if (!phoneRegex.test(customerPhone.replace(/[\s\-\(\)]/g, ''))) {
        showAlert({
            icon: 'error',
            title: 'Invalid Phone',
            text: 'Please enter a valid phone number',
            confirmButtonText: 'OK'
        });
        return;
    }
    $.ajax({
        type: "POST",
        url: "Appointments.aspx/SendFormsViaSMS",
        data: JSON.stringify({
            appointmentId: appointmentId,
            customerPhone: customerPhone
        }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            if (response.d === true) {
                showAlert({
                    icon: 'success',
                    title: 'SMS Sent',
                    text: `Form notification has been sent to ${customerPhone} successfully!`,
                    timer: 3000
                });
            } else {
                showAlert({
                    icon: 'error',
                    title: 'Error',
                    text: 'Failed to send SMS',
                    confirmButtonText: 'OK'
                });
            }
        },
        error: function (xhr, status, error) {
            showAlert({
                icon: 'error',
                title: 'Error',
                text: 'Failed to send SMS: ' + error,
                confirmButtonText: 'OK'
            });
        }
    });
}
// Handle all modal dismissals properly
$(document).on('hidden.bs.modal', '.modal', function () {
    $(this).find('form').trigger('reset');
    $(this).find('.is-invalid').removeClass('is-invalid');
    $(this).find('.invalid-feedback').remove();
});

// Specifically handle forms modal
$(document).on('click', '[data-dismiss="modal"]', function () {
    const modal = $(this).closest('.modal');
    modal.modal('hide');
});

// Handle escape key and backdrop clicks
$(document).on('keydown', function (e) {
    if (e.key === 'Escape') {
        $('.modal.show').modal('hide');
    }
});

$('.modal').on('click', function (e) {
    if ($(e.target).hasClass('modal')) {
        $(this).modal('hide');
    }
});
// Initialize forms integration when page loads
$(document).ready(function () {
    initializeFormsIntegration();
});


function syncDatePickers(changedPickerId, newDate) {
    if (isDateSyncing) {
        console.log('Date syncing already in progress, skipping...');
        return;
    }
    isDateSyncing = true;

    try {
        if (!newDate || isNaN(new Date(newDate))) {
            console.warn('Invalid date in syncDatePickers, using today');
            newDate = new Date().toISOString().split('T')[0];
        }
        console.log(`Syncing date pickers: changedPickerId=${changedPickerId}, newDate=${newDate}`);

        // This block handles the special case where a date *range* is selected in the list view.
        // It should remain as is.
        if (changedPickerId === '#listDatePickerFrom' || changedPickerId === '#listDatePickerTo') {
            const fromDate = $("#listDatePickerFrom").val();
            const toDate = $("#listDatePickerTo").val();

            if (fromDate && toDate) {
                $("#resourceDatePickerFrom").val(fromDate);
                $("#resourceDatePickerTo").val(toDate);
                $("#resourceViewSelect").val('custom');
                $("#resourceCustomDateRangeContainer").removeClass('d-none');

                resourceCustomDateRange.from = fromDate;
                resourceCustomDateRange.to = toDate;

                if (currentView === "resource") {
                    renderResourceView(fromDate);
                }
            }
        }
        // This block handles all single date picker changes.
        else {
            ['#dayDatePicker', '#resourceDatePicker', '#mapDatePicker', '#listDatePicker'].forEach(pickerId => {
                // Update the value of all other date pickers to match the one that was changed.
                if (pickerId !== changedPickerId) {
                    $(pickerId).val(newDate);
                }
            });
        }

        // Set the global current date.
        currentDate = new Date(newDate);

        // This is the crucial part: After any date change, we must determine which view is
        // currently active and re-render it along with its specific date navigation.
        switch (currentView) {
            case "date":
                renderDateView(newDate);
                break;
            case "resource":
                // For the resource view, it's essential to re-render both the view
                // and its date navigation bar to keep them in sync.
                renderResourceView(newDate);
                renderDateNav('resourceNav', newDate); // Explicitly call renderDateNav for the resource view
                break;
            case "map":
                renderMapView(newDate); // The map view doesn't have a complex date nav, so just re-render the map.
                break;
            case "list":
                renderListView(); // The list view's rendering is handled by its own function.
                break;
            default:
                console.warn(`Unknown currentView: ${currentView}`);
        }
    } catch (error) {
        console.error('Error syncing date pickers:', error);
    } finally {
        // Release the lock to allow the next sync operation.
        isDateSyncing = false;
        console.log('Date syncing completed');
    }
}


// Update the DOMContentLoaded event listener to handle the initial sync
document.addEventListener("DOMContentLoaded", function () {
    const resourceFrom = document.getElementById("resourceDatePickerFrom");
    const resourceTo = document.getElementById("resourceDatePickerTo");
    const listFrom = document.getElementById("listDatePickerFrom");
    const listTo = document.getElementById("listDatePickerTo");

    // Helper function to sync dates and trigger appropriate actions
    function syncDates(source, target, isFromDate) {
        source.addEventListener("change", () => {
            // Update the corresponding field
            target.value = source.value;

            // If we're updating from list view to resource view
            if (source === listFrom || source === listTo) {
                const fromDate = $("#listDatePickerFrom").val();
                const toDate = $("#listDatePickerTo").val();

                if (fromDate && toDate) {
                    // Set resource view to custom mode
                    $("#resourceViewSelect").val('custom');
                    $("#resourceCustomDateRangeContainer").removeClass('d-none');

                    // Update the resource view's custom date range
                    resourceCustomDateRange.from = fromDate;
                    resourceCustomDateRange.to = toDate;

                    // If we're in resource view, trigger the search
                    if (currentView === "resource") {
                        renderResourceView(fromDate);
                    }
                }
            }
        });
    }

    // Sync both directions
    syncDates(resourceFrom, listFrom, true);
    syncDates(listFrom, resourceFrom, true);
    syncDates(resourceTo, listTo, false);
    syncDates(listTo, resourceTo, false);
});


function loadCustomerDataForModal(appointmentId) {
    const appointment = appointments.find(a => a.AppoinmentId === appointmentId.toString());
    if (!appointment || !appointment.CustomerID) {
        console.warn('No customer data found for appointment:', appointmentId);

        populateCustomerDataTab(null);
        return;
    }
    const siteId = appointment.SiteId || "0";

    $.ajax({
        type: "POST",
        url: "Appointments.aspx/GetCustomerDetailsForModal",
        data: JSON.stringify({
            customerId: appointment.CustomerID.toString(),
            siteId: siteId.toString()
        }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            if (response.d && response.d.Success) {
                const customerData = response.d;
                populateCustomerDataTab(customerData);
            } else {
                console.error('Failed to load customer data:', response.d?.Error || 'Unknown error');
                populateCustomerDataTab(null);
            }
        },
        error: function (xhr, status, error) {
            console.error('Error loading customer data:', error);
            populateCustomerDataTab(null);
        }
    });
}


// Populate customer data tab in the modal
function populateCustomerDataTab(customerData) {
    // Update the customer data tab content
    const customerDataTab = document.getElementById('customer-data');
    if (!customerDataTab) {
        console.error('Customer data tab not found');
        return;
    }

    // Update the table content
    const customerNameCell = customerDataTab.querySelector('#customerName');
    const siteContactCell = customerDataTab.querySelector('#siteContact');
    const customerEmailCell = customerDataTab.querySelector('#customerEmail');
    const siteAddressCell = customerDataTab.querySelector('#siteAddress');
    const siteStatusCell = customerDataTab.querySelector('#siteStatus');
    const siteInstructionsCell = customerDataTab.querySelector('#siteInstructions');
    const siteDescriptionCell = customerDataTab.querySelector('#siteDescription');

    if (customerNameCell) {
        customerNameCell.innerHTML = customerData.CustomerName || 'N/A';
    }

    if (siteContactCell) {
        const contactHtml = `
            ${customerData.Contact || 'N/A'}<br />
            <i class="fas fa-phone me-1" style="font-size: 13px;"></i>Phone:
            <a href="${customerData.PhoneLink || '#'}">${customerData.Phone || 'N/A'}</a><br />
            <i class="fas fa-mobile-alt me-1"></i>Mobile:
            <a href="${customerData.MobileLink || '#'}">${customerData.Mobile || 'N/A'}</a>
        `;
        siteContactCell.innerHTML = contactHtml;
    }

    if (customerEmailCell) {
        const emailHtml = `<a href="${customerData.EmailLink || '#'}">${customerData.Email || 'N/A'}</a>`;
        customerEmailCell.innerHTML = emailHtml;
    }

    if (siteAddressCell) {
        siteAddressCell.innerHTML = customerData.Address || 'N/A';
    }

    if (siteStatusCell) {
        siteStatusCell.innerHTML = customerData.Status || 'N/A';
    }

    if (siteInstructionsCell) {
        siteInstructionsCell.innerHTML = customerData.Note || 'N/A';
    }

    if (siteDescriptionCell) {
        siteDescriptionCell.innerHTML = customerData.CreatedOn || 'N/A';
    }
}

// Pagination functions for list view
function updateListViewPagination() {
    const totalItems = listViewFilteredAppointments.length;
    listViewTotalPages = Math.ceil(totalItems / listViewPageSize);

    // Ensure current page is within bounds
    if (listViewCurrentPage > listViewTotalPages) {
        listViewCurrentPage = listViewTotalPages || 1;
    }

    // Update pagination controls
    const pageInfo = document.getElementById('listViewPageInfo');
    const prevBtn = document.getElementById('listViewPrevPage');
    const nextBtn = document.getElementById('listViewNextPage');
    const pageSizeSelect = document.getElementById('listViewPageSize');

    if (pageInfo) {
        const startItem = (listViewCurrentPage - 1) * listViewPageSize + 1;
        const endItem = Math.min(listViewCurrentPage * listViewPageSize, totalItems);
        pageInfo.textContent = `Showing ${startItem}-${endItem} of ${totalItems} appointments`;
    }

    if (prevBtn) {
        prevBtn.classList.toggle('disabled', listViewCurrentPage <= 1);
    }

    if (nextBtn) {
        nextBtn.classList.toggle('disabled', listViewCurrentPage >= listViewTotalPages);
    }

    if (pageSizeSelect) {
        pageSizeSelect.value = listViewPageSize;
    }
}

function goToListViewPage(page) {
    if (page < 1 || page > listViewTotalPages) return;

    listViewCurrentPage = page;
    renderListViewTable();
    updateListViewPagination();
}

function changeListViewPageSize() {
    const pageSizeSelect = document.getElementById('listViewPageSize');
    if (pageSizeSelect) {
        listViewPageSize = parseInt(pageSizeSelect.value);
        listViewCurrentPage = 1; // Reset to first page
        renderListViewTable();
        updateListViewPagination();
    }
}

function renderListViewTable() {
    const tbody = $("#listTableBody");
    const startIndex = (listViewCurrentPage - 1) * listViewPageSize;
    const endIndex = startIndex + listViewPageSize;
    const pageAppointments = listViewFilteredAppointments.slice(startIndex, endIndex);

    if (pageAppointments.length === 0) {
        tbody.html('<tr><td colspan="13" class="text-center">No appointments found.</td></tr>');
        return;
    }

    tbody.html(pageAppointments.map(a => {
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
                <td data-label="Address">${a.SiteAddress || a.Address1 || 'N/A'}</td>
                  <td data-label="Request Date">${formatToUSDate(a.RequestDate)}</td>
                <td data-label="Time Slot">${formatTimeRange(timeSlot) || 'N/A'}</td>
                <td data-label="Service Type">${a.ServiceType || 'N/A'}</td>
                <td data-label="Email" class="custom-link">${a.Email ? `<a href="mailto:${a.Email}">${a.Email}</a>` : 'N/A'}</td>
                <td data-label="Mobile" class="custom-link">${a.Mobile ? `<a href="tel:${a.Mobile}">${a.Mobile}</a>` : 'N/A'}</td>
                <td data-label="Phone" class="custom-link">${a.Phone ? `<a href="tel:${a.Phone}">${a.Phone}</a>` : 'N/A'}</td>
                <td data-label="Appointment Status">${a.AppoinmentStatus || 'N/A'}</td>
                <td data-label="Resource">${a.ResourceName || 'N/A'}</td>
              <td data-label="Ticket Status">${a.TicketStatus && a.TicketStatus !== 'Unknown' ? a.TicketStatus : 'N/A'}</td>
            </tr>
        `;
    }).join(''));

    // Rebind click handlers
    $(document).off('click', '.view-appointment').on('click', '.view-appointment', function () {
        const appointmentId = $(this).data("id");
        openEditModal(appointmentId);
    });
}

// Pagination functions for resource view
function updateResourceViewPagination() {
    const totalItems = resourceViewFilteredAppointments.length;
    resourceViewTotalPages = Math.ceil(totalItems / resourceViewPageSize);

    // Ensure current page is within bounds
    if (resourceViewCurrentPage > resourceViewTotalPages) {
        resourceViewCurrentPage = resourceViewTotalPages || 1;
    }

    // Update pagination controls
    const pageInfo = document.getElementById('resourceViewPageInfo');
    const prevBtn = document.getElementById('resourceViewPrevPage');
    const nextBtn = document.getElementById('resourceViewNextPage');
    const pageSizeSelect = document.getElementById('resourceViewPageSize');

    if (pageInfo) {
        const startItem = (resourceViewCurrentPage - 1) * resourceViewPageSize + 1;
        const endItem = Math.min(resourceViewCurrentPage * resourceViewPageSize, totalItems);
        pageInfo.textContent = `Showing ${startItem}-${endItem} of ${totalItems} resources`;
    }

    if (prevBtn) {
        prevBtn.classList.toggle('disabled', resourceViewCurrentPage <= 1);
    }

    if (nextBtn) {
        nextBtn.classList.toggle('disabled', resourceViewCurrentPage >= resourceViewTotalPages);
    }

    if (pageSizeSelect) {
        pageSizeSelect.value = resourceViewPageSize;
    }
}

function goToResourceViewPage(page) {
    if (page < 1 || page > resourceViewTotalPages) return;

    resourceViewCurrentPage = page;
    renderResourceViewTable();
    updateResourceViewPagination();
}

function changeResourceViewPageSize() {
    const pageSizeSelect = document.getElementById('resourceViewPageSize');
    if (pageSizeSelect) {
        resourceViewPageSize = parseInt(pageSizeSelect.value);
        resourceViewCurrentPage = 1; // Reset to first page
        renderResourceViewTable();
        updateResourceViewPagination();
    }
}

function renderResourceViewTable() {
    const startIndex = (resourceViewCurrentPage - 1) * resourceViewPageSize;
    const endIndex = startIndex + resourceViewPageSize;
    const pageResources = resourceViewFilteredAppointments.slice(startIndex, endIndex);

    // Re-render the resource view with paginated data
    renderResourceView($("#resourceDatePicker").val());
}

function openCustomerResponseModal() {
    $('#customerResponseModal').modal('show');
    openFormForFillingForCustomerResponse(GlobalTemplateId);
    $('#appointmentFormsModal').modal('hide');
}

function openFormForFillingForCustomerResponse(templateId) {
    if (!templateId) {
        showAlert({
            icon: 'warning',
            title: 'Form Not Selected.',
            text: 'Please select a form',
            timer: 3000
        });
    }
    GlobalTemplateId = templateId;
    var apptId = $('#AppoinmentId').val();
    var cId = $('#CustomerID').val();
    $.ajax({
        type: "POST",
        url: "Appointments.aspx/GetCustomerResponseOnForms",
        data: JSON.stringify({
            templateId: templateId,
            appointmentId: apptId,
            customerId: cId
        }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            try {
                let formStructure = {};
                if (response && response.d !== undefined && response.d !== null) {
                    if (typeof response.d === "string") {
                        // try to parse string
                        try {
                            formStructure = JSON.parse(response.d);
                        } catch (parseErr) {
                            console.error("Failed to JSON.parse(response.d):", parseErr, "response.d:", response.d);
                            $('#formViewerContainer').html('<div class="drop-zone">Invalid form structure received from server</div>');
                            return;
                        }
                    } else {
                        // already an object
                        formStructure = response.d;
                    }
                } else {
                    console.warn("Empty response.d:", response);
                }

                console.log("Parsed formStructure:", formStructure);


                var formTemplateData = formStructure;
                $('#customerResponseContainer').empty();
                if (formTemplateData && formTemplateData.length > 0) {
                    formTemplateData.forEach(function (field) {

                        // Generate field HTML using your existing generator
                        const fieldHtml = generateFieldFromStructure({
                            id: field.fieldId,
                            type: field.type,
                            label: field.label
                        });

                        // Append the HTML to the container
                        $('#customerResponseContainer').append(fieldHtml);

                        // Now bind the saved value
                        const fieldWrapper = $(`[data-field-id="${field.fieldId}"]`);

                        switch (field.type) {
                            case 'text':
                            case 'number':
                            case 'date':
                                fieldWrapper.find('input').val(field.value || '');
                                break;

                            case 'textarea':
                                fieldWrapper.find('textarea').val(field.value || '');
                                break;

                            case 'dropdown':
                                fieldWrapper.find('select').val(field.value || '');
                                break;

                            case 'checkbox':
                                fieldWrapper.find('input[type="checkbox"]').prop('checked', field.value === true || field.value === "true");
                                break;

                            case 'radio':
                                fieldWrapper.find(`input[type="radio"][value="${field.value}"]`).prop('checked', true);
                                break;

                            case 'signature':
                                fieldWrapper.find('.signature-pad').text(field.value || 'Signature Area');
                                break;
                        }

                    });
                } else {
                    // Show empty state
                    $('#customerResponseContainer').html('<div class="drop-zone">Drag fields here to build your form</div>');
                }
            } catch (error) {
                console.error('Error parsing form structure:', error);
                $('#customerResponseContainer').html('<div class="drop-zone">Drag fields here to build your form</div>');
            }
        },
        error: function (xhr, status, error) {
            console.error('Error loading form structure:', error);
            showAlert({
                icon: 'error',
                title: 'Error',
                text: 'Failed to load form structure',
                confirmButtonText: 'OK'
            });
            $('#customerResponseContainer').html('<div class="drop-zone">Drag fields here to build your form</div>');
        }
    });
}
function showAppointmentModalFromResponseClose() {
    $('#appointmentFormsModal').modal('show');
    openFormForFilling(GlobalTemplateId);
}
function openAppointmentModal() {
    $('#editModal').modal('show');
}
function getFormStatusClass(status) {
    switch (status?.toLowerCase()) {
        case 'completed': return 'text-success';
        case 'inprogress': return 'text-info';
        case 'submitted': return 'text-primary';
        default: return 'text-warning';
    }
}

