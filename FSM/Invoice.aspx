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
            </div>
        </header>
        <div class="card card-custom">
            <div class="row filter-section">
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
                    <button type="button" id="searchBtn" class="btn btn-bluelight w-100">Search Date</button>
                </div>
                <div class="col-md-2 mb-3 d-flex align-items-end">
                    <button id="clearBtn" class="btn btn-secondary w-100">Clear All</button>
                </div>
            </div>

            <div class="row mb-3">
                <div class="col-12">
                    <button id="sendBtn" class="btn btn-bluelight" title="Send Selected">Send</button>
                    <button id="viewBtn" class="btn btn-bluelight" title="View Details">View</button>
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
        const sendBtn = document.getElementById('sendBtn');
        const viewBtn = document.getElementById('viewBtn');
        const progressGIF = document.getElementById('progressGIF');
        const selectAll = document.getElementById('selectAll');
        const searchByPaymentStatus = document.getElementById('searchByPaymentStatus');
        sendBtn.addEventListener('click', sendInvoices);
        viewBtn.addEventListener('click', viewInvoice);
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

        $('#searchBtn').on('click', function (e) {
            e.preventDefault();
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

        $('#clearBtn').on('click', function (e) {
            e.preventDefault();
            $('#fromDate').val('');
            $('#toDate').val('');
            $('#searchByPaymentStatus').val(''); 
            table.draw();
        });

        function sendInvoices(e) {
            e.preventDefault();
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

        function viewInvoice(e) {
            e.preventDefault();
            const selected = getSelectedIds();
            if (selected.length === 0 || selected.length > 1) {
                alert('Please select one invoice/estimate to view');
                return;
            }
        }

        selectAll.addEventListener('change', (e) => {
            document.querySelectorAll('.row-select').forEach(cb => {
                cb.checked = e.target.checked;
            });
        });

        function getSelectedIds() {
            const checkboxes = document.querySelectorAll('.row-select:checked');
            return Array.from(checkboxes).map(cb => parseInt(cb.value));
        }
    </script>
</asp:Content>
