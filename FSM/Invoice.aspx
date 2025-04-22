<%@ Page Title="Invoices" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="Invoice.aspx.cs" Inherits="FSM.Invoice" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .invoice-container {
            padding: 20px;
            margin-top: 50px;
        }

        .invoice-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }

        .page-title {
            font-size: 24px;
            font-weight: bold;
            color: #f84700;
        }

        .invoice-table th {
            background: #f3f4f6;
            color: #010101;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 12px;
            padding: 12px;
            text-align: left;
        }

        .invoice-table td {
            padding: 12px;
            border-bottom: 1px solid #e5e7eb;
            color: #1f2937;
        }

        .invoice-table tbody tr:hover {
            background: #f9fafb;
        }

        .btn-bluelight {
            background-color: #4d78b1;
            color: #fff;
            margin-right: 5px;
        }

            .btn-bluelight:hover {
                background-color: #3b5e8c;
                color: #fff;
            }

        .filter-section {
            margin-bottom: 20px;
        }

        .card-custom {
            border: 1px solid #ccc;
            border-radius: 8px;
            padding: 15px;
            background: #fff;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }

        .status-icon-paid {
            color: #28a745;
            font-size: 14px;
        }

        .status-icon-due {
            color: #dc3545;
            font-size: 14px;
        }

        .action-buttons {
            display: flex;
            gap: 5px;
        }

        @media (max-width: 768px) {
            .invoice-container {
                padding: 10px;
                margin-top: 20px;
            }

            .filter-section .col-md-2 {
                flex: 0 0 50%;
                max-width: 50%;
            }
        }

        @media (max-width: 576px) {
            .filter-section .col-md-2 {
                flex: 0 0 100%;
                max-width: 100%;
            }
        }
    </style>

    <!-- Ensure DataTables CSS/JS are included -->
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.11.3/css/dataTables.bootstrap5.min.css" />
    <script src="https://cdn.datatables.net/1.11.3/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.11.3/js/dataTables.bootstrap5.min.js"></script>


    <div class="invoice-container">
        <header class="mb-4">
            <div class="row align-items-center">
                <div class="col-md-6">
                    <h1 class="page-title mb-3 mb-md-0">Invoices/Estimates</h1>
                </div>
                <div class="col-md-6 text-md-end">
                    <button id="createBtn" class="btn btn-bluelight" title="Create New Invoice/Estimate">Create</button>
                </div>
            </div>
        </header>
        <div class="card card-custom">
            <div class="row filter-section">
                <%--  <div class="col-md-2 mb-3">
                    <label class="form-label mb-0">Search By</label>
                    <select id="searchBy" class="form-select">
                        <option value="All">All</option>
                        <option value="CustomerName">Customer Name</option>
                        <option value="City">City</option>
                        <option value="InvoiceNumber">Invoice Number</option>
                        <option value="Invoice">Invoice</option>
                        <option value="Estimate">Estimate</option>
                    </select>
                </div>
                <div class="col-md-2 mb-3">
                    <label class="form-label mb-0">Search Value</label>
                    <input type="text" id="searchValue" class="form-control" placeholder="Enter value" />
                </div>--%>
                <div class="col-md-2 mb-3">
                    <label class="form-label mb-0">Search by Status</label>
                    <select id="searchByPaymentStatus" class="form-select">
                        <option value="">All</option>
                        <option value="Paid">Paid</option>
                        <option value="Due">Due</option>
                    </select>
                </div>
                <div class="col-md-2 mb-3">
                    <label class="form-label mb-0">From Date</label>
                    <input type="date" id="fromDate" class="form-control" value="" />
                </div>
                <div class="col-md-2 mb-3">
                    <label class="form-label mb-0">To Date</label>
                    <input type="date" id="toDate" class="form-control" value="" />
                </div>
                <div class="col-md-2 mb-3 d-flex align-items-end">
                    <button id="searchBtn" class="btn btn-bluelight w-100">Search Date</button>
                </div>
                <div class="col-md-2 mb-3 d-flex align-items-end">
                    <button id="clearBtn" class="btn btn-secondary w-100">Clear All</button>
                </div>
            </div>

            <div class="row mb-3">
                <div class="col-12">
                    <button id="sendBtn" class="btn btn-bluelight" title="Send Selected">Send</button>
                    <button id="addBillableBtn" class="btn btn-bluelight" title="Add Billable Items (QBO Sync)">Add Billable</button>
                    <button id="viewTaxRatesBtn" class="btn btn-bluelight" title="View Tax Rates (QBO Sync - View Only)">View Tax Rates</button>
                    <button id="syncQuickBookBtn" class="btn btn-bluelight" title="QuickBooks Online Sync">QuickBooks Sync</button>
                    <span id="progressGIF" style="display: none; margin-left: 10px;">
                        <img src="images/Rolling.gif" alt="Loading" />
                        Sync in progress...
                    </span>
                </div>
            </div>

            <h5 class="card-label" style="text-align: left;">All Invoice/Proposal</h5>
            <hr />
            <div class="table-responsive">
                <table id="invoiceTable" class="invoice-table">
                    <thead>
                        <tr>
                            <th>
                                <input type="checkbox" id="selectAll" /></th>
                            <th>Customer Name</th>
                            <th>Type</th>
                            <th>Invoice No #</th>
                            <th>Date</th>
                            <th>Subtotal</th>
                            <th>Discount</th>
                            <th>Tax</th>
                            <th>Total</th>
                            <th>Due</th>
                            <th>Deposit</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody id="invoiceBody"></tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            // Sample invoice data
            const invoices = [
                { id: 1, name: "John Doe", type: "Invoice", number: "INV001", date: "2025-03-15", subtotal: 1000, discount: 50, tax: 80, total: 1030, paid: 500, due: 530, status: "Due", city: "New York" },
                { id: 2, name: "Jane Smith", type: "Estimate", number: "EST002", date: "2025-03-20", subtotal: 2000, discount: 0, tax: 160, total: 2160, paid: 0, due: 2160, status: "Due", city: "Los Angeles" },
                { id: 3, name: "Alice Johnson", type: "Invoice", number: "INV003", date: "2025-04-01", subtotal: 1500, discount: 100, tax: 120, total: 1520, paid: 1520, due: 0, status: "Paid", city: "Chicago" },
                { id: 4, name: "Bob Brown", type: "Invoice", number: "INV004", date: "2025-04-10", subtotal: 800, discount: 20, tax: 64, total: 844, paid: 400, due: 444, status: "Due", city: "Houston" },
                { id: 5, name: "Eve White", type: "Estimate", number: "EST005", date: "2025-04-15", subtotal: 1200, discount: 30, tax: 96, total: 1266, paid: 0, due: 1266, status: "Due", city: "Seattle" }
            ];

            //const fromDate = document.getElementById('fromDate');
            //const toDate = document.getElementById('toDate');
            //const searchBtn = document.getElementById('searchBtn');
            const createBtn = document.getElementById('createBtn');
            const sendBtn = document.getElementById('sendBtn');
            const addBillableBtn = document.getElementById('addBillableBtn');
            const viewTaxRatesBtn = document.getElementById('viewTaxRatesBtn');
            const syncQuickBookBtn = document.getElementById('syncQuickBookBtn');
            const progressGIF = document.getElementById('progressGIF');
            const selectAll = document.getElementById('selectAll');

            // Helper functions for new features
            function createInvoice() {
                alert('Create new Invoice/Estimate functionality (Primary Functionality) - To be implemented');
                // Add logic to create new invoice/estimate
            }

            function sendInvoices() {
                const selected = getSelectedIds();
                if (selected.length === 0) {
                    alert('Please select at least one invoice/estimate to send');
                    return;
                }
                progressGIF.style.display = 'inline';
                setTimeout(() => {
                    progressGIF.style.display = 'none';
                    alert(`Sending ${selected.length} selected items (simulated)`);
                }, 2000);
            }

            function addBillableItems() {
                const selected = getSelectedIds();
                if (selected.length === 0) {
                    alert('Please select at least one invoice/estimate to add billable items');
                    return;
                }
                progressGIF.style.display = 'inline';
                setTimeout(() => {
                    progressGIF.style.display = 'none';
                    alert(`Adding billable items to ${selected.length} selected items (QBO Sync simulated)`);
                }, 2000);
            }

            function viewTaxRates() {
                alert('Viewing Tax Rates (View Only - Synced from QBO)');
                // Add logic to show tax rates in read-only mode
            }

            function syncQuickBook() {
                progressGIF.style.display = 'inline';
                setTimeout(() => {
                    progressGIF.style.display = 'none';
                    alert('QuickBooks Sync completed (simulated)');
                }, 2000);
            }

            function getSelectedIds() {
                const checkboxes = document.querySelectorAll('.row-select:checked');
                return Array.from(checkboxes).map(cb => parseInt(cb.value));
            }

          
            createBtn.addEventListener('click', createInvoice);
            sendBtn.addEventListener('click', sendInvoices);
            addBillableBtn.addEventListener('click', addBillableItems);
            viewTaxRatesBtn.addEventListener('click', viewTaxRates);
            syncQuickBookBtn.addEventListener('click', syncQuickBook);
            
            selectAll.addEventListener('change', (e) => {
                document.querySelectorAll('.row-select').forEach(cb => {
                    cb.checked = e.target.checked;
                });
            });
        });

        const searchByPaymentStatus = document.getElementById('searchByPaymentStatus');
        let table = null;
        loadData();
        function loadData() {
            table = $('#invoiceTable').DataTable({
                "processing": true,
                "serverSide": true,
                "filter": true,
                "ajax": {
                    "url": 'Invoice.aspx/GetCustomerInvoices',
                    "type": "POST",
                    "contentType": "application/json; charset=utf-8",
                    "dataType": "json",
                    "data": function (d) {
                        return JSON.stringify({
                            draw: d.draw,
                            start: d.start,
                            length: d.length,
                            searchValue: d.search.value,
                            sortColumn: d.columns[d.order[0].column].data,
                            sortDirection: d.order[0].dir,
                            invoiceStatus: $('#searchByPaymentStatus').val(),
                            fromDate: $('#fromDate').val(),
                            toDate: $('#toDate').val()
                        });
                    },
                    "dataSrc": function (json) {
                        const parsed = JSON.parse(json.d); // Parse the JSON string
                        json.draw = parsed.draw;
                        json.recordsTotal = parsed.recordsTotal;
                        json.recordsFiltered = parsed.recordsFiltered;
                        console.log(parsed);
                        if (parsed.error) {
                            alert(parsed.error);
                            return [];
                        }
                        return parsed.data;
                    }
                },
                "paging": true,
                "pageLength": 10,
                "lengthMenu": [5, 10, 25, 50],
                "columns": [
                    {
                        "data": 'ID',
                        render: data => `<input type="checkbox" class="row-select" value="${data}" />`,
                        orderable: false
                    },
                    { "data": 'CustomerName' },
                    { "data": 'InvoiceType' },
                    { "data": 'InvoiceNumber' },
                    { "data": 'InvoiceDate' },
                    { "data": 'Subtotal' },
                    { "data": 'Discount' },
                    { "data": 'Tax' },
                    { "data": 'Total' },
                    { "data": 'Due' },
                    { "data": 'DepositAmount' },
                    { "data": 'InvoiceStatus' }
                ],
            });
        }

        $('#searchByPaymentStatus').on('change', function () {
            table.draw(); // refresh data with new filters
        });

        $('#searchBtn').on('click', function () {
            let fromDate = $('#fromDate').val();
            let toDate = $('#toDate').val();

            if (!fromDate || !toDate) {
                alert("Please select both From Date and To Date.");
                return;
            }

            if (new Date(fromDate) > new Date(toDate)) {
                alert("From Date cannot be after To Date.");
                return;
            }
            table.draw();
        });

        $('#clearBtn').on('click', function () {
            $('#fromDate').val('');
            $('#toDate').val('');
            $('#searchByPaymentStatus').val(''); 
            table.draw();
        });
    </script>
</asp:Content>
