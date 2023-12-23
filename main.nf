process downloadFASTQ {
  input:
    val srr_acc

  script:
  "prefetch $srr_acc"
}

workflow {
  Channel.fromPath(params.srr_acc_file).splitText() | downloadFASTQ
}
