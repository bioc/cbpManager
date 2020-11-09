# image
output$patientDataImg <- renderImage({
  return(list(src = system.file("www", "patient-data.PNG", package = "cbpManager"),contentType = "image/png",alt = "patient-data-image", width="auto"))
}, deleteFile = FALSE)

# reactive list with PATIENT_IDs from data_clinical_patient
patient_id_list <- reactiveValues(ids = NULL)
observeEvent(loadedData$data_clinical_patient, {
  ids <- loadedData$data_clinical_patient[3:nrow(loadedData$data_clinical_patient), "PATIENT_ID"]
  patient_id_list$ids <- ids[!is.na(ids)]
})

#Data table output
output$patientTable <- DT::renderDT({
  if(!is.null(loadedData$data_clinical_patient)){
    DT::datatable(loadedData$data_clinical_patient,
              selection = 'single',
              rownames = F, options = list(pageLength = 25, dom = 'ltipr', scrollX = TRUE)) %>%
      DT::formatStyle('PATIENT_ID', target = 'row', backgroundColor = DT::styleEqual(c("Patient Identifier", "Patient identifier"), c('lightblue', 'lightblue')))
  }
})

# add patient ####

# output reactive UIs per column
output$AddPatientUIs <- renderUI({
  lapply(colnames(loadedData$data_clinical_patient),
         function(colname){
           generateUIwidgets(colname, mode = "add", tab = "Patient")
          })
})


# show modalDialog for new patient
observeEvent(input$NewPatient,
             showModal(
               modalDialog(
                 title = "Add patient",
                 # fluidPage(
                 #   PatientTabUI$AddPatientInputList
                 # ),
                 uiOutput("AddPatientUIs"),
                 easyClose = FALSE,
                 footer = tagList(
                   modalButton("Cancel"),
                   actionButton("ModalbuttonAddPatient", "Add")
                 )
               )
             )
)
# validate inputs in modalDialog and add new patient to table
observeEvent(input$ModalbuttonAddPatient, {
  all_reactive_inputs <- reactiveValuesToList(input)
  addPatientValues <- all_reactive_inputs[grep("addPatientInput_",names(all_reactive_inputs))]
  names(addPatientValues) <- gsub("addPatientInput_", "", names(addPatientValues))
  if(addPatientValues["PATIENT_ID"]==""){
    showNotification("PATIENT_ID cannot be empty.", type="error", duration = NULL)
  } else if(!grepl("^[a-zA-Z0-9\\.\\_\\-]*$", addPatientValues["PATIENT_ID"])){
    showNotification("PATIENT_ID allows only numbers, letters, points, underscores and hyphens.", type="error", duration = NULL)
  } else if(addPatientValues["PATIENT_ID"] %in% patient_id_list$ids){
    showNotification("PATIENT_ID already exists.", type="error", duration = NULL)
  } else {
    loadedData$data_clinical_patient <- rbind(loadedData$data_clinical_patient, addPatientValues)
    removeModal()
  }
})

# edit patient ####
# output reactive UIs per column
output$EditPatientUIs <- renderUI({
  lapply(colnames(loadedData$data_clinical_patient),
         function(colname){
           generateUIwidgets(colname, mode = "edit", tab = "Patient", data = loadedData$data_clinical_patient, selected_row = input$patientTable_rows_selected, patientIDs = patient_id_list$ids)
         })
})
# ModalDialog for editing a patient
observeEvent(input$EditPatient,{
  if(is.null(input$patientTable_rows_selected)){
    showNotification("Please select a row", type="warning", duration = NULL)
    #} else if(input$patientTable_rows_selected == 1 | input$patientTable_rows_selected == 2){
    #  showNotification("Please select a row with a patient", type="warning", duration = NULL)
  } else {
    showModal(
      modalDialog(
        title = "Edit patient",
        uiOutput("EditPatientUIs"),
        easyClose = FALSE,
        footer = tagList(
          modalButton("Cancel"),
          actionButton("ModalbuttonEditPatient", "Edit")
        )
      )
    )
  }
}, ignoreInit = T)

# validate edits and change values in the table
observeEvent(input$ModalbuttonEditPatient, {
  all_reactive_inputs <- reactiveValuesToList(input)
  editPatientValues <- all_reactive_inputs[grep("editPatientInput_",names(all_reactive_inputs))]
  names(editPatientValues) <- gsub("editPatientInput_", "", names(editPatientValues))
  if(editPatientValues["PATIENT_ID"]==""){
    showNotification("PATIENT_ID cannot be empty.", type="error", duration = NULL)
  }
  # else if(editPatientValues["PATIENT_ID"] %in% patient_id_list$ids[-which(patient_id_list$ids == editPatientValues$PATIENT_ID)]){
  #   showNotification("PATIENT_ID already exists.", type="error", duration = NULL)
  # }
  else {
    for(i in colnames(loadedData$data_clinical_patient)){
      loadedData$data_clinical_patient[input$patientTable_rows_selected,i] <- editPatientValues[i]
    }
    removeModal()
  }
})

# delete patient ####
observeEvent(input$DeletePatient, {
  if(is.null(input$patientTable_rows_selected)){

    showNotification("Please select a row", type="warning", duration = NULL)
  } else if(input$patientTable_rows_selected == 1 | input$patientTable_rows_selected == 2){
    showNotification("Selected row cannot be deleted", type="error", duration = NULL)
  } else {
    showModal(modalDialog(
      "Do you want to delete the selected patient entry?",
      title = "Delete",
      easyClose = FALSE,
      footer = tagList(
        modalButton("Cancel"),
        actionButton("ModalbuttonDeletePatient", "Delete")
      )
    ))
  }
})
observeEvent(input$ModalbuttonDeletePatient, {
  entry <- input$patientTable_rows_selected

  loadedData$data_clinical_patient <- loadedData$data_clinical_patient[-entry,,drop = FALSE]
  removeModal()
})

# add column ####
# ModalDialog for adding a column
observeEvent(input$AddColumnPatient,{
  showModal(
    modalDialog(
      title = "Add new column(s)",
      fluidRow(column(
        width = 8,
        radioButtons("AddColPatientMode", label = "",
                     choices = list("Choose from pre-defined columns" = 1, "Add custom column" = 2),
                     selected = 1))),
      uiOutput("AddColPatientUI"),
      easyClose = FALSE,
      footer = tagList(
        modalButton("Cancel"),
        actionButton("ModalbuttonAddColPatient", "Add column(s)")
      )
    ))
}, ignoreInit = T)
# output UI to select column that should be deleted
output$AddColPatientUI <- renderUI({
  if(input$AddColPatientMode == 1){
    fluidRow(column(
      width = 8,
      selectInput(inputId="SelColnamePat",
                  label = "Select pre-defined column(s)",
                  choices = c(patientCols$colname),
                  multiple = TRUE
      ))
    )
  } else if (input$AddColPatientMode == 2){
    fluidRow(column(
      width = 8,
      textInput(inputId="colnamePat",
                label = "Column name:",
                placeholder = "e.g. ATTRIBUTE"
      ),
      textInput(inputId="visShortNamePat",
                label = "Short name (visible in cBioPortal):",
                placeholder = "e.g. Attr."
      ),
      textInput(inputId="visLongNamePat",
                label = "Long name (visible in cBioPortal):",
                placeholder = "e.g. Attribute of patient"
      ))
    )
  }
})

observeEvent(input$ModalbuttonAddColPatient, {
  if(input$AddColPatientMode == 1){
    if(is.null(input$SelColnamePat)){
      showNotification("Please select a column.", type="error", duration = NULL)
    } else {
      # prevent overwriting existing columns
      colsToAdd <-input$SelColnamePat[!input$SelColnamePat%in%names(loadedData$data_clinical_patient)]

      loadedData$data_clinical_patient[colsToAdd] <- list("")
      for(col in colsToAdd){
        loadedData$data_clinical_patient[1,col] <- patientCols[which(patientCols$colname == col), "shortColname"]
        loadedData$data_clinical_patient[2,col] <- patientCols[which(patientCols$colname == col), "longColname"]
      }
      removeModal()
    }
  } else if (input$AddColPatientMode == 2){
    if(input$colnamePat == ""){
      showNotification("Column name cannot be empty.", type="error", duration = NULL)
    } else if(input$visShortNamePat == ""){
      showNotification("Short name cannot be empty.", type="error", duration = NULL)
    } else if(input$visLongNamePat == ""){
      showNotification("Long name cannot be empty.", type="error", duration = NULL)
    } else if(toupper(input$colnamePat) %in% colnames(loadedData$data_clinical_patient)){
      showNotification("Column already exists.", type="error", duration = NULL)
    } else {
      colname <- .create_name(input$colnamePat)
      loadedData$data_clinical_patient %<>% mutate(!!(colname) := "")
      loadedData$data_clinical_patient[1,colname] <- input$visShortNamePat
      loadedData$data_clinical_patient[2,colname] <- input$visLongNamePat
      removeModal()
    }
  }
})

# delete column ####
observeEvent(input$DeleteColumnPatient, {
  showModal(modalDialog(
    title = "Delete column(s)",
    fluidRow(column(
      width = 8,
      selectInput(inputId="DelColnamePat",
                  label = "Select column(s) for deletion:",
                  choices = setdiff(colnames(loadedData$data_clinical_patient), "PATIENT_ID"),
                  multiple = TRUE
      ))
    ),
    easyClose = FALSE,
    footer = tagList(
      modalButton("Cancel"),
      actionButton("ModalbuttonDeleteColPatient", "Delete column(s)")
    )
  ))
})
observeEvent(input$ModalbuttonDeleteColPatient, {
  loadedData$data_clinical_patient <- loadedData$data_clinical_patient[,!(names(loadedData$data_clinical_patient) %in% input$DelColnamePat), drop = FALSE]
  removeModal()
})
# save patient table ####
observeEvent(input$SaveDataPatient, {
  # data_clinical_patient
  df <- convertDataFrame(loadedData$data_clinical_patient)
  df[df==""]<-NA

  write.table(df, file.path(study_dir, input$cancer_study_identifier, "data_clinical_patient.txt.temp"), append = FALSE, sep = "\t",
              row.names = FALSE, col.names = FALSE, quote = FALSE, na="")
  file.rename(file.path(study_dir, input$cancer_study_identifier, "data_clinical_patient.txt.temp"), file.path(study_dir, input$cancer_study_identifier, "data_clinical_patient.txt"))
  # meta_clinical_patient
  meta_patient_df <- data.frame(V1 = c("cancer_study_identifier", "genetic_alteration_type", "datatype", "data_filename"),
                                V2 = c(input$cancer_study_identifier, "CLINICAL", "PATIENT_ATTRIBUTES", "data_clinical_patient.txt")
  )
  write.table(meta_patient_df, file.path(study_dir, input$cancer_study_identifier, "meta_clinical_patient.txt.temp"), append = FALSE, sep = ": ", row.names = FALSE, col.names = FALSE, quote = FALSE)
  file.rename(file.path(study_dir, input$cancer_study_identifier, "meta_clinical_patient.txt.temp"), file.path(study_dir, input$cancer_study_identifier, "meta_clinical_patient.txt"))
  showNotification("Patient data saved successfully!", type="message", duration = 10)
}, ignoreInit = T)