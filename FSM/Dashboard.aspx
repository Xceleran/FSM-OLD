<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/FSM.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="FSM.Dashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Bootstrap CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">

    <style>
        :root {
            --shadow-lg: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.1);
            --text-gray-700: #4b5563;
            --text-blue-700: #1e40af;
            --bg-light: #f3f4f6;
            --bg-dark: #1f2937;
        }

        [data-theme="dark"] {
            --shadow-lg: 0 4px 6px -1px rgba(0, 0, 0, 0.3), 0 2px 4px -2px rgba(0, 0, 0, 0.2);
            --text-gray-700: #d1d5db;
            --text-blue-700: #60a5fa;
            --bg-light: #374151;
            --bg-dark: #111827;
        }

        body {
            background-color: var(--bg-light);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .container-fluid-mockup {
            max-width: 1400px;
            margin: 0 auto;
            padding: 1rem;
            width: 100%;
        }

        .hero-section-mockup {
            background: var(--bg-light);
            border-radius: 8px;
            padding: 2rem;
            margin: 5rem auto;
            box-shadow: var(--shadow-lg);
            display: flex;
            flex-direction: row;
            align-items: center;
            justify-content: center;
            gap: 2rem;
        }

        [data-theme="dark"] .hero-section-mockup {
            background: linear-gradient(135deg, rgba(255, 255, 255, 0.1) 0%, rgba(255, 255, 255, 0.05) 100%);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
        }

        .hero-text-mockup {
            flex: 1;
            text-align: left;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .page-title-mockup {
            font-size: clamp(4rem, 5vw, 3rem);
            font-weight: 700;
            color: var(--text-blue-700);
            margin-bottom: -8px;
        }

        .subtitle-mockup {
            font-size: clamp(4.25rem, 3vw, 1.75rem);
            font-weight: 400;
            color: var(--text-gray-700);
            margin-bottom: 1rem;
        }

        .hero-image-mockup {
            max-width: 100%;
            width: clamp(200px, 40vw, 600px);
            height: auto;
            border-radius: 8px;
            object-fit: cover;
        }

        .logo-image-mockup {
            max-width: 80px;
            height: auto;
            border-radius: 4px;
            content: url('https://testsite.myserviceforce.com/fsm/images/xceleran.png');
            /*content: url('https://central.xceleran.com/fsm/images//xceleran.png');*/
            margin: 0 auto;
            display: block;
        }

        [data-theme="dark"] .logo-image-mockup {
            content: url('https://testsite.myserviceforce.com/fsm/images/xceleranwhite.png');        
           /* content: url('https://central.xceleran.com/fsm/images//xceleranwhite.png');*/
        }

  

        /* Responsive Design */
        @media (max-width: 992px) {
            .hero-section-mockup {
                flex-direction: column;
                text-align: center;
                padding: 1.5rem;
                gap: 1.5rem;
            }

            .hero-text-mockup {
                text-align: center;
            }

            .hero-image-mockup {
                width: 100%;
                max-width: 500px;
            }

            .page-title-mockup {
                font-size: clamp(1.75rem, 4vw, 2.5rem);

            }

            .subtitle-mockup {
                font-size: clamp(1rem, 2.5vw, 1.5rem);
            }

            .logo-image-mockup {
                max-width: 60px;
            }
        }

        @media (max-width: 576px) {
            .container-fluid-mockup {
                padding: 0.5rem;
            }

            .hero-section-mockup {
                margin: 1rem auto;
                padding: 1rem;
            }
             .page-title-mockup {
        margin-bottom: 1rem;

 }
         
            .hero-image-mockup {
                max-width: 100%;
            }

            .dashboard-content-mockup {
                padding: 1rem;
            }

            .chart-bar-mockup {
                height: 6rem;
            }

            .chart-bar-mockup .bars-mockup {
                height: 5rem;
            }

            .chart-bar-mockup .bar-mockup {
                width: 1rem;
            }
        }
    </style>

    <main class="main-content-mockup container-fluid container-fluid-mockup">
        <!-- Hero Section -->
        <section class="hero-section-mockup">
                <img src="https://testsite.myserviceforce.com/fsm/images/fsmmain.png" alt="Technician with Van" class="hero-image-mockup">
           <%-- <img src="https://central.xceleran.com/fsm/images/fsmmain.png" alt="Technician with Van" class="hero-image-mockup">--%>

            <div class="hero-text-mockup">
                <h1 class="page-title-mockup">Welcome to FSM</h1>
                <p class="subtitle-mockup">Field Service Module</p>
            </div>
        
        </section>

    </main>

    <!-- Bootstrap JS CDN -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
</asp:Content>