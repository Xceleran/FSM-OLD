<%@ Page Title="Invoices" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="Invoice.aspx.cs" Inherits="FSM.Invoice" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

 <!-- Local Styles and Scripts -->
 <link rel="stylesheet" href="Content/invoice.css">


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
                    <button type="button" id="searchBtn" class="btn edit-btn w-100">Search Date</button>
                </div>
                <div class="col-md-2 mb-3 d-flex align-items-end">
                    <button id="clearBtn" class="btn btn-secondary w-50">Clear All</button>
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
     <script src="Scripts/invoice.js"></script>
  

    <script>
    
    </script>
</asp:Content>
