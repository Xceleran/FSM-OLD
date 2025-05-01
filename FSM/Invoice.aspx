<%@ Page Title="Invoices" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="Invoice.aspx.cs" Inherits="FSM.Invoice" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
   <style>
       :root {
    --bg-gray-100: rgb(243, 244, 246);
    --text-gray-800: rgb(31, 41, 55);
    --text-gray-700: rgb(55, 65, 81);
    --text-gray-600: rgb(75, 85, 99);
    --text-orange-700: rgb(38, 85, 152);
    --bg-orange-200: rgb(185, 215, 244);
    --text-orange-500: rgb(28, 29, 96);
    --bg-slate-200: rgb(226, 232, 240);
    --bg-white: rgb(255, 255, 255);
    --bg-gray-300: rgb(209, 213, 219);
    --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1);
}

[data-theme="dark"] {
    --bg-gray-100: rgb(28, 29, 96);
    --text-gray-800: rgb(198, 200, 204);
    --text-gray-700: rgb(239, 242, 247);
    --text-gray-600: rgb(75, 85, 99);
    --text-orange-700: rgb(38, 85, 152);
    --bg-orange-200: rgb(185, 215, 244);
    --text-orange-500: rgb(28, 29, 96);
    --bg-slate-200: rgb(226, 232, 240);
    --bg-white: rgb(255, 255, 255);
    --bg-gray-300: rgb(209, 213, 219);
    --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.3), 0 4px 6px -4px rgba(0, 0, 0, 0.2);
}

.invoice-container {
    padding: 20px;
    margin-top: 50px;
}
table#invoiceTable {
    width: 100% !important;
}
.invoice-table {
    width: 100%;
    border-collapse: separate;
    border-spacing: 0;
    background: rgba(255, 255, 255, 0.12);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    border-radius: 8px;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
}
[data-theme="dark"] .dropdown-option:hover {
    background: #0d6efd;
    color: white;
}
[data-theme="dark"] .invoice-table {
    background: rgba(255, 255, 255, 0.12);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(255, 255, 255, 0.1);
}

.page-title {
    font-size: 24px;
    font-weight: bold;
    color: var(--text-orange-700);
}

[data-theme="dark"] .page-title {
    color: var(--bg-orange-200);
}
[data-theme="dark"] .sidebar-nav-link:hover {
    color: #b1ceec !important;
}
.invoice-table th {
    background: var(--bg-gray-100);
    color: var(--text-gray-800);
    font-weight: 600;
    text-transform: uppercase;
    font-size: 12px;
    padding: 12px;
    text-align: left;
}

[data-theme="dark"] .invoice-table th {
    background: transparent;
    color: var(--text-gray-700);
}

.invoice-table td {
    padding: 12px;
    border-bottom: 1px solid var(--bg-gray-300);
    color: var(--text-gray-800);
}

[data-theme="dark"] .invoice-table td {
    color: var(--text-gray-700);
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.invoice-table tbody tr:hover {
    background: var(--bg-orange-200);
}

[data-theme="dark"] .invoice-table tbody tr:hover {
    background: rgba(255, 255, 255, 0.2);
}

.btn-bluelight {
    background-color: var(--text-orange-500);
    color: var(--bg-white);
    margin-right: 5px;
    border-radius: 6px;
}

.btn-bluelight:hover {
    background-color: var(--text-orange-700);
    color: var(--bg-white);
}

[data-theme="dark"] .btn-bluelight {
    background: rgba(255, 255, 255, 0.12);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    color: var(--text-gray-700);
    border: 1px solid rgba(255, 255, 255, 0.1);
}

[data-theme="dark"] .btn-bluelight:hover {
    background: rgb(12, 23, 54);
    color: var(--text-gray-700);
}

.filter-section {
    margin-bottom: 20px;
}

.card-custom {
    border: 1px solid var(--bg-gray-300);
    border-radius: 8px;
    padding: 15px;
    background: rgba(255, 255, 255, 0.12);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

[data-theme="dark"] .card-custom {
    background: rgba(255, 255, 255, 0.12);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    border: 1px solid rgba(255, 255, 255, 0.1);
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
}

.card-label {
    font-size: 18px;
    font-weight: 700;
    color: var(--text-gray-800);
    text-align: left;
}

[data-theme="dark"] .card-label {
    color: var(--text-gray-700);
}

.form-label {
    color: var(--text-gray-800);
}

[data-theme="dark"] .form-label {
    color: var(--text-gray-700);
}

.dataTables_wrapper .dataTables_length label,
.dataTables_wrapper .dataTables_filter label,
.dataTables_wrapper .dataTables_info {
    color: var(--text-gray-800);
}

[data-theme="dark"] .dataTables_wrapper .dataTables_length label,
[data-theme="dark"] .dataTables_wrapper .dataTables_filter label,
[data-theme="dark"] .dataTables_wrapper .dataTables_info {
    color: var(--text-gray-700);
}

.dataTables_wrapper .dataTables_length select,
.dataTables_wrapper .dataTables_filter input,
#fromDate,
#toDate {
    background: var(--bg-white);
    color: var(--text-gray-800);
    border: 1px solid var(--bg-gray-300);
    border-radius: 6px;
}

[data-theme="dark"] .dataTables_wrapper .dataTables_length select,
[data-theme="dark"] .dataTables_wrapper .dataTables_filter input,
[data-theme="dark"] #fromDate,
[data-theme="dark"] #toDate {
    background: rgba(255, 255, 255, 0.12);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    color: var(--text-gray-700);
    border: 1px solid rgba(255, 255, 255, 0.1);
}

/* Custom Dropdown */
.custom-dropdown {
    position: relative;
    width: 100%;
    background: rgba(255, 255, 255, 0.12);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    border: 1px solid var(--bg-gray-300);
    border-radius: 6px;
    color: rgb(90, 90, 90);
    cursor: pointer;
    z-index: 1000;
}

[data-theme="dark"] .custom-dropdown {
  background: rgb(255 255 255 / 12%);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    border: 1px solid rgba(255, 255, 255, 0.1);
    color: rgb(255 255 255);
}

.dropdown-selected {
    padding: 6px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.dropdown-arrow {
    font-size: 12px;
    color: rgb(90, 90, 90);
}

[data-theme="dark"] .dropdown-arrow {
        color: rgb(255 255 255);
}

.dropdown-options {
    display: none;
    position: absolute;
    top: 100%;
    left: 0;
    right: 0;
    background: rgb(255 255 255);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    border: 1px solid var(--bg-gray-300);
    border-radius: 6px;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
    z-index: 10000;
    pointer-events: auto;
}

[data-theme="dark"] .dropdown-options {
    background: rgb(255, 255, 255);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    border: 1px solid rgb(67 65 65 / 87%);
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
}

.dropdown-option {
    padding: 10px;
    color: rgb(90, 90, 90);
}

[data-theme="dark"] .dropdown-option {
    color: rgb(34 34 34);
}

.dropdown-option:hover {
    background: var(--bg-orange-200);
}

[data-theme="dark"] .dropdown-option:hover {
    background: rgb(176 205 235);
}

/* Ensure buttons stay below dropdown */
#sendBtn,
#viewBtn {
    z-index: 999;
}

/* Calendar icon (assumed to be part of jQuery UI Datepicker or a custom icon) */
.ui-datepicker-trigger {
    color: var(--text-gray-800);
}

[data-theme="dark"] .ui-datepicker-trigger {
    color: var(--text-gray-700);
}

/* Custom calendar icon (if not using jQuery UI Datepicker) */
#fromDate + img,
#toDate + img {
    color: var(--text-gray-800);
}

[data-theme="dark"] #fromDate + img,
[data-theme="dark"] #toDate + img {
    color: var(--text-gray-700);
    filter: brightness(0) invert(1); /* Ensures icon turns white if it's an image */
}

/* jQuery UI Datepicker (Calendar) */
.ui-datepicker {
    background: var(--bg-white);
    border: 1px solid var(--bg-gray-300);
    border-radius: 6px;
    color: var(--text-gray-800);
}

[data-theme="dark"] .ui-datepicker {
    background: rgba(255, 255, 255, 0.12);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    border: 1px solid rgba(255, 255, 255, 0.1);
    color: var(--text-gray-700);
}

.ui-datepicker-header {
    background: var(--bg-gray-100);
    color: var(--text-gray-800);
}

[data-theme="dark"] .ui-datepicker-header {
    background: transparent;
    color: var(--text-gray-700);
}

.ui-datepicker-title {
    color: var(--text-gray-800);
}

[data-theme="dark"] .ui-datepicker-title {
    color: var(--text-gray-700);
}

.ui-datepicker-prev,
.ui-datepicker-next {
    color: var(--text-gray-800);
}

[data-theme="dark"] .ui-datepicker-prev,
[data-theme="dark"] .ui-datepicker-next {
    color: var(--text-gray-700);
}

.ui-datepicker-prev:hover,
.ui-datepicker-next:hover {
    background: var(--bg-orange-200);
}

[data-theme="dark"] .ui-datepicker-prev:hover,
[data-theme="dark"] .ui-datepicker-next:hover {
    background: rgba(255, 255, 255, 0.2);
}

.ui-datepicker-calendar th,
.ui-datepicker-calendar td {
    color: var(--text-gray-800);
}

[data-theme="dark"] .ui-datepicker-calendar th,
[data-theme="dark"] .ui-datepicker-calendar td {
    color: var(--text-gray-700);
}

.ui-datepicker-calendar td a {
    color: var(--text-gray-800);
}

[data-theme="dark"] .ui-datepicker-calendar td a {
    color: var(--text-gray-700);
}

.ui-state-highlight,
.ui-state-active {
    background: var(--bg-orange-200);
    color: var(--text-gray-800);
}

[data-theme="dark"] .ui-state-highlight,
[data-theme="dark"] .ui-state-active {
    background: rgba(255, 255, 255, 0.2);
    color: var(--text-gray-700);
}

.status-icon-paid {
    color: #28a745;
    font-size: 14px;
}

[data-theme="dark"] .status-icon-paid {
    color: #34c759;
}

.status-icon-due {
    color: #dc3545;
    font-size: 14px;
}

[data-theme="dark"] .status-icon-due {
    color: #ff4d4f;
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

/* Modal overlay */
.overlay {
    display: none;
    position: fixed;
    width: 100%;
    height: 100%;
    top: 0;
    left: 0;
    z-index: 999;
    background: rgba(0, 0, 0, 0.6);
    backdrop-filter: blur(3px);
}

/* Modal popup */
.popup-inner {
    max-width: 90%;
    width: 800px;
    max-height: 85vh;
    overflow-y: auto;
    padding: 30px;
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    background: #ffffff;
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
    z-index: 1000;
}

/* Close button */
.btnX {
    position: absolute;
    top: 15px;
    right: 15px;
    width: 40px;
    height: 40px;
    background: #f8f9fa;
    border-radius: 50%;
    display: flex;
    justify-content: center;
    align-items: center;
    cursor: pointer;
    transition: background 0.2s;
}

.btnX:hover {
    background: #e5e7eb;
}

.btnX .btn-close {
    font-size: 16px;
}

/* Invoice modal header */
.invoice-header {
    padding: 20px;
    border-radius: 8px 8px 0 0;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.company-name {
    font-size: 24px;
    font-weight: 700;
    color: #F5A623;
}

.company-info {
    font-size: 14px;
    color: #4b5563;
    text-align: right;
}

.company-info p {
    margin: 0;
    line-height: 1.4;
}

/* Invoice title */
#h_Type {
    font-size: 28px;
    font-weight: 700;
    color: #333;
    margin: 20px 0;
}

/* Invoice details */
.invoice-details {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 20px;
    margin-bottom: 30px;
}

.invoice-details div {
    font-size: 14px;
    color: #4b5563;
}

.invoice-details div strong {
    display: block;
    font-weight: 600;
    color: #333;
    margin-bottom: 5px;
}

.invoice-details .total-amount strong {
    color: #F5A623;
    font-size: 18px;
}

/* Items section */
.items-section {
    margin-top: 20px;
}

.items-section h5 {
    font-size: 18px;
    font-weight: 700;
    color: #333;
    margin-bottom: 15px;
}

#table {
    width: 100%;
    border-collapse: collapse;
    font-size: 14px;
    background: #e7f0ff;
    border-radius: 8px;
}

#table th {
    color: #333;
    font-weight: 600;
    padding: 12px;
    text-align: left;
    border-bottom: 1px solid #e5e7eb;
}

#table td {
    padding: 12px;
    color: #4b5563;
    border-bottom: 1px solid #e5e7eb;
}

#table th:last-child,
#table td:last-child {
    text-align: right;
}

/* Totals section */
.totals-section {
    margin-top: 20px;
    text-align: right;
}
#itemBody tr{
        background: #ffffff;
}
.totals-section div {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    font-size: 14px;
    color: #4b5563;
    margin-bottom: 5px;
    margin-right: 5px;
}

.totals-section div strong {
    font-weight: 600;
    color: #333;
}

.totals-section div:last-child strong {
    font-size: 16px;
}

/* Deposit section */
#div_DepositBody #table {
    margin-top: 10px;
}

/* Modal buttons */
#InvoiceBlock .btn {
    padding: 10px 20px;
    font-size: 14px;
    border-radius: 6px;
    transition: background 0.2s;
}

#InvoiceBlock .btn-secondary {
    background: #6b7280;
    border: none;
    color: #fff;
}

#InvoiceBlock .btn-secondary:hover {
    background: #4b5563;
}

/* Email modal */
#EmailBLock .modal-content {
    padding: 20px;
    border-radius: 8px;
    background: #ffffff;
}

#EmailBLock .modal-header {
    border-bottom: 1px solid #e5e7eb;
    padding-bottom: 15px;
}

#EmailBLock .modal-title {
    font-size: 20px;
    font-weight: 600;
    color: #333;
}

#EmailBLock .modal-body {
    padding: 20px 0;
}

#EmailBLock .form-control,
#EmailBLock .form-select,
#EmailBLock textarea {
    border-radius: 6px;
    border: 1px solid #d1d5db;
    font-size: 14px;
    padding: 10px;
}

#EmailBLock .form-check-input {
    margin-right: 10px;
}

#EmailBLock .modal-footer {
    border-top: 1px solid #e5e7eb;
    padding-top: 15px;
}

/* Template selection */
.parent .col {
    padding: 10px;
    text-align: center;
}

.parent img {
    max-width: 100%;
    height: auto;
    border-radius: 6px;
    border: 1px solid #e5e7eb;
    transition: transform 0.2s;
}

[data-theme="dark"] .parent img {
    border: 1px solid rgba(255, 255, 255, 0.1);
}

.parent img:hover {
    transform: scale(1.05);
}

.tick_container {
    position: absolute;
    top: 10px;
    right: 10px;
    background: #28a745;
    border-radius: 50%;
    width: 24px;
    height: 24px;
    display: flex;
    justify-content: center;
    align-items: center;
    color: #fff;
}

[data-theme="dark"] .tick_container {
    background: #34c759;
}

/* Disclaimer */
#InvoiceDesclimer {
    margin-top: 20px;
    padding: 15px;
    background: #f8f9fa;
    border-radius: 6px;
    font-size: 12px;
    color: #4b5563;
}

/* Responsive modal */
@media (max-width: 1200px) {
    .popup-inner {
        width: 90%;
        max-width: 700px;
    }
}

@media (max-width: 992px) {
    .popup-inner {
        padding: 20px;
    }

    #h_Type {
        font-size: 24px;
    }

    .invoice-details {
        grid-template-columns: repeat(2, 1fr);
    }

    #table th,
    #table td {
        padding: 10px;
        font-size: 13px;
    }
}

@media (max-width: 768px) {
    .popup-inner {
        max-width: 95%;
        max-height: 90vh;
        padding: 15px;
    }

    .invoice-header {
        flex-direction: column;
        text-align: center;
    }

    .company-info {
        text-align: center;
        margin-top: 10px;
    }

    #h_Type {
        font-size: 20px;
        text-align: center;
    }

    .invoice-details {
        grid-template-columns: 1fr;
    }

    #table {
        font-size: 12px;
    }

    #table th,
    #table td {
        padding: 8px;
    }

    #InvoiceBlock .btn {
        width: 100%;
        margin: 5px 0;
    }

    .parent .col {
        flex: 0 0 50%;
        max-width: 50%;
    }
}

@media (max-width: 576px) {
    .popup-inner {
        max-width: 100%;
        padding: 10px;
        border-radius: 0;
    }

    #h_Type {
        font-size: 18px;
    }

    .btnX {
        top: 10px;
        right: 10px;
        width: 36px;
        height: 36px;
    }

    #table {
        font-size: 11px;
    }

    #table th,
    #table td {
        padding: 6px;
    }

    .parent .col {
        flex: 0 0 100%;
        max-width: 100%;
    }

    #EmailBLock .form-control,
    #EmailBLock .form-select,
    #EmailBLock textarea {
        font-size: 12px;
        padding: 8px;
    }

    #InvoiceDesclimer {
        font-size: 10px;
        padding: 10px;
    }
}
select.form-select.form-select-sm {
    color: black !important;
    background: white !important;
}
   </style>

    <!-- Ensure DataTables CSS/JS are included -->
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.11.3/css/dataTables.bootstrap5.min.css" />
    <script src="https://cdn.datatables.net/1.11.3/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.11.3/js/dataTables.bootstrap5.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" />
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
                    <div class="custom-dropdown" id="searchByPaymentStatus">
                        <div class="dropdown-selected">
                            <span>All</span>
                            <i class="fas fa-chevron-down dropdown-arrow"></i>
                        </div>
                        <div class="dropdown-options">
                            <div class="dropdown-option" data-value="">All</div>
                            <div class="dropdown-option" data-value="Paid">Paid</div>
                            <div class="dropdown-option" data-value="Due">Due</div>
                        </div>
                        <input type="hidden" name="searchByPaymentStatus" id="hiddenSearchByPaymentStatus" value="">
                    </div>
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
                    <button id="sendBtn" type="button" class="btn btn-bluelight" title="Send Selected">Send</button>
                    <button id="viewBtn" type="button" class="btn btn-bluelight" title="View Details">View</button>
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

    <div id="modal" class="popup" style="z-index: 10000000000">
        <div class="popup-inner">
            <div class="btnX shadow d-flex justify-content-center align-items-center">
                <button type="button" class="btn-close" onclick="ClosePopup();"></button>
            </div>
            <div id="InvoiceBlock">
                <section>
                    <div class="container">
                        <div class="invoice-header">
                            <div>
                                <img src="https://testsite.myserviceforce.com/fsm/images/xceleran.png" alt="Xceleran Logo" class="right-logo-img">
                            </div>
                            <div class="company-info">
                                <p></p>
                                <p>info@xceleran.com</p>
                                <p>www.xceleran.com</p>
                                <p>866-966-6111</p>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-12">
                                <h1 id="h_Type">Invoice</h1>
                            </div>
                            <div class="float-start">
                                <p style="display: none" id="InvocieProgress">
                                    <img id="imgInvocieProgress" src="images/Rolling.gif" />
                                    Loading....
                                </p>
                            </div>
                            <asp:HiddenField ID="InvPrimaryID" runat="server" ClientIDMode="Static" />
                            <div class="col-12">
                                <div class="invoice-details">
                                    <div>
                                        <strong>Billed To:</strong>
                                        <span id="lblCustomerName"></span>
                                        <br />
                                        <span id="lblAddress"></span>,<br />
                                        <span id="lblCity"></span>, 
                                        <span id="lblState"></span>, 
                                        <span id="lblZip"></span>
                                        <br />
                                        <span id="lblPhone"></span>
                                        <br />
                                        <span id="lblEmail"></span>
                                        <span id="lblCustomerID" hidden="hidden"></span>
                                        <span id="lbl_" hidden="hidden"></span>
                                        <span id="qboCustID" hidden="hidden"></span>
                                        <span id="qboInvID" hidden="hidden"></span>
                                        <span id="QboEstimateId" hidden="hidden"></span>
                                    </div>
                                    <div>
                                        <strong>Invoice Date:</strong>
                                        <span id="lblIssueDate"></span>
                                    </div>
                                    <div>
                                        <strong>Invoice Number:</strong>
                                        <span id="lblInvoiceNo"></span>
                                        <span id="lblInvoiceDisplayNo"></span>
                                        <div style="display: none" id="div_Converted">
                                            <a href="#" onclick="OpenInvoice('F26CEEF9-C61D-4E4C-9DC9-8FCC9553C1F7','31')">
                                                <span class="badge badge-success" style="color: #fff; background-color: #28a745; font-size: 14px !important; font-weight: 400 !important;">
                                                    <i class="fa fa-check-circle" style="font-size: 14px; color: #fff !important; margin-right: 8px;"></i>
                                                    Converted To Invoice #
                                                </span>
                                            </a>
                                        </div>
                                    </div>
                                    <div class="total-amount">
                                        <strong>Total Amount:</strong>
                                        $ <span id="lblInvoiceTotal" style="font-size: 32px;">529.88</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
                <div class="items-section">
                    <div class="container">
                        <div class="row">
                            <div class="col-12">
                                <h5>Item Details</h5>
                            </div>
                            <div class="col-12">
                                <div class="table-responsive">
                                    <table id="table">
                                        <thead>
                                            <tr>
                                                <th scope="col" style="width: 50%;">Description</th>
                                                <th scope="col">Cost</th>
                                                <th scope="col">Qty</th>
                                                <th scope="col">Amount</th>
                                            </tr>
                                        </thead>
                                        <tbody id="itemBody"></tbody>
                                    </table>
                                </div>
                            </div>
                            <div class="col-12 totals-section">
                                <div>
                                    <strong>Sub Total:</strong>
                                    <span id="bottom_Subtotal" runat="server"></span>
                                </div>
                                <div>
                                    <strong>Tax:</strong>
                                    <span id="tax" runat="server"></span>
                                </div>
                                <div>
                                    <strong>Discount:</strong>
                                    <span id="discount" runat="server"></span>
                                </div>
                                <div>
                                    <strong>Total:</strong>
                                    <span id="bottom_Total" runat="server"></span>
                                </div>
                            </div>
                            <div id="div_Depositheader" class="col-12">
                                <h5>Deposit</h5>
                            </div>
                            <div id="div_DepositBody" class="col-12">
                                <div class="table-responsive">
                                    <table id="table">
                                        <thead>
                                            <tr>
                                                <th scope="col">Type</th>
                                                <th scope="col">Source</th>
                                                <th scope="col">Check Name</th>
                                                <th scope="col">Check Number</th>
                                                <th scope="col">Amount</th>
                                                <th scope="col">Date</th>
                                            </tr>
                                        </thead>
                                        <tbody id="DepositBody"></tbody>
                                    </table>
                                </div>
                            </div>
                          <%--  <div class="col-12 mt-5">
                                <div class="d-flex flex-column flex-md-row justify-content-between align-items-center gap-3">
                                    <div class="col d-flex justify-content-start align-items-center">
                                        <input type="button" class="btn btn-secondary w-100" value="Email" onclick="sendMailDivToggole()" />
                                    </div>
                                    <div class="col d-flex justify-content-start align-items-center">
                                        <input type="button" class="btn btn-secondary w-100" value="Deposit List" onclick="ShowDeposit()" />
                                    </div>
                                    <div class="col justify-content-end align-items-center">
                                        <input type="button" id="btn_Collect_Payment" class="btn btn-secondary w-100" value="Collect Payment" onclick="CollectPayment()" runat="server" />
                                        <select style="display: none" class="form-select" runat="server" id="PaymentProcessSelect" onchange="CollectPayment()">
                                            <option value="">Select Payment Option</option>
                                            <option value="gpi">XinatorCC Payment Processor</option>
                                            <%-- <option value="wisetack" runat="server">WiseTack- Consumer Financing</option>--%>
                             <%--           </select>
                                    </div>
                                </div>
                            </div>--%>
                        </div>
                        <br />
                        <br />
                        <div id="InvoiceDesclimer" class="card" runat="server">
                            <p style="font-size: 10px; align-content: flex-start; font-family: Helvetica Neue,Helvetica,Arial,Verdana,Trebuchet MS; padding: 2px;">
                                *All financing is subject to credit approval. Your terms may vary. Payment options through Wisetack are provided by our <a href="https://www.wisetack.com/lenders">lending partners</a>. For example, a $1,200 purchase could cost $104.89 a month for 12 months, based on an 8.9% APR, or $400 a month for 3 months, based on a 0% APR. Offers range from 0-35.9% APR based on creditworthiness. No other financing charges or participation fees. See additional terms at <a href="http://wisetack.com/faqs" target="_blank">http://wisetack.com/faqs</a>.
                            </p>
                        </div>
                    </div>
                </div>
            </div>
            <div id="EmailBLock" class="d-none">
                <div class="modal-content" style="text-align: left">
                    <div class="modal-header">
                        <h5 class="modal-title" id="exampleModalLongTitle">Send Email</h5>
                    </div>
                    <div class="modal-body">
                        <asp:HiddenField ID="CustomerID" runat="server" />
                        <asp:HiddenField ID="IsDataSaving" Value="0" runat="server" />
                        <asp:HiddenField ID="EnableSaveOnly" Value="0" runat="server" />
                        <asp:HiddenField ID="_CC" runat="server" />
                        <asp:HiddenField ID="_InvoiceNo" runat="server" />
                        <asp:HiddenField ID="hf_CustomerQboID" Value="0" runat="server" />
                        <div class="row mt-0">
                            <div class="col-12 mt-0">
                                <label for="_To" class="col-form-label">To</label>
                                <div class="col-lg-12">
                                    <input type="text" id="_To" name="_To" runat="server" class="form-control" />
                                </div>
                            </div>
                        </div>
                        <div class="row mt-2">
                            <div class="col-12 mt-0">
                                <label for="_BCC" class="col-form-label">Bcc</label>
                                <div class="col-lg-12">
                                    <input type="text" id="_BCC" name="BCC" runat="server" class="form-control" />
                                </div>
                            </div>
                        </div>
                        <div class="row mt-2">
                            <div class="col-12 mt-0">
                                <label for="EmailSubject" class="col-form-label">Subject</label>
                                <div class="col-lg-12">
                                    <input type="text" id="_EmailSubject" name="EmailSubject" runat="server" class="form-control col-6" max="500" />
                                </div>
                            </div>
                        </div>
                        <div class="row mt-2">
                            <div class="col-12 mt-0">
                                <div class="col-lg-12">
                                    <div class="custom-file">
                                        <asp:FileUpload ID="file" ClientIDMode="Static" runat="server" AllowMultiple="true" MaxLength="100" CssClass="custom-file-input" onchange="javascript:updateList()" />
                                        <label class="custom-file-label" for="file">
                                            <span class="fa fa-paperclip"></span>Attach Files</label><br />
                                        <span class="remove-list fa fa-check"></span><span id="fixAttachment"></span>
                                        <ul id="fileList" class="file-list">
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row mt-2">
                            <div class="container parent">
                                <div class="row">
                                    <div class='col text-center'>
                                        <input type="radio" checked="checked" name="imgbackground" id="img1" class="d-none imgbgchk" value="AsaInvoice">
                                        <label for="img1">
                                            Template 1
                                            <img src="images/AsaInvoice.jpg" alt="Invoice 1">
                                            <div class="tick_container">
                                                <div class="tick"><i class="fa fa-check"></i></div>
                                            </div>
                                        </label>
                                    </div>
                                    <div class='col text-center'>
                                        <input type="radio" name="imgbackground" id="img2" class="d-none imgbgchk" value="AsaQuote">
                                        <label for="img2">
                                            Template 2
                                            <img src="images/AsaQuote.jpg" alt="Estimate 1">
                                            <div class="tick_container">
                                                <div class="tick"><i class="fa fa-check"></i></div>
                                            </div>
                                        </label>
                                    </div>
                                    <div class='col text-center'>
                                        <input type="radio" name="imgbackground" id="img3" class="d-none imgbgchk" value="Invoice">
                                        <label for="img3">
                                            Template 3
                                            <img src="images/Invoice.jpg" alt="Image 3">
                                            <div class="tick_container">
                                                <div class="tick"><i class="fa fa-check"></i></div>
                                            </div>
                                        </label>
                                    </div>
                                    <div class='col text-center'>
                                        <input type="radio" name="imgbackground" id="img5" class="d-none imgbgchk" value="InvoiceWithoutDiscount">
                                        <label for="img5">
                                            Template 4
                                            <img src="images/InvWithoutDis.PNG" alt="Image 3">
                                            <div class="tick_container">
                                                <div class="tick"><i class="fa fa-check"></i></div>
                                            </div>
                                        </label>
                                    </div>
                                    <div class='col text-center'>
                                        <input type="radio" title="Template 5" name="imgbackground" id="img4" class="d-none imgbgchk" value="Estimate">
                                        <label for="img4">
                                            Template 5
                                            <img src="images/Estimate.jpg" alt="Image 4">
                                            <div class="tick_container">
                                                <div class="tick"><i class="fa fa-check"></i></div>
                                            </div>
                                        </label>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row mt-2">
                            <div class="col-12 mt-0">
                                <label for="EmailBody" class="col-form-label"><span>Email Body</span></label>
                                <div class="col-lg-12">
                                    <textarea id="EmailBody" name="EmailBody" rows="8" runat="server" class="form-control"></textarea>
                                </div>
                            </div>
                        </div>
                        <div class="col-4 mt-1" id="IsSendPaymentLinkDIV">
                            <div class="container">
                                <div class="form-check form-check-xl">
                                    <input type="checkbox" class="form-check-input" id="IsSendPaymentLink" style="width: 1.5em; height: 1.5em;" runat="server">
                                    <label class="form-check-label" for="exampleCheckbox" style="font-size: 1.3em;">Include Payment Link</label>
                                </div>
                            </div>
                        </div>
                        <div class="col-6 mt-1" runat="server" id="IsSendWisetackPaymentLinkDIV">
                            <div class="container">
                                <div class="form-check form-check-xl">
                                    <input type="checkbox" class="form-check-input" id="IsSendWisetackPaymentLink" style="width: 1.5em; height: 1.5em;" runat="server">
                                    <label class="form-check-label" for="exampleCheckbox" style="font-size: 1.3em;">Do not Include Wisetack Offer</label>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer justify-content-between">
                        <div class="col-lg-12 mt-3">
                            <div class="d-flex justify-content-start">
                            </div>
                            <div class="d-flex justify-content-end btn-group">
                                <button type="button" class="btn btn-secondary btn-block ml-1" data-dismiss="modal" onclick="CloseMailDiv()" style="float: left">Close</button>
                            </div>
                        </div>
                    </div>
                </div>
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
        ClosePopup();
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
                            invoiceStatus: $('#hiddenSearchByPaymentStatus').val(),
                            fromDate: $('#fromDate').val(),
                            toDate: $('#toDate').val()
                        });
                    },
                    "dataSrc": function (json) {
                        const parsed = JSON.parse(json.d);
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
                        render: function (data, type, row) {
                            const rowData = encodeURIComponent(JSON.stringify(row));
                            return `<input type="checkbox" class="row-select" value="${rowData}" />`;
                        },
                        orderable: false
                    },
                    { "data": 'CustomerName', orderable: false },
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

        //$('#searchByPaymentStatus').on('change', function () {
        //    table.draw();
        //});

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
            $('#hiddenSearchByPaymentStatus').val('');
            $('#searchByPaymentStatus .dropdown-selected span').text('All');
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
            const selected = getSelectedRows();
            if (selected.length === 0 || selected.length > 1) {
                alert('Please select one invoice/estimate to view');
                return;
            }
            console.log(selected[0].CustomerID);
            console.log(selected[0].ID);
            loadInvoiceData(selected[0].ID, selected[0].CustomerID);
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

        function getSelectedRows() {
            const checkboxes = document.querySelectorAll('.row-select:checked');
            return Array.from(checkboxes).map(cb => {
                const rowDataStr = decodeURIComponent(cb.value);
                return JSON.parse(rowDataStr);
            });
        }

        function loadInvoiceData(invoiceNumber, customerId) {
            $.ajax({
                url: 'Invoice.aspx/OpenInvoice',
                type: "POST",
                contentType: 'application/json',
                data: "{InvoiceNo: '" + invoiceNumber + "',CustomerID:'" + customerId + "'}",
                dataType: 'json',
                success: function (sR) {
                    console.log('OpenInvoice response:', sR);
                    const jsonData = JSON.parse(sR.d);
                    console.log('Table:', jsonData.Table);
                    console.log('Table1:', jsonData.Table1);
                    console.log('Table2:', jsonData.Table2);

                    if (!jsonData.Table1 || !jsonData.Table1[0]) {
                        console.error('Invoice data not found');
                        alert('Failed to load invoice details.');
                        return;
                    }

                    var CustomerData = jsonData.Table[0];
                    var InvoiceData = jsonData.Table1[0];
                    var invDetailsData = jsonData.Table2;

                    // Set Subtotal with fallback
                    $("#MainContent_bottom_Subtotal").text("$" + (InvoiceData.Subtotal || '0.00'));

                    // Rest of the existing code (CustomerName, Address, etc.)
                    if (CustomerData.ctype.toString() == '2') {
                        $("#InvoiceDesclimer").hide();
                        $("#IsSendWisetackPaymentLinkDIV").hide();
                    } else {
                        $("#InvoiceDesclimer").show();
                        $("#IsSendWisetackPaymentLinkDIV").show();
                    }

                    if (InvoiceData.IsConverted == '1') {
                        $("#div_Converted").show();
                        var convertHtmlText = "<a href=Invoice.aspx?InvNum=" + InvoiceData.ConvertedInvocieID.toString() + "&cId=" + CustomerData.CustomerGuid.toString() + "&InType=Invoice&AppID=" + InvoiceData.AppointmentId.toString() + ">" +
                            "<span class='badge badge-success' style='color: #fff;background-color: #28a745;font-size: 14px !important;font-weight: 400 !important;'><i class='fa fa-check-circle' style='font-size:14px;color: #fff !important;margin-right: 8px;'></i>" +
                            "Converted To Invoice # " + InvoiceData.ConvertedInvocieNumber.toString() + "</span></a>";
                        $("#div_Converted").html(convertHtmlText);
                    }

                    $("#qboCustID").text(CustomerData.qboCustID.toString().replace("0", ""));
                    $("#qboInvID").text(InvoiceData.qboInvID.toString().replace("0", ""));
                    $("#InvPrimaryID").val(invoiceNumber);
                    $("#qboEstID").text(InvoiceData.qboEstID.toString().replace("0", ""));
                    $("#ctype").val(InvoiceData.ctype);
                    $("#lblCustomerID").text(CustomerData.CustomerID);
                    $("#lblCustomerName").text(CustomerData.FullName);
                    $("#lblAddress").text(CustomerData.Address1);
                    $("#lblCity").text(CustomerData.City);
                    $("#lblState").text(CustomerData.State);
                    $("#lblZip").text(CustomerData.ZipCode);
                    $("#lblPhone").text(CustomerData.Phone);
                    $("#lblEmail").text(CustomerData.Email);
                    $("#lblInvoiceNo").text(InvoiceData.Number);
                    $("#lblInvoiceNo").html("<a href=Invoice.aspx?InvNum=" + invoiceNumber + "&cId=" + CustomerData.CustomerGuid.toString() + "&InType=" + InvoiceData.Type.toString() + "&AppID=" + InvoiceData.AppointmentId.toString() + ">" + InvoiceData.Number + "</a>");
                    $("#lblInvoiceDisplayNo").text(InvoiceData.DisplayNumber);
                    $("#lblIssueDate").text(InvoiceData.IssueDate);
                    $("#lblInvoiceTotal").text(InvoiceData.Total);
                    $("#bottom_Subtotal").text("$" + (InvoiceData.Subtotal || '0.00'));
                    $("#MainContent_discount").text("$" + (InvoiceData.Discount || '0.00'));
                    $("#MainContent_tax").text("$" + (InvoiceData.Tax || '0.00'));
                    $("#MainContent_bottom_Total").text("$" + (InvoiceData.Total || '0.00'));
                    $("#_InvoiceNo").val(invoiceNumber);

                    $('#table tbody > tr').remove();
                    for (var i = 0; i < invDetailsData.length; i++) {
                        var itemDetails = "<tr>" +
                            "<td>" + invDetailsData[i].ItemName + "<br>" + invDetailsData[i].Description + "</td>" +
                            "<td>$ " + invDetailsData[i].uPrice + "</td>" +
                            "<td>" + invDetailsData[i].Quantity + "</td>" +
                            "<td>$ " + invDetailsData[i].TotalPrice + "</td>" +
                            "</tr>";
                        $('#itemBody').append(itemDetails);
                    }

                    if (InvoiceData.Type.toString() == "Invoice") {
                        $('#btn_Collect_Payment').show();
                        $('#h_Type').html("Invoice " + InvoiceData.Number);
                        $('#IsSendPaymentLinkDIV').show();
                        $('#PaymentProcessSelect').show();
                    } else {
                        $('#h_Type').html("Estimate " + InvoiceData.Number);
                    }

                    ShowPopup();
                },
                error: function (error) {
                    console.error('AJAX error:', error);
                    alert('Error loading invoice data.');
                }
            });
        }

        function ShowPopup() {
            var modal = document.getElementById('modal');
            modal.style.display = "block";
            $("#PaymentProcessSelect").val("");
        }

        function ClosePopup() {
            var modal = document.getElementById('modal');
            modal.style.display = "none";
            document.body.style.overflow = "auto";
        }

        function FillEmailModal(customerGuid, InvoiceNo) {
            $.ajax({
                url: 'Invoice.aspx/FillEmailModal',
                type: "Post",
                contentType: 'application/json',
                data: "{CustomerID:'" + customerGuid + "',InvoiceNo:'" + InvoiceNo + "'}",
                dataType: 'json',
                success: function (sR) {
                    if (sR.d != "0") {
                        var data = $.parseJSON(sR.d);
                        var doctype = $('#h_Type').html();
                        $('#_Type').val(doctype);
                        console.log(data)
                        if (doctype.includes("Invoice")) {
                            $("#_EmailSubject").val(data.InvoiceMailSubject);
                            $("#EmailBody").val(data.InvoiceMailBody);
                        }
                        if (doctype.includes("Estimate")) {
                            $("#_EmailSubject").val(data.ProposalMailSubject);
                            $("#EmailBody").val(data.ProposalMailBody);
                        }
                        $("#_CC").val(data.EmailCC);
                        $("#_BCC").val(data.EmailBCC);
                        $("#_To").val(data.EmailTo);
                        $("#file").val();
                        $("#fileList").empty();
                        $("#_InvoiceNo").val(InvoiceNo);
                    }
                },
                error: function (error) {
                }
            });
        }

        function sendMailDivToggole() {
            $('#EmailBLock').toggleClass('d-none');
            $('#InvoiceBlock').toggleClass('d-none');
        }

        function CloseMailDiv() {
            $('#EmailBLock').addClass('d-none');
            $('#InvoiceBlock').removeClass('d-none');
        }

        function ShowDeposit() {
        }

        function CollectPayment() {
        }
    </script>

    <script>
        // Custom Dropdown Functionality
        document.addEventListener('DOMContentLoaded', function () {
            const dropdown = document.querySelector('#searchByPaymentStatus');
            const selected = dropdown.querySelector('.dropdown-selected');
            const optionsContainer = dropdown.querySelector('.dropdown-options');
            const options = dropdown.querySelectorAll('.dropdown-option');
            const hiddenInput = dropdown.querySelector('#hiddenSearchByPaymentStatus');

            // Toggle dropdown on click
            selected.addEventListener('click', function (e) {
                e.stopPropagation();
                const isOpen = optionsContainer.style.display === 'block';
                optionsContainer.style.display = isOpen ? 'none' : 'block';
                // Disable pointer events on buttons when dropdown is open
                document.querySelector('#sendBtn').style.pointerEvents = isOpen ? 'auto' : 'none';
                document.querySelector('#viewBtn').style.pointerEvents = isOpen ? 'auto' : 'none';
            });

            // Handle option selection
            options.forEach(option => {
                option.addEventListener('click', function () {
                    const value = this.getAttribute('data-value');
                    const text = this.textContent;
                    selected.querySelector('span').textContent = text;
                    hiddenInput.value = value;
                    optionsContainer.style.display = 'none';
                    // Re-enable pointer events on buttons
                    document.querySelector('#sendBtn').style.pointerEvents = 'auto';
                    document.querySelector('#viewBtn').style.pointerEvents = 'auto';

                    // Trigger DataTable redraw
                    table.draw();
                });
            });

            // Close dropdown when clicking outside
            // Close dropdown when clicking outside
            document.addEventListener('click', function () {
                optionsContainer.style.display = 'none';
                // Re-enable pointer events on buttons
                document.querySelector('#sendBtn').style.pointerEvents = 'auto';
                document.querySelector('#viewBtn').style.pointerEvents = 'auto';
            });
        });
    </script>
</asp:Content>
