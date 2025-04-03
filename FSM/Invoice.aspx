<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="FSM.Dashboard" %>

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
        <div class="card card-custom">
            <div class="row filter-section">
                <div class="col-md-2 mb-3">
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
                </div>
                <div class="col-md-2 mb-3">
                    <label class="form-label mb-0">Status</label>
                    <select id="searchByPaymentStatus" class="form-select">
                        <option value="All">All</option>
                        <option value="Paid">Paid</option>
                        <option value="Due">Due</option>
                    </select>
                </div>
                <div class="col-md-2 mb-3">
                    <label class="form-label mb-0">From Date</label>
                    <input type="date" id="fromDate" class="form-control" value="2025-03-13" />
                </div>
                <div class="col-md-2 mb-3">
                    <label class="form-label mb-0">To Date</label>
                    <input type="date" id="toDate" class="form-control" value="2025-04-30" />
                </div>
                <div class="col-md-2 mb-3 d-flex align-items-end">
                    <button id="searchBtn" class="btn btn-bluelight w-100">Search</button>
                </div>
            </div>

            <div class="row mb-3">
                <div class="col-12">
                    <button id="syncQuickBookBtn" class="btn btn-bluelight" title="QuickBooks Online Sync">QuickBooks Online Sync</button>
                    <span id="progressGIF" style="display: none; margin-left: 10px;">
                        <img src="images/Rolling.gif" alt="Loading" /> Sync in progress...
                    </span>
                </div>
            </div>

            <h5 class="card-label" style="text-align: left;">All Invoice/Proposal</h5>
            <hr />
            <div class="table-responsive">
                <table id="invoiceTable" class="invoice-table">
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Type</th>
                            <th>Number</th>
                            <th>Date</th>
                            <th>Subtotal</th>
                            <th>Discount</th>
                            <th>Tax</th>
                            <th>Total</th>
                            <th>Paid</th>
                            <th>Due</th>
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
                { name: "John Doe", type: "Invoice", number: "INV001", date: "2025-03-15", subtotal: 1000, discount: 50, tax: 80, total: 1030, paid: 500, due: 530, status: "Due", city: "New York" },
                { name: "Jane Smith", type: "Estimate", number: "EST002", date: "2025-03-20", subtotal: 2000, discount: 0, tax: 160, total: 2160, paid: 0, due: 2160, status: "Due", city: "Los Angeles" },
                { name: "Alice Johnson", type: "Invoice", number: "INV003", date: "2025-04-01", subtotal: 1500, discount: 100, tax: 120, total: 1520, paid: 1520, due: 0, status: "Paid", city: "Chicago" },
                { name: "Bob Brown", type: "Invoice", number: "INV004", date: "2025-04-10", subtotal: 800, discount: 20, tax: 64, total: 844, paid: 400, due: 444, status: "Due", city: "Houston" },
                { name: "Eve White", type: "Estimate", number: "EST005", date: "2025-04-15", subtotal: 1200, discount: 30, tax: 96, total: 1266, paid: 0, due: 1266, status: "Due", city: "Seattle" }
            ];

            // Initialize DataTable
            const table = $('#invoiceTable').DataTable({
                data: invoices,
                columns: [
                    { data: 'name' },
                    { data: 'type' },
                    { data: 'number' },
                    { data: 'date' },
                    { data: 'subtotal', render: data => `$${data.toFixed(2)}` },
                    { data: 'discount', render: data => `$${data.toFixed(2)}` },
                    { data: 'tax', render: data => `$${data.toFixed(2)}` },
                    { data: 'total', render: data => `$${data.toFixed(2)}` },
                    { data: 'paid', render: data => `$${data.toFixed(2)}` },
                    { data: 'due', render: data => `$${data.toFixed(2)}` },
                    {
                        data: 'status',
                        render: data => {
                            const icon = data === 'Paid' ? '<i class="fas fa-check-circle status-icon-paid"></i>' : '<i class="fas fa-exclamation-circle status-icon-due"></i>';
                            return `${icon} ${data}`;
                        }
                    }
                ],
                pageLength: 5,
                lengthMenu: [5, 10, 25, 50],
                responsive: true,
                dom: '<"row"<"col-sm-12 col-md-6"l><"col-sm-12 col-md-6"f>>t<"row"<"col-sm-12 col-md-5"i><"col-sm-12 col-md-7"p>>'
            });

            // DOM Elements
            const searchBy = document.getElementById('searchBy');
            const searchValue = document.getElementById('searchValue');
            const searchByPaymentStatus = document.getElementById('searchByPaymentStatus');
            const fromDate = document.getElementById('fromDate');
            const toDate = document.getElementById('toDate');
            const searchBtn = document.getElementById('searchBtn');
            const syncQuickBookBtn = document.getElementById('syncQuickBookBtn');
            const progressGIF = document.getElementById('progressGIF');

            // Custom filter function
            function filterInvoices() {
                const searchByVal = searchBy.value;
                const searchVal = searchValue.value.toLowerCase();
                const statusVal = searchByPaymentStatus.value;
                const from = new Date(fromDate.value);
                const to = new Date(toDate.value);

                table.clear();
                const filtered = invoices.filter(invoice => {
                    const invoiceDate = new Date(invoice.date);
                    let matchSearch = true;
                    let matchStatus = statusVal === 'All' || invoice.status === statusVal;
                    let matchDate = invoiceDate >= from && invoiceDate <= to;

                    if (searchVal) {
                        switch (searchByVal) {
                            case 'CustomerName':
                                matchSearch = invoice.name.toLowerCase().includes(searchVal);
                                break;
                            case 'City':
                                matchSearch = invoice.city.toLowerCase().includes(searchVal);
                                break;
                            case 'InvoiceNumber':
                                matchSearch = invoice.number.toLowerCase().includes(searchVal);
                                break;
                            case 'Invoice':
                                matchSearch = invoice.type === 'Invoice' && (invoice.name.toLowerCase().includes(searchVal) || invoice.number.toLowerCase().includes(searchVal));
                                break;
                            case 'Estimate':
                                matchSearch = invoice.type === 'Estimate' && (invoice.name.toLowerCase().includes(searchVal) || invoice.number.toLowerCase().includes(searchVal));
                                break;
                            case 'All':
                                matchSearch = invoice.name.toLowerCase().includes(searchVal) || invoice.number.toLowerCase().includes(searchVal) || invoice.city.toLowerCase().includes(searchVal);
                                break;
                        }
                    }

                    return matchSearch && matchStatus && matchDate;
                });

                table.rows.add(filtered).draw();
            }

            // Sync simulation
            function syncQuickBook() {
                progressGIF.style.display = 'inline';
                setTimeout(() => {
                    progressGIF.style.display = 'none';
                    alert('QuickBooks Sync completed (simulated).');
                }, 2000);
            }

            // Event Listeners
            searchBtn.addEventListener('click', filterInvoices);
            syncQuickBookBtn.addEventListener('click', syncQuickBook);
            searchValue.addEventListener('input', filterInvoices);
            searchBy.addEventListener('change', filterInvoices);
            searchByPaymentStatus.addEventListener('change', filterInvoices);
            fromDate.addEventListener('change', filterInvoices);
            toDate.addEventListener('change', () => {
                if (new Date(toDate.value) < new Date(fromDate.value)) {
                    toDate.value = fromDate.value;
                }
                filterInvoices();
            });
        });
    </script>
</asp:Content>