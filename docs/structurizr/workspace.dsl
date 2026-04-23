workspace "Vehicle Configurator" "C4 model for the Vehicle Configurator prototype — a three-tier web application for configuring a car and submitting an order." {

    !identifiers hierarchical

    !docs docs
    !adrs adrs

    model {

        // ---------------------------------------------------------------
        // People
        // ---------------------------------------------------------------
        user     = person "End user"  "A prospective buyer configuring a car and submitting an order."
        operator = person "Operator"  "Developer/operator provisioning and updating the Azure deployment from their laptop." "Internal"

        // ---------------------------------------------------------------
        // External systems
        // ---------------------------------------------------------------
        github = softwareSystem "GitHub"                       "Source code hosting and CI/CD via GitHub Actions (repo: fbrase-itk/vehicle_configurator)." {
            tags "External"
        }
        ghcr   = softwareSystem "GitHub Container Registry"    "Hosts the three component images as ghcr.io/fbrase-itk/vehicle_configurator-{frontend,backend,database}." {
            tags "External"
        }
        azure  = softwareSystem "Azure Container Apps"         "Serverless container runtime (West Europe) used as the production deployment target." {
            tags "External"
        }

        // ---------------------------------------------------------------
        // The system itself (C4 L2 — Containers)
        // ---------------------------------------------------------------
        vc = softwareSystem "Vehicle Configurator" "Web application for configuring a car (engine, paint, wheels, caliper, special equipment), computing the total price, saving a shareable configuration, and submitting an order." {

            // -----------------------------------------------------------
            // Frontend container
            // -----------------------------------------------------------
            frontend = container "Frontend" "Vue 3 SPA with a live three.js 3D preview. Serves static assets in prod via nginx and reverse-proxies /api/* to the backend." "Vue 3, Vite, three.js, nginx" {

                fe_app     = component "App shell"             "App.vue: sticky header, design-token :root block, #header-actions teleport target, <router-view/>." "Vue 3 SFC"
                fe_cfg     = component "Configurator page"     "Multi-step configurator, live total price, teleports step navigation and the 'Continue to Summary' CTA into the header, persists and navigates to /summary/:id." "Vue 3 SFC"
                fe_sum     = component "Summary page"          "Loads a persisted configuration, renders the 3D preview + detail table + order form, 'Back' teleport." "Vue 3 SFC"
                fe_preview = component "CarPreview3D"          "three.js scene; loads aventador.glb + DRACO + HDR once, mutates body/wheel/caliper materials and toggles rim meshes reactively on prop changes." "Vue 3 SFC + three.js"
                fe_api     = component "API client"            "Thin fetch wrapper around /api for options, engines-per-model, configurations, and orders." "JS module"
                fe_nginx   = component "nginx ingress (prod)"  "Serves /, SPA fallback (try_files), and reverse-proxies /api/ to ${BACKEND_UPSTREAM}:8080. Runs the Vite dev server in the dev container instead." "nginx 1.27 / Vite 5"

                fe_cfg     -> fe_preview "Binds selected paint / wheels / caliper / model props to"
                fe_sum     -> fe_preview "Binds persisted selections to"
                fe_cfg     -> fe_api     "Fetches catalog & saves configurations via"
                fe_sum     -> fe_api     "Fetches configuration & submits order via"
                fe_app     -> fe_cfg     "Routes / and /config/:id to"
                fe_app     -> fe_sum     "Routes /summary/:id to"
                fe_nginx   -> fe_app     "Serves the SPA bundle"
                fe_api     -> fe_nginx   "Relative /api/* requests routed through"
            }

            // -----------------------------------------------------------
            // Backend container
            // -----------------------------------------------------------
            backend = container "Backend" "Stateless REST API. Reads the catalog, validates and persists configurations and orders, computes totals. Virtual threads enabled." "Spring Boot 4, Java 25" {

                be_ctrl   = component "ConfiguratorController" "REST surface /api/*: options, car-models, engines, paints, wheel-designs, wheel-colors, caliper-colors, equipment, configurations, orders. Class-level @CrossOrigin(origins=\"*\")." "Spring @RestController"
                be_svc    = component "ConfiguratorService"    "Business logic: aggregates catalog for /api/options, assembles Configuration, generates UUID, calculateTotalPrice(), creates orders (@Transactional)." "Spring @Service"
                be_repos  = component "Repositories"           "Nine Spring Data JPA interfaces (one per entity), all extending JpaRepository. No custom queries." "Spring Data JPA"
                be_model  = component "JPA entities"           "CarModel, EngineOption, PaintOption, WheelDesign, WheelColor, CaliperColor, SpecialEquipment, Configuration (UUID PK), Order. Hibernate ddl-auto=none." "JPA / Hibernate"
                be_app    = component "Application"            "Spring Boot entry point (com.configurator.Application)." "Spring Boot"

                be_app    -> be_ctrl  "Bootstraps"
                be_ctrl   -> be_svc   "Delegates business logic to"
                be_svc    -> be_repos "Persists and reads through"
                be_repos  -> be_model "Maps rows to"
            }

            // -----------------------------------------------------------
            // Database container
            // -----------------------------------------------------------
            database = container "Database" "Relational store for catalog, configurations and orders. Schema and seed data applied by 001-init.sql on first start." "MySQL 8.4" {
                tags "Database"

                db_catalog = component "Catalog tables"         "car_models, engine_options, paint_options, wheel_designs, wheel_colors, caliper_colors, special_equipment. Seeded on first start." "MySQL"
                db_config  = component "Configuration tables"  "configurations (UUID PK) + join table configuration_equipment (≤ 5 rows per config)." "MySQL"
                db_orders  = component "Order table"           "orders (FK to configurations, customer name/email, total_price, created_at)." "MySQL"
            }

            // -----------------------------------------------------------
            // Relationships across containers
            // -----------------------------------------------------------
            frontend.fe_api    -> backend.be_ctrl  "Calls JSON REST endpoints on" "HTTPS /api/*"
            backend.be_repos   -> database         "Reads/writes via"             "JDBC :3306"
        }

        // ---------------------------------------------------------------
        // High-level user and system relationships (C4 L1 — System Context)
        // The container-level user -> vc.frontend relationship automatically
        // rolls up to user -> vc in the system context view.
        // ---------------------------------------------------------------
        user     -> vc.frontend "Configures a car, shares a URL, submits an order" "HTTPS"
        operator -> azure    "Provisions and updates the deployment using azure/*.sh scripts"
        operator -> github   "Pushes code, reviews PRs"
        github   -> ghcr     "Publishes container images on push to main / tags (docker-publish.yml)"
        github   -> azure    "Deploys new revisions via azure-deploy.yml (OIDC federation)"
        ghcr     -> azure    "Images pulled by" "docker pull"
        vc       -> ghcr     "Distributed as images through"

        // ---------------------------------------------------------------
        // Deployment environments
        // ---------------------------------------------------------------

        deploymentEnvironment "Local (Docker Compose)" {
            local_laptop = deploymentNode "Developer laptop" "" "Linux / macOS / Windows" {
                local_docker = deploymentNode "Docker Engine" "" "Docker 24+" {
                    local_network = deploymentNode "compose network" "" "Docker bridge network" {

                        local_fe_node = deploymentNode "frontend container" "Built from docker/frontend/Dockerfile (target=dev). Bind-mounts ../frontend:/app for hot reload. Publishes :5173." "Node 22 (Vite dev server)" {
                            local_fe = containerInstance vc.frontend
                        }

                        local_be_node = deploymentNode "backend container" "Built from docker/backend/Dockerfile. Multi-stage (Maven → JRE 25). Publishes :8080." "Java 25 / Spring Boot fat-jar" {
                            local_be = containerInstance vc.backend
                        }

                        local_db_node = deploymentNode "database container" "Image mysql:8.4. Bind-mounts ../database/init into /docker-entrypoint-initdb.d. Healthcheck = mysqladmin ping. Publishes :3306." "MySQL 8.4" {
                            local_db = containerInstance vc.database
                        }

                        local_db_volume = infrastructureNode "db-data volume" "Named Docker volume mounted at /var/lib/mysql for MySQL persistence across container restarts." "Docker volume"
                    }
                }
            }
        }

        deploymentEnvironment "Azure" {

            az_subscription = deploymentNode "Azure subscription" "" "Azure" {

                az_rg = deploymentNode "Resource group: rg-vehicle-configurator" "Located in West Europe. Lifecycle managed by azure/01-setup.sh and azure/03-teardown.sh." "Azure Resource Group" {

                    az_law = infrastructureNode "Log Analytics: vc-logs" "Collects stdout/stderr from all container apps." "Log Analytics workspace"

                    az_env = deploymentNode "Container Apps environment: vc-env" "Shared VNET + log sink for the three container apps; provides internal DNS <app>.internal.<envDefaultDomain>." "Azure Container Apps environment" {

                        az_fe_app = deploymentNode "frontend Container App" "External HTTP ingress on :80. Min 0 / max 2 replicas, 0.25 CPU / 0.5 GiB. BACKEND_UPSTREAM points at backend.internal.<envDefaultDomain>." "Azure Container App (nginx)" {
                            az_fe_instance = containerInstance vc.frontend
                        }

                        az_be_app = deploymentNode "backend Container App" "Internal HTTP ingress on :8080 (--allow-insecure). Min 0 / max 2 replicas, 0.5 CPU / 1 GiB." "Azure Container App (JVM)" {
                            az_be_instance = containerInstance vc.backend
                        }

                        az_db_app = deploymentNode "database Container App" "Internal TCP ingress on :3306. Min=max=1 replica, 0.5 CPU / 1 GiB. Stateful — storage is the replica filesystem." "Azure Container App (MySQL 8.4)" {
                            az_db_instance = containerInstance vc.database
                        }
                    }
                }
            }

            az_ghcr_node = deploymentNode "GHCR" "Public container registry that backs the ACA deployment." "ghcr.io" {
                az_img_fe = infrastructureNode "vehicle_configurator-frontend:<tag>" "Multi-stage nginx image (frontend prod)." "Container image"
                az_img_be = infrastructureNode "vehicle_configurator-backend:<tag>"  "Spring Boot fat-jar on Temurin 25 JRE."  "Container image"
                az_img_db = infrastructureNode "vehicle_configurator-database:<tag>" "mysql:8.4 + init scripts baked in."      "Container image"
            }
        }
    }

    // -------------------------------------------------------------------
    // Views (C4 diagrams)
    // -------------------------------------------------------------------
    views {

        systemContext vc "SystemContext" "C4 Level 1 — The Vehicle Configurator in its environment." {
            include *
            autolayout lr
        }

        container vc "Containers" "C4 Level 2 — The three runtime containers of the Vehicle Configurator." {
            include *
            autolayout lr
        }

        component vc.frontend "FrontendComponents" "C4 Level 3 — Internal components of the Frontend container." {
            include *
            autolayout tb
        }

        component vc.backend "BackendComponents" "C4 Level 3 — Internal components of the Backend container." {
            include *
            autolayout tb
        }

        component vc.database "DatabaseComponents" "C4 Level 3 — Logical grouping of tables inside MySQL." {
            include *
            autolayout lr
        }

        deployment vc "Local (Docker Compose)" "LocalDeployment" "Deployment view — one-command local stack via `docker compose up`." {
            include *
            autolayout lr
        }

        deployment vc "Azure" "AzureDeployment" "Deployment view — Azure Container Apps in rg-vehicle-configurator (West Europe)." {
            include *
            autolayout lr
        }

        // -----------------------------------------------------------------
        // Styles
        // -----------------------------------------------------------------
        styles {
            element "Person" {
                background #0049B0
                color #ffffff
                shape Person
            }
            element "Software System" {
                background #0F172A
                color #ffffff
            }
            element "Container" {
                background #2980b9
                color #ffffff
            }
            element "Component" {
                background #A7E2FF
                color #0F172A
            }
            element "Database" {
                shape Cylinder
                background #7c3aed
                color #ffffff
            }
            element "Web Browser" {
                shape WebBrowser
            }
            element "External" {
                background #475569
                color #ffffff
            }
            element "Internal" {
                background #27ae60
                color #ffffff
            }
            element "Infrastructure Node" {
                background #DDF3FE
                color #0F172A
            }
        }

        themes default
    }

    configuration {
        scope softwareSystem
    }
}
