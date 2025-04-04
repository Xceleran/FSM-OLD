<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="FSM.Dashboard" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
      

        .dashboard-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
            flex-wrap: wrap;
            gap: 16px;
        }

            .dashboard-header h1 {
                font-size: 28px;
                font-weight: 700;
                color: #f84700;
            }

        .header-actions {
            display: flex;
            gap: 12px;
        }

        .search-bar {
            padding: 10px 16px;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            width: 250px;
            max-width: 100%;
            background: #fff;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
        }

        .primary-btn, .secondary-btn {
            padding: 10px 20px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            transition: background 0.2s;
        }

        .primary-btn {
            background-color: #1e40af;
            color: #fff;
        }

            .primary-btn:hover {
                background-color: #1e3a8a;
            }

        .secondary-btn {
            background-color: #e5e7eb;
            color: #4b5563;
        }

            .secondary-btn:hover {
                background-color: #d1d5db;
            }

        .job-summary {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-bottom: 24px;
        }

        .summary-card {
            background-color: #fff;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.05);
            cursor: pointer;
            transition: transform 0.2s;
        }

            .summary-card:hover {
                transform: translateY(-2px);
            }

            .summary-card h3 {
                font-size: 14px;
                color: #6b7280;
                text-transform: uppercase;
            }

        .metric {
            font-size: 36px;
            font-weight: 700;
            margin: 12px 0;
            color: #1e40af;
        }

        .trend {
            font-size: 12px;
            font-weight: 500;
        }

            .trend.up {
                color: #15803d;
            }

            .trend.down {
                color: #c53030;
            }

            .trend.neutral {
                color: #6b7280;
            }

        .calendar-section {
            display: flex;
            gap: 20px;
            margin-bottom: 24px;
        }

        .technician-list, .calendar-view {
            background-color: #fff;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.05);
        }

        .technician-list {
            width: 200px;
            flex-shrink: 0;
        }

        .calendar-view {
            flex-grow: 1;
        }

        h2 {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 16px;
            color: #1e40af;
        }

        #techList {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .tech-item {
            padding: 12px;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: background 0.2s;
        }

            .tech-item:hover {
                background: #f9fafb;
            }

            .tech-item.active {
                background: #dbeafe;
                border-color: #1e40af;
            }

        .calendar-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 16px;
            flex-wrap: wrap;
        }

            .calendar-header select {
                padding: 8px 12px;
                border: 1px solid #d1d5db;
                border-radius: 8px;
                font-size: 14px;
                background: #fff;
            }

        #calendarRange {
            font-weight: 600;
            color: #1e40af;
        }

        .calendar-content {
            font-size: 14px;
            overflow-x: auto;
        }

        .day-view, .month-view {
            display: none;
        }

            .day-view.active, .month-view.active {
                display: block;
            }

        .resource-grid, .date-grid {
            display: grid;
            gap: 4px;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            background: #fff;
        }

        .resource-grid {
            grid-template-columns: 1fr;
        }

        .date-header {
            background: #f3f4f6;
            padding: 12px;
            font-weight: 600;
            font-size: 14px;
            color: #6b7280;
            border-bottom: 1px solid #e5e7eb;
            text-align: center;
        }

        .resource-cell, .date-cell {
            padding: 12px;
            border-bottom: 1px solid #e5e7eb;
            min-height: 60px;
            position: relative;
        }

        .job-card {
            background: #dbeafe;
            padding: 8px;
            border-radius: 6px;
            margin-bottom: 4px;
            font-size: 12px;
            transition: transform 0.2s;
        }

            .job-card:hover {
                transform: translateY(-2px);
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            }

            .job-card.completed {
                background: #bbf7d0;
                color: #15803d;
            }

            .job-card.in-progress {
                background: #fed7aa;
                color: #c2410c;
            }

            .job-card.pending {
                background: #bfdbfe;
                color: #1e40af;
            }

        .date-grid {
            grid-template-columns: repeat(7, 1fr);
            min-width: 700px;
        }

        .date-cell {
            min-height: 100px;
            overflow-y: auto;
        }

        .split-section {
            display: grid;
            grid-template-columns: 2fr 2fr;
            gap: 20px;
        }

        .recent-activity, .notifications {
            background-color: #fff;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.05);
        }

        ul {
            list-style: none;
        }

            ul li {
                padding: 12px 0;
                display: flex;
                align-items: center;
            }

        .status {
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12px;
            margin-right: 12px;
            font-weight: 500;
        }

            .status.completed {
                background-color: #bbf7d0;
                color: #15803d;
            }

            .status.in-progress {
                background-color: #fed7aa;
                color: #c2410c;
            }

            .status.pending {
                background-color: #bfdbfe;
                color: #1e40af;
            }

        .alert {
            margin-right: 12px;
            padding: 0px;
            margin-bottom: 0px;
        }

        /* Responsive */
        @media (max-width: 1024px) {
            .calendar-section {
                flex-direction: column;
            }

            .technician-list {
                width: 100%;
            }

            .split-section {
                grid-template-columns: 1fr;
            }

            .date-grid {
                grid-template-columns: repeat(4, 1fr);
            }
        }

        @media (max-width: 768px) {
            .dashboard-header {
                flex-direction: column;
                align-items: flex-start;
            }

            .header-actions {
                width: 100%;
                flex-direction: column;
            }

            .search-bar {
                width: 100%;
            }

            .job-summary {
                grid-template-columns: 1fr;
            }

            .date-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }
    </style>
    <main class="main-content">
        <header class="dashboard-header mt-3">
            <h1>Dashboard</h1>
            <div class="header-actions">
                <input type="text" placeholder="Search..." class="search-bar" id="searchBar">
                <button type="button" class="primary-btn" id="newWorkOrderBtn">+ New Work Order</button>
            </div>
        </header>

        <!-- Job Summary -->
        <section class="job-summary">
            <div class="summary-card" data-status="completed">
                <h3>Completed Jobs</h3>
                <p class="metric" id="completedJobs">12</p>
                <span class="trend up">+2 today</span>
            </div>
            <div class="summary-card" data-status="in-progress">
                <h3>In Progress</h3>
                <p class="metric" id="inProgressJobs">8</p>
                <span class="trend down">-1 today</span>
            </div>
            <div class="summary-card" data-status="pending">
                <h3>Pending Jobs</h3>
                <p class="metric" id="pendingJobs">5</p>
                <span class="trend neutral">No change</span>
            </div>
        </section>

        <!-- Calendar & Technicians -->
        <section class="calendar-section">
            <div class="technician-list">
                <h2>Technicians</h2>
                <div id="techList">
                    <!-- Populated via JS -->
                </div>
            </div>
            <div class="calendar-view">
                <h2>Schedule</h2>
                <div class="calendar-header">
                    <select id="viewMode">
                        <option value="day">Day View</option>
                        <option value="month">Month View</option>
                    </select>
                    <button type="button" class="secondary-btn" id="prevBtn">◄</button>
                    <span id="calendarRange">March 13, 2025</span>
                    <button type="button" class="secondary-btn" id="nextBtn">►</button>
                </div>
                <div class="calendar-content" id="calendarContent">
                    <!-- Populated via JS -->
                </div>
            </div>
        </section>

        <!-- Activity & Notifications -->
        <div class="split-section">
            <section class="recent-activity">
                <h2>Recent Activity</h2>
                <ul id="activityList">
                    <!-- Populated via JS -->
                </ul>
            </section>
            <section class="notifications">
                <h2>Notifications</h2>
                <ul id="notificationList">
                    <!-- Populated via JS -->
                </ul>
            </section>
        </div>
    </main>
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            // Sample Data
            const jobs = [
                { id: '123', customer: 'John Doe', site: 'Main Residence', status: 'completed', date: '2025-03-13', description: 'HVAC Maintenance', tech: 'Tech A' },
                { id: '124', customer: 'ABC Property Mgmt', site: 'Property A', status: 'in-progress', date: '2025-03-13', description: 'Plumbing Repair', tech: 'Tech B' },
                { id: '125', customer: 'Jane Smith', site: 'Office', status: 'pending', date: '2025-03-13', description: 'Electrical Check', tech: 'Tech C' },
                { id: '126', customer: 'XYZ Corp', site: 'Warehouse', status: 'pending', date: '2025-03-14', description: 'Lighting Install', tech: 'Tech A' },
                { id: '127', customer: 'Mike Ross', site: 'Storefront', status: 'in-progress', date: '2025-03-15', description: 'AC Repair', tech: 'Tech B' }
            ];

            const technicians = ['View All', 'Tech A', 'Tech B', 'Tech C'];
            let currentDate = new Date('2025-03-13');

            const activities = [
                { status: 'completed', text: 'Job #123 by Tech A', time: '10:30 AM' },
                { status: 'in-progress', text: 'Job #124 by Tech B', time: '10:15 AM' },
                { status: 'pending', text: 'Job #125 assigned', time: '9:45 AM' }
            ];

            const notifications = [
                { text: 'Pending Payment: Invoice #001', type: 'warning', icon: '⚠️' },
                { text: 'New Job Request: Customer X', type: 'info', icon: '📥' }
            ];

            // New Work Order Button
            document.getElementById('newWorkOrderBtn').addEventListener('click', () => {
                alert('Opening New Work Order form...');
            });

            // Search Functionality
            const searchBar = document.getElementById('searchBar');
            searchBar.addEventListener('input', (e) => {
                const query = e.target.value.toLowerCase();
                filterActivities(query);
                filterNotifications(query);
                updateCalendar();
            });

            // Job Summary Interaction
            document.querySelectorAll('.summary-card').forEach(card => {
                card.addEventListener('click', () => {
                    const status = card.dataset.status;
                    filterActivities('', status);
                    updateCalendar(status);
                });
            });

            // Technician List
            function renderTechnicians() {
                const techList = document.getElementById('techList');
                techList.innerHTML = '';
                technicians.forEach(tech => {
                    const div = document.createElement('div');
                    div.className = 'tech-item';
                    div.textContent = tech;
                    div.addEventListener('click', () => {
                        document.querySelectorAll('.tech-item').forEach(t => t.classList.remove('active'));
                        div.classList.add('active');
                        updateCalendar(null, tech === 'View All' ? null : tech);
                    });
                    techList.appendChild(div);
                });
                document.querySelector('.tech-item').classList.add('active'); // Default to "View All"
            }

            // Calendar
            document.getElementById('viewMode').addEventListener('change', updateCalendar);
            document.getElementById('prevBtn').addEventListener('click', () => {
                const view = document.getElementById('viewMode').value;
                if (view === 'day') {
                    currentDate.setDate(currentDate.getDate() - 1);
                } else {
                    currentDate.setMonth(currentDate.getMonth() - 1);
                }
                updateCalendar();
            });

            document.getElementById('nextBtn').addEventListener('click', () => {
                const view = document.getElementById('viewMode').value;
                if (view === 'day') {
                    currentDate.setDate(currentDate.getDate() + 1);
                } else {
                    currentDate.setMonth(currentDate.getMonth() + 1);
                }
                updateCalendar();
            });

            function updateCalendar(statusFilter = null, techFilter = null) {
                const view = document.getElementById('viewMode').value;
                const content = document.getElementById('calendarContent');
                const dateStr = currentDate.toISOString().slice(0, 10);
                document.getElementById('calendarRange').textContent = view === 'day'
                    ? currentDate.toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })
                    : currentDate.toLocaleDateString('en-US', { month: 'long', year: 'numeric' });

                content.innerHTML = `
            <div class="day-view ${view === 'day' ? 'active' : ''}"></div>
            <div class="month-view ${view === 'month' ? 'active' : ''}"></div>
        `;

                const filteredJobs = jobs.filter(job => {
                    const matchesStatus = !statusFilter || job.status === statusFilter;
                    const matchesTech = !techFilter || job.tech === techFilter;
                    const query = searchBar.value.toLowerCase();
                    const matchesQuery = !query ||
                        job.id.includes(query) ||
                        job.customer.toLowerCase().includes(query) ||
                        job.description.toLowerCase().includes(query);
                    return matchesStatus && matchesTech && matchesQuery;
                });

                if (view === 'day') {
                    const grid = content.querySelector('.day-view');
                    grid.innerHTML = '<div class="resource-grid"></div>';
                    const resourceGrid = grid.querySelector('.resource-grid');
                    const dayJobs = filteredJobs.filter(j => j.date === dateStr);
                    resourceGrid.innerHTML = `
                <div class="resource-cell">
                    ${dayJobs.map(j => `<div class="job-card ${j.status}" data-id="${j.id}">#${j.id} - ${j.description} (${j.tech})</div>`).join('')}
                </div>
            `;
                } else if (view === 'month') {
                    const grid = content.querySelector('.month-view');
                    grid.className = 'month-view active date-grid';
                    const year = currentDate.getFullYear();
                    const month = currentDate.getMonth();
                    const firstDay = new Date(year, month, 1).getDay(); // 0 = Sunday
                    const daysInMonth = new Date(year, month + 1, 0).getDate();

                    // Headers
                    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                    grid.innerHTML = days.map(day => `<div class="date-header">${day}</div>`).join('');

                    // Fill empty cells before the first day
                    for (let i = 0; i < firstDay; i++) {
                        grid.innerHTML += '<div class="date-cell empty"></div>';
                    }

                    // Fill all days of the month
                    for (let day = 1; day <= daysInMonth; day++) {
                        const date = new Date(year, month, day).toISOString().slice(0, 10);
                        const dayJobs = filteredJobs.filter(j => j.date === date);
                        const isToday = date === new Date().toISOString().slice(0, 10); // Highlight today
                        grid.innerHTML += `
                    <div class="date-cell ${isToday ? 'today' : ''}">
                        <div class="day-number">${day}</div>
                        ${dayJobs.map(j => `<div class="job-card ${j.status}" data-id="${j.id}">#${j.id} - ${j.description} (${j.tech})</div>`).join('')}
                    </div>
                `;
                    }

                    // Fill remaining cells to complete the grid (up to 6 rows max)
                    const totalCellsFilled = firstDay + daysInMonth;
                    const remainingCells = (Math.ceil(totalCellsFilled / 7) * 7) - totalCellsFilled;
                    for (let i = 0; i < remainingCells; i++) {
                        grid.innerHTML += '<div class="date-cell empty"></div>';
                    }
                }

                document.querySelectorAll('.job-card').forEach(card => {
                    card.addEventListener('click', () => {
                        const job = jobs.find(j => j.id === card.dataset.id);
                        alert(`Job #${job.id}\nCustomer: ${job.customer}\nSite: ${job.site}\nTech: ${job.tech}\nStatus: ${job.status}`);
                    });
                });
            }

            // Recent Activity
            function renderActivities(activityData) {
                const activityList = document.getElementById('activityList');
                activityList.innerHTML = '';
                activityData.forEach(activity => {
                    const li = document.createElement('li');
                    li.innerHTML = `<span class="status ${activity.status}">${activity.status.replace('-', ' ').replace(/\b\w/g, l => l.toUpperCase())}</span> ${activity.text} - ${activity.time}`;
                    activityList.appendChild(li);
                });
            }

            function filterActivities(query, statusFilter = '') {
                const filtered = activities.filter(a =>
                    (a.text.toLowerCase().includes(query) || a.time.toLowerCase().includes(query)) &&
                    (!statusFilter || a.status === statusFilter)
                );
                renderActivities(filtered);
            }

            // Notifications
            function renderNotifications(notificationData) {
                const notificationList = document.getElementById('notificationList');
                notificationList.innerHTML = '';
                notificationData.forEach(note => {
                    const li = document.createElement('li');
                    li.innerHTML = `<span class="alert">${note.icon}</span> ${note.text}`;
                    notificationList.appendChild(li);
                });
            }

            function filterNotifications(query) {
                const filtered = notifications.filter(n => n.text.toLowerCase().includes(query));
                renderNotifications(filtered);
            }

            function addNotification(message, type = 'info', icon = '📢') {
                notifications.unshift({ text: message, type, icon });
                renderNotifications(notifications.slice(0, 5));
            }

            // Initial Rendering
            renderTechnicians();
            updateCalendar();
            renderActivities(activities);
            renderNotifications(notifications);

            // Simulate Real-time Updates
            setTimeout(() => addNotification('Job #126 scheduled for Tech C'), 3000);
            setInterval(() => {
                const completed = parseInt(document.getElementById('completedJobs').textContent);
                if (Math.random() > 0.7) {
                    document.getElementById('completedJobs').textContent = completed + 1;
                    document.querySelector('.summary-card[data-status="completed"] .trend').textContent = `+${completed + 1 - 12} today`;
                }
            }, 10000);
        });
    </script>
</asp:Content>
