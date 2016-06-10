#' @title domino.snapshot
#' @name domino.snapshot
#'
#' @description take a snapshot of your command history and workspace.
#'
#' @param commitMessage A committ message to record with you snapshot
#'
#' @import grDevices
#' @import utils
#'
#' @export


domino.snapshot <- function(commitMessage) {
    if(missing(commitMessage)) {
        stop("Please provide a commit message to record with your snapshot", call.=FALSE)
    }
    savehistory(file="snapshot_command_history.txt")
    save.image(file="snapshot_workspace.RData")

    # save a plot
    plot_file = "snapshot_plot.png"
    if (file.exists(plot_file)) {
      file.remove(plot_file)
    }
    # 1 is the NULL device
    if (dev.cur() != 1) {
      new_device = dev.copy(png, filename="plot_snapshot.png")
      dev.set(new_device)
      dev.off()
    }


    domino.upload(commitMessage)
}
