#!/usr/bin/env nextflow
nextflow.enable.dsl=2

process splitInputFile {

  input:
    path inputFile
    val downloadsPerSplit

  output:
    path 'smaller*'         

  script:
    template 'splitInputFile.bash'
}

process downloadAndCheck {

  input:
    path inputFile
    val ebiFtpUser
    val ebiFtpPassword

  output:
    path 'needsUpdate.txt'         

  script:
    template 'checkForUpdates.bash'
}

workflow checkForUpdate {
  take:
    inputFile

  main:

    splitInputFileResults = splitInputFile(inputFile, params.downloadsPerSplit).collect().flatten()
    downloadAndCheckResults = downloadAndCheck(splitInputFileResults, params.ebiFtpUser, params.ebiFtpPassword)
    downloadAndCheckResults.collectFile(name: 'needsUpdate.txt', storeDir: params.outputDir)
        
}