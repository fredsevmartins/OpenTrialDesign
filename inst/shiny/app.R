library(shiny)
library(OpenTrialDesign)
native_select <- function(...) selectInput(...,selectize=FALSE)
ui <- fluidPage(title="OpenTrialDesign — Scientific trial planning",lang="en",
  tags$head(tags$style(HTML("
    .skip-link{position:absolute;left:-10000px}.skip-link:focus{position:static;background:white;color:#142d45;padding:12px}\n    :focus-visible{outline:3px solid #b15b00;outline-offset:3px}\n    body{background:#f4f7fb;color:#152b42;font-family:system-ui,sans-serif}
    .otd-header{background:#142d45;color:white;padding:24px 28px;margin:0 -15px 24px}
    .otd-header h1{font-size:28px;margin:0 0 6px;font-weight:700}.otd-header p{color:#c0d5e5;margin:0}
    .well{background:white;border:1px solid #dce5ef;border-radius:12px;box-shadow:none}
    .nav-tabs{border-bottom:2px solid #dce5ef;margin-bottom:20px;display:flex;flex-wrap:wrap}
    .nav-tabs>li>a{color:#254a66}.nav-tabs>li.active>a{color:#087f82;font-weight:650}
    .tab-content{background:white;padding:24px;border:1px solid #dce5ef;border-radius:12px}
    .btn-default{border-color:#087f82;color:#087f82;border-radius:6px}.btn-primary{background:#087f82;border-color:#087f82;color:#fff}
    .form-control{border-color:#c9d6e4;border-radius:6px}pre{background:#f7fafc;border-color:#dce5ef;border-radius:8px;white-space:pre-wrap}
    .otd-note{padding:12px 16px;background:#e8f5f4;border-left:3px solid #087f82;margin:12px 0}
    .otd-status{padding:12px 16px;border:1px solid #c9d6e4;border-radius:8px;margin-bottom:16px}
    .shiny-output-error{color:#a32328}.table{font-size:14px}caption{color:#40556b}label{font-weight:600}
    @media(max-width:767px){.tab-content{padding:14px}.otd-header{padding:18px}.nav-tabs>li>a{padding:9px}}
  "))),
  tags$a(href="#main-content",class="skip-link","Skip to main content"),
  div(class="otd-header", h1("OpenTrialDesign"), p("Trial planning, simulation and reproducible scientific decisions")),
  sidebarLayout(sidebarPanel(
    h4("Fixed trial assumptions"),
    native_select("endpoint", "Endpoint", c("Normal mean"="normal", "Binary response"="binary")),
    numericInput("effect", "Treatment minus control effect", 0.5, step=0.05),
    conditionalPanel("input.endpoint === 'normal'", numericInput("sd", "Common standard deviation", 1, min=0.01)),
    conditionalPanel("input.endpoint === 'binary'", numericInput("pcontrol", "Control response probability", 0.3, min=0.001, max=0.999)),
    native_select("alternative", "Alternative hypothesis", c("Two-sided"="two.sided", "Treatment greater"="greater", "Treatment less"="less")),
    numericInput("alpha", "Total fixed-design alpha", 0.05, min=0.001, max=0.2),
    numericInput("power", "Target power", 0.8, min=0.5, max=0.99),
    numericInput("n", "Participants per arm", 64, min=2),
    actionButton("calculate", "Calculate fixed design", class="btn-primary"),
    hr(), h4("Simulation settings"),
    numericInput("nsim", "Replications (maximum 100,000 in app)", 1000, min=2, max=100000),
    numericInput("seed", "Random seed", 2026, min=0),
    helpText("Jobs run in a separate R process. You can change tabs, inspect saved results or cancel a running job.")),
    mainPanel(id="main-content",
      div(class="otd-status", role="status", `aria-live`="polite", strong("Simulation: "), textOutput("job_status", inline=TRUE),
        actionButton("cancel", "Cancel active simulation")),
      uiOutput("scientific_review"),
      tabsetPanel(id="workspace",
      tabPanel("Design configuration", h3("Define the question"),
        p("Two-arm superiority with equal allocation. Fixed effects are treatment minus control; survival effects are treatment/control hazard ratios."),
        div(class="otd-note", "Every result is a snapshot. After editing assumptions, calculate again; saved results retain their original settings."),
        verbatimTextOutput("specification")),
      tabPanel("Sample size and power", h3("Fixed sample planning"), tableOutput("fixed_table"), verbatimTextOutput("fixed")),
      tabPanel("Group sequential designs", h3("Spending and enrollment"),
        textInput("information", "Cumulative information fractions (comma-separated)", "0.5,1"),
        native_select("engine", "Boundary engine", c("gsDesign", "rpact")),
        native_select("spending", "Alpha spending", c("OF", "Pocock")),
        native_select("futility", "Futility rule", c("none", "binding", "nonbinding")),
        numericInput("gsalpha", "One-sided efficacy alpha", .025, min=.001, max=.2),
        actionButton("sequential", "Calculate boundaries"),
        actionButton("seqsample", "Plan integer enrollment with rpact"),
        helpText("Enrollment planning uses a positive normal mean effect and the common SD from the sidebar. Integer stage sizes are recalibrated in rpact; gsDesign boundaries are not transferred."),
        verbatimTextOutput("sequential_result"), plotOutput("sequential_plot"),
        tableOutput("seqsample_table"), verbatimTextOutput("seqsample_result")),
      tabPanel("Adaptive designs", h3("Two-stage inverse-normal adaptation"),
        p("One-sided positive normal-mean superiority with common SD. Prespecified combination weights and native conditional-power resizing. Both equality-null and alternative scenarios are evaluated; the fixed-design alternative selector does not change this procedure."),
        numericInput("stage1", "First-stage total enrollment", 80, min=4, step=2),
        numericInput("planned", "Initially planned total enrollment", 160, min=8, step=2),
        numericInput("min2", "Minimum additional stage-two enrollment", 40, min=4, step=2),
        numericInput("max2", "Maximum additional stage-two enrollment", 240, min=4, step=2),
        numericInput("targetcp", "Target conditional power", .8, min=.01, max=.99),
        actionButton("adaptive", "Start adaptive simulation", class="btn-primary"), verbatimTextOutput("adaptive_result")),
      tabPanel("Survival studies", h3("Event and enrollment planning"),
        numericInput("hr", "Treatment/control hazard ratio", .7, min=.01, max=.99),
        numericInput("median", "Control median survival", 12, min=.01),
        numericInput("accrual", "Uniform accrual duration", 18, min=.01),
        numericInput("followup", "Additional follow-up after accrual", 12, min=.01),
        numericInput("dropout", "Dropout probability", 0, min=0, max=.99),
        numericInput("dropouttime", "Duration defining dropout probability", 12, min=.01),
        numericInput("events", "Event target (0 = administrative cutoff only)", 0, min=0, step=1),
        helpText("All time quantities use the same unit. An event target stops the trial at the target event or at the administrative cap, whichever comes first."),
        actionButton("survival", "Plan survival study"),
        checkboxInput("survnull", "Simulate equality null (HR = 1)", FALSE),
        actionButton("survsim", "Start survival simulation", class="btn-primary"),
        verbatimTextOutput("survival_result"), verbatimTextOutput("survsim_result")),
      tabPanel("Monte Carlo simulation", h3("Power and null error"),
        checkboxInput("null", "Equality-null scenario", TRUE),
        actionButton("simulate", "Start fixed trial simulation", class="btn-primary"),
        verbatimTextOutput("simulation_result"), plotOutput("simulation_plot")),
      tabPanel("Scenario comparison", h3("Sensitivity analysis"),
        p("Each scenario is a complete frozen project. The grid varies the current fixed-design assumptions; simulation intervals are marginal, not simultaneous."),
        textInput("grid_effects","Effects (comma-separated)","0.3,0.5"),
        textInput("grid_powers","Target powers (comma-separated)","0.8,0.9"),
        checkboxInput("grid_simulate","Simulate each scenario at the sidebar enrollment",FALSE),
        checkboxInput("grid_null","Evaluate equality null in batch simulations",TRUE),
        p("Maximum 36 scenarios and 100,000 total replications in this app. Seeds increment from the sidebar seed. Simulation jobs can be cancelled."),
        actionButton("compare", "Compare scenarios"),
        div(role="region",`aria-label`="Scrollable scenario results",tabindex="0",style="overflow-x:auto;max-width:100%",tableOutput("comparison")),
        downloadButton("comparison_csv","Export scenario CSV"),
        downloadButton("comparison_bundle","Download complete scenario bundle")),
      tabPanel("Projects and exports", h3("Save, replay and share"),
        native_select("report_source", "Calculated result", c("Fixed sample size"="fixed", "Fixed power"="power", "Sequential boundaries"="seq", "Sequential enrollment"="seqsample", "Adaptive simulation"="adaptive", "Survival planning"="survival", "Fixed simulation"="sim", "Survival simulation"="survsim", "Imported project"="imported", "Example"="example")),
        uiOutput("downloads"), verbatimTextOutput("snapshot"),
        hr(), fileInput("project_file", "Open a project (.json)", accept=".json"),
        verbatimTextOutput("import_preview"), uiOutput("project_execute")),
      tabPanel("Scientific reporting", h3("Methodological report"),
        p("Choose a calculated result in Projects and exports. Reports include the exact specification, methods, assumptions, package versions, seed and validation status."),
        native_select("report_format", "Report format", c("HTML"="html", "PDF (requires LaTeX)"="pdf")),
        uiOutput("report_download"), textOutput("report_help")),
      tabPanel("Example library", h3("Version-1 example catalog"),
        native_select("example", "Scientific example", sprintf("TD-%03d",1:30)),
        actionButton("runexample", "Execute example"), verbatimTextOutput("example_assumptions"), verbatimTextOutput("example_result")),
      tabPanel("User guide", h3("From assumptions to an auditable result"),
        tags$ol(tags$li("Configure the endpoint, effect direction, alpha and target power."),
          tags$li("Calculate enrollment and inspect achieved analytical power."),
          tags$li("Simulate both the alternative and the appropriate equality null; inspect Monte Carlo uncertainty."),
          tags$li("Save the JSON project and download a reproducibility bundle or methodological report.")),
        p("Sequential alpha is one-sided. Binding futility must be followed. Adaptive resizing uses the inverse-normal procedure, not an ordinary pooled test. Survival assumes proportional exponential hazards and independent censoring."),
        downloadButton("guide", "Download full user guide"),
        h4("Runtime capabilities"), div(style="overflow-x:auto;max-width:100%",tableOutput("capabilities")))
    )))
)
server <- function(input, output, session) {
  safe <- function(expr) tryCatch(expr, error=function(e) validate(shiny::need(FALSE,conditionMessage(e))))
  value <- function(x, default) if (is.null(x)) default else x
  fixed_parameters <- reactive(list(endpoint=value(input$endpoint,"normal"), effect=value(input$effect,.5),
    sd=value(input$sd,1), p_control=value(input$pcontrol,.3), alpha=value(input$alpha,.05),
    power=value(input$power,.8), alternative=value(input$alternative,"two.sided")))
  specification <- reactive(safe(do.call(trial_spec,fixed_parameters())))
  information <- reactive({
    fractions<-suppressWarnings(as.numeric(strsplit(value(input$information,"0.5,1"),",",fixed=TRUE)[[1]]))
    validate(shiny::need(length(fractions)>=2 && length(fractions)<=10,"App supports 2 to 10 information looks."))
    fractions
  })
  seq_parameters <- reactive(list(information=information(), alpha=value(input$gsalpha,.025),
    power=value(input$power,.8), spending=value(input$spending,"OF"), futility=value(input$futility,"none")))
  survival_parameters <- reactive(list(hazard_ratio=value(input$hr,.7), median_control=value(input$median,12),
    accrual=value(input$accrual,18), followup=value(input$followup,12), dropout=value(input$dropout,0),
    dropout_time=value(input$dropouttime,12), alpha=value(input$gsalpha,.025)))
  make_project <- function(workflow, parameters, title) trial_project(workflow,parameters,title)
  planning<-reactiveValues(fixed=NULL,power=NULL,seq=NULL,seqsample=NULL,survival=NULL,comparison=NULL)
  planning_errors<-reactiveValues()
  eager<-function(key,expression)tryCatch({
    answer<-force(expression);planning[[key]]<-answer;planning_errors[[key]]<-NULL
  },error=function(e){planning_errors[[key]]<-conditionMessage(e);showNotification(conditionMessage(e),type="error")})
  planned<-function(key){
    validate(shiny::need(is.null(planning_errors[[key]]),planning_errors[[key]]))
    planning[[key]]
  }
  fixed<-reactive(planned("fixed"));power_result<-reactive(planned("power"))
  seq<-reactive(planned("seq"));seqsample<-reactive(planned("seqsample"));surv<-reactive(planned("survival"))
  observeEvent(input$calculate,{
    parameters<-fixed_parameters();n<-value(input$n,64)
    eager("fixed",execute_project(make_project("fixed_sample_size",parameters,"Fixed trial sample size")))
    eager("power",execute_project(make_project("fixed_power",c(parameters,list(n_per_arm=n)),"Fixed trial power")))
  })
  observeEvent(input$sequential,eager("seq",execute_project(make_project("sequential_design",
    c(list(engine=value(input$engine,"gsDesign")),seq_parameters()),"Sequential boundaries"))))
  observeEvent(input$seqsample,eager("seqsample",{
    validate(shiny::need(value(input$endpoint,"normal")=="normal","Integer mean enrollment requires the Normal mean endpoint."))
    execute_project(make_project("sequential_means",c(list(effect=value(input$effect,.5),sd=value(input$sd,1)),seq_parameters()),"Sequential enrollment"))
  }))
  observeEvent(input$survival,eager("survival",execute_project(make_project("survival_design",
    c(survival_parameters(),list(power=value(input$power,.8))),"Survival planning"))))
  results <- reactiveValues(sim=NULL,adaptive=NULL,survsim=NULL,imported=NULL,example=NULL)
  active_job <- reactiveVal(NULL); job_message <- reactiveVal("Idle")
  launch_body <- function(project, destination) {
    previous <- active_job()
    if (!is.null(previous) && simulation_status(previous$handle)$state=="running") {
      showNotification("Cancel or finish the active simulation before starting another.",type="message"); return(invisible(NULL))
    }
    count <- value(project$parameters$nsim,1000)
    if (count>100000) {showNotification("App limit: 100,000 replications per job. Use the R API for larger runs.",type="error"); return(invisible(NULL))}
    tryCatch({
      handle <- start_simulation(project)
      active_job(list(handle=handle,destination=destination))
      job_message(paste("Running:",project$title))
    },error=function(e) {job_message(paste("Failed:",conditionMessage(e)));showNotification(conditionMessage(e),type="error")})
  }
  launch <- function(project, destination) tryCatch(launch_body(project,destination),
    error=function(e){job_message(paste("Failed:",conditionMessage(e)));showNotification(conditionMessage(e),type="error")})
  harvest_job <- function() {
    current <- active_job(); if(is.null(current)) return(invisible(NULL))
    status <- simulation_status(current$handle)
    if(status$state=="running") return(invisible(NULL))
    if(status$state=="completed") {
      if(current$destination=="batch")batch(collect_simulation(current$handle)) else
        results[[current$destination]] <- collect_simulation(current$handle)
      job_message(paste("Completed:",current$handle$project$title))
    } else job_message(paste(status$state,value(status$message,"")))
    active_job(NULL)
  }
  observe({invalidateLater(300,session);harvest_job()})
  observeEvent(input$cancel,{
    current<-active_job();if(!is.null(current))tryCatch({cancel_simulation(current$handle);harvest_job()},
      error=function(e){job_message(paste("Cancellation failed:",conditionMessage(e)));showNotification(conditionMessage(e),type="error")})
  })
  session$onSessionEnded(function(){current<-isolate(active_job());if(!is.null(current))cancel_simulation(current$handle)})
  observeEvent(input$simulate,launch(make_project("fixed_simulation",c(fixed_parameters(),
    list(n_per_arm=value(input$n,64),nsim=value(input$nsim,1000),seed=value(input$seed,2026),null=value(input$null,TRUE))),"Fixed trial Monte Carlo"),"sim"))
  observeEvent(input$adaptive,launch({
    if(value(input$endpoint,"normal")!="normal")stop("Adaptive means simulation requires the Normal mean endpoint.")
    make_project("adaptive_simulation",list(effect=value(input$effect,.5),
    sd=value(input$sd,1),stage1=value(input$stage1,80),planned_total=value(input$planned,160),
    min_stage2=value(input$min2,40),max_stage2=value(input$max2,240),target_cp=value(input$targetcp,.8),
    alpha=value(input$gsalpha,.025),power=value(input$power,.8),nsim=value(input$nsim,1000),seed=value(input$seed,2026)),"Adaptive inverse-normal simulation")},"adaptive"))
  observeEvent(input$survsim,launch(make_project("survival_simulation",c(survival_parameters(),
    list(n_per_arm=value(input$n,64),events=if(value(input$events,0)==0)NULL else input$events,
      nsim=value(input$nsim,1000),seed=value(input$seed,2026),null=value(input$survnull,FALSE))),"Survival Monte Carlo"),"survsim"))
  sim<-reactive(results$sim);adaptive<-reactive(results$adaptive);survsim<-reactive(results$survsim)
  batch<-reactiveVal(NULL)
  comparison<-reactive({x<-batch();if(is.null(x))return(NULL);x$data$summary})
  grid_projects<-reactive({
    parse<-function(x){v<-suppressWarnings(as.numeric(strsplit(x,",",fixed=TRUE)[[1]]));
      if(!length(v)||any(!is.finite(v)))stop("Provide comma-separated finite scenario values.");unique(v)}
    simulated<-value(input$grid_simulate,FALSE)
    args<-fixed_parameters()
    if(simulated)args<-c(args,list(n_per_arm=value(input$n,64),nsim=value(input$nsim,1000),
      seed=value(input$seed,2026),null=value(input$grid_null,TRUE)))
    projects<-scenario_grid(trial_project(if(simulated)"fixed_simulation" else "fixed_sample_size",args),
      list(effect=parse(value(input$grid_effects,"0.3,0.5")),power=parse(value(input$grid_powers,"0.8,0.9"))),max_scenarios=36)
    if(simulated&&length(projects)*value(input$nsim,1000)>100000)stop("App limit: 100,000 total batch replications.")
    projects
  })
  observeEvent(input$compare,tryCatch({
    projects<-grid_projects()
    if(value(input$grid_simulate,FALSE)){
      previous<-active_job()
      if(!is.null(previous)&&simulation_status(previous$handle)$state=="running")stop("Cancel or finish the active simulation first.")
      handle<-start_scenarios(projects)
      active_job(list(handle=handle,destination="batch"));job_message("Running: scenario sensitivity analysis")
    } else batch(run_scenarios(projects))
  },error=function(e){showNotification(conditionMessage(e),type="error")}))
  output$comparison_csv<-downloadHandler(filename=function()"OpenTrialDesign-scenarios.csv",content=function(file){
    req(batch());utils::write.csv(batch()$data$summary,file,row.names=FALSE)})
  output$comparison_bundle<-downloadHandler(filename=function()"OpenTrialDesign-scenarios.zip",content=function(file){req(batch());export_bundle(batch(),file,include_report=FALSE)})
  observeEvent(input$runexample,launch(make_project("example",list(id=input$example,
    nsim=value(input$nsim,1000),seed=value(input$seed,2026)),paste("Example",input$example)),"example"))
  example<-reactive(results$example)
  opened<-reactiveVal(NULL); import_error<-reactiveVal(NULL)
  observeEvent(input$project_file,{
    tryCatch({p<-read_project(input$project_file$datapath);opened(p);import_error(NULL)},
      error=function(e){opened(NULL);import_error(conditionMessage(e));showNotification(conditionMessage(e),type="error")})
  })
  observeEvent(input$runproject,{
    req(opened());p<-opened()
    if(p$workflow %in% c("fixed_simulation","adaptive_simulation","survival_simulation","example"))launch(p,"imported")
    else tryCatch({results$imported<-execute_project(p)},error=function(e)showNotification(conditionMessage(e),type="error"))
  })
  selected<-reactive(switch(value(input$report_source,"fixed"),fixed=fixed(),power=power_result(),
    seq=seq(),seqsample=seqsample(),adaptive=adaptive(),survival=surv(),sim=sim(),survsim=survsim(),imported=results$imported,example=example()))
  output$scientific_review<-renderUI({
    tryCatch({
      tab<-value(input$workspace,"Design configuration")
      project<-switch(tab,
        "Group sequential designs"=make_project("sequential_design",c(list(engine=value(input$engine,"gsDesign")),seq_parameters()),"Review boundaries"),
        "Adaptive designs"=make_project("adaptive_simulation",list(effect=value(input$effect,.5),sd=value(input$sd,1),
          stage1=value(input$stage1,80),planned_total=value(input$planned,160),min_stage2=value(input$min2,40),max_stage2=value(input$max2,240),
          target_cp=value(input$targetcp,.8),alpha=value(input$gsalpha,.025),power=value(input$power,.8),nsim=value(input$nsim,1000),seed=value(input$seed,2026)),"Review adaptation"),
        "Survival studies"=make_project("survival_simulation",c(survival_parameters(),list(n_per_arm=value(input$n,64),events=if(value(input$events,0)==0)NULL else input$events,
          nsim=value(input$nsim,1000),seed=value(input$seed,2026),null=value(input$survnull,FALSE))),"Review survival simulation"),
        "Monte Carlo simulation"=make_project("fixed_simulation",c(fixed_parameters(),list(n_per_arm=value(input$n,64),nsim=value(input$nsim,1000),seed=value(input$seed,2026),null=value(input$null,TRUE))),"Review fixed simulation"),
        "Scenario comparison"=grid_projects()[[1]],
        "Projects and exports"=opened(),
        "Example library"=make_project("example",list(id=value(input$example,"TD-001"),nsim=value(input$nsim,1000),seed=value(input$seed,2026)),"Review example"),
        make_project("fixed_sample_size",fixed_parameters(),"Review fixed planning"))
      if(is.null(project))return(NULL)
      d<-review_project(project)
      if(tab=="Scenario comparison")d<-rbind(d,data.frame(field=c("Grid effects","Grid target powers","Scenario count"),
        value=c(value(input$grid_effects,"0.3,0.5"),value(input$grid_powers,"0.8,0.9"),as.character(length(grid_projects())))))
      extras<-switch(tab,
        "Group sequential designs"=if(value(input$endpoint,"normal")=="normal")list(make_project("sequential_means",c(list(effect=value(input$effect,.5),sd=value(input$sd,1)),seq_parameters()),"Integer enrollment")) else list(),
        "Survival studies"=list(make_project("survival_design",c(survival_parameters(),list(power=value(input$power,.8))),"Survival planning")),
        "Design configuration"=list(make_project("fixed_power",c(fixed_parameters(),list(n_per_arm=value(input$n,64))),"Power at selected enrollment")),list())
      review_table<-function(rows)tags$table(class="table",tags$tbody(lapply(seq_len(nrow(rows)),function(i)tags$tr(tags$th(scope="row",rows$field[i]),tags$td(rows$value[i])))))
      tags$details(id="scientific-contract",open="open",tags$summary("Review scientific assumptions before execution"),
        tags$table(class="table",tags$caption("Live specification; calculated results keep their own frozen settings"),
          tags$tbody(lapply(seq_len(nrow(d)),function(i)tags$tr(tags$th(scope="row",d$field[i]),tags$td(d$value[i]))))),
        lapply(extras,function(extra)tags$details(tags$summary(extra$title),review_table(review_project(extra)))))
    },error=function(e)div(role="alert",conditionMessage(e)))
  })
  output$specification<-renderPrint(specification())
  output$fixed_table<-renderTable({req(fixed());result_table(fixed())})
  output$fixed<-renderPrint({req(fixed());print(fixed());print(power_result())})
  output$sequential_result<-renderPrint(seq());output$sequential_plot<-renderPlot({req(seq());plot_design(seq())})
  output$seqsample_table<-renderTable({req(seqsample());result_table(seqsample())});output$seqsample_result<-renderPrint(seqsample())
  output$adaptive_result<-renderPrint({req(adaptive());print(adaptive())})
  output$survival_result<-renderPrint(surv());output$survsim_result<-renderPrint({req(survsim());print(survsim())})
  output$simulation_result<-renderPrint({req(sim());print(sim())});output$simulation_plot<-renderPlot({req(sim());plot_design(sim())})
  output$comparison<-renderTable(comparison());output$example_result<-renderPrint(example())
  output$example_assumptions<-renderPrint({catalog<-utils::read.csv(system.file("examples/catalog.csv",package="OpenTrialDesign"));print(catalog[catalog$id==input$example,])})
  output$job_status<-renderText(job_message())
  output$capabilities<-renderTable(runtime_diagnostics())
  output$snapshot<-renderPrint({x<-selected();req(x);print(if(!is.null(x$project))x$project else x$specification)})
  output$project_execute<-renderUI({if(is.null(opened()))helpText("Open a valid project to enable execution.") else actionButton("runproject","Execute opened project")})
  output$import_preview<-renderPrint({if(!is.null(import_error()))cat(import_error()) else {req(opened());print(opened())}})
  output$downloads<-renderUI({x<-selected();if(is.null(x))return(helpText("Calculate or execute a project first."));tagList(
    if(!is.null(x$project))downloadButton("project","Save project JSON"),
    downloadButton("csv","Export CSV"),downloadButton("bundle","Download reproducibility bundle"))})
  output$report_help<-renderText({caps<-runtime_diagnostics();format<-value(input$report_format,"html")
    if(!caps$usable[caps$capability=="Pandoc"])"Install Pandoc to render reports."
    else if(format=="pdf"&&!caps$usable[caps$capability=="LaTeX"])"PDF is unavailable: install a LaTeX engine or choose HTML." else ""})
  output$report_download<-renderUI({x<-selected();req(x);caps<-runtime_diagnostics();format<-value(input$report_format,"html")
    if(!caps$usable[caps$capability=="Pandoc"]||(format=="pdf"&&!caps$usable[caps$capability=="LaTeX"]))return(NULL)
    downloadButton("report","Download methodological report")})
  output$project<-downloadHandler(filename=function()"OpenTrialDesign-project.json",content=function(file){req(selected()$project);write_project(selected()$project,file)})
  output$csv<-downloadHandler(filename=function()"OpenTrialDesign-results.csv",content=function(file)utils::write.csv(result_table(selected()),file,row.names=FALSE))
  output$bundle<-downloadHandler(filename=function()"OpenTrialDesign-bundle.zip",content=function(file)export_bundle(selected(),file,include_report=FALSE))
  output$report<-downloadHandler(filename=function()paste0("OpenTrialDesign-report.",value(input$report_format,"html")),content=function(file)render_report(selected(),file,value(input$report_format,"html")))
  output$guide<-downloadHandler(filename=function()"OpenTrialDesign-user-guide.html",content=function(file){
    guide<-system.file("doc/user-guide.html",package="OpenTrialDesign")
    if(!nzchar(guide))stop("Install the built source package to include the rendered user guide.")
    file.copy(guide,file)
  })
}
shinyApp(ui,server)
