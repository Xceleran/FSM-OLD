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

         .popup-inner {
            max-width: 70%;
            width: 100%;
            padding: 40px;
            position: absolute;
            top: 0;
            left: 50%;
            transform: translate(-50%, 0%);
            box-shadow: 0px 2px 6px rgba(0,0,0,1);
            border-radius: 3px;
            background: #fff;
            margin-top: 80px;
        }

         .overlay {
            display: none;
            position: fixed;
            width: 100%;
            height: 100%;
            top: 0;
            left: 0;
            z-index: 999;
            background: rgba(255,255,255,0.8) url("/examples/images/loader.gif") center no-repeat;
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
                        <div class="row">
                            <div class="col-12">
                                <h1 id="h_Type" class="float-end" style='color: #1c1d60;'>Invoice</h1>
                            </div>
                            <div class="float-start">
                                <p style="display: none" id="InvocieProgress">
                                    <img id="imgInvocieProgress" src="images/Rolling.gif" />
                                    Loading....
                                </p>
                            </div>
                            <asp:HiddenField ID="InvPrimaryID" runat="server" ClientIDMode="Static" />
                            <div class="col-12">
                                <div class="row d-sm-block d-md-flex justify-content-between align-items-center">
                                    <div class="col-12 col-sm-12 col-md-6 mt-2">
                                        <div class="row">
                                            <div class="col-12">
                                                <h5 class="float-start">
                                                    <span id="lblCustomerName"></span><span id="lblCustomerID" hidden="hidden"></span>
                                                    <span id="lbl_" hidden="hidden"></span>
                                                    <span id="qboCustID" hidden="hidden"></span>
                                                    <span id="qboInvID" hidden="hidden"></span>
                                                    <span id="QboEstimateId" hidden="hidden"></span>
                                                </h5>
                                            </div>
                                            <div class="col-12">
                                                <address class="float-start">
                                                    <span id="lblAddress"></span>, 
                                                    <span id="lblCity"></span>, 
                                                    <span id="lblState"></span>, 
                                                    <span id="lblZip"></span>
                                                </address>
                                            </div>
                                            <div class="col-12">
                                                <div class="row">
                                                    <div class="col-12">
                                                        <span class="float-start">Phone:<span id="lblPhone"></span></span>
                                                    </div>
                                                    <div class="col-12">
                                                        <span class="float-start">Email: <span id="lblEmail"></span></span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="col-12 col-sm-12 col-md-6 mt-2">
                                        <div class="d-flex justify-content-end align-items-center">
                                            <div class="col-auto">

                                                <div class="div-table">
                                                    <div class="div-table-row">
                                                        <div class="div-table-col">
                                                            <span class="spantitle" id="Inv_Type">Invoice No</span>
                                                            <div class="div-table-col" style="display: none" id="div_Converted">
                                                                <a href="#" onclick="OpenInvoice('F26CEEF9-C61D-4E4C-9DC9-8FCC9553C1F7','31')">
                                                                    <span class="badge badge-success" style="color: #fff; background-color: #28a745; font-size: 14px !important; font-weight: 400 !important;">
                                                                        <i class="fa fa-check-circle" style="font-size: 14px; color: #fff !important; margin-right: 8px;"></i>
                                                                        Converted To Invoice # </span></a>
                                                            </div>
                                                        </div>
                                                        <div class="div-table-col textcenter w25p"><span class="spani">:</span></div>
                                                        <div class="div-table-col textleft"><span class="spanid" id="lblInvoiceDisplayNo"></span></div>
                                                        <div class="div-table-col textleft"><span class="spanid" id="lblInvoiceNo"></span></div>


                                                    </div>
                                                    <div class="div-table-row">
                                                        <div class="div-table-col"><span class="spantitle">Issue Date</span></div>
                                                        <div class="div-table-col textcenter w25p"><span class="spani">:</span></div>
                                                        <div class="div-table-col textleft"><span class="spanid" id="lblIssueDate"></span></div>
                                                    </div>
                                                    <div class="div-table-row">
                                                        <div class="div-table-col"><span class="spantitle">Invoice Total</span></div>
                                                        <div class="div-table-col textcenter w25p"><span class="spani">:</span></div>
                                                        <div class="div-table-col">$ <span class="spanid" id="lblInvoiceTotal"></span></div>
                                                    </div>

                                                    <div class="div-table-row">
                                                        <div class="div-table-col"><span class="spantitle">Paid</span></div>
                                                        <div class="div-table-col textcenter w25p"><span class="spani">:</span></div>
                                                        <div class="div-table-col">$<span class="spanid" id="lblPaid"></span></div>
                                                    </div>
                                                    <div class="div-table-row">
                                                        <div class="div-table-col"><span class="spantitle">PO :</span></div>
                                                        <div class="div-table-col textcenter w25p"><span class="spani">:</span></div>
                                                        <div class="div-table-col"><span class="spanid" id="lblPONO"></span></div>
                                                    </div>

                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                            </div>
                        </div>
                    </div>
                </section>
                <hr />
                <div class="mt-2">
                    <div class="container">
                        <div class="row">
                            <div class="col-12 float-start">
                                <h5 class="float-start" style='color: #1c1d60;'>Items Details</h5>
                            </div>
                            <div class="col-12">
                                <div class="table-responsive">
                                    <table id="table">
                                        <thead>
                                            <tr>
                                                <th scope="col" style="width: 200px;">Item</th>
                                                <th scope="col" style="width: 400px;">Description</th>
                                                <th scope="col">Unit price</th>
                                                <th scope="col">qty</th>
                                                <th scope="col">Total</th>
                                            </tr>
                                        </thead>
                                        <tbody id="itemBody"></tbody>
                                    </table>
                                </div>
                            </div>
                            <div class="col-12 mt-2">
                                <div class="d-flex justify-content-end align-items-center">

                                    <div class="col-4">
                                        <div class="d-flex justify-content-between align-items-center">
                                            <span class="tospantitle">Sub Total</span>
                                            <span class="tospani">:</span>
                                            <span class="tospanid" id="bottom_Subtotal" runat="server"></span>
                                        </div>
                                        <div class="d-flex justify-content-between align-items-center">
                                            <span class="tospantitle">Tax</span>
                                            <span class="tospani">:</span>
                                            <span class="tospanid" id="tax" runat="server"></span>
                                        </div>

                                        <div class="d-flex justify-content-between align-items-center">
                                            <span class="tospantitle">Discount</span>
                                            <span class="tospani">:</span>
                                            <span class="tospanid" id="discount" runat="server"></span>
                                        </div>
                                        <div class="d-flex justify-content-between align-items-center">
                                            <span class="tospantitle font-weight-bold" >Total</span>
                                            <span class="tospani">:</span>
                                            <span class="tospanid" id="bottom_Total" runat="server"></span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div id="div_Depositheader" class="col-12 float-start">
                                <h5 class="float-start" style='color: #1c1d60;'>Deposit</h5>
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
                            <div class="col-12 mt-5">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="col d-flex justify-content-start align-items-center">
                                        <input type="button" class="btn btn-secondary w-50" value="Email" onclick="sendMailDivToggole()" />
                                    </div>
                                    <div class="col d-flex justify-content-start align-items-center">
                                        <input type="button" class="btn btn-secondary w-50" value="Deposit List" onclick="ShowDeposit()" />
                                    </div>
                                    <div class="col justify-content-end align-items-center">
                                        <input type="button" id="btn_Collect_Payment" class="btn btn-secondary w-100" value="Collect Payment" onclick="CollectPayment()" runat="server" />
                                        <select style="display: none" class="form-select" runat="server" id="PaymentProcessSelect" onchange="CollectPayment()">
                                            <option value="">Select Payment Option</option>
                                            <option value="gpi">XinatorCC Payment Processor</option>
                                            <%-- <option value="wisetack" runat="server">WiseTack- Consumer Financing</option>--%>
                                        </select>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <br />
                        <br />
                        <div id="InvoiceDesclimer" class="card" runat="server">
                            <p style="font-size: 10px; align-content: flex-start; font-family: Helvetica Neue,Helvetica,Arial,Verdana,Trebuchet MS; padding: 2px;">
                                *All financing is subject to credit approval. Your terms may vary. Payment options through Wisetack are provided by our <a href="https://www.wisetack.com/lenders">lending partners</a>. For example, a $1,200 purchase could cost $104.89 a month for 12 months, based on an 8.9% APR, or $400 a month for 3 months, based on a 0% APR. Offers range from 0-35.9% APR based on creditworthiness. No other financing charges or participation fees. See additional terms at <a href="http://wisetack.com/faqs" target="_blank">http://wisetack.com/faqs</a>.
                            </p>
                        </div>
                    </div>

                </div>
            </div>
            <div id="EmailBLock" class="d-none">
                <%-- Proposal Modal Start --%>
                <div class="modal-content" style="text-align: left">
                    <div class="modal-header">
                        <h5 class="modal-title" id="exampleModalLongTitle">Send Email</h5>
                        <%-- <button type="button" class="close btn-danger" data-dismiss="modal" aria-label="Close" onclick="ClosePopup()">
                                        <span aria-hidden="true">&times;</span>
                                    </button>--%>
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
                                                            <img src="images/AsaInvoice.jpg" alt="Invocie 1">
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
                                <button type="button" class="btn btn-secondary  btn-block ml-1" data-dismiss="modal" onclick="CloseMailDiv()" style="float: left">Close</button>&nbsp;&nbsp;
<%--                                            <asp:Button ID="btn_PrintPdf" runat="server" Text="Print" CssClass="btn btn-secondary text-nowrap" OnClick="btn_PrintPdf_Click" />&nbsp;&nbsp;
                                             <asp:Button ID="btnSendInvoiceMail" runat="server" Text="Send" CssClass="btn btn-primary text-nowrap" OnClick="btnSendInvoiceMail_Click" />--%>
                            </div>
                        </div>
                        <%--   <input type="button" class="btn btn-secondary w-30" value="Send" onclick="sendMail()" />--%>
                    </div>
                </div>
                <%--End Proposal Modal  --%>
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
                    console.log(sR)
                    const jsonData = JSON.parse(sR.d);
                    // const InvoiceDataSet = jsonData.Tables;
                    // var InvoiceDataSet = JSON.parse(sR.d);
                    console.log(jsonData.Table)
                    console.log(jsonData.Table1)
                    console.log(jsonData.Table2)

                    var CustomerData = jsonData.Table[0];
                    var InvoiceData = jsonData.Table1[0];
                    var invDetailsData = jsonData.Table2;
                    if (CustomerData.ctype.toString() == '2') {
                        $("#InvoiceDesclimer").hide();
                        $("#IsSendWisetackPaymentLinkDIV").hide();

                    } else {
                        $("#InvoiceDesclimer").show();
                        $("#IsSendWisetackPaymentLinkDIV").show();

                    }
                    //  alert(InvoiceData);
                    if (InvoiceData != null) {
                        console.log("IsConverted", InvoiceData.IsConverted)
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
                        var link = "Invoice.aspx?InvNum=" + invoiceNumber + "&cId=" + CustomerData.CustomerGuid.toString() + "&InType=" + InvoiceData.Type.toString() + "&AppID=" + InvoiceData.AppointmentId.toString();
                        //$("#Link_Invocie").html(InvoiceData.Number);
                        //$("#Link_Invocie").attr("href", link);

                        $("#lblInvoiceNo").html("<a href=Invoice.aspx?InvNum=" + invoiceNumber + "&cId=" + CustomerData.CustomerGuid.toString() + "&InType=" + InvoiceData.Type.toString() + "&AppID=" + InvoiceData.AppointmentId.toString() + ">" + InvoiceData.Number + "</a>");
                        $("#lblInvoiceDisplayNo").text(InvoiceData.DisplayNumber);
                        $("#lblIssueDate").text(InvoiceData.IssueDate);
                        $("#lblInvoiceTotal").text(InvoiceData.Total);
                        $("#lblPaid").text(InvoiceData.AmountCollect);
                        $("#lblPONO").text(InvoiceData.PONO);
                        $("#bottom_Subtotal").text("$" + InvoiceData.Subtotal);
                        $("#discount").text("$" + InvoiceData.Discount);
                        $("#tax").text("$" + InvoiceData.Tax);
                        $("#bottom_Total").text("$" + InvoiceData.Total);

                        $("#_InvoiceNo").val(invoiceNumber);
                        $('#table tbody > tr').remove();
                        for (var i = 0; i < invDetailsData.length; i++) {
                            var itemDetails = "<tr>" +
                                "<th scope='row'>" + invDetailsData[i].ItemName + "</th>" +
                                "<td>" + invDetailsData[i].Description + "</td>" +
                                "<td>$ " + invDetailsData[i].uPrice + "</td>" +
                                "<td>" + invDetailsData[i].Quantity + "</td>" +
                                "<td>$ " + invDetailsData[i].TotalPrice + "</td>" +
                                "</tr>";
                            $('#itemBody').append(itemDetails);
                        }
                        if (InvoiceData.Type.toString() == "Invoice") {
                            $('#btn_Collect_Payment').show();
                            $('#h_Type').html("Invoice");
                            $('#Inv_Type').html("Invoice No:");
                            $('#IsSendPaymentLinkDIV').show();
                            $('#PaymentProcessSelect').show();
                        }
                        else {
                            $('#Inv_Type').html("Estimate No:");
                            $('#h_Type').html("Estimate");
                            //$('#btn_Collect_Payment').hide();
                            //$('#IsSendPaymentLinkDIV').hide();
                            //$('#PaymentProcessSelect').hide();
                        }

                        ShowPopup();
                        //prgBar.style.display = "none";
                        //FillEmailModal(CustomerData.CustomerGuid.toString(), invoiceNumber);
                    }
                },
                error: function (error) {
                    //prgBar.style.display = "none";
                    //alert(error);
                }
            })
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
            // alert("caled");
            //alert(customerGuid);
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
                        //  document.getElementById('fixAttachment').innerHTML = " " + doctype + ".pdf";
                        if (doctype == "Invoice") {
                            $("#_EmailSubject").val(data.InvoiceMailSubject);
                            $("#EmailBody").val(data.InvoiceMailBody);

                        }
                        if (doctype == "Estimate") {

                            $("#_EmailSubject").val(data.ProposalMailSubject);
                            $("#EmailBody").val(data.ProposalMailBody);
                        }

                        $("#_CC").val(data.EmailCC);
                        $("#_BCC").val(data.EmailBCC);
                        $("#_To").val(data.EmailTo);
                        $("#file").val();
                        $("#fileList").empty();
                        // document.getElementById('fileList').innerHTML='<li><span class="remove-list fa fa-check"></span>Proposal.pdf</li>';
                        $("#_InvoiceNo").val(InvoiceNo);
                        //  $("#CustomerID").val(customerid);
                    }
                },
                error: function (error) {
                    //  alert(JSON.stringify(error));
                }
            });
        }

    </script>
</asp:Content>
