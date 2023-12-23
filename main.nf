process downloadFASTQ {
  input:
    val SRR_ACC

  script:
  "prefetch $SRR_ACC"
}

workflow {
  Channel.fromPath("SRR_Acc_List.txt").splitText() | downloadFASTQ
}
