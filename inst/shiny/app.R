library(shiny)
library(OpenTrialDesign)
ui <- fluidPage(titlePanel("OpenTrialDesign"),
  sidebarLayout(sidebarPanel(
    selectInput("endpoint", "Endpoint", c("normal", "binary")),
    numericInput("effect", "Treatment minus control effect", 0.15, step = 0.05),
    numericInput("sd", "Common standard deviation", 1, min = 0.01),
    numericInput("pcontrol", "Control response probability", 0.3, min = 0.01, max = 0.99),
    selectInput("alternative", "Alternative hypothesis", c("two.sided", "greater", "less")),
    numericInput("alpha", "Total fixed-design alpha", 0.05, min = 0.001, max = 0.2),
    numericInput("power", "Target power", 0.8, min = 0.5, max = 0.99),
    numericInput("n", "Participants per arm", 200, min = 2),
    numericInput("nsim", "Monte Carlo replications", 1000, min = 2),
    numericInput("seed", "Random seed", 2026, min = 0),
    actionButton("calculate", "Calculate fixed design")),
  mainPanel(tabsetPanel(
    tabPanel("Design configuration", p("Equal allocation superiority trials. Effects are treatment minus control. Directional alternatives must agree with the effect. Survival uses treatment/control hazard ratio."), verbatimTextOutput("specification")),
    tabPanel("Sample size and power", verbatimTextOutput("fixed")),
    tabPanel("Group sequential designs",
      selectInput("engine", "Scientific engine", c("gsDesign", "rpact")),
      selectInput("spending", "Alpha spending", c("OF", "Pocock")),
      selectInput("futility", "Futility rule", c("none", "binding", "nonbinding")),
      numericInput("gsalpha", "One-sided efficacy alpha", .025, min = .001, max = .2),
      actionButton("sequential", "Calculate two-look design"),
      verbatimTextOutput("sequential_result"), plotOutput("sequential_plot")),
    tabPanel("Adaptive designs", p("Two-stage inverse-normal combination procedure, fixed combination weights, conditional-power resizing. Both null and alternative scenarios are simulated."),
      numericInput("stage1", "First-stage total enrollment", 80, min = 4, step = 2),
      numericInput("planned", "Planned total enrollment", 160, min = 8, step = 2),
      numericInput("min2", "Minimum additional stage-two enrollment", 40, min = 4, step = 2),
      numericInput("max2", "Maximum additional stage-two enrollment", 240, min = 4, step = 2),
      actionButton("adaptive", "Simulate adaptive procedure"), verbatimTextOutput("adaptive_result")),
    tabPanel("Survival studies", numericInput("hr", "Treatment/control hazard ratio", .7, min = .01, max = .99),
      numericInput("median", "Control median survival", 12, min = .01),
      numericInput("accrual", "Uniform accrual duration", 18, min = .01),
      numericInput("followup", "Additional follow-up", 12, min = .01),
      numericInput("dropout", "Dropout probability by time 12", 0, min = 0, max = .99),
      actionButton("survival", "Plan survival study"),
      checkboxInput("survnull", "Simulate equality null", FALSE),
      actionButton("survsim", "Simulate survival study"),
      verbatimTextOutput("survival_result"), verbatimTextOutput("survsim_result")),
    tabPanel("Monte Carlo simulation", checkboxInput("null", "Equality-null scenario", TRUE),
      actionButton("simulate", "Simulate fixed trial"), verbatimTextOutput("simulation_result"), plotOutput("simulation_plot")),
    tabPanel("Scenario comparison", p("Compare target power 80% and 90% for the current fixed specification."),
      actionButton("compare", "Compare scenarios"), tableOutput("comparison")),
    tabPanel("Scientific reporting", selectInput("report_source", "Result to report",
      c("Fixed" = "fixed", "Sequential" = "seq", "Adaptive" = "adaptive", "Survival" = "survival", "Simulation" = "sim")),
      downloadButton("report", "Download HTML methodological report")),
    tabPanel("Example library", selectInput("example", "Provisional scientific catalog", sprintf("TD-%03d", 1:30)),
      actionButton("runexample", "Execute example"), verbatimTextOutput("example_assumptions"), verbatimTextOutput("example_result")),
    tabPanel("User guide", p("Start with a fixed specification, calculate enrollment, then assess power and the equality null by simulation. Monte Carlo intervals quantify simulation uncertainty. Sequential alpha is one-sided and separate from fixed total alpha. Binding futility must be followed. Adaptive resizing uses the inverse-normal procedure; it does not justify resizing an ordinary pooled test. All survival times share one unit. Computational verification is not independent scientific validation."))
  ))))
server <- function(input, output, session) {
  safe <- function(expr) tryCatch(expr, error = function(e) {
    validate(need(FALSE, conditionMessage(e)))
  })
  specification <- reactive(safe(trial_spec(input$endpoint, input$effect, input$sd,
    input$pcontrol, input$alpha, input$power, input$alternative)))
  fixed <- eventReactive(input$calculate, safe(sample_size(specification())))
  seq <- eventReactive(input$sequential, safe(sequential_design(input$engine,
    alpha = input$gsalpha, power = input$power, spending = input$spending, futility = input$futility)))
  adaptive <- eventReactive(input$adaptive, safe(adaptive_simulation(effect = input$effect,
    sd = input$sd, stage1 = input$stage1, planned_total = input$planned,
    min_stage2 = input$min2, max_stage2 = input$max2, alpha = input$gsalpha,
    nsim = input$nsim, seed = input$seed)))
  surv <- eventReactive(input$survival, safe(survival_design(input$hr, input$median,
    input$accrual, input$followup, input$dropout, alpha = input$gsalpha, power = input$power)))
  survsim <- eventReactive(input$survsim, safe(simulate_survival(input$n, input$hr,
    input$median, input$accrual, input$followup, input$dropout,
    alpha = input$gsalpha, nsim = input$nsim, seed = input$seed, null = input$survnull)))
  sim <- eventReactive(input$simulate, safe(simulate_trial(specification(), input$n,
    input$nsim, input$seed, input$null)))
  comparison <- eventReactive(input$compare, safe({
    s <- specification()
    compare_scenarios(list(`80% power` = trial_spec(s$endpoint,s$effect,s$sd,s$p_control,s$alpha,.8,s$alternative),
      `90% power` = trial_spec(s$endpoint,s$effect,s$sd,s$p_control,s$alpha,.9,s$alternative)))
  }))
  example <- eventReactive(input$runexample, safe(run_example(input$example, input$nsim, input$seed)))
  output$specification <- renderPrint(specification())
  output$fixed <- renderPrint({print(fixed()); print(safe(trial_power(fixed()$specification, input$n)))})
  output$sequential_result <- renderPrint(seq())
  output$sequential_plot <- renderPlot(plot_design(seq()))
  output$adaptive_result <- renderPrint(adaptive())
  output$survival_result <- renderPrint(surv())
  output$survsim_result <- renderPrint(survsim())
  output$simulation_result <- renderPrint(sim())
  output$simulation_plot <- renderPlot(plot_design(sim()))
  output$comparison <- renderTable(comparison())
  output$example_result <- renderPrint(example())
  output$example_assumptions <- renderPrint({
    catalog <- utils::read.csv(system.file("examples/catalog.csv", package = "OpenTrialDesign"))
    print(catalog[catalog$id == input$example, ])
  })
  output$report <- downloadHandler(filename = function() "OpenTrialDesign-report.html",
    content = function(file) {
      x <- switch(input$report_source, fixed = fixed(), seq = seq(), adaptive = adaptive(),
        survival = surv(), sim = sim())
      render_report(x, file, "html")
    })
}
shinyApp(ui, server)
