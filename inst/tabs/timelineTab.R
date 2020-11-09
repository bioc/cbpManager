timelineTab <- tabItem(
  tabName = "timelines",
  h2("Timelines"),
  fluidRow(
    column(width = 4,
           box(width = NULL,
               title="Description",
               htmltools::HTML(
                 "<p><b>Visualization of timeline data of a patient.</b> The timeline data is a representation of the various events that occur during the course of treatment for a patient from initial diagnosis. In cBioPortal timeline data is represented as one or more tracks in the patient view. This application produces separate files for treatment, surgery and status events (see tables below). Add a treatment, a surgery or a status to a patient by providing the Patient ID and the necessary dates. The event timepoints are calculated in *days from the date of diagnosis. The 'Date of the first Diagnosis' act as point zero on the timeline scale. </br> To add an event click on the <b>New</b> button and fill out the necessary fields. </br> By selecting a row you can <b>Edit</b> or <b>Delete</b> the event. </br><b>Note</b>: When editing an event the correct dates should be set again.</br>When you managed the events of a table, <b>Save</b> the table to make the changes persistent. This will produce the necessary files.</p>"
               )
           )
    ),
    column(width = 8,
           box(width = NULL,
               tags$head(
                 tags$style(
                   type="text/css",
                   "#timelineDataImg img {max-width: 100%; width: 100%; height: auto}"
                 )
               ),
               imageOutput("timelineDataImg", height = "auto")
           ),
           box(width = NULL,
               title = "Add date of the first diagnosis to a Patient ID",
               actionButton("datesAdd", "Add date"),
               actionButton("datesEdit", "Edit date"),
               actionButton("datesDelete", "Delete date"),
               actionButton("datesSave", "Save", class = "btn-success"),
               br(), br(),
               DT::DTOutput("dateTable")
               )
           )
    ),
  tabsetPanel(type="tabs",
              tabPanel(title="Treatment",
                       fluidRow(
                         width = 12,
                         box(
                           title="Add treatment to timeline",
                           add_rowUI("Treatment"),
                           edit_rowUI("Treatment"),
                           delete_rowUI("Treatment"),
                           add_columnUI("Treatment"),
                           delete_columnUI("Treatment"),
                           save_timelineUI("Treatment"),
                           br(), br(),
                           DT::DTOutput("treatmentTable"),
                           tableOutput("data"),
                           width = 12
                         )
                       )
              ),
              tabPanel(title="Surgery",
                       fluidRow(
                         width = 12,
                         box(
                           title="Add surgery to timeline",
                           add_rowUI("Surgery"),
                           edit_rowUI("Surgery"),
                           delete_rowUI("Surgery"),
                           add_columnUI("Surgery"),
                           delete_columnUI("Surgery"),
                           save_timelineUI("Surgery"),
                           br(), br(),
                           DT::DTOutput("surgeryTable"),
                           width = 12
                         )
                       )
              ),
              tabPanel(title="Status",
                       fluidRow(
                         width = 12,
                         box(
                           title="Add status to timeline",
                           add_rowUI("Status"),
                           edit_rowUI("Status"),
                           delete_rowUI("Status"),
                           add_columnUI("Status"),
                           delete_columnUI("Status"),
                           save_timelineUI("Status"),
                           br(), br(),
                           DT::DTOutput("statusTable"),
                           width = 12
                         )
                       )
              )
  )
  # ,
  # fluidRow(
  #   width = 12,
  #   box(
  #     width = 12,
  #     title="Add custom timeline track",
  #     div(style="display: inline-block;vertical-align:top; width: 200px;",textInput("customTrackID", label = NULL, width = "400px", placeholder = "Name of timeline track")),
  #     div(style="display: inline-block;vertical-align:top; width: 200px;",actionButton("addTrack", "Add track")),
  #     uiOutput("customTracksUI"))
  # )
)