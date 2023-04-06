#!/usr/bin/env nextflow
nextflow.enable.dsl=2

//--------------------------------------------------------------------------
// Param Checking
//--------------------------------------------------------------------------

if(!params.inputFile) {
  throw new Exception("Missing params.inputFile")
}

//--------------------------------------------------------------------------
// Includes
//--------------------------------------------------------------------------

include { checkForUpdate } from './modules/checkForUpdate.nf'

//--------------------------------------------------------------------------
// Main Workflow
//--------------------------------------------------------------------------

workflow {
  checkForUpdate(params.inputFile)
}