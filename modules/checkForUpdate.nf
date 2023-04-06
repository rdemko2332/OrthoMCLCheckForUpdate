#!/usr/bin/env nextflow
nextflow.enable.dsl=2

process downloadAndCheck {
  publishDir "$params.outputDir"

  input:
    path inputFile

  output:
    path 'needsUpdate.txt'         

  script:
    template 'checkForUpdates.bash'
}

workflow checkForUpdate {
  take:
    inputFile

  main:

    downloadAndCheck(inputFile)
        
}